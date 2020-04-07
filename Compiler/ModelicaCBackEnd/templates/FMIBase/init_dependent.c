/*
    Copyright (C) 2015-2018 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the Common Public License as published by
    IBM, version 1.0 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY. See the Common Public License for more details.

    You should have received a copy of the Common Public License
    along with this program. If not, see
    <http://www.ibm.com/developerworks/library/os-cpl.html/>.
*/

$C_model_init_eval_dependent_parameters$

$C_model_init_eval_dependent_variables$

int model_init_eval_dependent(jmi_t* jmi) {
    model_init_eval_dependent_parameters(jmi);
    model_init_eval_dependent_variables(jmi);
    return 0;
}