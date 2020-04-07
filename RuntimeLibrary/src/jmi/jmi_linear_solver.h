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

/** \file jmi_linear_solver.h
 *  \brief A linear solver based on LAPACK.
 */

#ifndef _JMI_LINEAR_SOLVER_H
#define _JMI_LINEAR_SOLVER_H

#include "jmi_block_solver.h"
#include "jmi.h"

#define JMI_SWITCHES_AND_NON_REALS_CHANGED -1
#define JMI_SWITCHES_CHANGED               -3

/* Lapack function */
extern void dgetrf_(int* M, int* N, double* A, int* LDA, int* IPIV, int* INFO );
extern void dgetrs_(char* TRANS, int* N, int* NRHS, double* A, int* LDA, int* IPIV, double* B, int* LDB, int* INFO);
extern void dgelss_(int* M, int* N, int* NRHS, double* A, int* LDA, double* B, int* LDB,double* S,double* RCOND,int* RANK,double* WORK,int* LWORK, int* INFO);
extern void dgels_(char* TRANS, int* M, int* N, int* NRHS,double* A,int* LDA, double* B,int* LDB,double* WORK,int* LWORK,int* INFO );
extern int dgeequ_(int *m, int *n, double *a, int * lda, double *r__, double *c__, double *rowcnd, double 
    *colcnd, double *amax, int *info);
extern void dgesdd_(char* JOBZ, int* M, int* N, double* A, int* LDA, 
            double* S, double* U, int* LDU, double* VT, int* LDVT,     
            double* WORK, int* LWORK, int* IWORK, int* INFO);
extern int dlaqge_(int *m, int *n, double *a, int * lda, double *r__, double *c__, double *rowcnd, double 
    *colcnd, double *amax, char *equed);

typedef struct jmi_linear_solver_t jmi_linear_solver_t;
typedef struct jmi_linear_solver_sparse_t jmi_linear_solver_sparse_t;

int jmi_linear_solver_new(jmi_linear_solver_t** solver, jmi_block_solver_t* block);

int jmi_linear_solver_solve(jmi_block_solver_t* block);

int jmi_linear_solver_evaluate_jacobian_factorization(jmi_block_solver_t* block, jmi_real_t* factorization);

void jmi_linear_solver_delete(jmi_block_solver_t* block);

int jmi_linear_solver_sparse_setup(jmi_block_solver_t* block);

void jmi_linear_solver_sparse_delete(jmi_block_solver_t* block);

int jmi_linear_solver_sparse_compute_jacobian(jmi_block_solver_t* block);

int jmi_linear_solver_init_sparse_matrices(jmi_block_solver_t* block);

int jmi_linear_completed_integrator_step(jmi_block_solver_t* block);

/** \brief Computes C (dense) = -A (sparse)*B (sparse) */
/* int jmi_linear_solver_sparse_multiply(const jmi_matrix_sparse_csc_t *A, const jmi_matrix_sparse_csc_t *B, double *C); */

/** \brief Computes C(:,col) (dense) = -A (sparse)*B(:,col) (sparse) */
int jmi_linear_solver_sparse_multiply_column(const jmi_matrix_sparse_csc_t *A, const jmi_matrix_sparse_csc_t *B, jmi_int_t* nz_pattern, jmi_int_t nz_size, jmi_int_t B_col, double *C);

/** \brief Computes C (dense) += A (sparse) */
int jmi_linear_solver_sparse_add_inplace(const jmi_matrix_sparse_csc_t *A, double *C);

/** \brief Solves L (sparse, tringular) x (sparse) = B (sparse) */
int jmi_linear_solver_sparse_backsolve(const jmi_matrix_sparse_csc_t *L, const jmi_matrix_sparse_csc_t *B, jmi_int_t* nz_pattern, jmi_int_t* nz_pattern_sizes, jmi_int_t nz_size, jmi_int_t col, double *work);

struct jmi_linear_solver_sparse_t {
    jmi_matrix_sparse_csc_t *L;
    jmi_matrix_sparse_csc_t *A12;
    jmi_matrix_sparse_csc_t *A21;
    jmi_matrix_sparse_csc_t *A22;
    jmi_matrix_sparse_csc_t *M1;
    jmi_int_t** nz_patterns;
    jmi_int_t** nz_pattern_sizes;
    jmi_int_t** M1_patterns;
    jmi_int_t* nz_sizes;
    jmi_int_t* M1_sizes;
    jmi_int_t* nz_offsets;
    double **work_x;
    jmi_int_t max_threads;
};

struct jmi_linear_solver_t {
    int* ipiv;                     /**< \brief Work vector needed for dgesv */
    jmi_real_t* factorization;      /**< \brief Matrix for storing the Jacobian factorization */
    jmi_real_t* jacobian_temp;         /**< \brief Matrix for storing the Jacobian */
    jmi_real_t* singular_values;  /**< \brief Vector for the singular values of the Jacobian */
    jmi_real_t* singular_vectors; /**< \brief Matrix for the right singular vectors */
    jmi_real_t* jacobian_extension; /**< \brief The extended Jacobian in case of special singular systems */
    jmi_real_t* rhs;                  /**< \brief The right-hand-side vector (possibly extended) */
    int* rhs_extension_index;
    jmi_real_t*  dependent_set;     /**< \brief Matrix collecting information about linearly dependency */
    double* rScale;               /**< \brief Row scaling of the Jacobian matrix */
    double* cScale;               /**< \brief Column scaling of the Jacobian matrix */
    char equed;                    /**< \brief If scaling of the Jacobian matrix used ('N' - no scaling, 'R' - rows, 'C' - cols, 'B' - both */
    int cached_jacobian;          /**< \brief This flag indicates weather the Jacobian needs to be refactorized */
    int singular_jacobian;   /**< \brief Indicates if the Jacobian is singular or not */
    int iwork;
    int update_active_set;          /**< \brief Indicates if active set can be updated or not */
    int n_extra_rows;               /**< \brief Number of extra rows in the extended Jacobian */
    double* zero_vector;
    jmi_real_t* rwork;
    double* dgesdd_work;            /**< \brief Work vector for dgesdd */
    int     dgesdd_lwork;           /**< \brief Work vector for dgesdd */
    int*    dgesdd_iwork;           /**< \brief Work vector for dgesdd */
    jmi_linear_solver_sparse_t *Jsp;
};

#endif /* _JMI_LINEAR_SOLVER_H */
