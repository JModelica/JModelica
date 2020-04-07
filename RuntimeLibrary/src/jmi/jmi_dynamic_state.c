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

/*
 * jmi_dynamic_state.c contains functions that work with jmi_dynamic_state_set_t
 */
 
#include "jmi.h"
#include "jmi_util.h"
#include "jmi_dynamic_state.h"

#include <stdarg.h>

#define SAFETY_FACTOR 0.1
#define SAFETY_TOLERANCE 1e-8

int jmi_dynamic_state_add_set(jmi_t* jmi, int index, int n_variables, int n_states, int* variable_value_references, int* ds_state_value_references, int* ds_algebraic_value_references, jmi_dynamic_state_coefficents_func_t coefficents) {
    jmi_dynamic_state_set_t *set = &jmi->dynamic_state_sets[index];
    int i = 0;
    
    set->variables_value_references = (jmi_int_t*)calloc(n_variables,sizeof(jmi_int_t));
    set->state_value_references = (jmi_int_t*)calloc(n_states,sizeof(jmi_int_t));
    set->ds_state_value_references = (jmi_int_t*)calloc(n_states,sizeof(jmi_int_t));
    set->ds_state_value_local_index = (jmi_int_t*)calloc(n_states,sizeof(jmi_int_t));
    set->algebraic_value_references = (jmi_int_t*)calloc(n_variables-n_states,sizeof(jmi_int_t));
    set->temp_algebraic = (jmi_int_t*)calloc(n_variables-n_states,sizeof(jmi_int_t));
    set->ds_algebraic_value_references = (jmi_int_t*)calloc(n_variables-n_states,sizeof(jmi_int_t));
    set->ds_algebraic_value_local_index = (jmi_int_t*)calloc(n_variables-n_states,sizeof(jmi_int_t));
    set->coefficent_matrix = (jmi_real_t*)calloc((n_variables-n_states)*n_variables,sizeof(jmi_real_t));
    set->sub_coefficent_matrix = (jmi_real_t*)calloc((n_variables-n_states)*(n_variables-n_states),sizeof(jmi_real_t));
    set->n_variables = n_variables;
    set->n_states = n_states;
    set->n_algebraics = n_variables-n_states;
    set->coefficents = coefficents;
    
    set->dgeqp3_lwork = 3*n_variables+1;
    set->dgeqp3_work = (double*)calloc(set->dgeqp3_lwork,sizeof(double));
    set->dgeqp3_jpvt = (int*)calloc(set->n_variables, sizeof(int));
    set->dgeqp3_tau = (double*)calloc(set->n_algebraics, sizeof(double));
    
    for (i = 0; i < n_variables; i++) {
        set->variables_value_references[i] = variable_value_references[i];
    }
    /* As default, choose the first variables to the states */
    for (i = 0; i < n_states; i++) {
        set->state_value_references[i] = variable_value_references[i];
        set->ds_state_value_references[i] = ds_state_value_references[i];
    }
    for (i = 0; i < n_variables-n_states; i++) {
        set->algebraic_value_references[i] = variable_value_references[i+n_states];
        set->ds_algebraic_value_references[i] = ds_algebraic_value_references[i];
        set->ds_algebraic_value_local_index[i] = i+n_states;
    }
    
    return JMI_OK;
}

int jmi_dynamic_state_delete_set(jmi_t* jmi, jmi_int_t index) {
    jmi_dynamic_state_set_t *set = &jmi->dynamic_state_sets[index];
    
    free(set->variables_value_references);
    free(set->state_value_references);
    free(set->ds_state_value_references);
    free(set->ds_state_value_local_index);
    free(set->algebraic_value_references);
    free(set->ds_algebraic_value_references);
    free(set->ds_algebraic_value_local_index);
    free(set->coefficent_matrix);
    free(set->sub_coefficent_matrix);
    free(set->temp_algebraic);
    
    free(set->dgeqp3_work);
    free(set->dgeqp3_jpvt);
    free(set->dgeqp3_tau);
    
    return JMI_OK;
}

static int jmi_dynamic_state_perform_update_algebraics(jmi_t* jmi, jmi_dynamic_state_set_t* set) {
    int i = 0;
    int k = 0;
    
    for (i = 0; i < set->n_algebraics; i++) {
        set->algebraic_value_references[i] = set->temp_algebraic[i];
    }
    for (i = 0; i < set->n_variables; i++) {
        if (set->variables_value_references[i] == set->algebraic_value_references[k]) {
            set->ds_algebraic_value_local_index[k] = i;
            k++;
        }
    }
    
    return JMI_OK;
}

static int jmi_dynamic_state_perform_update_states(jmi_t* jmi, jmi_dynamic_state_set_t* set) {
    int i = 0;
    int k = 0;
    int j = 0;
    
    for (i = 0; i < set->n_variables; i++) {
        if (set->variables_value_references[i] != set->algebraic_value_references[k]) {
            set->state_value_references[j] = set->variables_value_references[i];
            j++;
        } else {
            k++;
        }
        
        if (k >= set->n_algebraics) { break; }
    }
    for (i = i+1; i < set->n_variables; i++) {
        set->state_value_references[j] = set->variables_value_references[i];
        j++;
    }
    return JMI_OK;
}

int jmi_dynamic_state_perform_update(jmi_t* jmi, jmi_int_t index_set) {
    jmi_dynamic_state_set_t *set = &jmi->dynamic_state_sets[index_set];
    jmi_log_node_t node={0};
    
    if (jmi->jmi_callbacks.log_options.log_level >= 5) {
        node = jmi_log_enter_fmt(jmi->log, logInfo, "DynamicStatesUpdate", 
                                "Updating the dynamic states in <set:%I>", index_set);
        jmi_log_vrefs(jmi->log, node, logInfo, "old_states", 'r', set->state_value_references, set->n_states);
        jmi_log_vrefs(jmi->log, node, logInfo, "old_algebraics", 'r', set->algebraic_value_references, set->n_algebraics);
    }
    
    /* Update algebraics */
    jmi_dynamic_state_perform_update_algebraics(jmi, set);
    
    /* Update states */
    jmi_dynamic_state_perform_update_states(jmi, set);
    
    /* Copy the values of the states and algebraics to the ds values */
    jmi_dynamic_state_copy_to_ds_values_single(jmi, index_set);

    /* Set that the states has been updated */
    jmi->updated_states = TRUE;
    
    if (jmi->jmi_callbacks.log_options.log_level >= 5) {
        jmi_log_vrefs(jmi->log, node, logInfo, "new_states", 'r', set->state_value_references, set->n_states);
        jmi_log_vrefs(jmi->log, node, logInfo, "new_algebraics", 'r', set->algebraic_value_references, set->n_algebraics);
        jmi_log_leave(jmi->log, node);
    }
    
    return JMI_OK;
}

int jmi_dynamic_state_copy_to_ds_values_single(jmi_t* jmi, jmi_int_t index_set) {
    jmi_dynamic_state_set_t *set = &jmi->dynamic_state_sets[index_set];
    int i;
    jmi_real_t *z;
    
    /* Update the ds state values  */
    for (i = 0; i < set->n_states; i++) {
        z = jmi_get_z(jmi);
        z[jmi_get_index_from_value_ref(set->ds_state_value_references[i])] = z[jmi_get_index_from_value_ref(set->state_value_references[i])];
    }
    /* Update the ds algebraic values  */
    for (i = 0; i < set->n_algebraics; i++) {
        z = jmi_get_z(jmi);
        z[jmi_get_index_from_value_ref(set->ds_algebraic_value_references[i])] = z[jmi_get_index_from_value_ref(set->algebraic_value_references[i])];
    }
    
    return JMI_OK;
}

int jmi_dynamic_state_copy_to_ds_values(jmi_t* jmi) {
    int i;
    
    for (i = 0; i < jmi->n_dynamic_state_sets; i++) {
        jmi_dynamic_state_copy_to_ds_values_single(jmi, i);
    }
    
    return JMI_OK;
}

static int jmi_dynamic_state_sort(jmi_t* jmi, int* array, int n) {
    int i, j, a;
    
    for (i = 0; i < n; ++i) {
        for (j = i + 1; j < n; ++j) {
            if (array[i] > array[j]) {
                a =  array[i];
                array[i] = array[j];
                array[j] = a;
            }
        }
    }
    return JMI_OK;
}

int jmi_dynamic_state_check_for_new_states(jmi_t* jmi, jmi_int_t index_set) {
    jmi_dynamic_state_set_t *set = &jmi->dynamic_state_sets[index_set];
    jmi_int_t new_states = FALSE;
    jmi_log_node_t node={0};
    
    /* Update the coefficients */
    set->coefficents(jmi, set->coefficent_matrix);
    
    if (jmi->jmi_callbacks.log_options.log_level >= 5) {
        node = jmi_log_enter_fmt(jmi->log, logInfo, "DynamicStatesChecking", 
                            "Verifying the dynamic states in <set:%I>", index_set);
        jmi_log_vrefs(jmi->log, node, logInfo, "variables", 'r', set->variables_value_references, set->n_variables);
        jmi_log_vrefs(jmi->log, node, logInfo, "states", 'r', set->state_value_references, set->n_states);
        jmi_log_vrefs(jmi->log, node, logInfo, "algebraics", 'r', set->algebraic_value_references, set->n_algebraics);
        jmi_log_real_matrix(jmi->log, node, logInfo, "CoefficientMatrix", set->coefficent_matrix, set->n_variables-set->n_states, set->n_variables);
    }
    
    if (set->n_variables - set->n_states == 1) {
        int i = 0;
        jmi_int_t best_choice = set->algebraic_value_references[0];
        jmi_real_t best_value = -1;
        
        for (i = 0; i < set->n_variables; i++) {
            if (set->algebraic_value_references[0] == set->variables_value_references[i]) {
                if (JMI_ABS(set->coefficent_matrix[i]) < SAFETY_FACTOR) {
                    /* Look if there are any other better choice */
                    best_value = JMI_ABS(set->coefficent_matrix[i]);
                }
            }
        }
        if (best_value != -1) {
            jmi_log_node(jmi->log, logInfo, "Info", "Looking for new dynamic states in <set:%I> due to <value:%E>.",index_set, best_value);
            for (i = 0; i < set->n_variables; i++) {
                if (JMI_ABS(best_value) < JMI_ABS(set->coefficent_matrix[i])) {
                    best_value = JMI_ABS(set->coefficent_matrix[i]);
                    best_choice = set->variables_value_references[i];
                }
            }
        }
        
        if (best_value != -1 && best_choice != set->algebraic_value_references[0]) {
            new_states = TRUE;
            set->temp_algebraic[0] = best_choice;
        }
        
        if (new_states == JMI_TRUE) {
            jmi_log_node(jmi->log, logInfo, "Info", "Found new dynamic states in <set:%I>. Changing algebraic to <real: #r%d#>.",
             index_set, best_choice);
        }
    } else {
        int info = 0, i;
        int best_choice_choosen = TRUE;
        jmi_real_t rr = 0.0, rr_new = 0.0;
        
        for (i = 0; i < set->n_algebraics; i++) { 
            memcpy(&set->sub_coefficent_matrix[i*set->n_algebraics], &set->coefficent_matrix[set->ds_algebraic_value_local_index[i]*set->n_algebraics], set->n_algebraics*sizeof(jmi_real_t)); 
        }
        dgeqp3_(&set->n_algebraics, &set->n_algebraics, set->sub_coefficent_matrix, &set->n_algebraics, set->dgeqp3_jpvt, set->dgeqp3_tau, set->dgeqp3_work, &set->dgeqp3_lwork, &info);
        
        if (info != 0) {
            if (jmi->jmi_callbacks.log_options.log_level >= 5) { jmi_log_leave(jmi->log, node); }
            jmi_log_node(jmi->log, logError, "DynamicState", "Failed to perform a QR factorization of the sub coefficient matrix in <set:%I>", index_set);
            return FALSE;
        }
        
        rr = JMI_ABS(set->sub_coefficent_matrix[set->n_algebraics*set->n_algebraics-1]);
        if (rr > SAFETY_FACTOR) {
            jmi_log_node(jmi->log, logInfo, "Info", "Satisfied with the current choice due to <rr:%E> in <set:%I>.",
                rr, index_set);
            if (jmi->jmi_callbacks.log_options.log_level >= 5) {
                jmi_log_real_matrix(jmi->log, node, logInfo, "R", set->sub_coefficent_matrix, set->n_algebraics, set->n_algebraics);
                jmi_log_leave(jmi->log, node);
            }
            return new_states;
        } else {
            jmi_log_node(jmi->log, logInfo, "Info", "Not satisfied with the current choice due to <rr:%E> in <set:%I>.",
                rr, index_set);
            if (jmi->jmi_callbacks.log_options.log_level >= 5) {
                jmi_log_real_matrix(jmi->log, node, logInfo, "R", set->sub_coefficent_matrix, set->n_algebraics, set->n_algebraics);
            }
        }
        
        
        memset(set->dgeqp3_jpvt, 0, set->n_variables * sizeof(int));
        dgeqp3_(&set->n_algebraics, &set->n_variables, set->coefficent_matrix, &set->n_algebraics, set->dgeqp3_jpvt, set->dgeqp3_tau, set->dgeqp3_work, &set->dgeqp3_lwork, &info);
        
        if (info == 0) {
            if (jmi->jmi_callbacks.log_options.log_level >= 5) {
                jmi_log_ints(jmi->log, node, logInfo, "pivoting", set->dgeqp3_jpvt, set->n_variables);
                jmi_log_real_matrix(jmi->log, node, logInfo, "R", set->coefficent_matrix, set->n_algebraics, set->n_variables);
            }
        } else {
            if (jmi->jmi_callbacks.log_options.log_level >= 5) { jmi_log_leave(jmi->log, node); }
            jmi_log_node(jmi->log, logError, "DynamicState", "Failed to perform a QR factorization of the coefficient matrix in <set:%I>", index_set);
            return FALSE;
        }
        
        /* Get the new rr value */
        rr_new = JMI_ABS(set->coefficent_matrix[set->n_algebraics*set->n_algebraics-1]);
        
        /* Check if there is an improvement */
        if (rr_new <= rr*(1+SAFETY_TOLERANCE)) { /* No improvement */
            if (jmi->jmi_callbacks.log_options.log_level >= 5) {
                jmi_log_node(jmi->log, logInfo, "Info", "No improvement when considering other states (<rr:%E> and <rr_new:%E>), keeping the current values in <set:%I>.",
                rr, rr_new, index_set);
                jmi_log_leave(jmi->log, node);
            }
            new_states = FALSE;
            return new_states;
        } else {
            if (jmi->jmi_callbacks.log_options.log_level >= 5) {
                jmi_log_node(jmi->log, logInfo, "Info", "Considering other states as <rr:%E> and <rr_new:%E> in <set:%I>.",
                rr, rr_new, index_set);
            }
        }
        
        jmi_dynamic_state_sort(jmi, set->dgeqp3_jpvt, set->n_algebraics);
        
        if (jmi->jmi_callbacks.log_options.log_level >= 5) {
            jmi_log_ints(jmi->log, node, logInfo, "sorted", set->dgeqp3_jpvt, set->n_variables);
        }
        
        for (i = 0; i < set->n_algebraics; i++) {
            if (set->algebraic_value_references[i] != set->variables_value_references[set->dgeqp3_jpvt[i]-1]) {
                best_choice_choosen = FALSE;
            }
        }
        
        if (best_choice_choosen == JMI_FALSE) {
            jmi_log_node(jmi->log, logInfo, "Info", "Found new optimal choice of states in <set:%I>.", index_set);
            
            new_states = TRUE;
            for (i = 0; i < set->n_algebraics; i++) {
                set->temp_algebraic[i] = set->variables_value_references[set->dgeqp3_jpvt[i]-1];
            }
            if (jmi->jmi_callbacks.log_options.log_level >= 5) {
                jmi_log_vrefs(jmi->log, node, logInfo, "new_algebraics", 'r', set->temp_algebraic, set->n_algebraics);
            }
        }
    }
    
    if (jmi->jmi_callbacks.log_options.log_level >= 5) { jmi_log_leave(jmi->log, node); }
    
    return new_states;
}

int jmi_dynamic_state_update_states(jmi_t* jmi, jmi_int_t index_set) {    
    jmi_int_t new_states = jmi_dynamic_state_check_for_new_states(jmi, index_set);
    
    if (new_states == JMI_TRUE) {
        jmi_dynamic_state_perform_update(jmi, index_set);
    }
    
    return JMI_OK;
}

int jmi_dynamic_state_update(jmi_t* jmi) {
    int i;
    
    for (i = 0; i < jmi->n_dynamic_state_sets; i++) {
        jmi_dynamic_state_update_states(jmi, i);
    }
    
    return JMI_OK;
}

int jmi_dynamic_state_verify_choice(jmi_t* jmi) {
    int i = 0;
    jmi_int_t new_states = FALSE;
    jmi_log_node_t node={0};
    
    if (jmi->jmi_callbacks.log_options.log_level >= 5) {
        node = jmi_log_enter_fmt(jmi->log, logInfo, "DynamicStatesVerifying", 
                            "Verifying the dynamic states.");
    }
    
    for (i = 0; i < jmi->n_dynamic_state_sets; i++) {
        new_states = jmi_dynamic_state_check_for_new_states(jmi, i);
        if (new_states == JMI_TRUE) {
            if (jmi->jmi_callbacks.log_options.log_level >= 5) {
                jmi_log_node(jmi->log, logInfo, "Info", "Detected bad choice of dynamic states in <set:%I>.",i);
                jmi_log_leave(jmi->log, node);
            }
            return JMI_UPDATE_STATES;
        }
    }
    
    if (jmi->jmi_callbacks.log_options.log_level >= 5) { jmi_log_leave(jmi->log, node); }
    
    return JMI_OK;
}

int jmi_dynamic_state_check_is_state(jmi_t* jmi, jmi_int_t index, ...) {
    jmi_dynamic_state_set_t *set = &jmi->dynamic_state_sets[index];
    int ret = TRUE;
    int i = 0;
    jmi_log_node_t node={0};
    
    va_list ap;
    va_start(ap, index);
    
    if (jmi->jmi_callbacks.log_options.log_level >= 5) {
        node = jmi_log_enter_fmt(jmi->log, logInfo, "DynamicStatesCheck", 
                            "Checking if the following are states.");
    }
    
    for (i = 0; i < set->n_states; i++) {
        jmi_int_t value_reference = va_arg(ap, jmi_int_t);
        
        if (jmi->jmi_callbacks.log_options.log_level >= 5) {
            jmi_log_vrefs(jmi->log, node, logInfo, "is_state", 'r', &value_reference, 1);
        }
        
        if (set->state_value_references[i] != value_reference) {
            ret = FALSE;
            break;
        }
    }
    va_end(ap);
    
    if (jmi->jmi_callbacks.log_options.log_level >= 5) { jmi_log_leave(jmi->log, node); }
    
    return ret;
}
