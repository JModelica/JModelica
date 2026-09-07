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

/** \file jmi_linear_algebra.h
 *  \brief Linear algebra related methods and computational algorithms
 **/

#ifndef _JMI_LINEAR_ALGEBRA_H
#define _JMI_LINEAR_ALGEBRA_H

#include "jmi_types.h"

/* Lapack functions */
extern void dgetrf_(int* M, int* N, double* A, int* LDA, int* IPIV, int* INFO );
extern void dgetrs_(char* TRANS, int* N, int* NRHS, double* A, int* LDA, int* IPIV, double* B, int* LDB, int* INFO);
extern void dgecon_(char *NORM, int *N, double *A, int *LDA, double *anorm, double *rcond, double *work, int *iwork, int *INFO);
extern double dlange_(char *NORM, int *M, int *N, double *A, int *LDA, double *WORK);

/* Blas functions */
extern void dger_(int* M, int* N, double* ALPHA, double* X, int* INCX, double* Y,int* INCY,double* A, int* LDA);
extern void dgemv_(char* TRANS, int* M, int* N, double* ALPHA, double* A, int* LDA, double* X, int* INCX, double* BETA, double* Y, int* INCY);
extern void daxpy_(int* N,double* DA,double* DX,int* INCX,double* DY, int* INCY);
extern double ddot_(int* N, double* DX, int* INCX, double* Y, int* INCY);
/* extern int idamax_(int *N, double* X, int *INC); */
extern double dnrm2_(int* N, double* X, int *INC);

/**
 * \brief Computes the weighted residual mean square
 *
 * sum( (w_i*x_i)^2 )^0.5 / N.
 *
 * @param jmi_real_t* A real pointer to the weights.
 * @param jmi_real_t* A pointer to values.
 * @param jmi_int_t The number of elements.
 * @return The WRMS.
 */
jmi_real_t jmi_linear_algebra_wrms(jmi_real_t* weights, jmi_real_t* x, jmi_int_t N);

/**
 * \brief Computes y:= ax + y
 *
 * @param jmi_real_t A real constant a.
 * @param jmi_real_t* A real pointer to the x vector.
 * @param jmi_real_t* A real pointer to the y vector.
 * @param jmi_int_t The number of elements.
 */
void jmi_linear_algebra_daxpy(jmi_real_t a, jmi_real_t* x, jmi_real_t* y, jmi_int_t N);

/**
 * \brief Computes the dot product, x^T y
 *
 * @param jmi_real_t* A real pointer to the x vector.
 * @param jmi_real_t* A real pointer to the y vector.
 * @param jmi_int_t The number of elements.
 * @return The dot product.
 */
jmi_real_t jmi_linear_algebra_ddot(jmi_real_t* x, jmi_real_t* y, jmi_int_t N);

/**
 * \brief Computes the matrix-vector operation, y := alpha*A*x + beta*y
 *
 * @param jmi_real_t A real constant a.
 * @param jmi_real_t* A real pointer to the matrix A.
 * @param jmi_real_t* A real pointer to the x vector.
 * @param jmi_real_t A real constant b.
 * @param jmi_real_t* A real pointer to the y vector.
 * @param jmi_int_t The number of elements.
 * @param jmi_int_t Boolean flag indicating if matrix A should be transposed.
 * @return The dot product.
 */
void jmi_linear_algebra_dgemv(jmi_real_t a, jmi_real_t* A, jmi_real_t* x, jmi_real_t b, jmi_real_t* y, jmi_int_t N, jmi_int_t trans);

/**
 * \brief Computes the rank-1 operation, A := alpha*x*y**T + A
 *
 * @param jmi_real_t A real constant a.
 * @param jmi_real_t* A real pointer to the x vector.
 * @param jmi_real_t* A real pointer to the y vector.
 * @param jmi_real_t* A real pointer to the matrix A.
 * @param jmi_int_t The number of elements.
 * @return The dot product.
 */
void jmi_linear_algebra_dger(jmi_real_t a, jmi_real_t* x, jmi_real_t *y, jmi_real_t *A, jmi_int_t N);

/**
 * \brief Computes z:= ax + by
 *
 * @param jmi_real_t A real constant a.
 * @param jmi_real_t* A real pointer to the x vector.
 * @param jmi_real_t A real constant b.
 * @param jmi_real_t* A real pointer to the y vector.
 * @param jmi_real_t* A real pointer to the z vector (output).
 * @param jmi_int_t The number of elements.
 */
void jmi_linear_algebra_daxpby(jmi_real_t a, jmi_real_t* x, jmi_real_t b, jmi_real_t* y, jmi_real_t* z, jmi_int_t N);
jmi_int_t jmi_linear_algebra_LU_factorize(jmi_real_t* A, jmi_int_t* pivots, jmi_int_t N);
jmi_int_t jmi_linear_algebra_LU_solve(jmi_real_t* LU, jmi_int_t* pivots, jmi_real_t* x, jmi_int_t N);

/**
 * \brief Finds the index of the absolute maximum value of a vector.
 *
 * @param jmi_real_t* A pointer to the vector.
 * @param jmi_int_t The number of elements.
 * @return The index of the maximum absolute value
 */
jmi_int_t jmi_linear_algebra_idamax(jmi_real_t *x, jmi_int_t N);

/**
 * \brief Computes the euclidean norm of a vector.
 *
 * @param jmi_real_t* A pointer to the vector.
 * @param jmi_int_t The number of elements.
 * @return The norm of the vector
 */
jmi_real_t jmi_linear_algebra_norm(jmi_real_t* x, jmi_int_t N);

/**
 * \brief Estimates the reciprocal condition number of a matrix
 *
 * @param jmi_real_t* The LU factorization of a matrix
 * @param jmi_real_t The norm of the matrix
 * @param jmi_int_t The number of elements.
 * @param char The type of the norm.
 */
jmi_real_t jmi_linear_algebra_dgecon(jmi_real_t* LU, jmi_real_t A_norm, jmi_int_t N, char norm_type);

/**
 * \brief Computes the norm of a matrix
 *
 * @param jmi_real_t* The matrix
 * @param jmi_int_t The number of elements.
 * @param char The type of the norm.
 */
jmi_real_t jmi_linear_algebra_dlange(jmi_real_t* A, jmi_int_t N, char norm_type);


#endif
