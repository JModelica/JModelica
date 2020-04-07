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


/** \file jmi_block_residual.h
 *  \brief Structures and functions for handling equation blocks.
 */

#ifndef _JMI_BLOCK_RESIDUAL_H
#define _JMI_BLOCK_RESIDUAL_H

#include "jmi_util.h"
#include "jmi_block_solver.h"

/* Lapack function */
extern void dgesv_(int* N, int* NRHS, double* A, int* LDA, int* IPIV,
                double* B, int* LDB, int* INFO );

extern double dnrm2_(int* N, double* X, int* INCX);

/**
 * \brief Function signature for evaluation of a equation block residual
 * function in the generated code.
 *
 * @param jmi A jmi_t struct.
 * @param x (Input/Output) The iteration variable vector. If the init argument is
 * set to JMI_BLOCK_INITIALIZE then x is an output argument that holds the
 * initial values. If init is set to JMI_BLOCK_EVALUATE, then x is an input
 * argument used in the evaluation of the residual.
 * @param residual (Output) The residual vector if init is set to
 * JMI_BLOCK_EVALUATE, otherwise this argument is not used.
 * @param init Set to either JMI_BLOCK_INITIALIZE or JMI_BLOCK_EVALUATE.
 * @return Error code.
 */
typedef int (*jmi_block_residual_func_t)(jmi_t* jmi, jmi_real_t* x,
        jmi_real_t* residual, int init);
        
typedef int (*jmi_block_jacobian_func_t)(jmi_t* jmi, jmi_real_t* x,
        jmi_real_t** jac, int init);

typedef int (*jmi_block_jacobian_structure_func_t)(jmi_t* jmi, jmi_real_t* x,
        jmi_int_t** jac, int init);
        
/**
 * \brief Function signature for evaluation of a directional derivatives for a
 * block function in the generated code.
 *
 * @param jmi A jmi_t struct.
 * @param x (Input/Output) The iteration variable vector. If the init argument is
 * set to JMI_BLOCK_INITIALIZE then x is an output argument that holds the
 * initial values. If init is set to JMI_BLOCK_EVALUATE, then x is an input
 * argument used in the evaluation of the residual.
 * @param dx (input) The seed vector that is used if init is set to JMI_BLOCK_EVALUATE
 * @param dRes (output) the directional derivative if init is set to JMI_BLOCK_EVALUATE
 * @param residual (Output) The residual vector if init is set to
 * JMI_BLOCK_EVALUATE, otherwise this argument is not used.
 * @param init Set to either JMI_BLOCK_INITIALIZE or JMI_BLOCK_EVALUATE.
 * @return Error code.
 */
typedef int (*jmi_block_dir_der_func_t)(jmi_t* jmi, jmi_real_t* x,
         jmi_real_t* dx,jmi_real_t* residual, jmi_real_t* dRes, int init);

/**
 * \brief A equation block solver function signature.
 *
 * @param block A jmi_block_residual_t struct.
 * @return Error code.
 */
typedef int (*jmi_block_residual_solve_func_t)(jmi_block_residual_t* block);

/**
 * \brief A equation block solver destructor signature.
 *
 * @param block A jmi_block_residual_t struct.
  */
typedef void (*jmi_block_residual_delete_func_t)(jmi_block_residual_t* block);

/**
 * \brief Compute the block Jacobian for the solver
 *
 * @param block A jmi_block_residual_t struct.
 * @param jacobian A vector that upon function exit contains the Jacobian in column major form.
 * @return Error code.
 */
typedef int (*jmi_block_residual_jacobian_func_t)(jmi_block_residual_t* block, jmi_real_t* jacobian);

/**
 * \brief Compute the LU factorization of the block Jacobian for the solver
 *
 * @param block A jmi_block_residual_t struct.
 * @param jacobian A vector that upon function exit contains the LU factorization of the Jacobian in column major form.
 * @return Error code.
 */
typedef int (*jmi_block_residual_jacobian_factorization_func_t)(jmi_block_residual_t* block, jmi_real_t* factorization);

struct jmi_block_residual_t {
    jmi_t *jmi;                    /**< \brief A pointer to the corresponding jmi_t struct */
    jmi_block_solver_options_t * options; /**< \brief block solver options */
    jmi_block_residual_func_t F;   /**< \brief A function pointer to the block residual function */
    jmi_block_jacobian_func_t J;   /**< \brief A function pointer to the block jacobian function */
    jmi_block_jacobian_structure_func_t J_structure;   /**< \brief A function pointer to the block jacobian structure function */
    jmi_block_dir_der_func_t dF;   /**< \brief A function pointer to the block AD-function */
    jmi_real_t* x;                 /**< \brief Work vector for the real iteration variables */

    /* Sizes */
    int n;                         /**< \brief The number of real unknowns in the equation system */
    int n_dr;                      /**< \brief The number of discrete real unknowns in the equation system */
    int n_nr;                      /**< \brief The number of non-real unknowns in the equation system */
    int n_nrt;                     /**< \brief The number of non-real temporaries in the equation system */
    int n_str;                     /**< \brief The number of string unknowns in the equation system */
    int n_sr;                      /**< \brief The number of solved reals in the equation system */
    int n_direct_nr;               /**< \brief The number of non-real unknowns that directly impacts the equation system */
    int n_direct_bool;             /**< \brief The number of booleans unknowns that directly impacts the equation system */
    int n_sw;                      /**< \brief The number of active switches in the equation system */
    int n_direct_sw;               /**< \brief The number of active switches that directly impacts the equation system */

    int event_iter;                 /**< \brief Current iteration for the switches. Used to index the saved switches/booleans in sw_old/bool_old */
    jmi_real_t* sw_old;             /**< \brief  Saved states of the switches during passed event iterations. Used for infinite loop detection. */
    jmi_real_t* nr_old;             /**< \brief  Saved states of the booleans during passed event iterations. Used for infinite loop detection. */
    jmi_string_t* str_old;          /**< \brief  Saved states of the strings during passed event iterations. Used for infinite loop detection. */
    jmi_real_t* x_old;              /**< \brief  Saved states of the interation variables during passed event iterations. Used for infinite loop detection. */
    jmi_real_t* dr_old;             /**< \brief  Saved states of the discrete reals during passed event iterations. Used for infinite loop detection. */
    jmi_int_t* sw_index;            /**< \brief  Index of the active switches for this block. */
    jmi_int_t* sr_vref;             /**< \brief  Value reference of the solved reals for this block. */
    jmi_int_t* sw_direct_index;     /**< \brief  Index of the direct switches for this block. */
    jmi_int_t* nr_index;            /**< \brief  Index of the non-reals in this block. */
    jmi_int_t* nr_pre_index;        /**< \brief  Index of the pre non-reals in this block. */
    jmi_int_t* nr_direct_index;     /**< \brief  Index of the direct non-reals in this block. */
    jmi_int_t* bool_direct_index;   /**< \brief  Index of the direct booleans in this block. */
    jmi_int_t* str_index;           /**< \brief  Index of the strings in this block. */
    jmi_int_t* str_pre_index;       /**< \brief  Index of the pre strings in this block. */
    jmi_int_t* nr_vref;             /**< \brief  Valuereference of the non-reals in this block. */
    jmi_int_t* str_vref;            /**< \brief  Valuereference of the string in this block. */
    jmi_int_t* dr_index;            /**< \brief  Index of the discrete reals for this block. */
    jmi_int_t* dr_pre_index;        /**< \brief  Index of the pre discrete-reals in this block. */
    jmi_int_t* dr_vref;             /**< \brief  Valuereference of the discrete-reals in this block. */
    
    /* Work vectors */
    jmi_real_t* work_switches;      /**< \brief Work vector for the switches */
    jmi_real_t* work_non_reals;     /**< \brief Work vector for the non-reals */
    jmi_string_t* work_strings;     /**< \brief Work vector for the strings */
    jmi_real_t* work_discrete_reals;     /**< \brief Work vector for the discrete-reals */
    jmi_real_t* work_ivs;           /**< \brief Work vector for the iteration variables */

    jmi_real_t* dx;                 /**< \brief Work vector for the seed vector */
    jmi_real_t* dv;                 /**< \brief Work vector for (dF/dv)*dv */
    int index;                      /**< \brief Block integer index, used for internal representation of the block */
#ifdef JMI_PROFILE_RUNTIME
    int parent_index; /*Used for profiling*/
    int is_init_block; /*Used for profiling*/
#endif
    jmi_string_t label;             /**< \brief Block string label, used for external representation of the block */

    jmi_real_t* res;               /**< \brief Work vector for the block residual */
    jmi_real_t* dres;              /**< \brief Work vector for the directional derivative that corresponds to dx */
    jmi_real_t* jac;               /**< \brief Work vector for the block Jacobian */
    jmi_real_t* fac;               /**< \brief Work vector for the factorized block Jacobian */
    int* ipiv;                     /**< \brief Work vector needed for dgesv */
    
    jmi_real_t* dgelss_rwork;      /**< \brief Work vector for DGELSS */
    int dgelss_iwork;              /**< \brief Size of the work vector for DGELSS */ 

    jmi_real_t* min;               /**< \brief Min values for iteration variables */
    jmi_real_t* max;               /**< \brief Max values for iteration variables */
    jmi_real_t* nominal;           /**< \brief Nominal values for iteration variables */
    jmi_real_t* initial;           /**< \brief Initial values for iteration variables */

    jmi_real_t* discrete_nominals;  /**< \brief Nominals values for the discrete reals */
    
    int jacobian_variability;      /**< \brief Variability of Jacobian coefficients: JMI_CONSTANT_VARIABILITY
                                         JMI_PARAMETER_VARIABILITY, JMI_DISCRETE_VARIABILITY, JMI_CONTINUOUS_VARIABILITY */

    int* value_references; /**< \brief Iteration variable value references. **/
    
    jmi_block_solver_t* block_solver;

    void * solver;
    jmi_block_residual_solve_func_t solve;
    jmi_block_residual_delete_func_t delete_solver;

    jmi_block_residual_jacobian_func_t evaluate_jacobian;
    /*
        The function was never used and was not fully implemneted. Removing.
    jmi_block_residual_jacobian_factorization_func_t evaluate_jacobian_factorization;
    */
    
    int init;              /**< \brief A flag for initialization */
    int at_event;          /**< \brief A flag indicating if we are at an event */
    
    long int nb_calls;                    /**< \brief Nb of times the block has been solved */
    long int nb_iters;                     /**< \breif Total nb if iterations of non-linear solver */
    long int nb_jevals ;
    long int nb_fevals;
    double time_spent;             /**< \brief Total time spent in non-linear solver */
    char* message_buffer ; /**< \brief Message buffer used for debugging purposes */
    int singular_jacobian;
};

/**
 * \brief Register a block residual function in a jmi_t struct.
 *
 * @param jmi A jmi_t struct.
 * @param F A jmi_block_residual_func_t function
 * @param dF A jmi_block_dir_der_func_t function
 * @param jacobian_func A jmi_block_solver_jacobian_func_t function
 * @param jacobian_struct A jmi_block_solver_jacobian_structure_func_t function
 * @param n Integer size of the block of real variables
 * @param n_sr Integer size of the block of solved real variables
 * @param n_dr Number discrete real variables in the block
 * @param n_nr Integer size of the block of non-real variables
 * @param n_dinr Integer size of the block of directly impacting non-real variables
 * @param n_as Integer size of the number of active switches
 * @param n_das Integer size of the number of directly active switches
 * @param jacobian_variability Variability of the Jacobian coefficients
 * @param attribute_variability Variability of the variable attributes
 * @param solver Solver to be used for the block
 * @param index Block integer index, used for internal representation of the block
 * @param label Block string label, used for external representation of the block
 * @param parent_index Index of parent block.
 * @return Error code.
 */
int jmi_dae_add_equation_block(jmi_t* jmi, jmi_block_residual_func_t F, jmi_block_dir_der_func_t dF,
                                jmi_block_jacobian_func_t J, jmi_block_jacobian_structure_func_t J_structure,
                                int n, int n_sr, int n_dr, int n_nr, int n_dinr, int n_nrt, int n_str,
                                int n_sw, int n_disw, int jacobian_variability, int attribute_variability,
                                jmi_block_solver_kind_t solver, int index, jmi_string_t label, int parent_index);

/**
 * \brief Register an initialization block residual function in a jmi_t struct.
 *
 * @param jmi A jmi_t struct.
 * @param F A jmi_block_residual_func_t function
 * @param dF A jmi_block_dir_der_func_t function
 * @param jacobian_func A jmi_block_solver_jacobian_func_t function
 * @param jacobian_struct A jmi_block_solver_jacobian_structure_func_t function
 * @param n Integer size of the block of real variables
 * @param n_sr Integer size of the block of solved real variables
 * @param n_dr Number discrete real variables in the block
 * @param n_nr Integer size of the block of non-real variables
 * @param n_dinr Integer size of the block of directly impacting non-real variables
 * @param n_as Integer size of the number of active switches
 * @param n_das Integer size of the number of directly active switches
 * @param jacobian_variability Variability of the Jacobian coefficients
 * @param attribute_variability Variability of the variable attributes
 * @param solver Solver to be used for the block
 * @param index Block integer index, used for internal representation of the block
 * @param label Block string label, used for external representation of the block
 * @param parent_index Index of parent block.
 * @return Error code.
 */
int jmi_dae_init_add_equation_block(jmi_t* jmi, jmi_block_residual_func_t F, jmi_block_dir_der_func_t dF,
                                jmi_block_jacobian_func_t J, jmi_block_jacobian_structure_func_t J_structure,
                                int n, int n_sr, int n_dr, int n_nr, int n_dinr, int n_nrt, int n_str,
                                int n_sw, int n_disw, int jacobian_variability, int attribute_variability,
                                jmi_block_solver_kind_t solver, int index, jmi_string_t label, int parent_index);


/**
 * \brief Allocates a jmi_block_residual struct.
 * 
 * @param b A jmi_block_residual_t struct (Output)
 * @param jmi A jmi_t struct.
 * @param solver Kind of solver to use
 * @param F A jmi_block_residual_func_t function
 * @param dF A jmi_block_dir_der_func_t function 
 * @param n Integer size of the block of real variables
 * @param n_dr Number discrete real variables in the block
 * @param n_nr Integer size of the block of non-real variables
 * @param jacobian_variability Variability of the Jacobian coefficients
 * @param index Block integer index, used for internal representation of the block
 * @param label Block string label, used for external representation of the block
 * @return Error code.
 */
int jmi_new_block_residual(jmi_block_residual_t** block, jmi_t* jmi, jmi_block_solver_kind_t solver,
                           jmi_block_residual_func_t F, jmi_block_dir_der_func_t dF,
                           jmi_block_jacobian_func_t J, jmi_block_jacobian_structure_func_t J_structure,
                           int n, int n_sr, int n_dr, int n_nr, int n_dinr, int n_nrt, int n_str,
                           int n_sw, int n_disw, int jacobian_variability, int index, jmi_string_t label);
int jmi_solve_block_residual(jmi_block_residual_t * block);

/**
 * \brief Updates the pre() discrete values in the block.
 * 
 * @param b A jmi_block_residual_t struct.
 * @return Error code.
 */
int jmi_block_update_pre(jmi_block_residual_t* b);

int jmi_block_jacobian_fd(jmi_block_residual_t* b, jmi_real_t* x, jmi_real_t delta_rel, jmi_real_t delta_abs);

/**
 * \brief Deletes a jmi_block_residual struct.
 * 
 * @param b A jmi_block_residual_t struct.
 * @return Error code.
 */
int jmi_delete_block_residual(jmi_block_residual_t* b);

/**
 * \brief Calculate directional derivatives for a equation block.
 *
 * The function expects the block to be already solved and uses current solution
 *  for derivatives calculation.
 *
 * @param jmi A jmi_t struct.
 * @param current_block An equation block to process.
 * @return Error code.
 */
int jmi_ode_unsolved_block_dir_der(jmi_t *jmi, jmi_block_residual_t *current_block);

/**
 * \brief Computes an reduced step (x+h*(x_new-x)).
 * 
 * @param h The "step-size"
 * @param x_new The states corresponding to the new state
 * @param x  The states corresponding to the old state
 * @param x_target The result (output)
 * @param size The size of the vectors x,x_new and x_target
 * @return Error code.
 */
int jmi_compute_reduced_step(jmi_real_t h, jmi_real_t* x_new, jmi_real_t* x, jmi_real_t* x_target, jmi_int_t size);

/**
 * \brief Determines if the current switches has already been tried.
 * 
 * This method loops over all the already tried states of the model
 * i.e. the tried set of the switches and iteration variables and
 * determines if the one currently being tried has already been
 * checked.
 * 
 * @param b A jmi_block_residual_t struct.
 * @param sw The current switches
 * @param x The current iteration variable values
 * @param iter The number of already tried states of the model
 */
jmi_int_t jmi_block_check_infinite_loop(jmi_block_residual_t* b, jmi_real_t* sw, jmi_real_t* x, jmi_int_t iter);

/**
 * \brief Computes the minial step for changing the relations, i.e. switches or booleans.
 * 
 * This method computess the minial step (h) such that x + h*(x_new - x)
 * does not change the relations, i.e. so that it does not changes the
 * sign on any switch or any boolean. The returned minimal step is then
 * h+eps. The step is computed using a bi-section algorithm.
 * 
 * @param block The current block being solved for.
 * @param x The old state values
 * @param x_new The new state values that has changed a relation
 * @param sw_init The switches corresponding to x
 * @param bool_init The booleans corresponding to x
 * @param nR The number of switches
 * @param tolerance The tolerance in the bi-section algorithm.
 * @return The minimal step-size.
 */
jmi_real_t jmi_compute_minimal_step(jmi_block_residual_t* block, jmi_real_t* x, jmi_real_t* x_new, jmi_real_t* sw_init, jmi_real_t* bool_init, jmi_int_t nR, jmi_real_t tolerance);

/**
 * \brief Finds the current values of the switches and non-reals that belong to the block.
 * 
 * This is a helper method for jmi_block_update_discrete_variables,
 * jmi_block_log_discrete_variables and jmi_block_check_discrete_variables_change
 * that finds the current switches and non-reals for this block.
 *
 * @param block The current block being solved for.
 * @param switches Holder for the switch values
 * @param non_reals Holder for the non-real values
 * @param discrete_reals Holder for the discrete-real values
 * @param strings Holder for the string values
 */
int jmi_block_get_sw_nr_dr(jmi_block_residual_t* block, jmi_real_t* switches, jmi_real_t* non_reals,
                            jmi_real_t* discrete_reals, jmi_string_t *strings);

/**
 * \brief Sets the switches and non-reals that belong to the block.
 *
 * @param block The current block being solved for.
 * @param switches The switch values
 * @param non_reals The non-real values
 * @param discrete_reals The discrete-real values
 * @param strings The the string values
 */
int jmi_block_set_sw_nr_dr(jmi_block_residual_t* block, jmi_real_t* switches, jmi_real_t* non_reals,
                            jmi_real_t* discrete_reals, jmi_string_t *strings);


int jmi_kinsol_solver_evaluate_jacobian(jmi_block_residual_t* block, jmi_real_t* jacobian);
int jmi_linear_solver_evaluate_jacobian(jmi_block_residual_t* block, jmi_real_t* jacobian);

/** \brief Notify the residual that an integrator step is completed */
int jmi_block_residual_completed_integrator_step(jmi_block_residual_t* block);

/* Utilized Lapack routines */
extern void dgetrf_(int* M, int* N, double* A, int* LDA, int* IPIV, int* INFO );
extern void dgetrs_(char* TRANS, int* N, int* NRHS, double* A, int* LDA, int* IPIV, double* B, int* LDB, int* INFO);
extern void dgelss_(int* M, int* N, int* NRHS, double* A, int* LDA, double* B, int* LDB,double* S,double* RCOND,int* RANK,double* WORK,int* LWORK, int* INFO);


#endif /* _JMI_COMMON_H */
