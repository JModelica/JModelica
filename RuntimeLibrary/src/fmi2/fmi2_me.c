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

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include "fmi2_me.h"
#include "fmi2_cs.h"

const char* fmi2_get_types_platform() {
    return fmi2TypesPlatform;
}

const char* fmi2_get_version() {
    return fmi2Version;
}

fmi2Status fmi2_set_debug_logging(fmi2Component    c,
                                  fmi2Boolean      loggingOn, 
                                  size_t           nCategories, 
                                  const fmi2String categories[]) {

    fmi2_me_t* self = (fmi2_me_t*)c;
    size_t i;
    int max_log_level, tmp_log_level;
    if (c == NULL) {
        return fmi2Fatal;
    }

    max_log_level = 0;
    for (i = 0; i < nCategories; i++) {
        if (strcmp(categories[i], "logLevel1")) {
            tmp_log_level = 1;
        } else if (strcmp(categories[i], "logLevel2")) {
            tmp_log_level = 2;
        } else if (strcmp(categories[i], "logLevel3")) {
            tmp_log_level = 3;
        } else if (strcmp(categories[i], "logLevel4")) {
            tmp_log_level = 4;
        } else if (strcmp(categories[i], "logLevel5")) {
            tmp_log_level = 5;
        } else if (strcmp(categories[i], "logLevel6")) {
            tmp_log_level = 6;
        } else {
            jmi_log_node(self->jmi.log, logError, "Error", "The log category '%s' is not allowed", categories[i]);
            return fmi2Error;
        }

        if (tmp_log_level > max_log_level) {
            max_log_level = tmp_log_level;
        }
    }
    
    self->jmi.jmi_callbacks.log_options.logging_on_flag = loggingOn;
    self->jmi.jmi_callbacks.log_options.log_level = max_log_level;
    return fmi2OK;
}

fmi2Component fmi2_instantiate(fmi2String instanceName,
                               fmi2Type   fmuType, 
                               fmi2String fmuGUID, 
                               fmi2String fmuResourceLocation, 
                               const fmi2CallbackFunctions* functions, 
                               fmi2Boolean                  visible,
                               fmi2Boolean                  loggingOn) {
    
    fmi2Component component;
    fmi2Integer   retval;
    
    if(!functions->allocateMemory || !functions->freeMemory || !functions->logger) {
         if(functions->logger) {
             /* We have to use the raw logger callback here; the logger in the jmi_t struct is not yet initialized. */
             functions->logger(0, instanceName, fmi2Error, "ERROR", "Memory management functions allocateMemory/freeMemory are required.");
         }
         return NULL;
    }
    
    /*Allocate memory for the correct struct. */
    if (fmuType == fmi2ModelExchange) {
        component = (fmi2Component)functions->allocateMemory(1, sizeof(fmi2_me_t));
        if(!component) return NULL;

        retval = fmi2_me_instantiate(component, instanceName, fmuType, fmuGUID, 
                                     fmuResourceLocation, functions, visible,
                                     loggingOn);
        if (retval != fmi2OK) {
            functions->freeMemory(component);
            return NULL;
        }

    } else if (fmuType == fmi2CoSimulation) {
        component = (fmi2Component)functions->allocateMemory(1, sizeof(fmi2_cs_t));
        if(!component) return NULL;

        retval = fmi2_cs_instantiate(component, instanceName, fmuType, fmuGUID, 
                                     fmuResourceLocation, functions, visible,
                                     loggingOn);
        if (retval != fmi2OK) {
            functions->freeMemory(component);
            return NULL;
        }
    } else {
        /* We have to use the raw logger callback here; the logger in the jmi_t struct is not yet initialized. */
        functions->logger(0, instanceName, fmi2Error, "ERROR", "Valid choises for fmuType are fmi2ModelExchange and fmi2CoSimulation");
        component = NULL;
    }
    
    return component;
}

static fmi2Status category_to_fmi2Status(jmi_log_category_t c) {
    switch (c) {
    case logError:   return fmi2Error;
    case logWarning: return fmi2Warning;
    case logInfo:    return fmi2OK;
    default:         return fmi2Error;
    }
}

static const char *category_to_fmi2Category(jmi_log_category_t c) {
    switch (c) {
    case logError:   return "ERROR";
    case logWarning: return "WARNING";
    case logInfo:    return "INFO";
    default:         return "UNKNOWN CATEGORY";
    }
}

void fmi2_me_emit_log(jmi_callbacks_t*   jmi_callbacks,     jmi_log_category_t category,
                      jmi_log_category_t severest_category, char*              message) {

    fmi2_me_t* c = (fmi2_me_t*)(jmi_callbacks->model_data);
    
    if(c){
        if(c->fmi_functions->logger)
            c->fmi_functions->logger(c->fmi_functions->componentEnvironment,
                                     jmi_callbacks->instance_name, 
                                     category_to_fmi2Status(category),
                                     category_to_fmi2Category(severest_category),
                                     "%s", message); /* prevent interpretation of message as format string */
    } else {
        switch (category) {
            case logError:
                fprintf(stderr, "<!-- ERROR:   --> %s\n", message);
            break;
            case logWarning:
                fprintf(stderr, "<!-- WARNING: --> %s\n", message);
            break;
            case logInfo:
                fprintf(stdout, "%s\n", message);
            break;
        }
    }
}

BOOL fmi2_me_is_log_category_emitted(jmi_callbacks_t* cb, jmi_log_category_t category) {

    jmi_callbacks_t* jmi_callbacks = cb;
    fmi2_me_t * self = (fmi2_me_t *)cb->model_data;
    if ((self != NULL) && !jmi_callbacks->log_options.logging_on_flag) {
        return FALSE;
    }
    
    switch (category) {
        case logError:   break;
        case logWarning: if(cb->log_options.log_level < 3) return FALSE; break;
        case logInfo:    if(cb->log_options.log_level < 4) return FALSE; break;
    }
    return TRUE;
}

void fmi2_free_instance(fmi2Component c)  {
    /* Dispose the given model instance and deallocated all the allocated memory and other resources 
     * that have been allocated by the functions of the Model Exchange Interface for instance "c".*/
    fmi2CallbackFreeMemory fmi_free;
    
    if (c) {
        fmi_free = ((fmi2_me_t*)c)->fmi_functions->freeMemory;
        
        if (((fmi2_me_t*)c)->fmu_type == fmi2ModelExchange) {
            fmi2_me_free_instance(c);
            fmi_free(((fmi2_me_t*)c));
        } else if (((fmi2_me_t*)c)->fmu_type == fmi2CoSimulation) {
            fmi2_cs_free_instance(c);
            fmi_free(((fmi2_cs_t*)c));
        }
    }
}

fmi2Status fmi2_setup_experiment(fmi2Component c, 
                                 fmi2Boolean   toleranceDefined, 
                                 fmi2Real      tolerance, 
                                 fmi2Real      startTime, 
                                 fmi2Boolean   stopTimeDefined, 
                                 fmi2Real      stopTime) {
    fmi2Status retval;
    fmi2_me_t* fmi2_me; 
    
    if (c == NULL) {
        return fmi2Fatal;
    }

    fmi2_me = (fmi2_me_t*)c;

    if (fmi2_me->fmu_mode != instantiatedMode) {
        jmi_log_node(fmi2_me->jmi.log, logError, "FMIState",
            "Can only set up an experiment right after the model is instantiated or has been reset.");
        return fmi2Error;
    }
    
    jmi_setup_experiment(&fmi2_me->jmi, toleranceDefined, tolerance);
    
    if (stopTimeDefined) {
        fmi2_me->stopTime = stopTime;
    }
    retval = fmi2_set_time(c, startTime);
    
    if (fmi2_me->fmu_type == fmi2CoSimulation) {
        ((fmi2_cs_t*)c)->ode_problem->time = startTime;
    }
    
    return retval;
}

fmi2Status fmi2_enter_initialization_mode(fmi2Component c) {
    fmi2Integer retval;
    jmi_ode_problem_t* ode_problem;
    jmi_ode_solver_options_t options;
    jmi_t* jmi;
    jmi_cs_data_t* cs_data;

    if (c == NULL) {
        return fmi2Fatal;
    }
    
    if (((fmi2_me_t *)c)->fmu_mode != instantiatedMode) {
        jmi_log_node(((fmi2_me_t *)c)->jmi.log, logError, "FMIState",
            "Can only enter initialization mode after instantiating the model.");
        return fmi2Error;
    }
    jmi = &((fmi2_me_t*)c)->jmi;
    
    retval = jmi_initialize(jmi);
    if (retval != 0) {
        return fmi2Error;
    }
    
    ((fmi2_me_t *)c) -> fmu_mode = initializationMode;
    
    if (((fmi2_me_t *)c) -> fmu_type == fmi2CoSimulation) {
        ode_problem = ((fmi2_cs_t *)c) -> ode_problem; 
        cs_data = ((fmi2_cs_t *)c)->cs_data;
        /*Get the states and the nominals for the ODE problem. Initialization. */
        fmi2_get_continuous_states(cs_data->fmix_me, ode_problem->states, ode_problem->sizes.states);
        fmi2_get_nominals_of_continuous_states(cs_data->fmix_me, ode_problem->nominals, ode_problem->sizes.states);
        
        
        /* These options for the solver need to be found in a better way. */
        options = jmi_ode_solver_default_options();
        options.method                  = jmi->options.cs_solver;
        options.euler_options.step_size = jmi->options.cs_step_size;
        options.cvode_options.rel_tol   = jmi->options.cs_rel_tol;
        options.experimental_mode       = jmi->options.cs_experimental_mode;
        
        /* Create solver */
        ode_problem->ode_solver = jmi_new_ode_solver(ode_problem, options);
        if (ode_problem->ode_solver == NULL) { 
            return fmi2Error;
        }
    }
    
    return fmi2OK;
}

fmi2Status fmi2_exit_initialization_mode(fmi2Component c) {
    if (c == NULL) {
        return fmi2Fatal;
    }

    if (((fmi2_me_t *)c)->fmu_mode != initializationMode) {
        jmi_log_node(((fmi2_me_t *)c)->jmi.log, logError, "FMIState",
            "Can only exit initialization mode when being in initialization mode.");
        return fmi2Error;
    }
    ((fmi2_me_t *)c)->fmu_mode = continuousTimeMode;
    if (((fmi2_me_t *)c)->fmu_type == fmi2ModelExchange) {
        fmi2Status retval = fmi2_enter_event_mode(c);
        if (retval != fmi2OK) {
            return retval;
        }
    } else if (((fmi2_me_t *)c)->fmu_type == fmi2CoSimulation) {
        /* Start event iteration after initialization: */
        jmi_ode_solver_external_event(((fmi2_cs_t *)c)->ode_problem->ode_solver);
    }
    return fmi2OK;
}

fmi2Status fmi2_terminate(fmi2Component c) {
    /* Release all resources that have been allocated since fmi_initialize has been called. */
    int retval;

    if (c == NULL) {
        return fmi2Fatal;
    }
    
    retval = jmi_update_and_terminate(&((fmi2_me_t*)c)->jmi);
    if (retval != 0) {
        return fmi2Error;
    }
    return fmi2OK;
}

fmi2Status fmi2_reset(fmi2Component c) {
    jmi_t* jmi;
    fmi2_me_t* fmi2_me;
    jmi_callbacks_t* cb;
    char*  tmp_resource_location;
    
    if (c == NULL) {
        return fmi2Fatal;
    }
    
    fmi2_me = (fmi2_me_t*)c;
    jmi = &fmi2_me->jmi;
    
    /* Clear the ode_solver in case of CoSimulation */
    if (fmi2_me->fmu_type == fmi2CoSimulation) {
        jmi_free_ode_solver(((fmi2_cs_t *)c)->ode_problem->ode_solver);
        ((fmi2_cs_t *)c)->ode_problem->ode_solver = NULL;
    }
    
    /* Save some information from the jmi struct */
    cb = &jmi->jmi_callbacks;
    tmp_resource_location = jmi->resource_location; /* jmi_delete do not free resource_location */
    
    /* Clear the jmi struct */
    jmi_delete(jmi);
    
    /* Reset default options */
    cb->log_options.logging_on_flag = (char)fmi2_me->initial_logging_on;
    cb->log_options.log_level       = 5;       /* must be high to let the messages during initialization go through */
    fmi2_me->stopTime               = JMI_INF; /* Default if not set in setup_experiment */
    
    /* Reinstantiate the jmi struct */
    jmi_me_init(cb, &fmi2_me->jmi, fmi2_me->fmu_GUID, tmp_resource_location);
    
    /* Instantiate the ode_problem in case of CoSimulation */
    if (fmi2_me->fmu_type == fmi2CoSimulation) {
        fmi2_cs_t* fmi2_cs = (fmi2_cs_t*)c;
        
        jmi_reset_cs_data(fmi2_cs->cs_data);
        jmi_reset_ode_problem(fmi2_cs->ode_problem);
        /* Due to no jmi_t reset, pointers may have changed: */
        fmi2_cs->ode_problem->log = jmi->log;
        fmi2_cs->ode_problem->jmi_callbacks = &jmi->jmi_callbacks;
    }
    
    /* The FMU is reset */
    fmi2_me->fmu_mode = instantiatedMode;
    
    return fmi2OK;
}

fmi2Status fmi2_get_real(fmi2Component c, const fmi2ValueReference vr[],
                         size_t nvr, fmi2Real value[]) {
    fmi2Integer retval;
    size_t i;
    
    if (c == NULL) {
        return fmi2Fatal;
    }

    retval = jmi_get_real(&((fmi2_me_t *)c)->jmi, vr, nvr, value);
    if (retval != 0) {
        return fmi2Error;
    }
    
    /* Negate the values of the retrieved "negate alias" variables. */
    for (i = 0; i < nvr; i++) {
        if (jmi_value_ref_is_negated(vr[i])) {
            value[i] = -value[i];
        }
    }

    return fmi2OK;
}

fmi2Status fmi2_get_integer(fmi2Component c, const fmi2ValueReference vr[],
                            size_t nvr, fmi2Integer value[]) {
    fmi2Integer retval;
    size_t i;
    
    if (c == NULL) {
        return fmi2Fatal;
    }

    retval = jmi_get_integer(&((fmi2_me_t *)c)->jmi, vr, nvr, value);
    if (retval != 0) {
        return fmi2Error;
    }
    
    /* Negate the values of the retrieved "negate alias" variables. */
    for (i = 0; i < nvr; i++) {
        if (jmi_value_ref_is_negated(vr[i])) {
            value[i] = -value[i];
        }
    }

    return fmi2OK;
}

fmi2Status fmi2_get_boolean(fmi2Component c, const fmi2ValueReference vr[],
                            size_t nvr, fmi2Boolean value[]) {
    fmi2Integer retval;
    jmi_boolean* jmi_boolean_values = (jmi_boolean*)calloc(nvr, sizeof(char));
    size_t i;
    
    if (c == NULL) {
        return fmi2Fatal;
    }

    retval = jmi_get_boolean(&((fmi2_me_t *)c)->jmi, vr, nvr, jmi_boolean_values);
    if (retval != 0) {
        return fmi2Error;
    }
    
    for (i = 0; i < nvr; i++) {
        value[i] = jmi_boolean_values[i];
    }
    free(jmi_boolean_values);

    return fmi2OK;
}

fmi2Status fmi2_get_string(fmi2Component c, const fmi2ValueReference vr[],
                           size_t nvr, fmi2String value[]) {
    fmi2Integer retval;
    
    if (c == NULL) {
        return fmi2Fatal;
    }

    retval = jmi_get_string(&((fmi2_me_t *)c)->jmi, vr, nvr, value);
    if (retval != 0) {
        return fmi2Error;
    }

    return fmi2OK;
}

fmi2Status fmi2_set_real(fmi2Component c, const fmi2ValueReference vr[],
                         size_t nvr, const fmi2Real value[]) {
    fmi2Integer retval;
    fmi2_me_t* fmi2_me = (fmi2_me_t*)c;
    size_t i;
    
    if (c == NULL) {
        return fmi2Fatal;
    }
    
    for (i = 0; i < nvr; i++) {
        /* Negate the values before setting the "negate alias" variables. */
        if (jmi_value_ref_is_negated(vr[i])) {
            fmi2_me->work_real_array[i] = -value[i];
        } else {
            fmi2_me->work_real_array[i] = value[i];
        }
    }
    
    if (fmi2_me->fmu_type == fmi2CoSimulation &&
        ((fmi2_cs_t *)c)->ode_problem->ode_solver != NULL &&
        jmi_cs_check_discrete_input_change(&fmi2_me->jmi, vr, nvr, (void*)fmi2_me->work_real_array))
    {
        jmi_ode_solver_external_event(((fmi2_cs_t *)c)->ode_problem->ode_solver);
    }
    if (fmi2_me->fmu_type == fmi2CoSimulation &&
        ((fmi2_cs_t *)c)->ode_problem->ode_solver != NULL &&
        jmi_cs_check_input_change(&fmi2_me->jmi, vr, nvr, fmi2_me->work_real_array))
    {
        jmi_ode_solver_need_to_initialize(((fmi2_cs_t *)c)->ode_problem->ode_solver);
    } 
    
    retval = jmi_set_real(&((fmi2_me_t *)c)->jmi, vr, nvr, fmi2_me->work_real_array);
    if (retval != 0) {
        return fmi2Error;
    }
    
    return fmi2OK;
}

fmi2Status fmi2_set_integer(fmi2Component c, const fmi2ValueReference vr[],
                            size_t nvr, const fmi2Integer value[]) {
    fmi2Integer retval;
    fmi2_me_t* fmi2_me = (fmi2_me_t*)c;
    size_t i;
    
    if (c == NULL) {
        return fmi2Fatal;
    }
    
    /* Negate the values before setting the "negate alias" variables. */
    for (i = 0; i < nvr; i++) {
        if (jmi_value_ref_is_negated(vr[i])) {
            fmi2_me->work_int_array[i] = -value[i];
        } else {
            fmi2_me->work_int_array[i] = value[i];
        }
    }
    
    if (fmi2_me->fmu_type == fmi2CoSimulation &&
        ((fmi2_cs_t *)c)->ode_problem->ode_solver != NULL &&
        jmi_cs_check_discrete_input_change(&fmi2_me->jmi, vr, nvr, (void*)fmi2_me->work_int_array))
    {
        jmi_ode_solver_external_event(((fmi2_cs_t *)c)->ode_problem->ode_solver);
    }
    
    retval = jmi_set_integer(&((fmi2_me_t *)c)->jmi, vr, nvr, fmi2_me->work_int_array);
    if (retval != 0) {
        return fmi2Error;
    }
    
    return fmi2OK;
}

fmi2Status fmi2_set_boolean(fmi2Component c, const fmi2ValueReference vr[],
                            size_t nvr, const fmi2Boolean value[]) {
    fmi2Integer retval;
    fmi2_me_t* fmi2_me = (fmi2_me_t *)c;
    size_t i;
    jmi_boolean* jmi_boolean_values;
    
    if (c == NULL) {
        return fmi2Fatal;
    }
    
    jmi_boolean_values = (jmi_boolean*)calloc(nvr, sizeof(jmi_boolean));
    for (i = 0; i < nvr; i++) {
        jmi_boolean_values[i] = value[i];
    }
    
    if (fmi2_me->fmu_type == fmi2CoSimulation  &&
        ((fmi2_cs_t *)c)->ode_problem->ode_solver != NULL &&
        jmi_cs_check_discrete_input_change(&fmi2_me->jmi, vr, nvr, (void*)jmi_boolean_values))
    {
        jmi_ode_solver_external_event(((fmi2_cs_t *)c)->ode_problem->ode_solver);
    }
    
    retval = jmi_set_boolean(&fmi2_me->jmi, vr, nvr, jmi_boolean_values);
    free(jmi_boolean_values);
    
    if (retval != 0) {
        return fmi2Error;
    }

    return fmi2OK;
}

fmi2Status fmi2_set_string(fmi2Component c, const fmi2ValueReference vr[],
                           size_t nvr, const fmi2String value[]) {
    fmi2Integer retval;
    
    if (c == NULL) {
        return fmi2Fatal;
    }
    
    retval = jmi_set_string(&((fmi2_me_t *)c)->jmi, vr, nvr, value);
    if (retval != 0) {
        return fmi2Error;
    }
    
    return fmi2OK;
}

fmi2Status fmi2_get_fmu_state(fmi2Component c, fmi2FMUstate* FMUstate) {
    return fmi2Error;
}

fmi2Status fmi2_set_fmu_state(fmi2Component c, fmi2FMUstate FMUstate) {
    return fmi2Error;
}

fmi2Status fmi2_free_fmu_state(fmi2Component c, fmi2FMUstate* FMUstate) {
    return fmi2Error;
}

fmi2Status fmi2_serialized_fmu_state_size(fmi2Component c, fmi2FMUstate FMUstate,
                                          size_t* size) {
    return fmi2Error;
}

fmi2Status fmi2_serialize_fmu_state(fmi2Component c, fmi2FMUstate FMUstate,
                                    fmi2Byte serializedState[], size_t size) {
    return fmi2Error;
}

fmi2Status fmi2_de_serialize_fmu_state(fmi2Component c,
                                       const fmi2Byte serializedState[],
                                       size_t size, fmi2FMUstate* FMUstate) {
    return fmi2Error;
}

fmi2Status fmi2_get_directional_derivative(fmi2Component c,
                const fmi2ValueReference vUnknown_ref[], size_t nUnknown,
                const fmi2ValueReference vKnown_ref[],   size_t nKnown,
                const fmi2Real dvKnown[], fmi2Real dvUnknown[]) {
    fmi2Integer retval;
    
    if (c == NULL) {
        return fmi2Fatal;
    }
    
    retval = jmi_get_directional_derivative(&((fmi2_me_t *)c)->jmi, vUnknown_ref,
                    nUnknown, vKnown_ref, nKnown, dvKnown, dvUnknown);
    if (retval != 0) {
        return fmi2Error;
    }
    
    return fmi2OK;
}

fmi2Status fmi2_enter_event_mode(fmi2Component c) {
    fmi2Integer retval;
    
    if (c == NULL) {
        return fmi2Fatal;
    }

    if (((fmi2_me_t *)c)->fmu_mode != continuousTimeMode) {
        jmi_log_node(((fmi2_me_t *)c)->jmi.log, logError, "FMIState",
            "Can only enter event mode from continuous time mode.");
        return fmi2Error;
    }
    
    retval = jmi_enter_event_mode(&((fmi2_me_t *)c)->jmi);
    if (retval != 0) {
        return fmi2Error;
    }
    
    ((fmi2_me_t *)c) -> fmu_mode = eventMode;
    return fmi2OK;
}

fmi2Status fmi2_new_discrete_state(fmi2Component  c, fmi2EventInfo* fmiEventInfo) {
    fmi2Integer retval;
    fmi2_me_t* fmi2_me = (fmi2_me_t *)c;
    
    if (c == NULL) {
        return fmi2Fatal;
    }
    
    fmi2_me->event_info->iteration_converged        = !fmiEventInfo->newDiscreteStatesNeeded;
    fmi2_me->event_info->terminate_simulation       =  fmiEventInfo->terminateSimulation;
    fmi2_me->event_info->nominals_of_states_changed =  fmiEventInfo->nominalsOfContinuousStatesChanged;
    fmi2_me->event_info->state_values_changed       =  fmiEventInfo->valuesOfContinuousStatesChanged;
    fmi2_me->event_info->next_event_time_defined    =  fmiEventInfo->nextEventTimeDefined;
    fmi2_me->event_info->next_event_time            =  fmiEventInfo->nextEventTime;
    
    retval = jmi_event_iteration(&((fmi2_me_t *)c)->jmi, TRUE, fmi2_me->event_info);
    if (retval != 0) {
        return fmi2Error;
    }
    
    fmiEventInfo->newDiscreteStatesNeeded           = !(fmi2_me->event_info->iteration_converged);
    fmiEventInfo->terminateSimulation               =  fmi2_me->event_info->terminate_simulation;
    fmiEventInfo->nominalsOfContinuousStatesChanged =  fmi2_me->event_info->nominals_of_states_changed;
    fmiEventInfo->valuesOfContinuousStatesChanged   =  fmi2_me->event_info->state_values_changed;
    fmiEventInfo->nextEventTimeDefined              =  fmi2_me->event_info->next_event_time_defined;
    fmiEventInfo->nextEventTime                     =  fmi2_me->event_info->next_event_time;
    
    return fmi2OK;
}

fmi2Status fmi2_enter_continuous_time_mode(fmi2Component c) {
    if (c == NULL) {
        return fmi2Fatal;
    }

    if (((fmi2_me_t *)c)->fmu_mode != eventMode) {
        jmi_log_node(((fmi2_me_t *)c)->jmi.log, logError, "FMIState",
            "Can only enter continuous time mode from event mode.");
        return fmi2Error;
    }
    
    ((fmi2_me_t *)c) -> fmu_mode = continuousTimeMode;
    return fmi2OK;
}

fmi2Status fmi2_completed_integrator_step(fmi2Component c,
                                          fmi2Boolean   noSetFMUStatePriorToCurrentPoint, 
                                          fmi2Boolean*  enterEventMode, 
                                          fmi2Boolean*  terminateSimulation) {
    
    fmi2_me_t* self;
    jmi_t* jmi;
    fmi2Real triggered_event;

    if (c == NULL) {
        return fmi2Fatal;
    }
    
    self = (fmi2_me_t*)c;
    jmi = &self->jmi;
    if (jmi_completed_integrator_step(jmi, &triggered_event)) {
        return fmi2Error;
    }
    
    if (triggered_event == 1.0){
        *enterEventMode = fmi2True;
    }else{
        *enterEventMode = fmi2False;
    }
    
    *terminateSimulation = fmi2False;
    return fmi2OK;
}

fmi2Status fmi2_set_time(fmi2Component c, fmi2Real time) {
    fmi2Integer retval;

    if (c == NULL) {
        return fmi2Fatal;
    }

    if (((fmi2_me_t*)c)->stopTime*(1+JMI_ALMOST_EPS) < time) {
        jmi_log_node(((fmi2_me_t *)c)->jmi.log, logError, "Error", "Cannot set a time past the <stop_time: %g>. Asked <time: %g>", ((fmi2_me_t*)c)->stopTime, time);
        return fmi2Error;
    }

    retval = jmi_set_time(&((fmi2_me_t*)c)->jmi, time);
    if (retval != 0) {
        return fmi2Error;
    }
    
    return fmi2OK;
}

fmi2Status fmi2_set_continuous_states(fmi2Component c, const fmi2Real x[],
                                      size_t nx) {
    fmi2Integer retval;

    if (c == NULL) {
        return fmi2Fatal;
    }
    
    retval = jmi_set_continuous_states(&((fmi2_me_t*)c)->jmi, x, nx);
    if (retval != 0) {
        return fmi2Error;
    }

    return fmi2OK;
}

fmi2Status fmi2_get_derivatives(fmi2Component c, fmi2Real derivatives[], size_t nx) {
    fmi2Integer retval;
    
    if (c == NULL) {
        return fmi2Fatal;
    }
    
    retval = jmi_get_derivatives(&((fmi2_me_t *)c)->jmi, derivatives, nx);
    if (retval != 0) {
        return fmi2Error;
    }
    
    return fmi2OK;
}

fmi2Status fmi2_get_event_indicators(fmi2Component c, 
                                     fmi2Real eventIndicators[], size_t ni) {
    fmi2Integer retval;
    
    if (c == NULL) {
        return fmi2Fatal;
    }
    
    retval = jmi_get_event_indicators(&((fmi2_me_t *)c)->jmi, eventIndicators, ni);
    if (retval != 0) {
        return fmi2Error;
    }
    
    return fmi2OK;
}

fmi2Status fmi2_get_continuous_states(fmi2Component c, fmi2Real x[], size_t nx) {
    if (c == NULL) {
        return fmi2Fatal;
    }
    
    memcpy (x, jmi_get_real_x(&((fmi2_me_t *)c)->jmi), nx*sizeof(fmi2Real));
    return fmi2OK;
}

fmi2Status fmi2_get_nominals_of_continuous_states(fmi2Component c, 
                                                  fmi2Real x_nominal[], 
                                                  size_t nx) {
    fmi2Integer retval;
    
    if (c == NULL) {
        return fmi2Fatal;
    }
    
    retval = jmi_get_nominal_continuous_states(&((fmi2_me_t *)c)->jmi, x_nominal, nx);
    if (retval != 0) {
        return fmi2Error;
    }
    
    return fmi2OK;
}

/* Local helper for fmi2_me_instantiate. */
int uri_to_path(char *path, const char* uri) {
    char* scheme   = "file://";
    char buf[3]    = "00";
    int scheme_len = strlen(scheme);
    int uri_len    = strlen(uri);
    int i;
    int j;
    
    if (strncmp(uri, scheme, scheme_len))
        return 1;
        
    if (uri[scheme_len] != '/' && uri[scheme_len] != '\\')
        return 1;
    
#ifdef _WIN32
    scheme_len++;
#endif
    
    if (uri_len <= scheme_len)
        return 1;
    
    for (i = scheme_len, j = 0; i < uri_len; i++, j++) {
        if (uri[i] == '%') {
            if (i < uri_len - 2 && isxdigit(uri[i + 1]) && isxdigit(uri[i + 2])) {
                strncpy(buf, uri + i + 1, 2);
                path[j] = (unsigned char) strtol(buf, NULL, 16);
                i += 2;
            } else {
                return 1;
            }
        } else {
            path[j] = uri[i];
        }
    }
    
    if (path[j-1] == '/' || path[j-1] == '\\') {
        j--;
    }
    path[j] = '\0';
    
    return 0;
}

/* Helper method for fmi2_instatiate. */
fmi2Status fmi2_me_instantiate(fmi2Component c,
                               fmi2String    instanceName,
                               fmi2Type      fmuType, 
                               fmi2String    fmuGUID, 
                               fmi2String    fmuResourceLocation, 
                               const fmi2CallbackFunctions* functions, 
                               fmi2Boolean                  visible,
                               fmi2Boolean                  loggingOn) {
    fmi2Integer retval;
    char* tmpname;
    char* tmpGUID;
    char* resource_location;
    size_t inst_name_len;
    size_t inst_GUID_len;
    
    fmi2_me_t* fmi2_me = (fmi2_me_t*)c;
    jmi_callbacks_t* cb = &fmi2_me->jmi.jmi_callbacks;

    inst_name_len = strlen(instanceName)+1;
    tmpname = (char*)(fmi2_me_t *)functions->allocateMemory(inst_name_len, sizeof(char));
    strncpy(tmpname, instanceName, inst_name_len);
    
    inst_GUID_len = strlen(fmuGUID)+1;
    tmpGUID = (char*)(fmi2_me_t *)functions->allocateMemory(inst_GUID_len, sizeof(char));
    strncpy(tmpGUID, fmuGUID, inst_GUID_len);

    cb->emit_log                    = fmi2_me_emit_log;
    cb->is_log_category_emitted     = fmi2_me_is_log_category_emitted;
    cb->log_options.logging_on_flag = (char)loggingOn;
    cb->log_options.log_level       = 5; /* must be high to let the messages during initialization go through */
    cb->allocate_memory             = functions->allocateMemory;
    cb->free_memory                 = functions->freeMemory;
    cb->model_name                  = jmi_get_model_identifier();    /**< \brief Name of the model (corresponds to a fixed compiled unit name) */
    cb->instance_name               = tmpname;                       /**< \brief Name of this model instance. */
    cb->model_data                  = fmi2_me;
    
    resource_location = (char*)(fmi2_me_t *)functions->allocateMemory(strlen(fmuResourceLocation), sizeof(char));
    retval = uri_to_path(resource_location, fmuResourceLocation);
    if (retval) {
        functions->logger(0, instanceName, fmi2Error, "ERROR", "Invalid fmuResourceLocation <URI:%s>. Expected format: 'file:///absolute/path/resources'", fmuResourceLocation);
        functions->freeMemory(resource_location);
        return fmi2Error;
    }
    
    fmi2_me->fmu_instance_name  = tmpname;
    fmi2_me->fmu_GUID           = tmpGUID;
    fmi2_me->fmi_functions      = functions;
    fmi2_me->fmu_type           = fmuType;
    fmi2_me->fmu_mode           = instantiatedMode;
    fmi2_me->initial_logging_on = loggingOn;
    fmi2_me->stopTime           = JMI_INF; /* Default if not set in setup_experiment */
    fmi2_me->event_info         = (jmi_event_info_t*)(fmi2_me_t *)functions->allocateMemory(1, sizeof(jmi_event_info_t));
    
    retval = jmi_me_init(cb, &fmi2_me->jmi, fmuGUID, resource_location);
    if (retval != 0) {
        return fmi2Error;
    }
    
    fmi2_me->work_real_array    = (fmi2Real*)(fmi2_me_t *)functions->allocateMemory(jmi_get_z_size(&(fmi2_me->jmi)), sizeof(fmi2Real));
    fmi2_me->work_int_array     = (fmi2Integer*)(fmi2_me_t *)functions->allocateMemory(jmi_get_z_size(&(fmi2_me->jmi)), sizeof(fmi2Integer));
    
    return fmi2OK;
}

/* Helper method for fmi2_free_instance. */
void fmi2_me_free_instance(fmi2Component c) {
    fmi2_me_t* fmi2_me = (fmi2_me_t*)c;
    fmi2CallbackFreeMemory fmi_free = fmi2_me->fmi_functions->freeMemory;
    
    fmi_free((void*)fmi2_me->fmu_instance_name);
    fmi_free((void*)fmi2_me->fmu_GUID);
    fmi_free(fmi2_me->jmi.resource_location);
    fmi_free(fmi2_me->event_info);
    fmi_free(fmi2_me->work_real_array);
    fmi_free(fmi2_me->work_int_array);
    jmi_delete(&fmi2_me->jmi);
}
