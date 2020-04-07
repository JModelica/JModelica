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

/* FMI 2.0 functions specific for CS.*/

FMI2_Export fmi2Status fmi2SetRealInputDerivatives(fmi2Component c, 
                                                   const fmi2ValueReference vr[],
                                                   size_t nvr, const fmi2Integer order[],
                                                   const fmi2Real value[]) {
	return fmi2_set_real_input_derivatives(c, vr, nvr, order, value);
}

FMI2_Export fmi2Status fmi2GetRealOutputDerivatives(fmi2Component c,
                                                    const fmi2ValueReference vr[],
                                                    size_t nvr, const fmi2Integer order[],
                                                    fmi2Real value[]) {
	return fmi2_get_real_output_derivatives(c, vr, nvr, order, value);
}

FMI2_Export fmi2Status fmi2DoStep(fmi2Component c, fmi2Real currentCommunicationPoint,
                                  fmi2Real    communicationStepSize,
                                  fmi2Boolean noSetFMUStatePriorToCurrentPoint) {
	return fmi2_do_step(c, currentCommunicationPoint, communicationStepSize,
                        noSetFMUStatePriorToCurrentPoint);
}

FMI2_Export fmi2Status fmi2CancelStep(fmi2Component c) {
	return fmi2_cancel_step(c);
}

FMI2_Export fmi2Status fmi2GetStatus(fmi2Component c, const fmi2StatusKind s,
                                     fmi2Status* value) {
	return fmi2_get_status(c, s, value);
}

FMI2_Export fmi2Status fmi2GetRealStatus(fmi2Component c, const fmi2StatusKind s,
                                         fmi2Real* value) {
	return fmi2_get_real_status(c, s, value);
}

FMI2_Export fmi2Status fmi2GetIntegerStatus(fmi2Component c, const fmi2StatusKind s,
                                            fmi2Integer* values) {
	return fmi2_get_integer_status(c, s, values);
}

FMI2_Export fmi2Status fmi2GetBooleanStatus(fmi2Component c, const fmi2StatusKind s,
                                            fmi2Boolean* value) {
	return fmi2_get_boolean_status(c, s, value);
}

FMI2_Export fmi2Status fmi2GetStringStatus(fmi2Component c, const fmi2StatusKind s,
                                           fmi2String* value) {
	return fmi2_get_string_status(c, s, value);
	
}
