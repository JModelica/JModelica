/*
    Copyright (C) 2017 Modelon AB

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


#include "jmi_realtime_solver.h"
#include "jmi_block_solver_impl.h"
#include "jmi_linear_algebra.h"
#include <math.h>
#include <string.h>

#define JMI_REALTIME_SOLVER_MAX_ITER 20
#define JMI_REALTIME_UPDATE_JACOBIAN_ITER 10
#define JMI_REALTIME_PROGRESS_LOG_LEVEL 4


static void progress_reset_char_log(jmi_block_solver_t* block) {
    jmi_realtime_solver_t* solver = (jmi_realtime_solver_t*)block->solver;
    
    solver->char_log_length = 0;
    solver->char_log[0] = 0;
}

static void progress_char_log(jmi_block_solver_t* block, char c) {
    jmi_realtime_solver_t* solver = (jmi_realtime_solver_t*)block->solver;
    
    if (block->callbacks->log_options.log_level < JMI_REALTIME_PROGRESS_LOG_LEVEL) { return; }
    
    if (solver->char_log_length < JMI_REALTIME_SOLVER_MAX_CHAR_LOG_LENGTH) {
        solver->char_log[solver->char_log_length] = c;
        solver->char_log_length++;
        solver->char_log[solver->char_log_length] = 0;
    } else {
        solver->char_log[JMI_REALTIME_SOLVER_MAX_CHAR_LOG_LENGTH-1] = '?';
    }
}

void jmi_realtime_compute_weights(jmi_real_t* x, jmi_real_t* nominals, jmi_real_t* weights, jmi_real_t tolerance, jmi_int_t N) {
    jmi_int_t i;
    
    for (i = 0; i < N; i++) {
        weights[i] = 1.0/(JMI_ABS(x[i])*tolerance + JMI_ABS(nominals[i])*tolerance);
    }
}

void jmi_realtime_solver_delete(jmi_block_solver_t *block) {
    jmi_realtime_solver_t* solver = (jmi_realtime_solver_t*)block->solver;
    
    free(solver->weights);
    free(solver->pivots);
    free(solver->dx);
    free(solver->df);
    free(solver->jacobian);
    free(solver->factorization);
    
    free(solver);
    block->solver = 0;
}

int jmi_realtime_solver_new(jmi_realtime_solver_t** solver_ptr, jmi_block_solver_t* block) {
    jmi_realtime_solver_t* solver= (jmi_realtime_solver_t*)calloc(1,sizeof(jmi_realtime_solver_t));

    if (!solver) return -1;
    
    solver->weights       = (jmi_real_t*)calloc(block->n,sizeof(jmi_real_t));
    solver->pivots        = (jmi_int_t*)calloc(block->n,sizeof(jmi_int_t));
    solver->dx            = (jmi_real_t*)calloc(block->n,sizeof(jmi_real_t));
    solver->df            = (jmi_real_t*)calloc(block->n,sizeof(jmi_real_t));
    solver->jacobian      = (jmi_real_t*)calloc(block->n*block->n,sizeof(jmi_real_t));
    solver->factorization = (jmi_real_t*)calloc(block->n*block->n,sizeof(jmi_real_t));
    
    /* Statistics */
    solver->nbr_non_convergence = 0;
    solver->nbr_iterations      = 0;
    solver->last_wrms           = 0.0;
    solver->last_wrms_id        = -1;
    solver->last_jacobian_rcond = -1;
    solver->last_jacobian_norm  = -1;
    
    *solver_ptr = solver;
    
    return 0;
}

static void jmi_realtime_solver_progress(jmi_block_solver_t *block) {
    jmi_realtime_solver_t* solver = (jmi_realtime_solver_t*)block->solver;
    jmi_log_t *log = block->log;
    char message[256];

    if (block->callbacks->log_options.log_level < JMI_REALTIME_PROGRESS_LOG_LEVEL) { return; }
    
    /* Only print header first iteration */
    if (solver->nbr_iterations == 0) { /* Do not print header if INITIAL_GUESS ok */
        jmi_log_node(log, logInfo, "Progress", "<source:%s><message:%s><isheader:%d>",
            "jmi_realtime_solver",
            "iter       res_norm      max_res: ind   wrms: ind      rcond ",
            1);
    }
    
    if (solver->nbr_iterations > 0) {
        jmi_int_t idmax = jmi_linear_algebra_idamax(block->res, block->n);
        /* Keep the progress message on a single line by using jmi_log_enter_, jmi_log_fmt_ etc. */
        jmi_log_node_t node = jmi_log_enter_(log, logInfo, "Progress");
        
        sprintf(message, "%4d%-4s%11.4e % 11.4e:%4d %11.4e:%4d %11.4e", solver->nbr_iterations, solver->char_log,
            jmi_linear_algebra_norm(block->res,block->n), block->res[idmax], idmax, solver->last_wrms, solver->last_wrms_id, solver->last_jacobian_rcond);
        progress_reset_char_log(block);

        jmi_log_fmt_(log, node, logInfo, "<source:%s><block:%s><message:%s>",
            "jmi_realtime_solver", block->label, message);
        jmi_log_leave(log, node);
    }
    return;
}

int jmi_realtime_solver_solve(jmi_block_solver_t *block) {
    jmi_realtime_solver_t* solver = (jmi_realtime_solver_t*)block->solver;
    jmi_real_t tolerance = block->options->res_tol;
    jmi_int_t ret, i;
    jmi_log_node_t destnode={0};
    jmi_int_t broyden_updates = block->options->jacobian_update_mode == jmi_broyden_jacobian_update_mode;
    clock_t start_measuring = jmi_block_solver_start_clock(block);
    clock_t jac_measuring, fac_measuring;
    jmi_real_t elapsed_time_jac = 0.0, elapsed_time_fac = 0.0;
    
    /* Initialize the work vector */
    block->F(block->problem_data,block->x,block->res,JMI_BLOCK_INITIALIZE);
    
    /* Initialize statistics */
    solver->nbr_iterations = 0;

    /* Evaluate */
    ret = block->F(block->problem_data,block->x,block->res,JMI_BLOCK_EVALUATE);
    if(ret) { jmi_realtime_solver_error_handling(block, block->x, JMI_REALTIME_SOLVER_BLOCK_EVALUATION_FAIL); return -1; }
    

    if(block->init || block->at_event || !broyden_updates) {
        /* Compute the Jacobian (always and only done once) */
        jac_measuring = jmi_block_solver_start_clock(block);
        ret = jmi_realtime_solver_jacobian(block, block->res, solver->factorization);
        elapsed_time_jac = jmi_block_solver_elapsed_time(block, jac_measuring);
        if (ret) { jmi_realtime_solver_error_handling(block, block->x, JMI_REALTIME_SOLVER_JACOBIAN_APPROXIMATION_FAIL); return -1; }
        
        if (block->callbacks->log_options.log_level >= JMI_REALTIME_PROGRESS_LOG_LEVEL) {
            solver->last_jacobian_norm = jmi_linear_algebra_dlange(solver->factorization, block->n, 'I');
        }
        
        /* Broyden updates */
        if (broyden_updates) { memcpy(solver->jacobian, solver->factorization, block->n*block->n*sizeof(jmi_real_t)); }
        
        /* Factorize the Jacobian */
        fac_measuring = jmi_block_solver_start_clock(block);
        ret = jmi_linear_algebra_LU_factorize(solver->factorization, solver->pivots, block->n);
        elapsed_time_fac = jmi_block_solver_elapsed_time(block, fac_measuring);
        if (ret) { jmi_realtime_solver_error_handling(block, block->x, JMI_REALTIME_SOLVER_LU_FACTORIZATION_FAIL); return -1; }
        
        if (block->callbacks->log_options.log_level >= JMI_REALTIME_PROGRESS_LOG_LEVEL) {
            solver->last_jacobian_rcond = jmi_linear_algebra_dgecon(solver->factorization, solver->last_jacobian_norm, block->n, 'I');
        }
    }
    
    /* Open log and log the Jacobian.*/
    if((block->callbacks->log_options.log_level >= 5)) {
        destnode = jmi_log_enter_fmt(block->log, logInfo, "RealtimeSolver", 
                                     "Realtime solver invoked for <block:%s>", block->label);
        jmi_log_reals(block->log, destnode, logInfo, "ivs", block->x, block->n);
        if((block->callbacks->log_options.log_level >= 6)) {
            jmi_log_real_matrix(block->log, destnode, logInfo, "LU", solver->factorization, block->n, block->n);
        }
    }
    
    /* Iterate */
    for (i = 0; i < JMI_REALTIME_SOLVER_MAX_ITER; i++) {
        solver->nbr_iterations++;

        /* Values x and res are current */
        if (broyden_updates) { memcpy(solver->df, block->res, block->n*sizeof(jmi_real_t)); }
        
        /* Solve linear system to get the step, J_{k}*dx_{k} = F_{k} */
        ret = jmi_linear_algebra_LU_solve(solver->factorization, solver->pivots, block->res, block->n);
        if (ret) { jmi_realtime_solver_error_handling(block, block->x, JMI_REALTIME_SOLVER_LU_SOLVE_FAIL); return -1; }

        /* Compute new x, x_{k+1} = x_{k} - dx_{k} */
        jmi_linear_algebra_daxpy(-1.0, block->res, block->x, block->n);

        /* Compute norm of the increment, dx_{k} */
        jmi_realtime_compute_weights(block->x, block->nominal, solver->weights, tolerance, block->n);
        solver->last_wrms = jmi_linear_algebra_wrms(solver->weights, block->res, block->n);
        
        /* If broyden, need to store dx_{k} */
        if (broyden_updates) { memcpy(solver->dx, block->res, block->n*sizeof(jmi_real_t)); }
        
        /* Logging compute the id of the largest (weighted) step */
        if (block->callbacks->log_options.log_level >= JMI_REALTIME_PROGRESS_LOG_LEVEL) { 
            jmi_linear_algebra_ddot(solver->weights, block->res, block->n);
            solver->last_wrms_id = jmi_linear_algebra_idamax(block->res, block->n);
        }
        
        /* Evaluate the block with the new iteration variables */
        ret = block->F(block->problem_data,block->x,block->res,JMI_BLOCK_EVALUATE);
        if(ret) { jmi_realtime_solver_error_handling(block, block->x, JMI_REALTIME_SOLVER_BLOCK_EVALUATION_FAIL); return -1; }
        
        if (broyden_updates) {
            /* df_{k} = f_{k+1} - f_{k} */
            jmi_linear_algebra_daxpby(1.0, block->res, -1.0, solver->df, solver->df, block->n);
            
            jmi_realtime_solver_perform_broyden_update(block, solver->df, solver->dx);
        }
        
        /* Progress log.*/
        jmi_realtime_solver_progress(block);
        
        /* Check for convergence */
        if (solver->last_wrms < 1.0) { break; }
    }
    
    /* Close log.*/
    if((block->callbacks->log_options.log_level >= 5)) {
        jmi_log_reals(block->log, destnode, logInfo, "ivs", block->x, block->n);
        jmi_log_reals(block->log, destnode, logInfo, "residual", block->res, block->n);
        jmi_log_leave(block->log, destnode);
    }
    
    if (solver->last_wrms >= 1.0) {
        solver->nbr_non_convergence++;
        
        jmi_log_node(block->log, logWarning, "RealtimeNonConvergence", 
                    "Failed to converge <block: %s> at <t: %f> due to <WRMS: %f> after <iteration: %d> and after elapsed <time: %f> whereof <Jac: %f> and <LU: %f>. Continuing...", 
                    block->label, block->cur_time, solver->last_wrms, i, jmi_block_solver_elapsed_time(block, start_measuring), elapsed_time_jac, elapsed_time_fac);
    } else {
        jmi_log_node(block->log, logInfo, "RealtimeConvergence", 
                    "Succeeded to converge <block: %s> at <t: %f> with <WRMS: %f> after <iteration: %d> and after elapsed <time: %f> whereof <Jac: %f> and <LU: %f>.", 
                    block->label, block->cur_time, solver->last_wrms, i, jmi_block_solver_elapsed_time(block, start_measuring), elapsed_time_jac, elapsed_time_fac);
    }
    
    return 0;
}

int jmi_realtime_solver_perform_broyden_update(jmi_block_solver_t *block, jmi_real_t* df, jmi_real_t* dx) {
    jmi_realtime_solver_t* solver = (jmi_realtime_solver_t*)block->solver;
    jmi_int_t ret;

    jmi_realtime_solver_broyden_update(solver->jacobian, df, dx, block->n);
    memcpy(solver->factorization, solver->jacobian, block->n*block->n*sizeof(jmi_real_t));
    
    progress_char_log(block, 'B');
    
    /* Factorize the Jacobian */
    ret = jmi_linear_algebra_LU_factorize(solver->factorization, solver->pivots, block->n);
    if (ret) { jmi_realtime_solver_error_handling(block, block->x, JMI_REALTIME_SOLVER_LU_FACTORIZATION_FAIL); return -1; }
    
    return 0;
}

/*
 * J_n1 = Jn + (df - Jn dx) / ||dx||^2 dx
 */
int jmi_realtime_solver_broyden_update(jmi_real_t* jacobian, jmi_real_t* df, jmi_real_t* dx, jmi_int_t N) {
    jmi_real_t norm, norm_inv;
    
    /* Computes -Jn dx + df */
    jmi_linear_algebra_dgemv(1.0, jacobian, dx, 1.0, df, N, FALSE);
    
    /* 1 / || dx || ^ 2 */
    norm = jmi_linear_algebra_ddot(dx, dx, N);
    
    if (norm < 1e-14) { norm_inv = 0.0; } else { norm_inv = -1.0/norm; }
    
    /* J_n1 = Jn + 1/||dx||^2 * tmp * dx^T */
    jmi_linear_algebra_dger(norm_inv, df, dx, jacobian, N);
    
    return 0;
}

int jmi_realtime_solver_jacobian(jmi_block_solver_t *block, jmi_real_t* f, jmi_real_t* jacobian) {
    jmi_real_t eps = block->options->jacobian_finite_difference_delta;
    jmi_int_t ret, i;
    
    
    /*
    jmi_real_t fnorm, min_inc;
    jmi_realtime_solver_t* solver = (jmi_realtime_solver_t*)block->solver;
    jmi_realtime_compute_weights(block->x, block->nominal, solver->weights, block->options->res_tol, block->n);
    
    fnorm   = jmi_linear_algebra_wrms(solver->weights, f, block->n);
    min_inc = (fnorm != 0.0) ? (1000 * 0.001 * 1e-16 * block->n * fnorm) : 1.0;
    */
    
    progress_char_log(block, 'J');
    
    for (i = 0; i < block->n; i++) {
        jmi_real_t xi   = block->x[i];
        jmi_real_t sign = JMI_SIGN(xi); 
        jmi_real_t inc  = sign*eps*JMI_MAX(JMI_ABS(xi), JMI_ABS(block->nominal[i]));
        /*jmi_real_t inc  = sign*JMI_MAX(eps*JMI_ABS(xi), min_inc/solver->weights[i]);  */
        jmi_real_t inc_inv;
        
        block->x[i] += inc;
        
        ret = block->F(block->problem_data,block->x,block->dres,JMI_BLOCK_EVALUATE);
        if (ret) {
            inc = -inc;
            block->x[i] = xi + inc;
            ret = block->F(block->problem_data,block->x,block->dres,JMI_BLOCK_EVALUATE);
        }
        if (ret) {
            /* Error handling... */
            return -1;
        }
        
        inc_inv = 1.0 / inc;
        jmi_linear_algebra_daxpby(inc_inv, block->dres, -inc_inv, f, &(jacobian[i*(block->n)]), block->n); 
        
        block->x[i] = xi;
    }

    return 0;
}


void jmi_realtime_solver_error_handling(jmi_block_solver_t *block, jmi_real_t* x, jmi_realtime_solver_error_codes_t return_code) {
    jmi_log_node_t node={0};
    
    
    if (return_code == JMI_REALTIME_SOLVER_BLOCK_EVALUATION_FAIL) {
        node = jmi_log_enter_fmt(block->log, logWarning, "BlockEvaluationFailed", 
                "Failed to evaulation block function, <errorCode: %d> returned in <block: %s> at <t: %f>.", 
                return_code, block->label, block->cur_time);
    } else if (return_code == JMI_REALTIME_SOLVER_JACOBIAN_APPROXIMATION_FAIL) {
        node = jmi_log_enter_fmt(block->log, logWarning, "BlockJacobianFailed", 
                "Failed to approximate the block Jacobian, <errorCode: %d> returned in <block: %s> at <t: %f>.",
                return_code, block->label, block->cur_time);
    } else if (return_code == JMI_REALTIME_SOLVER_LU_FACTORIZATION_FAIL) {
        node = jmi_log_enter_fmt(block->log, logWarning, "BlockJacobianFactorizationFailed", 
                "Failed to perform the LU factorization of the block Jacobian, <errorCode: %d> returned in <block: %s> at <t: %f>.",
                return_code, block->label, block->cur_time);
    } else if (return_code == JMI_REALTIME_SOLVER_LU_SOLVE_FAIL) {
        node = jmi_log_enter_fmt(block->log, logWarning, "BlockJacobianSolveFailed", 
                "Failed to solve the linear system using the LU factorization of the block Jacobian, <errorCode: %d> returned in <block: %s> at <t: %f>.",
                return_code, block->label, block->cur_time);
    } else {
        node = jmi_log_enter_fmt(block->log, logWarning, "UnknownFailure", 
                "Unknown <errorCode: %d> returned from the realtime solver in <block: %s> at <t: %f>.", 
                return_code, block->label, block->cur_time);
    }
    
    
    if (block->callbacks->log_options.log_level >= 3) { 
        jmi_log_reals(block->log, node, logWarning, "ivs", x, block->n); 
    }

    jmi_log_leave(block->log, node);
}
