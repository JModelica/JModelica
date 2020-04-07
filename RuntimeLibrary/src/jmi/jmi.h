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

/** \file jmi.h
 *  \brief The public JMI model interface.
 **/

#ifndef _JMI_H
#define _JMI_H

#include "jmi_ode_solver.h"
#include "jmi_util.h"
#include "jmi_global.h"
#include "jmi_block_solver.h"
#include "jmi_delay.h"
#include "jmi_work_array.h"


/* @{ */

/**
 * \defgroup Defines Defined constants
 * \brief Constants defined in the JMI Model interface.
 */
/* @{ */

#define JMI_OK     0                 /**< \brief Everything is OK. */
#define JMI_ERROR -1                 /**< \brief An ERROR occurred. */

#define JMI_TIME_EXACT 0            /**< \brief Time events that are exact shall be handled. */
#define JMI_TIME_GREATER 1          /**< \brief Time events should be handled as time has passed the exact. */

/**  \brief Definitions of boolean true and false literals.*/
#define JMI_TRUE  ((jmi_real_t) (1.0))
#define JMI_FALSE ((jmi_real_t) (0.0))

/** \brief */
#define JMI_SCALING_NONE 1        /**< \brief No scaling.*/
#define JMI_SCALING_VARIABLES 2   /**< \brief Scale real variables by multiplying incoming variables in residual functions by the scaling factors in jmi_t->variable_scaling_factors */

#define JMI_REL_GT 0
#define JMI_REL_GEQ 2
#define JMI_REL_LT 4
#define JMI_REL_LEQ 8

#define JMI_EQUAL                           1
#define JMI_SWITCHES_AND_NON_REALS_CHANGED -1
#define JMI_NON_REALS_CHANGED              -2
#define JMI_SWITCHES_CHANGED               -3
#define JMI_DISCRETE_REALS_CHANGED         -4
#define JMI_SWITCHES_AND_DISCRETE_REALS_CHANGED -5
#define JMI_SWITCHES_AND_DISCRETE_REALS_AND_NON_REALS_CHANGED -6
#define JMI_DISCRETE_REALS_AND_NON_REALS_CHANGED -7

#define JMI_UPDATE_STATES    1 
 
 /* @} */

/**
 * \defgroup jmi_function_typedefs Function typedefs
 *
 * \brief Function signatures to be used in the generated code
 */

/* @{ */

/**
 * \brief A generic function signature that only takes a jmi_t struct as input.
 *
 * @param jmi A jmi_t struct.
 * @return Error code.
 */
typedef int (*jmi_generic_func_t)(jmi_t* jmi);

/**
 * \brief A function signature for computation of the next time event.
 *
 * @param jmi A jmi_t struct.
 * @param event (Output) Information about the next time event.
 * @return Error code.
 */
typedef int (*jmi_next_time_event_func_t)(jmi_t* jmi, jmi_time_event_t* event);

/**
 * \brief Function signature for evaluation of a residual function in
 * the generated code.
 *
 * Notice that this function signature is used for all functions in
 * the DAE and DAE initialization interfaces.
 *
 * @param jmi A jmi_t struct.
 * @param res (Output) The residual value.
 * @return Error code.
 *
 */
typedef int (*jmi_residual_func_t)(jmi_t* jmi, jmi_real_t** res);

/**
 * \brief Function signature for evaluation of a directional derivative function
 * in the generated code.
 *
 * Notice that this function signature is used for all functions in
 * the DAE and DAE initialization.
 *
 * @param jmi A jmi_t struct.
 * @param res (Output) The residual value vector.
 * @param dF (Output) The directional derivative of the residual function.
 * @param dz the Seed vector of size n_x + n_x + n_u + n_w.
 * @return Error code.
 *
 */
typedef int (*jmi_directional_der_residual_func_t)(jmi_t* jmi, jmi_real_t** res,
        jmi_real_t** dF, jmi_real_t** dz);
 
 
 /* @} */

/**
 * \defgroup jmi_structs_init The jmi_t and jmi_model_t
 *
 * \brief Functions for initialization of the jmi_t and jmi_model_t.
 *
 */

/* @{ */

/**
 * \brief Allocates memory and sets up the jmi_t struct.
 *
 * This function is typically called from within jmi_new in the generated code.
 * The reason for introducing this function is that the allocation of the
 * jmi_t struct should not be repeated in the generated code.
 *
 * @param jmi (Output) A pointer to a jmi_t pointer.
 * @param n_real_ci Number of real independent constants.
 * @param n_real_cd Number of real dependent constants.
 * @param n_real_pi Number of real independent parameters.
 * @param n_real_pd Number of real dependent parameters.
 * @param n_integer_ci Number of integer independent constants.
 * @param n_integer_cd Number of integer dependent constants.
 * @param n_integer_pi Number of integer independent parameters.
 * @param n_integer_pd Number of integer dependent parameters.
 * @param n_boolean_ci Number of boolean independent constants.
 * @param n_boolean_cd Number of boolean dependent constants.
 * @param n_boolean_pi Number of boolean independent parameters.
 * @param n_boolean_pd Number of boolean dependent parameters.
 * @param n_real_dx Number of real derivatives.
 * @param n_real_x Number of real differentiated variables.
 * @param n_real_u Number of real inputs.
 * @param n_real_w Number of real algebraics.
 * @param n_real_d Number of real discrete parameters.
 * @param n_integer_d Number of integer discrete parameters.
 * @param n_integer_u Number of integer inputs.
 * @param n_boolean_d Number of boolean discrete parameters.
 * @param n_boolean_u Number of boolean inputs.
 * @param n_sw Number of switching functions in DAE \$fF\$f.
 * @param n_sw_init Number of switching functions in DAE initialization system \$fF_0\$f.
 * @param n_guards Number of guards in DAE \$fF\$f.
 * @param n_guards_init Number of guards in DAE initialization system \$fF_0\$f.
 * @param n_dae_blocks Number of DAE blocks.
 * @param n_dae_init_blocks Number of DAE initialization blocks.
 * @param n_initial_relations Number of relational operators in the initial equations.
 * @param initial_relations Kind of relational operators in the initial equations. One of JMI_REL_GT, JMI_REL_GEQ, JMI_REL_LT, JMI_REL_LEQ.
 * @param n_relations Number of relational operators in the DAE equations.
 * @param relations Kind of relational operators in the DAE equations. One of: JMI_REL_GT, JMI_REL_GEQ, JMI_REL_LT, JMI_REL_LEQ.
 * @param scaling_method Scaling method. Options are JMI_SCALING_NONE or JMI_SCALING_VARIABLES.
 * @param homotopy_block Block number of the block which contains homotopy operators, -1 if none.
 * @param jmi_callbacks A jmi_callback_t struct.
 * @return Error code.
 */
int jmi_init(jmi_t** jmi,
        int n_real_ci, int n_real_cd, int n_real_pi,
        int n_real_pi_s, int n_real_pi_f, int n_real_pi_e, int n_real_pd,
        int n_integer_ci, int n_integer_cd, int n_integer_pi,
        int n_integer_pi_s, int n_integer_pi_f, int n_integer_pi_e, int n_integer_pd, 
        int n_boolean_ci, int n_boolean_cd, int n_boolean_pi,
        int n_boolean_pi_s, int n_boolean_pi_f, int n_boolean_pi_e, int n_boolean_pd,
        int n_real_dx, int n_real_x, int n_real_u, int n_real_w,
        int n_real_d, int n_integer_d, int n_integer_u,
        int n_boolean_d, int n_boolean_u,
        int n_sw, int n_sw_init, int n_time_sw, int n_state_sw,
        int n_guards, int n_guards_init,
        int n_dae_blocks, int n_dae_init_blocks,
        int n_initial_relations, int* initial_relations,
        int n_relations, int* relations, int n_dynamic_state_sets,
        jmi_real_t* nominals,
        int scaling_method, int n_ext_objs, int homotopy_block,
        jmi_callbacks_t* jmi_callbacks);
        
/**
 * Deallocates memory and deletes a jmi_t struct.
 *
 * @param jmi A pointer to the jmi_t struc to be deleted.
 */
int jmi_delete(jmi_t* jmi);

/**
 * \brief Allocates a jmi_model_t struct.
 *
 * @param jmi A jmi_t struct.
 * @param model_ode_derivatives_dir_der A function pointer to the ODE directional derivative function.
 * @param model_ode_derivatives A function pointer to the ODE RHS function.
 * @param model_ode_event_indicators A function pointer to the ODE event indicators.
 * @param model_ode_initialize A function pointer to the ODE initialization function.
 * @param model_init_eval_dependent   A function pointer for evaluating the independent parameters.
 * @param model_init_eval_independent A function pointer for evaluating the dependent parameters.
 * @param model_ode_next_time_event A function pointer for evaluating the next time event.
 */
void jmi_model_init(jmi_t* jmi,
                    jmi_generic_func_t model_ode_derivatives_dir_der,
                    jmi_generic_func_t model_ode_derivatives,
                    jmi_residual_func_t model_ode_event_indicators,
                    jmi_generic_func_t model_ode_initialize,
                    jmi_generic_func_t model_init_eval_independent,
                    jmi_generic_func_t model_init_eval_dependent,
                    jmi_next_time_event_func_t model_ode_next_time_event);

/**
 * \brief Dallocates the jmi_model_t struct in jmi if it is not NULL.
 *
 * @param jmi A jmi_t struct.
 */
void jmi_model_delete(jmi_t* jmi);

/**
 * \brief Contains a pointers to the runtime modules.
 */
struct jmi_modules_t {
    jmi_module_t *mod_get_set;

    /* Add future modules here */
};

typedef struct jmi_z_offsets {
    size_t ci, cd, pi, pd, ps, pf, pe, w, wp;
} jmi_z_offsets_t;

typedef struct jmi_z_strings {
    char** values;
    jmi_z_offsets_t offs;
    jmi_z_offsets_t nums;
    size_t n;
} jmi_z_strings_t;

typedef struct jmi_z {
    jmi_z_strings_t strings;
} jmi_z_t;


/**
 * \brief The main struct of the JMI Model interface containing
 * dimension information and model function pointers in jmi_model_t.
 *
 * jmi_t is the main struct in the JMI model interface. It contains
 * pointers to structs of types, jmi_model_t represents the model in
 * the form of function pointers contining the generated code.
 */
struct jmi_t {
    jmi_callbacks_t jmi_callbacks;       /**< \brief Struct containing callbacks the jmi runtime needs. */
    
    jmi_model_t* model;                  /**< \brief Struct contaning callbacks to the model functions. */
    
    jmi_generic_func_t init_delay;       /**< \brief Function for initializing delay structures. */
    jmi_generic_func_t sample_delay;     /**< \brief Function for initializing delay structures. */

    jmi_z_t z_t;

    int n_real_ci;                       /**< \brief Number of independent constants. */
    int n_real_cd;                       /**< \brief Number of dependent constants. */
    int n_real_pi;                       /**< \brief Number of independent parameters. */
    int n_real_pd;                       /**< \brief Number of dependent parameters. */

    int n_integer_ci;                    /**< \brief Number of integer independent constants. */
    int n_integer_cd;                    /**< \brief Number of integer dependent constants. */
    int n_integer_pi;                    /**< \brief Number of integer independent parameters. */
    int n_integer_pd;                    /**< \brief Number of integer dependent parameters. */

    int n_boolean_ci;                    /**< \brief Number of boolean independent constants. */
    int n_boolean_cd;                    /**< \brief Number of boolean dependent constants. */
    int n_boolean_pi;                    /**< \brief Number of boolean independent parameters. */
    int n_boolean_pd;                    /**< \brief Number of boolean dependent parameters. */

    int n_real_dx;                       /**< \brief Number of derivatives. */
    int n_real_x;                        /**< \brief Number of differentiated states. */
    int n_real_u;                        /**< \brief Number of inputs. */
    int n_real_w;                        /**< \brief Number of algebraics. */

    int n_real_d;                        /**< \brief Number of discrete variables. */

    int n_integer_d;                     /**< \brief Number of integer discrete variables. */
    int n_integer_u;                     /**< \brief Number of integer inputs. */

    int n_boolean_d;                     /**< \brief Number of boolean discrete variables. */
    int n_boolean_u;                     /**< \brief Number of boolean inputs. */

    int n_sw;                            /**< \brief Number of switching functions in the DAE \f$F\f$. */
    int n_sw_init;                       /**< \brief Number of switching functions in the DAE initialization system\f$F_0\f$. */
    int n_time_sw;                       /**< \brief Number of switches related to time events in the DAE \f$F\f$. */
    int n_state_sw;                      /**< \brief Number of switches related to state events in the DAE \f$F\f$. */

    int n_guards;                        /**< \brief Number of guards in the DAE \f$F\f$. */
    int n_guards_init;                   /**< \brief Number of guards in the DAE initialization system\f$F_0\f$. */

    int n_v;                             /**< \brief Number of elements in \f$v\f$. Number of equations??*/

    int n_z;                             /**< \brief Number of elements in \f$z\f$. */
    
    int n_dae_blocks;                    /**< \brief Number of BLT blocks. */
    int n_dae_init_blocks;               /**< \brief Number of initial BLT blocks. */

    int n_delays;                        /**< \brief Number of (fixed and variable time) delay blocks. */
    int n_spatialdists;                  /**< \brief Number of spatialDistribution blocks. */

    /* Offset variables in the z vector, for convenience. */
    /* Structural, final, and evaluated parameters "_pi_s", "_ip_f", and
     * "_pi_e" are subsets of independent parameters "_pi"
     * and their offsets are only used for generating error messages */
    int offs_real_ci;                    /**< \brief  Offset of the independent real constant vector in \f$z\f$. */
    int offs_real_cd;                    /**< \brief  Offset of the dependent real constant vector in \f$z\f$. */
    int offs_real_pi;                    /**< \brief  Offset of the independent real parameter vector in \f$z\f$. */
    int offs_real_pi_s;                  /**< \brief  Offset of the structural real parameter vector in \f$z\f$. */
    int offs_real_pi_f;                  /**< \brief  Offset of the final real parameter vector in \f$z\f$. */
    int offs_real_pi_e;                  /**< \brief  Offset of the evaluated real parameter vector in \f$z\f$. */
    int offs_real_pd;                    /**< \brief  Offset of the dependent real parameter vector in \f$z\f$. */

    int offs_integer_ci;                 /**< \brief  Offset of the independent integer constant vector in \f$z\f$. */
    int offs_integer_cd;                 /**< \brief  Offset of the dependent integer constant vector in \f$z\f$. */
    int offs_integer_pi;                 /**< \brief  Offset of the independent integer parameter vector in \f$z\f$. */
    int offs_integer_pi_s;               /**< \brief  Offset of the structural integer parameter vector in \f$z\f$. */
    int offs_integer_pi_f;               /**< \brief  Offset of the final integer parameter vector in \f$z\f$. */
    int offs_integer_pi_e;               /**< \brief  Offset of the evaluated integer parameter vector in \f$z\f$. */
    int offs_integer_pd;                 /**< \brief  Offset of the dependent integer parameter vector in \f$z\f$. */

    int offs_boolean_ci;                 /**< \brief  Offset of the independent boolean constant vector in \f$z\f$. */
    int offs_boolean_cd;                 /**< \brief  Offset of the dependent boolean constant vector in \f$z\f$. */
    int offs_boolean_pi;                 /**< \brief  Offset of the independent boolean parameter vector in \f$z\f$. */
    int offs_boolean_pi_s;               /**< \brief  Offset of the structural boolean parameter vector in \f$z\f$. */
    int offs_boolean_pi_f;               /**< \brief  Offset of the final boolean parameter vector in \f$z\f$. */
    int offs_boolean_pi_e;               /**< \brief  Offset of the evaluated boolean parameter vector in \f$z\f$. */
    int offs_boolean_pd;                 /**< \brief  Offset of the dependent boolean parameter vector in \f$z\f$. */

    int offs_real_dx;                    /**< \brief  Offset of the derivative real vector in \f$z\f$. */
    int offs_real_x;                     /**< \brief  Offset of the differentiated real variable vector in \f$z\f$. */
    int offs_real_u;                     /**< \brief  Offset of the input real vector in \f$z\f$. */
    int offs_real_w;                     /**< \brief  Offset of the algebraic real variables vector in \f$z\f$. */
    int offs_t;                          /**< \brief  Offset of the time entry in \f$z\f$. */
    int offs_homotopy_lambda;            /**< \brief  Offset of the homotopy lambda entry in \f$z\f$. */

    int offs_real_d;                     /**< \brief  Offset of the discrete real variable vector in \f$z\f$. */

    int offs_integer_d;                  /**< \brief  Offset of the discrete integer variable vector in \f$z\f$. */
    int offs_integer_u;                  /**< \brief  Offset of the input integer vector in \f$z\f$. */

    int offs_boolean_d;                  /**< \brief  Offset of the discrete boolean variable vector in \f$z\f$. */
    int offs_boolean_u;                  /**< \brief  Offset of the input boolean vector in \f$z\f$. */

    int offs_sw;                         /**< \brief  Offset of the first switching function in the DAE \f$F\f$ */
    int offs_sw_init;                    /**< \brief  Offset of the first switching function in the DAE initialization system \f$F_0\f$ */
    int offs_state_sw;                   /**< \brief  Offset of the first switching function (state) in the DAE \f$F\f$ */
    int offs_time_sw;                    /**< \brief  Offset of the first switching function (time) in the DAE \f$F\f$ */

    int offs_guards;                     /**< \brief  Offset of the first guard \f$F\f$ */
    int offs_guards_init;                /**< \brief  Offset of the first guard in the DAE initialization system \f$F_0\f$ */

    int offs_pre_real_dx;                /**< \brief  Offset of the pre derivative real vector in \f$z\f$. */
    int offs_pre_real_x;                 /**< \brief  Offset of the pre differentiated real variable vector in \f$z\f$. */
    int offs_pre_real_u;                 /**< \brief  Offset of the pre input real vector in \f$z\f$. */
    int offs_pre_real_w;                 /**< \brief  Offset of the pre algebraic real variables vector in \f$z\f$. */

    int offs_pre_real_d;                 /**< \brief  Offset of the pre discrete real variable vector in \f$z\f$. */

    int offs_pre_integer_d;              /**< \brief  Offset of the pre discrete integer variable vector in \f$z\f$. */
    int offs_pre_integer_u;              /**< \brief  Offset of the pre input integer vector in \f$z\f$. */

    int offs_pre_boolean_d;              /**< \brief  Offset of the pre discrete boolean variable vector in \f$z\f$. */
    int offs_pre_boolean_u;              /**< \brief  Offset of the pre input boolean vector in \f$z\f$. */

    int offs_pre_sw;                     /**< \brief  Offset of the first pre switching function in the DAE \f$F\f$ */
    int offs_pre_sw_init;                /**< \brief  Offset of the first pre switching function in the DAE initialization system \f$F_0\f$ */

    int offs_pre_guards;                 /**< \brief  Offset of the first pre guard \f$F\f$ */
    int offs_pre_guards_init;            /**< \brief  Offset of the first pre guard in the DAE initialization system \f$F_0\f$ */

    jmi_real_t** z;                      /**< \brief  This vector contains the actual values. */
    jmi_real_t** z_last;                 /**< \brief  This vector contains the values from the last successful integration step. */
    jmi_real_t** dz;                     /**< \brief  This vector is used to store calculated directional derivatives */
    int dz_active_index;                 /**< \brief The element in dz_active_variables to be used (0..JMI_ACTIVE_VAR_BUFS_NUM). Needed for local iterations */
    int block_level;                     /**< \brief Block level for nested equation blocks. Currently 0 or 1. */
    jmi_real_t *dz_active_variables[1];	 /**< \brief  This vector is used to store seed-values for active variables in block Jacobians */
#define JMI_ACTIVE_VAR_BUFS_NUM 3
    jmi_real_t *dz_active_variables_buf[JMI_ACTIVE_VAR_BUFS_NUM];  /**< \brief  This vector is the buffer used by dz_active_variables */
    void** ext_objs;                     /**< \brief This vector contains the external object pointers. */
    
    jmi_real_t* nominals;                             /**< \brief Nominal values of differentiated states. */
    jmi_real_t *variable_scaling_factors;             /**< \brief Scaling factors. For convenience the vector has the same size as z but only scaling of reals are used. */
    int scaling_method;                               /**< \brief Scaling method: JMI_SCALING_NONE, JMI_SCALING_VARIABLES */
    jmi_block_residual_t** dae_block_residuals;       /**< \brief A vector of function pointers to DAE equation blocks */
    jmi_block_residual_t** dae_init_block_residuals;  /**< \brief A vector of function pointers to DAE initialization equation blocks */
    int cached_block_jacobians;                       /**< \brief This flag indicates weather the Jacobian needs to be refactorized */

    jmi_delay_t *delays;                 /**< \brief Delay blocks (fixed and variable time) */
    jmi_spatialdist_t *spatialdists;     /**< \brief spatialDistribution blocks */
    jmi_boolean delay_event_mode;        /**< \brief Controls operation of `jmi_delay_record_sample` and `jmi_spatialdist_record_sample` */
    
    jmi_dynamic_state_set_t* dynamic_state_sets; /**< \brief Struct for the list of dynamic state sets */
    jmi_int_t n_dynamic_state_sets;              /**< \brief Number of set of dynamic state variables */

    jmi_int_t n_initial_relations;       /**< \brief Number of relational operators used in the event indicators for the initialization system. There should be the same number of initial relations as there are event indicators */
    jmi_int_t* initial_relations;        /**< \brief Kind of relational operators used in the event indicators for the initialization system: JMI_REL_GT, JMI_REL_GEQ, JMI_REL_LT, JMI_REL_LEQ */
    jmi_int_t n_relations;               /**< \brief Number of relational operators used in the event indicators for the DAE system */
    jmi_int_t* relations;                /**< \brief Kind of relational operators used in the event indicators for the DAE system: JMI_REL_GT, JMI_REL_GEQ, JMI_REL_LT, JMI_REL_LEQ */

    jmi_real_t atEvent;                  /**< \brief A boolean variable indicating if the model equations are evaluated at an event.*/
    jmi_real_t atInitial;                /**< \brief A boolean variable indicating if the model equations are evaluated at the initial time */
    jmi_real_t atTimeEvent;              /**< \brief A boolean variable indicating if the model equations are evaluated at a time event time */
    int eventPhase;                      /**< \brief Zero if in first phase of event iteration, non zero if in second phase */
    int save_restore_solver_state_mode;  /**< \brief A boolean variable indicating if in a mode where solver state should be saved and restored */
    
    jmi_time_event_t nextTimeEvent;

    jmi_int_t is_initialized;            /**< Flag to keep track of if the initial equations have been solved. */

    int nbr_event_iter;                  /**< Counter for the nummber of global event iterations performed. */
    int nbr_consec_time_events;          /**< Counter for the nummber of consecutive time events handled (max should always be 2). */ 

    jmi_log_t* log;                      /**< \brief Struct containing the structured logger. */

    jmi_options_t options;               /**< \brief Runtime options */
    jmi_real_t events_epsilon;           /**< \brief Value used to adjust the event indicator functions */
    jmi_real_t time_events_epsilon;      /**< \brief Value used to adjust the time event indicator functions */
    jmi_real_t tmp_events_epsilon;       /**< \brief Temporary holder for the event epsilon during initialization */
    jmi_real_t newton_tolerance;         /**< \brief Tolerance that is used in the newton iteration */
    jmi_int_t recomputeVariables;        /**< \brief Dirty flag indicating when equations should be resolved. */
    jmi_int_t recompute_init_independent;/**< \brief Dirty flag indicating when independent parameters should be reevaluated */
    jmi_int_t recompute_init_dependent;  /**< \brief Dirty flag indicating when dependent parameters should be reevaluated */
    jmi_int_t recompute_init_variables;  /**< \brief Dirty flag indicating when start values for variables should be reevaluated */
    jmi_int_t updated_states;            /**< \brief Flag indicating if the dynamic set of states has been updated. */

    jmi_real_t* real_x_work;             /**< \brief Work array for the real x variables */
    jmi_real_t* real_u_work;             /**< \brief Work array for the real u variables */
	jmi_real_work_array_t* real_work;		 /**< \brief Work array for real variables */
	jmi_int_work_array_t* int_work;		 /**< \brief Work array for int variables */
    
    jmp_buf try_location[JMI_MAX_EXCEPTION_DEPTH+1];                /**< \brief Buffer for setjmp/longjmp, for exception handling. */
    jmi_int_t current_try_depth;

    jmi_int_t model_terminate;           /**< \brief Flag to trigger termination of the simulation. */
    jmi_int_t user_terminate;            /**< \brief Flag that the user has terminated the model. */

    jmi_int_t reinit_triggered;          /**< \brief Flag to signal that a reinit triggered in the current event iteration. */
    
    jmi_string_t resource_location;      /**< \brief Absolute file path to resource directory. No trailing separator. May be null. */
    jmi_int_t resource_location_verified;/**< \brief Flag indicating if the resource location has been checked to exist or not. */

    jmi_modules_t modules;               /**< \brief Interchangable modules struct */
    jmi_chattering_t* chattering;        /**< \brief Contains chattering information, used for logging */

    jmi_dynamic_function_memory_t* dyn_fcn_mem;
    jmi_dynamic_function_memory_t* dyn_fcn_mem_globals;
    
    void* globals;                       /**< \brief Global temporaries used in generated code */
};

/**
 * \brief Struct describing the model equations.
 *
 * Contains function pointers for evaluating the generated code of the model.
 */
struct jmi_model_t {
    jmi_residual_func_t ode_event_indicators;       /**< \brief A function for evaluating the ODE event indicators. */
    jmi_generic_func_t ode_derivatives;              /**< \brief A function for evaluating the ODE derivatives. */
    jmi_generic_func_t ode_derivatives_dir_der;      /**< \brief A function for evaluating the ODE directional derivative. */
    jmi_generic_func_t ode_initialize;               /**< \brief A function for initializing the ODE. */
    jmi_generic_func_t init_eval_independent;        /**< \brief A function for initial evaluation of independent parameters. */
    jmi_generic_func_t init_eval_dependent;          /**< \brief A function for initial evaluation of dependent   parameters. */
    jmi_next_time_event_func_t ode_next_time_event;  /**< \brief A function for computing the next time event instant. */
};

/**
 * \brief Create a new jmi_t struct.
 *
 * This function creates a new jmi struct, for which a pointer is returned in the output argument jmi.
 *
 * Typically this function is defined in the generated code.
 *
 * @param jmi A pointer to a jmi_t pointer where the new jmi_t struct is stored.
 * @param jmi_callbacks A jmi_callbacks_t struct.
 * @return Error code.
 */
int jmi_new(jmi_t** jmi, jmi_callbacks_t* jmi_callbacks);

/**
 * Clean up after a completed simulation.
 *
 * @param jmi A pointer to the jmi_t struct to clean up.
 * @return Error code.
 */
int jmi_destruct_external_objs(jmi_t* jmi);

/**
 * \brief Get the name of the model that produced this FMU.
 */
const char *jmi_get_model_identifier();

/**
 * \brief Call a jmi_generic_func_t, and handle exceptions and setting the current jmi_t pointer.
 */
int jmi_generic_func(jmi_t *jmi, jmi_generic_func_t func);

/**
 * \brief Evaluate the ODE derivatives.
 *
 * @param jmi A jmi_t struct.
 * @return Error code.
 */
int jmi_ode_derivatives(jmi_t* jmi);

/**
 * \brief Evaluate the ODE directional derivatives.
 *
 * @param jmi A jmi_t struct.
 * @param dv The seed vector.
 * @return Error code.
 */
int jmi_ode_derivatives_dir_der(jmi_t* jmi);

/**
 * \brief Initialize the ODE.
 *
 * @param jmi A jmi_t struct.
 * @return Error code.
 */
int jmi_ode_initialize(jmi_t* jmi);

/**
 * \brief Computes the next time event.
 *
 * @param jmi A jmi_t struct.
 * @param event (Output) Information of the next time event.
 * @return Error code.
 */
int jmi_ode_next_time_event(jmi_t* jmi, jmi_time_event_t* event);

/**
 * \brief Evaluate DAE event indicator residuals.
 *
 * The user sets the input variables by writing to
 * the vectors obtained from the functions ::jmi_get_dx, ::jmi_get_x etc.
 *
 * @param jmi A jmi_t struct.
 * @param res (Output) The event indicator residuals.
 * @return Error code.
 *
 */
int jmi_dae_R(jmi_t* jmi, jmi_real_t* res);

/**
 * \brief Evaluate the adjusted DAE event indicator residuals.
 *
 * This method perturbes the event indicator functions based on the
 * relation operator (>,>=,<,<=) and the current value of the event
 * indicator with an epsilon (jmi->events_epsilon)
 *
 * @param jmi A jmi_t struct.
 * @param res (Output) The event indicator residuals.
 * @return Error code.
 *
 */
int jmi_dae_R_perturbed(jmi_t* jmi, jmi_real_t* res);

/**
 * \brief Mark independent parameters as dirty, triggering reevaluation 
 * on the next call to jmi_init_eval_independent.
 */
void jmi_init_eval_independent_set_dirty(jmi_t* jmi);

/**
 * \brief Reevaluate the independent parameters if necessary.
 *
 * @param jmi A jmi_t struct.
 * @return Error code.
 */
int jmi_init_eval_independent(jmi_t* jmi);

/**
 * \brief Mark dependent parameters as dirty, triggering reevaluation 
 * on the next call to jmi_init_eval_dependent.
 */
void jmi_init_eval_dependent_set_dirty(jmi_t* jmi);

/**
 * \brief Reevaluate the dependent parameters if necessary.
 *
 * @param jmi A jmi_t struct.
 * @return Error code.
 */
int jmi_init_eval_dependent(jmi_t* jmi);

/* @} */

/**
 * \defgroup Misc Miscanellous
 * \brief Miscanellous functions.
 */
/* @{ */

/* Initialize delay interface 
 * Called when initializing jmi struct */
int jmi_init_delay_if(jmi_t* jmi, int n_delays, int n_spatialdists, jmi_generic_func_t init, jmi_generic_func_t sample, int n_delay_switches);

/* Tear down delay interface
 * Called when destroying jmi struct */
int jmi_destroy_delay_if(jmi_t* jmi);


/* Initialize delay blocks 
 * Called after model initalization */
int jmi_init_delay_blocks(jmi_t* jmi);

/** 
 * \brief Destroys external objects
 */
int jmi_destruct_external_objects(jmi_t* jmi);

/* Sample delay blocks
 * Called after each completed integrator step and event iteration.
 * Expects event mode set with jmi_delay_set_event_mode */
int jmi_sample_delay_blocks(jmi_t* jmi);

/**
 * \brief Notifies the internal blocks that an integrator step is complete.
 * 
 * @param jmi A jmi_t struct.
 * @return 
 */
int jmi_block_completed_integrator_step(jmi_t *jmi);

#endif
