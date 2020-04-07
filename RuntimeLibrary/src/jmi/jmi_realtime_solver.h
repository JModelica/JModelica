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


/** \file jmi_realtime_solver.h
 *  \brief Newton solver targeting realtime applications
 **/

#ifndef _JMI_REALTIME_SOLVER_H
#define _JMI_REALTIME_SOLVER_H

#include "jmi_block_solver.h"

#define JMI_REALTIME_SOLVER_MAX_CHAR_LOG_LENGTH 8

typedef struct jmi_realtime_solver_t jmi_realtime_solver_t;

/** \brief Error codes from the realtime solver */
typedef enum jmi_realtime_solver_error_codes_t {
    JMI_REALTIME_SOLVER_BLOCK_EVALUATION_FAIL = 0,
    JMI_REALTIME_SOLVER_JACOBIAN_APPROXIMATION_FAIL = 1,
    JMI_REALTIME_SOLVER_LU_FACTORIZATION_FAIL = 2,
    JMI_REALTIME_SOLVER_LU_SOLVE_FAIL = 4
} jmi_realtime_solver_error_codes_t;

struct jmi_realtime_solver_t {
    jmi_real_t* jacobian;           /**< \brief Matrix for storing the Jacobian. */
    jmi_real_t* dx;                 /**< \brief Updates to the IVs in the iterate. */
    jmi_real_t* df;                 /**< \brief Difference in the residual between iterates. */
    jmi_real_t* factorization;      /**< \brief Matrix for storing the Jacobian factorization. */
    jmi_int_t*  pivots;             /**< \brief Pivots related to the Jacobian factorization. */
    jmi_real_t* weights;            /**< \brief Weights used when computing the WRMS norm. */
    
    
    int char_log_length;                                       /** Number of chars in char_log */
    char char_log[JMI_REALTIME_SOLVER_MAX_CHAR_LOG_LENGTH+1];  /** Short log like "Js". Null-terminated. */
    
    jmi_int_t nbr_non_convergence;
    jmi_int_t nbr_iterations;
    jmi_real_t last_wrms;
    jmi_int_t  last_wrms_id;
    jmi_real_t last_jacobian_norm;
    jmi_real_t last_jacobian_rcond;
};


int  jmi_realtime_solver_solve(jmi_block_solver_t *block);

void jmi_realtime_solver_delete(jmi_block_solver_t *block);
int jmi_realtime_solver_new(jmi_realtime_solver_t** solver, jmi_block_solver_t* block);

int jmi_realtime_solver_jacobian(jmi_block_solver_t *block, jmi_real_t* f, jmi_real_t* jacobian);
int jmi_realtime_solver_broyden_update(jmi_real_t* jacobian, jmi_real_t* df, jmi_real_t* dx, jmi_int_t N);
int jmi_realtime_solver_perform_broyden_update(jmi_block_solver_t *block, jmi_real_t* df, jmi_real_t* dx);
void jmi_realtime_solver_error_handling(jmi_block_solver_t *block, jmi_real_t* x, jmi_realtime_solver_error_codes_t return_code);

#endif
