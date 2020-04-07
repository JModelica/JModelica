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

#include "string.h"

#include "jmi_linear_solver.h"
#include "jmi_block_solver_impl.h"
#include "jmi_log.h"
#include <stdint.h>


#define SMALL 1e-15
#define THRESHOLD 1e-15

int jmi_linear_solver_new(jmi_linear_solver_t** solver_ptr, jmi_block_solver_t* block) {
    jmi_linear_solver_t* solver= (jmi_linear_solver_t*)calloc(1,sizeof(jmi_linear_solver_t));

    int n_x = block->n;
    int i;
    
    if (!solver) return -1;
    
    /* Initialize work vectors.*/
    solver->factorization = (jmi_real_t*)calloc(n_x*n_x,sizeof(jmi_real_t));
    solver->dependent_set = (jmi_real_t*)calloc(n_x*n_x,sizeof(jmi_real_t));
    solver->jacobian_temp = (jmi_real_t*)calloc(2*n_x*n_x,sizeof(jmi_real_t));
    solver->jacobian_extension = (jmi_real_t*)calloc(n_x*n_x,sizeof(jmi_real_t));
    solver->rhs = (jmi_real_t*)calloc(2*n_x,sizeof(jmi_real_t));
    /* solver->rhs_extension_index = (int*)calloc(n_x,sizeof(int)); */
    solver->singular_values = (jmi_real_t*)calloc(2*n_x,sizeof(jmi_real_t));
    solver->singular_vectors = (jmi_real_t*)calloc(n_x*n_x,sizeof(jmi_real_t));
    solver->rScale = (double*)calloc(n_x,sizeof(double));
    solver->cScale = (double*)calloc(n_x,sizeof(double));
    solver->equed = 'N';
    solver->ipiv = (int*)calloc(n_x,sizeof(int));
    solver->update_active_set = 1;
    solver->n_extra_rows = 0;
    
    solver->singular_jacobian = 0;
    solver->iwork = 10*n_x;
    solver->rwork = (double*)calloc(solver->iwork,sizeof(double));
    solver->zero_vector = (double*)calloc(n_x,sizeof(double));
    
    solver->dgesdd_lwork = 10*n_x*n_x+4*n_x;
    solver->dgesdd_work  = (double*)calloc(solver->dgesdd_lwork,sizeof(double));
    solver->dgesdd_iwork = (int*)calloc(8*n_x,sizeof(int)); 

    for (i=0; i<n_x; i++) {
        solver->zero_vector[i] = 0.0;
    }
    
    solver->Jsp = NULL;

    *solver_ptr = solver;
    
    return 0;
}

static int jmi_linear_find_dependent_set(jmi_block_solver_t * block) {
    int i = 0, j = 0, n_x = block->n;
    int nbr_dep = 0, info = 0, rank = 0;
    jmi_real_t test_value = 0; 
    jmi_linear_solver_t* solver = block->solver;
    jmi_log_node_t destnode={0};
    
    /* Reset the dependent sets */
    for (i = 0; i < n_x; i++) { solver->dependent_set[(n_x-1)*n_x+i] = 0; }
    
    memcpy(solver->jacobian_temp, block->J->data, n_x*n_x*sizeof(jmi_real_t));
    /* Compute the null space of A */
    /*
     *       SUBROUTINE DGESDD( JOBZ, M, N, A, LDA, S, U, LDU, VT, LDVT, WORK,
     *                          LWORK, IWORK, INFO )
     */
    dgesdd_("O", &n_x, &n_x, solver->jacobian_temp, &n_x, 
               solver->singular_values, NULL, &n_x, solver->singular_vectors, &n_x,
              solver->dgesdd_work, &solver->dgesdd_lwork, solver->dgesdd_iwork, &info);
              
    if(info != 0) {
        jmi_log_node(block->log, logError, "Error", "DGESDD failed to compute the SVD in <block: %s> with error code <error: %s>", block->label, info);
        return 0;
    }
    
    /* Compute the rank */
    for (i = 0; i < n_x; i++) { if (solver->singular_values[i] > THRESHOLD) { rank += 1; } else { break; } }
    
    /* The matrix seems to be of full rank */
    if (rank >= n_x) {
        return 0;
    }
    
    /* Compute the dependent sets */
    for (i = 0; i < n_x-rank; i++) {
        nbr_dep = 0;
        for (j = 0; j < n_x; j++) {
            test_value = solver->singular_vectors[j*n_x+rank+i];
            if ((test_value >= 0 && test_value > SMALL) || (test_value < 0 && test_value < -SMALL)) {
                solver->dependent_set[i*n_x+nbr_dep] = j;
                nbr_dep++;
            }
        }
        /* An error occurred */
        if (nbr_dep >= n_x) {
            nbr_dep = 0;
        }
        solver->dependent_set[(n_x-1)*n_x+i] = nbr_dep;
    }

    /* Log the dependent sets and the singular vectors.*/
    if((block->callbacks->log_options.log_level >= 5)) {
        destnode = jmi_log_enter_fmt(block->log, logInfo, "LinearSolveDependentSet", 
                                     "Linear solver set calculation invoked for <block:%s>", block->label);
        jmi_log_real_matrix(block->log, destnode, logInfo, "DependentSet", solver->dependent_set, block->n, block->n);
        jmi_log_real_matrix(block->log, destnode, logInfo, "SingularVectors", solver->singular_vectors, block->n, block->n);
        jmi_log_leave(block->log, destnode);
    }
    
    return 0;
}

static int jmi_linear_check_active_variable(jmi_block_solver_t * block, int set, int index) {
    int active = 0, flag = 0;
    jmi_real_t *x  = block->x;
    jmi_real_t val = x[index];
    jmi_real_t eps = ((jmi_block_solver_options_t*)(block->options))->events_epsilon;
    
    x[index] = val+eps+THRESHOLD;
    flag = block->check_discrete_variables_change(block->problem_data, x);
    if (flag == JMI_SWITCHES_CHANGED || 
        flag == JMI_SWITCHES_AND_NON_REALS_CHANGED || 
        flag == JMI_SWITCHES_AND_DISCRETE_REALS_CHANGED ||
        flag == JMI_SWITCHES_AND_DISCRETE_REALS_AND_NON_REALS_CHANGED) { active = 1; }
    
    if (!active) {
        x[index] = val-eps-THRESHOLD;
        flag = block->check_discrete_variables_change(block->problem_data, x);
        if (flag == JMI_SWITCHES_CHANGED || 
            flag == JMI_SWITCHES_AND_NON_REALS_CHANGED || 
            flag == JMI_SWITCHES_AND_DISCRETE_REALS_CHANGED || 
            flag == JMI_SWITCHES_AND_DISCRETE_REALS_AND_NON_REALS_CHANGED) { active = 1; }
    }
    
    x[index] = val;
    
    if (active) {
        jmi_log_node(block->log, logInfo, "ActiveVariable", "Found active iteration variable, number <iv: %I> in <set: %I> from <block: %s>", 
             index, set, block->label);
    }
    
    return active;
}

static int jmi_linear_find_active_set(jmi_block_solver_t * block ) {
    int i = 0, j = 0, k = 0, set = 0, n_x = block->n;
    int active = 0, nbr_active = 0, n_ux = 0;
    jmi_linear_solver_t* solver = block->solver;
    jmi_log_node_t destnode={0};
    
    if(block->check_discrete_variables_change && solver->update_active_set == 1) {
        
        for (i = 0; i < n_x-1; i++) {
            set = (int)solver->dependent_set[(n_x-1)*n_x+i];
            nbr_active = 0;
            
            if (set > 0) {
                for (k = 0; k < set; k++) {
                    active = jmi_linear_check_active_variable(block, i, (int)solver->dependent_set[i*n_x+k]);
                    
                    if (active) {
                        /* solver->rhs_extension_index[n_ux] = (int)solver->dependent_set[i*n_x+k]; */
                        for (j = 0; j < n_x; j++) {
                            if (j == (int)solver->dependent_set[i*n_x+k]) {
                                solver->jacobian_extension[j*n_x+n_ux] = 1.0;
                            } else {
                                solver->jacobian_extension[j*n_x+n_ux] = 0.0;
                            }
                        }
                        nbr_active++; 
                        n_ux++; 
                    }
                }
                if (nbr_active == set) { n_ux = n_ux-set; };
            }
        }
        solver->n_extra_rows = n_ux;
    }
    
    if (solver->n_extra_rows > 0) {
        for (j = 0; j < n_x; j++) {
            memcpy(&solver->jacobian_temp[j*(n_x+solver->n_extra_rows)], &block->J->data[j*n_x], n_x*sizeof(jmi_real_t));
            memcpy(&solver->jacobian_temp[j*(n_x+solver->n_extra_rows)+n_x], &solver->jacobian_extension[j*n_x], solver->n_extra_rows*sizeof(jmi_real_t));
        }
        for (j = 0; j < solver->n_extra_rows; j++) { solver->rhs[n_x+j] = 0.0; };
    }

    /* Log the jacobian.*/
    if((block->callbacks->log_options.log_level >= 5) && solver->n_extra_rows > 0) {
        destnode = jmi_log_enter_fmt(block->log, logInfo, "LinearSolveDependentSet", 
                                     "Linear solver set calculation invoked for <block:%s>", block->label);
        jmi_log_real_matrix(block->log, destnode, logInfo, "ExtendedJacobian", solver->jacobian_temp, block->n+solver->n_extra_rows, block->n);
        jmi_log_reals(block->log, destnode, logInfo, "ExtendedRightHandSide", solver->rhs, block->n+solver->n_extra_rows);
        jmi_log_leave(block->log, destnode);
    }
    
    solver->update_active_set = 0;
    
    return n_x+solver->n_extra_rows;
}

static int jmi_linear_solver_employ_variable_scaling(jmi_block_solver_t *block, jmi_real_t* J) {
    if(block->options->iteration_variable_scaling_mode) {
        /* Scale Jacobian based on nominal values.*/
        
        /* jmi_matrix_diagonal_mul(J, block->nominal, block->n); */
        
        int i, j, n_x = block->n;
        
        
        for (i = 0; i < n_x; i++){
            for (j = 0; j < n_x; j++) {
                J[j*block->n + i] *= block->nominal[j];
            }
        }
    }
    return 0;
}

static int jmi_linear_solver_rescale_variables(jmi_block_solver_t *block, jmi_real_t* x) {
    if(block->options->iteration_variable_scaling_mode) {
        /* Rescale variables based on nominal values.*/
        /* jmi_vector_mul(x, block->nominal,  block->n); */
        
        int i, n_x = block->n;
        
        for (i = 0; i < n_x; i++){
            x[i] = block->nominal[i]*x[i];
        }
    }
    return 0;
}


int jmi_linear_solver_solve(jmi_block_solver_t * block){
    int n_x = block->n;
    int iwork;
    int rank;
    double rcond;
    int info;
    int i;
    jmi_log_node_t destnode={0};

    char trans;
    jmi_linear_solver_t* solver = block->solver;
    iwork = solver->iwork;
    
    /* If there are no equations, evaluate and return. */
    if (n_x == 0) { 
        info = block->F(block->problem_data,solver->zero_vector, solver->rhs, JMI_BLOCK_EVALUATE);
        return 0; 
    }
    
    /* If needed, re-evaluate jacobian. */
    if (solver->cached_jacobian != 1) {
        int j = 0;
          /*
             TODO: this code should be merged with the code used in kinsol interface module.
             A regularization strategy for simple cases singular jac should be introduced.
          */
        if (block->Jacobian_structure) { 
            if(block->init) {  
                info = jmi_linear_solver_sparse_setup(block);  
                if (info) { 
                    jmi_log_node(block->log, logError, "JacobianSparseSetup", "Failed to setup the sparse Jacobian for <block: %s>",  
                            block->label); 
                    return -1; 
                } 
            } 
            info = jmi_linear_solver_sparse_compute_jacobian(block); 
        } else  { 
            info = block->F(block->problem_data,NULL,block->J->data,JMI_BLOCK_EVALUATE_JACOBIAN); 
        } 
        
        jmi_linear_solver_employ_variable_scaling(block, block->J->data);
        
        memcpy(solver->factorization, block->J->data, n_x*n_x*sizeof(jmi_real_t));
        if(info) {
            if(block->init) {
                jmi_log_node(block->log, logError, "ErrJac", "Failed in Jacobian calculation for <block: %s>", 
                             block->label);
            }
            else {
                jmi_log_node(block->log, logWarning, "WarnJac", "Failed in Jacobian calculation for <block: %s>", 
                             block->label);
            }
            return -1;
        }

        if((n_x>1)  && block->options->use_jacobian_equilibration_flag) {
            double rowcnd, colcnd, amax;
            dgeequ_(&n_x, &n_x, solver->factorization, &n_x, solver->rScale, solver->cScale, 
                    &rowcnd, &colcnd, &amax, &info);
            if(info == 0) {
                dlaqge_(&n_x, &n_x, solver->factorization, &n_x, solver->rScale, solver->cScale, 
                        &rowcnd, &colcnd, &amax, &solver->equed);
            }
            else
                solver->equed = 'N';
        }
        
        /*Check the Jacobian for INF and NANs */
        for (i = 0; i < n_x; i++) {
            for (j = 0; j < n_x; j++) {
                /* Unrecoverable error*/
                if ( block->J->data[i*n_x+j] - block->J->data[i*n_x+j] != 0) {
                    jmi_log_node(block->log, logError, "NaNOutput", "Not a number in the Jacobian <row: %I> <col: %I> from <block: %s>", 
                            i,j, block->label);
                    return -1;
                }
            }
        }
    }

    /* Log the jacobian.*/
    if((block->callbacks->log_options.log_level >= 5)) {
        destnode = jmi_log_enter_fmt(block->log, logInfo, "LinearSolve", 
                                     "Linear solver invoked for <block:%s>", block->label);
        jmi_log_reals(block->log, destnode, logInfo, "ivs", block->x, block->n);
        jmi_log_real_matrix(block->log, destnode, logInfo, "A", block->J->data, block->n, block->n);
    }

    /*  If jacobian is reevaluated then factorize Jacobian. */
    if (solver->cached_jacobian != 1) {
        /* Call 
        *  DGETRF computes an LU factorization of a general M-by-N matrix A
        *  using partial pivoting with row interchanges.
        * */
        dgetrf_(&n_x, &n_x, solver->factorization, &n_x, solver->ipiv, &info);
        if(info) {
            jmi_log_node(block->log, logWarning, "SingularJacobian", "Singular Jacobian detected for <block: %s> at <t: %f>", 
                         block->label, block->cur_time);
                         
            solver->singular_jacobian = 1;
            
            jmi_linear_find_dependent_set(block);
            solver->update_active_set = 1;
            
        }else{
            solver->singular_jacobian = 0;
        }

        if (block->jacobian_variability == JMI_CONSTANT_VARIABILITY ||
             block->jacobian_variability == JMI_PARAMETER_VARIABILITY) {
            solver->cached_jacobian = 1;
        }

    }
    
    /* Compute right hand side at initial x*/ 
    if (solver->singular_jacobian == 1) {
        /* In case of singular system, use the last point in the calculation of the b-vector */
        if (jmi_block_solver_use_save_restore_state_behaviour(block)) {
            for (i = 0; i < block->n; i++) { block->x[i] = block->last_accepted_x[i]; }
        }
        info = block->F(block->problem_data,block->x, solver->rhs, JMI_BLOCK_EVALUATE);
    } else {
        /* Ignore bounds when calculating RHS with zero vector*/
        int current_enforce_bounds_flag = block->options->enforce_bounds_flag;;
        block->options->enforce_bounds_flag = FALSE;
        info = block->F(block->problem_data,solver->zero_vector, solver->rhs, JMI_BLOCK_EVALUATE);
        block->options->enforce_bounds_flag = current_enforce_bounds_flag;
    }
    if(info) {
        /* Close the LinearSolve log node and generate the Error/Warning node and return. */
        if((block->callbacks->log_options.log_level >= 5)) jmi_log_leave(block->log, destnode);

        if(block->init) {
            jmi_log_node(block->log, logError, "ErrEvalEq", "Failed to evaluate equations in <block: %s>", block->label);
        }
        else {
            jmi_log_node(block->log, logWarning, "WarnEvalEq", "Failed to evaluate equations in <block: %s>", block->label);
        }
        return -1;
    }
    
    /*Check the right hand side for INF and NANs */
    for (i = 0; i < n_x; i++) {
        /* Unrecoverable error*/
        if ( solver->rhs[i] - solver->rhs[i] != 0) {
            /* Close the LinearSolve log node and generate the Error/Warning node and return. */
            if((block->callbacks->log_options.log_level >= 5)) jmi_log_leave(block->log, destnode);
            
            jmi_log_node(block->log, logError, "NaNOutput", "Not a number in block <rhs: %I> from <block: %s>", 
                         i, block->label);
            return -1;
        }
    }
    
    if((solver->equed == 'R') || (solver->equed == 'B')) {
        for (i=0;i<n_x;i++) {
            solver->rhs[i] *= solver->rScale[i];
        }
    }
    
    if((block->callbacks->log_options.log_level >= 5)) {
        jmi_log_reals(block->log, destnode, logInfo, "b", solver->rhs, block->n);     
    }
 
    /* Do back-solve */
    trans = 'N'; /* No transposition */
    i = 1; /* One rhs to solve for */
      
    if (solver->singular_jacobian == 1){
        /*
         *   DGELSS - compute the minimum norm solution to  a real 
         *   linear least squares problem
         * 
         * SUBROUTINE DGELSS( M, N, NRHS, A, LDA, B, LDB, S, RCOND, RANK,WORK, LWORK, INFO )
         *
         */
        int n_rows = n_x;
        rcond = -1.0;
        
        /* Find the active set */
        n_rows = jmi_linear_find_active_set(block);
        
        if (n_rows > n_x) {
            dgelss_(&n_rows, &n_x, &i, solver->jacobian_temp, &n_rows, solver->rhs, &n_rows ,solver->singular_values, &rcond, &rank, solver->rwork, &iwork, &info);
        } else {
            memcpy(solver->jacobian_temp, block->J->data, n_x*n_x*sizeof(jmi_real_t));
            dgelss_(&n_x, &n_x, &i, solver->jacobian_temp, &n_x, solver->rhs, &n_x ,solver->singular_values, &rcond, &rank, solver->rwork, &iwork, &info);
        }
        
        if(info != 0) {
            jmi_log_node(block->log, logError, "Error", "DGELSS failed to solve the linear system in <block: %s> with error code <error: %s>", block->label, info);
            return -1;
        }
        
    }else{
        /*
         * DGETRS solves a system of linear equations
         *     A * X = B  or  A' * X = B
         *  with a general N-by-N matrix A using the LU factorization computed
         *  by DGETRF.
         */
        dgetrs_(&trans, &n_x, &i, solver->factorization, &n_x, solver->ipiv, solver->rhs, &n_x, &info);
        
        /* After solving a consistent system, allow for update of the active set */
        solver->update_active_set = 1;
    }
    
    if(info) {
        /* can only be "bad param" -> internal error */
        jmi_log_node(block->log, logError, "Error", "Internal error when solving <block: %s> with <error_code: %s>", block->label, info);
        return -1;
    }
    
    jmi_linear_solver_rescale_variables(block, solver->rhs);
    
    if((solver->equed == 'C') || (solver->equed == 'B')) {
        if (solver->singular_jacobian == 1) {
            for (i=0;i<n_x;i++) {
                 block->x[i] = block->x[i] + solver->rhs[i] * solver->cScale[i];
            }

        } else {
            for (i=0;i<n_x;i++) {
                 block->x[i] = solver->rhs[i] * solver->cScale[i];
            }
        }
    } else {
        if (solver->singular_jacobian == 1) {
            for (i=0;i<n_x;i++) {
                block->x[i] = block->x[i] + solver->rhs[i];
            }
        } else {
            for (i=0;i<n_x;i++) {
                block->x[i] = solver->rhs[i];
            }
        }
    }
    
    if((block->callbacks->log_options.log_level >= 5)) {
        jmi_log_reals(block->log, destnode, logInfo, "x", solver->rhs, block->n);
        jmi_log_reals(block->log, destnode, logInfo, "ivs", block->x, block->n);
        jmi_log_leave(block->log, destnode);
    }
    
    /* Write solution back to model */
    /* JMI_BLOCK_EVALUATE is used since it is needed for torn linear equation blocks! Might be changed in the future! */
    block->F(block->problem_data,block->x, solver->rhs, JMI_BLOCK_EVALUATE);

    /* Check if the calculated solution from minimum norm is a valid solution to the original problem */
    if(solver->singular_jacobian==1) {
        jmi_real_t scaled_max_norm;
        int ef = 0;
        jmi_update_f_scale(block);
        
        ef = jmi_scaled_vector_norm(solver->rhs, N_VGetArrayPointer(block->f_scale), block->n, JMI_NORM_MAX, &scaled_max_norm);
        if (ef == -1) {
            jmi_log_node(block->log, logError, "NormFailure", "Failed to compute the scaled residual norm to the linear system in <block: %s>", block->label);
        }
        
        if(scaled_max_norm <= block->options->res_tol) {
            if(block->callbacks->log_options.log_level >= 5){
                jmi_log_node(block->log, logInfo, "Info", "Successfully calculated the minimum norm solution to the linear system in <block: %s>", block->label);
            }
        } else {
            info = -1;
            destnode = jmi_log_enter_fmt(block->log, logError, "UnsolveableLinearSystem", "Failed to calculate a valid minimum norm solution to the linear system in <block: %s> at <t: %f>", block->label, block->cur_time);
            jmi_log_reals(block->log, destnode, logError, "residuals", solver->rhs, block->n);
            jmi_log_reals(block->log, destnode, logError, "scaled_max_norm", &(scaled_max_norm), 1);
            jmi_log_reals(block->log, destnode, logError, "tolerance", &(block->options->res_tol), 1);
            jmi_log_leave(block->log, destnode);
        }

    }

    return info==0 ? 0: -1;
}

int jmi_linear_solver_csc_to_dense(const jmi_matrix_sparse_csc_t *A, double *x) {
    int col, p;

    for (col = 0 ; col < A->nbr_cols ; col++) {
        for (p = A->col_ptrs[col] ; p < A->col_ptrs[col+1] ; p++) {
            x[A->nbr_cols*col+A->row_ind[p]] = A->x[p];
        }
    }
    return 0;
}


static int jmi_linear_solver_sparse_compute_sparsity_backsolve_dfs(const jmi_matrix_sparse_csc_t *L, jmi_int_t *nz_pattern, jmi_int_t col, jmi_int_t* work, jmi_int_t* nnz) {
    jmi_int_t L_p;
    nz_pattern[nnz[0]] = col;
    work[col] = col;
    nnz[0] = nnz[0] + 1;
    
    for (L_p = L->col_ptrs[col]; L_p < L->col_ptrs[col+1]; L_p++) {
        if (work[L->row_ind[L_p]] == -1) {
            jmi_linear_solver_sparse_compute_sparsity_backsolve_dfs(L, nz_pattern, L->row_ind[L_p], work, nnz);
        }
    }
    return 0;
}

/* L X = B */
static int jmi_linear_solver_sparse_compute_sparsity_backsolve(const jmi_matrix_sparse_csc_t *L, const jmi_matrix_sparse_csc_t *B, jmi_int_t* nz_pattern, jmi_int_t col, jmi_int_t* work) {
    jmi_int_t B_p;
    jmi_int_t nnz = 0;
    
    memset(work, -1, sizeof(jmi_int_t)*B->nbr_rows);
    
    for (B_p = B->col_ptrs[col]; B_p < B->col_ptrs[col+1]; B_p++) {
        if (work[B->row_ind[B_p]] == -1) {
            jmi_linear_solver_sparse_compute_sparsity_backsolve_dfs(L, nz_pattern, B->row_ind[B_p], work, &nnz);
        }
    }
    nz_pattern[L->nbr_cols] = nnz;
    
    return 0;
}

/* L (sparse, tringular) x (sparse) = B (sparse) */
int jmi_linear_solver_sparse_backsolve(const jmi_matrix_sparse_csc_t *L, const jmi_matrix_sparse_csc_t *B, jmi_int_t* nz_pattern, jmi_int_t* nz_pattern_sizes, jmi_int_t nz_size, jmi_int_t col, double *work) {
    jmi_int_t i, B_p;

    /* Copy the right-hand side into the work vector */
    for (B_p = B->col_ptrs[col]; B_p < B->col_ptrs[col+1]; B_p++) {
        work[B->row_ind[B_p]] = B->x[B_p];
    }
    
    /* Perform the backsolve */
    for (i = 0; i < nz_size; i++) {
        jmi_int_t col_L = nz_pattern[i];
        jmi_int_t L_p   = L->col_ptrs[col_L];
        jmi_int_t odd_internal_loop = nz_pattern_sizes[i];
        double val;
        
        /* This is a multiplication due to that diag(L) has been previously
        been replaced by 1/diag(L) */
        work[col_L] *= L->x[L_p++];
        val = work[col_L];
        
        if (odd_internal_loop) { /* The number of internal loops are odd */
            work[L->row_ind[L_p]] -= L->x[L_p]*val;
            L_p = L_p + 1 ;
        }
        
        /* Increment loop by 2 for performance */
        for (; L_p < L->col_ptrs[col_L+1]; L_p += 2) {
            work[L->row_ind[L_p]]   -= L->x[L_p]*val;
            work[L->row_ind[L_p+1]] -= L->x[L_p+1]*val;
        }
    }
    
    return 0;
}

/* C (dense) += A (sparse) */
int jmi_linear_solver_sparse_add_inplace(const jmi_matrix_sparse_csc_t *A, double *C) {
    jmi_int_t col, p;

    for (col = 0 ; col < A->nbr_cols ; col++) {
        jmi_int_t col_ind = A->nbr_cols*col;
        for (p = A->col_ptrs[col]; p < A->col_ptrs[col+1]; p++) {
            C[col_ind+A->row_ind[p]] += A->x[p];
        }
    }
    return 0;
}

/* C (dense) = -A (sparse)*B (sparse) */
/*
int jmi_linear_solver_sparse_multiply(const jmi_matrix_sparse_csc_t *A, const jmi_matrix_sparse_csc_t *B, double *C) {
    jmi_int_t B_col;

    for (B_col = 0; B_col < B->nbr_cols; B_col++) {
        jmi_linear_solver_sparse_multiply_column(A, B, B_col, C);
    }
    
    return 0;
}
*/

/* C (dense) = -A (sparse)*B(:,col) (sparse) */
int jmi_linear_solver_sparse_multiply_column(const jmi_matrix_sparse_csc_t *A, const jmi_matrix_sparse_csc_t *B, jmi_int_t* nz_pattern, jmi_int_t nz_size, jmi_int_t B_col, double *C) {
    jmi_int_t i, p;
    jmi_int_t col_ind = A->nbr_rows*B_col;
    
    for (i = 0; i < nz_size; i++) {
        jmi_int_t B_p = nz_pattern[i];
        double val = B->x[B_p];
        jmi_int_t col = B->row_ind[B_p];

        for (p = A->col_ptrs[col]; p < A->col_ptrs[col + 1]; p++) {
            C[col_ind + A->row_ind[p]] -= A->x[p] * val;
        }
    }
    return 0;
}

int jmi_linear_solver_sparse_compute_jacobian(jmi_block_solver_t* block) {
    int info = 0;
    jmi_linear_solver_t* solver = block->solver;
    jmi_linear_solver_sparse_t* Jsp = solver->Jsp;

    if(!(block->Jacobian)) {
        jmi_log_node(block->log, logError, "MissingJacobian", "The method to compute the Jacobian is missing in <block: %s>.", block->label);
        return -1;
    }

    if (Jsp->L != NULL) {
        info |= block->Jacobian(block->problem_data,NULL,&(Jsp->L->x),  JMI_BLOCK_JACOBIAN_EVALUATE_L);
        info |= block->Jacobian(block->problem_data,NULL,&(Jsp->A12->x),JMI_BLOCK_JACOBIAN_EVALUATE_A12);
        info |= block->Jacobian(block->problem_data,NULL,&(Jsp->A21->x),JMI_BLOCK_JACOBIAN_EVALUATE_A21);
    }
    info |= block->Jacobian(block->problem_data,NULL,&(Jsp->A22->x),JMI_BLOCK_JACOBIAN_EVALUATE_A22);
    if (info) { 
        jmi_log_node(block->log, logError, "Jacobian", "Failed to evaluate the sparse Jacobian in <block: %s>.", block->label);
        return info; 
    }

    /* A22 - A21L^(-1)A12 */
    /* M1 = L^(-1)A12 */
    /* M2 = A21L^(-1)A12 */
    /* M3 = A22 - A21L^(-1)A12 */
    
    /* Compute L^(-1) A12 */
    if (Jsp->L != NULL ) {
        jmi_int_t col;

        memset(block->J->data, 0, sizeof(double)*block->n*block->n);
        
        {
            jmi_int_t tid = 0;
            double *work;
            work = Jsp->work_x[tid];
            
            /* Perform division once so that multiplication can be used in backsolve (for performance) */
            for (col = 0; col < Jsp->L->nbr_cols; col++) { Jsp->L->x[Jsp->L->col_ptrs[col]] = 1.0/Jsp->L->x[Jsp->L->col_ptrs[col]]; }
            
            for (col = 0; col < Jsp->A12->nbr_cols; col++) {
                jmi_int_t i;
                jmi_int_t offset = Jsp->nz_offsets[col];

                jmi_linear_solver_sparse_backsolve(Jsp->L, Jsp->A12, Jsp->nz_patterns[col], Jsp->nz_pattern_sizes[col], Jsp->nz_sizes[col], col, work);
            
                for (i = 0; i < Jsp->nz_sizes[col]; i++) {
                    Jsp->M1->x[offset+i] = work[Jsp->nz_patterns[col][i]];
                    work[Jsp->nz_patterns[col][i]] = 0.0; /* Reset work vector */
                }

                /* Compute A21L^(-1)A12 */
                jmi_linear_solver_sparse_multiply_column(Jsp->A21, Jsp->M1, Jsp->M1_patterns[col], Jsp->M1_sizes[col], col, block->J->data);
            }
        }
        
        
        /* Compute A22 - A21L^(-1)A12 */
        jmi_linear_solver_sparse_add_inplace(Jsp->A22, block->J->data);
    } else {
        /* Convert back to dense */
        jmi_linear_solver_csc_to_dense(Jsp->A22, block->J->data);
    }

    return info;
}


static int compare( const void* a, const void* b)
{
     jmi_int_t int_a = * ( (jmi_int_t*) a );
     jmi_int_t int_b = * ( (jmi_int_t*) b );

     if ( int_a == int_b ) return 0;
     else if ( int_a < int_b ) return -1;
     else return 1;
}

/* C (dense) = -A (sparse)*B(:,col) (sparse) */
static int jmi_linear_solver_sparse_compute_multiply_patterns(const jmi_matrix_sparse_csc_t *A, const jmi_matrix_sparse_csc_t *B, jmi_int_t B_col, jmi_int_t* nz_patterns, jmi_int_t* sizes) {
    jmi_int_t B_p;
    jmi_int_t i = 0;

    for (B_p = B->col_ptrs[B_col]; B_p < B->col_ptrs[B_col + 1]; B_p++) {
        jmi_int_t col = B->row_ind[B_p];
        
        if (A->col_ptrs[col] != A->col_ptrs[col + 1]) {
            nz_patterns[i] = B_p;
            i++;
        }
    }
    sizes[0] = i;
    
    return 0;
}

int jmi_linear_solver_sparse_setup(jmi_block_solver_t* block) {
    jmi_linear_solver_t* solver = block->solver;
    jmi_linear_solver_sparse_t* Jsp;
    jmi_int_t col, i, j, nzmax = 0;
    int ret;
    
    solver->Jsp = (jmi_linear_solver_sparse_t*)calloc(1, sizeof(jmi_linear_solver_sparse_t));
    solver->Jsp->L = NULL; solver->Jsp->A12 = NULL; solver->Jsp->A21 = NULL; solver->Jsp->A22 = NULL;
    solver->Jsp->M1 = NULL;
    solver->Jsp->work_x = NULL;
    Jsp = solver->Jsp;
    
    ret = jmi_linear_solver_init_sparse_matrices(block);
    if (ret) { return ret; }
    
    /* Check if torn */
    if (Jsp->L != NULL) {
        jmi_int_t *work_nz_pattern;
        jmi_int_t *work;
        jmi_int_t max_dim = Jsp->L->nbr_cols > Jsp->A22->nbr_cols ? Jsp->L->nbr_cols : Jsp->A22->nbr_cols;
        jmi_int_t max_threads = 1;
        
        work_nz_pattern   = (jmi_int_t*)calloc(Jsp->L->nbr_cols+1, sizeof(jmi_int_t));
        work              = (jmi_int_t*)calloc(Jsp->L->nbr_cols, sizeof(jmi_int_t));
        
        Jsp->nz_offsets   = (jmi_int_t*)calloc(Jsp->A12->nbr_cols, sizeof(jmi_int_t));
        Jsp->nz_sizes     = (jmi_int_t*)calloc(Jsp->A12->nbr_cols, sizeof(jmi_int_t));
        Jsp->nz_patterns  = (jmi_int_t**)calloc(Jsp->A12->nbr_cols, sizeof(jmi_int_t*));
        Jsp->nz_pattern_sizes  = (jmi_int_t**)calloc(Jsp->A12->nbr_cols, sizeof(jmi_int_t*));
        Jsp->M1_patterns  = (jmi_int_t**)calloc(Jsp->A12->nbr_cols, sizeof(jmi_int_t*));
        Jsp->M1_sizes     = (jmi_int_t*)calloc(Jsp->A12->nbr_cols, sizeof(jmi_int_t));
        
        /* Allocate work arrays for the different threads */
        Jsp->max_threads = max_threads;
        Jsp->work_x       = (double**)calloc(max_threads, sizeof(double*));
        for (col = 0; col < max_threads; col++) {
            Jsp->work_x[col] = (double*)calloc(max_dim, sizeof(double));
        }

        Jsp->nz_offsets[col] = 0;
    
        /* Compute the sparsity structure of L^(-1) A12 */
        for (col = 0; col < Jsp->A12->nbr_cols; col++) {
            
            jmi_linear_solver_sparse_compute_sparsity_backsolve(Jsp->L, Jsp->A12, work_nz_pattern, col, work);
            qsort(  work_nz_pattern, work_nz_pattern[Jsp->L->nbr_cols], sizeof(jmi_int_t), compare );
            
            Jsp->nz_sizes[col]    = work_nz_pattern[Jsp->L->nbr_cols];
            Jsp->nz_patterns[col] = (jmi_int_t*)calloc(Jsp->nz_sizes[col], sizeof(jmi_int_t));
            Jsp->nz_pattern_sizes[col] = (jmi_int_t*)calloc(Jsp->nz_sizes[col], sizeof(jmi_int_t));
            for (i = 0; i <  Jsp->nz_sizes[col]; i++) { 
                Jsp->nz_patterns[col][i] = work_nz_pattern[i];
                Jsp->nz_pattern_sizes[col][i] = (Jsp->L->col_ptrs[work_nz_pattern[i]+1] - Jsp->L->col_ptrs[work_nz_pattern[i]] - 1) % 2;
            }

            if (col < Jsp->A12->nbr_cols - 1) {
                Jsp->nz_offsets[col+1] = Jsp->nz_offsets[col] + Jsp->nz_sizes[col];
            }
            
            nzmax += Jsp->nz_sizes[col];
        }
        free(work);
    
        Jsp->M1 = jmi_linear_solver_create_sparse_matrix(Jsp->L->nbr_rows, Jsp->A12->nbr_cols, nzmax);
        j = 0;
        for (col = 0; col < Jsp->A12->nbr_cols; col++) {
            Jsp->M1->col_ptrs[col] = j;
            for (i = 0; i < Jsp->nz_sizes[col]; i++) {
                Jsp->M1->row_ind[j] = Jsp->nz_patterns[col][i];
                Jsp->M1->x[j] = 1.0;
                j = j + 1;
            }
        }
        Jsp->M1->col_ptrs[Jsp->A12->nbr_cols] = j;
        
        /* Analyze and store the pattern for the computation A21 * M1 */
        for (col = 0; col < Jsp->M1->nbr_cols; col++) {
            jmi_linear_solver_sparse_compute_multiply_patterns(Jsp->A21, Jsp->M1, col, work_nz_pattern, &(Jsp->M1_sizes[col]));
            Jsp->M1_patterns[col] = (jmi_int_t*)calloc(Jsp->M1_sizes[col], sizeof(jmi_int_t));
            for (i = 0; i < Jsp->M1_sizes[col]; i++) { Jsp->M1_patterns[col][i] = work_nz_pattern[i]; }
        }
        
        free(work_nz_pattern);
        
        /* A22 - A21L^(-1)A12 */
        /* M1 = L^(-1)A12 */        
    } else if (Jsp->A22 == NULL) {
         jmi_log_node(block->log, logError, "JacobianSparsity", "Failed to retrieve the sparsity structure of the Jacobian in <block: %s>.", block->label);
        return -1;
    }
    
    if(block->callbacks->log_options.log_level >= 4) {
        jmi_log_node_t node;
        node = jmi_log_enter_fmt(block->log, logInfo, "LinearSparsity", "Sparsity information in <block:%s>", block->label);
        
        if (Jsp->L != NULL)
            jmi_log_fmt(block->log, node, logInfo, "Torn matrix L <numberOfColumns: %d> <numberOfRows: %d> <nonZeroElements: %d>", Jsp->L->nbr_cols, Jsp->L->nbr_rows, Jsp->L->nnz);
        if (Jsp->A12 != NULL)
            jmi_log_fmt(block->log, node, logInfo, "Torn matrix A12 <numberOfColumns: %d> <numberOfRows: %d> <nonZeroElements: %d>", Jsp->A12->nbr_cols, Jsp->A12->nbr_rows, Jsp->A12->nnz);
        if (Jsp->A21 != NULL)
            jmi_log_fmt(block->log, node, logInfo, "Torn matrix A21 <numberOfColumns: %d> <numberOfRows: %d> <nonZeroElements: %d>", Jsp->A21->nbr_cols, Jsp->A21->nbr_rows, Jsp->A21->nnz);
        if (Jsp->A22 != NULL)
            jmi_log_fmt(block->log, node, logInfo, "Torn matrix A22 <numberOfColumns: %d> <numberOfRows: %d> <nonZeroElements: %d>", Jsp->A22->nbr_cols, Jsp->A22->nbr_rows, Jsp->A22->nnz);
        if (Jsp->M1 != NULL)
            jmi_log_fmt(block->log, node, logInfo, "Torn matrix L^(-1)A12 <numberOfColumns: %d> <numberOfRows: %d> <nonZeroElements: %d>", Jsp->M1->nbr_cols, Jsp->M1->nbr_rows, Jsp->M1->nnz);
        
        jmi_log_leave(block->log, node);
    }

    return 0;
}

void jmi_linear_solver_sparse_delete(jmi_block_solver_t* block) {
    jmi_linear_solver_t* solver = block->solver;
    jmi_linear_solver_sparse_t* Jsp = solver->Jsp;
    
    if (Jsp != NULL) {
        if (Jsp->nz_patterns != NULL) {
            jmi_int_t col;
            for (col = 0; col < Jsp->A12->nbr_cols; col++) {
                free(Jsp->nz_patterns[col]);
            }
            free(Jsp->nz_patterns);
        }
        if (Jsp->nz_pattern_sizes != NULL) {
            jmi_int_t col;
            for (col = 0; col < Jsp->A12->nbr_cols; col++) {
                free(Jsp->nz_pattern_sizes[col]);
            }
            free(Jsp->nz_pattern_sizes);
        }
        if (Jsp->M1_patterns != NULL) {
            jmi_int_t col;
            for (col = 0; col < Jsp->A12->nbr_cols; col++) {
                free(Jsp->M1_patterns[col]);
            }
            free(Jsp->M1_patterns);
        }
        if (Jsp->nz_sizes != NULL) { free(Jsp->nz_sizes); }
        if (Jsp->nz_offsets != NULL) { free(Jsp->nz_offsets); }
        if (Jsp->M1_sizes != NULL) { free(Jsp->M1_sizes); }
        if (Jsp->work_x != NULL)    { 
            int i;
            for (i = 0; i < Jsp->max_threads; i++) {
                if (Jsp->work_x[i] != NULL) { free(Jsp->work_x[i]); }
            }
            free(Jsp->work_x); 
        }

        if (Jsp->L != NULL)   { jmi_linear_solver_delete_sparse_matrix(Jsp->L);   }
        if (Jsp->A12 != NULL) { jmi_linear_solver_delete_sparse_matrix(Jsp->A12); }
        if (Jsp->A21 != NULL) { jmi_linear_solver_delete_sparse_matrix(Jsp->A21); }
        if (Jsp->A22 != NULL) { jmi_linear_solver_delete_sparse_matrix(Jsp->A22); }
        if (Jsp->M1 != NULL)  { jmi_linear_solver_delete_sparse_matrix(Jsp->M1);  }
        free(Jsp);
    }
}

int jmi_linear_solver_init_sparse_matrices(jmi_block_solver_t* block) {
    int info = 0;
    jmi_linear_solver_t* solver = block->solver;
    jmi_linear_solver_sparse_t* Jsp = solver->Jsp;
    int dim[3];
    int *p = &dim[0];

    if (!(block->Jacobian_structure)) {
        jmi_log_node(block->log, logError, "MissingJacobianSparsity", "The method to compute the Jacobian structure is missing in <block: %s>.", block->label);
        return -1;
    }

    info = block->Jacobian_structure(block->problem_data,NULL, &p,  JMI_BLOCK_JACOBIAN_L_DIMENSIONS);
    if (info) {
        jmi_log_node(block->log, logError, "JacobianSparsity", "The method to retrieve the Jacobian dimensions (for L) in <block: %s> failed.", block->label);
        return -1;
    }
    
    Jsp->L = jmi_linear_solver_create_sparse_matrix(dim[2], dim[1], dim[0]);
    info = block->Jacobian_structure(block->problem_data,NULL, &(Jsp->L->col_ptrs),  JMI_BLOCK_JACOBIAN_L_COLPTR);
    if (info) {
        jmi_log_node(block->log, logError, "JacobianSparsity", "The method to retrieve the Jacobian column pointers (for L) in <block: %s> failed.", block->label);
        return -1;
    }
    info = block->Jacobian_structure(block->problem_data,NULL, &(Jsp->L->row_ind),  JMI_BLOCK_JACOBIAN_L_ROWIND);
    if (info) {
        jmi_log_node(block->log, logError, "JacobianSparsity", "The method to retrieve the Jacobian row indices (for L) in <block: %s> failed.", block->label);
        return -1;
    }

    info = block->Jacobian_structure(block->problem_data,NULL, &p,  JMI_BLOCK_JACOBIAN_A12_DIMENSIONS);
    if (info) {
        jmi_log_node(block->log, logError, "JacobianSparsity", "The method to retrieve the Jacobian dimensions (for A12) in <block: %s> failed.", block->label);
        return -1;
    }
    
    Jsp->A12 = jmi_linear_solver_create_sparse_matrix(dim[2], dim[1], dim[0]);
    info = block->Jacobian_structure(block->problem_data,NULL, &(Jsp->A12->col_ptrs),  JMI_BLOCK_JACOBIAN_A12_COLPTR);
    if (info) {
        jmi_log_node(block->log, logError, "JacobianSparsity", "The method to retrieve the Jacobian column pointers (for A12) in <block: %s> failed.", block->label);
        return -1;
    }
    info = block->Jacobian_structure(block->problem_data,NULL, &(Jsp->A12->row_ind),  JMI_BLOCK_JACOBIAN_A12_ROWIND);
    if (info) {
        jmi_log_node(block->log, logError, "JacobianSparsity", "The method to retrieve the Jacobian row indices (for A12) in <block: %s> failed.", block->label);
        return -1;
    }
    
    info = block->Jacobian_structure(block->problem_data,NULL, &p,  JMI_BLOCK_JACOBIAN_A21_DIMENSIONS);
    if (info) {
        jmi_log_node(block->log, logError, "JacobianSparsity", "The method to retrieve the Jacobian dimensions (for A21) in <block: %s> failed.", block->label);
        return -1;
    }
    
    Jsp->A21 = jmi_linear_solver_create_sparse_matrix(dim[2], dim[1], dim[0]);
    info = block->Jacobian_structure(block->problem_data,NULL, &(Jsp->A21->col_ptrs),  JMI_BLOCK_JACOBIAN_A21_COLPTR);
    if (info) {
        jmi_log_node(block->log, logError, "JacobianSparsity", "The method to retrieve the Jacobian column pointers (for A21) in <block: %s> failed.", block->label);
        return -1;
    }
    info = block->Jacobian_structure(block->problem_data,NULL, &(Jsp->A21->row_ind),  JMI_BLOCK_JACOBIAN_A21_ROWIND);
    if (info) {
        jmi_log_node(block->log, logError, "JacobianSparsity", "The method to retrieve the Jacobian row indices (for A21) in <block: %s> failed.", block->label);
        return -1;
    }
    
    info = block->Jacobian_structure(block->problem_data,NULL, &p,  JMI_BLOCK_JACOBIAN_A22_DIMENSIONS);
    if (info) {
        jmi_log_node(block->log, logError, "JacobianSparsity", "The method to retrieve the Jacobian dimensions (for A22) in <block: %s> failed.", block->label);
        return -1;
    }
    
    Jsp->A22 = jmi_linear_solver_create_sparse_matrix(dim[2], dim[1], dim[0]);
    info = block->Jacobian_structure(block->problem_data,NULL, &(Jsp->A22->col_ptrs),  JMI_BLOCK_JACOBIAN_A22_COLPTR);
    if (info) {
        jmi_log_node(block->log, logError, "JacobianSparsity", "The method to retrieve the Jacobian column pointers (for A22) in <block: %s> failed.", block->label);
        return -1;
    }
    info = block->Jacobian_structure(block->problem_data,NULL, &(Jsp->A22->row_ind),  JMI_BLOCK_JACOBIAN_A22_ROWIND);
    if (info) {
        jmi_log_node(block->log, logError, "JacobianSparsity", "The method to retrieve the Jacobian row indices (for A22) in <block: %s> failed.", block->label);
        return -1;
    }
    return info;
}

int jmi_linear_completed_integrator_step(jmi_block_solver_t* block) {
    if (jmi_block_solver_use_save_restore_state_behaviour(block)) {
        int flag;
        
        flag = block->F(block->problem_data,block->last_accepted_x,block->res,JMI_BLOCK_INITIALIZE);
        if (flag) {
            jmi_log_node(block->log, logError, "ReadLastIterationVariables",
                         "Failed to read the iteration variables, <errorCode: %d> in <block: %s>", flag, block->label);
            return flag;
        }
        
        if((block->callbacks->log_options.log_level >= 6)) {
            jmi_log_node_t node;
            node = jmi_log_enter_fmt(block->log, logInfo, "LinearSaveState", "Saving the Linear state in <block:%s>", block->label);
            jmi_log_reals(block->log, node, logInfo, "ivs", block->last_accepted_x, block->n);
            jmi_log_leave(block->log, node);
        }
    }
    return 0;
}

void jmi_linear_solver_delete(jmi_block_solver_t* block) {
    jmi_linear_solver_t* solver = block->solver;
    
    if (block->Jacobian_structure) {
        jmi_linear_solver_sparse_delete(block);
    }
    
    free(solver->ipiv);
    free(solver->factorization);
    free(solver->singular_values);
    free(solver->singular_vectors);
    free(solver->jacobian_extension);
    free(solver->rhs);
    free(solver->jacobian_temp);
    free(solver->dependent_set);
    free(solver->rScale);
    free(solver->cScale);
    free(solver->rwork);
    free(solver->zero_vector);
    free(solver->dgesdd_work);
    free(solver->dgesdd_iwork);
    free(solver);
    block->solver = 0;
}

