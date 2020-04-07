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

#include "jmi_minpack_solver.h"
#include "jmi_block_solver_impl.h"

static double max_norm(int n, const real *y) {
    double norm = 0.0;
    int i = 0;
    
    for (i=0; i < n; i++) {
        if (y[i] > 0.0 && y[i] > norm) {
            norm = y[i];
        } else if (y[i] < 0.0 && -1.0*y[i] > norm) {
            norm = -1.0*y[i];
        }
    }
    return norm;
}

static int fcn(void *problem_data, int n, const real *y, real *fvec, int iflag ){
    jmi_block_solver_t *block = problem_data;
    int ret;
    
    ret = block->F(block->problem_data,(jmi_real_t*)y,(jmi_real_t*)fvec,JMI_BLOCK_EVALUATE);
    
    return ret;
}

static int minpack_f(void *problem_data, int n, const real *y, real *fvec, real *fjac,
        int ldfjac, int iflag) {
    
    jmi_block_solver_t *block = problem_data;
    int i;
    int ret = 0;
    block->nb_fevals++;
    
    /* Test if input is OK (no -1.#IND) */
    for (i=0;i<n;i++) {
        /* Unrecoverable error*/
        if (y[i]-y[i] != 0) {
            jmi_log_node(block->log, logWarning, "NaNInput", "Not a number in <input: #r%d#> to <block: %s>", 
                         block->value_references[i], block->label);
            return -1;
        }
    }
    if (iflag == 0) {
        /* Log the progression of the solver */
        double resnorm = max_norm(n, fvec);
        jmi_log_node_t topnode = jmi_log_enter(block->log, logInfo, "MinpackInfo");

        jmi_log_fmt(block->log, topnode, logInfo, "<iteration_index:%I>", ++block->nb_iters);
        jmi_log_reals(block->log, topnode, logInfo, "ivs", y, block->n);
        jmi_log_reals(block->log, topnode, logInfo, "residual", fvec, block->n);
        jmi_log_fmt(block->log, topnode, logInfo, "<residual_norm:%E>", resnorm);

        jmi_log_leave(block->log, topnode);
        
    } else if (iflag == 1) {
        /*Evaluate the residual*/
        ret = block->F(block->problem_data,(jmi_real_t*)y,(jmi_real_t*)fvec,JMI_BLOCK_EVALUATE);
    } else {
        /*Evaluate the jacobian*/
        if (block->dF) {
            int j;
            /* Utilize directional derivatives to calculate Jacobian */
            for(i = 0; i < n; i++){
                block->dx[i] = 1;
                ret |= block->dF(block->problem_data,(jmi_real_t*)y,block->dx,block->res,block->dres,JMI_BLOCK_EVALUATE);
                for(j = 0; j < n; j++){
                    real dres = block->dres[j];
                    (fjac)[i*n+j] = dres;
                }
                block->dx[i] = 0;
            }       
        } else {
            /* Finite Difference Jacobian */
            jmi_minpack_solver_t* solver = block->solver;
            int flag;
            real epsfcn = 1e-8;
            
            flag = fcn(problem_data,n,y,fvec,iflag);
            
            memcpy(solver->ytemp, y, n*sizeof(real));
            
            flag =  __cminpack_func__(fdjac1)(fcn,
                problem_data, n, solver->ytemp, fvec, fjac, ldfjac,
                n-1, n-1, epsfcn, solver->rworkj1, solver->rworkj2);
                
            if (flag < 0) {
                ret = -1;
            } else {
                ret = 0;
            }
        }
        
        if((block->callbacks->log_options.log_level >= 4)) {
            jmi_log_node_t node = jmi_log_enter_fmt(block->log, logInfo, "JacobianUpdated", "<block:%s>", block->label);
            if((block->callbacks->log_options.log_level >= 6)) {
                jmi_log_real_matrix(block->log, node, logInfo, "jacobian", fjac, n, n);
            }
            jmi_log_leave(block->log, node);
        }
    }
    
    if(ret) {
        jmi_log_node(block->log, logWarning, "ErrOutput", "<errorCode: %d> returned from function evaluation in <block: %s>", 
                     ret, block->label);
        return ret;
    }
    
    /* Test if output is OK (no -1.#IND) */
    if (iflag == 1) {
        for (i=0;i<n;i++) {
            double v = fvec[i];
            /* Recoverable error*/
            if (v- v != 0) {
                jmi_log_node(block->log, logWarning, "NANOutput", 
                             "Not a number in <output: %I> from <block: %s>", i, block->label);
                ret = 1;
            }
        }
    }

    return ret; /*Success*/
}

int jmi_minpack_solver_new(jmi_minpack_solver_t** solver_ptr, jmi_block_solver_t* block) {
    jmi_minpack_solver_t* solver;
    int flag = 1, n = block->n;
    
    solver = (jmi_minpack_solver_t*)calloc(1,sizeof(jmi_minpack_solver_t));
    
    solver->lr = (int)((n*(n+1))/2+1); /* Why +1?? */
    
    solver->yscale = (real*)calloc(n, sizeof(real));
    solver->ytemp = (real*)calloc(n, sizeof(real));
    solver->rwork1 = (real*)calloc(n, sizeof(real));
    solver->rwork2 = (real*)calloc(n, sizeof(real));
    solver->rwork3 = (real*)calloc(n, sizeof(real));
    solver->rwork4 = (real*)calloc(n, sizeof(real));
    solver->qTf = (real*)calloc(n, sizeof(real));
    solver->qr = (real*)calloc(solver->lr, sizeof(real));
    
    solver->rworkj1 = (real*)calloc(n, sizeof(real));
    solver->rworkj2 = (real*)calloc(n, sizeof(real));
    
    *solver_ptr = solver;
    return flag;
}

static void jmi_minpack_solver_print_solve_start(jmi_block_solver_t * block,
                                         jmi_log_node_t *destnode) {
    if((block->callbacks->log_options.log_level >= 5)) {
        jmi_log_t *log = block->log;
        *destnode = jmi_log_enter_fmt(log, logInfo, "PowellHybridMethod", 
                                      "MINPACK invoked for <block:%s>", block->label);
        jmi_log_vrefs(log, *destnode, logInfo, "variables", 'r', block->value_references, block->n);
        jmi_log_reals(log, *destnode, logInfo, "max", block->max, block->n);
        jmi_log_reals(log, *destnode, logInfo, "min", block->min, block->n);
        jmi_log_reals(log, *destnode, logInfo, "nominal", block->nominal, block->n);
        jmi_log_reals(log, *destnode, logInfo, "initial_guess", block->initial, block->n);        
    }
}

static void jmi_minpack_solver_print_solve_end(jmi_minpack_solver_t* solver, jmi_block_solver_t * block,
                                               const jmi_log_node_t *node, int flag) {
    
    jmi_log_t *log = block->log;
    if (flag == 0) {
        jmi_log_node(log, logError, "Error", "<returnCode: %d> returned from <block: %s> "
            "improper input parameters.", flag, block->label);
    } else if (flag  == 1) {
        jmi_log_node(log, logInfo, "Info", "<returnCode: %d> returned from <block: %s> "
            "relative error between two consecutive iterates is at most <xtol: %f>.", flag, block->label, solver->ytol);
    } else if (flag  == 2) {
        jmi_log_node(log, logError, "Error", "<returnCode: %d> returned from <block: %s> "
            "reached the maximum number of function calls allowed.", flag, block->label);
    } else if (flag  == 3) {
        jmi_log_node(log, logError, "Error", "<returnCode: %d> returned from <block: %s> "
            "<xtol: %f> is too small. no further improvement in the approximate solution x is possible.", flag, block->label, solver->ytol, block->x);
    } else if (flag  == 4) {
        jmi_log_node(log, logError, "Error", "<returnCode: %d> returned from <block: %s> "
            "iteration is not making good progress, as measured by the improvement from the last five jacobian evaluations.", flag, block->label);
    } else if (flag  == 5) {
        jmi_log_node(log, logError, "Error", "<returnCode: %d> returned from <block: %s> "
            "iteration is not making good progress, as measured by the improvement from the last ten iterations.", flag, block->label);
    }
    jmi_log_fmt(log, *node, logInfo, "Minpack solver finished with <minpack_exit_flag: %d>", flag);

    jmi_log_leave(log, *node);
}

static int jmi_minpack_init(jmi_block_solver_t * block) {
    jmi_minpack_solver_t* solver = block->solver;
    
    /* set tolerances */
    if((block->n > 1) || !block->options->use_Brent_in_1d_flag) {
        solver->ytol = block->options->res_tol;
        if(solver->ytol < block->options->min_tol) {
            solver->ytol = block->options->min_tol;
        }
    }
    else
        solver->ytol = block->options->min_tol;
    
    return 1;
}

int jmi_minpack_solver_solve(jmi_block_solver_t* block) {
    jmi_minpack_solver_t* solver = block->solver;
    jmi_log_node_t topnode={0};
    int info, i;
    int mode; /* 2 for scaling with nominals, 1 for scaling done internally */
    int nprint = 1; /* Enables logging entire simulation. */
    int nbr_fcn_evals = 0, nbr_jac_evals = 0;
    int max_fcn_evals = 200; /* Max number of function evaluations */
    real factor = block->options->step_limit_factor * 10; /* Default is 100 and is scaled with the option step_limit_factor */

    if (block->options->iteration_variable_scaling_mode == 2) {
        /* utilize the heuristict of MINPACK to guess nominal, internal scaling */
        mode = 1;
    } else {
        /* use the nominals from the block, external scaling */
        mode = 2;
        for (i = 0; i < block->n; i++) {
            solver->yscale[i] = 1.0/block->nominal[i];
        }
    }
    
    
    if(block->init) {
        jmi_minpack_init(block);
    }

    block->nb_iters = 0;
    
    jmi_minpack_solver_print_solve_start(block, &topnode);
    info = __cminpack_func__(hybrj)(minpack_f, (void*)block, block->n, block->x,
	      block->res, block->jac, block->n, solver->ytol,
          max_fcn_evals, solver->yscale, mode, factor,
	      nprint, &nbr_fcn_evals, &nbr_jac_evals, solver->qr,
	      solver->lr, solver->qTf, solver->rwork1, solver->rwork2,
	      solver->rwork3, solver->rwork4);
    jmi_minpack_solver_print_solve_end(solver, block, &topnode, info);
    
    if (info != 1) {
        info = -1;
    } else {
        info = 0;
    }
    
    return info;
    
}

void jmi_minpack_solver_delete(jmi_block_solver_t* block) {
    jmi_minpack_solver_t* solver = block->solver;
    
    free(solver->yscale);
    free(solver->ytemp);
    free(solver->rwork1);
    free(solver->rwork2);
    free(solver->rwork3);
    free(solver->rwork4);
    free(solver->qTf);
    free(solver->qr);
    
    free(solver->rworkj1);
    free(solver->rworkj2);
    
    /*Deallocate struct */
    free(solver);
    block->solver = 0;
}
