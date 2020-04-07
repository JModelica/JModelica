/*
    Copyright (C) 2013 Modelon AB

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

/** \file jmi_types.h
    \brief Basic type definitions used in the run-time.
*/    

#ifndef _JMI_TYPES_H
#define _JMI_TYPES_H

#include <stdio.h>

/* Typedef for the doubles used in the interface. */
typedef double jmi_real_t; /*< Typedef for the real number
               < representation used in the Runtime
               < Library. */
typedef int jmi_int_t; /*< Typedef for the integer number
               < representation used in the Runtime
               < Library. */
typedef char* jmi_string_t; /*< Typedef for the string
               < representation used in the external constant
               < evaluation framework. */
typedef void* jmi_extobj_t; /*< Typedef for the external object
               < representation used in the Runtime
               < Library. */
               
/* Forward declaration of jmi structs */
typedef struct jmi_t jmi_t;                                         /**< \brief Forward declaration of struct. */
typedef struct jmi_model_t jmi_model_t;                             /**< \brief Forward declaration of struct. */
typedef struct jmi_func_t jmi_func_t;                               /**< \brief Forward declaration of struct. */
typedef struct jmi_block_residual_t jmi_block_residual_t;           /**< \brief Forward declaration of struct. */
typedef struct jmi_cs_real_input_t jmi_cs_real_input_t;             /**< \brief Forward declaration of struct. */
typedef struct jmi_ode_solver_t jmi_ode_solver_t;                   /**< \brief Forward declaration of struct. */
typedef struct jmi_ode_problem_t jmi_ode_problem_t;                 /**< \brief Forward declaration of struct. */
typedef struct jmi_color_info jmi_color_info;                       /**< \brief Forward declaration of struct. */
typedef struct jmi_simple_color_info_t jmi_simple_color_info_t;     /**< \brief Forward declaration of struct. */
typedef struct jmi_delay_t jmi_delay_t;                             /**< \brief Forward declaration of struct. */
typedef struct jmi_spatialdist_t jmi_spatialdist_t;                 /**< \brief Forward declaration of struct. */
typedef struct jmi_dynamic_state_set_t jmi_dynamic_state_set_t;     /**< \brief Forward declaration of struct. */
typedef struct jmi_modules_t jmi_modules_t;                         /**< \brief Forward declaration of struct. */
typedef struct jmi_module_t jmi_module_t;                           /**< \brief Forward declaration of struct. */
typedef struct jmi_chattering_t jmi_chattering_t;                   /**< \brief Forward declaration of struct. */

#define JMI_MAX(X,Y) ((X) > (Y) ? (X) : (Y))
#define JMI_MIN(X,Y) ((X) < (Y) ? (X) : (Y))
#define JMI_ABS(X)   ((X) < (0) ? (-1*(X)) : (X))
#define JMI_SIGN(X)  ((X) >= (0) ? 1 : (-1))

typedef int BOOL;

#define TRUE  1
#define FALSE 0

typedef enum {
    JMI_REAL,
    JMI_INTEGER,
    JMI_BOOLEAN,
    JMI_STRING
} jmi_type_t;

typedef char jmi_boolean;
typedef const char* jmi_string;
typedef unsigned int jmi_value_reference;

typedef enum {
    JMI_MATRIX_DENSE,     /* Dense */
    JMI_MATRIX_SPARSE_CSC /* Compressed Sparse Column*/
} jmi_matrix_type_t;

typedef struct jmi_matrix_t {
    jmi_matrix_type_t type;
} jmi_matrix_t;

typedef enum {
    JMI_MATRIX_DENSE_COLUMN_MAJOR,
    JMI_MATRIX_DENSE_ROW_MAJOR
} jmi_matrix_dense_order_t;

typedef struct jmi_matrix_dense_t {
    jmi_matrix_t type; /* Type of matrix */
    jmi_matrix_dense_order_t order; /* Order of the matrix (column/row major) */
    jmi_int_t nbr_cols; /* Number of columns */
    jmi_int_t nbr_rows; /* Number of rows */
    double *x;       /* Data values */
} jmi_matrix_dense_t;

typedef struct jmi_matrix_sparse_csc_t {
    jmi_matrix_t type; /* Type of matrix */
    jmi_int_t nbr_cols;   /* Number of columns */
    jmi_int_t nbr_rows;   /* Number of rows */
    jmi_int_t nnz;        /* Number of non zero elements */
    jmi_int_t *col_ptrs;  /* Column pointers (size nbr_cols+1) */ 
    jmi_int_t *row_ind;   /* Row indices (size nnz) */
    double *x;         /* Data values (size nnz) */
} jmi_matrix_sparse_csc_t;

/**
 * \brief Allocates a jmi_matrix_sparse_csc_t instance.
 *
 * @param rows Number of rows in the matrix.
 * @param cols Number of columns in the matrix.
 * @param nnz Number of structural non-zeros in the matrix.
 * @return An instance of jmi_matrix_sparse_csc_t.
  */
jmi_matrix_sparse_csc_t *jmi_linear_solver_create_sparse_matrix(jmi_int_t rows, jmi_int_t cols, jmi_int_t nnz);

/**
 * \brief Destroy a jmi_matrix_sparse_csc_t instance.
 *
 * @param A jmi_matrix_sparse_csc_t instance.
 * @param method A jmi_ode_method_t struct. 
 * @param step_size The step size for the mehtod.
 * @param rel_tol The relative tolerance for the method.
 * @return Error code.
  */
void jmi_linear_solver_delete_sparse_matrix(jmi_matrix_sparse_csc_t *A);

typedef struct jmi_jacobian_quadrant {
    void  (*dim)();
    void  (*col)();
    void  (*row)();
    void  (*eval)();
} jmi_jacobian_quadrant_t;

typedef struct jmi_jacobian_quadrants {
    jmi_jacobian_quadrant_t L;
    jmi_jacobian_quadrant_t A12;
    jmi_jacobian_quadrant_t A21;
    jmi_jacobian_quadrant_t A22;
} jmi_jacobian_quadrants_t;

#endif
