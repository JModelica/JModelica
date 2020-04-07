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

$C_dae_init_blocks_residual_functions$

$CAD_dae_init_blocks_residual_functions$

void model_init_add_blocks(jmi_t** jmi) {
$C_dae_init_add_blocks_residual_functions$

$CAD_dae_init_add_blocks_residual_functions$
}

$C_ode_initialization$

int model_ode_initialize(jmi_t* jmi) {
    return model_ode_initialize_base(jmi);
}

int model_init_R0(jmi_t* jmi, jmi_real_t** res) {
$C_DAE_initial_event_indicator_residuals$
}
