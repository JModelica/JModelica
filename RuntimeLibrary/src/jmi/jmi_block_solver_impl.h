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


/** \file jmi_block_solver_impl.h
 *  \brief Equation block solver private header.
 */

#ifndef _JMI_BLOCK_SOLVER_IMPL_H
#define _JMI_BLOCK_SOLVER_IMPL_H
#include "jmi_block_solver.h"
#include <nvector/nvector_serial.h>
#include <sundials/sundials_direct.h>

/**
    \brief Main data structure used in the block solver.
*/
struct jmi_block_solver_t {
    void* problem_data; /**< \brief External problem data pointer. Can be used by the problem code. */
    jmi_block_solver_options_t* options;
    jmi_callbacks_t* callbacks;
    jmi_log_t* log;
    jmi_string_t label;

    N_Vector f_scale;          /**< \brief Work vector for scaling of f */
    realtype scale_update_time; /**< \brief The last time when f scale was updated */
    int n;                         /**< \brief The number of iteration variables */
    int n_sr;                         /**< \brief The number of solved variables */
    jmi_real_t* x;                 /**< \brief Work vector for the real iteration variables */
    jmi_real_t* last_accepted_x;   /**< \brief Work vector for the real iteration variables holding the last accepted vales by the integrator */
    DlsMat J;                       /**< \brief The Jacobian matrix  */
    DlsMat J_scale;                 /**< \brief Jacobian matrix scaled with xnorm for used for fnorm calculation */
    int using_max_min_scaling_flag; /**< \brief A flag indicating if either the maximum scaling is used of the minimum */

    jmi_real_t* dx;                /**< \brief Work vector for the seed vector */

    jmi_real_t* res;               /**< \brief Work vector for the block residual */
    jmi_real_t* dres;              /**< \brief Work vector for the directional derivative that corresponds to dx */
    jmi_real_t* jac;               /**< \brief Work vector for the block Jacobian */
    int* ipiv;                     /**< \brief Work vector needed for dgesv */
#ifdef JMI_PROFILE_RUNTIME
    jmi_block_solver_t * parent_block;
    int is_init_block;
    double time_in_brent;
    double time_f;
    double time_df;
#endif

    double func_eval_time;          /**< \brief Total time spend in function evaluations */
    double jac_eval_time;           /**< \brief Total time spend in jacobian evaluations */
    double broyden_update_time;     /**< \brief Total time spend on Broyden updates */
    double step_calc_time;          /**< \brief Total time spend in solving linear system */
    double factorization_time;      /**< \brief Total time spend on factorizing jacobian matrix */
    double bounds_handling_time;    /**< \brief Total time spend on step limiting */
    double logging_time;            /**< \brief Total time spend on logging of kin_info and kin_err */

    jmi_real_t* min;               /**< \brief Min values for iteration variables */
    jmi_real_t* max;               /**< \brief Max values for iteration variables */
    jmi_real_t* nominal;           /**< \brief Nominal values for iteration variables */
    jmi_real_t* residual_nominal;   /**< \brief Nominals values for residual variables */
    jmi_real_t* residual_heuristic_nominal;   /**< \brief Heuristic nominals values for residual variables */
    jmi_real_t* initial;           /**< \brief Initial values for iteration variables */
    jmi_real_t* start_set;         /**< \brief If the start value is specified for the iteration variables */

    int jacobian_variability;      /**< \brief Variability of Jacobian coefficients: JMI_CONSTANT_VARIABILITY
                                         JMI_PARAMETER_VARIABILITY, JMI_DISCRETE_VARIABILITY, JMI_CONTINUOUS_VARIABILITY */

    int* value_references; /**< \brief Iteration variable value references. **/

    double cur_time;        /**< \brief Current time send in jmi_block_solver_solve(). Used for logging and controling rescaling. */
    int force_rescaling;            /**< \brief A flag indicating that residual scaling should be updated */

    void * solver;
    jmi_block_solver_solve_func_t solve;
    jmi_block_solver_delete_func_t delete_solver;
    jmi_block_solver_completed_integrator_step_func_t completed_integrator_step;
    
    int init;              /**< \brief A flag for initialization */
    int at_event;          /**< \brief A flag indicating if we are at an event */

    jmi_block_solver_residual_func_t F;
    jmi_block_solver_dir_der_func_t dF;
    jmi_block_solver_jacobian_func_t Jacobian;
    jmi_block_solver_jacobian_structure_func_t Jacobian_structure;
    jmi_block_solver_check_discrete_variables_change_func_t check_discrete_variables_change;
    jmi_block_solver_update_discrete_variables_func_t update_discrete_variables;
    jmi_block_solver_log_discrete_variables log_discrete_variables;
    jmi_block_restore_solver_state_mode_t restore_solver_state_mode;

    long int nb_calls;                    /**< \brief Nb of times the block has been solved */
    long int nb_iters;                     /**< \breif Total nb if iterations of non-linear solver */
    long int nb_jevals ;
    long int nb_fevals;
    double time_spent;             /**< \brief Total time spent in non-linear solver */
    char* message_buffer ; /**< \brief Message buffer used for debugging purposes */

    double canari; /* for debugging */

    int* residual_error_indicator;  /**< \brief flags indicating if NaN, Inf or Limiting values output of residual vector */

} ;

extern const double jmi_block_solver_canari;

/* Lapack function */
extern double dnrm2_(int* N, double* X, int* INCX);
extern void dgesv_(int* N, int* NRHS, double* A, int* LDA, int* IPIV,
                double* B, int* LDB, int* INFO );

#endif /* _JMI_BLOCK_SOLVER_H */
