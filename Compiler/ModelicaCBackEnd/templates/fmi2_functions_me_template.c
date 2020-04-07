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

/* FMI 2.0 functions specific for ME.*/

FMI2_Export fmi2Status fmi2EnterEventMode(fmi2Component c) {
	return fmi2_enter_event_mode(c);
}

FMI2_Export fmi2Status fmi2NewDiscreteStates(fmi2Component  c,
                                            fmi2EventInfo* fmiEventInfo) {
	return fmi2_new_discrete_state(c, fmiEventInfo);
}

FMI2_Export fmi2Status fmi2EnterContinuousTimeMode(fmi2Component c) {
	return fmi2_enter_continuous_time_mode(c);
}

FMI2_Export fmi2Status fmi2CompletedIntegratorStep(fmi2Component c,
                                                   fmi2Boolean   noSetFMUStatePriorToCurrentPoint, 
                                                   fmi2Boolean*  enterEventMode, 
                                                   fmi2Boolean*   terminateSimulation) {
	return fmi2_completed_integrator_step(c, noSetFMUStatePriorToCurrentPoint,
                                          enterEventMode, terminateSimulation);
}

FMI2_Export fmi2Status fmi2SetTime(fmi2Component c, fmi2Real time) {
	return fmi2_set_time(c, time);
}

FMI2_Export fmi2Status fmi2SetContinuousStates(fmi2Component c, const fmi2Real x[],
                                               size_t nx) {
	return fmi2_set_continuous_states(c, x, nx);
}

FMI2_Export fmi2Status fmi2GetDerivatives(fmi2Component c, fmi2Real derivatives[],
                                          size_t nx) {
	return fmi2_get_derivatives(c, derivatives, nx);
}

FMI2_Export fmi2Status fmi2GetEventIndicators(fmi2Component c, 
                                              fmi2Real eventIndicators[], size_t ni) {
	return fmi2_get_event_indicators(c, eventIndicators, ni);
}

FMI2_Export fmi2Status fmi2GetContinuousStates(fmi2Component c, fmi2Real x[],
                                               size_t nx) {
	return fmi2_get_continuous_states(c, x, nx);
}

FMI2_Export fmi2Status fmi2GetNominalsOfContinuousStates(fmi2Component c, 
                                                         fmi2Real x_nominal[], 
                                                         size_t nx) {
	return fmi2_get_nominals_of_continuous_states(c, x_nominal, nx);
}
