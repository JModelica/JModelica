 /*
    Copyright (C) 2016 Modelon AB

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

#include <stdlib.h>
#include <jmi_get_set.h>

#define NOT_USED(x) ((void)x)

typedef struct jmi_get_set_module_t jmi_get_set_module_t;

struct jmi_get_set_module_t {
    int dummy_placeholder;
};

#define GET_MODULE(j) ((j)->modules.mod_get_set)

#define RECOMPUTE_VARIABLES(j)     ((j)->recomputeVariables)
#define RECOMPUTE_VARIABLES_SET(j) (RECOMPUTE_VARIABLES(j) = 1)
#define RECOMPUTE_VARIABLES_CLR(j) (RECOMPUTE_VARIABLES(j) = 0)

int jmi_get_set_module_init(jmi_t *jmi) {
    jmi_get_set_module_t *module;
    int result = JMI_ERROR;

    if ((module = (jmi_get_set_module_t*)malloc(sizeof(*module))) == NULL) {
        goto error;
    }

    GET_MODULE(jmi) = (jmi_module_t*)module;

    result = JMI_OK;
error:
    return result;
}

void
jmi_get_set_module_destroy(jmi_t *jmi)
{
    if (jmi && GET_MODULE(jmi)) {
        free(GET_MODULE(jmi));

        GET_MODULE(jmi) = (jmi_module_t*)0;
    }
}

/* Local helper for doing evaluations before we set a value and check what needs to be marked as dirty */
void jmi_set_recompute(jmi_t* jmi, int index, int offset, int* needRecomputeVars, int* needParameterUpdate) {
    *needRecomputeVars = 1;
    if (index < offset) {
        *needParameterUpdate = 1;
    }
}

/* Local helper for updating variables after one is set */
int jmi_set_update(jmi_t* jmi, int needParameterUpdate, int needRecomputeVars) {
    if (needParameterUpdate) {
        jmi_init_eval_dependent_set_dirty(jmi);
    }
    if(needRecomputeVars) {
        RECOMPUTE_VARIABLES_SET(jmi);
    }
    return 0;
}

int jmi_set_real_impl(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr,
                 const jmi_real_t value[]) {
    jmi_value_reference i;
    jmi_value_reference index;
    jmi_real_t* z = jmi_get_z(jmi);
    int needParameterUpdate = 0;
    int needRecomputeVars = 0;
    
    for (i = 0; i < nvr; i = i + 1) {
        index = jmi_get_index_from_value_ref(vr[i]);
        if(z[index] != value[i]) {
            jmi_set_recompute(jmi, index, jmi->offs_real_dx, &needRecomputeVars, &needParameterUpdate);
            z[index] = value[i];
        }
    }
    
    return jmi_set_update(jmi, needParameterUpdate, needRecomputeVars);
}

int jmi_set_integer_impl(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr,
                    const jmi_int_t value[]) {
    jmi_value_reference i;
    jmi_value_reference index;
    jmi_real_t* z = jmi_get_z(jmi);
    int needParameterUpdate = 0;
    int needRecomputeVars = 0;
    
    for (i = 0; i < nvr; i = i + 1) {
        index = jmi_get_index_from_value_ref(vr[i]);
        if(z[index] != value[i]) {
            jmi_set_recompute(jmi, index, jmi->offs_real_dx, &needRecomputeVars, &needParameterUpdate);
            z[index] = value[i];
        }
    }
    
    return jmi_set_update(jmi, needParameterUpdate, needRecomputeVars);
}

int jmi_set_boolean_impl(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr,
                    const jmi_boolean value[]) {
    jmi_value_reference i;
    jmi_value_reference index;
    jmi_real_t* z = jmi_get_z(jmi);
    int needParameterUpdate = 0;
    int needRecomputeVars = 0;
    
    for (i = 0; i < nvr; i = i + 1) {
        index = jmi_get_index_from_value_ref(vr[i]);
        if(z[index] != value[i]) {
            jmi_set_recompute(jmi, index, jmi->offs_real_dx, &needRecomputeVars, &needParameterUpdate);
            z[index] = value[i];
        }
    }
    
    return jmi_set_update(jmi, needParameterUpdate, needRecomputeVars);
}

int jmi_set_string_impl(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr,
                   const jmi_string value[]) {
    jmi_value_reference i;
    jmi_value_reference index;
    char** z = jmi_get_string_z(jmi);
    int needParameterUpdate = 0;
    int needRecomputeVars = 0;
    size_t len;

    for (i = 0; i < nvr; i = i + 1) {
        if (jmi_get_type_from_value_ref(vr[i]) != JMI_STRING) {
            jmi_log_node(jmi->log, logError, "SetValueFailed", "Error setting string, value reference points to non-string.");
            return -1;
        }
    }
    
    for (i = 0; i < nvr; i = i + 1) {
        index = jmi_get_index_from_value_ref(vr[i]);
        len = strlen(z[index]);
        if(len != strlen(value[i]) || strncmp(z[index], value[i], len) != 0) {
            jmi_set_recompute(jmi, index, jmi->z_t.strings.offs.w, &needRecomputeVars, &needParameterUpdate);
            JMI_ASG_STR_Z(z[index], value[i]);
        }
    }
    
    return jmi_set_update(jmi, needParameterUpdate, needRecomputeVars);
}

/* Local helper for checking if we need to evaluate discrete or continuous variables */
static int jmi_evaluate_variables_required(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr, size_t offset) {
    jmi_value_reference i;
    for (i = 0; i < nvr; i++) {
        if (jmi_get_index_from_value_ref(vr[i]) >= offset) {
            return 1;
        }
    }
    return 0;
}

/* Local helper for updating variables before one is retrieved */
int jmi_get_update(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr, size_t offset) {
    int retval;
    int eval_variables_required;
    
    retval = jmi_init_eval_dependent(jmi);
    if (retval != 0) {
        return -1;
    }
    
    eval_variables_required = jmi_evaluate_variables_required(jmi, vr, nvr, offset);
    if (jmi->recomputeVariables == 1 && jmi->is_initialized == 1 && eval_variables_required == 1 && jmi->user_terminate == 0) {
        retval = jmi_ode_derivatives(jmi);
        if(retval != 0) {
            jmi_log_node(jmi->log, logError, "ModelEquationsEvaluationFailed", "Error evaluating model equations.");
            jmi_reset_internal_variables(jmi);
            return -1;
        }
        RECOMPUTE_VARIABLES_CLR(jmi);
    }
    return 0;
}

int jmi_get_real_impl(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr,
                 jmi_real_t value[]) {

    int retval;
    jmi_value_reference i;
    jmi_value_reference index;
    jmi_real_t* z;

    retval = jmi_get_update(jmi, vr, nvr, jmi->offs_real_dx);
    if (retval != 0) {
        return retval;
    }

    z = jmi_get_z(jmi);

    for (i = 0; i < nvr; i = i + 1) {
        index = jmi_get_index_from_value_ref(vr[i]);
        value[i] = (jmi_real_t)z[index];
    }

    return 0;
}

int jmi_get_integer_impl(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr,
                    jmi_int_t value[]) {

    int retval;
    jmi_real_t* z;
    jmi_value_reference i;
    jmi_value_reference index;

    retval = jmi_get_update(jmi, vr, nvr, jmi->offs_real_dx);
    if (retval != 0) {
        return retval;
    }

    z = jmi_get_z(jmi);

    for (i = 0; i < nvr; i = i + 1) {
        index = jmi_get_index_from_value_ref(vr[i]);
        value[i] = (jmi_int_t)z[index];
    }
    return 0;
}

int jmi_get_boolean_impl(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr,
                    jmi_boolean value[]) {

    int retval;
    jmi_real_t* z;
    jmi_value_reference i;
    jmi_value_reference index;

    retval = jmi_get_update(jmi, vr, nvr, jmi->offs_real_dx);
    if (retval != 0) {
        return retval;
    }

    z = jmi_get_z(jmi);

    for (i = 0; i < nvr; i = i + 1) {
        index = jmi_get_index_from_value_ref(vr[i]);
        value[i] = z[index];
    }
    return 0;
}

int jmi_get_string_impl(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr,
                   jmi_string  value[]) {

    int retval;
    int i;
    jmi_string_t* z;
    jmi_value_reference index;

    retval = jmi_get_update(jmi, vr, nvr, jmi->z_t.strings.offs.w);
    if (retval != 0) {
        return retval;
    }

    z = jmi_get_string_z(jmi);

    for (i = 0; i < nvr; i++) {
        index = jmi_get_index_from_value_ref(vr[i]);
        value[i] = z[index];
    }

    return 0;
}

int jmi_set_time_impl(jmi_t* jmi, jmi_real_t time) {
    jmi_real_t* time_old = (jmi_get_t(jmi));

    if (*time_old != time) {
        if (*time_old > time && jmi->is_initialized == 1) {
            jmi_reset_internal_variables(jmi);
        }

        *time_old = time;
        RECOMPUTE_VARIABLES_SET(jmi);
    }

    return 0;
}

int jmi_set_continuous_states_impl(jmi_t* jmi, const jmi_real_t x[], size_t nx) {
    jmi_real_t* x_cur = jmi_get_real_x(jmi);
    size_t i;

    for (i = 0; i < nx; i++){
        if (x_cur[i] != x[i]){
            x_cur[i] = x[i];

            RECOMPUTE_VARIABLES_SET(jmi);
        }
    }
    return 0;
}

int jmi_get_event_indicators_impl(jmi_t* jmi, jmi_real_t eventIndicators[], size_t ni) {
    int retval;
    jmi_log_node_t node={0};

    if (jmi->jmi_callbacks.log_options.log_level >= 5){
        node =jmi_log_enter_fmt(jmi->log, logInfo, "GetEventIndicators",
                                "Call to get event indicators at <t:%g>.", jmi_get_t(jmi)[0]);
    }

    if (RECOMPUTE_VARIABLES(jmi) == 1 && jmi->user_terminate == 0) {
        retval = jmi_ode_derivatives(jmi);
        if(retval != 0) {
            jmi_log_node(jmi->log, logWarning, "Warning",
                "Evaluating the derivatives failed while evaluating the event indicators at <t:%g>, retrying with restored values.", jmi_get_t(jmi)[0]);
            /* If it failed, reset to the previous succesful values */

            jmi_reset_internal_variables(jmi);

            /* Try again */
            retval = jmi_ode_derivatives(jmi);
            if(retval != 0) {
                if (jmi->jmi_callbacks.log_options.log_level >= 5){
                    jmi_log_leave(jmi->log, node);
                }
                jmi_log_node(jmi->log, logError, "Error",
                    "Evaluating the derivatives failed while evaluating the event indicators at <t:%g>", jmi_get_t(jmi)[0]);
                /* If it failed, reset to the previous succesful values */
                jmi_reset_internal_variables(jmi);

                return -1;
            }
        }

        RECOMPUTE_VARIABLES_CLR(jmi);
    }

    retval = jmi_dae_R_perturbed(jmi,eventIndicators);
    if(retval != 0) {
        jmi_log_node(jmi->log, logError, "EventIndicatorsEvaluationFailed", "Error evaluating event indicators.");
        if (jmi->jmi_callbacks.log_options.log_level >= 5){
            jmi_log_leave(jmi->log, node);
        }
        return -1;
    }

    if (jmi->jmi_callbacks.log_options.log_level >= 5){
        jmi_log_reals(jmi->log, node, logInfo, "Event Indicators", eventIndicators, ni);
        jmi_log_leave(jmi->log, node);
    }

    return 0;
}

int jmi_get_derivatives_impl(jmi_t* jmi, jmi_real_t derivatives[] , size_t nx) {
    int retval;
    jmi_log_node_t node={0};

    if (jmi->jmi_callbacks.log_options.log_level >= 5){
        node =jmi_log_enter_fmt(jmi->log, logInfo, "GetDerivatives",
                                "Call to get derivatives at <t:%g>.", jmi_get_t(jmi)[0]);
        if (jmi->jmi_callbacks.log_options.log_level >= 6){
            jmi_log_reals(jmi->log, node, logInfo, "switches", jmi_get_sw(jmi), jmi->n_sw);
            jmi_log_reals(jmi->log, node, logInfo, "booleans", jmi_get_boolean_d(jmi), jmi->n_boolean_d);
            jmi_log_reals(jmi->log, node, logInfo, "integers", jmi_get_integer_d(jmi), jmi->n_integer_d);
        }
    }

    if (RECOMPUTE_VARIABLES(jmi) == 1  && jmi->user_terminate == 0) {
        retval = jmi_ode_derivatives(jmi);
        if(retval != 0) {
            jmi_log_node(jmi->log, logWarning, "Warning",
                "Evaluating the derivatives failed at <t:%g>, retrying with restored values.", jmi_get_t(jmi)[0]);
            /* If it failed, reset to the previous succesful values */
            jmi_reset_internal_variables(jmi);

            /* Try again */
            retval = jmi_ode_derivatives(jmi);
            if(retval != 0) {
                if (jmi->jmi_callbacks.log_options.log_level >= 5){
                    jmi_log_leave(jmi->log, node);
                }
                jmi_log_node(jmi->log, logError, "Error",
                    "Evaluating the derivatives failed at <t:%g>", jmi_get_t(jmi)[0]);
                /* If it failed, reset to the previous successful values */
                jmi_reset_internal_variables(jmi);

                return -1;
            }
        }

        RECOMPUTE_VARIABLES_CLR(jmi);
    }

    memcpy (derivatives, jmi_get_real_dx(jmi), nx*sizeof(jmi_real_t));

    /* Verify that output is free from NANs */
    {
        int index_of_nan = 0;
        retval = jmi_check_nan(jmi, derivatives, nx, &index_of_nan);
        if (retval != 0) {
            jmi_log_node(jmi->log, logError, "Error",
                    "Evaluating the derivatives failed at <t:%g>. Produced NaN in <index:%I>", jmi_get_t(jmi)[0], index_of_nan);
            return -1;
        }
    }

    if (jmi->jmi_callbacks.log_options.log_level >= 5){
        jmi_log_leave(jmi->log, node);
    }

    return 0;
}


int jmi_save_last_successful_values(jmi_t *jmi) {
    jmi_real_t* z;
    jmi_real_t* z_last;

    z = jmi_get_z(jmi);
    z_last = jmi_get_z_last(jmi);

    memcpy(&z_last[jmi->offs_real_dx], &z[jmi->offs_real_dx], (jmi->n_z-jmi->offs_real_dx)*sizeof(jmi_real_t));

    return 0;
}

int jmi_reset_last_successful_values(jmi_t *jmi) {
    jmi_real_t* z;
    jmi_real_t* z_last;

    z = jmi_get_z(jmi);
    z_last = jmi_get_z_last(jmi);
    memcpy(z, z_last, jmi->n_z*sizeof(jmi_real_t));

    return 0;
}

int jmi_reset_last_internal_successful_values(jmi_t *jmi) {
    jmi_real_t* z;
    jmi_real_t* z_last;

    z = jmi_get_z(jmi);
    z_last = jmi_get_z_last(jmi);
    memcpy(&z[jmi->offs_real_dx], &z_last[jmi->offs_real_dx], (jmi->n_z-jmi->offs_real_dx)*sizeof(jmi_real_t));

    return 0;
}

int jmi_reset_internal_variables(jmi_t* jmi) {
    /* Store the current time and states */
    jmi_real_t time = *(jmi_get_t(jmi));
    jmi_real_t *x = jmi->real_x_work;
    jmi_real_t *u = jmi->real_u_work;

    memcpy(x, jmi_get_real_x(jmi), jmi->n_real_x*sizeof(jmi_real_t));
    memcpy(u, jmi_get_real_u(jmi), jmi->n_real_u*sizeof(jmi_real_t));

    jmi_reset_last_internal_successful_values(jmi);

    /* Restore the current time and states */
    memcpy (jmi_get_real_u(jmi), u, jmi->n_real_u*sizeof(jmi_real_t));
    memcpy (jmi_get_real_x(jmi), x, jmi->n_real_x*sizeof(jmi_real_t));
    *(jmi_get_t(jmi)) = time;

    if (jmi->jmi_callbacks.log_options.log_level >= 6){
        jmi_log_node_t node =jmi_log_enter_fmt(jmi->log, logInfo, "ResettingInternalVariables",
                                "Resetting internal variables at <t:%g>.", jmi_get_t(jmi)[0]);
        jmi_log_leave(jmi->log, node);
    }

    return 0;
}
