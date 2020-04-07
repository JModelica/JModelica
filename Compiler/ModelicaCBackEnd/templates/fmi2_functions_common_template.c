/*
    Copyright (C) 2013-2018 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the Common Public License as published by
    IBM, version 1.0 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY. See the Common Public License for more details.

    You should have received a copy of the Common Public License
    along with this program. If not, see
    <http://www.ibm.com/developerworks/library/os-cpl.html/>.
*/

/* FMI 2.0 functions common for both ME and CS.*/

FMI2_Export const char* fmi2GetTypesPlatform() {
    return fmi2_get_types_platform();
}

FMI2_Export const char* fmi2GetVersion() {
    return fmi2_get_version();
}

FMI2_Export fmi2Status fmi2SetDebugLogging(fmi2Component    c,
                                           fmi2Boolean      loggingOn, 
                                           size_t           nCategories, 
                                           const fmi2String categories[]) {
    return fmi2_set_debug_logging(c, loggingOn, nCategories, categories);
}

FMI2_Export fmi2Component fmi2Instantiate(fmi2String instanceName,
                                          fmi2Type   fmuType,
                                          fmi2String fmuGUID,
                                          fmi2String fmuResourceLocation,
                                          const fmi2CallbackFunctions* functions,
                                          fmi2Boolean                 visible,
                                          fmi2Boolean                 loggingOn) {
    if (!can_instantiate(fmuType, instanceName, functions))
        return NULL;

    return fmi2_instantiate(instanceName, fmuType, fmuGUID, fmuResourceLocation,
                            functions, visible, loggingOn);
}

FMI2_Export void fmi2FreeInstance(fmi2Component c) {
    fmi2_free_instance(c);
}

FMI2_Export fmi2Status fmi2SetupExperiment(fmi2Component c, 
                                           fmi2Boolean   toleranceDefined, 
                                           fmi2Real      tolerance, 
                                           fmi2Real      startTime, 
                                           fmi2Boolean   stopTimeDefined, 
                                           fmi2Real      stopTime) {
    return fmi2_setup_experiment(c, toleranceDefined, tolerance, startTime,
                                 stopTimeDefined, stopTime);
}

FMI2_Export fmi2Status fmi2EnterInitializationMode(fmi2Component c) {
    return fmi2_enter_initialization_mode(c);
}

FMI2_Export fmi2Status fmi2ExitInitializationMode(fmi2Component c) {
    return fmi2_exit_initialization_mode(c);
}

FMI2_Export fmi2Status fmi2Terminate(fmi2Component c) {
    return fmi2_terminate(c);
}

FMI2_Export fmi2Status fmi2Reset(fmi2Component c) {
    return fmi2_reset(c);
}

FMI2_Export fmi2Status fmi2GetReal(fmi2Component c, const fmi2ValueReference vr[],
                                   size_t nvr, fmi2Real value[]) {
    return fmi2_get_real(c, vr, nvr, value);
}

FMI2_Export fmi2Status fmi2GetInteger(fmi2Component c, const fmi2ValueReference vr[],
                                      size_t nvr, fmi2Integer value[]) {
    return fmi2_get_integer(c, vr, nvr, value);
}

FMI2_Export fmi2Status fmi2GetBoolean(fmi2Component c, const fmi2ValueReference vr[],
                                      size_t nvr, fmi2Boolean value[]) {
    return fmi2_get_boolean(c, vr, nvr, value);
}

FMI2_Export fmi2Status fmi2GetString(fmi2Component c, const fmi2ValueReference vr[],
                                     size_t nvr, fmi2String value[]) {
    return fmi2_get_string(c, vr, nvr, value);
}

FMI2_Export fmi2Status fmi2SetReal(fmi2Component c, const fmi2ValueReference vr[],
                                   size_t nvr, const fmi2Real value[]) {
    return fmi2_set_real(c, vr, nvr, value);
}

FMI2_Export fmi2Status fmi2SetInteger(fmi2Component c, const fmi2ValueReference vr[],
                                      size_t nvr, const fmi2Integer value[]) {
    return fmi2_set_integer(c, vr, nvr, value);
}

FMI2_Export fmi2Status fmi2SetBoolean(fmi2Component c, const fmi2ValueReference vr[],
                                      size_t nvr, const fmi2Boolean value[]) {
    return fmi2_set_boolean(c, vr, nvr, value);
}

FMI2_Export fmi2Status fmi2SetString(fmi2Component c, const fmi2ValueReference vr[],
                                     size_t nvr, const fmi2String value[]) {
    return fmi2_set_string(c, vr, nvr, value);
}

FMI2_Export fmi2Status fmi2GetFMUstate(fmi2Component c, fmi2FMUstate* FMUstate) {
    return fmi2_get_fmu_state(c, FMUstate);
}

FMI2_Export fmi2Status fmi2SetFMUstate(fmi2Component c, fmi2FMUstate FMUstate) {
    return fmi2_set_fmu_state(c, FMUstate);
}

FMI2_Export fmi2Status fmi2FreeFMUstate(fmi2Component c, fmi2FMUstate* FMUstate) {
    return fmi2_free_fmu_state(c, FMUstate);
}

FMI2_Export fmi2Status fmi2SerializedFMUstateSize(fmi2Component c, fmi2FMUstate FMUstate,
                                                  size_t* size) {
    return fmi2_serialized_fmu_state_size(c, FMUstate, size);
}

FMI2_Export fmi2Status fmi2SerializeFMUstate(fmi2Component c, fmi2FMUstate FMUstate,
                                  fmi2Byte serializedState[], size_t size) {
    return fmi2_serialize_fmu_state(c, FMUstate, serializedState, size);
}

FMI2_Export fmi2Status fmi2DeSerializeFMUstate(fmi2Component c,
                                  const fmi2Byte serializedState[],
                                  size_t size, fmi2FMUstate* FMUstate) {
    return fmi2_de_serialize_fmu_state(c, serializedState, size, FMUstate);
}

FMI2_Export fmi2Status fmi2GetDirectionalDerivative(fmi2Component c,
                 const fmi2ValueReference vUnknown_ref[], size_t nUnknown,
                 const fmi2ValueReference vKnown_ref[],   size_t nKnown,
                 const fmi2Real dvKnown[], fmi2Real dvUnknown[]) {
	return fmi2_get_directional_derivative(c, vUnknown_ref, nUnknown,
                                           vKnown_ref, nKnown, dvKnown, dvUnknown);
}
