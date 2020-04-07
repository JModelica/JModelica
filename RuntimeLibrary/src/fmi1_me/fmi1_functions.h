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

/** \file fmi1_functions.h
 *  \brief The FMI 1.0 types
 */

#ifndef _FMI1_FUNCTIONS_H
#ifndef fmiModelFunctions_h
#ifndef fmiCSFunctions_h
#define _FMI1_FUNCTIONS_H

#include "fmi1_types.h"
#include <stdlib.h>

/* Version number */
#define fmiVersion "1.0"

/** FMI 1.0 status codes */
typedef enum {
    fmiOK,
    fmiWarning,
    fmiDiscard,
    fmiError,
    fmiFatal,
    fmiPending
} fmiStatus;

/** FMI 1.0 logger function type */
typedef void  (*fmiCallbackLogger)        (fmiComponent c, fmiString instanceName, fmiStatus status, fmiString category, fmiString message, ...);
/** FMI 1.0 allocate memory function type */
typedef void* (*fmiCallbackAllocateMemory)(size_t nobj, size_t size);
/** FMI 1.0 free memory  function type */
typedef void  (*fmiCallbackFreeMemory)    (void* obj);
/** FMI 1.0 step finished callback function type */
typedef void  (*fmiStepFinished)          (fmiComponent c, fmiStatus status);

/** Functions for FMI 1.0 ME */
typedef struct {
    fmiCallbackLogger         logger;
    fmiCallbackAllocateMemory allocateMemory;
    fmiCallbackFreeMemory     freeMemory;
} fmiMECallbackFunctions;

/** The FMI 1.0 CS strcuture adds one field to the ME, otherwize compatible */
typedef struct {
    fmiCallbackLogger         logger;
    fmiCallbackAllocateMemory allocateMemory;
    fmiCallbackFreeMemory     freeMemory;
    fmiStepFinished           stepFinished;
} fmiCallbackFunctions;

/** Event info structure as used in FMI 1.0 ME */
typedef struct {
    fmiBoolean iterationConverged;
    fmiBoolean stateValueReferencesChanged;
    fmiBoolean stateValuesChanged;
    fmiBoolean terminateSimulation;
    fmiBoolean upcomingTimeEvent;
    fmiReal    nextEventTime;
} fmiEventInfo;

/** FMI 1.0 asyncronous co-simulation  status */
/*
typedef enum {
    fmi1_do_step_status,
    fmi1_pending_status,
    fmi1_last_successful_time
} fmiStatusKind;
*/
typedef enum {
    fmiDoStepStatus,
    fmiPendingStatus,
    fmiLastSuccessfulTime
} fmiStatusKind;

/* FMI 1.0 common functions */
typedef const char*         (*fmi1_get_version_ft)                  (void);
typedef fmiStatus       (*fmi1_set_debug_logging_ft)            (fmiComponent c, fmiBoolean loggingOn);
typedef fmiStatus       (*fmi1_set_real_ft)                     (fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiReal   value[]);
typedef fmiStatus       (*fmi1_set_integer_ft)                  (fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiInteger value[]);
typedef fmiStatus       (*fmi1_set_boolean_ft)                  (fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiBoolean value[]);
typedef fmiStatus       (*fmi1_set_string_ft)                   (fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiString  value[]);
typedef fmiStatus       (*fmi1_get_real_ft)                     (fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiReal   value[]);
typedef fmiStatus       (*fmi1_get_integer_ft)                  (fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiInteger value[]);
typedef fmiStatus       (*fmi1_get_boolean_ft)                  (fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiBoolean value[]);
typedef fmiStatus       (*fmi1_get_string_ft)                   (fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiString  value[]);

/* FMI ME 1.0 functions */
typedef const char*         (*fmi1_get_model_typesPlatform_ft)      (void);
typedef fmiComponent    (*fmi1_instantiate_model_ft)            (fmiString instanceName, fmiString GUID, fmiMECallbackFunctions functions, fmiBoolean loggingOn);
typedef void                (*fmi1_free_model_instance_ft)          (fmiComponent c);
typedef fmiStatus       (*fmi1_set_time_ft)                 (fmiComponent c, fmiReal time);
typedef fmiStatus       (*fmi1_set_continuous_states_ft)        (fmiComponent c, const fmiReal x[], size_t nx);
typedef fmiStatus       (*fmi1_completed_integrator_step_ft)    (fmiComponent c, fmiBoolean* callEventUpdate);
typedef fmiStatus       (*fmi1_initialize_ft)                   (fmiComponent c, fmiBoolean toleranceControlled, fmiReal relativeTolerance, fmiEventInfo* eventInfo);
typedef fmiStatus       (*fmi1_get_derivatives_ft)              (fmiComponent c, fmiReal derivatives[]    , size_t nx);
typedef fmiStatus       (*fmi1_get_event_indicators_ft)         (fmiComponent c, fmiReal eventIndicators[], size_t ni);
typedef fmiStatus       (*fmi1_event_update_ft)             (fmiComponent c, fmiBoolean intermediateResults, fmiEventInfo* eventInfo);
typedef fmiStatus       (*fmi1_get_continuous_states_ft)        (fmiComponent c, fmiReal states[], size_t nx);
typedef fmiStatus       (*fmi1_get_nominal_continuousStates_ft) (fmiComponent c, fmiReal x_nominal[], size_t nx);
typedef fmiStatus       (*fmi1_get_state_valueReferences_ft)    (fmiComponent c, fmiValueReference vrx[], size_t nx);
typedef fmiStatus       (*fmi1_terminate_ft)                    (fmiComponent c);  


/* FMI CS 1.0 functions */
typedef const char*     (*fmi1_get_types_platform_ft)           (void );
typedef fmiComponent    (*fmi1_instantiate_slave_ft)            (fmiString  instanceName, fmiString  fmuGUID, fmiString  fmuLocation, 
                                                             fmiString  mimeType, fmiReal timeout, fmiBoolean visible, fmiBoolean interactive, 
                                                             fmiCallbackFunctions functions, fmiBoolean loggingOn);
typedef fmiStatus       (*fmi1_initialize_slave_ft)         (fmiComponent c, fmiReal tStart, fmiBoolean StopTimeDefined, fmiReal tStop);
typedef fmiStatus       (*fmi1_terminate_slave_ft)              (fmiComponent c);
typedef fmiStatus       (*fmi1_reset_slave_ft)                  (fmiComponent c);
typedef void                (*fmi1_free_slave_instance_ft)          (fmiComponent c);
typedef fmiStatus       (*fmi1_set_real_inputDerivatives_ft)    (fmiComponent c, const  fmiValueReference vr[], size_t nvr, const fmiInteger order[], const  fmiReal value[]);                                                  
typedef fmiStatus       (*fmi1_get_real_outputDerivatives_ft)   (fmiComponent c, const fmiValueReference vr[], size_t  nvr, const fmiInteger order[], fmiReal value[]);                                              
typedef fmiStatus       (*fmi1_cancel_step_ft)                  (fmiComponent c);
typedef fmiStatus       (*fmi1_do_step_ft)                      (fmiComponent c, fmiReal currentCommunicationPoint, fmiReal communicationStepSize, fmiBoolean newStep);

typedef fmiStatus       (*fmi1_get_status_ft)                   (fmiComponent c, const fmiStatusKind s, fmiStatus*  value);
typedef fmiStatus       (*fmi1_get_real_status_ft)              (fmiComponent c, const fmiStatusKind s, fmiReal*    value);
typedef fmiStatus       (*fmi1_get_integer_status_ft)           (fmiComponent c, const fmiStatusKind s, fmiInteger* value);
typedef fmiStatus       (*fmi1_get_boolean_status_ft)           (fmiComponent c, const fmiStatusKind s, fmiBoolean* value);
typedef fmiStatus       (*fmi1_get_string_status_ft)            (fmiComponent c, const fmiStatusKind s, fmiString*  value); 


#define FMI_STATES 1
#define FMI_INPUTS 2
#define FMI_DERIVATIVES 1
#define FMI_OUTPUTS 2

typedef fmiStatus (*fmi1_get_jacobian_ft) (fmiComponent c, int independents, int dependents, fmiReal jac[], size_t njac);
typedef fmiStatus (*fmi1_get_directional_derivative_ft) (fmiComponent c, const fmiValueReference z_vref[], size_t nzvr, const fmiValueReference v_vref[], size_t nvvr, fmiReal dz[], const fmiReal dv[]);
typedef fmiStatus (*fmi1_get_partial_derivatives_ft) (fmiComponent c, fmiStatus (*setMatrixElement)(void* data, fmiInteger row, fmiInteger col, fmiReal value), void* A, void* B, void* C, void* D);

#ifndef _WIN32
#define DllExport
#endif

#endif
#endif
#endif
