/*
    Copyright (C) 2009 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License version 3 as published
    by the Free Software Foundation, or optionally, under the terms of the
    Common Public License version 1.0 as published by IBM.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License, or the Common Public License, for more details.

    You should have received copies of the GNU General Public License
    and the Common Public License along with this program.  If not,
    see <http://www.gnu.org/licenses/> or
    <http://www.ibm.com/developerworks/library/os-cpl.html/> respectively.
*/

#include <string.h>
#include <stdlib.h>
#include <assert.h>

#include "jmi_brent_solver.h"
#include "jmi_block_solver_impl.h"
#include "jmi_block_log.h"

#include "jmi_brent_search.h"

#define BRENT_BASE_LOG_LEVEL 7     /* Minimal Brent printouts log level */
#define BRENT_EXTENDED_LOG_LEVEL 8 /* Extended Brent printouts log level */

#define BRENT_INITIAL_STEP_FACTOR 0.001 /* Initial bracketing step as a fraction of nominal */
#define BRENT_MAX_NEWTON 10 /* Max number of Newton iteration */
#define BRENT_INF 1e20
#define BRENT_SIGNIFICANT_DECREASE 0.01 /* Value used in Newton for determining if the values should be used or not */
#define BRENT_SMALL_RESIDUAL_FACTOR 1e3

/* Interface to the residual function that is compatible with Brent search.
   @param y - input - function argument
   @param f - output - residual value
   @param problem_data - solver object propagated as opaques data
*/
int brentf(jmi_real_t y, jmi_real_t* f, void* problem_data) {
    jmi_block_solver_t *block = (jmi_block_solver_t*)problem_data;
    int ret = 0;
    
    /* Increment function calls counter */
    block->nb_fevals++;

    /* Check that arguments are valid */
    ret = jmi_check_and_log_illegal_iv_input(block, &y, 1);
    if (ret == -1) {
        return -1;
    }

    /*Evaluate the residual*/
    ret = block->F(block->problem_data,&y,f,JMI_BLOCK_EVALUATE);
    if (ret) {
        jmi_log_t* log = block->log;
        jmi_log_node_t node = 
            jmi_log_enter_fmt(log, logWarning, "Warning", "<errorCode: %d> returned when calling residual function in <block: %s>", ret, block->label);
        jmi_log_reals(log, node, logWarning, "ivs", &y, 1);
        jmi_log_leave(log, node);
        return ret;
    }
    /* Check that outputs are valid */    
    {
        double heuristic_nominal = BIG_REAL/JMI_LIMIT_VALUE;
        ret = jmi_check_and_log_illegal_residual_output(block, f, &y, &heuristic_nominal,1);
    }
    return ret;
}

int brentdf(jmi_real_t y, jmi_real_t f, jmi_real_t* df, void* problem_data) {
    jmi_block_solver_t *block = (jmi_block_solver_t*)problem_data;
    int ret = 0;
    jmi_real_t y0 = y, ftemp, inc;
    int sign;

    /* Check that arguments are valid */
    ret = jmi_check_and_log_illegal_iv_input(block, &y, 1);
    if (ret == -1) {
        return -1;
    }
        
    if (block->dF) {
        /* utilize directional derivatives to calculate Jacobian */
        block->dx[0] = 1;
        ret = block->dF(block->problem_data,&y,block->dx,&f,block->dres,JMI_BLOCK_EVALUATE);
        *df = block->dres[0];
        block->dx[0] = 0;
        
        if (ret) {
            jmi_log_t* log = block->log;
            jmi_log_node_t node = 
                jmi_log_enter_fmt(log, logWarning, "Warning", "<errorCode: %d> returned when calling directional derivative function in <block: %s>", ret, block->label);
            jmi_log_reals(log, node, logWarning, "ivs", &y, 1);
            jmi_log_leave(log, node);
            return ret;
        }
    } else {
        sign = (y >= 0)  ? 1 : -1;
        inc = JMI_MAX(JMI_ABS(y), block->nominal[0])*sign*1e-8;
        y += inc;
        /* make sure we're inside bounds*/
        if(block->options->enforce_bounds_flag && ((y > block->max[0]) || (y < block->min[0]))) {
            inc = -inc;
            y = y0 + inc;
        }

        ret = brentf(y, &ftemp, block);

        /* If function evaluation failed, try finite difference in other direction. */
        if (ret) {
            inc = -inc;
            y = y0 + inc;
            if (block->options->enforce_bounds_flag && ((y <= block->max[0]) && (y >= block->min[0]))) {
                ret = brentf(y, &ftemp, block);
            }
        }

        if (ret) {
            jmi_log_t* log = block->log;
            jmi_log_node_t node = 
                jmi_log_enter_fmt(log, logWarning, "Warning", "<errorCode: %d> returned when calling residual function in <block: %s>", ret, block->label);
            jmi_log_reals(log, node, logWarning, "ivs", &y, 1);
            jmi_log_leave(log, node);
            return ret;
        }
        
        *df = (ftemp-f)/inc;
    }
    
    /* Check that outputs are valid */    
    {
        jmi_real_t v = *df;
        if (v- v != 0) {
             jmi_log_t* log = block->log;
             jmi_log_node_t node = jmi_log_enter_fmt(block->log, logWarning, "NaNOutput", "Not a number in derivative from <block: %s>", block->label);
             jmi_log_reals(log, node, logWarning, "ivs", &y, 1);
             jmi_log_leave(log, node);
             ret = 1;
        }
    }

    return ret;
}

/* Initialize solver structures 

block->options->use_Brent_in_1d_flag
solver->kin_stol = block->options->min_tol;
*/


int jmi_brent_solver_new(jmi_brent_solver_t** solver_ptr, jmi_block_solver_t* block) {
    jmi_brent_solver_t* solver;
    int flag = 0;
    
    solver = (jmi_brent_solver_t*)calloc(1,sizeof(jmi_brent_solver_t));
    if (!solver) return -1;
         
    *solver_ptr = solver;
    return flag;
}

void jmi_brent_solver_delete(jmi_block_solver_t* block) {
    jmi_brent_solver_t* solver = block->solver;
    
    /*Deallocate struct */
    free(solver);
    block->solver = 0;
}

void jmi_brent_solver_print_solve_start(jmi_block_solver_t *block,
                                        jmi_log_node_t *destnode) {
    if (block->callbacks->log_options.log_level >= BRENT_BASE_LOG_LEVEL) {
        jmi_log_t *log = block->log;
        *destnode = jmi_log_enter_fmt(log, logInfo, "BrentSolve", 
                                      "Brent solver invoked for <block:%s> with <variable:#r%d#>",
                                      block->label, block->value_references[0]);
    }
}

const char* jmi_brent_flag_to_name(int flag) {
    switch(flag) {
    case JMI_BRENT_MEM_FAIL: return "BRENT_MEM_FAIL";
    case JMI_BRENT_ILL_INPUT: return "BRENT_ILL_INPUT";
    case JMI_BRENT_SYSFUNC_FAIL: return "BRENT_SYSFUNC_FAIL";
    case JMI_BRENT_FIRST_SYSFUNC_ERR: return "JMI_BRENT_FIRST_SYSFUNC_ERR";
    case JMI_BRENT_REPTD_SYSFUNC_ERR: return "JMI_BRENT_REPTD_SYSFUNC_ERR";
    case JMI_BRENT_ROOT_BRACKETING_FAILED: return "BRENT_ROOT_BRACKETING_FAILED";
    case JMI_BRENT_FAILED: return "BRENT_FAILED";
    case JMI_BRENT_SUCCESS: return "BRENT_SUCCESS";
    default: return "BRENT_ERROR";
    }
}

void jmi_brent_solver_print_solve_end(jmi_block_solver_t *block, const jmi_log_node_t *node, int flag) {
    /* jmi_brent_solver_t* solver = block->solver; */

    /* NB: must match the condition in jmi_brent_solver_print_solve_start exactly! */
    if (block->callbacks->log_options.log_level >= BRENT_BASE_LOG_LEVEL) {
        jmi_log_t *log = block->log;
        const char *flagname = jmi_brent_flag_to_name(flag);
        if (flagname != NULL) jmi_log_fmt_(log, *node, logInfo, "Brent solver finished with <brent_exit_flag:%s>. ", flagname);
        else jmi_log_fmt_(log, *node, logInfo, "Brent solver finished with unrecognized <brent_exit_flag:%d>. ", flag);
        jmi_log_fmt_(log, *node, logInfo, "<solution:%g>", block->x[0]);
        jmi_log_leave(log, *node);
    }
}

int jmi_brent_test_best_guess(jmi_block_solver_t *block, double xBest, double fBest) {
    /* Calculate scaling */
    int flag;
    double dfBest = 0.0;
    double scaled_max_norm = 0;

    jmi_block_solver_options_t* bsop = block->options;
    flag = brentdf(xBest, fBest, &dfBest, block);
    DENSE_ELEM(block->J, 0, 0) = dfBest;
    jmi_update_f_scale(block);
        
    flag = jmi_scaled_vector_norm(&fBest, N_VGetArrayPointer(block->f_scale), block->n, JMI_NORM_MAX, &scaled_max_norm);
    
    if(flag != -1 && JMI_ABS(scaled_max_norm) <= bsop->res_tol) {
        if (block->callbacks->log_options.log_level >= BRENT_BASE_LOG_LEVEL)
            jmi_log_node(block->log, logInfo, "BrentSmallestResidualSuccess", 
                    "The smallest scaled residual computed, <res_scaled: %f>, is small enough in <block: %s>", scaled_max_norm, block->label);
        return JMI_BRENT_SUCCESS;
    } else {
        if (block->callbacks->log_options.log_level >= BRENT_BASE_LOG_LEVEL)
            jmi_log_node(block->log, logInfo, "BrentSmallestResidualFailure", 
            "The smallest scaled residual computed is not good enough in <block: %s>. Scaled residual <res_scaled: %f>, <iv_lower_bound: %f>, <tolerance: %f> ", block->label, scaled_max_norm, xBest, bsop->res_tol);
        return JMI_BRENT_FAILED;
    }
}

int jmi_brent_newton(jmi_block_solver_t *block, double *x0, double *f0, double *d) {
    double x = *x0;
    double x_tmp = x;
    double f = *f0;
    double df = 0.0;
    double delta = 1e20;
    double delta_prev = delta;
    int flag;
    int i = 0;
    jmi_log_node_t node={0};
    
    if (block->callbacks->log_options.log_level >= BRENT_BASE_LOG_LEVEL) { 
            node = jmi_log_enter_fmt(block->log, logInfo, "BrentNewton", 
                                "Starting Newton to find a good initial for Brent in <block:%s> <initial_f:%f>", block->label, *f0);
    }
    
    
    for (i = 0; i < BRENT_MAX_NEWTON; i++) {
        x = x_tmp;
        if (i > 0) { /* First call is unnecessary due to an updated f is provided to the method */
            flag = brentf(x, &f, block);
            if (flag) {
                if (block->callbacks->log_options.log_level >= BRENT_BASE_LOG_LEVEL) { jmi_log_leave(block->log, node); }
                jmi_log_node(block->log, logError, "Error", "Residual function evaluation failed during Newton for block "
                        "<block: %s>", block->label);
                return -1;
            }
        }
        
        /* Iteration terminates successfully */
        if (JMI_ABS(f) <= DBL_MIN) {
            if (block->callbacks->log_options.log_level >= BRENT_BASE_LOG_LEVEL) {
                jmi_log_fmt(block->log, node, logInfo, "The residual meets the tolerance requirement <res: %f>. Stopping Newton.", f);
            }
            break; 
        }
        
        /* If the step is zero, stop */
        if (JMI_ABS(delta) < UNIT_ROUNDOFF*block->nominal[0]) { 
            if (block->callbacks->log_options.log_level >= BRENT_BASE_LOG_LEVEL) {
                jmi_log_fmt(block->log, node, logInfo, "The step is too small <delta: %f>. Stopping Newton.", delta);
            }
            break; 
        }
        
        flag = brentdf(x, f, &df, block);
        if (flag) {
            if (block->callbacks->log_options.log_level >= BRENT_BASE_LOG_LEVEL) { jmi_log_leave(block->log, node); }
            jmi_log_node(block->log, logError, "Error", "Residual derivative function evaluation failed during Newton for block "
                    "<block: %s>", block->label);
            return -1;
        }
        if (JMI_ABS(df) < UNIT_ROUNDOFF) {
            if (block->callbacks->log_options.log_level >= BRENT_BASE_LOG_LEVEL) {
                jmi_log_fmt(block->log, node, logInfo, "The residual derivative is too small <df: %f>. Stopping Newton.", df);
            }
            break;
        }
        
        delta = f/df;
        
        if (block->callbacks->log_options.log_level >= BRENT_BASE_LOG_LEVEL) {
            jmi_log_fmt(block->log, node, logInfo, "Iteration variable <ivs: %f>, Function value <f: %f>, Derivative value <df: %f>, Delta <delta:%f>",
            x,f,df,delta);
        }
        
        x_tmp = x - delta;
        
        /* Clamping */
        if (block->options->enforce_bounds_flag && x_tmp < block->min[0]) {
            if (block->callbacks->log_options.log_level >= BRENT_BASE_LOG_LEVEL) {
                jmi_log_fmt(block->log, node, logInfo, "Clamping iteration variable <ivs: %f> to minimum, <min: %f>",
                    x_tmp,block->min[0]);
            }
            x_tmp = block->min[0];
        } else if (block->options->enforce_bounds_flag && x_tmp > block->max[0]) {
            if (block->callbacks->log_options.log_level >= BRENT_BASE_LOG_LEVEL) {
                jmi_log_fmt(block->log, node, logInfo, "Clamping iteration variable <ivs: %f> to maximum, <max: %f>",
                    x_tmp,block->max[0]);
            }
            x_tmp = block->max[0];
        }
        
        /* Check if Newton is making good progress */
        if (i > 1 && JMI_ABS(delta) > 2*JMI_ABS(delta_prev)) {
            if (block->callbacks->log_options.log_level >= BRENT_BASE_LOG_LEVEL) {
                jmi_log_fmt(block->log, node, logInfo, "Not making progress with Newton. Stopping Newton.");
            }
            break;
        }
        
        delta_prev = delta;
        
    }
    
    if (block->callbacks->log_options.log_level >= BRENT_BASE_LOG_LEVEL) { jmi_log_leave(block->log, node); }
    
    /* If the function value was significantly decreased during Newton, return successful together with the values, x, f and the last step */
    if (delta != 0 && (JMI_ABS(f) < JMI_ABS(*f0) * BRENT_SIGNIFICANT_DECREASE || JMI_ABS(f) < UNIT_ROUNDOFF)) {
        *x0 = x;
        *f0 = f;
        *d = delta >= 0 ? delta : -delta;
    } else {
        return -1;
    }
    
    return 0;
}

/* Initialize solver structures */
/* just a placeholder in case more init is needed*/
static int jmi_brent_init(jmi_block_solver_t * block) {
   jmi_brent_solver_t* solver = (jmi_brent_solver_t*)block->solver;
   solver->originalStart = block->x[0];
   jmi_setup_f_residual_scaling(block);
   return 0;
}


static int jmi_brent_try_bracket(jmi_block_solver_t * block, 
                                     double x_cur, double f_cur,
                                     double x_bracket, double* f_bracket)
{
    int flag;
    jmi_brent_solver_t* solver = (jmi_brent_solver_t*)block->solver;
    jmi_log_t *log = block->log;

    flag =  brentf(x_bracket, f_bracket, block); /* evaluate residual */
    if (flag) {
        /* report error */
        jmi_log_node(log, BRENT_EXTENDED_LOG_LEVEL, "BrentTryBracket",
                     "Unable to evaluate residual at <iv: %g>", x_bracket);
        return -1;
    }

    jmi_log_node(log, BRENT_EXTENDED_LOG_LEVEL, "BrentTryBracket",
                 "Trying to bracket the root with <iv: %g, f: %g>", x_bracket, f_bracket[0]);

    if (f_bracket[0] > DBL_MIN) { 
        if (f_cur <= 0) { /* sign change - bracketing done */
            solver->f_pos_min = f_bracket[0];
            solver->y_pos_min = x_bracket;
            solver->f_neg_max = f_cur;
            solver->y_neg_max = x_cur;
            return 1;
        }
    }
    else if (f_bracket[0] < -DBL_MIN) { 
        if (f_cur >= 0) { /* sign change - bracketing done */
            solver->f_neg_max = f_bracket[0];
            solver->y_neg_max = x_bracket;
            solver->f_pos_min = f_cur;
            solver->y_pos_min = x_cur;
            return 1;
        }
    }
    else {
        block->x[0] = x_bracket;
        jmi_log_node(log, BRENT_EXTENDED_LOG_LEVEL, "BrentBracketExact", "Got zero residual while bracketing");
        return 2;
    }
    return 0; /* will need more bracketing */
}

int jmi_brent_solver_solve(jmi_block_solver_t * block){
    int flag;
#ifdef JMI_PROFILE_RUNTIME
    clock_t t;
#endif
    jmi_brent_solver_t* solver = (jmi_brent_solver_t*)block->solver;
    double f, init;
    double initialStepNewton = BRENT_INF;
    double xNewton = 0.0;
    double fNewton = 0.0;
    double dNewton = 0.0;
    double xBest = 0.0;
    double fBest = 0.0;
    jmi_log_node_t topnode={0};
    jmi_log_t *log = block->log;
#ifdef JMI_PROFILE_RUNTIME
    if (block->parent_block) {
        t = clock();
    }
#endif



    jmi_brent_solver_print_solve_start(block, &topnode);

    if (block->init) {
        jmi_brent_init(block);
        init = block->x[0];
    }
    else {
        double nom, min, max;
        
        
        if (jmi_block_solver_use_save_restore_state_behaviour(block)) {
            flag = block->F(block->problem_data,block->last_accepted_x, NULL, JMI_BLOCK_WRITE_BACK);
            if(flag) {        
                jmi_log_node(log, logError, "ErrorSettingInitialGuess", "<errorCode: %d> returned from <block: %s> "
                             "when setting the initial guess.", flag, block->label);
                return flag;
            }
        }
        /* Read initial values and bounds for iteration variables from variable vector.
        * This is needed if the user has changed initial guesses in between calls to
        * the solver.
        */
        flag = block->F(block->problem_data,block->x,block->res,JMI_BLOCK_INITIALIZE);
        init = block->x[0];
        if (flag ||(init != init)) {        
            if(!flag) flag = 100;
            jmi_log_node(log, logWarning, "ErrorReadingInitialGuess", "<errorCode: %d> returned from <block: %s> "
                         "when reading initial guess.", flag, block->label);
            jmi_brent_solver_print_solve_end(block, &topnode, flag);
#ifdef JMI_PROFILE_RUNTIME
            if (block->parent_block) {
                block->parent_block->time_in_brent += ((double)clock() - t) / CLOCKS_PER_SEC;
            }
#endif
            return flag;
        }

        if(block->options->iteration_variable_scaling_mode != jmi_iter_var_scaling_none) {
            flag = block->F(block->problem_data,block->nominal,block->res,JMI_BLOCK_NOMINAL);
            nom = block->nominal[0];
            if (flag ||(nom != nom)) {
                if(!flag) flag = 100;
                jmi_log_node(log, logWarning, "ErrorReadingNominal", "<errorCode: %d> returned to <block: %s> "
                    "when reading nominal value.", flag, block->label);
                jmi_brent_solver_print_solve_end(block, &topnode, flag);
#ifdef JMI_PROFILE_RUNTIME
                if (block->parent_block) {
                    block->parent_block->time_in_brent += ((double)clock() - t) / CLOCKS_PER_SEC;
                }
#endif
                return flag;
            }
            if(block->nominal[0] < 0) /* According to spec negative nominal is fine but solver expects positive.*/
                block->nominal[0] = -block->nominal[0];
        }


        flag = block->F(block->problem_data,block->min,block->res,JMI_BLOCK_MIN);
        min = block->min[0];
        if (flag ||(min != min)) {        
            if(!flag) flag = 100;
            jmi_log_node(log, logWarning, "ErrorReadingMin", "<errorCode: %d> returned to <block: %s> "
                "when reading  min bound value.", flag, block->label);
            jmi_brent_solver_print_solve_end(block, &topnode, flag);
#ifdef JMI_PROFILE_RUNTIME
            if (block->parent_block) {
                block->parent_block->time_in_brent += ((double)clock() - t) / CLOCKS_PER_SEC;
            }
#endif
            return flag;
        }

        flag = block->F(block->problem_data,block->max,block->res,JMI_BLOCK_MAX);
        max = block->max[0];
        if (flag || (max != max)) {        
            if(!flag) flag = 100;
            jmi_log_node(log, logWarning, "ErrorReadingMax", "<errorCode: %d> returned to <block: %s> "
                "when reading max bound value.", flag, block->label);
            jmi_brent_solver_print_solve_end(block, &topnode, flag);
#ifdef JMI_PROFILE_RUNTIME
            if (block->parent_block) {
                block->parent_block->time_in_brent += ((double)clock() - t) / CLOCKS_PER_SEC;
            }
#endif
            return flag;
        }


        if ((init > max) || (init < min)) {
            jmi_real_t old_init = init;
            init = init > max ? max : min;
            block->x[0] = block->initial[0] = init;
            jmi_log_node(block->log, logWarning, "StartOutOfBounds",
                         "Start value <start: %g> is not between <min: %g> and <max: %g> "
                         "for the iteration variable <iv: #r%d#> in <block: %s>. Clamping to <clamped_start: %g>.",
                         old_init, min, max, block->value_references[0], block->label, init);
        }


    }

    jmi_log_fmt(log, topnode, BRENT_EXTENDED_LOG_LEVEL, "<max: %g>", block->max[0]);
    jmi_log_fmt(log, topnode, BRENT_EXTENDED_LOG_LEVEL, "<min: %g>", block->min[0]);
    jmi_log_fmt(log, topnode, BRENT_EXTENDED_LOG_LEVEL, "<nominal: %g>", block->nominal[0]);
    jmi_log_fmt(log, topnode, BRENT_EXTENDED_LOG_LEVEL, "<initial_guess: %g>", block->x[0]);

    /* evaluate att initial */
    /* evaluate the function at initial */
    flag = brentf(block->x[0], &f, block);

    if(flag) {
        if(block->x[0] != solver->originalStart) {
            jmi_log_node(log, logWarning, "Warning",  "Residual function evaluation failed at initial point for "
                         "<block: %s>, will try <initial_guess: %g>", block->label, solver->originalStart);
        
            flag = brentf(solver->originalStart, &f, block);
            if(!flag) {
                block->x[0] = solver->originalStart;
            }
        }
        if(flag && (block->x[0] != block->min[0]) && (block->min[0] != solver->originalStart)) {
            jmi_log_node(log, logWarning, "Warning",  "Residual function evaluation failed at initial point for "
                         "<block: %s>, will try <initial_guess: %g>", block->label, block->min[0]);
        
            flag = brentf(block->min[0], &f, block);
            if(!flag) {
                block->x[0] = block->min[0];
            }
        }
        if(flag && (block->x[0] != block->max[0]) && (block->max[0] != solver->originalStart)) {
            jmi_log_node(log, logWarning, "Warning",  "Residual function evaluation failed at initial point for "
                         "<block: %s>, will try <initial_guess: %g>", block->label, block->max[0]);        
            flag = brentf(block->max[0], &f, block);
            if(!flag) {
                block->x[0] = block->max[0];
            }
        }
        if(flag && (block->x[0] != block->nominal[0]) && (block->nominal[0] != solver->originalStart)) {
            double nom_guess = block->nominal[0];
            if( block->nominal[0] > block->max[0] ) {
               nom_guess *=-1;
            }
            if(nom_guess < block->max[0] && nom_guess > block->min[0]) { /* Only try if nominal is within bounds */
                jmi_log_node(log, logWarning, "Warning",  "Residual function evaluation failed at initial point for "
                    "<block: %s>, will try <initial_guess: %g>", block->label, nom_guess);        
                flag = brentf(nom_guess, &f, block);
                if(!flag) {
                    block->x[0] = nom_guess;
                }
            }
        }
    }

    jmi_log_fmt(log, topnode, BRENT_EXTENDED_LOG_LEVEL, "<initial_f:%g>", f);

    if (flag) {

        jmi_log_node(block->log, logError, "Error", "Residual function evaluation failed at initial point for "
            "<block: %s> <Iter: #r%d#>", block->label, block->value_references[0]);
        jmi_brent_solver_print_solve_end(block, &topnode, JMI_BRENT_FIRST_SYSFUNC_ERR);
#ifdef JMI_PROFILE_RUNTIME
        if (block->parent_block) {
            block->parent_block->time_in_brent += ((double)clock() - t) / CLOCKS_PER_SEC;
        }
#endif
        if(block->options->brent_ignore_error_flag)
            return JMI_BRENT_SUCCESS;
        else
            return JMI_BRENT_FIRST_SYSFUNC_ERR;
    }
    
    /* Save the best guess for x and f to be used as a backup */
    xBest = block->x[0];
    fBest = f;

    /* Try to use Newton to find a good initial interval */
    if (block->options->use_newton_for_brent) {
        if ((f > DBL_MIN) || ((f < -DBL_MIN))) {
            xNewton = block->x[0];
            fNewton = f;
            flag = jmi_brent_newton(block, &xNewton, &fNewton, &dNewton);
            jmi_log_fmt(log, topnode, BRENT_EXTENDED_LOG_LEVEL, "<flag:%d>, <newton_x:%g>, <newton_f:%g>, <newton_step:%g>", flag, xNewton, fNewton, dNewton);
            
            /* Update best values */
            if (JMI_ABS(fNewton) < JMI_ABS(fBest)) {
                xBest = xNewton;
                fBest = fNewton;
            }

            /* If Newton was successful, use the returned values, otherwise continue */
            if (!flag) {
                block->x[0] = xNewton;
                f = fNewton;
                initialStepNewton = dNewton;
            }
        }
    }

    /* bracket the root */
    if ((f > DBL_MIN) || ((f < -DBL_MIN))) {
        double x = block->x[0], tmp, f_tmp;
        double lower = x, f_lower = f;
        double upper = x, f_upper = f;
        /* Introduce to avoid IllegalIterationVariableInput warnings */
        double bracketMin = JMI_MAX(block->options->enforce_bounds_flag ? block->min[0] : -BIG_REAL, -block->nominal[0]*JMI_LIMIT_VALUE);
        double bracketMax = JMI_MIN(block->options->enforce_bounds_flag ? block->max[0] : BIG_REAL, block->nominal[0]*JMI_LIMIT_VALUE);

        double initialStepStatic = block->nominal[0]*BRENT_INITIAL_STEP_FACTOR;
        double initialStepStaticSmall = initialStepStatic*BRENT_INITIAL_STEP_FACTOR;
        double initialStep = (initialStepNewton > initialStepStatic) ? (JMI_ABS(f) < UNIT_ROUNDOFF*BRENT_SMALL_RESIDUAL_FACTOR ? initialStepStaticSmall : initialStepStatic) : initialStepNewton;
        double lstep = initialStep, ustep = initialStep;
        while (1) {
            if (lower > bracketMin && /* lower is fine as long as we're inside the bounds */
                (
                    ( upper >= bracketMax) ||  /* prefer lower if upper is outside bounds */
                    ((f_lower < f_upper) && (f > 0)) || /* or lower is "closer" to sign change */
                    ((f_lower >= f_upper) && (f < 0))
                )
                ) {
                /* widen the interval */
                tmp = lower - lstep;  
                if ((tmp < bracketMin) || (tmp != tmp)) { /* make sure we're inside bounds and not NAN*/
                    tmp = bracketMin;
                    /* This update can increase roundoff that prevents lstep from decreasing.
                       Ok if we hit the bound anyway. */
                    lstep = lower - tmp;
                }
                if ( lower > solver->originalStart && tmp <= solver->originalStart && lstep > initialStep * 10) {
                    tmp = solver->originalStart;
                    lstep = initialStep;
                }

                flag = jmi_brent_try_bracket(block, lower, f_lower, tmp, &f_tmp);

                 /* modify the step for the next time */
                if (flag < 0) { 
                    /* there was an error - reduce the step */
                    lstep *= 0.5;
                    jmi_log_node(log, BRENT_EXTENDED_LOG_LEVEL, "BrentBracketStepReduced", 
                                 "Reducing bracketing step in negative direction "
                                 "to <lstep: %g>", lstep);
                    if ((lstep <= UNIT_ROUNDOFF * block->nominal[0]) || (lower - lstep == lower)) {
                        jmi_log_node(log, BRENT_EXTENDED_LOG_LEVEL, "BrentBracketStepTooSmall", 
                                     "Too small bracketing step - modifying <lower_bound: %g> "
                                     "on the iteration variable", lower);
                        block->min[0] = lower; /* we cannot step further without breaking the function -> update the bound */
                        bracketMin = JMI_MAX(bracketMin, block->min[0]);
                    }
                }
                else if (flag == 0) {
                    /* Update best values */ 
                    if (JMI_ABS(f_lower) < JMI_ABS(fBest)) {
                        xBest = lower;
                        fBest = f_lower;
                    }
                    /* increase the step */
                    lstep *= 2;
                    lower = tmp;
                    f_lower = f_tmp;
                    jmi_log_node(log, BRENT_EXTENDED_LOG_LEVEL, "BrentBracketStepIncreased",
                                 "Increasing bracketing step in negative direction "
                                 "to <lstep: %g>", lstep);
                }
            }
            else if (upper < bracketMax) { /* upper might work otherwise */
                tmp = upper + ustep;
                if ((tmp > bracketMax) || (tmp != tmp)) {
                    tmp = bracketMax;
                    /* This update can increase roundoff that prevents lstep from decreasing.
                       Ok if we hit the bound anyway. */
                    ustep = tmp - upper;
                }
                if ( upper < solver->originalStart && tmp >= solver->originalStart && ustep > initialStep * 10) {
                    tmp = solver->originalStart;
                    ustep = initialStep;
                }

                flag = jmi_brent_try_bracket(block, upper, f_upper, tmp, &f_tmp);

                 /* modify the step for the next time */
                if (flag < 0) { 
                    /* there was an error - reduce the step */
                    ustep *= 0.5;
                    jmi_log_node(log, BRENT_EXTENDED_LOG_LEVEL, "BrentBracketStepReduced", 
                                 "Reducing bracketing step in positive direction "
                                 "to <ustep: %g>", ustep);

                    if ((ustep <= UNIT_ROUNDOFF * block->nominal[0]) ||  (upper + ustep == upper)) {
                        jmi_log_node(log, BRENT_EXTENDED_LOG_LEVEL, "BrentBracketStepTooSmall", 
                                     "Too small bracketing step - modifying <upper_bound: %g> "
                                     "on the iteration variable", upper);
                        block->max[0] = upper; /* we cannot step further without breaking the function -> update the bound */
                        bracketMax = JMI_MIN(bracketMax, block->max[0]);
                    }
                }
                else if (flag == 0) {
                    /* Update best values */ 
                    if (JMI_ABS(f_upper) < JMI_ABS(fBest)) {
                        xBest = upper;
                        fBest = f_upper;
                    }
                    /* increase the step */
                    ustep *= 2;
                    upper = tmp;
                    f_upper = f_tmp;
                    jmi_log_node(log, BRENT_EXTENDED_LOG_LEVEL, "BrentBracketStepIncreased",
                                 "Increasing bracketing step in positive direction "
                                 "to <ustep: %g>", ustep);
                }
            }
            else { /* Bracketing failed */
                /* Check if fBest satisfies convergence criteria */
                flag = jmi_brent_test_best_guess(block, xBest, fBest);
                if (flag == JMI_BRENT_SUCCESS) {
                    jmi_log_node(log, logInfo, "BrentBracketingResidualAccepted", "Could not bracket the root but accepting the smallest residual computed during bracketing in <block: %s>.", block->label);
                    block->x[0] = xBest;
                    block->F(block->problem_data,block->x, NULL, JMI_BLOCK_WRITE_BACK);
                    jmi_brent_solver_print_solve_end(block, &topnode, JMI_BRENT_SUCCESS);
                    return JMI_BRENT_SUCCESS;
                }
                jmi_log_node(log, logError, "BrentBracketFailed", "Could not bracket the root in <block: %s>. Iteration variable <variable:#r%d#>, search interval bounds: <min: %g>, <max: %g>.", block->label, block->value_references[0], block->min[0], block->max[0]);
                jmi_brent_solver_print_solve_end(block, &topnode, JMI_BRENT_ROOT_BRACKETING_FAILED);
                /* Write initial guess back to model. */ 
                block->x[0] = init;
                block->F(block->problem_data,block->x, NULL, JMI_BLOCK_WRITE_BACK);
#ifdef JMI_PROFILE_RUNTIME
                if (block->parent_block) {
                    block->parent_block->time_in_brent += ((double)clock() - t) / CLOCKS_PER_SEC;
                }
#endif
                if(block->options->brent_ignore_error_flag) {
                    /*block->x[0] = init;
                    block->F(block->problem_data,block->x, NULL, JMI_BLOCK_WRITE_BACK); */
                    return JMI_BRENT_SUCCESS;
                }
                else
                    return JMI_BRENT_ROOT_BRACKETING_FAILED;
            }
            if (flag > 0) { 
                break; /* bracketing done*/
            }
        }
        if (flag == 2) {
            /* root found while in bracketing */
            jmi_brent_solver_print_solve_end(block, &topnode, JMI_BRENT_SUCCESS);
#ifdef JMI_PROFILE_RUNTIME
            if (block->parent_block) {
                block->parent_block->time_in_brent += ((double)clock() - t) / CLOCKS_PER_SEC;
            }
#endif
            return JMI_BRENT_SUCCESS;
        }
    }
    else {
        jmi_log_node(log, BRENT_EXTENDED_LOG_LEVEL, "BrentBracketExact", "Initial guess has zero residual");
        jmi_brent_solver_print_solve_end(block, &topnode, JMI_BRENT_SUCCESS);
#ifdef JMI_PROFILE_RUNTIME
        if (block->parent_block) {
            block->parent_block->time_in_brent += ((double)clock() - t) / CLOCKS_PER_SEC;
        }
#endif
        return JMI_BRENT_SUCCESS;
    }
    jmi_log_node(log, BRENT_EXTENDED_LOG_LEVEL, "BrentBracket", 
                 "Bracketed the root between <iv_neg: %g> and <iv_pos: %g>, residuals <res_neg: %g> and <res_pos: %g>", 
                 solver->y_neg_max, solver->y_pos_min, solver->f_neg_max, solver->f_pos_min);

    {            
        jmi_real_t u, f;
        flag = jmi_brent_search(brentf, solver->y_neg_max,  solver->y_pos_min, 
                                solver->f_neg_max, solver->f_pos_min, 0, &u, &f,block);
        block->x[0] = u;
        
        if (flag) {
            jmi_log_node(log, logError, "Error", "Function evaluation failed while iterating in <block: %s>", block->label);
            jmi_brent_solver_print_solve_end(block, &topnode, JMI_BRENT_SYSFUNC_FAIL);
             block->x[0] = init;
             block->F(block->problem_data,block->x, NULL, JMI_BLOCK_WRITE_BACK);
#ifdef JMI_PROFILE_RUNTIME
            if (block->parent_block) {
                block->parent_block->time_in_brent += ((double)clock() - t) / CLOCKS_PER_SEC;
            }
#endif
            return JMI_BRENT_SYSFUNC_FAIL;
        } else {
                /* Write solution back to model just to make sure. In some cases x was not the last evaluations*/    
            block->F(block->problem_data,block->x, NULL, JMI_BLOCK_WRITE_BACK);
        }
    }   
        
    jmi_brent_solver_print_solve_end(block, &topnode, JMI_BRENT_SUCCESS);
#ifdef JMI_PROFILE_RUNTIME
    if (block->parent_block) {
        block->parent_block->time_in_brent += ((double)clock() - t) / CLOCKS_PER_SEC;
    }
#endif
    return JMI_BRENT_SUCCESS;
}

int jmi_brent_search(jmi_brent_func_t f, jmi_real_t u_min, jmi_real_t u_max, jmi_real_t f_min, jmi_real_t f_max, jmi_real_t tolerance, jmi_real_t* u_out, jmi_real_t* f_out,void *data) {
    jmi_real_t a=u_min; /* left point */
    jmi_real_t fa = f_min;
    jmi_real_t b=u_max; /* right point */
    jmi_real_t fb = f_max;
    jmi_real_t c = u_min; /* Intermediate point a <= c <= b */
    jmi_real_t fc = f_min;
    jmi_real_t e= u_max - u_min;
    jmi_real_t d=e;
    jmi_real_t m,s,p,q,r;
    jmi_real_t tol; /* absolute tolerance for the current "b" */
    int flag;
    jmi_block_solver_t* block = (jmi_block_solver_t*)data;
    jmi_log_t* log = block->log;
    jmi_log_node_t log_node={0};
    if (block->callbacks->log_options.log_level >= BRENT_EXTENDED_LOG_LEVEL) {
        log_node = jmi_log_enter(log, logInfo, "BrentSearch");
    }

#ifdef DEBUG
    if (fa*fb > 0) {
        if (block->callbacks->log_options.log_level >= BRENT_EXTENDED_LOG_LEVEL) {
            jmi_log_node(log, logError, "Error", "Brent got two endpoints with the same sign in <block: %s>", block->label);
            jmi_log_leave(log, log_node);
        }
        return JMI_BRENT_ILL_INPUT;
    }
#endif
    while(1) {
        if (JMI_ABS(fc) < JMI_ABS(fb)) {
            a = b;
            b = c;
            c = a;
            fa = fb;
            fb = fc;
            fc = fa;
        }

        jmi_log_node(log, BRENT_EXTENDED_LOG_LEVEL, "BrentIteration",
                     "Root is bracketed between <iv_best: %g> and <iv_second: %g>, residuals <f_best: %g> and <f_second: %g>",
                     b, c, fb, fc);

        tol = 2*UNIT_ROUNDOFF*JMI_ABS(b) + tolerance;
        m = (c - b)/2;
        
        if ((JMI_ABS(m) <= tol) || (fb == 0.0)) {
            /* root found (interval is small enough) */
            if (JMI_ABS(fb) < JMI_ABS(fc)) {
                *u_out = b;
                *f_out = fb;
            }
            else {
                *u_out = c;
                *f_out = fc;
            }
            if (block->callbacks->log_options.log_level >= BRENT_EXTENDED_LOG_LEVEL) {
                jmi_log_leave(log, log_node);
            }
            return 0;
        }
        /* Find the new point: */
        /* Determine if a bisection is needed */
        if ((JMI_ABS(e) < tol) || ( JMI_ABS(fa) <= JMI_ABS(fb))) {
            e = m;
            d = e;
        }
        else {
            s = fb/fa;
            if (a == c) {
                /* linear interpolation */
                p = 2*m*s;
                q = 1 - s;
            }
            else {
                /* inverse quadratic interpolation */
                q = fa/fc;
                r = fb/fc;
                p = s*(2*m*q*(q - r) - (b - a)*(r - 1));
                q = (q - 1)*(r - 1)*(s - 1);
            }
            if (p > 0) 
                q = -q;
            else
                p = -p;
            s = e;
            e = d;
            
            if ((2*p < 3*m*q - JMI_ABS(tol*q)) && (p < JMI_ABS(0.5*s*q)))
                /* interpolation successful */
                d = p/q;
            else {
                /* use bi-section */
                e = m;
                d = e;
            }
        }
        
        
        /* Best guess value is saved into "a" */
        a = b;
        fa = fb;
        b = b + ((JMI_ABS(d) > tol) ? d : ((m > 0) ? tol: -tol));
        flag = f(b, &fb, data);
        if (flag) {
             if (JMI_ABS(fa) < JMI_ABS(fc)) {
                *u_out = a;
                *f_out = fa;
            }
            else {
                *u_out = c;
                *f_out = fc;
            }
            if (block->callbacks->log_options.log_level >= BRENT_EXTENDED_LOG_LEVEL) {
                jmi_log_leave(log, log_node);
            }
            return flag;
        }

        if (fb * fc  > 0) {
            /* initialize variables */
            c = a;
            fc = fa;
            e = b - a;
            d = e;
        }
    }
    if (block->callbacks->log_options.log_level >= BRENT_EXTENDED_LOG_LEVEL) {
        jmi_log_leave(log, log_node);
    }

}

int jmi_brent_completed_integrator_step(jmi_block_solver_t* block) {
    int flag = 0;
    if (jmi_block_solver_use_save_restore_state_behaviour(block)) {
        /* Brent specific handling of a completed step */
        flag = block->F(block->problem_data,block->last_accepted_x,block->res,JMI_BLOCK_INITIALIZE);
        if (flag) {
            jmi_log_node(block->log, logError, "ReadLastIterationVariables",
                         "Failed to read the iteration variables, <errorCode: %d> in <block: %s>", flag, block->label);
            return flag;
        }
    }
    return flag;
}
