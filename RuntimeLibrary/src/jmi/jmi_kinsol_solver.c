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

#include <time.h>
#include <string.h>
#include <stdlib.h>

#include <sundials/sundials_math.h>
#include <sundials/sundials_direct.h>
#include <nvector/nvector_serial.h>
#include <kinsol/kinsol_direct.h>
#include <kinsol/kinsol_impl.h>
#include <sundials/sundials_dense.h>

#include "jmi_kinsol_solver.h"
#include "jmi_block_solver_impl.h"
#include "jmi_block_solver.h"
#include "jmi_block_log.h"
#include "jmi_linear_algebra.h"

#include "jmi_brent_search.h"
/* RCONST from SUNDIALS and defines a compatible type, usually double precision */
#define ONE RCONST(1.0)
#define Ith(v,i)    NV_Ith_S(v,i)
#define UROUND 1e-15

#define JMI_LIMIT_VALUE 1e30

#define JMI_DELTA_INCREASE_MAGNITUDE 10.0
#define JMI_MAX_DELTA_INCREASE_MAGNITUDE 100.0
#define JMI_MAX_DELTA 0.1

/* KINSOL callback for linear system solve */
/* static int jmi_kin_lsolve(struct KINMemRec * kin_mem, N_Vector x, N_Vector b, realtype *res_norm); */
static int jmi_kin_lsolve(struct KINMemRec * kin_mem, N_Vector x, N_Vector b, realtype *sJpnorm, realtype *sFdotJp);
/* KINSOL callback for setting up linear solver (jacobian update and decomposition) */
static int jmi_kin_lsetup(struct KINMemRec * kin_mem);

/*Kinsol function wrapper
    @param yy - Input - function argument
    @param ff - Output - residuals
    @param problem_data - solver object propagated as opaque data
*/
int kin_f(N_Vector yy, N_Vector ff, void *problem_data);

/* Only call directly after jmi_update_f_scale */
static void jmi_regularize_and_do_condition_estimate_on_scaled_jacobian(jmi_block_solver_t *block);

static realtype jmi_calculate_jacobian_condition_number(jmi_block_solver_t * block);

/* Calculate Transpose(v1)*diag(w)*diag(w)*v2.
   w can be NULL in which case it is set to identity */
static realtype jmi_kinsol_calc_v1twwv2(N_Vector v1, N_Vector v2, N_Vector w) {
    long int i, N;
    realtype sum, prodi;

    sum = 0.0;

    N  = NV_LENGTH_S(v1);

    if( v1 == v2) {
        N_Vector v = v1;
        realtype *vd;
        vd = NV_DATA_S(v);
        if ( w != 0) {
            realtype *wd;
            wd = NV_DATA_S(w);
            for (i = 0; i < N; i++) {
                prodi = vd[i]*wd[i];
                sum += prodi*prodi;
            }
        } else {
            for (i = 0; i < N; i++) {
                prodi = vd[i];
                sum += prodi*prodi;
            }
        }
    } else {
        realtype *vd1, *vd2;
        vd1 = NV_DATA_S(v1);
        vd2 = NV_DATA_S(v2);
        if ( w != 0) {
            realtype *wd;
            wd = NV_DATA_S(w);
            for (i = 0; i < N; i++) {
                prodi = vd1[i]*wd[i]*wd[i]*vd2[i];
                sum += prodi;
            }
        } else {
            for (i = 0; i < N; i++) {
                prodi = vd1[i]*vd2[i];
                sum += prodi;
            }
        }
    }
    return(sum);
}

/* compare analytical/external and finite differences Jacobians */
static int jmi_kinsol_check_jacobian(jmi_block_solver_t* block, jmi_real_t* jac_finite_difference, jmi_real_t* jac_analytical) {
    int N = block->n, i, j;
    jmi_kinsol_solver_t* solver = block->solver;
    
    if (   block->dF 
        ||(block->Jacobian && (solver->has_compression_setup_flag 
        || block->options->jacobian_calculation_mode == jmi_calculate_externally_jacobian_calculation_mode)))
    {
        for (i = 0; i < N; i++) {
            for (j = 0; j < N; j++) {
                realtype fd_val = jac_finite_difference[i * N + j];
                realtype a_val = jac_analytical[i * N + j];
                realtype rel_error = JMI_ABS(a_val - fd_val) / (JMI_ABS(fd_val) + 1);
                if (rel_error >= block->options->block_jacobian_check_tol) {
                    if(block->options->jacobian_calculation_mode == jmi_calculate_externally_jacobian_calculation_mode) {
                        jmi_log_node(block->log, logError, "JacobianCheck",
                            "<j: %d, i: %d, external: %e, finiteDifference: %e, relativeError: %e>", 
                            j, i, a_val, fd_val, rel_error);
                    }
                    else {
                        jmi_log_node(block->log, logError, "JacobianCheck",
                            "<j: %d, i: %d, analytic: %e, finiteDifference: %e, relativeError: %e>", 
                            j, i, a_val, fd_val, rel_error);
                    }
                }
            }
        }
    } else {
        jmi_log_node(block->log, logError, "JacobianCheck", 
            "No block jacobian specified, unable to do jacobian check");
    }
    return 0;
}

int jmi_kinsol_one_sided_differences_for_one_column(jmi_block_solver_t * block, realtype delta, int column_index, N_Vector jthCol) {
    int ret;
    jmi_kinsol_solver_t* solver = block->solver;
    struct KINMemRec* kin_mem = solver->kin_mem;
    realtype inc, inc_inv, ujsaved, ujscale, sign;
    realtype *u_data, *uscale_data;
    /* Obtain pointers to the data for u and uscale */
    u_data   = N_VGetArrayPointer(solver->kin_y);
    uscale_data = N_VGetArrayPointer(solver->kin_y_scale);
    ujsaved = u_data[column_index];
    ujscale = ONE/uscale_data[column_index];
    sign = (ujsaved >= 0) ? 1 : -1;
    inc = JMI_MAX(JMI_ABS(ujsaved), ujscale)*sign*delta;
    u_data[column_index] += inc;
    /* make sure we're inside bounds*/
    if((u_data[column_index] > block->max[column_index]) || (u_data[column_index] < block->min[column_index])) {
        inc = -inc;
        u_data[column_index] = ujsaved + inc;
    }

    ret = kin_f(solver->kin_y, solver->work_vector, block);
    if(ret > 0) {
        /* try to recover by stepping in the opposite direction */
        inc = -inc;
        u_data[column_index] = ujsaved + inc;

        ret = kin_f(solver->kin_y, solver->work_vector, block);
    }
    if (ret != 0) {
        u_data[column_index] = ujsaved;
        return ret; 
    }
    inc_inv = ONE/inc; 
    N_VLinearSum(inc_inv, solver->work_vector, -inc_inv, kin_mem->kin_fval, jthCol);

    u_data[column_index] = ujsaved;
    return ret;
}

int jmi_kinsol_is_zero_column(realtype* col, int n) {
    int i;
    for(i=0; i<n; i++) {
        if(col[i] != 0) {
            return FALSE;
        }
    }
    return TRUE;
}

int jmi_kinsol_zero_column_jacobian_handling(jmi_block_solver_t * block) {
    int j, ret, is_zero_column;
    int updated_jacobian = FALSE;
    jmi_kinsol_solver_t* solver = block->solver;
    realtype delta;
    realtype *tmp2_data;
    realtype *col;
    N_Vector jthCol;
    
    for(j=0; j<block->n; j++) {
        col = DENSE_COL(block->J, j);
        delta = block->options->jacobian_finite_difference_delta*JMI_DELTA_INCREASE_MAGNITUDE;
        is_zero_column = jmi_kinsol_is_zero_column(col, block->n);
        if(!is_zero_column) continue;
        /* Zero column, try finite differences with greater delta */
        while(is_zero_column && delta < block->options->jacobian_finite_difference_delta*JMI_MAX_DELTA_INCREASE_MAGNITUDE*2 && delta < JMI_MAX_DELTA*10) { 
            tmp2_data = N_VGetArrayPointer(solver->work_vector2);
            jthCol = solver->work_vector2;
            N_VSetArrayPointer(DENSE_COL(block->J, j), jthCol);
            ret = jmi_kinsol_one_sided_differences_for_one_column(block, delta, j, jthCol);
            N_VSetArrayPointer(tmp2_data, solver->work_vector2);
            if(ret != 0) break;
            delta *=JMI_DELTA_INCREASE_MAGNITUDE;
            is_zero_column = jmi_kinsol_is_zero_column(col, block->n);
        }

        if(!is_zero_column) {
            jmi_log_node_t node = jmi_log_enter_fmt(block->log, logInfo, "ZeroColumnJacobianUpdate", 
                "The column for <iter: #r%d#> was zero but is now recalculated with one-sided differences with <delta: %E>", block->value_references[j], delta/JMI_DELTA_INCREASE_MAGNITUDE);
            jmi_log_reals(block->log, node, logInfo, "column", DENSE_COL(block->J, j), block->n);
            jmi_log_leave(block->log, node);
            updated_jacobian = TRUE;
        }
    }
    return updated_jacobian;
}


/* Kinsol Jacobian function wrapper */
int kin_dF(int N, N_Vector u, N_Vector fu, DlsMat J, jmi_block_solver_t * block, N_Vector tmp1, N_Vector tmp2);

/*Kinsol function wrapper
    @param yy - Input - function argument
    @param ff - Output - residuals
    @param problem_data - solver object propagated as opaque data
*/
int kin_f(N_Vector yy, N_Vector ff, void *problem_data){
    realtype *y, *f;
    jmi_block_solver_t *block = problem_data;
    jmi_kinsol_solver_t* solver = block->solver;
    clock_t t = jmi_block_solver_start_clock(block);
    jmi_log_t *log = block->log;
    int n, ret;
    block->nb_fevals++;
    y = NV_DATA_S(yy); /*y is now a vector of realtype*/
    f = NV_DATA_S(ff); /*f is now a vector of realtype*/

    n = NV_LENGTH_S(yy);
    ret = jmi_check_and_log_illegal_iv_input(block, y, n);
    /* Test if input is OK (no -1.#IND) */
    
    if(ret == -1) {
        block->func_eval_time += jmi_block_solver_elapsed_time(block, t);
        return ret;
    }

    /*Evaluate the residual*/
    ret = block->F(block->problem_data,y,f,JMI_BLOCK_EVALUATE);

    if(ret) {
        jmi_log_node_t node = jmi_log_enter_fmt(block->log, logWarning, "ErrOutput", "<errorCode: %d> returned from function evaluation in <block: %s>", 
            ret, block->label);
        if (block->callbacks->log_options.log_level >= 3) {
            jmi_log_reals(log, node, logWarning, "ivs", y, block->n);
        }
        jmi_log_leave(log, node);
        /* Log time */
        block->func_eval_time += jmi_block_solver_elapsed_time(block, t);
        /* Always treat this as a recoverable error */
        return 1;
    }

    /* Test if output is OK (no -1.#IND) */
    n = NV_LENGTH_S(ff);
    ret = jmi_check_and_log_illegal_residual_output(block, f, y, block->residual_heuristic_nominal ,n);
    
    /* record information for Brent search */
    if(!ret && (block->n == 1) && block->options->use_Brent_in_1d_flag) {
        double yv = y[0];
        double fv = f[0];
        if(fv <= 0) {
            if(solver->f_neg_max_1d < fv) {
                solver->f_neg_max_1d = fv;
                solver->y_neg_max_1d = yv;
            }    
        }
        else {
            if(solver->f_pos_min_1d > fv) {
                solver->f_pos_min_1d = fv;
                solver->y_pos_min_1d = yv;
            }    
        }
    }

    /* Log time */
    block->func_eval_time += jmi_block_solver_elapsed_time(block, t);
    return ret; /*Success (1==Recoverable, -1==Unrecoverable)*/
}

static void kin_reset_char_log(jmi_kinsol_solver_t* solver) {
    solver->char_log_length = 0;
    solver->char_log[0] = 0;
}

static void kin_char_log(jmi_kinsol_solver_t* solver, char c) {
    if (solver->char_log_length < JMI_KINSOL_SOLVER_MAX_CHAR_LOG_LENGTH) {
        solver->char_log[solver->char_log_length] = c;
        solver->char_log_length++;
        solver->char_log[solver->char_log_length] = 0;
    } else {
        solver->char_log[JMI_KINSOL_SOLVER_MAX_CHAR_LOG_LENGTH-1] = '?';
    }
}

int jmi_kin_setup_column_partition(jmi_block_solver_t * block) {
    jmi_kinsol_solver_t* solver = (jmi_kinsol_solver_t*)block->solver;
    int N = block->n;
    int leftColumns = N;
    int i, group = 0;
    N_Vector col_i = N_VCloneEmpty(solver->work_vector);

    N_VConst(0.0, solver->work_vector);
    while(leftColumns > 0 && group <N) {
        group++;
        N_VConst(0.0, solver->work_vector2);
        for(i = 0; i<N; i++) {
            if(Ith(solver->work_vector, i) == 0.0) {
                N_VSetArrayPointer(DENSE_COL(solver->J_Dependency, i), col_i);
                
                if(N_VDotProd(solver->work_vector2, col_i) == 0.0) { /* Column can be added */                  
                    N_VLinearSum(1.0, solver->work_vector2, 1.0, col_i, solver->work_vector2);

                    solver->jac_compression_groups[N-leftColumns]=group;
                    solver->jac_compression_group_index[N-leftColumns]=i;
                    Ith(solver->work_vector, i) = 1.0;
                    leftColumns--;
                }
            }
        }
    }
    N_VDestroy(col_i);
    
    if(leftColumns != 0) {
        jmi_log_node(block->log, logWarning, "ColumnPartitioning", "Column partitioning error, dependency data may be corrupt.");
        return -1;
    }
    return 0;
}

/* Wrapper function to Jacobian evaluation as needed by standard KINSOL solvers */
int kin_dF(int N, N_Vector u, N_Vector fu, DlsMat J, jmi_block_solver_t * block, N_Vector tmp1, N_Vector tmp2){
    clock_t t = jmi_block_solver_start_clock(block);
    jmi_kinsol_solver_t* solver = (jmi_kinsol_solver_t*)block->solver;            
    int i, j, ret = 0;
    realtype curtime = block->cur_time;
    realtype *jac_fd = NULL;
    solver->kin_jac_update_time = curtime;
    block->nb_jevals++;

    kin_char_log(solver, 'J');
    if((block->callbacks->log_options.log_level >= 6)) {
        char message[256];
        sprintf(message, "Updating Jacobian (evaluations: %d)", (int)block->nb_jevals);
        jmi_log_node(block->log, logInfo, "Progress", "<source:%s><block:%s><message:%s>",
            "jmi_kinsol_solver", block->label, message);
    }

    if ((!solver->has_compression_setup_flag && ((!block->dF && !block->Jacobian) || (block->options->jacobian_calculation_mode != jmi_calculate_externally_jacobian_calculation_mode && !block->dF)
        || (!block->Jacobian && block->options->jacobian_calculation_mode == jmi_calculate_externally_jacobian_calculation_mode))) || block->options->block_jacobian_check) {
            /* Use (almost) standard finite differences */
            realtype inc, inc_inv, ujsaved, ujscale, sign;
            realtype *tmp2_data, *u_data, *uscale_data;
            N_Vector ftemp, jthCol;
            /* Save pointer to the array in tmp2 */
            tmp2_data = N_VGetArrayPointer(tmp2);

            /* Make sure that the residual values are up to date */
            ret = kin_f(u, fu, block);
            if(ret != 0) {
                block->jac_eval_time += jmi_block_solver_elapsed_time(block, t);
                return ret;
            }

            /* Rename work vectors for readability */
            ftemp = tmp1; 
            jthCol = tmp2;

            /* Obtain pointers to the data for u and uscale */
            u_data   = N_VGetArrayPointer(u);
            uscale_data = N_VGetArrayPointer(solver->kin_y_scale);

            /* This is the only for loop for 0..N-1 in KINSOL */

            for (j = 0; j < N; j++) {
                realtype sqrt_relfunc = block->options->jacobian_finite_difference_delta; /*kin_mem->kin_sqrt_relfunc;*/
                int utilize_central_differences;


                ujsaved = u_data[j];
                ujscale = ONE/uscale_data[j];
                sign = (ujsaved >= 0) ? 1 : -1;
                inc = JMI_MAX(JMI_ABS(ujsaved), ujscale)*sign;

                switch(block->options->jacobian_calculation_mode) {
                case jmi_central_diffs_jacobian_calculation_mode:
                    utilize_central_differences = TRUE;
                    break;
                case jmi_central_diffs_at_bound_jacobian_calculation_mode:
                    if(( (block->max[j]-ujsaved) < 2*sqrt_relfunc*JMI_ABS(inc) && block->max[j] > 0 ) || 
                        ((ujsaved-block->min[j]) < 2*sqrt_relfunc*JMI_ABS(inc) && block->min[j] < 0)) {
                        utilize_central_differences = TRUE;
                    } else {
                        utilize_central_differences = FALSE;
                    }
                    break;
                case jmi_central_diffs_at_bound_and_zero_jacobian_calculation_mode:
                    if(( (block->max[j]-ujsaved) < 2*sqrt_relfunc*JMI_ABS(inc) && block->max[j] > 0 ) || 
                        ((ujsaved-block->min[j]) < 2*sqrt_relfunc*JMI_ABS(inc) && block->min[j] < 0)) {
                        utilize_central_differences = TRUE;
                    } else if(ujsaved*sign < sqrt_relfunc*JMI_ABS(inc) && block->max[j] !=0 && block->min[j] !=0) {
                        utilize_central_differences = TRUE;
                    } else {
                        utilize_central_differences = FALSE;
                    }
                    break;
                case jmi_central_diffs_solve2_jacobian_calculation_mode:
                    if(!solver->is_first_newton_solve_flag) {
                        utilize_central_differences = TRUE;
                    } else {
                        utilize_central_differences = FALSE;
                    }
                    break;
                case jmi_central_diffs_at_bound_solve2_jacobian_calculation_mode:
                    if(!solver->is_first_newton_solve_flag) {
                        if(( (block->max[j]-ujsaved) < 2*sqrt_relfunc*JMI_ABS(inc) && block->max[j] > 0 ) || 
                            ((ujsaved-block->min[j]) < 2*sqrt_relfunc*JMI_ABS(inc) && block->min[j] < 0)) {
                            utilize_central_differences = TRUE;
                        } else {
                            utilize_central_differences = FALSE;
                        }
                    } else {
                        utilize_central_differences = FALSE;
                    }
                    break;
                case jmi_central_diffs_at_bound_and_zero_solve2_jacobian_calculation_mode:
                    if(!solver->is_first_newton_solve_flag) {
                        if(( (block->max[j]-ujsaved) < 2*sqrt_relfunc*JMI_ABS(inc) && block->max[j] > 0 ) || 
                            ((ujsaved-block->min[j]) < 2*sqrt_relfunc*JMI_ABS(inc) && block->min[j] < 0)) {
                            utilize_central_differences = TRUE;
                        } else if(ujsaved*sign < sqrt_relfunc*JMI_ABS(inc)&& block->max[j] !=0 && block->min[j] !=0) {
                            utilize_central_differences = TRUE;
                        } else {
                            utilize_central_differences = FALSE;
                        }
                    } else {
                        utilize_central_differences = FALSE;
                    }
                    break;
                case jmi_central_diffs_at_small_res_jacobian_calculation_mode:
                    if(solver->last_fnorm < 1e-2 && solver->last_fnorm > 0) {
                        utilize_central_differences = TRUE;
                    } else {
                        utilize_central_differences = FALSE;
                    }
                    break;
                default: 
                    utilize_central_differences = FALSE;
                    break;
                }

                /* Central differences to be utilized  under certain conditions */
                if(utilize_central_differences) {
                    double incLeft = 0.0, incRight = 0.0, leftPart, rightPart;
                    /*jmi_log_node_t node = jmi_log_enter(block->log, logInfo, "CentralDifferences"); */
                    inc = JMI_ABS(inc);
                    incRight = JMI_MIN(block->max[j]-ujsaved, sqrt_relfunc*inc);
                    u_data[j] = ujsaved + incRight;
                    ret = kin_f(u, ftemp, block);

                    u_data[j] = ujsaved;
                    if(ret == 0 ) {
                        if(incRight > 0)
                            inc_inv = ONE/incRight;
                        else
                            inc_inv = 0;
                        N_VLinearSum(inc_inv, ftemp, -inc_inv, fu, solver->work_vector2);
                    } else {
                        incRight = 0;
                    }

                    incLeft = JMI_MIN(ujsaved-block->min[j], sqrt_relfunc*inc);
                    u_data[j] = ujsaved - incLeft;
                    ret = kin_f(u, ftemp, block);

                    if(ret == 0) {
                        if(incLeft > 0)
                            inc_inv = -ONE/incLeft;
                        else
                            inc_inv = 0;
                        N_VLinearSum(inc_inv, ftemp, -inc_inv, fu, solver->work_vector);             
                    } else {
                        incLeft = 0;
                    }

                    if((block->options->jacobian_calculation_mode == jmi_central_diffs_at_bound_and_zero_jacobian_calculation_mode ||
                        block->options->jacobian_calculation_mode == jmi_central_diffs_at_bound_jacobian_calculation_mode ||
                        block->options->jacobian_calculation_mode == jmi_central_diffs_at_bound_and_zero_solve2_jacobian_calculation_mode ||
                        block->options->jacobian_calculation_mode == jmi_central_diffs_at_bound_solve2_jacobian_calculation_mode) &&
                        (block->max[j]-ujsaved) > sqrt_relfunc*inc && (block->max[j]-ujsaved) < 2*sqrt_relfunc*inc && sign > 0) {
                            rightPart = 0.5*((block->max[j]-ujsaved)-sqrt_relfunc*inc)/(sqrt_relfunc*inc)+0.5;
                            leftPart = 1 - rightPart;
                    } else if((block->options->jacobian_calculation_mode == jmi_central_diffs_at_bound_and_zero_jacobian_calculation_mode ||
                        block->options->jacobian_calculation_mode == jmi_central_diffs_at_bound_jacobian_calculation_mode ||
                        block->options->jacobian_calculation_mode == jmi_central_diffs_at_bound_and_zero_solve2_jacobian_calculation_mode ||
                        block->options->jacobian_calculation_mode == jmi_central_diffs_at_bound_solve2_jacobian_calculation_mode) &&
                        (ujsaved-block->min[j]) > sqrt_relfunc*inc && (ujsaved-block->min[j]) < 2*sqrt_relfunc*inc && sign < 0) {
                            leftPart = 0.5*((ujsaved-block->min[j])-sqrt_relfunc*inc)/(sqrt_relfunc*inc)+0.5;
                            rightPart = 1-leftPart;
                    } else if( (block->options->jacobian_calculation_mode == jmi_central_diffs_at_bound_and_zero_jacobian_calculation_mode ||
                        block->options->jacobian_calculation_mode == jmi_central_diffs_at_bound_and_zero_solve2_jacobian_calculation_mode) && 
                        ujsaved*sign < sqrt_relfunc*inc && sign > 0) {
                            rightPart = 0.5*(ujsaved*sign)/(sqrt_relfunc*inc)+0.5;
                            leftPart = 1 - rightPart;
                    } else if((block->options->jacobian_calculation_mode == jmi_central_diffs_at_bound_and_zero_jacobian_calculation_mode ||
                        block->options->jacobian_calculation_mode == jmi_central_diffs_at_bound_and_zero_solve2_jacobian_calculation_mode) && 
                        ujsaved*sign < sqrt_relfunc*inc  && sign < 0) {
                            leftPart = 0.5*(ujsaved*sign)/(sqrt_relfunc*inc)+0.5;
                            rightPart = 1 - leftPart;
                    } else {
                        rightPart = incRight/(incRight+incLeft);
                        leftPart = incLeft/(incRight+incLeft);
                    }
                    /* Generate the jth col of Jac(u) */
                    N_VSetArrayPointer(DENSE_COL(J, j), jthCol);
                    N_VLinearSum(rightPart, solver->work_vector2, leftPart, solver->work_vector, jthCol);
                    u_data[j] = ujsaved;
                    /* Restore original array pointer in tmp2 */
                    N_VSetArrayPointer(tmp2_data, tmp2);
                    /*jmi_log_leave(block->log, node);*/
                    if(incLeft == 0 && incRight == 0) break;
                    continue;
                }
                if(sqrt_relfunc > 0) 
                    inc *= sqrt_relfunc;
                /* Generate the jth col of Jac(u) */
                N_VSetArrayPointer(DENSE_COL(J, j), jthCol);
                ret = jmi_kinsol_one_sided_differences_for_one_column(block, sqrt_relfunc, j, jthCol);
                /* Restore original array pointer in tmp2 */
                N_VSetArrayPointer(tmp2_data, tmp2);
                if (ret != 0) break; 
            }

            /* Evaluate the residual with the original u vector to avoid that the initial guess 
            for the final IV is pertubated when the iterations start*/
            /*ret = kin_f(u, ftemp, block);*/

            if (block->options->block_jacobian_check) {
                jac_fd = (realtype*) calloc(N * N, sizeof(realtype));
                for (i = 0; i < N * N; i++) {
                    jac_fd[i] = J->data[i];
                }
            }
    }

    if (solver->has_compression_setup_flag && block->options->jacobian_calculation_mode == jmi_compression_jacobian_calculation_mode && block->Jacobian) {
            /* Use (almost) standard finite differences */
            realtype inc, inc_inv, ujsaved, ujscale, sign;
            realtype *tmp2_data, *u_data, *uscale_data;
            N_Vector ftemp, jthCol, utemp;
            int k, first_index_in_group = 0;

            /* Save pointer to the array in tmp2 */
            tmp2_data = N_VGetArrayPointer(tmp2);

            /* Make sure that the residual values are up to date */
            ret = kin_f(u, fu, block);
            if(ret != 0) {
                block->jac_eval_time += jmi_block_solver_elapsed_time(block, t);
                return ret;
            }

            /* Rename work vectors for readibility */
            ftemp = tmp1; 
            jthCol = tmp2;

            /* Make sure we save initial point */
            utemp = solver->work_vector2;
            N_VScale(1.0, u, utemp); 
            /* Obtain pointers to the data for u and uscale */
            u_data   = N_VGetArrayPointer(u);
            uscale_data = N_VGetArrayPointer(solver->kin_y_scale);

            /* This is the only for loop for 0..N-1 in KINSOL */

            for (i = 0; i < N; i++) {
                realtype sqrt_relfunc = block->options->jacobian_finite_difference_delta; /*kin_mem->kin_sqrt_relfunc;*/
                j = solver->jac_compression_group_index[i];  
                ujsaved = u_data[j];
                ujscale = ONE/uscale_data[j];
                sign = (ujsaved >= 0) ? 1 : -1;
                inc = JMI_MAX(JMI_ABS(ujsaved), ujscale)*sign;
                if(sqrt_relfunc > 0) 
                    inc *= sqrt_relfunc;
                u_data[j] += inc;
                /* make sure we're inside bounds*/
                if((u_data[j] > block->max[j]) || (u_data[j] < block->min[j])) {
                    inc = -inc;
                    u_data[j] = ujsaved + inc;
                }
                Ith(solver->work_vector,j) = inc;

                if(i==N-1 || solver->jac_compression_groups[i] != solver->jac_compression_groups[i+1]) {
                    ret = kin_f(u, ftemp, block);
                    N_VScale(1.0, utemp, u);
                } else {
                    continue;
                }
                if (ret != 0) break; 


                for(k=first_index_in_group; k<=i; k++) {
                    inc_inv = ONE/Ith(solver->work_vector, solver->jac_compression_group_index[k]);
                    /* Generate the jth col of Jac(u) */
                    N_VSetArrayPointer(DENSE_COL(J, solver->jac_compression_group_index[k]), jthCol);
                    N_VLinearSum(inc_inv, ftemp, -inc_inv, fu, jthCol);
                    
                    N_VSetArrayPointer(DENSE_COL(solver->J_Dependency, solver->jac_compression_group_index[k]), solver->work_vector3);
                    N_VProd(solver->work_vector3, jthCol, jthCol);
                    
                }
                /* Restore original array pointer in tmp2 */
                N_VSetArrayPointer(tmp2_data, tmp2);
                first_index_in_group = i+1;
                /* Make sure we save initial point */
                N_VScale(1.0, u, utemp); 
            }
    }
    if(block->Jacobian && (block->options->jacobian_calculation_mode == jmi_calculate_externally_jacobian_calculation_mode) && !solver->has_compression_setup_flag) {
        ret = block->Jacobian(block->problem_data, N_VGetArrayPointer(u), J->cols, JMI_BLOCK_EVALUATE_JAC);
    }

    if (block->dF && (block->options->jacobian_calculation_mode != jmi_calculate_externally_jacobian_calculation_mode)) {
        /* utilize directional derivatives to calculate Jacobian */
        for(i = 0; i < N; i++){ 
            block->x[i] = Ith(u,i);
        }
        for(i = 0; i < N; i++){
            block->dx[i] = 1;
            ret |= block->dF(block->problem_data,block->x,block->dx,block->res,block->dres,JMI_BLOCK_EVALUATE);
            for(j = 0; j < N; j++){
                realtype dres = block->dres[j];
                (J->data)[i*N+j] = dres;
            }
            DENSE_COL(J,i) = &(J->data)[i*N];
            block->dx[i] = 0;
        }       
    }
    
    /* Verify Jacobian */
    if (block->options->block_jacobian_check) {
        jmi_kinsol_check_jacobian(block, jac_fd, J->data);
        free(jac_fd);
    }

    if((block->callbacks->log_options.log_level >= 4) && ret == 0) { /* Do only log if succeeded */
        jmi_log_node_t node = jmi_log_enter_fmt(block->log, logInfo, "JacobianUpdated", "<block:%s>", block->label);
        if (block->callbacks->log_options.log_level >= 6) {
            jmi_log_real_matrix(block->log, node, logInfo, "jacobian", J->data, N, N);
        }
        jmi_log_leave(block->log, node);
    }

    block->jac_eval_time += jmi_block_solver_elapsed_time(block, t);
    return ret;
}

static void jmi_kinsol_linesearch_error_message(jmi_block_solver_t * block, const char* msg) {
    jmi_kinsol_solver_t* solver = block->solver;
    jmi_log_node_t node = jmi_log_enter(block->log, logError, "KinsolError");
    realtype fnorm, snorm;
    KINGetFuncNorm(solver->kin_mem, &fnorm);
    KINGetStepLength(solver->kin_mem, &snorm);
    
    jmi_log_fmt(block->log, node, logError, "Error occured in <function: %s> at <t: %f> when solving <block: %s>",
        "KINSol", block->cur_time, block->label);
    jmi_log_fmt(block->log, node, logError, "<msg: %s>", msg);
    jmi_log_fmt(block->log, node, logError, "<functionL2Norm: %g, scaledStepLength: %g, tolerance: %g>",
                fnorm, snorm, solver->kin_stol);
    jmi_log_leave(block->log, node);
}

static void jmi_kinsol_small_step_nonconv_info_message(jmi_block_solver_t * block) {
    jmi_kinsol_solver_t* solver = block->solver;
    jmi_log_category_t logCategory = logInfo;
    jmi_log_node_t node;
    realtype fnorm, snorm;
    if(block->options->solver_exit_criterion_mode == jmi_exit_criterion_step_residual) 
        logCategory = logError;
    node = jmi_log_enter(block->log, logCategory, "KinsolErrorInfo");
    KINGetFuncNorm(solver->kin_mem, &fnorm);
    KINGetStepLength(solver->kin_mem, &snorm);
    
    jmi_log_fmt(block->log, node, logCategory, "Error occured in <function: %s> at <t: %f> when solving <block: %s>",
        "KINSol", block->cur_time, block->label);
    jmi_log_fmt(block->log, node, logCategory, "<msg: %s>", "Step norm criterion is satisfied but residual norm is above the tolerance.");
    jmi_log_fmt(block->log, node, logCategory, "<functionL2Norm: %g, scaledStepLength: %g, tolerance: %g>",
                fnorm, snorm, solver->kin_stol);
    jmi_log_leave(block->log, node);
}

/* Local helper that will log the condition number of the Jacobian */
static void jmi_kinsol_log_jacobian_cond_nbr(jmi_block_solver_t *block) {
    jmi_kinsol_solver_t* solver = block->solver;
    int info, N = block->n;
    realtype tol = solver->kin_stol;

    dgetrf_(&N, &N, block->J_scale->data, &N, solver->lapack_iwork, &info);
    if(info > 0) {
        jmi_log_node(block->log, logWarning, "SingularJacobian",
            "Singular Jacobian detected when checking condition number in <block:%s>. Solver may fail to converge.", block->label);
    }
    else {
        char norm = 'I';
        double Jnorm = 1.0, Jcond = 1.0;
        dgecon_(&norm, &N, block->J_scale->data, &N, &Jnorm, &Jcond, solver->lapack_work, solver->lapack_iwork,&info);       

        if(tol * Jcond < UNIT_ROUNDOFF) {
            jmi_log_node_t node = jmi_log_enter_fmt(block->log, logWarning, "IllConditionedJacobian",
                "<JacobianInverseConditionEstimate:%E> Solver may fail to converge in <block: %s>.", Jcond, block->label);
            if (block->callbacks->log_options.log_level >= 4) {
                jmi_log_reals(block->log, node, logWarning, "ivs", N_VGetArrayPointer(solver->kin_y), block->n);
            }
            jmi_log_leave(block->log, node);

        }
        else {
            jmi_log_node(block->log, logInfo, "JacobianCondition",
                "<JacobianInverseConditionEstimate:%E>", Jcond);
        }
    }
}

/* Logging callback for KINSOL used to report on errors during solution */
void kin_err(int err_code, const char *module, const char *function, char *msg, void *eh_data){
    jmi_log_category_t category = logWarning;
    jmi_block_solver_t *block = eh_data;
    jmi_kinsol_solver_t* solver = block->solver;
    clock_t t = jmi_block_solver_start_clock(block);
    realtype fnorm, snorm;
    KINGetFuncNorm(solver->kin_mem, &fnorm);
    KINGetStepLength(solver->kin_mem, &snorm);
    
    if((block->n == 1) && block->options->use_Brent_in_1d_flag)  /* Brent search will be used to find the root if possible -> no error */
            /* || (fnorm < solver->kin_stol)): In some cases KINSOL actually converges but returns an error anyway. Need to be double checked! */
    {
        block->logging_time += jmi_block_solver_elapsed_time(block, t);
        return;
    }
    
    if ((err_code > 0) || !block->init) { /*Warning*/
        category = logWarning;
    } else if (err_code < 0){ /*Error*/
        category = logError;
    }
    
    if (err_code != KIN_LINESEARCH_NONCONV && err_code != KIN_LINESEARCH_BCFAIL) /* If the error is LINSEARCH_NONCONV it might not be an error depending 
                                               in on the fnorm, so post-pone this error message in these cases */
    {
        jmi_log_node_t node = jmi_log_enter(block->log, category, "KinsolError");
        jmi_log_fmt(block->log, node, category, "Error occured in <function: %s> at <t: %f> when solving <block: %s>",
            function, block->cur_time, block->label);
        jmi_log_fmt(block->log, node, category, "<msg: %s>", msg);
        jmi_log_fmt(block->log, node, category, "<functionL2Norm: %g, scaledStepLength: %g, tolerance: %g>",
                    fnorm, snorm, solver->kin_stol);
        jmi_log_leave(block->log, node);

        if(block->options->check_jac_cond_flag) {
            int i, N = block->n;
            realtype tol = solver->kin_stol;
            realtype *scale_ptr = N_VGetArrayPointer(block->f_scale);
            if(block->options->residual_equation_scaling_mode != 0) {
                for(i = 0; i < N; i++){
                    int j;
                    realtype* scaled_col_ptr = DENSE_COL(block->J_scale, i);
                    realtype* col_ptr = DENSE_COL(block->J, i);
                    realtype xscale = JMI_ABS(block->nominal[i]);
                    realtype x = JMI_ABS(block->x[i]);
                    if(x < xscale) x = xscale;
                    if(x < tol) x = tol;
                    for(j = 0; j < N; j++){
                        scaled_col_ptr[j] = col_ptr[j] * x *scale_ptr[j];
                    }
                }
            } else {
                DenseCopy(block->J, block->J_scale);
            }
            
            jmi_kinsol_log_jacobian_cond_nbr(block);
        }
    }

    block->logging_time += jmi_block_solver_elapsed_time(block, t);
}

static void jmi_kinsol_print_progress(jmi_block_solver_t *block, int logResidualOnlyFlag, int convergence_flag) {
    jmi_kinsol_solver_t* solver = (jmi_kinsol_solver_t*)block->solver;
    jmi_log_t *log = block->log;
    struct KINMemRec* kin_mem = (struct KINMemRec*)solver->kin_mem;
    long nniters;
    char message[256];

    if (block->callbacks->log_options.log_level < 4) return;
    KINGetNumNonlinSolvIters(kin_mem, &nniters);
    /* Only print header first iteration */
    if (nniters == 0 && logResidualOnlyFlag != 2) { /* Do not print header if INITIAL_GUESS ok */
        jmi_log_node(log, logInfo, "Progress", "<source:%s><message:%s><isheader:%d>",
            "jmi_kinsol_solver",
            "iter       res_norm      max_res: ind   nlb  nab   lambda_max: ind      lambda",
            1);
    }
    if(logResidualOnlyFlag && convergence_flag != KIN_LINESEARCH_BCFAIL) {
        /* last log in the solve trace - use (nniter+1)*/
        nniters = nniters + 1;
    }
    if (nniters > 0) {
        int nwritten = 0;
        /* Keep the progress message on a single line by using jmi_log_enter_, jmi_log_fmt_ etc. */
        jmi_log_node_t node = jmi_log_enter_(log, logInfo, "Progress");
        
        nwritten = sprintf(message, "%4d%-4s%11.4e % 11.4e:%4d", (int)nniters, solver->char_log,
            solver->last_fnorm, solver->last_max_residual, solver->last_max_residual_index+1);
        kin_reset_char_log(solver);
        if(!logResidualOnlyFlag) {
            char*  buffer = message + nwritten;
            if (solver->last_bounding_index >= 0) {
                if(solver->range_most_limiting) {
                    sprintf(buffer, "  %4d %4d  %11.4e:%4dr %11.4e",
                        solver->last_num_limiting_bounds, solver->last_num_active_bounds,
                        solver->lambda_max, solver->last_bounding_index+1, solver->lambda);
                }
                else {
                    sprintf(buffer, "  %4d %4d  %11.4e:%4d  %11.4e",
                        solver->last_num_limiting_bounds, solver->last_num_active_bounds,
                        solver->lambda_max, solver->last_bounding_index+1, solver->lambda);
                }
            }
            else {
                sprintf(buffer, "  %4d %4d  %11.4e       %11.4e",
                    solver->last_num_limiting_bounds, solver->last_num_active_bounds,
                    solver->lambda_max, solver->lambda);
            }

        }
        jmi_log_fmt_(log, node, logInfo, "<source:%s><block:%s><message:%s>",
            "jmi_kinsol_solver", block->label, message);
        jmi_log_leave(log, node);
    }
    return;
}

/* Logging callback used by KINSOL to report progress at higher log levels */
void kin_info(const char *module, const char *function, char *msg, void *eh_data){
    int i;
    jmi_block_solver_t *block = eh_data;
    jmi_kinsol_solver_t* solver = block->solver;
    struct KINMemRec* kin_mem = solver->kin_mem;
    realtype* residual_scaling_factors = N_VGetArrayPointer(block->f_scale);
    jmi_log_t *log = block->log;
    clock_t t = jmi_block_solver_start_clock(block);
    
    /* Only output an iteration under certain conditions:
         *  1. nle_solver_log > 2
         *  2. The calling function is either KINSolInit or KINSol
         *  3. The message string starts with "nni"
         *
         *  This approach gives one printout per iteration
         */

    if (block->callbacks->log_options.log_level >= 4)
    {
        jmi_log_node_t topnode = jmi_log_enter(log, logInfo, "KinsolInfo");
        jmi_log_fmt(log, topnode, logInfo, "<calling_function:%s>", function);
        jmi_log_fmt(log, topnode, logInfo, "<message:%s>", msg);
        
        if (strcmp("KINStop",function)==0) {
            solver->iterationProgressFlag = 1;
        } else if ((((strcmp("KINSolInit",function)==0) ||
              (strcmp("KINSol",function)==0)) && (strncmp("nni",msg,3)==0))) {
            realtype* f = N_VGetArrayPointer(kin_mem->kin_fval);
            long int nniters;

            int max_index = 0;
            realtype max_residual = 0;

            /* Get the number of iterations */
            KINGetNumNonlinSolvIters(kin_mem, &nniters);
    
            if (block->callbacks->log_options.log_level >= 5 && nniters > 0) {
                if(solver->iterationProgressFlag) {
                    jmi_log_reals(log, topnode, logInfo, "actual_step", N_VGetArrayPointer(kin_mem->kin_pp), block->n);
                } else {
                    jmi_log_node_t node= jmi_log_enter_vector_(log, topnode, logInfo, "actual_step");
                    for( i=0; i<block->n; i++) {
                        jmi_log_real_(log, 0.0);
                    }
                    jmi_log_leave(log, node);
                }
            }
            
            jmi_log_fmt(log, topnode, logInfo, "<iteration_index:%I>", (int)nniters);
            if(solver->iterationProgressFlag) 
                jmi_log_fmt(log, topnode, logInfo, "<scaled_step_norm:%E>", N_VWL2Norm(kin_mem->kin_pp, kin_mem->kin_uscale));       
            else
                jmi_log_fmt(log, topnode, logInfo, "<scaled_step_norm:%E>", 0.0);

            {
                /* Extract lambda_max and lambda for logging */
                realtype lambda_max = 0.0;
                realtype lambda = 0.0;

                if (nniters > 0 && solver->last_xnorm > 0 ) {
                    lambda_max = solver->max_step_ratio;
                    if(solver->iterationProgressFlag) {
                        if(solver->sJpnorm == 0) {
                            lambda = 1.0;
                        } else {
                            lambda = kin_mem->kin_sJpnorm / solver->sJpnorm;
                        }
                        if(solver->last_num_active_bounds > 0)
                            lambda *= solver->max_step_ratio;
                    } else {
                        lambda = 0;
                    }
                }
                else {
                    lambda_max = lambda = 0;
                }
                solver->lambda = lambda;
                solver->lambda_max = lambda_max;

                jmi_kinsol_print_progress(block, 0, 0);
                if (nniters > 0) {
                    jmi_log_fmt(log, topnode, logInfo, "<lambda_max:%E>", lambda_max);
                    jmi_log_fmt(log, topnode, logInfo, "<lambda:%E>", lambda);
                }

            }

            jmi_log_reals(log, topnode, logInfo, "ivs", N_VGetArrayPointer(kin_mem->kin_uu), block->n);
            if(solver->iterationProgressFlag || nniters == 0) {
                realtype fnorm;
                KINGetFuncNorm(solver->kin_mem, &fnorm);
                
                jmi_log_fmt(log, topnode, logInfo, "<scaled_residual_norm:%E>", fnorm);
                if (block->callbacks->log_options.log_level >= 5) {
                    jmi_log_node_t node;
                    node = jmi_log_enter_vector_(log, topnode, logInfo, "scaled_residuals");
                    for (i=0;i<block->n;i++) jmi_log_real_(log, f[i]*residual_scaling_factors[i]);
                    jmi_log_leave(log, node);
                }
                if (block->n >= 1) {
                    max_residual = f[0]*residual_scaling_factors[0];
                    for (i=1;i<block->n;i++) {
                        realtype res = f[i]*residual_scaling_factors[i];
                        if (JMI_ABS(res) > JMI_ABS(max_residual)) {
                            max_residual = res;
                            max_index = i;
                        }
                    }
                    jmi_log_fmt(log, topnode, logInfo, "<max_scaled_residual_value:%E>", max_residual);
                    jmi_log_fmt(log, topnode, logInfo, "<max_scaled_residual_index:%I>", max_index);
                }
                if (solver->last_fnorm < fnorm && nniters > 0) { /* This is not ment to happen */
                    jmi_log_node_t warning_node_top;
                    jmi_log_node_t warning_node;
                    realtype* last_f = N_VGetArrayPointer(solver->last_residual);
                    warning_node_top = jmi_log_enter_fmt(log, logWarning, "ResidualIncreaseAfterLineSearch", "The residual L2 norm has increased, from <norm_old: %E> to <norm_new: %E>",
                        solver->last_fnorm, fnorm);
                    warning_node = jmi_log_enter_index_vector_(log, warning_node_top, logWarning,"increased_residuals", 'R');
                    for (i=0; i<block->n; i++) { /* Go through the residuals and log which ones increased */
                        if (JMI_ABS(last_f[i]) < JMI_ABS(f[i])) {
                            jmi_log_int_(log, i);
                        }
                    }
                    jmi_log_leave(log, warning_node);
                    jmi_log_leave(log, warning_node_top);
                }
                solver->last_fnorm = fnorm;
                solver->last_max_residual= max_residual;
                solver->last_max_residual_index = max_index;
            } 

            solver->iterationProgressFlag = 0;
        }
        
        jmi_log_leave(log, topnode);
    }
    
    block->logging_time += jmi_block_solver_elapsed_time(block, t);
}

/* Print out meaningfull message based on KINSOL return flag */
void jmi_kinsol_error_handling(jmi_block_solver_t * block, int flag){
    if (flag != 0) {
        jmi_log_node(block->log, logError, "KinsolError", "KINSOL returned with <kinsol_flag: %s>", jmi_kinsol_flag_to_name(flag));
    }
}

/* initialize data on bounds */
static int jmi_kinsol_init_bounds(jmi_block_solver_t * block) {
    jmi_kinsol_solver_t* solver = (jmi_kinsol_solver_t*)block->solver;
        
    int i,num_bounds = 0;
    
    if(!block->options->enforce_bounds_flag) {
        solver->num_bounds = 0;
        return 0;
    }
    
    for(i=0; i < block->n; ++i) {
        if(block->max[i] != BIG_REAL) num_bounds++;
        if(block->min[i] != -BIG_REAL) num_bounds++;
    }
    
    solver->num_bounds = num_bounds;
    if(num_bounds) {
        solver->bound_vindex = (int*)calloc(num_bounds, sizeof(int));
        solver->bound_kind  = (int*)calloc(num_bounds, sizeof(int));
        solver->bound_limiting  = (int*)calloc(num_bounds, sizeof(int));
        solver->bounds = (realtype*)calloc(num_bounds, sizeof(realtype));
        solver->active_bounds = (realtype*)calloc(block->n, sizeof(realtype));
        num_bounds = 0;
    }

    for(i=0; i < block->n; ++i) {
        int hasMin = 0, hasMax = 0;
        double range = block->max[i] - block->min[i];

        if(block->max[i] != BIG_REAL) {
            /* upper bound on a variable */
            solver->bound_vindex[num_bounds] = i; /* variable index */
            solver->bound_kind[num_bounds] = 1;
            solver->bounds[num_bounds] = block->max[i];
            num_bounds++;
            hasMax = 1;
        }
        if(block->min[i] != -BIG_REAL) {
            /* lower bound on a variable */
            solver->bound_vindex[num_bounds] = i; /* variable index */
            solver->bound_kind[num_bounds] = -1;
            solver->bounds[num_bounds] = block->min[i];
            num_bounds++;
            hasMin = 1;
        }
        
        if(hasMin && hasMax && (range > 0) /* range limit only of interest when both max & min are present and are of the same sign */
            && (block->max[i] * block->min[i] > 0) ) {
            solver->range_limits[i] = range * block->options->step_limit_factor;
        }
        else {
            solver->range_limits[i] = BIG_REAL;
        }
        if(block->max[i] == block->min[i])
            jmi_log_node(block->log, logWarning, "MinAndMaxEqual", "Min and max equal for <Iter: #r%d#>.", block->value_references[i]);
    }

    return 0;
}

/* Helper to convert log_level used in the logger to print level in KINSOL */
static int get_print_level(jmi_block_solver_t* bs) {
    int log_level = bs->callbacks->log_options.log_level;
    if (log_level <= 3) return 0;
    else if (log_level <= 4) return log_level-2;
    else return 3;
}

static int jmi_kinsol_use_nominals_as_start(jmi_block_solver_t * block) {
    int i;
    
    if (!block->options->use_nominals_as_fallback_in_init ||
        !block->init)
    {
        return 0; /* Option set to false or not at init: return false */
    }
    
    for (i = 0; i < block->n; i++) {
        if (block->start_set[i] == 0) {
            return 1; /* At least one start value not specified: return true */
        }
    }
    
    return 0; /* All iteration variables have start values: return false */
}

static void jmi_kinsol_set_nominals_as_start(jmi_block_solver_t * block) {
    jmi_kinsol_solver_t* solver = block->solver;
    int i;

    for (i = 0; i < block->n; i++) {
        if (block->start_set[i] == 0) {
            if (block->nominal[i] <= block->max[i]) {
                N_VGetArrayPointer(solver->kin_y)[i] = block->nominal[i];
            } else {
                N_VGetArrayPointer(solver->kin_y)[i] = -block->nominal[i];
            }
        } else {
            N_VGetArrayPointer(solver->kin_y)[i] = block->initial[i];
        }
    }
}

/* Initialize solver structures */
static int jmi_kinsol_init(jmi_block_solver_t * block) {
    jmi_kinsol_solver_t* solver = block->solver;
    int ef, i;
    double max_nominal;
    struct KINMemRec * kin_mem = solver->kin_mem; 

    jmi_log_node_t node = jmi_log_enter_fmt(block->log, logInfo, "SolverOptions", "<block:%s>", block->label);
    jmi_log_fmt(block->log, node,logInfo, "Tolerance <tolerance: %g>",block->options->res_tol);
    jmi_log_fmt(block->log, node,logInfo, "Max number of iterations <max_iter: %d>",block->options->max_iter);
    jmi_log_fmt(block->log, node,logInfo, "Step limit <step_limit_factor: %g>",block->options->step_limit_factor);
    if(block->options->experimental_mode != 0)
        jmi_log_fmt(block->log, node,logInfo, "Experimental <experimental_mode: %d>",block->options->experimental_mode);
    jmi_log_fmt(block->log, node, logInfo, " <rescale_after_singular_jac: %d>", block->options->rescale_after_singular_jac_flag);
    jmi_log_fmt(block->log, node, logInfo, " <use_Brent_in_1d: %d>", block->options->use_Brent_in_1d_flag);
    jmi_log_fmt(block->log, node, logInfo, " <check_jac_cond: %d>", block->options->check_jac_cond_flag);
    jmi_log_fmt(block->log, node, logInfo, " <enforce_bounds: %d>", block->options->enforce_bounds_flag);
    jmi_log_fmt(block->log, node, logInfo, " <iteration_variable_scaling: %d>", block->options->iteration_variable_scaling_mode);
    jmi_log_fmt(block->log, node, logInfo, " <residual_equation_scaling: %d>", block->options->residual_equation_scaling_mode);
    jmi_log_fmt(block->log, node, logInfo, " <solver_exit_criterion: %d>", block->options->solver_exit_criterion_mode);
    jmi_log_fmt(block->log, node, logInfo, " <regularization_tolerance: %g>", block->options->regularization_tolerance);
    jmi_log_fmt(block->log, node, logInfo, " <min_residual_scaling_factor: %g>", block->options->min_residual_scaling_factor);
    jmi_log_fmt(block->log, node, logInfo, " <max_residual_scaling_factor: %g>", block->options->max_residual_scaling_factor);
    jmi_log_fmt(block->log, node, logInfo, " <jacobian_finite_difference_delta: %g>", block->options->jacobian_finite_difference_delta);
    jmi_log_fmt(block->log, node, logInfo, " <use_jacobian_equilibration: %d>", block->options->use_jacobian_equilibration_flag);
    jmi_log_fmt(block->log, node, logInfo, " <Brent_ignore_error: %d>", block->options->brent_ignore_error_flag);
    jmi_log_fmt(block->log, node, logInfo, " <jacobian_update_mode: %d>", block->options->jacobian_update_mode);
    jmi_log_fmt(block->log, node, logInfo, " <jacobian_calculation_mode: %d>", block->options->jacobian_calculation_mode);
    jmi_log_fmt(block->log, node, logInfo, " <log_level: %d>", block->callbacks->log_options.log_level);
    jmi_log_fmt(block->log, node, logInfo, " <jacobian_check: %d>", block->options->block_jacobian_check);
    jmi_log_fmt(block->log, node, logInfo, " <jacobian_check_tolerance: %g>", block->options->block_jacobian_check_tol);
    jmi_log_fmt(block->log, node, logInfo, " <step_limit_factor: %g>", block->options->step_limit_factor);
    jmi_log_fmt(block->log, node, logInfo, " <max_iter_no_jacobian: %d>", block->options->max_iter_no_jacobian);
    jmi_log_fmt(block->log, node, logInfo, " <active_bounds_mode: %d>", block->options->active_bounds_mode);
    jmi_log_fmt(block->log, node, logInfo, " <start_from_last_integrator_step: %d>", block->options->start_from_last_integrator_step);
    jmi_log_leave(block->log, node);

    KINSetPrintLevel(solver->kin_mem, get_print_level(block));

    /* Test to enable residual monitoring based Jac update */
    if(block->options->jacobian_update_mode == jmi_reuse_jacobian_update_mode
        || block->options->jacobian_update_mode == jmi_broyden_jacobian_update_mode
        || (block->options->experimental_mode &jmi_block_solver_experimental_use_modifiedBFGS)
        || (block->options->experimental_mode & jmi_block_solver_experimental_Sparse_Broyden))
        KINSetNoResMon(solver->kin_mem,0);
    else
        KINSetNoResMon(solver->kin_mem,1);
    KINSetMaxSetupCalls(solver->kin_mem,block->options->max_iter_no_jacobian);

    /* residual monitoring does not need to be done in every step but max_iter_no_jacobian must be proportional to the number */
    if( (int)((double)block->options->max_iter_no_jacobian / 5.0) * 5 != block->options->max_iter_no_jacobian) {
        if((int)((double)block->options->max_iter_no_jacobian / 3.0) * 3 == block->options->max_iter_no_jacobian) {
            KINSetMaxSubSetupCalls(solver->kin_mem, 3);
        } else if ( (block->options->max_iter_no_jacobian  & 1) == 0) {
            KINSetMaxSubSetupCalls(solver->kin_mem, 2);
        } else {
            KINSetMaxSubSetupCalls(solver->kin_mem, 1);
        }
    }

    /* set tolerances */
    if((block->n > 1) || !block->options->use_Brent_in_1d_flag) {
        solver->kin_stol = block->options->res_tol;
        if(solver->kin_stol < block->options->min_tol) {
            solver->kin_stol = block->options->min_tol;
        }
    }
    else
        solver->kin_stol = block->options->min_tol;
    
    solver->kin_ftol = UROUND; /* block->options->res_tol; */
    
    /* If not set, set the default */
    if (block->options->regularization_tolerance == -1){
        solver->kin_reg_tol = 1.0/block->options->res_tol;
    } else {
        solver->kin_reg_tol = block->options->regularization_tolerance;
    }

    KINSetScaledStepTol(solver->kin_mem, solver->kin_stol);
    KINSetFuncNormTol(solver->kin_mem, solver->kin_ftol);
    KINSetNumMaxIters(solver->kin_mem, block->options->max_iter);
    
    /* Allow long steps */
    max_nominal = 1;
    for(i=0;i< block->n;++i){
        double nom = JMI_ABS(block->nominal[i]);
        if (nom > max_nominal) {
            max_nominal = JMI_ABS(block->nominal[i]);
        }
    }
    solver->max_nw_step = block->options->step_limit_factor*max_nominal;
    KINSetMaxNewtonStep(solver->kin_mem, solver->max_nw_step);
    
    /* Set variable scaling based on nominal values. */
    if(block->options->iteration_variable_scaling_mode) {
        int i;
        for(i=0;i< block->n;++i){
            double nominal = JMI_ABS(block->nominal[i]);
            if(nominal != 1.0) {
                if(nominal == 0.0)
                    nominal = 1/solver->kin_stol;
                else
                    nominal = 1/nominal;
                Ith(solver->kin_y_scale,i)=nominal;
            }
        }
    }

    solver->last_xnorm = 1.0;
    jmi_kinsol_init_bounds(block);
    
    /* evaluate the function at initial */
    ef =  kin_f(solver->kin_y, kin_mem->kin_fval, block);
    if(ef) {
        if (jmi_kinsol_use_nominals_as_start(block)) {
            jmi_kinsol_set_nominals_as_start(block);
            jmi_log_node(block->log, logWarning, "NominalsAsInitialGuess",
                "Failed to evaluate the residual using the default initial "
                "guess. Attempting using the nominal values in <block:%s>",
                block->label);
            ef = kin_f(solver->kin_y, kin_mem->kin_fval, block);
        }
        if (ef) {
            jmi_log_node(block->log, logError, "InitialEvaluation",
                "Residual function evaluation failed at initial point for "
                "<block: %s>", block->label);
        }
    }
    kin_mem->kin_uscale = solver->kin_y_scale;

    if(!solver->has_compression_setup_flag && block->Jacobian && block->options->jacobian_calculation_mode == jmi_compression_jacobian_calculation_mode) {
        int ret, N=block->n;
        ret = block->Jacobian(block->problem_data, 0, solver->J_Dependency->cols, JMI_BLOCK_GET_DEPENDENCY_MATRIX);
        if(ret==0) {
            ret = jmi_kin_setup_column_partition(block);
            if(ret == 0) {
                if((block->callbacks->log_options.log_level >= 4)) {
                    jmi_log_node_t node = jmi_log_enter_fmt(block->log, logInfo, "DependencyMatrix", "<block:%s>", block->label);
                    if (block->callbacks->log_options.log_level >= 6) {
                        jmi_log_real_matrix(block->log, node, logInfo, "dependency_matrix", solver->J_Dependency->data, N, N);
                        jmi_log_ints(block->log, node, logInfo, "column_partitioning_groups", solver->jac_compression_groups, N);
                        jmi_log_ints(block->log, node, logInfo, "column_partitioning_group_index", solver->jac_compression_group_index, N);
                    }
                    jmi_log_leave(block->log, node);
                }
                solver->has_compression_setup_flag = TRUE;
            }
        } 
    }

    /* evaluate Jacobian at initial */
    if(jmi_kin_lsetup(kin_mem)) {
        ef = 1;
        jmi_log_node(block->log, logError, "InitialEvaluation", "Jacobian evaluation failed at initial point for "
                     "<block: %s>", block->label);
    }
    return ef;
}

/* Limit the maximum step to be within bounds. Do projection if needed. */
static void jmi_kinsol_limit_step(struct KINMemRec * kin_mem, N_Vector x, N_Vector b, realtype *sJpnorm, realtype *sFdotJp) {
    jmi_block_solver_t *block = (jmi_block_solver_t *)kin_mem->kin_user_data;
    jmi_kinsol_solver_t* solver = (jmi_kinsol_solver_t*)block->solver;  
    realtype xnorm;        /* step norm */
    realtype min_step_ratio; /* fraction of the Newton step that is still over minimal step*/
    realtype max_step_ratio; /* maximum step length ratio limited by bounds */

    realtype* xxd = N_VGetArrayPointer(x); /* Newton step on input, may be modified if step is projected */
    realtype* xd = N_VGetArrayPointer(b); /* used as a buffer */
    booleantype activeBounds = FALSE;
    booleantype limitingBounds = FALSE;
    booleantype rangeLimited = FALSE;
    int i;
    jmi_log_t *log = block->log;
    jmi_log_node_t outer={0};
    jmi_log_node_t inner={0};
    clock_t t = jmi_block_solver_start_clock(block);

    /* MAX_NEWTON_STEP_RATIO is used just to ensure that full Newton step can 
    be taken when no bounds are present. 
    TODO: Consider addionally limiting the Newton step length set
    based on the nominal values of the IVs.
    Consider using block->options->step_limit_factor instead
    */
#define MAX_NEWTON_STEP_RATIO 1.0

    xnorm = N_VWL2Norm(x, kin_mem->kin_uscale); /* scaled L2 norm of the Newton step */
    solver->last_xnorm = xnorm;
    solver->last_bounding_index = -1;
    solver->last_num_limiting_bounds = 0;
    solver->last_num_active_bounds = 0;
    solver->range_most_limiting = FALSE;

    if((!block->options->enforce_bounds_flag) || (xnorm == 0.0)) 
    {
        /* make sure full newton step can be taken */
        realtype maxstep = 2.0 * xnorm;
#if 0
        if(maxstep > kin_mem->kin_mxnewtstep)
#endif
            kin_mem->kin_mxnewtstep = maxstep;
        block->bounds_handling_time += jmi_block_solver_elapsed_time(block, t);
        return;
    }

    /*  Scale the step up so that step multiplier is 1.0 at the beginning.
        The "long" step is now saved into "b", pointed by "xd"
    */
    N_VScale(MAX_NEWTON_STEP_RATIO, x, b);
    
    /* minimal/maximal allowed step multiplier */
    max_step_ratio = 1.0;
    if(block->options->experimental_mode & jmi_block_solver_experimental_active_bounds_threshold)
        min_step_ratio = block->options->active_bounds_threshold;
    else
        min_step_ratio = 2*solver->kin_stol;

    /* 
        Go over the list of bounds and reduce "max_step_ratio"; project if needed
    */
    for(i = 0; i < solver->num_bounds; ++i) {
        int index = solver->bound_vindex[i]; /* variable index */
        int kind = solver->bound_kind[i];   /* min or max */
        realtype ui =  NV_Ith_S(kin_mem->kin_uu,index);  /* current variable value */
        realtype pi = xd[index];            /* solved step length for the variable*/
        realtype bound = solver->bounds[i]; 
        realtype pbi = (bound - ui)*(1 - UNIT_ROUNDOFF);  /* distance to the bound */
        realtype nom_step_ratio_i;
        realtype nom_i;
        realtype step_ratio_i;
        double eps = solver->kin_stol;
        int nom_criteria = FALSE;        

        if(    ((kind == 1)&& (pbi >= pi))
            || ((kind == -1)&& (pbi <= pi))) {
            solver->bound_limiting[i] = 0 ;
            continue; /* will not cross the bound */
        }

        solver->bound_limiting[i] = 1 ;
        limitingBounds = TRUE ;
        solver->last_num_limiting_bounds++;
        step_ratio_i =pbi/pi;   /* step ratio to bound */
        nom_i = JMI_ABS(block->nominal[index]);

        nom_step_ratio_i = (eps*kind*nom_i+ui-bound)/-pi; /* The fraction delta of the step so that (bound-(ui+pi*delta))*kind=stol*nom */
        if(nom_step_ratio_i < min_step_ratio) {
            nom_criteria = TRUE;
        }
        if( (kind == 1 && ui > bound-eps*nom_i && ui <= bound) ||
            (kind== -1 && ui < bound+eps*nom_i && ui >= bound)) {
                nom_criteria = TRUE;
        }
        if( (kind == 1 && ui+pi < bound+eps*nom_i) || (kind==-1 && ui+pi > bound-eps*nom_i) ) {
            nom_criteria = TRUE;
        }
        if(step_ratio_i < min_step_ratio || nom_criteria) {
            /* this bound is active (we need to follow it) */
            activeBounds = TRUE;
            solver->bound_limiting[i] = 2;
            solver->last_num_active_bounds++;
            xxd[index] = 0;
            /* distance to the bound */
            solver->active_bounds[index] = pbi; /*  (kind == 1)? pbi:-pbi ; */
        }
        else {
            if (max_step_ratio > step_ratio_i) {
                /* reduce the step */
                max_step_ratio = step_ratio_i;
                solver->last_bounding_index = index;
                solver->range_most_limiting = FALSE;
            }
        }
    }
    if (block->callbacks->log_options.log_level >= 5) {
        jmi_log_node(log, logInfo, "BoundsMaxStepRatio", "Step ratio after bounds check <lambda_max_bounds: %g>", max_step_ratio);
    }

    /*
        Go over the iteration vars and reduce max_step_ratio
        based on step_limit_factor & range_limits
    */
    if(block->options->step_limit_factor <= 1 ) {
        if (block->callbacks->log_options.log_level >= 5) {
            /* Print variables with long steps */
            outer = jmi_log_enter_(log, logInfo, "StepLimits");
            inner = jmi_log_enter_vector_(log, outer, logInfo, "range");
        }
        for( i=0; i<block->n; i++ ) {
            double range_limit = solver->range_limits[i];
            double step_limit = range_limit;
            realtype pi = JMI_ABS(xxd[i]);            /* abs solved step length for the variable*/
            double nom = JMI_ABS(block->nominal[i]);
            double nom_limit;
            double ui =  JMI_ABS(NV_Ith_S(kin_mem->kin_uu,i));  /* current variable value */
            double step_ratio;
            int activeBound = 0;
            realtype bnd;
            
            if(solver->num_bounds > 0)
                bnd = solver->active_bounds[i];
            else
                bnd = 0.0;

            if(pi == 0.0) {
                /* either projected or zero step */                
                if(bnd != 0.0) { 
                    /* enforce range check to avoid jumping over the full range */
                    pi = JMI_ABS(bnd);                    
                    activeBound = 1;
                }
                else {
                    /* zero step - no range violation possible*/
                    solver->range_limited[i] = 0;
                    if (block->callbacks->log_options.log_level >= 5) {
                        jmi_log_real_(log, BIG_REAL);
                    }
                    continue;
                }
            }

            if(nom < ui) {  /* if nominal is below current - take current*/
                nom = ui; 
            }
            /* step length limit based on max(nominal, |current|)*/
            nom_limit = nom *  block->options->step_limit_factor;
            if(range_limit > nom_limit) { /* if nominal based is tighter than range based update step factor */
                step_limit = nom_limit;
            }

            if (block->callbacks->log_options.log_level >= 5) {
                jmi_log_real_(log, step_limit);
            }

            if( pi < step_limit) {
                solver->range_limited[i] = 0;
                continue;
            }

            solver->range_limited[i] = 1;
            rangeLimited = TRUE;
            
            if(activeBound) {
                if(bnd > 0)
                    solver->active_bounds[i] = step_limit;
                else
                    solver->active_bounds[i] = -step_limit;
            } else {
                step_ratio = step_limit/JMI_ABS(pi);

                if(max_step_ratio > step_ratio) {
                    max_step_ratio = step_ratio;
                    solver->last_bounding_index = i;
                    solver->range_most_limiting = TRUE;
                }
            }
        }
        if (block->callbacks->log_options.log_level >= 5) {
            jmi_log_leave(log, inner);
            jmi_log_leave(log, outer);
            jmi_log_node(block->log, logInfo, "RangeMaxStepRatio", "Step ratio after range check <lambda_max_range: %g>", max_step_ratio);
        }
    }

    /* log the IV ranges that limit the step */
    if (block->callbacks->log_options.log_level >= 5 && rangeLimited) {
        /* Print variables with long steps */
        jmi_log_node_t outer = jmi_log_enter_(log, logInfo, "RangeLimited");
        jmi_log_node_t inner = jmi_log_enter_vector_(log, outer, logInfo, "range");            
        for (i=0; i < block->n; i++) {
            if (solver->range_limited[i]) {
                jmi_log_vref_(log, 'r', block->value_references[i]);
            }
        }
        jmi_log_leave(log, inner);
        jmi_log_leave(log, outer);
    }

    /* log the bounds that limit the step */
    if (block->callbacks->log_options.log_level >= 5 && limitingBounds) {
        /* Print limiting bounds */
        jmi_log_node_t outer = jmi_log_enter_(log, logInfo, "LimitationBounds");
        int kind;
        for (kind=1; kind >= -1; kind -= 2) {
            jmi_log_node_t inner = jmi_log_enter_vector_(log, outer, logInfo, 
                                                         kind==1 ? "max" : "min");            
            for (i=0; i < solver->num_bounds; i++) {
                int index = solver->bound_vindex[i]; /* variable index */
                if (solver->bound_limiting[i] != 0
                    && solver->bound_kind[i] == kind) {
                    jmi_log_vref_(log, 'r', block->value_references[index]);
                }
            }
            jmi_log_leave(log, inner);
        }
        jmi_log_leave(log, outer);
    }
    /* log the active bounds that we are following */
    if (block->callbacks->log_options.log_level >= 5 && activeBounds) {        
        /* Print active bounds*/
        jmi_log_node_t outer = jmi_log_enter_(log, logInfo, "ActiveBounds");
        int kind;
        for (kind=1; kind >= -1; kind -= 2) {
            jmi_log_node_t inner = jmi_log_enter_vector_(log, outer, logInfo, 
                                                         kind==1 ? "max" : "min");            
            for (i=0; i < solver->num_bounds; i++) {
                int index = solver->bound_vindex[i]; /* variable index */
                
                if ((solver->bound_limiting[i] == 2) 
                    && solver->bound_kind[i] == kind) {
                    jmi_log_vref_(log, 'r', block->value_references[index]);
                }
            }
            jmi_log_leave(log, inner);
        }
        jmi_log_leave(log, outer);
    }

    if( MAX_NEWTON_STEP_RATIO != 1.0) {
        /* 
            Since analysis was done with x = MAX_NEWTON_STEP_RATIO * Newton step
            the actual Newton step ration is also MAX_NEWTON_STEP_RATIO larger
        */
        max_step_ratio *= MAX_NEWTON_STEP_RATIO;
    }
    
    /* The way step limiting is implemented it should be allowed to take the full step length more than 5 times
    which is a fixed check in KINSOL */
    kin_mem->kin_ncscmx = 0; /* zero out counter of steps with kin_mxnewtstep length */

    solver->max_step_ratio = max_step_ratio;
    if(!activeBounds) {
        /* bounds do not affect the base-line algorithm, only limit the step */
        kin_mem->kin_mxnewtstep = max_step_ratio * xnorm ;
        block->bounds_handling_time += jmi_block_solver_elapsed_time(block, t);
        return;
    }

    /* Update the x to be the maximum vector within bounds */ 
    for(i = 0; i < block->n; ++i) {
        realtype bnd = solver->active_bounds[i];
        if(bnd != 0.0) { /* the maximum step should keep us on this active bound */
            xd[i] = bnd;
            solver->active_bounds[i] = 0;
        }
        else if(max_step_ratio < 1.0) { /* update the step length for other vars */
            xd[i] = xxd[i] * max_step_ratio;
        }
        else xd[i] = xxd[i];
    }
    if(max_step_ratio < 1.0) {
        /* reduce the norms of Jp. This is only approximate since active bounds are not accounted for.*/
        *sFdotJp *= max_step_ratio;
        *sJpnorm *= max_step_ratio;
        solver->sJpnorm = *sJpnorm;
    }
    /* The maximum newton step leads to the bound  
    -> store the "x" and set maximum step to be L2 norm of x */
    N_VScale(1.0, b, x);

    xnorm = N_VWL2Norm(x, kin_mem->kin_uscale); /* scaled L2 norm of the Newton step */
    solver->last_xnorm = xnorm*(1 - UNIT_ROUNDOFF);

    kin_mem->kin_mxnewtstep =  solver->last_xnorm;
    block->bounds_handling_time += jmi_block_solver_elapsed_time(block, t);
}

/* Form regularized matrix Transpose(J).J */
static void jmi_kinsol_reg_matrix(jmi_block_solver_t * block) {
    jmi_kinsol_solver_t* solver = block->solver;
    int i,j,k;
    int N = block->n;
    realtype * uscale_data = N_VGetArrayPointer(solver->kin_y_scale);
    realtype * fscale_data = N_VGetArrayPointer(block->f_scale);    

    for (i=0;i<N;i++) {
        /* Add the regularization parameter on the diagonal.   */        
        DENSE_ELEM(solver->JTJ,i,i) = uscale_data[i]*uscale_data[i];
        /*Calculate value at RTR(i,i) */
        for (k=0;k<N;k++) DENSE_ELEM(solver->JTJ,i,i) += DENSE_ELEM(block->J,k,i)*DENSE_ELEM(block->J,k,i)*fscale_data[k]*fscale_data[k];
        for (j=i+1;j<N;j++){
            
            /*Calculate value at RTR(i,j) */
            DENSE_ELEM(solver->JTJ,i,j) = 0;
            for (k=0;k<N;k++) DENSE_ELEM(solver->JTJ,i,j) += DENSE_ELEM(block->J,k,j)*DENSE_ELEM(block->J,k,i)*fscale_data[k]*fscale_data[k];
            DENSE_ELEM(solver->JTJ,j,i) = DENSE_ELEM(solver->JTJ,i,j);
        }
    }

    if((block->callbacks->log_options.log_level >= 4)) {
        jmi_log_node_t node = jmi_log_enter_fmt(block->log, logInfo, "RegularizedJacobian", "<block:%s>", block->label);
        if (block->callbacks->log_options.log_level >= 6) {
            jmi_log_real_matrix(block->log, node, logInfo, "regularized_jacobian", solver->JTJ->data, N, N);
        }
        jmi_log_leave(block->log, node);
    }
}

/* Perform LU factorization with different linear algebra packages */
static int jmi_LU_factorization(jmi_block_solver_t * block, DlsMat matrix) {
    jmi_kinsol_solver_t* solver = block->solver;
    int info = 0, N = block->n;
    int lin_alg_package = block->options->experimental_mode & jmi_block_solver_experimental_LU_through_sundials ? 1:0;
    
    if(lin_alg_package == 0) {
        dgetrf_(  &N, &N, matrix->data, &N, solver->lapack_ipiv, &info);
    } else if (lin_alg_package == 1) {
        /* Perform factorization to detect if there is a singular Jacobian */
        info = DenseGETRF(matrix, solver->sundials_permutationwork);
    }
    return info;
}

/* Solve with an LU factorized matrix with different linear algebra packages */
static int jmi_LU_solve(jmi_block_solver_t * block, DlsMat matrix, realtype* xd) {
    jmi_kinsol_solver_t* solver = block->solver;
    int ret = 0, N = block->n;
    int lin_alg_package = block->options->experimental_mode & jmi_block_solver_experimental_LU_through_sundials ? 1:0;
    
    if(lin_alg_package == 1) {
        DenseGETRS(matrix, solver->sundials_permutationwork, xd);
    } else if (lin_alg_package == 0){
        /* Back-solve and get solution in x */
        char trans = 'N'; /* No transposition */
        int i = 1;
        dgetrs_(&trans, &N, &i, matrix->data, &N, solver->lapack_ipiv, xd, &N, &ret);
    }
    return ret;
}

/* Call this function directly after jmi_update_f_scale */
static void jmi_regularize_and_do_condition_estimate_on_scaled_jacobian(jmi_block_solver_t *block) {

    jmi_kinsol_solver_t* solver = block->solver;
    int i, N = block->n;
    jmi_block_solver_options_t* bsop = block->options;
    int use_scaling_flag = bsop->residual_equation_scaling_mode;
    realtype* scale_ptr = N_VGetArrayPointer(block->f_scale);

    if (block->using_max_min_scaling_flag && !solver->J_is_singular_flag) {
        realtype cond = jmi_calculate_jacobian_condition_number(block);

        jmi_log_node(block->log, logInfo, "Regularization",
            "Calculated condition number in <block: %s>. Regularizing if <cond: %E> is greater than <regtol: %E>", block->label, cond, solver->kin_reg_tol);
        if (cond > solver->kin_reg_tol) {
            if(N > 1 && solver->handling_of_singular_jacobian_flag == JMI_REGULARIZATION) {
                jmi_kinsol_reg_matrix(block);
                jmi_LU_factorization(block, solver->JTJ);
            }
            solver->J_is_singular_flag = 1;
        }
    }


    /* estimate condition number of the scaled jacobian 
    and scale function tolerance with it. */
    if((N > 1) && bsop->check_jac_cond_flag){
        realtype* scaled_col_ptr;

        if(use_scaling_flag) {
            for(i = 0; i < N; i++){
                int j;
                scaled_col_ptr = DENSE_COL(block->J_scale, i);
                for(j = 0; j < N; j++){
                    scaled_col_ptr[j] = scaled_col_ptr[j] * scale_ptr[j];
                }
            }
        } else {
            DenseCopy(block->J, block->J_scale);
        }

        jmi_kinsol_log_jacobian_cond_nbr(block);
    }
}

/* Estimate condition number utilizing dgecon from LAPACK*/
static realtype jmi_calculate_jacobian_condition_number(jmi_block_solver_t * block) {
    jmi_kinsol_solver_t* solver = block->solver;
    char norm = 'I';
    int N = block->n;
    double J_norm = 1.0;
    double J_recip_cond = 1.0;
    int info;
    
    /* Compute infinity norm of J to be used with dgecon */
    J_norm = dlange_(&norm, &N, &N, block->J->data, &N, solver->lapack_work);
    
    /* Copy Jacobian to factorization matrix */
    DenseCopy(block->J, solver->J_LU);
    /* Perform LU factorization to be used with dgecon */
    info = jmi_LU_factorization(block, solver->J_LU); 
    if (info != 0 ) {
        /* If matrix i singular, return something very large to be evaluated*/
        return 1e100;
    }
    /* Compute reciprocal condition number */
    dgecon_(&norm, &N, solver->J_LU->data, &N, &J_norm, &J_recip_cond, solver->lapack_work, solver->lapack_iwork,&info);

    return 1.0/J_recip_cond;
}

/* Perform factorization of the Jacobian approximation stored in solver->J */
static int jmi_kin_factorize_jacobian(jmi_block_solver_t *block);
/* Callback from KINSOL called to calculate Jacobian */
static int jmi_kin_lsetup(struct KINMemRec * kin_mem) {
    jmi_block_solver_t *block = kin_mem->kin_user_data;
    jmi_kinsol_solver_t* solver = block->solver;
    
    int N = block->n;
    long int nniters;
    int ret;
    KINGetNumNonlinSolvIters(kin_mem, &nniters);
   
    if(solver->current_nni == nniters && nniters > 0) { /* We are on retry iterations */
        kin_char_log(solver, 'x');
    }

    if(solver->updated_jacobian_flag) {
        return 0;
    }
    SetToZero(block->J);

    /* Evaluate Jacobian */
    ret = kin_dF(N, solver->kin_y, kin_mem->kin_fval, block->J, block, kin_mem->kin_vtemp1, kin_mem->kin_vtemp2);
    solver->updated_jacobian_flag = 1; /* The Jacobian is current */
    
    if(ret != 0 && solver->has_compression_setup_flag && block->options->jacobian_calculation_mode == jmi_compression_jacobian_calculation_mode) {
        solver->has_compression_setup_flag = FALSE;
        jmi_log_node(block->log, logWarning, "CompressedJacobianEvaluation", "Failed to evaluate Jacobian using compression. Will try full finite differences.");
        /* Try if it helps with full finite differences with possibility to step in other direction */
        ret = kin_dF(N, solver->kin_y, kin_mem->kin_fval, block->J, block, kin_mem->kin_vtemp1, kin_mem->kin_vtemp2);
        solver->has_compression_setup_flag = TRUE;
    }

    if(ret != 0 ) return ret; /* There was an error in calculation of Jacobian */
    
    if(solver->use_steepest_descent_flag) return ret; /* No further processing when using steepest descent */
    
    ret = jmi_kin_factorize_jacobian(block);

    if(ret != 0 ) return ret;

    if(solver->force_new_J_flag ) {
        /* If the Jacobian was calculated due to the singularity in the previous point
        update the residual scales if corresponding option is set
       */
        solver->force_new_J_flag = 0;
    }

    if(block->force_rescaling) {
        if(block->options->residual_equation_scaling_mode != jmi_residual_scaling_none)
            kin_char_log(solver, 's');
        jmi_update_f_scale(block);
        jmi_regularize_and_do_condition_estimate_on_scaled_jacobian(block);
    }
    
    return 0;
        
}

/* Perform Broyden update and factorize the resulted matrix */
static int jmi_kin_make_Broyden_update(jmi_block_solver_t *block, N_Vector b) {
    clock_t t = jmi_block_solver_start_clock(block);
    jmi_kinsol_solver_t* solver = (jmi_kinsol_solver_t*)block->solver;
    struct KINMemRec* kin_mem = solver->kin_mem;
    int ret, i, j;
    int N = block->n;
    double denom;

    /* Broyden update: Jac = Jac + (ResidualDelta  - Jac * step)*(step_scale^2 step)^T / norm_2(step_scale * step)^2;
    See algorithm A8.3.1 in "Numerical methods for Unconstrained Opt and NLE" */
    denom = jmi_kinsol_calc_v1twwv2(kin_mem->kin_pp,kin_mem->kin_pp,solver->kin_y_scale);
    /* work_vector = Jac * step */
    jmi_linear_algebra_dgemv(1.0, block->J->data, N_VGetArrayPointer(kin_mem->kin_pp), 0, N_VGetArrayPointer(solver->work_vector), N, FALSE);
    /* work_vector = (ResidualDelta  - Jac * step) unless below update tolerance */
    for(i = 0; i < N; i++) {
        double tempi = -(Ith(b,i) - Ith(solver->last_residual,i)) - Ith(solver->work_vector,i);
        if(JMI_ABS(tempi) >= UNIT_ROUNDOFF*(JMI_ABS(Ith(b,i))+JMI_ABS(Ith(solver->last_residual,i)))) {
            Ith(solver->work_vector,i) = tempi/denom;
        } else {
            Ith(solver->work_vector,i) = 0;
        }
    }

    for(j=0; j < N; j++) {
        realtype *jacCol_j = DENSE_COL(block->J,j); 
        double tempj = Ith(kin_mem->kin_pp, j)*Ith(solver->kin_y_scale,j)*Ith(solver->kin_y_scale,j);
        for(i = 0; i < N; i++) {
            if( Ith(solver->work_vector,i) != 0.0) {
                if(block->options->experimental_mode & jmi_block_solver_experimental_Broyden_with_zeros && jacCol_j[i] == 0) {
                } else {
                    jacCol_j[i] += Ith(solver->work_vector,i) * tempj;
                }
            }
        }
    }

    if((block->callbacks->log_options.log_level >= 4)) {
        jmi_log_node_t node = jmi_log_enter_fmt(block->log, logInfo, "BroydenJacobianUpdate", "<block:%s>", block->label);
        if (block->callbacks->log_options.log_level >= 6) {
            jmi_log_real_matrix(block->log, node, logInfo, "jacobian", block->J->data, N, N);
        }
        jmi_log_leave(block->log, node);
    }
    block->broyden_update_time += jmi_block_solver_elapsed_time(block, t);
    ret = jmi_kin_factorize_jacobian(block );
    return ret;
}

/* Perform sparse (Bogle & Perkins, "A new sparsity preserving Quasi-Newtion update for solving nonlinear equations", 1990) 
    Broyden update and factorize the resulted matrix */
static int jmi_kin_make_sparse_Broyden_update(jmi_block_solver_t *block, N_Vector b) {
    clock_t t = jmi_block_solver_start_clock(block);
    jmi_kinsol_solver_t* solver = (jmi_kinsol_solver_t*)block->solver;
    struct KINMemRec* kin_mem = solver->kin_mem;
    int ret, i, j;
    int N = block->n;

    /* work_vector = Jac * step */
    jmi_linear_algebra_dgemv(1.0, block->J->data, N_VGetArrayPointer(kin_mem->kin_pp), 0, N_VGetArrayPointer(solver->work_vector), N, FALSE);
    /* work_vector = (ResidualDelta  - Jac * step) unless below update tolerance */
    for(i = 0; i < N; i++) {
        double tempi = -(Ith(b,i) - Ith(solver->last_residual,i)) - Ith(solver->work_vector,i);
        if(JMI_ABS(tempi) >= UNIT_ROUNDOFF*(JMI_ABS(Ith(b,i))+JMI_ABS(Ith(solver->last_residual,i)))) {
            Ith(solver->work_vector,i) = tempi;
        } else {
            Ith(solver->work_vector,i) = 0;
        }
    }

    /* work_vector2(i) = sum(k=1:n) step(k)*Jac(i,k) */
    for(i = 0; i < N; i++) {  
        double denom = 0;
        for(j=0; j < N; j++) {
            denom += Ith(kin_mem->kin_pp, j)*Ith(kin_mem->kin_pp, j)*DENSE_ELEM(block->J,i,j)*DENSE_ELEM(block->J,i,j);
        }
        Ith(solver->work_vector2,i) = denom;
    }

    for(j=0; j < N; j++) {
        realtype *jacCol_j = DENSE_COL(block->J,j); 
        for(i = 0; i < N; i++) {
            if( Ith(solver->work_vector2,i) >= UNIT_ROUNDOFF) {
                jacCol_j[i] += Ith(solver->work_vector,i) * Ith(kin_mem->kin_pp, i)*jacCol_j[i]*jacCol_j[i]/Ith(solver->work_vector2,i);
            }
        }
    }

    if((block->callbacks->log_options.log_level >= 4)) {
        jmi_log_node_t node = jmi_log_enter_fmt(block->log, logInfo, "SparseBroydenJacobianUpdate", "<block:%s>", block->label);
        if (block->callbacks->log_options.log_level >= 6) {
            jmi_log_real_matrix(block->log, node, logInfo, "jacobian", block->J->data, N, N);
        }
        jmi_log_leave(block->log, node);
    }
    block->broyden_update_time += jmi_block_solver_elapsed_time(block, t);
    ret = jmi_kin_factorize_jacobian(block );
    return ret;
}

/* Perform modified BFGS update and factorize the resulted matrix */
static int jmi_kin_make_modifiedBFGS_update(jmi_block_solver_t *block, N_Vector b) {
    clock_t t = jmi_block_solver_start_clock(block);
    jmi_kinsol_solver_t* solver = (jmi_kinsol_solver_t*)block->solver;
    struct KINMemRec* kin_mem = solver->kin_mem;
    int ret, i, j;
    int N = block->n;
    double denom1, denom2;

    /* work_vector2 = res_diff */
    N_VLinearSum(1, solver->last_residual, -1, b, solver->work_vector);
    N_VProd(solver->work_vector, block->f_scale, solver->work_vector);
    N_VProd(solver->work_vector, block->f_scale, solver->work_vector);
    /* work_vector2 = res_diff^T*f_scale^2*Jac */
    jmi_linear_algebra_dgemv(1.0, block->J->data, N_VGetArrayPointer(solver->work_vector), 0, N_VGetArrayPointer(solver->work_vector2), N, TRUE);
    /* denom1 = step^T.*kin_y_scale^2*step */
    denom1 = jmi_kinsol_calc_v1twwv2(kin_mem->kin_pp,kin_mem->kin_pp,solver->kin_y_scale);
    /* work_vector = Jac * step */
    jmi_linear_algebra_dgemv(1.0, block->J->data, N_VGetArrayPointer(kin_mem->kin_pp), 0, N_VGetArrayPointer(solver->work_vector), N, FALSE);
    /* denom2 = res_diff^T.*kin_f_scale^2*Jac*step */
    denom2 = 0;
    for(i = 0; i < N; i++) {
        denom2 += -(Ith(b,i) - Ith(solver->last_residual,i))*Ith(block->f_scale,i)*Ith(block->f_scale,i)*Ith(solver->work_vector,i);
    }
    
    for(j=0; j < N; j++) {
        realtype *jacCol_j = DENSE_COL(block->J,j); 
        double tempj1 = Ith(kin_mem->kin_pp,j)*Ith(solver->kin_y_scale,j)*Ith(solver->kin_y_scale,j)/denom1;
        double tempj2 = Ith(solver->work_vector2,j)/denom2;
        for(i = 0; i < N; i++) {
            jacCol_j[i] += -(Ith(b,i) - Ith(solver->last_residual,i))*tempj1-Ith(solver->work_vector,i)*tempj2;
        }
    }

    if((block->callbacks->log_options.log_level >= 4)) {
        jmi_log_node_t node = jmi_log_enter_fmt(block->log, logInfo, "ModifiedBFGSJacobianUpdate", "<block:%s>", block->label);
        if (block->callbacks->log_options.log_level >= 6) {
            jmi_log_real_matrix(block->log, node, logInfo, "jacobian", block->J->data, N, N);
        }
        jmi_log_leave(block->log, node);
    }
    if(block->n > 1) {
        block->broyden_update_time += jmi_block_solver_elapsed_time(block, t);
    }
    ret = jmi_kin_factorize_jacobian(block );
    return ret;
}

/* Perform factorization of the Jacobian approximation stored in solver->J */
static int jmi_kin_factorize_jacobian(jmi_block_solver_t *block ) {
    jmi_kinsol_solver_t* solver = (jmi_kinsol_solver_t*)block->solver;
    int info;
    int N = block->n;
    clock_t t = jmi_block_solver_start_clock(block);
      
    DenseCopy(block->J, solver->J_LU); /* make a copy of the Jacobian that will be used for LU factorization */

    /* Equillibrate if corresponding option is set */
    if((N>1) && block->options->use_jacobian_equilibration_flag) {
        int info;
        double rowcnd, colcnd, amax;
        dgeequ_(&N, &N, solver->J_LU->data, &N, solver->rScale, solver->cScale, 
                &rowcnd, &colcnd, &amax, &info);
        if(info == 0) {
            dlaqge_(&N, &N, solver->J_LU->data, &N, solver->rScale, solver->cScale, 
                    &rowcnd, &colcnd, &amax, &solver->equed);
        }
        else if(info > 0) {
            solver->equed = 'N';
            if(info <= N)
                jmi_log_node(block->log, logWarning, "ZeroRow", "<Row: %d> of the Jacobian is exactly zero in <block: %s>.", info, block->label);
            else
                jmi_log_node(block->log, logWarning, "ZeroColumn", "<Column: %d> of the Jacobian is exactly zero in <block: %s>.", info-N, block->label);
        }
        else {
            solver->equed = 'N';
        }
    }
    
    info = jmi_LU_factorization(block, solver->J_LU);
    if(info != 0) {
        if(jmi_kinsol_zero_column_jacobian_handling(block)) {
            DenseCopy(block->J, solver->J_LU); /* make a copy of the Jacobian that will be used for LU factorization */
            info = jmi_LU_factorization(block, solver->J_LU);
        }
    }
    
    if(info != 0 ) {
        if (N > 1) {
            if (solver->J_is_singular_flag) { /* If the previous Jacobian update was singular, use minimum norm */
                solver->handling_of_singular_jacobian_flag = JMI_MINIMUM_NORM;
            } else {
                solver->handling_of_singular_jacobian_flag = JMI_REGULARIZATION;
            }
            
            if(block->callbacks->log_options.log_level >= 5) {
                jmi_log_node_t inner_node;
                inner_node = jmi_log_enter_fmt(block->log, logInfo, "SingularJacobian", 
                                    "Singular Jacobian detected when factorizing in linear solver "
                                    "in <block: %s>", block->label);
                jmi_log_leave(block->log, inner_node);
            }

            if (solver->handling_of_singular_jacobian_flag == JMI_REGULARIZATION) {
                jmi_log_t *log = block->log;
                jmi_log_node_t node = jmi_log_enter_fmt(log, logWarning, "Regularization", 
                            "Singular Jacobian detected when factorizing in linear solver. "
                             "Will try to regularize the equations in <block: %s>", block->label);
                if (block->callbacks->log_options.log_level >= 3) {
                    jmi_log_reals(log, node, logWarning, "ivs",  N_VGetArrayPointer(solver->kin_y), N);
                }
                jmi_log_leave(log, node);
                
                if(N > 1) {
                    jmi_kinsol_reg_matrix(block);
                    info = jmi_LU_factorization(block, solver->JTJ);
                }
            } else if (solver->handling_of_singular_jacobian_flag == JMI_MINIMUM_NORM) {
                jmi_log_node(block->log, logWarning, "MinimumNorm", "Singular Jacobian detected when factorizing in linear solver. "
                             "Will try to find the minimum norm solution in <block: %s>", block->label);
                SetToZero(solver->J_sing);
                DenseCopy(block->J, solver->J_sing);
            } else {
                /* Error */
                jmi_log_node(block->log, logWarning, "IllegalOption", "Illegal singular jacobian handling <option: %d> in <block: %s>", 
                    solver->handling_of_singular_jacobian_flag, block->label);
                block->factorization_time += jmi_block_solver_elapsed_time(block, t);
                return -1;
            }
            
            solver->J_is_singular_flag = 1;
        }
    } else {
        /* if (solver->using_max_min_scaling_flag) {
            realtype cond = jmi_calculate_condition_number(block, solver->J->data);
            jmi_log_node(block->log, logWarning, "JacobianConditioningNumber",
                             "<JacobianConditionEstimate:%E> large values may lead to convergence problems.", cond);
        }
        */
        solver->J_is_singular_flag = 0;
    }

    block->factorization_time += jmi_block_solver_elapsed_time(block, t);
    return 0;
}

/* Callback from KINSOL to solve linear system and calculate the step */
/* static int jmi_kin_lsolve(struct KINMemRec * kin_mem, N_Vector x, N_Vector b, realtype *res_norm) { */
static int jmi_kin_lsolve(struct KINMemRec * kin_mem, N_Vector x, N_Vector b, realtype *sJpnorm, realtype *sFdotJp) {
    jmi_block_solver_t *block = kin_mem->kin_user_data;
    jmi_kinsol_solver_t* solver = block->solver;
    clock_t t;
    realtype*  bd = N_VGetArrayPointer(b); /* - residuals, i.e. -F(x) */
    realtype*  xd = N_VGetArrayPointer(x); /* on input - last successfull step; on output - new step */
    jmi_log_node_t node={0};
    long int  nniters;           
    int N = block->n;
    int ret = 0, i;
    KINGetNumNonlinSolvIters(kin_mem, &nniters);
    solver->current_nni = nniters;

    
    if (!solver->updated_jacobian_flag && nniters > 0) {
        if(block->options->jacobian_update_mode == jmi_broyden_jacobian_update_mode)
            ret = jmi_kin_make_Broyden_update(block, b);
        if (block->options->experimental_mode & jmi_block_solver_experimental_use_modifiedBFGS)
            ret = jmi_kin_make_modifiedBFGS_update(block, b);
        if (block->options->experimental_mode & jmi_block_solver_experimental_Sparse_Broyden)
            ret = jmi_kin_make_sparse_Broyden_update(block, b);

        if(ret != 0) return ret;
    }

    if(((block->options->residual_equation_scaling_mode == jmi_residual_scaling_aggressive_auto) &&
        nniters > 1 && solver->is_first_newton_solve_flag) 
        || (block->options->residual_equation_scaling_mode == jmi_residual_scaling_full_jacobian_auto 
        && nniters > 1 && solver->updated_jacobian_flag && solver->is_first_newton_solve_flag)) {
        int i;
        jmi_log_node_t node = jmi_log_enter_fmt(block->log, logInfo, "AggressiveResidualScalingUpdate", "Updating f_scale aggressively");
        N_VScale(1.0, block->f_scale, solver->work_vector);
        kin_char_log(solver, 's');
        jmi_update_f_scale(block);
        jmi_regularize_and_do_condition_estimate_on_scaled_jacobian(block);
        for(i=0; i<block->n; i++) {
            Ith(block->f_scale, i) = Ith(block->f_scale, i) > Ith( solver->work_vector, i)? Ith( solver->work_vector, i):Ith(block->f_scale, i);
        }
        if (block->callbacks->log_options.log_level >= 4) {
            jmi_log_node_t outer = jmi_log_enter_fmt(block->log, logInfo, "ResidualScalingUpdated", "<block:%s>", block->label);
            if (block->callbacks->log_options.log_level >= 5) {
                jmi_log_node_t inner = jmi_log_enter_vector_(block->log, outer, logInfo, "scaling");
                realtype* res = N_VGetArrayPointer(block->f_scale);
                for (i=0;i<N;i++) jmi_log_real_(block->log, 1/res[i]);
                jmi_log_leave(block->log, inner);
            }
            jmi_log_leave(block->log, outer);
        }
        jmi_log_leave(block->log, node);
    }
    t = jmi_block_solver_start_clock(block);
    N_VScale(ONE, b, solver->last_residual);

    solver->updated_jacobian_flag = 0; /* The Jacobian is no longer current */
    
    if(solver->force_new_J_flag) {  
        block->step_calc_time += jmi_block_solver_elapsed_time(block, t);
        return 1;
    }
    
    /*
      Taken directly from SUNDIALS:
 
        Compute the terms Jpnorm and sfdotJp for use in the global strategy
       routines and in KINForcingTerm. Both of these terms are subsequently
       corrected if the step is reduced by constraints or the line search.
  
       sJpnorm is the norm of the scaled product (scaled by fscale) of
       the current Jacobian matrix J and the step vector p.
  
       sfdotJp is the dot product of the scaled f vector and the scaled
       vector J*p, where the scaling uses fscale. */
    if((block->callbacks->log_options.log_level >= 6)) {
        node = jmi_log_enter_fmt(block->log, logInfo, "KinsolLinearSolver", "Solving the linear system in <block:%s>", block->label);
    }
  
    *sJpnorm = N_VWL2Norm(b,block->f_scale);
    solver->sJpnorm = *sJpnorm;
    N_VProd(b, block->f_scale, x);
    N_VProd(x, block->f_scale, x);
    
    *sFdotJp = N_VDotProd(kin_mem->kin_fval, x);
    /* if the Jacobian was equilibrated then scale the residuals accordingly */
    if((solver->equed == 'R') || (solver->equed == 'B')) {
        for(i = 0; i < N; i++) {
            bd[i] *= solver->rScale[i];
        }
    }
    if(solver->use_steepest_descent_flag || block->options->active_bounds_mode == jmi_use_steepest_descent_active_bounds_mode) {
        /* calculate steepest descent direction */

        /*  gradient = Transpose(J) W*W F, 
            where W is the diagonal matix of residual scaling factors. 
            W*W F is effectively calculated above in "x" as a part of kin_sfdotJp calculation.
            solver->gradient is the negative gradient.
         */

        jmi_linear_algebra_dgemv(1, block->J->data, N_VGetArrayPointer(x), 0, N_VGetArrayPointer(solver->gradient), N, TRUE);
    }
    if(solver->use_steepest_descent_flag) {
        /* Make step in steepest descent direction and not Newton*/
        N_VScale(ONE, solver->gradient, x);
        kin_char_log(solver, 'd');
        ret = 0;
    }
    else if(solver->J_is_singular_flag) {
        if (N == 1) {
            xd[0] = block->nominal[0] * 0.1 *((bd[0] > 0)?1:-1) * ((DENSE_ELEM(block->J,0,0) > 0)?1:-1);
            ret = 0;
        } else if (solver->handling_of_singular_jacobian_flag == JMI_REGULARIZATION) {
            /* solve the regularized problem */
            int i,j;
            realtype * fscale_data = N_VGetArrayPointer(block->f_scale);
            realtype gnorm;/*gradient norm*/

            for (i=0;i<N;i++){
                xd[i] = 0;
                for (j=0;j<N;j++) xd[i] += DENSE_ELEM(block->J,j,i)*bd[j]*fscale_data[j]*fscale_data[j];
            }
            
            gnorm = N_VWL2Norm(x, kin_mem->kin_uscale);
            if((block->callbacks->log_options.log_level >= 5)) {
                jmi_log_node(block->log, logInfo, "Gradient", 
                    "Singular point with gradient (<norm:%g>) in <block: %s>.",
                        gnorm, block->label);
            }
            if(gnorm < solver->kin_stol) {
                /*near zero  gradient */
                realtype* uscale_data = N_VGetArrayPointer(solver->kin_y_scale);
                jmi_log_node(block->log, logWarning, "ZeroGradient", 
                    "Singular point with near-zero gradient (<norm:%g>) detected in <block: %s>.",
                        gnorm, block->label);
                       for (i=0;i<N;i++){
                            xd[i] = 0;
                            for (j=0;j<N;j++) xd[i] += bd[j]*fscale_data[j]*fscale_data[j]/uscale_data[j];
                        }
            }

            /* Back-solve and get solution in x */
            t = jmi_block_solver_start_clock(block);
            ret = jmi_LU_solve(block, solver->JTJ, xd);
            kin_char_log(solver, 'r');
            solver->force_new_J_flag = 1;
            if(block->options->rescale_after_singular_jac_flag)
                block->force_rescaling = 1;
            
        } else if (solver->handling_of_singular_jacobian_flag == JMI_MINIMUM_NORM) {
            /*
             *   DGELSS - compute the minimum norm solution to  a real 
             *   linear least squares problem
             * 
             * SUBROUTINE DGELSS( M, N, NRHS, A, LDA, B, LDB, S, RCOND, RANK,WORK, LWORK, INFO )
             *
             */
            int nrhs = 1; /* One rhs to solve for */ 
            double rcond = -1.0;
            int rank = 0;
            int iwork = 5*N;
            
            N_VScale(ONE, b, x);
            t = jmi_block_solver_start_clock(block);
            dgelss_(&N, &N, &nrhs, solver->J_sing->data, &N, xd, &N ,solver->singular_values, &rcond, &rank, solver->dgelss_rwork, &iwork, &ret);
            solver->force_new_J_flag = 1;
            if(block->options->rescale_after_singular_jac_flag)
                block->force_rescaling = 1;
            
            if(block->callbacks->log_options.log_level >= 5) {
                jmi_log_node_t inner_node;
                inner_node =jmi_log_enter_fmt(block->log, logInfo, "MinimumNorm", 
                                "Found the minimum norm solution.");
                jmi_log_reals(block->log, inner_node, logInfo, "singular_values", solver->singular_values, N);
                jmi_log_fmt(block->log, inner_node, logInfo, "<rank:%d>", rank);
                jmi_log_leave(block->log, inner_node);
            }
            kin_char_log(solver, 'm');
        }

        /* Evaluate discrete variables after a regularization. */
        if (block->at_event) {
            jmi_log_node_t inner_node={0};
            if(block->callbacks->log_options.log_level >= 5 && block->log_discrete_variables) {
                inner_node =jmi_log_enter_fmt(block->log, logInfo, "RegularizationDiscreteUpdate", 
                                "Evaluating switches after regularization.");
                jmi_log_fmt(block->log, inner_node, logInfo, "Pre discrete variables");
                block->log_discrete_variables(block->problem_data, inner_node);
            }

            block->F(block->problem_data, block->x, block->res, JMI_BLOCK_EVALUATE | JMI_BLOCK_EVALUATE_NON_REALS);
            
            if(block->callbacks->log_options.log_level >= 5 && block->log_discrete_variables) {
                jmi_log_fmt(block->log, inner_node, logInfo, "Post discrete variables");
                block->log_discrete_variables(block->problem_data, inner_node);
                jmi_log_leave(block->log, inner_node);
            }
        }
    }
    else {
        /* Normal linear system solve (with LU) to get Newton step */
        N_VScale(ONE, b, x);
        i = 1;
        
        if((block->callbacks->log_options.log_level >= 6)) {
            jmi_log_real_matrix(block->log, node, logInfo, "jacobian", block->J->data, N, N);
            jmi_log_reals(block->log, node, logInfo, "rhs", xd, N);
        }
        
        ret = jmi_LU_solve(block, solver->J_LU, xd);

        if((block->callbacks->log_options.log_level >= 6)) {
            jmi_log_reals(block->log, node, logInfo, "solution", xd, N);
        }
    }

    if((block->callbacks->log_options.log_level >= 6)) {
        jmi_log_leave(block->log, node);
    }

    if(ret) {
        block->step_calc_time += jmi_block_solver_elapsed_time(block, t);
        return ret; /* Break out on error */
    }
    
    if((solver->equed == 'C') || (solver->equed == 'B')) {
        /* scale solution if the Jacobian was equilibrated */
        int i;
        realtype*  gd = N_VGetArrayPointer(solver->gradient);
        for(i = 0; i < block->n; i++) {
            xd[i] *= solver->cScale[i];
            if(solver->use_steepest_descent_flag || block->options->active_bounds_mode == jmi_use_steepest_descent_active_bounds_mode) {
                gd[i] *= solver->cScale[i];
            }
        }
    }
    block->step_calc_time += jmi_block_solver_elapsed_time(block, t);

    {
        jmi_log_node_t topnode={0};
        if(block->callbacks->log_options.log_level >= 5) {
            topnode = jmi_log_enter_(block->log,logInfo,"StepDirection");
            jmi_log_reals(block->log, topnode, logInfo, "unbounded_step", xd, block->n);
        }
        jmi_kinsol_limit_step(kin_mem, x, b, sJpnorm, sFdotJp);
        t = jmi_block_solver_start_clock(block);
        if(solver->last_num_active_bounds > 0 && (block->options->active_bounds_mode == jmi_use_steepest_descent_active_bounds_mode)) {
            realtype sfJp, fnorm, g_scale;
            
            /*scalar product of gradient and projected step = Transpose(gradient) * x = Transpose(Transpose(J) Wf Wf F)*x = Transpose(F) Wf Wf J x = sfJp */
            sfJp = jmi_kinsol_calc_v1twwv2(x, solver->gradient, 0); 

            if(sfJp <= 0.0) {
                if(block->callbacks->log_options.log_level >= 5) {
                    double step_factor = solver->last_num_active_bounds > 0? 1.0:solver->max_step_ratio;
                    N_VScale(step_factor, x, b);
                    jmi_log_reals(block->log, topnode, logInfo, "projected_newton_step", bd, block->n);                    
                }
                kin_char_log(solver, 'd');
                jmi_log_node(block->log, logInfo, "StepNotDescent", 
                    "Projected Newton step is not descent in <block: %s>, scaled scalar product with gradient <spxg: %g>, trying steepest descent", block->label, sfJp);

                /* allow beta condition failures since with steepest descent small steps are common */
                kin_mem->kin_nbcf = 0;

                /*
                    sfdotJp = Transpose(F) * Wf*Wf*J*gradient = Transpose(F) * Wf*Wf*J* Transpose(J)* Wf*Wf*F = Transpose(gradient)*gradient
                */
                sfJp = jmi_kinsol_calc_v1twwv2(solver->gradient, solver->gradient, 0);
                KINGetFuncNorm(solver->kin_mem, &fnorm);
                g_scale = fnorm*fnorm/sfJp;
                if(block->callbacks->log_options.log_level >= 5) {
                    jmi_log_node(block->log, logInfo, "GradientScaling", "Used gradient scaling is <gs: %g> in <block: %s>", g_scale, block->label);
                }
                N_VScale(g_scale, solver->gradient, x);
                jmi_kinsol_limit_step(kin_mem, x, b, sJpnorm, sFdotJp);

                sfJp = jmi_kinsol_calc_v1twwv2(x, solver->gradient, 0); 

                if(sfJp == 0.0) {
                    jmi_log_node(block->log, logWarning, "StepIsZero", "Projected steepest descent step is zero in <block: %s>", block->label);
                }
            }
            
            /* recalculate sJpnorm  */ 
            jmi_linear_algebra_dgemv(1.0, block->J->data, N_VGetArrayPointer(x), 0, N_VGetArrayPointer(b), N, FALSE);
            *sJpnorm = N_VWL2Norm(b,block->f_scale);
            *sFdotJp = -sfJp; /* Due to opposite sign of solver->gradient minus is present here. */
            solver->sJpnorm = *sJpnorm;

        }
        if(block->callbacks->log_options.log_level >= 5) {
            double step_factor = solver->last_num_active_bounds > 0? 1.0:solver->max_step_ratio;
            N_VScale(step_factor, x, b);
            jmi_log_reals(block->log, topnode, logInfo, "projected_step", bd, block->n);
            jmi_log_leave(block->log, topnode);
        }
    }
    block->step_calc_time += jmi_block_solver_elapsed_time(block, t);
    return 0;
}

int jmi_kinsol_solver_new(jmi_kinsol_solver_t** solver_ptr, jmi_block_solver_t* block) {
    jmi_kinsol_solver_t* solver;
    int flag, n = block->n;
    
    
    struct KINMemRec * kin_mem = KINCreate();
    if(!kin_mem) return -1;
    solver = (jmi_kinsol_solver_t*)calloc(1,sizeof(jmi_kinsol_solver_t));
    if(!solver ) return -1;
    solver->kin_mem = kin_mem;
#ifdef JMI_PROFILE_RUNTIME 
    block->time_f = 0;
    block->time_df = 0;
#endif
    
    /*Initialize work vectors.*/

    /*Sets the scaling vectors to ones.*/
    /*To be changed. */
    solver->kin_y = N_VMake_Serial(n, block->x);
    solver->kin_y_scale = N_VNew_Serial(n);
    solver->gradient  = N_VNew_Serial(n);    
    solver->last_residual = N_VNew_Serial(n);
    solver->kin_jac_update_time = -1.0;
    /*NOTE: it'd be nice to use "jmi->newton_tolerance" here
      However, newton_tolerance is not set yet at this point.
    */
    solver->kin_ftol = UROUND; /* block->options->min_tol; */
    solver->kin_stol = block->options->min_tol;
    solver->has_compression_setup_flag = FALSE;
    solver->is_first_newton_solve_flag = TRUE;
    solver->current_nni = 0;
    
    solver->JTJ = NewDenseMat(n ,n);
    solver->J_LU = NewDenseMat(n ,n);
    solver->J_sing = NewDenseMat(n, n);
    solver->J_Dependency = NewDenseMat(n,n);
    solver->J_is_singular_flag = 0;

    solver->equed = 'N';
    solver->rScale = (realtype*)calloc(n+1,sizeof(realtype));
    solver->cScale = (realtype*)calloc(n+1,sizeof(realtype));
    solver->range_limits = (realtype*)calloc(n+1,sizeof(realtype));
    solver->range_limited = (int*)calloc(n+1,sizeof(int));
    solver->jac_compression_groups = (int*)calloc(n+1,sizeof(int));
    solver->jac_compression_group_index = (int*)calloc(n+1,sizeof(int));
    solver->range_most_limiting = 0;

    solver->work_vector = N_VNew_Serial(n);
    solver->work_vector2 = N_VNew_Serial(n);
    solver->work_vector3 = N_VNewEmpty_Serial(n);
    solver->lapack_work = (realtype*)calloc(4*(n+1),sizeof(realtype));
    solver->lapack_iwork = (int *)calloc(n+2, sizeof(int));
    solver->lapack_ipiv = (int *)calloc(n+2, sizeof(int));

    solver->dgesdd_lwork = 7*n*n+4*n;
    solver->dgesdd_work  = (realtype*)calloc(solver->dgesdd_lwork,sizeof(realtype));
    solver->dgesdd_iwork = (int*)calloc(8*n,sizeof(int));

    solver->sundials_permutationwork = (long int*)calloc(n+1,sizeof(long int));
    
    solver->dgelss_rwork = (realtype*)calloc(5*n,sizeof(realtype));
    solver->singular_values = (realtype*)calloc(n,sizeof(realtype));
    solver->max_step_ratio = 1.0;

    kin_reset_char_log(solver);

    /* Initialize scaling to 1.0 - defaults */
    N_VConst_Serial(1.0,solver->kin_y_scale);
                
    flag = KINInit(solver->kin_mem, kin_f, solver->kin_y); /*Initialize Kinsol*/
    jmi_kinsol_error_handling(block, flag);
    
    /*Attach linear solver*/
    kin_mem->kin_lsetup = jmi_kin_lsetup;
    kin_mem->kin_lsolve = jmi_kin_lsolve;
    kin_mem->kin_setupNonNull = TRUE;
    kin_mem->kin_inexact_ls = FALSE;
    /*End linear solver*/
    
    /*Set problem data to Kinsol*/
    flag = KINSetUserData(solver->kin_mem, block);
    jmi_kinsol_error_handling(block, flag);  
    
    /*Stopping tolerance of F -> just a default */
    KINSetFuncNormTol(solver->kin_mem, solver->kin_ftol); 
    
    /*Stepsize tolerance*/
    KINSetScaledStepTol(solver->kin_mem, solver->kin_stol);
    
    /* Max number of iters */
    KINSetNumMaxIters(solver->kin_mem, block->options->max_iter);
    
    /*Verbosity*/
    KINSetPrintLevel(solver->kin_mem, get_print_level(block));
    
    /*Error function*/
    KINSetErrHandlerFn(solver->kin_mem, kin_err, block);
    /*Info function*/
    KINSetInfoHandlerFn(solver->kin_mem, kin_info, block);
    /*  Jacobian can be reused if set to true, this parameter should be changed later on after first time of Newton solve. */
    KINSetNoInitSetup(solver->kin_mem, 0);    
    
    /* Struct for storing the Kinsol state */
    solver->saved_state = (jmi_kinsol_solver_reset_t*)calloc(1,sizeof(jmi_kinsol_solver_reset_t));
    solver->saved_state->J = NewDenseMat(n,n);
    solver->saved_state->J_modified = NewDenseMat(n,n);
    solver->saved_state->kin_f_scale = N_VNew_Serial(n);
    solver->saved_state->kin_y_scale = N_VNew_Serial(n);
    solver->saved_state->lapack_ipiv = (int *)calloc(n+2, sizeof(int));
    solver->saved_state->J_is_singular_flag = 0;
    solver->saved_state->force_new_J_flag = 0;
    solver->saved_state->force_rescaling = 0;
    solver->saved_state->handling_of_singular_jacobian_flag = JMI_REGULARIZATION;
    solver->saved_state->mbset = 0;
      
    *solver_ptr = solver;

    return flag;
}

void jmi_kinsol_solver_delete(jmi_block_solver_t* block) {
    jmi_kinsol_solver_t* solver = block->solver;
#ifdef JMI_PROFILE_RUNTIME 
    if (block->n > 1) {
        char message[256];
        sprintf(message, "Time in df: %g, BlockLabel: %s, is_init_block: %d", block->time_df, block->label, block->is_init_block);
        jmi_log_node(block->log, logError, "ACC_TIME_IN_KIN_DF", message);

        sprintf(message, "Time in f: %g, BlockLabel: %s, is_init_block: %d", block->time_f, block->label, block->is_init_block);
        jmi_log_node(block->log, logError, "ACC_TIME_IN_KIN_F", message);

        if (block->options->use_Brent_in_1d_flag) {
            sprintf(message, "Time in brent: %g, BlockLabel: %s", block->time_in_brent, block->label);
            jmi_log_node(block->log, logError, "ACC_TIME_IN_BRENT", message); /**/
        }
    }
#endif

    /*Deallocate Kinsol work vectors.*/
    N_VDestroy_Serial(solver->kin_y);
    N_VDestroy_Serial(solver->kin_y_scale);
    N_VDestroy_Serial(solver->gradient);
    N_VDestroy_Serial(solver->last_residual);
    DestroyMat(solver->JTJ);
    DestroyMat(solver->J_LU);
    DestroyMat(solver->J_sing);
    DestroyMat(solver->J_Dependency);
    free(solver->cScale);
    free(solver->rScale);
    free(solver->range_limits);
    free(solver->range_limited);
    free(solver->jac_compression_groups);
    free(solver->jac_compression_group_index);
    N_VDestroy_Serial(solver->work_vector);
    N_VDestroy_Serial(solver->work_vector2);
    N_VDestroy_Serial(solver->work_vector3);
    free(solver->lapack_work);
    free(solver->lapack_iwork);
    free(solver->lapack_ipiv);
    free(solver->dgelss_rwork);
    free(solver->singular_values);

    free(solver->sundials_permutationwork);

    free(solver->dgesdd_work);
    free(solver->dgesdd_iwork);
    
    if(solver->num_bounds > 0) {
        free(solver->bound_vindex);
        free(solver->bound_kind);
        free(solver->bound_limiting);
        free(solver->bounds);
        free(solver->active_bounds);
    }
    
    /* Struct for storing the Kinsol state */
    DestroyMat(solver->saved_state->J);
    DestroyMat(solver->saved_state->J_modified);
    N_VDestroy_Serial(solver->saved_state->kin_f_scale);
    N_VDestroy_Serial(solver->saved_state->kin_y_scale);
    free(solver->saved_state->lapack_ipiv);
    free(solver->saved_state);

    /*Deallocate Kinsol */
    if(solver->kin_mem)
        KINFree(&(solver->kin_mem));
    /*Deallocate struct */
    free(solver);
    block->solver = 0;
}

void jmi_kinsol_solver_print_solve_start(jmi_block_solver_t * block,
                                         jmi_log_node_t *destnode) {
    if ((block->callbacks->log_options.log_level >= 4)) {
        jmi_log_t *log = block->log;
        *destnode = jmi_log_enter_fmt(log, logInfo, "NewtonSolve", 
                                      "Newton solver invoked for <block:%s>", block->label);
        if ((block->callbacks->log_options.log_level >= 5)) {
            jmi_kinsol_solver_t* solver = (jmi_kinsol_solver_t*)block->solver;
            jmi_log_vrefs(log, *destnode, logInfo, "variables", 'r', block->value_references, block->n);
            jmi_log_reals(log, *destnode, logInfo, "max", block->max, block->n);
            jmi_log_reals(log, *destnode, logInfo, "min", block->min, block->n);
            jmi_log_reals(log, *destnode, logInfo, "nominal", block->nominal, block->n);
            jmi_log_reals(log, *destnode, logInfo, "initial_guess", block->x, block->n);
            jmi_log_reals(log, *destnode, logInfo, "ranges", solver->range_limits, block->n);
        }
    }
}

const char *jmi_kinsol_flag_to_name(int flag) {
    /*
        char* name = KINGetReturnFlagName(flag);
        KINGetReturnFlagName(flag) allocates memory and may cause memleak
     */

    switch (flag) {
    case KIN_SUCCESS: return "KIN_SUCCESS";
    case KIN_INITIAL_GUESS_OK: return "KIN_INITIAL_GUESS_OK";
    case KIN_STEP_LT_STPTOL: return "KIN_STEP_LT_STPTOL";
    case KIN_WARNING: return "KIN_WARNING";
    case KIN_MEM_NULL: return "KIN_MEM_NULL";
    case KIN_ILL_INPUT: return "KIN_ILL_INPUT";
    case KIN_NO_MALLOC: return "KIN_NO_MALLOC";
    case KIN_MEM_FAIL: return "KIN_MEM_FAIL";
    case KIN_LINESEARCH_NONCONV: return "KIN_LINESEARCH_NONCONV";
    case KIN_MAXITER_REACHED: return "KIN_MAXITER_REACHED";
    case KIN_MXNEWT_5X_EXCEEDED: return "KIN_MXNEWT_5X_EXCEEDED";
    case KIN_LINESEARCH_BCFAIL: return "KIN_LINESEARCH_BCFAIL";
    case KIN_LINSOLV_NO_RECOVERY: return "KIN_LINSOLV_NO_RECOVERY";
    case KIN_LINIT_FAIL: return "KIN_LINIT_FAIL";
    case KIN_LSETUP_FAIL: return "KIN_LSETUP_FAIL";
    case KIN_LSOLVE_FAIL: return "KIN_LSOLVE_FAIL";
    case KIN_SYSFUNC_FAIL: return "KIN_SYSFUNC_FAIL";
    case KIN_FIRST_SYSFUNC_ERR: return "KIN_FIRST_SYSFUNC_ERR";
    case KIN_REPTD_SYSFUNC_ERR: return "KIN_REPTD_SYSFUNC_ERR";
    default: return "UNKNOWN";
    }
}

void jmi_kinsol_solver_print_solve_end(jmi_block_solver_t * block, const jmi_log_node_t *node, int flag) {
    long int nniters;
    jmi_kinsol_solver_t* solver = block->solver;
    
    KINGetNumNonlinSolvIters(solver->kin_mem, &nniters);

    /* NB: must match the condition in jmi_kinsol_solver_print_solve_start exactly! */
    if((block->callbacks->log_options.log_level >= 4)) {
        jmi_log_t *log = block->log;
        const char *flagname = jmi_kinsol_flag_to_name(flag);
        if (flagname != NULL) jmi_log_fmt(log, *node, logInfo, "Newton solver finished with <kinsol_exit_flag:%s>", flagname);
        else jmi_log_fmt(log, *node, logInfo, "Newton solver finished with unrecognized <kinsol_exit_flag:%d>", flag);
        jmi_log_leave(log, *node);
    }
}

static int jmi_kinsol_invoke_kinsol(jmi_block_solver_t *block, int strategy) {
    jmi_kinsol_solver_t* solver = block->solver;
    int flag;
    jmi_log_node_t topnode={0};
    struct KINMemRec* kin_mem = (struct KINMemRec*) solver->kin_mem;
    
    if(block->options->solver_exit_criterion_mode == jmi_exit_criterion_step || 
        block->options->solver_exit_criterion_mode == jmi_exit_criterion_step_residual) {
        KINSetFuncNormTol(solver->kin_mem, solver->kin_ftol);
        KINSetScaledStepTol(solver->kin_mem, solver->kin_stol);
    } else if (block->options->solver_exit_criterion_mode == jmi_exit_criterion_residual) {
        KINSetFuncNormTol(solver->kin_mem, solver->kin_stol);
        KINSetScaledStepTol(solver->kin_mem, solver->kin_ftol);
    } 
    jmi_kinsol_solver_print_solve_start(block, &topnode);
    flag = KINSol(solver->kin_mem, solver->kin_y, strategy, solver->kin_y_scale, block->f_scale);
    if(flag == KIN_INITIAL_GUESS_OK) { /* last_fnorm not up to date in this case */
        double max_residual = 0.0;
        int i, max_index = 0;
        realtype* f;
        char msg[256];
        realtype* residual_scaling_factors = NV_DATA_S(block->f_scale);
        long int nni = 0, nfe = 0;
        
        KINGetNumFuncEvals(solver->kin_mem, &nfe);
        KINGetNumNonlinSolvIters(solver->kin_mem, &nni);

        /*kin_f(solver->kin_y, solver->work_vector, block); */
        f = NV_DATA_S(kin_mem->kin_fval);
        if (block->n >= 1) {
            max_residual = f[0]*residual_scaling_factors[0];
            for (i=1;i<block->n;i++) {
                realtype res = f[i]*residual_scaling_factors[i];
                if (JMI_ABS(res) > JMI_ABS(max_residual)) {
                    max_residual = res;
                    max_index = i;
                }
            }
        }

        solver->last_max_residual= max_residual;
        solver->last_max_residual_index = max_index;
        solver->last_fnorm = N_VWL2Norm(kin_mem->kin_fval, block->f_scale);
        kin_mem->kin_fnorm = solver->last_fnorm;
        sprintf(msg, "nni = %4ld   nfe = %6ld   fnorm = %26.16g", nni, nfe, solver->last_fnorm);
        kin_info("", "KINSolInit", msg, kin_mem->kin_ih_data);
        jmi_kinsol_print_progress(block, 2, flag);
    } else {
        jmi_kinsol_print_progress(block, 1, flag);
    }
    if(flag == KIN_INITIAL_GUESS_OK) {
        flag = KIN_SUCCESS;
        /* If the evaluation of the residuals fails, e.g. due to NaN in the residuals, the Kinsol exits, but the old fnorm
             from a previous solve, possibly converged, is still stored. In such cases Kinsol reports success based on a fnorm
             value from a previous solve - if the previous solve was converged, then also a following faulty solve will be reported
             as a success. Commenting out this code since it causes problems.*/
    } else if (flag == KIN_LINESEARCH_NONCONV || flag == KIN_STEP_LT_STPTOL || flag == KIN_LINESEARCH_BCFAIL) {
        realtype fnorm;
        N_VProd(block->f_scale, kin_mem->kin_fval, solver->work_vector);
        fnorm =N_VMaxNorm(solver->work_vector);
        if((fnorm <= solver->kin_stol && !(block->options->solver_exit_criterion_mode == jmi_exit_criterion_step_residual))
            || (block->options->solver_exit_criterion_mode == jmi_exit_criterion_step && flag == KIN_STEP_LT_STPTOL) ||
            (fnorm <= solver->kin_stol && block->options->solver_exit_criterion_mode == jmi_exit_criterion_step_residual 
             && flag == KIN_STEP_LT_STPTOL)) {
            flag = KIN_SUCCESS;
        } else if (flag == KIN_LINESEARCH_NONCONV) { /* Print the postponed error message */
            jmi_kinsol_linesearch_error_message(block, "The line search algorithm was unable to find an iterate sufficiently distinct from the current iterate.");
        } else if (flag == KIN_LINESEARCH_BCFAIL) {
            long int nbc_fails;
            char msg[256];
            KINGetNumBetaCondFails(solver->kin_mem, &nbc_fails);
            sprintf(msg, "The line search algorithm was unable to to satisfy the beta-condition for %ld iterations.", nbc_fails);            
            jmi_kinsol_linesearch_error_message(block, msg);
        } else {
            jmi_kinsol_small_step_nonconv_info_message(block);
        }

        if(block->options->check_jac_cond_flag) {
            int i, N = block->n;
            realtype* scale_ptr = N_VGetArrayPointer(block->f_scale);
            realtype tol = solver->kin_stol;
            if(block->options->residual_equation_scaling_mode !=0) {
                for(i = 0; i < N; i++){
                    int j;
                    realtype* scaled_col_ptr = DENSE_COL(block->J_scale, i);
                    realtype* col_ptr = DENSE_COL(block->J, i);
                    realtype xscale = JMI_ABS(block->nominal[i]);
                    realtype x = JMI_ABS(block->x[i]);
                    if(x < xscale) x = xscale;
                    if(x < tol) x = tol;
                    for(j = 0; j < N; j++){
                        scaled_col_ptr[j] = col_ptr[j] * x *scale_ptr[j];
                    }
                }
            } else {
                DenseCopy(block->J, block->J_scale);
            }

            jmi_kinsol_log_jacobian_cond_nbr(block);
        }
    }
    jmi_kinsol_solver_print_solve_end(block, &topnode, flag);
    return flag;
}


int jmi_kinsol_solver_solve(jmi_block_solver_t * block){
    int flag;
    jmi_kinsol_solver_t* solver = block->solver;
    realtype curtime = block->cur_time;
    long int nniters = 0;
    int flagNonscaled;
    jmi_log_t *log = block->log;

    if(block->n == 1) {
       if (block->options->use_Brent_in_1d_flag) {
           return jmi_brent_solver_solve(block);
       }
       solver->f_pos_min_1d = BIG_REAL;
       solver->f_neg_max_1d = -BIG_REAL;
    }
    
    if(block->init) {
        flag = jmi_kinsol_init(block);
        if(flag) return flag;
    }
    else {
        if (jmi_block_solver_use_save_restore_state_behaviour(block)) {
            flag = jmi_kinsol_restore_state(block);
            
            if (flag) return flag;
        }
        
        /* Read initial values for iteration variables from variable vector.
        * This is needed if the user has changed initial guesses in between calls to
        * Kinsol.
        */
        flag = block->F(block->problem_data,block->x,block->res,JMI_BLOCK_INITIALIZE);
        if(flag) {        
            jmi_log_node(log, logWarning, "ErrorReadingInitialGuess", "<errorCode: %d> returned from <block: %s> "
                         "when reading initial guess.", flag, block->label);
            return flag;
        }
        if(solver->force_new_J_flag ) { /* New Jacobian forced due to solver failure in previous solve call */
            struct KINMemRec * kin_mem = solver->kin_mem; 
            if(jmi_kin_lsetup(kin_mem)) {
                jmi_log_node(block->log, logError, "Error", "Jacobian evaluation failed at initial point for "
                     "<block: %s>", block->label);
                return -1;
            }
        }
    }

    /* update the scaling only once per time step */
    if(block->init || (block->options->rescale_each_step_flag && (curtime > block->scale_update_time)) || block->force_rescaling) {
        if(block->options->residual_equation_scaling_mode != jmi_residual_scaling_none)
            kin_char_log(solver, 's');
        jmi_update_f_scale(block);
        jmi_regularize_and_do_condition_estimate_on_scaled_jacobian(block);
    }
    
    if(block->options->experimental_mode & jmi_block_solver_experimental_steepest_descent_first) {
        KINSetNoResMon(solver->kin_mem,0);        
        solver->use_steepest_descent_flag = 1;
    }

    solver->is_first_newton_solve_flag = TRUE;
    flag = jmi_kinsol_invoke_kinsol(block, KIN_LINESEARCH);
    /* From now on, the Jacobian can be reused. */
    KINSetNoInitSetup(solver->kin_mem, 1);  
    solver->is_first_newton_solve_flag = FALSE;

    if(block->options->experimental_mode & jmi_block_solver_experimental_steepest_descent_first) {
        KINSetNoResMon(solver->kin_mem,1);
        solver->use_steepest_descent_flag = 0;
    }
    
    /* If Kinsol failed, try to solve with steepest descent instead */
    if((block->options->experimental_mode & jmi_block_solver_experimental_steepest_descent) &&
        (flag != KIN_SUCCESS)) {
        
        jmi_log_node(log, logInfo, "Progress", "<source:%s><block:%s><message:%s>",
                     "jmi_kinsol_solver", block->label, "Attempting steepest descent iterations");        

        solver->use_steepest_descent_flag = 1;
        
        flag = KINSol(solver->kin_mem, solver->kin_y, KIN_LINESEARCH, solver->kin_y_scale, block->f_scale);
        if(flag == KIN_INITIAL_GUESS_OK) {
            flag = KIN_SUCCESS;
        }
        
        solver->use_steepest_descent_flag = 0;
    }
    
    /* First time scaling is always recomputed - initial guess may be "far away" and give bad scaling 
       TODO: we should probably rescale after event as well.
       TODO: Not sure if rescaling needs to happen in manual mode. Alternative is to have condition:
       ((block->options->residual_equation_scaling_mode == jmi_residual_scaling_auto ) ||
        (block->options->residual_equation_scaling_mode == jmi_residual_scaling_hybrid )
    */
    if( (block->options->residual_equation_scaling_mode != jmi_residual_scaling_none )
        && (block->init || (flag != KIN_SUCCESS))) {
        jmi_log_node(log, logInfo, "Rescaling", "Attempting rescaling in <block:%s>", block->label);

        flagNonscaled = flag;
        /* Get & store debug information */
        KINGetNumNonlinSolvIters(solver->kin_mem, &block->nb_iters);
        if(flagNonscaled != 0 && flag != KIN_STEP_LT_STPTOL) {
            jmi_log_node(log, logWarning, "NonConverge", "The equations with initial scaling didn't converge to a "
                         "solution in <block: %s>", block->label);
        }
        /* Update the scaling  */
        kin_char_log(solver, 's');
        jmi_update_f_scale(block);
        jmi_regularize_and_do_condition_estimate_on_scaled_jacobian(block);
        
        /* For the second solve set tight tolerance on the step and specified tolerance on the residual */
        KINSetScaledStepTol(solver->kin_mem, solver->kin_ftol);
        KINSetFuncNormTol(solver->kin_mem, solver->kin_stol);
        flag = jmi_kinsol_invoke_kinsol(block, KIN_LINESEARCH);
        KINSetScaledStepTol(solver->kin_mem, solver->kin_stol);
        KINSetFuncNormTol(solver->kin_mem, solver->kin_ftol);
        
        if(flag != KIN_SUCCESS) {
            /* If Kinsol failed, force a new Jacobian and new rescaling in the next try. */
            solver->force_new_J_flag = 1;
            block->force_rescaling = 1;

            if (flagNonscaled == 0) {
                jmi_log_node(log, logError, "Error", "The equations with initial scaling solved fine, "
                             "re-scaled equations failed in <block: %s>", block->label); 
            } else {
                if (jmi_kinsol_use_nominals_as_start(block)) {
                    jmi_kinsol_set_nominals_as_start(block);
                    jmi_log_node(log, logWarning, "NominalsAsInitialGuess",
                        "Failed to compute a solution using the default initial "
                        "guess. Attempting using the nominal values in <block:%s>",
                        block->label);
                    flag = jmi_kinsol_invoke_kinsol(block, KIN_LINESEARCH);
                }
                
                if (flag != KIN_SUCCESS) {
                    jmi_log_node(log, logError, "Error", "Could not converge after re-scaling equations in <block: %s>",
                                 block->label);
                }
            }
        }
    }

    /* Write solution back to model just to make sure. In some cases x was not the last evaluations*/    
    block->F(block->problem_data,block->x, NULL, JMI_BLOCK_WRITE_BACK);
    
    /* Get debug information */
    KINGetNumNonlinSolvIters(solver->kin_mem, &nniters);    
     
    /* Store debug information */
    block->nb_iters += nniters;
        
    return flag;
}

int jmi_kinsol_restore_state(jmi_block_solver_t* block) {
    int flag = 0;
    jmi_kinsol_solver_t* solver = block->solver;
    jmi_log_t *log = block->log;
    jmi_log_node_t node={0};
    long int nniters = 0;
    
    flag = block->F(block->problem_data,block->last_accepted_x, NULL, JMI_BLOCK_WRITE_BACK);
    if(flag) {        
        jmi_log_node(log, logError, "ErrorSettingInitialGuess", "<errorCode: %d> returned from <block: %s> "
                     "when setting the initial guess.", flag, block->label);
        return flag;
    }
    
    if((block->callbacks->log_options.log_level >= 6)) {
        node = jmi_log_enter_fmt(block->log, logInfo, "KinsolRestoreState", "Restoring the Kinsol state in <block:%s>", block->label);
        jmi_log_reals(block->log, node, logInfo, "ivs", block->last_accepted_x, block->n);
    }
    
    if (solver->saved_state->J_is_singular_flag) {
        if (solver->saved_state->handling_of_singular_jacobian_flag == JMI_REGULARIZATION) {
            DenseCopy(solver->saved_state->J_modified, solver->JTJ);
        } else if (solver->saved_state->handling_of_singular_jacobian_flag == JMI_MINIMUM_NORM) {
            DenseCopy(solver->saved_state->J_modified, solver->J_sing);
        }
    } else {
            DenseCopy(solver->saved_state->J_modified, solver->J_LU);
    }
    DenseCopy(solver->saved_state->J, block->J);
    
    block->scale_update_time = solver->saved_state->kin_scale_update_time;
    block->force_rescaling        = solver->saved_state->force_rescaling;

    KINGetNumNonlinSolvIters(solver->kin_mem, &nniters);

    solver->force_new_J_flag = solver->saved_state->force_new_J_flag;
    solver->handling_of_singular_jacobian_flag = solver->saved_state->handling_of_singular_jacobian_flag;
    solver->J_is_singular_flag = solver->saved_state->J_is_singular_flag;
    ((struct KINMemRec *)solver->kin_mem)->kin_nnilset = nniters - solver->saved_state->mbset;
    memcpy(N_VGetArrayPointer(block->f_scale), N_VGetArrayPointer(solver->saved_state->kin_f_scale), block->n*sizeof(realtype));
    memcpy(N_VGetArrayPointer(solver->kin_y_scale), N_VGetArrayPointer(solver->saved_state->kin_y_scale), block->n*sizeof(realtype));
    memcpy(solver->lapack_ipiv, solver->saved_state->lapack_ipiv, (block->n+2)*sizeof(int)); 
    
    if((block->callbacks->log_options.log_level >= 6)) {
        jmi_log_fmt(block->log, node, logInfo, "<mbset: %d> <nni: %d> < nnilset: %d>", solver->saved_state->mbset, nniters, &(((struct KINMemRec *)solver->kin_mem)->kin_nnilset));
        jmi_log_ints(block->log, node, logInfo, "handling_singular", &(solver->handling_of_singular_jacobian_flag), 1);
        jmi_log_ints(block->log, node, logInfo, "is_singular", &(block->force_rescaling), 1);
        jmi_log_ints(block->log, node, logInfo, "force_rescaling", &(solver->J_is_singular_flag), 1);
        jmi_log_reals(block->log, node, logInfo, "residual_scaling_update_time", &(block->scale_update_time), 1);
        jmi_log_reals(block->log, node, logInfo, "iv_scaling", N_VGetArrayPointer(solver->kin_y_scale), block->n);
        jmi_log_reals(block->log, node, logInfo, "residual_scaling", N_VGetArrayPointer(block->f_scale), block->n);
        jmi_log_leave(block->log, node);
    }
    
    return flag;
}

int jmi_kinsol_completed_integrator_step(jmi_block_solver_t* block) {
    if(block->n == 1 && 
       block->options->use_Brent_in_1d_flag && 
       jmi_block_solver_use_save_restore_state_behaviour(block)) {
           return jmi_brent_completed_integrator_step(block);
    } else if (jmi_block_solver_use_save_restore_state_behaviour(block)) {
        /* Kinsol specific handling of a completed step */
        int flag;
        jmi_kinsol_solver_t* solver = block->solver;
        jmi_log_node_t node={0};
        long int nniters = 0;
        
        flag = block->F(block->problem_data,block->last_accepted_x,block->res,JMI_BLOCK_INITIALIZE);
        if (flag) {
            jmi_log_node(block->log, logError, "ReadLastIterationVariables",
                         "Failed to read the iteration variables, <errorCode: %d> in <block: %s>", flag, block->label);
            return flag;
        }
        
        if((block->callbacks->log_options.log_level >= 6)) {
            node = jmi_log_enter_fmt(block->log, logInfo, "KinsolSaveState", "Saving the Kinsol state in <block:%s>", block->label);
            jmi_log_reals(block->log, node, logInfo, "ivs", block->last_accepted_x, block->n);
        }
        
        if (solver->J_is_singular_flag) {
            if (solver->handling_of_singular_jacobian_flag == JMI_REGULARIZATION) {
                DenseCopy(solver->JTJ, solver->saved_state->J_modified);
            } else if (solver->handling_of_singular_jacobian_flag == JMI_MINIMUM_NORM) {
                DenseCopy(solver->J_sing, solver->saved_state->J_modified);
            }
        } else {
            DenseCopy(solver->J_LU, solver->saved_state->J_modified);
        }
        DenseCopy(block->J, solver->saved_state->J);
        
        solver->saved_state->kin_scale_update_time = block->scale_update_time;
        solver->saved_state->force_rescaling       = block->force_rescaling;
        solver->saved_state->force_new_J_flag      = solver->force_new_J_flag;
        
        KINGetNumNonlinSolvIters(solver->kin_mem, &nniters);
        
        solver->saved_state->handling_of_singular_jacobian_flag = solver->handling_of_singular_jacobian_flag;
        solver->saved_state->J_is_singular_flag = solver->J_is_singular_flag;
        solver->saved_state->mbset = nniters - ((struct KINMemRec *)solver->kin_mem)->kin_nnilset;
        memcpy(N_VGetArrayPointer(solver->saved_state->kin_f_scale),N_VGetArrayPointer(block->f_scale), block->n*sizeof(realtype));
        memcpy(N_VGetArrayPointer(solver->saved_state->kin_y_scale),N_VGetArrayPointer(solver->kin_y_scale), block->n*sizeof(realtype));
        memcpy(solver->saved_state->lapack_ipiv, solver->lapack_ipiv, (block->n+2)*sizeof(int)); 
        
        if((block->callbacks->log_options.log_level >= 6)) {
            jmi_log_fmt(block->log, node, logInfo, "<mbset: %d> <nni: %d> < nnilset: %d>", solver->saved_state->mbset, nniters, &(((struct KINMemRec *)solver->kin_mem)->kin_nnilset));
            jmi_log_ints(block->log, node, logInfo, "handling_singular", &(solver->handling_of_singular_jacobian_flag), 1);
            jmi_log_ints(block->log, node, logInfo, "is_singular", &(solver->J_is_singular_flag), 1);
            jmi_log_ints(block->log, node, logInfo, "force_rescaling", &(solver->J_is_singular_flag), 1);
            jmi_log_reals(block->log, node, logInfo, "residual_scaling_update_time", &(block->scale_update_time), 1);
            jmi_log_reals(block->log, node, logInfo, "iv_scaling", N_VGetArrayPointer(solver->kin_y_scale), block->n);
            jmi_log_reals(block->log, node, logInfo, "residual_scaling", N_VGetArrayPointer(block->f_scale), block->n);
            jmi_log_leave(block->log, node);
        }
    }
    return 0;
}
