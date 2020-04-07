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


/** \file jmi_block_solver.h
 *  \brief Equation block solver interface.
 */

#ifndef _JMI_BLOCK_SOLVER_H
#define _JMI_BLOCK_SOLVER_H

#include "jmi_log.h"
#include "jmi_types.h"
#include <time.h>

#ifndef CLOCKS_PER_SEC /* In C89 CLK_TCK is the correct name */
#   ifdef CLK_TCK
#       define CLOCKS_PER_SEC   CLK_TCK
#   else
#       define CLOCKS_PER_SEC   1000000l /* The results in this case will likely be bogus. */
#   endif
#endif

/** \brief Evaluation modes for the residual function.*/
#define JMI_BLOCK_INITIALIZE                                    1 << 0
#define JMI_BLOCK_EVALUATE                                      1 << 1
#define JMI_BLOCK_WRITE_BACK                                    1 << 2
#define JMI_BLOCK_EVALUATE_INACTIVE                             1 << 3
#define JMI_BLOCK_EVALUATE_NON_REALS                            1 << 4
#define JMI_BLOCK_MIN                                           1 << 5
#define JMI_BLOCK_MAX                                           1 << 6
#define JMI_BLOCK_NOMINAL                                       1 << 7
#define JMI_BLOCK_EVALUATE_JACOBIAN                             1 << 8
#define JMI_BLOCK_EQUATION_NOMINAL                              1 << 9
#define JMI_BLOCK_VALUE_REFERENCE                               1 << 10
#define JMI_BLOCK_SOLVED_NON_REAL_VALUE_REFERENCE               1 << 11
#define JMI_BLOCK_SOLVED_STRING_VALUE_REFERENCE                 1 << 12
#define JMI_BLOCK_ACTIVE_SWITCH_INDEX                           1 << 13
#define JMI_BLOCK_START                                         1 << 14
#define JMI_BLOCK_DIRECTLY_IMPACTING_NON_REAL_VALUE_REFERENCE   1 << 15
#define JMI_BLOCK_DIRECTLY_ACTIVE_SWITCH_INDEX                  1 << 16
#define JMI_BLOCK_SOLVED_REAL_VALUE_REFERENCE                   1 << 17
#define JMI_BLOCK_NON_REAL_TEMP_VALUE_REFERENCE                 1 << 18
#define JMI_BLOCK_START_SET                                     1 << 19
#define JMI_BLOCK_EQUATION_NOMINAL_AUTO                         1 << 20
#define JMI_BLOCK_DISCRETE_REAL_VALUE_REFERENCE                 1 << 21
#define JMI_BLOCK_DISCRETE_REAL_NOMINAL                         1 << 22

/** \brief Evaluation modes for the callback Jacobian function.*/
#define JMI_BLOCK_JACOBIAN_EVALUATE_L                           0
#define JMI_BLOCK_JACOBIAN_EVALUATE_A12                         1
#define JMI_BLOCK_JACOBIAN_EVALUATE_A21                         2
#define JMI_BLOCK_JACOBIAN_EVALUATE_A22                         4
#define JMI_BLOCK_EVALUATE_JAC                                  524288
#define JMI_BLOCK_GET_DEPENDENCY_MATRIX                         1048576

/** \brief Evaluation modes for the callback Jacobian structure function.*/
typedef enum jmi_block_solver_jacobian_structure_mode_t {
 JMI_BLOCK_JACOBIAN_L_DIMENSIONS   =                      0,
 JMI_BLOCK_JACOBIAN_L_COLPTR       =                      1,
 JMI_BLOCK_JACOBIAN_L_ROWIND       =                      4,
 JMI_BLOCK_JACOBIAN_A12_DIMENSIONS =                      8,
 JMI_BLOCK_JACOBIAN_A12_COLPTR     =                      16,
 JMI_BLOCK_JACOBIAN_A12_ROWIND     =                      32,
 JMI_BLOCK_JACOBIAN_A21_DIMENSIONS =                      64,
 JMI_BLOCK_JACOBIAN_A21_COLPTR     =                      128,
 JMI_BLOCK_JACOBIAN_A21_ROWIND     =                      256,
 JMI_BLOCK_JACOBIAN_A22_DIMENSIONS =                      512,
 JMI_BLOCK_JACOBIAN_A22_COLPTR     =                      1024,
 JMI_BLOCK_JACOBIAN_A22_ROWIND     =                      2048
} jmi_block_solver_jacobian_structure_mode_t;

#define JMI_LIMIT_VALUE 1e30
#define JMI_VAR_NOT_USED(x) ((void)x)

#define JMI_NORM_MAX 0

/** \brief Jacobian variability for the linear solver */
typedef enum jmi_block_solver_jac_variability_t {
    JMI_CONSTANT_VARIABILITY=0,
    JMI_PARAMETER_VARIABILITY=1,
    JMI_DISCRETE_VARIABILITY=2,
    JMI_CONTINUOUS_VARIABILITY=4
} jmi_block_solver_jac_variability_t;

/** \brief Available block solvers */
typedef enum {
     JMI_SIMPLE_NEWTON_SOLVER, /* Only used for testing at some point. Not maintained. */
     JMI_KINSOL_SOLVER,
     JMI_LINEAR_SOLVER,
     JMI_MINPACK_SOLVER,
     JMI_REALTIME_SOLVER
} jmi_block_solver_kind_t;

/** \brief Scaling mode for the residuals in non-linear solver*/
typedef enum jmi_block_solver_residual_scaling_mode_t {
    jmi_residual_scaling_none = 0, /* Must be zero */
    jmi_residual_scaling_auto = 1,
    jmi_residual_scaling_manual = 2,
    jmi_residual_scaling_hybrid = 3,
    jmi_residual_scaling_aggressive_auto = 4,
    jmi_residual_scaling_full_jacobian_auto = 5
} jmi_block_solver_residual_scaling_mode_t;

/** \brief Scaling mode for the iteration variables in the non-linear solver*/
typedef enum jmi_block_solver_iv_scaling_mode_t {
    jmi_iter_var_scaling_none = 0,
    jmi_iter_var_scaling_nominal = 1,
    jmi_iter_var_scaling_heuristics = 2
} jmi_block_solver_iv_scaling_mode_t;

/** \brief Exit criterion mode for the non-linear solver*/
typedef enum jmi_block_solver_exit_criterion_mode_t {
    jmi_exit_criterion_step_residual = 0, /* Must be zero */
    jmi_exit_criterion_step = 1,
    jmi_exit_criterion_residual = 2,
    jmi_exit_criterion_hybrid = 3
} jmi_block_solver_exit_criterion_mode_t;

/** \brief Mode for Jacobian updates*/
typedef enum jmi_block_solver_jacobian_update_mode_t {
    jmi_full_jacobian_update_mode = 0, 
    jmi_broyden_jacobian_update_mode = 1,
    jmi_reuse_jacobian_update_mode = 2
} jmi_block_solver_jacobian_update_mode_t;

/** \brief Mode for Jacobian calculation*/
typedef enum jmi_block_solver_jacobian_calculation_mode_t {
    jmi_onesided_diffs_jacobian_calculation_mode = 0, 
    jmi_central_diffs_jacobian_calculation_mode = 1,
    jmi_central_diffs_at_bound_jacobian_calculation_mode = 2,
    jmi_central_diffs_at_bound_and_zero_jacobian_calculation_mode = 3,
    jmi_central_diffs_solve2_jacobian_calculation_mode = 4,
    jmi_central_diffs_at_bound_solve2_jacobian_calculation_mode = 5,
    jmi_central_diffs_at_bound_and_zero_solve2_jacobian_calculation_mode = 6,
    jmi_central_diffs_at_small_res_jacobian_calculation_mode = 7,
    jmi_calculate_externally_jacobian_calculation_mode = 8,
    jmi_compression_jacobian_calculation_mode = 9
} jmi_block_solver_jacobian_calculation_mode_t;

/** \brief Modes for bounds handling. */
typedef enum jmi_block_solver_active_bounds_mode_t {
    jmi_project_newton_step_active_bounds_mode = 0,
    jmi_use_steepest_descent_active_bounds_mode = 1
} jmi_block_solver_active_bounds_mode_t;

/** \brief Experimental features in the solver. */
typedef enum jmi_block_solver_experimental_mode_t {
    jmi_block_solver_experimental_none = 0,
    jmi_block_solver_experimental_steepest_descent = 1,
    jmi_block_solver_experimental_steepest_descent_first = 2,
    jmi_block_solver_experimental_Brent = 4,
    jmi_block_solver_experimental_LU_through_sundials = 8,
    jmi_block_solver_experimental_Brent_with_newton = 16,
    jmi_block_solver_experimental_active_bounds_threshold = 32,
    jmi_block_solver_experimental_Broyden_with_zeros = 64,
    jmi_block_solver_experimental_Sparse_Broyden = 2048,
    jmi_block_solver_experimental_use_modifiedBFGS = 4096
} jmi_block_solver_experimental_mode_t;

typedef enum jmi_block_solver_status_t {
    jmi_block_solver_status_success = 0,
    jmi_block_solver_status_err_event_eval = 1,
    jmi_block_solver_status_inf_event_loop = 2,
    jmi_block_solver_status_event_non_converge = 3,
    jmi_block_solver_status_err_f_eval = 4,
    jmi_block_solver_status_err_jac_eval = 5
} jmi_block_solver_status_t;


/**
 * \brief Function signature for evaluation of a equation block residual
 * in the block solver interface.
 *
 * @param problem_data Problem data pointer passed in the jmi_block_solver_new.
 * @param x (Input/Output) The iteration variable vector. For example, if the init argument is
 * set to JMI_BLOCK_INITIALIZE then x is an output argument that holds the
 * initial values. If init is set to JMI_BLOCK_EVALUATE, then x is an input
 * argument used in the evaluation of the residual.
 * @param residual (Output) The residual vector if init is set to
 * JMI_BLOCK_EVALUATE.
 * @param mode Evaluation mode. For available modes, see the defines for the residual function.
 * @return Error code.
 */
typedef int (*jmi_block_solver_residual_func_t)(void* problem_data, jmi_real_t* x,
        jmi_real_t* residual, int mode);
        
/**
 * \brief Function signature for evaluation of a directional derivatives for a
 * residual function in the block solver interface.
 *
 * @param problem_data Problem data pointer passed in the jmi_block_solver_new.
 * @param x (Input/Output) The iteration variable vector. If the init argument is
 * set to JMI_BLOCK_INITIALIZE then x is an output argument that holds the
 * initial values. If init is set to JMI_BLOCK_EVALUATE, then x is an input
 * argument used in the evaluation of the residual.
 * @param dx (input) The seed vector that is used if init is set to JMI_BLOCK_EVALUATE
 * @param dRes (output) the directional derivative if init is set to JMI_BLOCK_EVALUATE
 * @param residual (Output) The residual vector if init is set to
 * JMI_BLOCK_EVALUATE, otherwise this argument is not used.
 * @param mode Evaluation mode.
 * @return Error code.
 */
typedef int (*jmi_block_solver_dir_der_func_t)(void* problem_data, jmi_real_t* x,
         jmi_real_t* dx,jmi_real_t* residual, jmi_real_t* dRes, int mode);

/**
 * \brief Function signature for evaluation of the Jacobian corresponding to 
 * an equation block residual in the block solver interface.
 *
 * @param problem_data Problem data pointer passed in the jmi_block_solver_new.
 * @param x (Input/Output) If mode is set to JMI_BLOCK_EVALUATE_JAC, then x is an input
 * argument used in the evaluation of the Jacobian.
 * @param jac(Output) The Jacobian matrix if mode is set to
 * JMI_BLOCK_EVALUATE_JAC, the dependency matrix if mode is set to JMI_BLOCK_GET_DEPENDENCY_MATRIX,
 * otherwise this argument is not used.
 * @param mode Evaluation mode. See the defines for the Jacobian function.
 * @return Error code.
 */
typedef int (*jmi_block_solver_jacobian_func_t)(void* problem_data, jmi_real_t* x,
         jmi_real_t** jac, int mode);
         
/**
 * \brief Function signature for evaluation of the Jacobian structure 
 * corresponding to an equation block residual in the block solver interface.
 *
 * @param problem_data Problem data pointer passed in the jmi_block_solver_new.
 * @param x (Input) Can be used if the Jacobian structure depends on values.
 * @param structure(Output) The Jacobian structure. The output information is determined by
 * the mode used.
 * @param mode Evaluation mode. The modes are defined by jmi_block_solver_jacobian_structure_mode_t.
 * @return Error code.
 */
typedef int (*jmi_block_solver_jacobian_structure_func_t)(void* problem_data, jmi_real_t* x,
         jmi_int_t** structure, int mode);

/**
 * \brief Function signature for checking if discrete variables would change
 * if the Ivs are set to "x".
 *
 * @param problem_data (Input) Problem data pointer passed in the jmi_block_solver_new.
 * @param x (Input) The iteration variable vector. 
 * @return 0 if there is no change, 1 otherwise.
 */
typedef int (*jmi_block_solver_check_discrete_variables_change_func_t)(void* problem_data, double* x);

/**
 * \brief Function signature for updating discrete variables due to changes in
 *  the iteration variables. Values from the last residuals evaluation are used.
 *
 * @param problem_data (Input) Problem data pointer passed in the jmi_block_solver_new.
 * @param non_reals_changed_flag (Output) The flag indicating if discrete variables changed and further iterations are needed.
 * @return 0 on successful execution or error code.
 */
typedef jmi_block_solver_status_t (*jmi_block_solver_update_discrete_variables_func_t)(void* problem_data, int* non_reals_changed_flag);

/**
 * \brief Function signature for checking if in "restore solver state"-mode.
 *
 * @param problem_data (Input) Problem data pointer passed in the jmi_block_solver_new.
 * @return 1 if in mode otherwise 0.
 */
typedef int (*jmi_block_restore_solver_state_mode_t)(void* problem_data);

/* TODO: log_discrete_variables is not really needed. Kept just to make sure there are not changes during refactoring */
typedef int (*jmi_block_solver_log_discrete_variables)(void* problem_data, jmi_log_node_t node);

/* Forward declaration of the necessary structs */
typedef struct jmi_block_solver_t jmi_block_solver_t;
typedef struct jmi_block_solver_options_t jmi_block_solver_options_t;
typedef struct jmi_block_solver_callbacks_t jmi_block_solver_callbacks_t;

/**
 * \brief Allocate the internal structure for the block solver.
 */
int jmi_new_block_solver(jmi_block_solver_t** block_solver_ptr,
                         jmi_callbacks_t* cb,
                         jmi_log_t* log,
                         jmi_block_solver_callbacks_t solver_callbacks,
                         int n,
                         jmi_block_solver_options_t* options,
                         void* problem_data);

/**
 * \brief Free the allocated memory.
 * 
 * @param block_solver_ptr A double pointer to the jmi_block_solver_t struct
 */
void jmi_delete_block_solver(jmi_block_solver_t** block_solver_ptr);

/**
 * \brief A equation block solver function signature.
 *
 * @param block A jmi_block_solver_t struct.
 * @return Error code.
 */
typedef int (*jmi_block_solver_solve_func_t)(jmi_block_solver_t* block_solver);

/**
 * \brief A equation block solver destructor signature.
 *
 * @param block A jmi_block_residual_t struct.
  */
typedef void (*jmi_block_solver_delete_func_t)(jmi_block_solver_t* block_solver);

/**
 * \brief A equation block signature for notifying the block that an integrator step has been accepted.
 * 
 * @param block A jmi_block_solver_t struct.
 * @return Error code.
 */
typedef int (*jmi_block_solver_completed_integrator_step_func_t)(jmi_block_solver_t* block_solver);

/**< \brief Equation block solver options. */
struct jmi_block_solver_options_t {
    double res_tol;                         /**< \brief Tolerance for the equation block solver */
    double min_tol;                         /**< \brief Minimal allowed value for the tolerance */
    double step_limit_factor;               /**< \brief Step limiting factor */
    double regularization_tolerance;        /**< \brief Tolerance for deciding when regularization should be performed */
    int max_iter;                           /**< \brief Maximum number of iterations for the equation block solver before failure */
    int max_iter_no_jacobian;               /**< \brief Maximum number of iterations for the equation block solver without full Jacobian recalculation */

    jmi_block_solver_exit_criterion_mode_t solver_exit_criterion_mode; /**< \brief Exit criterion mode for non-linear block solver:
                                                                       0 - step length + residual, 1 - step length, 2 - residual, 3 -hybrid (default) */

    int enforce_bounds_flag;                /**< \brief Enforce min-max bounds on variables in the equation blocks*/
    int use_jacobian_equilibration_flag;    /**< \brief If Jacobian equilibration should be used in equation block solvers */
    int use_Brent_in_1d_flag;               /**< \brief If Brent search should be used to improve accuracy in solution of 1D non-linear equations */

    int block_jacobian_check;               /**< \brief Compares analytic block Jacobian with finite difference block Jacobian */ 
    double block_jacobian_check_tol;        /**< \brief Tolerance for block Jacobian comparison */
    
    jmi_block_solver_jacobian_update_mode_t jacobian_update_mode; /**< \brief Jacobian update mode in equation block solvers: 0 - full Jacobian, 1 - Broyden update */
    jmi_block_solver_jacobian_calculation_mode_t jacobian_calculation_mode; /**< \brief Jacobian calculation mode 0- one-sided diffs, 1 - central diffs, 2 - central diffs at bound, 3 - central diffs at bound and 0 */
    jmi_block_solver_residual_scaling_mode_t residual_equation_scaling_mode; /**< \brief Equations scaling mode in equation block solvers:0-no scaling,1-automatic scaling,2-manual scaling */
    jmi_block_solver_active_bounds_mode_t active_bounds_mode; /**< \brief Handling of active bounds mode: 0 - only project, 1 - use steepest descent in case of non descent direction */

    double max_residual_scaling_factor;    /**< \brief Maximum residual scaling factor used in nle solver */
    double min_residual_scaling_factor;    /**< \brief Minimum residual scaling factor used in nle solver */

    jmi_block_solver_iv_scaling_mode_t iteration_variable_scaling_mode;    /**< \brief Iteration variables scaling mode in equation block solvers:
                                                                         0 - no scaling, 1 - scaling based on nominals only (default), 2 - utilize heuristict to guess nominal based on min,max,start, etc. */

    int rescale_each_step_flag;             /**< \brief If scaling should be updated at every step (only active if residual_equation_scaling_mode is not "none") */
    int rescale_after_singular_jac_flag;    /**< \brief If scaling should be updated after singular Jacobian was detected (only active if residual_equation_scaling_mode is not "none") */

    int check_jac_cond_flag;       /**< \brief Flag if the solver should check Jacobian condition number and log it. */
    int brent_ignore_error_flag;   /**< \brief Flag if the solver should ignore errors in Brent solve. */
    int experimental_mode;         /**< \brief  Activate experimental features of equation block solvers. Combination of jmi_block_solver_experimental_mode_t flags. */
    double events_epsilon;         /**< \brief The event epsilon used for event indicators and switches. */
    double time_events_epsilon;    /**< \brief The time event epsilon used for time event indicators and switches. */
    int use_newton_for_brent;      /**< \brief If a few Newton steps are to be performed in order to get a better guess for Brent. */
    double active_bounds_threshold; /**< \brief Threshold for when we are at active bounds. */
    int use_nominals_as_fallback_in_init; /**< \brief If set, uses the nominals as initial guess in case everything else failed during initialization */
    int start_from_last_integrator_step; /**< \brief If set, uses the iteration variables from the last integrator step as initial guess. */
    double jacobian_finite_difference_delta; /**< \brief Option for which delta to use in finite differences Jacobian, default sqrt(eps). */
    int block_profiling; /**< \brief Option for enabling profiling of the blocks. */
    
    /* Options below are not supposed to change between invocations of the solver. */
    jmi_block_solver_kind_t solver;                          /**< \brief Kind of block solver to use */
    jmi_block_solver_jac_variability_t jacobian_variability; /**< \brief Jacobian variability for linear block solver */
    jmi_string_t label;                                      /**< \brief Label of this block solver (used for logging) */

};

struct jmi_block_solver_callbacks_t {
    jmi_block_solver_residual_func_t F;                                                         /**< \brief Function for evaluation of the block residual. */
    jmi_block_solver_dir_der_func_t dF;                                                         /**< \brief Directional derivative, can be NULL. */
    jmi_block_solver_jacobian_func_t Jacobian;                                                  /**< \brief Function for evaluation of the block Jacobian, can be NULL if, e.g., kin_dF should be used. */
    jmi_block_solver_jacobian_structure_func_t Jacobian_structure;                              /**< \brief Function for evaluation of the block Jacobian structure, can be NULL. */
    jmi_block_solver_check_discrete_variables_change_func_t check_discrete_variables_change;    /**< \brief Function for checking if discrete variables change, used in enhanced event iteration, can be NULL. */
    jmi_block_solver_update_discrete_variables_func_t update_discrete_variables;                /**< \brief Function for updating discrete variables. */
    jmi_block_solver_log_discrete_variables log_discrete_variables;                             /**< \brief Function for logging the discrete variables. */
    jmi_block_restore_solver_state_mode_t restore_solver_state_mode;                            /**< \brief Function for deciding when during the simulation/solver phase the solver state should be saved/restored. */
};

/** \brief Solve the equations in the associated problem. 
 * 
 * atInitial should only be set to true if JMI_BLOCK_START exists as a flag and start values should
 * be collected therefrom the first time the block is called during the initialization phase. When 
 * false start values are collected from JMI_BLOCK_INITIALIZE.
*/
int jmi_block_solver_solve(jmi_block_solver_t * block_solver, double cur_time, int handle_discrete_changes, int at_initial);

/** \brief Start the clock for profiling. */
clock_t jmi_block_solver_start_clock(jmi_block_solver_t * block_solver);

/** \brief Stop the clock for profiling. */
double jmi_block_solver_elapsed_time(jmi_block_solver_t * block_solver, clock_t start_clock);

/** \brief Notify the block that an integrator step is completed */
int jmi_block_solver_completed_integrator_step(jmi_block_solver_t * block_solver);

/**
 * \brief Compares two sets of iteration variables.
 * 
 * Compares two sets of iteration variables and returns (1) if their difference 
 * is small and (0) if not. The difference between the sets of iteration
 * variables is considered small if
 *     |x_pre[i] – x_post[i] | < RTOL*|x_pre[i]| + RTOL*x_nom[i],
 * is true for each iteration variable (i = 1,2,...,n).
 * 
 * @param block_solver A jmi_block_solver_t struct
 * @param x_pre The first set of iteration variables
 * @param x_post The second set of iteration variables
 */
int jmi_block_solver_compare_iter_vars(jmi_block_solver_t* block_solver, jmi_real_t* x_pre, jmi_real_t* x_post);

/**
 * \brief Checks if the "restore to last integrator step" behavior is active.
 * 
 * Returns (1) if the option start_from_last_integrator_step and the return
 * value of the callback restore_solver_state_mode are true otherwise (0).
 * 
 * @param block_solver A jmi_block_solver_t struct
 */
int jmi_block_solver_use_save_restore_state_behaviour(jmi_block_solver_t* block_solver);

/** \brief Initialize the options with defaults */
void jmi_block_solver_init_default_options(jmi_block_solver_options_t* op);

/** \brief Retrieve a block solver callback struct with defaults */
jmi_block_solver_callbacks_t jmi_block_solver_default_callbacks(void);

/** \brief Update function scaling based on Jacobian information */
void jmi_update_f_scale(jmi_block_solver_t *block);

/**< \brief Retrieve residual scales used in solver */
double* jmi_solver_get_f_scales(jmi_block_solver_t* block);

/**< \brief Setup residual scaling */
void jmi_setup_f_residual_scaling(jmi_block_solver_t *block);

/** \brief Computes the scaled vector norm */
int jmi_scaled_vector_norm(jmi_real_t *x, jmi_real_t *scale, jmi_int_t n, jmi_int_t NORM, jmi_real_t* out);

/** \brief Check and log illegal iv inputs */
int jmi_check_and_log_illegal_iv_input(jmi_block_solver_t* block, jmi_real_t* ivs, int N);

/** \brief Check and log illegal residual output(s) */
int jmi_check_and_log_illegal_residual_output(jmi_block_solver_t *block, jmi_real_t* f, jmi_real_t* ivs, jmi_real_t* heuristic_nominal,int N);
#endif /* _JMI_BLOCK_SOLVER_H */
