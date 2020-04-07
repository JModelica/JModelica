/*
    Copyright (C) 2009-2018 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the Common Public License as published by
    IBM, version 1.0 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY. See the Common Public License for more details.

    You should have received a copy of the Common Public License
    along with this program. If not, see
    <http://www.ibm.com/developerworks/library/os-cpl.html/>.
*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "fmiModelFunctions.h"
#include <jmi.h>
#include <fmi1_me.h>
#include "ModelicaUtilities.h"
#include "ModelicaStandardTables.h"

#define MODEL_IDENTIFIER $C_model_id$

/* FMI Functions*/

/* Inquire version numbers of header files */
DllExport const char* fmiGetModelTypesPlatform() {
    return fmi1_me_get_model_types_platform();
}
DllExport const char* fmiGetVersion() {
    return fmi1_me_get_version();
}

/* Creation and destruction of model instances and setting debug status */
DllExport fmiComponent fmiInstantiateModel(fmiString instanceName, fmiString GUID, fmiCallbackFunctions functions, fmiBoolean loggingOn) {
$HOOK__C_FMI_instantiate$    
    return fmi1_me_instantiate_model(instanceName, GUID, functions, loggingOn);
}

DllExport void fmiFreeModelInstance(fmiComponent c) {
    fmi1_me_free_model_instance(c);
}

DllExport fmiStatus fmiSetDebugLogging(fmiComponent c, fmiBoolean loggingOn) {
    return fmi1_me_set_debug_logging(c, loggingOn);
}


/* Providing independent variables and re-initialization of caching */
DllExport fmiStatus fmiSetTime(fmiComponent c, fmiReal fmitime) {
    return fmi1_me_set_time(c, fmitime);
}

DllExport fmiStatus fmiSetContinuousStates(fmiComponent c, const fmiReal x[], size_t nx) {
    return fmi1_me_set_continuous_states(c, x, nx);
}

DllExport fmiStatus fmiCompletedIntegratorStep(fmiComponent c, fmiBoolean* callEventUpdate) {
    return fmi1_me_completed_integrator_step(c, callEventUpdate);
}

DllExport fmiStatus fmiSetReal(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiReal value[]) {
    return fmi1_me_set_real(c, vr, nvr, value);
}

DllExport fmiStatus fmiSetInteger(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiInteger value[]) {
    return fmi1_me_set_integer(c, vr, nvr, value);
}

DllExport fmiStatus fmiSetBoolean(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiBoolean value[]) {
    return fmi1_me_set_boolean(c, vr, nvr, value);
}

DllExport fmiStatus fmiSetString(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiString  value[]) {
    return fmi1_me_set_string(c, vr, nvr, value);
}


/* Evaluation of the model equations */
DllExport fmiStatus fmiInitialize(fmiComponent c, fmiBoolean toleranceControlled, fmiReal relativeTolerance, fmiEventInfo* eventInfo) {
    return fmi1_me_initialize(c, toleranceControlled, relativeTolerance, eventInfo);
}

DllExport fmiStatus fmiGetDerivatives(fmiComponent c, fmiReal derivatives[] , size_t nx) {
    return fmi1_me_get_derivatives(c, derivatives, nx);
}

DllExport fmiStatus fmiGetEventIndicators(fmiComponent c, fmiReal eventIndicators[], size_t ni) {
    return fmi1_me_get_event_indicators(c, eventIndicators, ni);
}

DllExport fmiStatus fmiGetReal(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiReal value[]) {
    return fmi1_me_get_real(c, vr, nvr, value);
}

DllExport fmiStatus fmiGetInteger(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiInteger value[]) {
    return fmi1_me_get_integer(c, vr, nvr, value);
}

DllExport fmiStatus fmiGetBoolean(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiBoolean value[]) {
    return fmi1_me_get_boolean(c, vr, nvr, value);
}

DllExport fmiStatus fmiGetString(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiString  value[]) {
    return fmi1_me_get_string(c, vr, nvr, value);
}

DllExport jmi_t* fmiGetJMI(fmiComponent c) {
    return fmi1_me_get_jmi_t(c);
}

DllExport fmiStatus fmiEventUpdate(fmiComponent c, fmiBoolean intermediateResults, fmiEventInfo* eventInfo) {
    return fmi1_me_event_update(c, intermediateResults, eventInfo);
}

DllExport fmiStatus fmiGetContinuousStates(fmiComponent c, fmiReal states[], size_t nx) {
    return fmi1_me_get_continuous_states(c, states, nx);
}

DllExport fmiStatus fmiGetNominalContinuousStates(fmiComponent c, fmiReal x_nominal[], size_t nx) {
    return fmi1_me_get_nominal_continuous_states(c, x_nominal, nx);
}

DllExport fmiStatus fmiGetStateValueReferences(fmiComponent c, fmiValueReference vrx[], size_t nx) {
    return fmi1_me_get_state_value_references(c, vrx, nx);
}

DllExport fmiStatus fmiTerminate(fmiComponent c) {
    return fmi1_me_terminate(c);
}

DllExport fmiStatus fmiExtractDebugInfo(fmiComponent c) {
    return fmi1_me_extract_debug_info(c);
}
