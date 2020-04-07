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

#include "jmi_me.h"
#include "jmi_delay.h"
#include "jmi_dynamic_state.h"
#include "jmi_chattering.h"
#include "module_include/jmi_get_set.h"



int jmi_me_init(jmi_callbacks_t* jmi_callbacks, jmi_t* jmi, jmi_string GUID, jmi_string_t resource_location) {
                       
    jmi_t* jmi_ = jmi;
    int retval;
    
    retval = jmi_new(&jmi, jmi_callbacks);
    if(retval != 0) {
        /* creating jmi struct failed */
        jmi_log_node(jmi_->log, logError, "StructCreationFailure","Creating internal struct failed.");
        return retval;
    }
    
    jmi_ = jmi;
    
    retval = jmi_me_init_modules(jmi);
    if (retval != 0) {
        jmi_log_node(jmi_->log, logError, "ModuleInitializationFailure","Failed to initialize modules");
        jmi_delete(jmi_);
        return -1;
    }


    /* Check if the GUID is correct.*/
    if (strcmp(GUID, C_GUID) != 0) {
        jmi_log_node(jmi_->log, logError, "ModelDescriptionFileInconsistency","The model and the description file are not consistent to each other.");
        jmi_delete(jmi_);
        return -1;
    }
    
    /* Postpone resource check until it is used. */
    jmi_->resource_location = resource_location;
    
    /* set start values*/
    if (jmi_init_eval_independent(jmi) != 0) {
        return -1;
    }
    
    /* Runtime options may be updated with start values */
    jmi_update_runtime_options(jmi);

    /* Write start values to the pre vector*/
    jmi_copy_pre_values(jmi);
    
    return 0;
}

int jmi_me_init_modules(jmi_t* jmi) {
    int retval;

    retval = jmi_get_set_module_init(jmi);
    if (retval != 0) {
        jmi_log_comment(jmi->log, logError, "jmi_get_set_module_init() failed");
        return -1;
    }

    return 0;
}

void jmi_me_delete_modules(jmi_t* jmi) {
    jmi_get_set_module_destroy(jmi);
}

void jmi_setup_experiment(jmi_t* jmi, jmi_boolean tolerance_defined,
                          jmi_real_t relative_tolerance) {
    
    jmi_update_runtime_options(jmi);
    /* Sets the relative tolerance to a default value for use in Kinsol when tolerance controlled is false */
    if (tolerance_defined == FALSE) {
        jmi->events_epsilon = jmi->options.events_default_tol; /* Used in the event detection */
        jmi->newton_tolerance = jmi->options.nle_solver_default_tol; /* Used in the Newton iteration */
    } else {
        jmi->events_epsilon = jmi->options.events_tol_factor*relative_tolerance; /* Used in the event detection */
        jmi->newton_tolerance = jmi->options.nle_solver_tol_factor*relative_tolerance; /* Used in the Newton iteration */
    }
    jmi->time_events_epsilon = jmi->options.time_events_default_tol;

    jmi->options.block_solver_options.res_tol = jmi->newton_tolerance;
    jmi->options.block_solver_options.events_epsilon = jmi->events_epsilon;
    jmi->options.block_solver_options.time_events_epsilon = jmi->time_events_epsilon;
}

int jmi_initialize(jmi_t* jmi) {
    int retval;
    jmi_log_node_t top_node={0};
    
    if (jmi->is_initialized == 1) {
        jmi_log_comment(jmi->log, logError, "FMU is already initialized: only one initialization is allowed");
        return -1;
    }
    
    if (jmi->jmi_callbacks.log_options.log_level >= 4){
        top_node =jmi_log_enter_fmt(jmi->log, logInfo, "Initialization", 
                                "Starting initialization.");
    }
    
    /* Reevaluate parameters and start variables if necessary */
    retval = jmi_init_eval_dependent(jmi);
    
    if(retval != 0) { /* Error check */
        jmi_log_comment(jmi->log, logError, "Error evaluating dependent parameters. Initialization failed.");
        if (jmi->jmi_callbacks.log_options.log_level >= 4){
            jmi_log_leave(jmi->log, top_node);
        }
        return -1;
    }

    /* We are at the initial event TODO: is this really necessary? */
    jmi->atEvent   = JMI_TRUE;
    jmi->atInitial = JMI_TRUE;
    jmi->tmp_events_epsilon = jmi->events_epsilon;
    jmi->events_epsilon = 0.0;
    
    /* Solve initial equations */
    retval = jmi_ode_initialize(jmi);

    if(retval != 0) { /* Error check */
        jmi_log_comment(jmi->log, logError, "Initialization failed.");
        if (jmi->jmi_callbacks.log_options.log_level >= 4){
            jmi_log_leave(jmi->log, top_node);
        }
        return -1;
    }
    
    /* Copy ds values */
    jmi_dynamic_state_copy_to_ds_values(jmi);
    /* Update ds values */
    jmi_dynamic_state_update(jmi);
    
    /* Copy values to pre after the initial equations are solved. */
    jmi_copy_pre_values(jmi);

    /* Reset atEvent flag */
    jmi->atEvent = JMI_FALSE;
    jmi->atInitial = JMI_FALSE;

    jmi_save_last_successful_values(jmi);
    
    /* Save restore mode activated after initialization */
    jmi->save_restore_solver_state_mode = 1;
    jmi->is_initialized = 1;
    
    /* Initialize delay blocks */
    retval = jmi_init_delay_blocks(jmi);
    if(retval != 0) {
        jmi_log_comment(jmi->log, logError, "Failed to initialize delay blocks.");
        if (jmi->jmi_callbacks.log_options.log_level >= 4){
            jmi_log_leave(jmi->log, top_node);
        }
        return -1;
    }
    
    /* Initialize chattering struct */
    jmi_chattering_init(jmi);
    
    retval = jmi_next_time_event(jmi);
    if(retval != 0) {
        jmi_log_comment(jmi->log, logError, "Computation of next time event failed after initialization.");
        if (jmi->jmi_callbacks.log_options.log_level >= 4){
            jmi_log_leave(jmi->log, top_node);
        }
        return -1;
    }
    
    if (jmi->jmi_callbacks.log_options.log_level >= 4){
        jmi_log_leave(jmi->log, top_node);
    }
    
    /* Resize the dynamic memory pool */
    jmi_dynamic_function_resize(jmi->dyn_fcn_mem);
    
    return 0;
}

int jmi_cannot_set(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr,
                    size_t start, size_t end, char* fmt) {
    jmi_value_reference i;
    jmi_value_reference index;
    for (i = 0; i < nvr; i = i + 1) {
        /* Get index in z vector from value reference. */
        index = jmi_get_index_from_value_ref(vr[i]);
        if (index >= start && index < end) {
            jmi_log_node(jmi->log, logError, "CannotSetVariable",
                         fmt, vr[i]);
            return -1;
        }
    }
    return 0;
}

int jmi_set_real(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr,
                 const jmi_real_t value[]) {

    if (jmi->user_terminate == 1) {
        jmi_log_node(jmi->log, logError, "CannotSetVariable",
                         "Cannot set Real variables when the model is terminated");
        return -1;
    }
    
    if (jmi_cannot_set(jmi, vr, nvr, jmi->offs_real_ci, jmi->offs_real_pi,
        "Cannot set Real constant <variable: #r%d#>")
        || jmi_cannot_set(jmi, vr, nvr, jmi->offs_real_pi_s, jmi->offs_real_pi_f,
        "Cannot set Real structural parameter <variable: #r%d#>")
        || jmi_cannot_set(jmi, vr, nvr, jmi->offs_real_pi_f, jmi->offs_real_pi_e,
        "Cannot set Real final parameter <variable: #r%d#>")
        || jmi_cannot_set(jmi, vr, nvr, jmi->offs_real_pi_e, jmi->offs_real_pd,
        "Cannot set Real evaluated parameter <variable: #r%d#>")
        || jmi_cannot_set(jmi, vr, nvr, jmi->offs_real_pd, jmi->offs_integer_ci,
        "Cannot set Real dependent parameter <variable: #r%d#>")) {
        
        return -1;
    }

    /* Transfer control to module */
    return jmi_set_real_impl(jmi, vr, nvr, value);
}

int jmi_set_integer(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr,
                    const jmi_int_t value[]) {

    if (jmi->user_terminate == 1) {
        jmi_log_node(jmi->log, logError, "CannotSetVariable",
                         "Cannot set Integer variables when the model is terminated");
        return -1;
    }
    
    if (jmi_cannot_set(jmi, vr, nvr, jmi->offs_integer_ci, jmi->offs_integer_pi,
        "Cannot set Integer constant <variable: #i%d#>")
        || jmi_cannot_set(jmi, vr, nvr, jmi->offs_integer_pi_s, jmi->offs_integer_pi_f,
        "Cannot set Integer structural parameter <variable: #i%d#>")
        || jmi_cannot_set(jmi, vr, nvr, jmi->offs_integer_pi_f, jmi->offs_integer_pi_e,
        "Cannot set Integer final parameter <variable: #i%d#>")
        || jmi_cannot_set(jmi, vr, nvr, jmi->offs_integer_pi_e, jmi->offs_integer_pd,
        "Cannot set Integer evaluated parameter <variable: #i%d#>")
        || jmi_cannot_set(jmi, vr, nvr, jmi->offs_integer_pd, jmi->offs_boolean_ci,
        "Cannot set Integer dependent parameter <variable: #i%d#>")) {
        
        return -1;
    }

    /* Transfer control to module */
    return jmi_set_integer_impl(jmi, vr, nvr, value);
}

int jmi_set_boolean(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr,
                    const jmi_boolean value[]) {

    if (jmi->user_terminate == 1) {
        jmi_log_node(jmi->log, logError, "CannotSetVariable",
                         "Cannot set Boolean variables when the model is terminated");
        return -1;
    }
    
    if (jmi_cannot_set(jmi, vr, nvr, jmi->offs_boolean_ci, jmi->offs_boolean_pi,
        "Cannot set Boolean constant <variable: #b%d#>")
        || jmi_cannot_set(jmi, vr, nvr, jmi->offs_boolean_pi_s, jmi->offs_boolean_pi_f,
        "Cannot set Boolean structural parameter <variable: #b%d#>")
        || jmi_cannot_set(jmi, vr, nvr, jmi->offs_boolean_pi_f, jmi->offs_boolean_pi_e,
        "Cannot set Boolean final parameter <variable: #b%d#>")
        || jmi_cannot_set(jmi, vr, nvr, jmi->offs_boolean_pi_e, jmi->offs_boolean_pd,
        "Cannot set Boolean evaluated parameter <variable: #b%d#>")
        || jmi_cannot_set(jmi, vr, nvr, jmi->offs_boolean_pd, jmi->offs_real_dx,
        "Cannot set Boolean dependent parameter <variable: #b%d#>")) {
        
        return -1;
    }

    /* Transfer control to module */
    return jmi_set_boolean_impl(jmi, vr, nvr, value);
}

int jmi_set_string(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr,
                   const jmi_string value[]) {

    jmi_z_offsets_t *o, *n;
    
    if (jmi->user_terminate == 1) {
        jmi_log_node(jmi->log, logError, "CannotSetVariable",
                         "Cannot set String variables when the model is terminated");
        return -1;
    }
    
    o  = &jmi->z_t.strings.offs;
    n  = &jmi->z_t.strings.nums;
    
    if (jmi_cannot_set(jmi, vr, nvr, o->ci, o->ci + n->ci + n->cd,
        "Cannot set String constant <variable: #r%d#>")
        || jmi_cannot_set(jmi, vr, nvr, o->ps, o->ps + n->ps,
        "Cannot set String structural parameter <variable: #r%d#>")
        || jmi_cannot_set(jmi, vr, nvr, o->pf, o->pf + n->pf,
        "Cannot set String final parameter <variable: #r%d#>")
        || jmi_cannot_set(jmi, vr, nvr, o->pe, o->pe + n->pe,
        "Cannot set String evaluated parameter <variable: #r%d#>")
        || jmi_cannot_set(jmi, vr, nvr, o->pd, o->pd + n->pd,
        "Cannot set String dependent parameter <variable: #r%d#>")) {
        
        return -1;
    }

    /* Transfer control to module */
    return jmi_set_string_impl(jmi, vr, nvr, value);
}

int jmi_get_real(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr,
                 jmi_real_t value[]) {

    /* Transfer control to module */
    return jmi_get_real_impl(jmi, vr, nvr, value);
}

int jmi_get_integer(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr,
                    jmi_int_t value[]) {

    /* Transfer control to module */
    return jmi_get_integer_impl(jmi, vr, nvr, value);
}

int jmi_get_boolean(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr,
                    jmi_boolean value[]) {

    /* Transfer control to module */
    return jmi_get_boolean_impl(jmi, vr, nvr, value);
}

int jmi_get_string(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr,
                   jmi_string value[]) {
    
    /* Transfer control to module */
    return jmi_get_string_impl(jmi, vr, nvr, value);
}

int jmi_get_directional_derivative(jmi_t* jmi,
                const jmi_value_reference vUnknown_ref[], size_t nUnknown,
                const jmi_value_reference vKnown_ref[],   size_t nKnown,
                const jmi_real_t dvKnown[], jmi_real_t dvUnknown[]) {
    
    jmi_real_t* store_dz = jmi->dz[0];
    int i, ef;
    jmi_log_node_t node={0};

    if (jmi->jmi_callbacks.log_options.log_level >= 5) {
        node =jmi_log_enter_fmt(jmi->log, logInfo, "GetDirectionalDerivatives",
                                "Call to get directional derivatives at <t:%g>.", jmi_get_t(jmi)[0]);
        if (jmi->jmi_callbacks.log_options.log_level >= 6){
            jmi_log_vrefs(jmi->log, node, logInfo, "known", 'r', (const int*)vKnown_ref, nKnown);
            jmi_log_vrefs(jmi->log, node, logInfo, "unknown", 'r', (const int*)vUnknown_ref, nUnknown);
            jmi_log_reals(jmi->log, node, logInfo, "direction", dvKnown, nKnown);
        }
    }
    
    jmi->dz[0]                  = jmi->dz_active_variables_buf[jmi->dz_active_index];
    jmi->dz_active_variables[0] = jmi->dz_active_variables_buf[jmi->dz_active_index];

    for (i = 0; i < jmi->n_v; i++) {
        jmi->dz_active_variables[0][i] = 0;
    }

    for (i = 0; i < nKnown; i++) {
        jmi->dz_active_variables[0][jmi_get_index_from_value_ref(vKnown_ref[i])-jmi->offs_real_dx] = dvKnown[i];
    }

    ef = jmi_ode_derivatives_dir_der(jmi);
    if (ef != 0) {
        jmi_log_node(jmi->log, logError, "Error",
                "Evaluating the directional derivatives failed at <t:%g>.", jmi_get_t(jmi)[0]);
    }

    for (i = 0; i < nUnknown; i++) {
        dvUnknown[i] = jmi->dz_active_variables[0][jmi_get_index_from_value_ref(vUnknown_ref[i])-jmi->offs_real_dx];
    }

    jmi->dz_active_variables[0] = jmi->dz_active_variables_buf[jmi->dz_active_index];
    jmi->dz[0] = store_dz;

    if (jmi->jmi_callbacks.log_options.log_level >= 5){
        if (jmi->jmi_callbacks.log_options.log_level >= 6){
            jmi_log_reals(jmi->log, node, logInfo, "derivative", dvUnknown, nUnknown);
        }
        jmi_log_leave(jmi->log, node);
    }

    return ef;
}

int jmi_get_derivatives(jmi_t* jmi, jmi_real_t derivatives[] , size_t nx) {
    
    /* Transfer control to module */
    return jmi_get_derivatives_impl(jmi, derivatives, nx);
}

int jmi_set_time(jmi_t* jmi, jmi_real_t time) {

    if (jmi->user_terminate == 1) {
        jmi_log_node(jmi->log, logError, "CannotSetVariable",
                         "Cannot set time when the model is terminated");
        return -1;
    }

    /* Transfer control to module */
    return jmi_set_time_impl(jmi, time);
}

int jmi_set_continuous_states(jmi_t* jmi, const jmi_real_t x[], size_t nx) {
    
    if (jmi->user_terminate == 1) {
        jmi_log_node(jmi->log, logError, "CannotSetVariable",
                         "Cannot set continuous states when the model is terminated");
        return -1;
    }

    /* Transfer control to module */
    return jmi_set_continuous_states_impl(jmi, x, nx);
}

int jmi_completed_integrator_step(jmi_t* jmi, jmi_real_t* triggered_event) {
    int retval = 0;
    jmi_log_node_t node={0};
    *triggered_event = JMI_FALSE;
    
    if (jmi->jmi_callbacks.log_options.log_level >= 5){
        node = jmi_log_enter_fmt(jmi->log, logInfo, "CompletedIntegratorStep", 
                                "Completed integrator step was called at <t:%g> indicating a successful step.", jmi_get_t(jmi)[0]);
    }
    
    /* Sample delay blocks */
    jmi_delay_set_event_mode(jmi, JMI_FALSE);
    retval = jmi_sample_delay_blocks(jmi);
    if(retval != 0) {
        jmi_log_comment(jmi->log, logError, "Delay sampling after completed integrator step failed.");
        if (jmi->jmi_callbacks.log_options.log_level >= 5){
            jmi_log_leave(jmi->log, node);
        }
        return -1;
    }
    
    /* Save the z values to the z_last vector */
    jmi_save_last_successful_values(jmi);
    /* Block completed step */
    jmi_block_completed_integrator_step(jmi);
    /* Chattering completed step */
    jmi_chattering_completed_integrator_step(jmi);
    
    /* Verify the choice of dynamic states */
    retval = jmi_dynamic_state_verify_choice(jmi);
    if (retval == JMI_UPDATE_STATES) { /*Bad choice, needs to be updated */
        *triggered_event = JMI_TRUE;
    }
    
    if (jmi->jmi_callbacks.log_options.log_level >= 5){
        jmi_log_leave(jmi->log, node);
    }

    
    return 0;
}

int jmi_get_event_indicators(jmi_t* jmi, jmi_real_t eventIndicators[], size_t ni) {
    
    /* Transfer control to module */
    return jmi_get_event_indicators_impl(jmi, eventIndicators, ni);
}

int jmi_get_nominal_continuous_states(jmi_t* jmi, jmi_real_t x_nominal[], size_t nx) {
    if (nx != jmi->n_real_x) {
        jmi_log_node(jmi->log, logError, "Error",
            "Wrong size of array when getting nominal values: size is <given_nx:%d>, should be <actual_nx:%d>", nx, jmi->n_real_x);
        return 1;
    }
    
    memcpy(x_nominal, jmi->nominals, nx * sizeof(jmi_real_t));
    return 0;
}

/* Local helper function */
static int jmi_exists_grt_than_time_event(jmi_t* jmi) {
    return jmi->model_terminate == FALSE                            &&
           jmi->atTimeEvent                                         &&
           jmi->eventPhase == JMI_TIME_EXACT                        &&
           jmi->nextTimeEvent.defined                               && 
           jmi_abs(jmi_get_t(jmi)[0]-jmi->nextTimeEvent.time)< jmi->time_events_epsilon;
}

int jmi_exit_event_mode(jmi_t* jmi, jmi_event_info_t* event_info) {
    jmi_int_t retval;
    jmi_log_node_t final_node = jmi_log_enter(jmi->log, logInfo, "final_step");

    /* Reset the number of event iterations */
    jmi->nbr_event_iter = 0;

    /* If the event epsilon is 0 due to initialization of the system, reset it */
    if (jmi->events_epsilon == 0.0) {
        jmi->events_epsilon = jmi->tmp_events_epsilon;
    }

    /* Reset atEvent flag */
    jmi->atEvent = JMI_FALSE;

    /* Final evaluation of the model with event flag set to false. It can
     * for example change values of booleans that should only be true during
     * events due to a sample function.
    */
    retval = jmi_ode_derivatives(jmi);
    if(retval != 0) {
        jmi_log_comment(jmi->log, logError, "Final evaluation of the model equations during event iteration failed.");
        return -1;
    }
    jmi->recomputeVariables = 0; /* The variables are computed. End of event iteration. */
    
    /* Sample delay blocks */
    jmi_delay_set_event_mode(jmi, JMI_TRUE);
    retval = jmi_sample_delay_blocks(jmi);
    if(retval != 0) {
        jmi_log_comment(jmi->log, logError, "Delay sampling after event iteration failed.");
        return -1;
    }
    
    /* Compute the next time event */
    retval = jmi_next_time_event(jmi);
    if(retval != 0) { /* Error check */
        jmi_log_comment(jmi->log, logError, "Computation of next time event failed.");
        return -1;
    }
    
    /* If there is an upcoming time event, then set the event information
     * accordingly.
     */
    if (jmi->nextTimeEvent.defined) {
        event_info->next_event_time_defined = TRUE;
        event_info->next_event_time = jmi->nextTimeEvent.time;
        if (event_info->next_event_time < jmi_get_t(jmi)[0]) {  /* Next event time is less than the current, error! */
            jmi_log_node(jmi->log, logError, "NextTimeEventFailure", "Failed to compute the next time event. "
                                "The next time event was computed to <t:%E> while the current time is <t:%E>.",
                                event_info->next_event_time,jmi_get_t(jmi)[0]);
            return -1;
        }
        jmi_log_node(jmi->log, logInfo, "NextTimeEvent", "A next time event is defined and computed to occur at <t:%E>",event_info->next_event_time);
    } else {
        event_info->next_event_time_defined = FALSE;
    }
    
    /* Save the z values to the z_last vector */
    jmi_save_last_successful_values(jmi);
    /* Block completed step, it should be saved and used when integrating */
    jmi->save_restore_solver_state_mode = 1;
    retval = jmi_block_completed_integrator_step(jmi);
    if(retval != 0) {
        jmi_log_comment(jmi->log, logError, "Completed block steps during event iteration failed.");
        return -1;
    }
    
    jmi_log_leave(jmi->log, final_node);

    if (jmi->n_sw > 0) {
        jmi_real_t* switches = jmi_get_sw(jmi);
        jmi_log_reals(jmi->log, jmi_log_get_current_node(jmi->log), logInfo, "post-switches", switches, jmi->n_sw);
    }
    
    /* Check for chattering and log it */
    jmi_chattering_check(jmi);
    
    if (jmi_exists_grt_than_time_event(jmi)) {
        int ret;
        jmi_boolean state_values_changed = event_info->state_values_changed;
        jmi->nbr_consec_time_events++;
        
        if (jmi->nbr_consec_time_events > 2) {
            jmi_log_node(jmi->log, logError, "NextTimeEventFailure",
                "Time event phase failure. Got next time event <t:%E> at "
                "current time <t:%E> that should already have been handled.",
                jmi->nextTimeEvent.time, jmi_get_t(jmi)[0]);
            return -1;
        }
        
        ret = jmi_enter_event_mode(jmi);
        if(ret != 0) {
            jmi_log_comment(jmi->log, logError, "Failed to re-enter the event mode at the second time event.");
            return -1;
        }
        
        ret = jmi_event_iteration(jmi, FALSE, event_info);
        
        /* If there was a previous state value changed, restore the flag */
        if (state_values_changed == TRUE) {
            event_info->state_values_changed = state_values_changed;
        }
        
        return ret;
    } else {
        jmi->nbr_consec_time_events = 0;
    }

    return 0;
}

int jmi_enter_event_mode(jmi_t* jmi) {
    jmi_int_t retval;
    
    /* Reset terminate flag. */
    jmi->model_terminate = 0;
    
    /* Initial evaluation of model so that we enter the event iteration with correct values. */
    /* TODO, make sure all blocks are updated */
    retval = jmi_ode_derivatives(jmi);

    if(retval != 0) {
        jmi_log_comment(jmi->log, logError, "Initial evaluation of the model equations during event iteration failed.");
        return -1;
    }
    
    /* This is an implicit accepted step. */
    retval = jmi_block_completed_integrator_step(jmi);
    if(retval != 0) {
        jmi_log_comment(jmi->log, logError, "Completed block steps during event iteration failed.");
        return -1;
    }
    
    /* We don't need to save and restore state during event iteration */
    jmi->save_restore_solver_state_mode = 0;
    
    /* We are at a time event -> set atTimeEvent to true. */
    if (jmi->nextTimeEvent.defined) {
        jmi->atTimeEvent = jmi_abs(jmi_get_t(jmi)[0]-jmi->nextTimeEvent.time) < jmi->time_events_epsilon;
        if(jmi->atTimeEvent) {
            jmi->eventPhase = jmi->nextTimeEvent.phase;
        } else {
            jmi->eventPhase = JMI_TIME_GREATER;
        }
        if(!jmi->atTimeEvent && jmi_get_t(jmi)[0]-jmi->nextTimeEvent.time > 0) { /* We passed the next time event, return error */
            jmi_log_node(jmi->log, logError, "NextTimeEventPassed",
                "Current time <t: %E> is after next time event <next_time_event: %E>. Consider to change option <time_events_default_tol: %E>.",
                jmi_get_t(jmi)[0], jmi->nextTimeEvent.time, jmi->time_events_epsilon);
            return -1;
        }
    }else{
        jmi->atTimeEvent = JMI_FALSE;
        jmi->eventPhase = JMI_TIME_GREATER;
    }
    
    /* Copy current values to pre values */
    jmi_copy_pre_values(jmi);
    
    return 0;
}

int jmi_event_iteration(jmi_t* jmi, jmi_boolean intermediate_results,
                        jmi_event_info_t* event_info) {
                            
    jmi_int_t retval;
    jmi_int_t i, max_iterations;
    jmi_real_t* z = jmi_get_z(jmi);
    jmi_real_t* switches;
    jmi_log_node_t top_node={0};
    jmi_log_node_t iter_node={0};
    jmi_log_node_t discrete_node={0};
    jmi_log_node_t reinit_node={0};

    /* Used for logging */
    switches = jmi_get_sw(jmi);
    
    max_iterations = 30;       /* Maximum number of event iterations */
    
    /* We are at an event -> set atEvent to true. */
    jmi->atEvent = JMI_TRUE;

    /* Performed at the first event iteration: */
    if (jmi->nbr_event_iter == 0) {

        /* Reset eventInfo */
        event_info->next_event_time_defined = FALSE;         /* The next event time is not set. */
        event_info->next_event_time = 0.0;                   /* A reset. */
        event_info->state_value_references_changed = FALSE;  /* No support for dynamic state selection */
        event_info->terminate_simulation = FALSE;            /* Don't terminate the simulation unless flagged to. */
        event_info->iteration_converged = FALSE;             /* The iteration has not converged */
        event_info->nominals_of_states_changed = FALSE;      /* Not used, get_nominals is not implemented. */
        event_info->state_values_changed = FALSE;            /* State variables have not been changed by reinit. */

        top_node = jmi_log_enter_fmt(jmi->log, logInfo, "GlobalEventIterations", 
                                 "Starting global event iteration at <t:%E>", jmi_get_t(jmi)[0]);
        
        if (jmi->n_sw > 0) {
            jmi_log_reals(jmi->log, top_node, logInfo, "pre-switches", switches, jmi->n_sw);
        }
        
    } else if (intermediate_results) {
        top_node = jmi_log_enter_fmt(jmi->log, logInfo, "GlobalEventIterations", 
                                 "Continuing global event iteration at <t:%E>", jmi_get_t(jmi)[0]);
    }

    /* Iterate */
    while (event_info->iteration_converged == FALSE) {
        jmi->reinit_triggered = 0; /* Reset reinit flag. */
        
        jmi->nbr_event_iter += 1;
        
        iter_node = jmi_log_enter_fmt(jmi->log, logInfo, "GlobalIteration", 
                                      "Global iteration <iter:%I>, at <t:%E>", jmi->nbr_event_iter, jmi_get_t(jmi)[0]);
        
        /* Copy current values to pre values */
        if (jmi->nbr_event_iter > 1) {
            jmi_copy_pre_values(jmi);
        }

        /* Evaluate the ODE */
        retval = jmi_ode_derivatives(jmi);
        
        if(retval != 0) {
            jmi_log_comment(jmi->log, logError, "Evaluation of model equations during event iteration failed.");
            jmi_log_unwind(jmi->log, top_node);
            return -1;
        }
        
        /* Compare current values with the pre values. If there is an element that differs, set
         * event_info->iteration_converged to false. */
        event_info->iteration_converged = TRUE; /* Assume the iteration converged */
        
        /* Log updates, NOTE this should in the future also contain which expressions changed! */
        if (jmi->jmi_callbacks.log_options.log_level >= 5){
            discrete_node =jmi_log_enter_fmt(jmi->log, logInfo, "GlobalUpdateOfDiscreteVariables", 
                                "Global updating of discrete variables");
        }
        
        for (i = jmi->offs_real_d; i < jmi->offs_pre_real_dx; i++) {
            if (z[i - jmi->offs_real_d + jmi->offs_pre_real_d] != z[i]) {
                event_info->iteration_converged = FALSE;
                
                /* Extra logging of the discrete variables that have been changed) */
                if (jmi->jmi_callbacks.log_options.log_level >= 5){
                    if (i < jmi->offs_boolean_d) {
                        jmi_log_node(jmi->log, logInfo, "Info", " <integer: #i%d#> <from: %d> <to: %d>", jmi_get_value_ref_from_index(i, JMI_INTEGER), (jmi_int_t)z[i - jmi->offs_real_d + jmi->offs_pre_real_d], (jmi_int_t)z[i]);
                    } else if (i < jmi->offs_sw) {
                        jmi_log_node(jmi->log, logInfo, "Info", " <boolean: #b%d#> <from: %d> <to: %d>", jmi_get_value_ref_from_index(i, JMI_BOOLEAN), (jmi_int_t)z[i - jmi->offs_real_d + jmi->offs_pre_real_d], (jmi_int_t)z[i]);
                    } else if (i < jmi->offs_guards) {
                        jmi_log_node(jmi->log, logInfo, "Info", " <switch: %I> <from: %d> <to: %d>", i-jmi->offs_sw, (jmi_int_t)z[i - jmi->offs_real_d + jmi->offs_pre_real_d], (jmi_int_t)z[i]);
                    }
                }
            }
        }
        
        /* Close the log node for the discrete variables update */
        if (jmi->jmi_callbacks.log_options.log_level >= 5){
            jmi_log_leave(jmi->log, discrete_node);
        }

        if (jmi->jmi_callbacks.log_options.log_level >= 5) {
            jmi_log_reals(jmi->log, iter_node, logInfo, "z_values", &z[jmi->offs_real_d], jmi->offs_pre_real_dx-jmi->offs_real_d);
            jmi_log_reals(jmi->log, iter_node, logInfo, "pre(z)_values", &z[jmi->offs_pre_real_d], jmi->offs_pre_real_dx-jmi->offs_real_d);
        }
        
        /* Check if a reinit triggered - this would mean that state variables changed. */
        if (jmi->reinit_triggered) {
            int verify_state_value_changed = 0;
            event_info->iteration_converged = FALSE;
            event_info->state_values_changed = TRUE;
            
            reinit_node =jmi_log_enter_fmt(jmi->log, logInfo, "ReInitTriggered", 
                                "A reinit triggered during the last event iteration.");
            for (i = 0; i < jmi->n_real_x; i++) {
                if (jmi_get_real_x(jmi)[i] != jmi_get_z(jmi)[jmi->offs_pre_real_x+i]) {
                    verify_state_value_changed = 1; /* State has changed */
                    jmi_log_node(jmi->log, logInfo, "StateUpdated", " <real: #r%d#> <from: %E> <to: %E>", jmi_get_value_ref_from_index(i+jmi->offs_real_x, JMI_REAL), jmi_get_z(jmi)[jmi->offs_pre_real_x+i], jmi_get_real_x(jmi)[i]);
                }
            }
            jmi_log_leave(jmi->log, reinit_node);
            
            if (verify_state_value_changed != 1) {
                jmi_log_node(jmi->log, logError, "ReInitFailure", "No state was changed despite a reinit triggered which indicates an error at <t:%E>.",jmi_get_t(jmi)[0]);
                jmi_log_unwind(jmi->log, top_node);
                return -1;
            }
        }
        
        /* No convergence under the allowed number of iterations. */
        if (jmi->nbr_event_iter >= max_iterations) {
            jmi_log_node(jmi->log, logError, "Error", "Failed to converge during global fixed point "
                         "iteration due to too many iterations at <t:%E>",jmi_get_t(jmi)[0]);
            jmi_log_unwind(jmi->log, top_node);
            return -1;
        }

        jmi_log_leave(jmi->log, iter_node);

        if (intermediate_results) {
            break;
        }
    }
    
    /* Only do the final steps if the event iteration is done. */
    if (event_info->iteration_converged == TRUE) {
        retval = jmi_exit_event_mode(jmi, event_info);
        
        if(retval != 0) {
            jmi_log_unwind(jmi->log, top_node);
            return -1;
        }
    }
    
    jmi_log_leave(jmi->log, top_node);

    /* If everything went well, check if termination of simulation was requested. */
    event_info->terminate_simulation = jmi->model_terminate ? TRUE : FALSE;
    
    if (jmi->updated_states == JMI_TRUE) {
        event_info->state_values_changed = TRUE;
        jmi->updated_states = FALSE;
    }
    
    return 0;
}

int jmi_next_time_event(jmi_t* jmi) {
    int retval;
    jmi->nextTimeEvent.defined = 0;
    
    retval = jmi_ode_next_time_event(jmi, &jmi->nextTimeEvent);
    if(retval != 0) {
        return -1;
    }
    
    /* See if the delay blocks need to update the next event time. Need to do this after sampling them,
       if the next event is caused by a delay of the current one. */
    retval = jmi_delay_next_time_event(jmi, &jmi->nextTimeEvent);
    if (retval != 0) {
        return -1;
    }
    
    return 0;
}

int jmi_update_and_terminate(jmi_t* jmi) {
    int retval;

    if (jmi->recomputeVariables == 1) {
        retval = jmi_ode_derivatives(jmi);
        if(retval != 0) {
            jmi_log_node(jmi->log, logError, "DerivativeCalculationFailure","Evaluating the ode derivatives failed.");
            return -1;
        }
        jmi->recomputeVariables = 0;
    }

    jmi_destruct_external_objects(jmi);
    jmi->user_terminate = 1;

    return 0;
}

int compare_option_names(const void* a, const void* b) {
    const char** sa = (const char**)a;
    const char** sb = (const char**)b;
    return strcmp(*sa, *sb);
}

static unsigned int get_option_index(char* option) {
    const char** found=(const char**)bsearch(&option, 
                                             fmi_runtime_options_map_names,
                                             fmi_runtime_options_map_length,
                                             sizeof(char*),
                                             compare_option_names);
    int vr, index;
    if(!found) return 0;
    index = (int)(found - &fmi_runtime_options_map_names[0]);
    if(index >= fmi_runtime_options_map_length ) return 0;
    vr = fmi_runtime_options_map_vrefs[index];
    return jmi_get_index_from_value_ref(vr);
}

/**
 * Update run-time options specified by the user.
 */
void jmi_update_runtime_options(jmi_t* jmi) {
    jmi_real_t* z = jmi_get_z(jmi);
    int index;
    jmi_options_t* op = &jmi->options;
    jmi_block_solver_options_t* bsop = &op->block_solver_options;
    index = get_option_index("_log_level");
    if(index) {
        op->log_options->log_level = (int)z[index];
    }
    index = get_option_index("_enforce_bounds");
    if(index)
        op->block_solver_options.enforce_bounds_flag = (int)z[index]; 
    
    index = get_option_index("_use_jacobian_equilibration");
    if(index ){
        bsop->use_jacobian_equilibration_flag = (int)z[index]; 
    }
    
    index = get_option_index("_residual_equation_scaling");
    if(index) {
        int fl = (int)z[index];
        switch(fl) {
        case jmi_residual_scaling_none:
            bsop->residual_equation_scaling_mode = jmi_residual_scaling_none;
            break;
        case jmi_residual_scaling_manual:
            bsop->residual_equation_scaling_mode = jmi_residual_scaling_manual;
            break;
        case jmi_residual_scaling_hybrid:
            bsop->residual_equation_scaling_mode = jmi_residual_scaling_hybrid;
            break;
        case jmi_residual_scaling_aggressive_auto:
            bsop->residual_equation_scaling_mode = jmi_residual_scaling_aggressive_auto;
            break;
        case jmi_residual_scaling_full_jacobian_auto:
            bsop->residual_equation_scaling_mode = jmi_residual_scaling_full_jacobian_auto;
            break;
        default:
            bsop->residual_equation_scaling_mode = jmi_residual_scaling_auto;
            break;
        }
    } 

    index = get_option_index("_nle_jacobian_update_mode");
    if(index) {
        int fl = (int)z[index];
        switch(fl) {
        case jmi_broyden_jacobian_update_mode:
            bsop->jacobian_update_mode = jmi_broyden_jacobian_update_mode;
            break;
        case jmi_full_jacobian_update_mode:
            bsop->jacobian_update_mode = jmi_full_jacobian_update_mode;
            break;
        default:
            bsop->jacobian_update_mode = jmi_reuse_jacobian_update_mode;
        }
    } 

    index = get_option_index("_nle_jacobian_calculation_mode");
    if(index) {
        int fl = (int)z[index];
        switch(fl) {
        case jmi_central_diffs_jacobian_calculation_mode:
            bsop->jacobian_calculation_mode = jmi_central_diffs_jacobian_calculation_mode;
            break;
        case jmi_central_diffs_at_bound_jacobian_calculation_mode:
            bsop->jacobian_calculation_mode = jmi_central_diffs_at_bound_jacobian_calculation_mode;
            break;
        case jmi_central_diffs_at_bound_and_zero_jacobian_calculation_mode:
            bsop->jacobian_calculation_mode = jmi_central_diffs_at_bound_and_zero_jacobian_calculation_mode;
            break;
        case jmi_central_diffs_solve2_jacobian_calculation_mode:
            bsop->jacobian_calculation_mode = jmi_central_diffs_solve2_jacobian_calculation_mode;
            break;
        case jmi_central_diffs_at_bound_solve2_jacobian_calculation_mode:
            bsop->jacobian_calculation_mode = jmi_central_diffs_at_bound_solve2_jacobian_calculation_mode;
            break;
        case jmi_central_diffs_at_bound_and_zero_solve2_jacobian_calculation_mode:
            bsop->jacobian_calculation_mode = jmi_central_diffs_at_bound_and_zero_solve2_jacobian_calculation_mode;
            break;
        case jmi_central_diffs_at_small_res_jacobian_calculation_mode:
            bsop->jacobian_calculation_mode = jmi_central_diffs_at_small_res_jacobian_calculation_mode;
            break;
        case jmi_calculate_externally_jacobian_calculation_mode:
            bsop->jacobian_calculation_mode = jmi_calculate_externally_jacobian_calculation_mode;
            break;
        case jmi_compression_jacobian_calculation_mode:
            bsop->jacobian_calculation_mode = jmi_compression_jacobian_calculation_mode;
            break;
        default:
            bsop->jacobian_calculation_mode = jmi_onesided_diffs_jacobian_calculation_mode;
            break;
        }
    } 

    index = get_option_index("_nle_active_bounds_mode");
    if(index) {
        int fl = (int)z[index];
        switch(fl) {
        case jmi_use_steepest_descent_active_bounds_mode:
            bsop->active_bounds_mode = jmi_use_steepest_descent_active_bounds_mode;
            break;
        default:
            bsop->active_bounds_mode = jmi_project_newton_step_active_bounds_mode;
        }
    } 
        
    index = get_option_index("_nle_solver_min_residual_scaling_factor");
    if(index)
        bsop->min_residual_scaling_factor = z[index];
        
    index = get_option_index("_nle_solver_use_nominals_as_fallback");
    if(index)
        bsop->use_nominals_as_fallback_in_init = (int)z[index];
        
    index = get_option_index("_nle_solver_use_last_integrator_step");
    if(index)
        bsop->start_from_last_integrator_step = (int)z[index];
    
    index = get_option_index("_nle_solver_max_residual_scaling_factor");
    if(index)
        bsop->max_residual_scaling_factor = z[index];

    index = get_option_index("_nle_solver_max_iter");
    if(index)
        bsop->max_iter = (int)z[index];
    index = get_option_index("_nle_solver_max_iter_no_jacobian");
    if(index)
        bsop->max_iter_no_jacobian = (int)z[index];
    index = get_option_index("_block_solver_experimental_mode");
    if(index)
        bsop->experimental_mode  = (int)z[index];
    
    index = get_option_index("_iteration_variable_scaling");
    if(index) {
        switch((int)z[index]) {
        case jmi_iter_var_scaling_none:
            bsop->iteration_variable_scaling_mode = jmi_iter_var_scaling_none;
            break;
        case jmi_iter_var_scaling_heuristics:
            bsop->iteration_variable_scaling_mode = jmi_iter_var_scaling_heuristics;
            break;
        default:
            bsop->iteration_variable_scaling_mode = jmi_iter_var_scaling_nominal;
        }
    }
    index = get_option_index("_nle_solver_exit_criterion");
    if(index) {
        switch((int)z[index]) {
        case jmi_exit_criterion_step_residual:
            bsop->solver_exit_criterion_mode = jmi_exit_criterion_step_residual;
            break;
        case jmi_exit_criterion_step:
            bsop->solver_exit_criterion_mode = jmi_exit_criterion_step;
            break;
        case jmi_exit_criterion_residual:
            bsop->solver_exit_criterion_mode = jmi_exit_criterion_residual;
            break;
        default:
            bsop->solver_exit_criterion_mode = jmi_exit_criterion_hybrid;
        }
    }
    index = get_option_index("_rescale_each_step");
    if(index)
        bsop->rescale_each_step_flag = (int)z[index]; 
    index = get_option_index("_rescale_after_singular_jac");
    if(index)
        bsop->rescale_after_singular_jac_flag = (int)z[index]; 
    index = get_option_index("_use_Brent_in_1d");
    if(index)
        bsop->use_Brent_in_1d_flag = (int)z[index]; 
    index = get_option_index("_use_newton_for_brent");
    if(index)
        bsop->use_newton_for_brent = (int)z[index];
    index = get_option_index("_nle_solver_default_tol");
    if(index)
        op->nle_solver_default_tol = z[index]; 
    index = get_option_index("_nle_solver_check_jac_cond");
    if(index)
        bsop->check_jac_cond_flag = (int)z[index]; 
    index = get_option_index("_nle_brent_ignore_error");
    if(index)
        bsop->brent_ignore_error_flag = (int)z[index];
    index = get_option_index("_nle_jacobian_finite_difference_delta");
    if(index)
        bsop->jacobian_finite_difference_delta = z[index];
    index = get_option_index("_nle_solver_step_limit_factor");
    if(index)
        bsop->step_limit_factor = z[index];
    index = get_option_index("_nle_solver_min_tol");
    if(index)
        bsop->min_tol = z[index];
    index = get_option_index("_nle_solver_regularization_tolerance");
    if(index)
        bsop->regularization_tolerance = z[index];
    index = get_option_index("_nle_solver_tol_factor");
    if(index)
        op->nle_solver_tol_factor = z[index]; 
        
    index = get_option_index("_events_default_tol");
    if(index)
        op->events_default_tol = z[index]; 
    index = get_option_index("_time_events_default_tol");
    if(index)
        op->time_events_default_tol = z[index];
    index = get_option_index("_events_tol_factor");
    if(index)
        op->events_tol_factor = z[index];
    index = get_option_index("_block_jacobian_check");
    if(index)
         bsop->block_jacobian_check = (int)z[index]; 
    index = get_option_index("_block_jacobian_check_tol");
    if(index)
         bsop->block_jacobian_check_tol = z[index];
    index = get_option_index("_block_solver_profiling");
    if(index)
        bsop->block_profiling  = (int)z[index];
    index = get_option_index("_cs_solver");
    if(index)
        op->cs_solver = (int)z[index];
    index = get_option_index("_cs_rel_tol");
    if(index)
        op->cs_rel_tol = z[index];
    index = get_option_index("_cs_step_size");
    if(index)
        op->cs_step_size = z[index];
    index = get_option_index("_cs_experimental_mode");
    if(index)
        op->cs_experimental_mode = (int)z[index];
    index = get_option_index("_runtime_log_to_file");
    if(index)
        op->log_options->copy_log_to_file_flag = (int)z[index]; 
    
    bsop->res_tol = jmi->newton_tolerance;
    bsop->events_epsilon = jmi->events_epsilon;
/*    op->block_solver_experimental_mode = 
            jmi_block_solver_experimental_steepest_descent_first;
   op->log_level = 5; */
}
