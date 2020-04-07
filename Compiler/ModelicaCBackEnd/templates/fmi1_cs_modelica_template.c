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
#include "fmiCSFunctions.h"
#include "fmi1_functions.h"
#include <jmi.h>
#include <fmi1_me.h>
#include <fmi1_cs.h>
#include "ModelicaUtilities.h"
#include "ModelicaStandardTables.h"

#define MODEL_IDENTIFIER $C_model_id$

/* FMI for co-simulation Functions*/

/* Inquire version numbers of header files */
DllExport const char* fmiGetTypesPlatform() {
    return fmi1_cs_get_types_platform();
}
DllExport const char* fmiGetVersion() {
    return fmi1_cs_get_version();
}

DllExport void fmiFreeSlaveInstance(fmiComponent c) {
    fmi1_cs_free_slave_instance(c);
}

/* Creation and destruction of model instances and setting debug status */
DllExport fmiComponent fmiInstantiateSlave(fmiString instanceName, fmiString GUID, fmiString fmuLocation, fmiString mimeType, 
                                   fmiReal timeout, fmiBoolean visible, fmiBoolean interactive, fmiCallbackFunctions functions, 
                                   fmiBoolean loggingOn) {
    return fmi1_cs_instantiate_slave(instanceName, GUID, fmuLocation, mimeType, timeout, visible, interactive, functions, loggingOn);
}


DllExport fmiStatus fmiTerminateSlave(fmiComponent c) {
    return fmi1_cs_terminate_slave(c);
}

DllExport fmiStatus fmiInitializeSlave(fmiComponent c, fmiReal tStart,
                                    fmiBoolean StopTimeDefined, fmiReal tStop){
    return fmi1_cs_initialize_slave(c,tStart,StopTimeDefined,tStop);
}

DllExport fmiStatus fmiSetDebugLogging(fmiComponent c, fmiBoolean loggingOn) {
    return fmi1_cs_set_debug_logging(c, loggingOn);
}

DllExport fmiStatus fmiDoStep(fmiComponent c,
			      fmiReal      currentCommunicationPoint,
			      fmiReal      communicationStepSize,
			      fmiBoolean   newStep) {
  return fmi1_cs_do_step(c, currentCommunicationPoint, communicationStepSize, newStep);
}

DllExport fmiStatus fmiCancelStep(fmiComponent c){
    return fmi1_cs_cancel_step(c);
}

DllExport fmiStatus fmiResetSlave(fmiComponent c) {
    return fmi1_cs_reset_slave(c);
}

DllExport fmiStatus fmiGetRealOutputDerivatives(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiInteger order[], fmiReal value[]){
    return fmi1_cs_get_real_output_derivatives(c, vr, nvr, order, value);
}

DllExport fmiStatus fmiSetRealInputDerivatives(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiInteger order[], const fmiReal value[]){
    return fmi1_cs_set_real_input_derivatives(c,vr,nvr,order,value);
}

DllExport fmiStatus fmiSetReal(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiReal value[]) {
    return fmi1_cs_set_real(c, vr, nvr, value);
}

DllExport fmiStatus fmiSetInteger(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiInteger value[]) {
    return fmi1_cs_set_integer(c, vr, nvr, value);
}

DllExport fmiStatus fmiSetBoolean(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiBoolean value[]) {
    return fmi1_cs_set_boolean(c, vr, nvr, value);
}

DllExport fmiStatus fmiSetString(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiString  value[]) {
    return fmi1_cs_set_string(c, vr, nvr, value);
}

DllExport fmiStatus fmiGetReal(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiReal value[]) {
    return fmi1_cs_get_real(c, vr, nvr, value);
}

DllExport fmiStatus fmiGetInteger(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiInteger value[]) {
    return fmi1_cs_get_integer(c, vr, nvr, value);
}

DllExport fmiStatus fmiGetBoolean(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiBoolean value[]) {
    return fmi1_cs_get_boolean(c, vr, nvr, value);
}

DllExport fmiStatus fmiGetString(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiString  value[]) {
    return fmi1_cs_get_string(c, vr, nvr, value);
}

DllExport fmiStatus fmiGetStatus(fmiComponent c, const fmiStatusKind s, fmiStatus* value){
    return fmi1_cs_get_status(c,s,value);
}

DllExport fmiStatus fmiGetRealStatus(fmiComponent c, const fmiStatusKind s, fmiReal* value){
    return fmi1_cs_get_real_status(c, s, value);
}

DllExport fmiStatus fmiGetIntegerStatus(fmiComponent c, const fmiStatusKind s, fmiInteger* value){
    return fmi1_cs_get_integer_status(c, s, value);
}

DllExport fmiStatus fmiGetBooleanStatus(fmiComponent c, const fmiStatusKind s, fmiBoolean* value){
    return fmi1_cs_get_boolean_status(c, s, value);
}

DllExport fmiStatus fmiGetStringStatus(fmiComponent c, const fmiStatusKind s, fmiString* value){
    return fmi1_cs_get_string_status(c,s,value);
}
