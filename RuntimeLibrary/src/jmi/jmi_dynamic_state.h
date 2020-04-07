 /*
    Copyright (C) 2015 Modelon AB

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


/** \file jmi_dynamic_state.h
 *  \brief Structures and functions for handling dynamic state select.
 */

#ifndef _JMI_DYNAMIC_STATE_H
#define _JMI_DYNAMIC_STATE_H

#include "jmi_types.h"

/* Lapack functions */
extern void dgeqp3_(int* M, int* N, double* A, int* LDA, int* JPVT, double* TAU, double* WORK, int* LWORK, int* INFO );

typedef int (*jmi_dynamic_state_coefficents_func_t)(jmi_t* jmi, jmi_real_t* residual);

struct jmi_dynamic_state_set_t {
    jmi_int_t n_variables;
    jmi_int_t n_states;
    jmi_int_t n_algebraics;
    jmi_int_t *variables_value_references;
    jmi_int_t *state_value_references;
    jmi_int_t *ds_state_value_references;
    jmi_int_t *ds_state_value_local_index;
    jmi_int_t *algebraic_value_references;
    jmi_int_t *ds_algebraic_value_references;
    jmi_int_t *ds_algebraic_value_local_index;
    jmi_int_t *temp_algebraic;
    jmi_real_t *coefficent_matrix;
    jmi_real_t *sub_coefficent_matrix;
    double* dgeqp3_work;
    double* dgeqp3_tau;
    int* dgeqp3_jpvt;
    int dgeqp3_lwork;
    jmi_dynamic_state_coefficents_func_t coefficents;
};

/**
 * \brief Copy the values of the choosen states and algebraics to the ds variables.
 *
 * @param jmi A jmi_t struct.
 */
int jmi_dynamic_state_copy_to_ds_values(jmi_t* jmi);

/**
 * \brief Copy the values of the choosen states and algebraics to the ds variables in a set.
 *
 * @param jmi A jmi_t struct.
 * @param index_set The set to copy.
 */
int jmi_dynamic_state_copy_to_ds_values_single(jmi_t* jmi, jmi_int_t index_set);

/**
 * \brief Perform an actual update of in a set.
 *
 * @param jmi A jmi_t struct.
 * @param index_set The set to update
 */
int jmi_dynamic_state_perform_update(jmi_t* jmi, jmi_int_t index_set);

/**
 * \brief Check for and update the states in a set.
 *
 * @param jmi A jmi_t struct.
 * @param index_set The set to check and update
 */
int jmi_dynamic_state_update_states(jmi_t* jmi, jmi_int_t index_set);

/**
 * \brief Check for and update the states in ALL sets.
 *
 * @param jmi A jmi_t struct.
 */
int jmi_dynamic_state_update(jmi_t* jmi);

/**
 * \brief Verify the choosen states in ALL sets.
 *
 * @param jmi A jmi_t struct.
 */
int jmi_dynamic_state_verify_choice(jmi_t* jmi);

/**
 * \brief Deletes a ynamic state set.
 *
 * @param jmi A jmi_t struct.
 * @param index The set index
 */
int jmi_dynamic_state_delete_set(jmi_t* jmi, jmi_int_t index);

/**
 * \brief Adds a new dynamic state set.
 *
 * @param jmi A jmi_t struct.
 * @param index The set index
 * @param n_variables The number of variables in the set
 * @param n_states The number of states to choose from the set
 * @param variable_value_references The variables value references in the set
 * @param state_value_references The value references to the dynamic states choosen (i.e. the ds.s*.s* variables)
 * @param algebraic_value_references The value references to the dynamic algebraics choosen (i.e. the ds.s*.a* variables)
 * @param coefficients The coefficent matrix.
 */
int jmi_dynamic_state_add_set(jmi_t* jmi, int index, int n_variables, int n_states, int* variable_value_references, int* state_value_references, int* algebraic_value_references, jmi_dynamic_state_coefficents_func_t coefficents); 

/**
 * \brief Check if the provided states are choosen as states.
 *
 * @param jmi A jmi_t struct.
 * @param index_set The set to look for states
 * @param ... The states to verify
 * @return JMI_TRUE if the states are choosen, otherwise JMI_FALSE
 */
int jmi_dynamic_state_check_is_state(jmi_t* jmi, jmi_int_t index_set, ...);


#endif /* _JMI_DYNAMIC_STATE_H */


