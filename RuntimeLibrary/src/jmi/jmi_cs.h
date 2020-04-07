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

#ifndef JMI_CS_H
#define JMI_CS_H

#include "jmi.h"
#include "jmi_ode_problem.h"
#include "jmi_me.h"

#define JMI_CS_MAX_INPUT_DERIVATIVES 3

struct jmi_cs_real_input_t {
    jmi_value_reference vr;         /**< \brief Valuereference of the real input*/
    jmi_real_t tn;                  /**< \brief Time when the input was specified. */
    jmi_real_t value;
    jmi_boolean active;
    jmi_real_t input_derivatives[JMI_CS_MAX_INPUT_DERIVATIVES];
    jmi_real_t input_derivatives_factor[JMI_CS_MAX_INPUT_DERIVATIVES];
};

typedef struct {
    jmi_cs_real_input_t* real_inputs;   /**< \brief List of real inputs with derivative information */
    size_t n_real_inputs;               /**< \brief Number of real inputs in real_inputs list */
    
    void* fmix_me;                      /**< \brief The underlying Model Exchange/ODE implementation */
} jmi_cs_data_t;

int jmi_cs_set_real_input_derivatives(jmi_cs_data_t* cs_data, jmi_log_t* log, 
        const jmi_value_reference vr[], size_t nvr, const int order[],
        const jmi_real_t value[]);
        
int jmi_cs_init_real_input_struct(jmi_cs_real_input_t* real_input);

/**
 * \brief Checks if the user is changing the values of any discrete inputs.
 * 
 * @param jmi The jmi_t struct.
 * @param vr The value references of values the user is setting.
 * @param nvr The number of value references.
 * @param value The new values for variables.
 * @return True if the input would result in changes of discrete inputs sent to
 * a fmiX_set_XXX function.
 */
int jmi_cs_check_discrete_input_change(jmi_t*                       jmi,
                                       const jmi_value_reference    vr[],
                                       size_t                       nvr,
                                       const void*                  value);

/**
 * \brief Checks if the user is changing the values of any real inputs.
 * 
 * @param jmi The jmi_t struct.
 * @param vr The value references of values the user is setting.
 * @param nvr The number of value references.
 * @param value The new values for variables.
 * @return True if the input would result in changes of real inputs sent to
 * a fmiX_set_XXX function.
 */
int jmi_cs_check_input_change(jmi_t*                       jmi,
                                       const jmi_value_reference    vr[],
                                       size_t                       nvr,
                                       const jmi_real_t*                  value);

/**
 * \brief Frees all data for struct allocated by the jmi_new_cs_data function.
 * 
 * @param cs_data The jmi_cs_data_t struct.
 */
void jmi_free_cs_data(jmi_cs_data_t* cs_data);


/**
 * \brief Resets the jmi_cs_data_t instance. The struct will be in the state
 * it was after jmi_new_cs_data. NOTE that this does not mean that the struct
 * that fmix_me points to is reset. So jmi_cs_data_t don't own it but only holds
 * a reference to and use it.
 *
 * @param cs_data A jmi_cs_data_t struct.
  */
void jmi_reset_cs_data(jmi_cs_data_t* cs_data);

/**
 * \brief Allocates all data for the jmi_cs_data_t struct.
 * 
 * @param fmix_me A pointer to the ME struct that the CS data should be used to wrap.
 * @param n_real_inputs The number of real inputs of the model.
 * @return A pointer to the allocated jmi_cs_data struct, NULL on failure.
 */
jmi_cs_data_t* jmi_new_cs_data(void* fmix_me, size_t n_real_inputs);

#endif /* JMI_CS_H */
