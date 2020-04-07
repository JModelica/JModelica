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

static const int N_real_ci = $n_real_ci$;
static const int N_real_cd = $n_real_cd$;
static const int N_real_pi = $n_real_pi$;
static const int N_real_pi_s = $n_real_pi_s$;
static const int N_real_pi_f = $n_real_pi_f$;
static const int N_real_pi_e = $n_real_pi_e$;
static const int N_real_pd = $n_real_pd$;

static const int N_integer_ci = $n_integer_ci$ + $n_enum_ci$;
static const int N_integer_cd = $n_integer_cd$ + $n_enum_cd$;
static const int N_integer_pi = $n_integer_pi$ + $n_enum_pi$;
static const int N_integer_pi_s = $n_integer_pi_s$ + $n_enum_pi_s$;
static const int N_integer_pi_f = $n_integer_pi_f$ + $n_enum_pi_f$;
static const int N_integer_pi_e = $n_integer_pi_e$ + $n_enum_pi_e$;
static const int N_integer_pd = $n_integer_pd$ + $n_enum_pd$;

static const int N_boolean_ci = $n_boolean_ci$;
static const int N_boolean_cd = $n_boolean_cd$;
static const int N_boolean_pi = $n_boolean_pi$;
static const int N_boolean_pi_s = $n_boolean_pi_s$;
static const int N_boolean_pi_f = $n_boolean_pi_f$;
static const int N_boolean_pi_e = $n_boolean_pi_e$;
static const int N_boolean_pd = $n_boolean_pd$;

static const int N_real_dx = $n_real_x$;
static const int N_real_x = $n_real_x$;
static const int N_real_u = $n_real_u$;
static const int N_real_w = $n_real_w$;

static const int N_real_d = $n_real_d$;

static const int N_integer_d = $n_integer_d$ + $n_enum_d$;
static const int N_integer_u = $n_integer_u$ + $n_enum_u$;

static const int N_boolean_d = $n_boolean_d$;
static const int N_boolean_u = $n_boolean_u$;

static const int N_ext_objs = $n_ext_objs$;

static const int N_time_sw = $n_time_switches$;
static const int N_state_sw = $n_state_switches$;
static const int N_sw = $n_time_switches$ + $n_state_switches$;
static const int N_delay_sw = $n_delay_switches$;
static const int N_eq_F = $n_equations$;
static const int N_eq_R = $n_event_indicators$;

static const int N_dae_blocks = $n_dae_blocks$;
static const int N_dae_init_blocks = $n_dae_init_blocks$;
static const int N_guards = $n_guards$;

static const int N_dynamic_state_sets = $dynamic_state_n_sets$;

static const int N_eq_F0 = $n_equations$ + $n_initial_equations$;
static const int N_eq_F1 = $n_initial_guess_equations$;
static const int N_eq_Fp = 0;
static const int N_eq_R0 = $n_event_indicators$ + $n_initial_event_indicators$;
static const int N_sw_init = $n_initial_switches$;
static const int N_guards_init = $n_guards_init$;

static const int N_delays = $n_delays$;
static const int N_spatialdists = $n_spatialdists$;

static const int N_outputs = $n_outputs$;

static const int Scaling_method = $C_DAE_scaling_method$;

static const int Homotopy_block = $C_DAE_INIT_homotopy_block$;

const char *C_GUID = $C_guid$;

$C_DAE_output_vrefs$

$C_DAE_initial_relations$

$C_DAE_relations$

$C_DAE_nominals$

$C_runtime_option_map$

$C_dynamic_state_coefficients$


int model_ode_guards(jmi_t* jmi) {
$C_ode_guards$
    return 0;
}

static int model_ode_next_time_event(jmi_t* jmi, jmi_time_event_t* nextTimeEvent) {
$C_ode_time_events$
    return 0;
}

static int model_ode_derivatives_dir_der(jmi_t* jmi) {
    int ef = 0;
$CAD_ode_derivatives$
    return ef;
}

static int model_ode_outputs(jmi_t* jmi) {
    int ef = 0;
$C_ode_outputs$
    return ef;
}

int model_ode_guards_init(jmi_t* jmi) {
$C_ode_guards_init$
    return 0;
}

static int model_init_delay(jmi_t* jmi) {
$C_delay_init$
    return 0;
}

static int model_sample_delay(jmi_t* jmi) {
$C_delay_sample$
    return 0;
}

static int jmi_z_offset_strings(jmi_z_strings_t* z) {
$C_z_offsets_strings$
    return 0;
}

int jmi_new(jmi_t** jmi, jmi_callbacks_t* jmi_callbacks) {

    jmi_z_offset_strings(&(*jmi)->z_t.strings);

    jmi_init(jmi, N_real_ci,      N_real_cd,      N_real_pi,      N_real_pi_s,
                  N_real_pi_f,    N_real_pi_e,    N_real_pd,      N_integer_ci,
                  N_integer_cd,   N_integer_pi,   N_integer_pi_s, N_integer_pi_f,
                  N_integer_pi_e, N_integer_pd,   N_boolean_ci,   N_boolean_cd,
                  N_boolean_pi,   N_boolean_pi_s, N_boolean_pi_f, N_boolean_pi_e,
                  N_boolean_pd,   N_real_dx,      N_real_x,       N_real_u, 
                  N_real_w,       N_real_d,       N_integer_d,    N_integer_u,
                  N_boolean_d,    N_boolean_u,    N_sw,           N_sw_init,
                  N_time_sw,      N_state_sw,     N_guards,       N_guards_init,
                  N_dae_blocks,   N_dae_init_blocks, N_initial_relations,
                  (int (*))DAE_initial_relations, N_relations,
                  (int (*))DAE_relations, N_dynamic_state_sets,
                  (jmi_real_t *) DAE_nominals, Scaling_method, N_ext_objs,
                  Homotopy_block, jmi_callbacks);

$C_dynamic_state_add_call$

    model_add_blocks(jmi);
    model_init_add_blocks(jmi);

    /* Initialize the model equations interface */
    jmi_model_init(*jmi,
                   *model_ode_derivatives_dir_der,
                   *model_ode_derivatives,
                   *model_ode_event_indicators,
                   *model_ode_initialize,
                   *model_init_eval_independent,
                   *model_init_eval_dependent,
                   *model_ode_next_time_event);
    
    /* Initialize the delay interface */
    jmi_init_delay_if(*jmi, N_delays, N_spatialdists, *model_init_delay,
                      *model_sample_delay, N_delay_sw);

    /* Initialize globals struct */
    (*jmi)->globals = calloc(1, sizeof(jmi_globals_t));

    return 0;
}

int jmi_destruct_external_objs(jmi_t* jmi) {
$C_destruct_external_object$
    return 0;
}

const char *jmi_get_model_identifier() {
    return "$C_model_id$";
}
