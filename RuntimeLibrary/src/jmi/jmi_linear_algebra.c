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

#include "jmi_linear_algebra.h"

#include <math.h>
#include <stdlib.h>

/* Computes a = sqrt( sum( (wi*xi)^2) / N) */
jmi_real_t jmi_linear_algebra_wrms(jmi_real_t* weights, jmi_real_t* x, jmi_int_t N) {
    jmi_int_t i;
    jmi_real_t sum = 0.0, prod;
    
    for (i = 0; i < N; i++) {
        prod = x[i]*weights[i];
        sum += prod*prod;
    }

    return sqrt(sum/N);
}

jmi_real_t jmi_linear_algebra_norm(jmi_real_t* x, jmi_int_t N) {
    int i = 1;
    
    return dnrm2_(&N, x, &i);
}

jmi_real_t jmi_linear_algebra_dgecon(jmi_real_t* LU, jmi_real_t A_norm, jmi_int_t N, char norm_type) {
    jmi_real_t rcond = 0.0;
    int info = 0;
    jmi_real_t *work = (jmi_real_t*)calloc(4*N, sizeof(jmi_real_t));
    jmi_int_t *iwork = (jmi_int_t*)calloc(4*N, sizeof(jmi_int_t));
    
    dgecon_(&norm_type, &N, LU, &N, &A_norm, &rcond, work, iwork, &info);
    
    free(work);
    free(iwork);
    
    return rcond;
}

/* Computes matrix norms */
jmi_real_t jmi_linear_algebra_dlange(jmi_real_t* A, jmi_int_t N, char norm_type) {
    jmi_real_t *work = 0;
    jmi_real_t norm;
    
    if (norm_type == 'I' || norm_type == 'i') { work = (jmi_real_t*)calloc(N, sizeof(jmi_real_t)); }
    
    norm = dlange_(&norm_type, &N, &N, A, &N, work); 
    
    if (norm_type == 'I' || norm_type == 'i') { free(work); }
    
    return norm;
}

/* Computes y = ax + y */
void jmi_linear_algebra_daxpy(jmi_real_t a, jmi_real_t* x, jmi_real_t* y, jmi_int_t N) {
    int i = 1;
    
    daxpy_(&N, &a, x, &i, y, &i);
}

/* Computes a = x^T y */
jmi_real_t jmi_linear_algebra_ddot(jmi_real_t* x, jmi_real_t* y, jmi_int_t N) {
    int i = 1;
    
    return ddot_(&N, x, &i, y, &i);
}

/* Computes  y = alpha*A*x + beta*y */
void jmi_linear_algebra_dgemv(jmi_real_t a, jmi_real_t* A, jmi_real_t* x, jmi_real_t b, jmi_real_t* y, jmi_int_t N, jmi_int_t trans) {
    char trans_char = trans? 'T':'N'; /* No transposition */
    int i = 1;
    
    dgemv_(&trans_char, &N, &N, &a, A, &N, x, &i, &b, y, &i);
}

/* Computes A = alpha*x*y**T + A */
void jmi_linear_algebra_dger(jmi_real_t a, jmi_real_t* x, jmi_real_t *y, jmi_real_t *A, jmi_int_t N) {
    int i = 1;
    
    dger_(&N, &N, &a, x, &i, y, &i, A, &N);
}

/* Compytes z = ax + by */
void jmi_linear_algebra_daxpby(jmi_real_t a, jmi_real_t* x, jmi_real_t b, jmi_real_t* y, jmi_real_t* z, jmi_int_t N) {
    int i;
    
    if (a==b) {
        for (i = 0; i < N; i++)
            z[i] = a*(x[i]+y[i]);
    } else if (a==-b) {
        for (i = 0; i < N; i++)
            z[i] = a*(x[i]-y[i]);
    } else {
        for (i = 0; i < N; i++)
            z[i] = a*x[i]+b*y[i];
    }
}

/* Find the index of the max absolute value */
jmi_int_t jmi_linear_algebra_idamax(jmi_real_t *x, jmi_int_t N) {
    int i = 0;
    int j=0;
    jmi_real_t cmax = JMI_ABS(x[i]);
    for(i=1; i<N; i++) {
        if(JMI_ABS(x[i])>cmax) {
            j=i;
        }
    }
    return j;
    /*return idamax_(&N, x, &i) - 1; */ /* Compensate for Fortran indexing */
}

/* Perform LU factorization using Lapack */
jmi_int_t jmi_linear_algebra_LU_factorize(jmi_real_t* A, jmi_int_t* pivots, jmi_int_t N) {
    int info = 0;

    dgetrf_(&N, &N, A, &N, pivots, &info);

    return info;
}

/* Solve with an LU factorized matrix using Lapack */
jmi_int_t jmi_linear_algebra_LU_solve(jmi_real_t* LU, jmi_int_t* pivots, jmi_real_t* x, jmi_int_t N) {
    int info = 0, i = 1;
    char trans = 'N'; /* No transposition */
    
    /* Back-solve and get solution in x */
    dgetrs_(&trans, &N, &i, LU, &N, pivots, x, &N, &info);

    return info;
}
