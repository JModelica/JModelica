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

/** \file jmi_util.h
 *  \brief Internals of the JMI Model interface.
 */

#ifndef _JMI_UTIL_H
#define _JMI_UTIL_H


#if !defined(NO_FILE_SYSTEM) && (defined(RT) || defined(NRT))
#define NO_FILE_SYSTEM
#endif

#ifndef NO_FILE_SYSTEM    
    #ifdef _WIN32
      #include <windows.h>
      #define JMI_PATH_MAX MAX_PATH
    #else
      #define _GNU_SOURCE
      #include <dlfcn.h>
      #ifdef __APPLE__
        #include <limits.h>
        #define JMI_PATH_MAX PATH_MAX
      #else
        #include <linux/limits.h>
        #include <limits.h>
        #define JMI_PATH_MAX PATH_MAX
      #endif
    #endif
    
    #include <sys/types.h>
    #include <sys/stat.h>
#endif

#ifndef JMI_PATH_MAX
#define JMI_PATH_MAX 256
#endif

#define JMI_REAL_WORK_ARRAY_SIZE 15
#define JMI_INT_WORK_ARRAY_SIZE 3

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <setjmp.h>

#include "jmi_callbacks.h"

#include "jmi_log.h"
#include "jmi_block_solver.h"

#include "jmi_dyn_mem.h"
#include "jmi_types.h"
#include "jmi_math.h"

/**
 * \defgroup Jmi_internal Internal functions of the JMI Model \
 * interface.
 *
 * \brief Documentation of the internal functions and data structures
 * of the JMI Model interface.
 *
 * The JMI Model interface is supported by internal data structures
 * and functions which are described in the following. 
 *
 * \section jmi_func_t Representation of functions
 *
 * All the mathematical functions defined in the JMI Model interface
 * are functions of independent variables contained in \f$z\f$. It is
 * therefore convenient to introduce an abstraction of a general
 * function \f$F(z)\f$, which can then be used to represent all
 * functions in the JMI Model interface. This abstraction is
 * materilized by the jmi_func_t struct. This struct contains function
 * pointers for evaluation of the function and its derivatives, as
 * well as sparsity information.
 *
 * \section jmi_jmi_t JMI Model interface structs
 *
 * The main struct of the JMI model interface is jmi_t. An instance of
 * this struct is passed as the first argument to most functions in
 * the JMI model interface and can be viewed as an object
 * corresponding to a particular model. jmi_t contains dimension
 * information of the model and a struct with function pointer for 
 * the model equations.
 *
 * Instances of jmi_t are created by a call to ::jmi_new, which is a
 * function that is typically defined in the generated model code.
 * The creation of a jmi_t struct proceeds in three
 * steps:
 *   - First, a raw struct is created by the function ::jmi_init. In
 *   this function, the dimensions of the variable vectors are set,
 *   but no substructs are initialized.
 *   - Then the jmi_dae_t and jmi_init_t structs are
 *   initialized by the function ::jmi_model_init. In these function
 *   calls, the corresponding function pointers are set and new
 *   jmi_func_t structs are created.
 *
 * Typically, ::jmi_init and ::jmi_model_init are called from within
 * the ::jmi_new function.
 *
 */

/* @{ */

/**
 * \defgroup jmi_internal_typedefs Typedefs
 * \brief Internal typedefs.
 */

/* @{ */

typedef struct _jmi_time_event_t {
    int defined;
    int phase;
    jmi_real_t time;
} jmi_time_event_t;

/**
 * If the time event T2 defined by <code>def</code>, <code>phase</code>, and <code>time</code>
 * is before the time event T1 defined by <code>event</code> then T1 is updated to T2.
 */
void jmi_min_time_event(jmi_time_event_t* event, int def, int phase, double time);

#define COND_EXP_EQ(op1,op2,th,el) ((op1==op2)? (th): (el)) /**< \brief Macro for conditional expression == <br> */
#define COND_EXP_LE(op1,op2,th,el) ((op1<=op2)? (th): (el)) /**< \brief Macro for conditional expression <= <br> */
#define COND_EXP_LT(op1,op2,th,el) ((op1<op2)? (th): (el))  /**< \brief Macro for conditional expression < <br> */
#define COND_EXP_GE(op1,op2,th,el) ((op1>=op2)? (th): (el)) /**< \brief Macro for conditional expression >= <br> */
#define COND_EXP_GT(op1,op2,th,el) ((op1>op2)? (th): (el))  /**< \brief Macro for conditional expression > <br> */

#define LOG_EXP_OR(op1,op2) ((op1)+(op2)>JMI_FALSE) /**< \brief Macro for logical expression or <br> */

#include "jmi_array_none.h"


#define LOG_EXP_AND(op1,op2) ((op1)*(op2))           /**< \brief Macro for logical expression and <br> */
#define LOG_EXP_NOT(op)      (JMI_TRUE-(op))         /**< \brief Macro for logical expression not <br> */


/* Record creation macro */
#define JMI_RECORD_STATIC(type, name) \
    type name##_rec = {0};\
    type* name = &name##_rec;

#ifdef _MSC_VER
/* Note: the return value isn't the same as for snprintf(). */
#define snprintf sprintf_s
#endif


/**
 * \brief Maximum depth for nested try blocks.
 */
#define JMI_MAX_EXCEPTION_DEPTH 10

/** Use for internal hard errors. Does not return. */
void jmi_internal_error(jmi_t *jmi, const char msg[]);

/*Some of these functions return types are a temporary remnants of CppAD*/

/**
 * Set the terminate flag and log message.
 */
void jmi_flag_termination(jmi_t *jmi, const char* msg);

/**< \brief Run-time options. */
typedef struct jmi_options_t {
    jmi_block_solver_options_t block_solver_options; /**< \bried Equation block solver options */
    jmi_log_options_t* log_options;                  /**< \bried  Logger options */

    double nle_solver_default_tol;          /**< \brief Default tolerance for the equation block solver */
    double nle_solver_tol_factor;           /**< \brief Tolerance safety factor for the non-linear equation block solver. */

    double events_default_tol;              /**< \brief Default tolerance for the event iterations. */        
    double time_events_default_tol;         /**< \brief Defult tolerance for the time event iterations. */
    double events_tol_factor;               /**< \brief Tolerance safety factor for the event iterations. */

    int cs_solver;                          /**< \brief Option for changing the internal CS solver */
    double cs_rel_tol;                      /** < \brief Default tolerance for the adaptive solvers in the CS case. */
    double cs_step_size;                    /** < \brief Default step-size for the non-adaptive solvers in the CS case. */   
    int cs_experimental_mode;  
} jmi_options_t;

/**< \brief Initialize run-time options. */
void jmi_init_runtime_options(jmi_t *jmi, jmi_options_t* op);

#define check_lbound(x, xmin, message) \
    if(jmi->options.block_solver_options.enforce_bounds_flag && (x < xmin)) \
        { jmi_log_node(jmi->log, logWarning, "LBoundExceeded", "<message:%s>", \
                       message);                                        \
        }

#define check_ubound(x, xmax, message) \
    if(jmi->options.block_solver_options.enforce_bounds_flag && (x > xmax)) \
        { jmi_log_node(jmi->log, logWarning, "UBoundExceeded", "<message:%s>", \
                       message);                                        \
        }

#define init_with_lbound(x, xmin, message) \
    if(jmi->options.block_solver_options.enforce_bounds_flag && (x < xmin)) \
        { jmi_log_node(jmi->log, logInfo, "LBoundSaturation", "<message:%s>", \
                       message); \
            x = xmin; }

#define init_with_ubound(x, xmax, message) \
    if(jmi->options.block_solver_options.enforce_bounds_flag && (x > xmax)) \
        { jmi_log_node(jmi->log, logInfo, "UBoundSaturation", "<message:%s>", \
                       message);                                        \
            x = xmax; }

#define check_bounds(x, xmin, xmax, message) \
    check_lbound(x, xmin, message)\
    else check_ubound(x, xmax, message)

#define init_with_bounds(x, xmin, xmax, message) \
    init_with_lbound(x, xmin, message) \
    else init_with_ubound(x, xmax, message)


/* @} */

/**
 * \defgroup Access Setters and getters for the fields in jmi_t
 *
 * \brief The fields of jmi_t are conveniently accessed using the setter and getter
 * functions provided in the JMI Model interface.
 *
 * Notice that it is not recommended to access the fields directely, since the internal
 * implementation of jmi_t may change, wheras the setters and getters are less likely to
 * do so.
 *
 */

/* @{ */

/**
 * \brief Copy variable values to the pre vector.
 *
 * @param jmi The jmi_t struct.
 * @return Error code.
 */
int jmi_copy_pre_values(jmi_t *jmi);

/**

 * \brief Get a pointer to the z vector containing all variables.
 *
 * @param jmi The jmi_t struct.
 * @return A pointer to the \f$z\f$ vector.
 *
 */
jmi_real_t* jmi_get_z(jmi_t* jmi);

/**

 * \brief Get the size of the z vector containing all variables.
 *
 * @param jmi The jmi_t struct.
 * @return The size of the \f$z\f$ vector.
 *
 */
int jmi_get_z_size(jmi_t* jmi);

jmi_string_t* jmi_get_string_z(jmi_t* jmi);

/**
 * \brief Get a pointer to the last successful z vector containing all variables.
 *
 * @param jmi The jmi_t struct.
 * @return A pointer to the \f$z\f$ vector.
 *
 */
jmi_real_t* jmi_get_z_last(jmi_t* jmi);

/**
 * \brief Get a pointer to the real independent constants vector.
 *
 * @param jmi The jmi_t struct.
 * @return A pointer to the \f$c_i^r\f$ vector.
 *
 */
jmi_real_t* jmi_get_real_ci(jmi_t* jmi);

/**
 * \brief Get a pointer to the real dependent constants vector.
 *
 * @param jmi The jmi_t struct.
 * @return A pointer to the \f$c_d^r\f$ vector.
 *
 */
jmi_real_t* jmi_get_real_cd(jmi_t* jmi);

/**
 * \brief Get a pointer to the real independent parameter vector.
 *
 * @param jmi The jmi_t struct.
 * @return A pointer to the \f$p_i^r\f$ vector.
 *
 */
jmi_real_t* jmi_get_real_pi(jmi_t* jmi);

/**
 * \brief Get a pointer to the real dependent parameters vector.
 *
 * @param jmi The jmi_t struct.
 * @return A pointer to the \f$p_d^r\f$ vector.
 *
 */
jmi_real_t* jmi_get_real_pd(jmi_t* jmi);

/**
 * \brief Get a pointer to the integer independent constants vector.
 *
 * @param jmi The jmi_t struct.
 * @return A pointer to the \f$c_i^r\f$ vector.
 *
 */
jmi_real_t* jmi_get_integer_ci(jmi_t* jmi);

/**
 * \brief Get a pointer to the integer dependent constants vector.
 *
 * @param jmi The jmi_t struct.
 * @return A pointer to the \f$c_d^i\f$ vector.
 *
 */
jmi_real_t* jmi_get_integer_cd(jmi_t* jmi);

/**
 * \brief Get a pointer to the integer independent parameter vector.
 *
 * @param jmi The jmi_t struct.
 * @return A pointer to the \f$p_i^i\f$ vector.
 *
 */
jmi_real_t* jmi_get_integer_pi(jmi_t* jmi);

/**
 * \brief Get a pointer to the integer dependent parameters vector.
 *
 * @param jmi The jmi_t struct.
 * @return A pointer to the \f$p_d^i\f$ vector.
 *
 */
jmi_real_t* jmi_get_integer_pd(jmi_t* jmi);

/**
 * \brief Get a pointer to the boolean independent constants vector.
 *
 * @param jmi The jmi_t struct.
 * @return A pointer to the \f$c_i^r\f$ vector.
 *
 */
jmi_real_t* jmi_get_boolean_ci(jmi_t* jmi);

/**
 * \brief Get a pointer to the boolean dependent constants vector.
 *
 * @param jmi The jmi_t struct.
 * @return A pointer to the \f$c_d^i\f$ vector.
 *
 */
jmi_real_t* jmi_get_boolean_cd(jmi_t* jmi);

/**
 * \brief Get a pointer to the boolean independent parameter vector.
 *
 * @param jmi The jmi_t struct.
 * @return A pointer to the \f$p_i^i\f$ vector.
 *
 */
jmi_real_t* jmi_get_boolean_pi(jmi_t* jmi);

/**
 * \brief Get a pointer to the boolean dependent parameters vector.
 *
 * @param jmi The jmi_t struct.
 * @return A pointer to the \f$p_d^i\f$ vector.
 *
 */
jmi_real_t* jmi_get_boolean_pd(jmi_t* jmi);

/**
 * \brief Get a pointer to the real derivatives vector.
 *
 * @param jmi The jmi_t struct.
 * @return A pointer to the \f$dx\f$ vector.
 *
 */
jmi_real_t* jmi_get_real_dx(jmi_t* jmi);

/**
 * \brief Get a pointer to the differentiated variables vector.
 *
 * @param jmi The jmi_t struct.
 * @return A pointer to the \f$x\f$ vector.
 *
 */
jmi_real_t* jmi_get_real_x(jmi_t* jmi);

/**
 * \brief Get a pointer to the inputs vector.
 *
 * @param jmi The jmi_t struct.
 * @return A pointer to the \f$u\f$ vector.
 *
 */
jmi_real_t* jmi_get_real_u(jmi_t* jmi);

/**
 * \brief Get a pointer to the algebraic variables vector.
 *
 * @param jmi The jmi_t struct.
 * @return A pointer to the \f$w\f$ vector.
 *
 */
jmi_real_t* jmi_get_real_w(jmi_t* jmi);

/**
 * \brief Get a pointer to the time value.
 *
 * @param jmi The jmi_t struct.
 * @return A pointer to \f$t\f$.
 *
 */
jmi_real_t* jmi_get_t(jmi_t* jmi);

/**
 * \brief Get a pointer to the derivatives corresponding to the i:th time point.
 *
 * @param jmi The jmi_t struct.
 * @param i Index of the time point: 0 corresponds to first time point.
 * @return A pointer to the \f$dx_{p,i}\f$ vector.
 *
 */
jmi_real_t* jmi_get_real_dx_p(jmi_t* jmi,int i);

/**
 * \brief Get a pointer to the differentiated variables corresponding to the i:th time point.
 *
 * @param jmi The jmi_t struct.
 * @param i Index of the time point: 0 corresponds to first time point.
 * @return A pointer to the \f$x_{p,i}\f$ vector.
 *
 */
jmi_real_t* jmi_get_real_x_p(jmi_t* jmi, int i);

/**
 * \brief Get a pointer to the inputs corresponding to the i:th time point.
 *
 * @param jmi The jmi_t struct.
 * @param i Index of the time point: 0 corresponds to first time point.
 * @return A pointer to the \f$u_{p,i}\f$ vector.
 *
 */
jmi_real_t* jmi_get_real_u_p(jmi_t* jmi, int i);

/**
 * \brief Get a pointer to the algebraic variables corresponding to the i:th time point.
 *
 * @param jmi The jmi_t struct.
 * @param i Index of the time point: 0 corresponds to first time point.
 * @return A pointer to the \f$w_{p,i}\f$ vector.
 *
 */
jmi_real_t* jmi_get_real_w_p(jmi_t* jmi, int i);

/**
 * \brief Get a pointer to the real discrete variables vector.
 *
 * @param jmi The jmi_t struct.
 * @return A pointer to the \f$d^r\f$ vector.
 *
 */
jmi_real_t* jmi_get_real_d(jmi_t* jmi);

/**
 * \brief Get a pointer to the integer discrete variables vector.
 *
 * @param jmi The jmi_t struct.
 * @return A pointer to the \f$d^i\f$ vector.
 *
 */
jmi_real_t* jmi_get_integer_d(jmi_t* jmi);

/**
 * \brief Get a pointer to the integer input variables vector.
 *
 * @param jmi The jmi_t struct.
 * @return A pointer to the \f$u^i\f$ vector.
 *
 */
jmi_real_t* jmi_get_integer_u(jmi_t* jmi);

/**
 * \brief Get a pointer to the boolean discrete variables vector.
 *
 * @param jmi The jmi_t struct.
 * @return A pointer to the \f$d^i\f$ vector.
 *
 */
jmi_real_t* jmi_get_boolean_d(jmi_t* jmi);

/**
 * \brief Get a pointer to the boolean input variables vector.
 *
 * @param jmi The jmi_t struct.
 * @return A pointer to the \f$u^i\f$ vector.
 *
 */
jmi_real_t* jmi_get_boolean_u(jmi_t* jmi);

/**
 * \brief Get a pointer to the first switching function in the DAE \$fF\$f.
 * A switch value of 1 corresponds to true and 0 corresponds to false.
 *
 * @param jmi The jmi_t struct.
 * @return A pointer to the vector of switching functions.
 *
 */
jmi_real_t* jmi_get_sw(jmi_t* jmi);

/**
 * \brief Get a pointer to the first switching function (state) in the DAE \$fF\$f.
 * A switch value of 1 corresponds to true and 0 corresponds to false.
 *
 * @param jmi The jmi_t struct.
 * @return A pointer to the vector of switching functions.
 *
 */
jmi_real_t* jmi_get_state_sw(jmi_t* jmi);

/**
 * \brief Get a pointer to the first switching function (time) in the DAE \$fF\$f.
 * A switch value of 1 corresponds to true and 0 corresponds to false.
 *
 * @param jmi The jmi_t struct.
 * @return A pointer to the vector of switching functions.
 *
 */
jmi_real_t* jmi_get_time_sw(jmi_t* jmi);

/**
 * \brief Get a pointer to the first switching function in the initialization system \$fF_0\$f.
 * A switch value of 1 corresponds to true and 0 corresponds to false.
 * @param jmi The jmi_t struct.
 * @return A pointer to the vector of switching functions.
 *
 */
jmi_real_t* jmi_get_sw_init(jmi_t* jmi);

/* @} */

/**
 * \defgroup Misc_internal Miscanellous
 * \brief Miscanellous functions.
 */
/* @{ */

/* Masks for maping vref to indices. */               
#define VREF_INDEX_MASK  0x07FFFFFF
#define VREF_NEGATE_MASK 0x08000000
#define VREF_TYPE_MASK   0xF0000000
#define REAL_TYPE_MASK 0x00000000
#define INT_TYPE_MASK  0x10000000
#define BOOL_TYPE_MASK 0x20000000
#define STR_TYPE_MASK  0x30000000

/**
 * \brief Translates a value reference into the corresponding index in the z vector.
 *
 * @param vref A value reference.
 * @return Index in z vector.
 */
jmi_value_reference jmi_get_index_from_value_ref(jmi_value_reference vref);

/**
 * \brief Translates a value reference into the corresponding primitive type.
 *
 * @param vref A value reference.
 * @return Type.
 */
jmi_value_reference jmi_get_type_from_value_ref(jmi_value_reference vref);

/**
 * \brief Checks if a value reference belongs to an internal negative alias
 * variable.
 *
 * @param vref A value reference.
 * @return boolean (zero or non-zero).
 */
jmi_value_reference jmi_value_ref_is_negated(jmi_value_reference vref);

/**
 * \brief Translates an index together with a type to a value reference
 * 
 * @param index An index in the z-vector
 * @param type An variable type (JMI_REAL, JMI_INT, ...)
 * @return Value Reference
 */
jmi_value_reference jmi_get_value_ref_from_index(int index, jmi_type_t type);

/**
 * \brief Compares two sets of switches.
 * 
 * Compares two sets of switches and returns (1) if they are equal and
 * (0) if not.
 * 
 * @param sw_pre The first set of switches
 * @param sw_post The second set of switches
 * @param size The size of the switches
 * @return 1 if equal, 0 if not
 */
int jmi_compare_switches(jmi_real_t* sw_pre, jmi_real_t* sw_post, jmi_int_t size);

/**
 * \brief Compares two sets of strings.
 * 
 * Compares two sets of strings and returns (1) if they are equal and
 * (0) if not.
 * 
 * @param str_pre The first set of strings
 * @param str_post The second set of strings
 * @param size The size of the strings
 * @return 1 if equal, 0 if not
 */
int jmi_compare_strings(jmi_string_t* str_pre, jmi_string_t* str_post, jmi_int_t size);

/**
 * \brief Compares two sets of discrete reals.
 * 
 * Compares two sets of discrete reals and returns (1) if they are equal and
 * (0) if not.
 * 
 * @param dr_pre The first set of discrete reals
 * @param dr_post The second set of discrete reals
 * @param nominals Nominal values of the discrete reals used in comparison
 * @param size The size of the switches
 * @return 1 if equal, 0 if not
 */
int jmi_compare_discrete_reals(jmi_real_t* dr_pre, jmi_real_t* dr_post, jmi_real_t* nominals, jmi_int_t size);

/**
 * \brief Turns a switch.
 * 
 * Turns a switch depending on the indicator value and the relation 
 * expression. The relation expression can either be >, >=, <, <=. An
 * Example is if ev_ind is postive and the relation is > then a switch
 * occurs if ev_ind is <= 0.0. If on the other hand the relation is >=
 * , then the switch occurs if ev_ind < -eps.
 * 
 * @param jmi The jmi struct
 * @param ev_ind The indicator value.
 * @param sw The switch value
 * @param eps The epsilon used for "moving" the zero.
 * @param rel The relation expression
 * @return The new switch value
 */
jmi_real_t jmi_turn_switch(jmi_t* jmi, jmi_real_t ev_ind, jmi_real_t sw, int rel);

jmi_real_t jmi_turn_switch_time(jmi_t* jmi, jmi_real_t ev_ind, jmi_real_t sw, int rel);

/**
 * \brief Returns the epsilon used when computing inStream operator.
 * 
 * @param jmi The jmi struct
 */
jmi_real_t jmi_in_stream_eps(jmi_t* jmi);

/**
 * \brief Check if file exists.
 *
 * @param file File path
 * @return Zero if not exist, non-zero otherwise.
 */
int jmi_file_exists(const char* file);

/**
 * \brief Check if directory exists.
 *
 * @param dir Directory path (without trailing separator)
 * @return Zero if not exist, non-zero otherwise.
 */
int jmi_dir_exists(const char* dir);

/**
 * \brief Returns absolute path to file in resource folder.
 *
 * @param jmi A jmi_t struct.
 * @param res A string to put the result in.
 * @param file A string describing a files relative location in the resource folder.
 * @return Absolute file path to the file.
 */
void jmi_load_resource(jmi_t *jmi, jmi_string_t res, const jmi_string_t file);

char* jmi_locate_resources(void* (*allocateMemory)(size_t nobj, size_t size));


/**
 * Create a string vector with initialized empty strings. Using malloc.
 * When assigning a new pointer the old element must be freed. Please use JMI_ASG_STR_Z(dest, src);
 */
jmi_string_t* jmi_create_strings(size_t n);

/**
 * Free a string vector created by jmi_create_strings. Will also free each element.
 */
void jmi_free_strings(jmi_string_t* s, size_t n);

typedef int (*jmi_directional_derivative_base_func_t)(void* args, jmi_real_t* x, jmi_real_t* y);

typedef int (*jmi_directional_derivative_attributes_func_t)(void* args, jmi_real_t* y);

typedef struct jmi_directional_derivative_callbacks_t jmi_directional_derivative_callbacks_t;

struct jmi_directional_derivative_callbacks_t {
	size_t n_input; /* Number of input variables */
	size_t n_output; /* Number of outputs */
	jmi_real_t* input; /* Input variable values */
	jmi_real_t* d_input; /* Direction for directional derivative */
	jmi_real_t* output; /* Output variable values */
	jmi_real_t* d_output; /* Directional derivatives for each output, to be calculated by runtime */
	jmi_directional_derivative_attributes_func_t F_max; /* Callback for max values for input variables */
	jmi_directional_derivative_attributes_func_t F_min; /*  Callback for min values for input variables */
	jmi_directional_derivative_attributes_func_t F_input_nominal; /* Callback for nominal values for input variables */
	jmi_directional_derivative_attributes_func_t F_output_nominal; /* Callback for nominal values for output variables */
	jmi_directional_derivative_base_func_t F;	
	jmi_string_t label; /* Label for origin of directional derivative callback */
};
jmi_directional_derivative_callbacks_t* jmi_create_directional_derivative_callbacks(size_t n_input, size_t n_output);

#define JMI_INIT_DIRECTIONAL_DERIVATIVE_CALLBACKS(DD, FMAX, FMIN, FNOM, FNOMOUT, F, LABEL) \
    jmi_init_directional_derivative_callbacks(DD, &FMAX, &FMIN, &FNOM, &FNOMOUT, &F, #LABEL);
void jmi_init_directional_derivative_callbacks(jmi_directional_derivative_callbacks_t* dd, jmi_directional_derivative_attributes_func_t F_max,
	jmi_directional_derivative_attributes_func_t F_min,
	jmi_directional_derivative_attributes_func_t F_input_nominal,
	jmi_directional_derivative_attributes_func_t F_output_nominal,
	jmi_directional_derivative_base_func_t F,	
	jmi_string_t label);
void jmi_free_directional_derivative_callbacks(jmi_directional_derivative_callbacks_t* dd);
int jmi_evaluate_directional_derivative(jmi_t* jmi, jmi_directional_derivative_callbacks_t* dd_callback, void* args);

#endif
