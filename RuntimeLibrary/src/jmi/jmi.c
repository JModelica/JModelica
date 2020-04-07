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


/*
 * jmi.c contains pure C functions and does not support any AD functions.
 */


#include "jmi.h"
#include "jmi_block_residual.h"
#include "jmi_log.h"
#include "jmi_delay_impl.h"
#include "jmi_dynamic_state.h"
#include "jmi_chattering.h"
#include "module_include/jmi_get_set.h"

void jmi_z_init(jmi_z_t* z) {
    z->strings.values = jmi_create_strings(z->strings.n);
}

void jmi_z_delete(jmi_z_t* z) {
    jmi_free_strings(z->strings.values, z->strings.n);
}

void jmi_model_init(jmi_t* jmi,
                    jmi_generic_func_t model_ode_derivatives_dir_der,
                    jmi_generic_func_t model_ode_derivatives,
                    jmi_residual_func_t model_ode_event_indicators,
                    jmi_generic_func_t model_ode_initialize,
                    jmi_generic_func_t model_init_eval_independent,
                    jmi_generic_func_t model_init_eval_dependent,
                    jmi_next_time_event_func_t model_ode_next_time_event) {
    
    /* Create jmi_model_t struct */
    jmi_model_t* model = (jmi_model_t*)calloc(1, sizeof(jmi_model_t));
    jmi->model = model;
    
    jmi->model->ode_derivatives = model_ode_derivatives;
    jmi->model->ode_derivatives_dir_der = model_ode_derivatives_dir_der;
    jmi->model->ode_initialize = model_ode_initialize;
    jmi->model->ode_next_time_event = model_ode_next_time_event;
    jmi->model->ode_event_indicators = model_ode_event_indicators;
    jmi->model->init_eval_independent = model_init_eval_independent;
    jmi->model->init_eval_dependent   = model_init_eval_dependent;
}

void jmi_model_delete(jmi_t* jmi) {
    if (jmi->model) {
        free(jmi->model);
    }
}

int jmi_init(jmi_t** jmi,
        int n_real_ci, int n_real_cd, int n_real_pi,
        int n_real_pi_s, int n_real_pi_f, int n_real_pi_e, int n_real_pd,
        int n_integer_ci, int n_integer_cd, int n_integer_pi,
        int n_integer_pi_s, int n_integer_pi_f, int n_integer_pi_e, int n_integer_pd, 
        int n_boolean_ci, int n_boolean_cd, int n_boolean_pi,
        int n_boolean_pi_s, int n_boolean_pi_f, int n_boolean_pi_e, int n_boolean_pd,
        int n_real_dx, int n_real_x, int n_real_u, int n_real_w,
        int n_real_d, int n_integer_d, int n_integer_u,
        int n_boolean_d, int n_boolean_u,
        int n_sw, int n_sw_init, int n_time_sw, int n_state_sw,
        int n_guards, int n_guards_init,
        int n_dae_blocks, int n_dae_init_blocks,
        int n_initial_relations, int* initial_relations,
        int n_relations, int* relations, int n_dynamic_state_sets,
        jmi_real_t* nominals,
        int scaling_method, int n_ext_objs,
        int homotopy_block, jmi_callbacks_t* jmi_callbacks) {
    jmi_t* jmi_ ;
    int i;
    
    /* Create jmi struct */    
    jmi_ = *jmi;
    
    /* Set sizes of dae vectors */
    jmi_->n_real_ci = n_real_ci;
    jmi_->n_real_cd = n_real_cd;
    jmi_->n_real_pi = n_real_pi;
    jmi_->n_real_pd = n_real_pd;

    jmi_->n_integer_ci = n_integer_ci;
    jmi_->n_integer_cd = n_integer_cd;
    jmi_->n_integer_pi = n_integer_pi;
    jmi_->n_integer_pd = n_integer_pd;

    jmi_->n_boolean_ci = n_boolean_ci;
    jmi_->n_boolean_cd = n_boolean_cd;
    jmi_->n_boolean_pi = n_boolean_pi;
    jmi_->n_boolean_pd = n_boolean_pd;

    jmi_->n_real_dx = n_real_dx;
    jmi_->n_real_x = n_real_x;
    jmi_->n_real_u = n_real_u;
    jmi_->n_real_w = n_real_w;

    jmi_->n_real_d = n_real_d;

    jmi_->n_integer_d = n_integer_d;
    jmi_->n_integer_u = n_integer_u;

    jmi_->n_boolean_d = n_boolean_d;
    jmi_->n_boolean_u = n_boolean_u;

    jmi_->n_sw = n_sw;
    jmi_->n_sw_init = n_sw_init;
    jmi_->n_time_sw = n_time_sw;
    jmi_->n_state_sw = n_state_sw;

    jmi_->n_guards = n_guards;
    jmi_->n_guards_init = n_guards_init;
    
    jmi_->n_dae_blocks = n_dae_blocks;
    jmi_->n_dae_init_blocks = n_dae_init_blocks;

    jmi_->offs_real_ci = 0;
    jmi_->offs_real_cd = jmi_->offs_real_ci + n_real_ci;
    jmi_->offs_real_pi = jmi_->offs_real_cd + n_real_cd;
    jmi_->offs_real_pi_s = jmi_->offs_real_pi   + n_real_pi
        - (n_real_pi_s + n_real_pi_f + n_real_pi_e);
    jmi_->offs_real_pi_f = jmi_->offs_real_pi_s + n_real_pi_s;
    jmi_->offs_real_pi_e = jmi_->offs_real_pi_f + n_real_pi_f;
    jmi_->offs_real_pd = jmi_->offs_real_pi + n_real_pi;

    jmi_->offs_integer_ci = jmi_->offs_real_pd + n_real_pd;
    jmi_->offs_integer_cd = jmi_->offs_integer_ci + n_integer_ci;
    jmi_->offs_integer_pi = jmi_->offs_integer_cd + n_integer_cd;
    jmi_->offs_integer_pi_s = jmi_->offs_integer_pi   + n_integer_pi
        - (n_integer_pi_s + n_integer_pi_f + n_integer_pi_e);
    jmi_->offs_integer_pi_f = jmi_->offs_integer_pi_s + n_integer_pi_s;
    jmi_->offs_integer_pi_e = jmi_->offs_integer_pi_f + n_integer_pi_f;
    jmi_->offs_integer_pd = jmi_->offs_integer_pi + n_integer_pi;

    jmi_->offs_boolean_ci = jmi_->offs_integer_pd + n_integer_pd;
    jmi_->offs_boolean_cd = jmi_->offs_boolean_ci + n_boolean_ci;
    jmi_->offs_boolean_pi = jmi_->offs_boolean_cd + n_boolean_cd;
    jmi_->offs_boolean_pi_s = jmi_->offs_boolean_pi   + n_boolean_pi
        - (n_boolean_pi_s + n_boolean_pi_f + n_boolean_pi_e);
    jmi_->offs_boolean_pi_f = jmi_->offs_boolean_pi_s + n_boolean_pi_s;
    jmi_->offs_boolean_pi_e = jmi_->offs_boolean_pi_f + n_boolean_pi_f;
    jmi_->offs_boolean_pd = jmi_->offs_boolean_pi + n_boolean_pi;

    jmi_->offs_real_dx = jmi_->offs_boolean_pd + n_boolean_pd;
    jmi_->offs_real_x = jmi_->offs_real_dx + n_real_dx;
    jmi_->offs_real_u = jmi_->offs_real_x + n_real_x;
    jmi_->offs_real_w = jmi_->offs_real_u + n_real_u;

    jmi_->offs_t = jmi_->offs_real_w + n_real_w;
    jmi_->offs_homotopy_lambda = jmi_->offs_t + 1;

    jmi_->offs_real_d = jmi_->offs_homotopy_lambda + 1;

    jmi_->offs_integer_d = jmi_->offs_real_d + n_real_d;
    jmi_->offs_integer_u = jmi_->offs_integer_d + n_integer_d;

    jmi_->offs_boolean_d = jmi_->offs_integer_u + n_integer_u;
    jmi_->offs_boolean_u = jmi_->offs_boolean_d + n_boolean_d;

    jmi_->offs_sw = jmi_->offs_boolean_u + n_boolean_u;
    jmi_->offs_sw_init = jmi_->offs_sw + n_sw;
    jmi_->offs_state_sw = jmi_->offs_sw;
    jmi_->offs_time_sw = jmi_->offs_sw+n_state_sw;

    jmi_->offs_guards = jmi_->offs_sw_init + n_sw_init;
    jmi_->offs_guards_init = jmi_->offs_guards + n_guards;

    jmi_->offs_pre_real_dx = jmi_->offs_guards_init + n_guards_init;
    jmi_->offs_pre_real_x = jmi_->offs_pre_real_dx + n_real_dx;
    jmi_->offs_pre_real_u = jmi_->offs_pre_real_x + n_real_x;
    jmi_->offs_pre_real_w = jmi_->offs_pre_real_u + n_real_u;

    jmi_->offs_pre_real_d = jmi_->offs_pre_real_w + n_real_w;
    jmi_->offs_pre_integer_d = jmi_->offs_pre_real_d + n_real_d;
    jmi_->offs_pre_integer_u = jmi_->offs_pre_integer_d + n_integer_d;

    jmi_->offs_pre_boolean_d = jmi_->offs_pre_integer_u + n_integer_u;
    jmi_->offs_pre_boolean_u = jmi_->offs_pre_boolean_d + n_boolean_d;
    jmi_->offs_pre_sw = jmi_->offs_pre_boolean_u + n_boolean_u;
    jmi_->offs_pre_sw_init = jmi_->offs_pre_sw + n_sw;
    jmi_->offs_pre_guards = jmi_->offs_pre_sw_init + n_sw_init;
    jmi_->offs_pre_guards_init = jmi_->offs_pre_guards + n_guards;

    jmi_->n_v = n_real_dx + n_real_x + n_real_u + n_real_w + n_real_d + 2;
    jmi_->n_z = jmi_->offs_real_dx + 2*(jmi_->n_v) - 2 + 
        2*(n_real_d + n_integer_d + n_integer_u + n_boolean_d + n_boolean_u) + 
        2*n_sw + 2*n_sw_init + 2*n_guards + 2*n_guards_init;

    jmi_z_init(&jmi_->z_t);
    jmi_->z = (jmi_real_t**)calloc(1,sizeof(jmi_real_t *));
    *(jmi_->z) = (jmi_real_t*)calloc(jmi_->n_z,sizeof(jmi_real_t));
    jmi_->z_last    = (jmi_real_t**)calloc(1,sizeof(jmi_real_t *));
    *(jmi_->z_last) = (jmi_real_t*)calloc(jmi_->n_z,sizeof(jmi_real_t));
    /*jmi_->pre_z = (jmi_real_t*)calloc(jmi_->n_z,sizeof(jmi_real_t ));*/
    
    jmi_->dz = (jmi_real_t**)calloc(1, sizeof(jmi_real_t *));
    *(jmi_->dz) = (jmi_real_t*)calloc(jmi_->n_v, sizeof(jmi_real_t));/*Need number of equations*/
    
    jmi_->ext_objs = (void**)calloc(n_ext_objs, sizeof(void*));
    jmi_->block_level = 0;
    jmi_->dz_active_index = 0;
    for (i=0;i<JMI_ACTIVE_VAR_BUFS_NUM;i++) {
        jmi_->dz_active_variables_buf[i] = (jmi_real_t*)calloc(jmi_->n_v, sizeof(jmi_real_t));
    }
    
    jmi_->dz_active_variables[0] = jmi_->dz_active_variables_buf[0];

    jmi_->variable_scaling_factors = (jmi_real_t*)calloc(jmi_->n_z,sizeof(jmi_real_t));
    jmi_->scaling_method = scaling_method;

    for (i=0;i<jmi_->n_z;i++) {
        jmi_->variable_scaling_factors[i] = 1.0;
        (*(jmi_->z))[i] = 0;
        (*(jmi_->z_last))[i] = 0;
    }
    /* jmi_save_last_successful_values(jmi_); */

    for (i=0;i<jmi_->n_v;i++) {
        int j;
        (*(jmi_->dz))[i] = 0;
        for (j=0; j<JMI_ACTIVE_VAR_BUFS_NUM; j++) {
            jmi_->dz_active_variables_buf[j][i] = 0;
        }
    }
    jmi_->n_dynamic_state_sets = n_dynamic_state_sets;
    jmi_->dynamic_state_sets = (jmi_dynamic_state_set_t*)calloc(n_dynamic_state_sets,sizeof(jmi_dynamic_state_set_t));
    jmi_->updated_states = FALSE;
    
    jmi_->chattering = jmi_chattering_create(n_sw);
    
    /* Work arrays */
    jmi_->real_x_work = (jmi_real_t*)calloc(jmi_->n_real_x,sizeof(jmi_real_t));
    jmi_->real_u_work = (jmi_real_t*)calloc(jmi_->n_real_u,sizeof(jmi_real_t));
    jmi_->int_work = jmi_create_int_work_array(JMI_INT_WORK_ARRAY_SIZE); 
    jmi_->real_work = jmi_create_real_work_array(JMI_REAL_WORK_ARRAY_SIZE);

    jmi_->n_initial_relations = n_initial_relations;
    jmi_->n_relations = n_relations;
    jmi_->initial_relations = (jmi_int_t*)calloc(n_initial_relations,sizeof(jmi_int_t));
    jmi_->relations = (jmi_int_t*)calloc(n_relations,sizeof(jmi_int_t));

    /* TODO: if we define the incoming vectors as jmi_int_t*, then we can use memcpy instead */
    for (i=0;i<n_initial_relations;i++) {
        jmi_->initial_relations[i] = initial_relations[i];
    }

    for (i=0;i<n_relations;i++) {
        jmi_->relations[i] = relations[i];
    }

    jmi_->nominals = (jmi_real_t*) calloc(n_real_x, sizeof(jmi_real_t));
    memcpy(jmi_->nominals, nominals, n_real_x * sizeof(jmi_real_t));

    jmi_->dae_block_residuals = (jmi_block_residual_t**)calloc(n_dae_blocks,
            sizeof(jmi_block_residual_t*));

    jmi_->dae_init_block_residuals = (jmi_block_residual_t**)calloc(n_dae_init_blocks,
            sizeof(jmi_block_residual_t*));

    jmi_->atEvent = JMI_FALSE;
    jmi_->atInitial = JMI_FALSE;
    jmi_->eventPhase = JMI_TIME_EXACT;
    jmi_->nextTimeEvent.defined = 0;
    jmi_->save_restore_solver_state_mode = 0;
    
    jmi_init_runtime_options(jmi_, &jmi_->options);

    jmi_->events_epsilon = jmi_->options.events_default_tol;
    jmi_->time_events_epsilon = jmi_->options.time_events_default_tol;
    jmi_->recomputeVariables = 1;
    jmi_init_eval_independent_set_dirty(jmi_);
    jmi_init_eval_dependent_set_dirty(jmi_);

    jmi_->log = jmi_log_init(jmi_callbacks);

    jmi_->model_terminate = 0;
    jmi_->user_terminate = 0;
    jmi_->reinit_triggered = 0;
    jmi_->resource_location_verified = 0;

    jmi_->is_initialized = 0;

    jmi_->nbr_event_iter = 0;
    jmi_->nbr_consec_time_events = 0;

    jmi_->dyn_fcn_mem = jmi_dynamic_function_pool_create(JMI_MEMORY_POOL_SIZE);
    jmi_->dyn_fcn_mem_globals = jmi_dynamic_function_pool_create(JMI_MEMORY_POOL_SIZE);

    return 0;
}

int jmi_delete(jmi_t* jmi){
    int i;

    jmi_me_delete_modules(jmi);
    jmi_z_delete(&jmi->z_t);
    jmi_model_delete(jmi);

    /* Deallocate init BLT blocks */
    for (i = 0; i < jmi->n_dae_init_blocks; i++) {
        jmi_delete_block_residual(jmi->dae_init_block_residuals[i]);
    }
    free(jmi->dae_init_block_residuals);
    
    /* Deallocate BLT blocks */
    for (i = 0; i < jmi->n_dae_blocks; i++) {
        jmi_delete_block_residual(jmi->dae_block_residuals[i]);
    }
    free(jmi->dae_block_residuals);
    
    for (i=0; i < jmi->n_dynamic_state_sets; i++) {
        jmi_dynamic_state_delete_set(jmi, i);
    }
    free(jmi->dynamic_state_sets);
    
    jmi_chattering_delete(jmi->chattering);

    free(*(jmi->z));
    free(jmi->z);
    free(*(jmi->z_last));
    free(jmi->z_last);
/*  free(jmi->pre_z);*/
    free(*(jmi->dz));
    free(jmi->dz);
    free(jmi->real_x_work);
    free(jmi->real_u_work);
    jmi_delete_real_work_array(jmi->real_work);
    jmi_delete_int_work_array(jmi->int_work);

    free(jmi->initial_relations);
    free(jmi->relations);
    free(jmi->nominals);
    for (i = 0; i < JMI_ACTIVE_VAR_BUFS_NUM; i++) {
        free(jmi->dz_active_variables_buf[i]);
    }
    free(jmi->variable_scaling_factors);
    jmi_destruct_external_objects(jmi);
    free(jmi->ext_objs);
    jmi_log_delete(jmi->log);

    jmi_destroy_delay_if(jmi);
    jmi_dynamic_function_pool_destroy(jmi->dyn_fcn_mem);
    jmi_dynamic_function_pool_destroy(jmi->dyn_fcn_mem_globals);

    free(jmi->globals);

    return 0;
}

int jmi_block_completed_integrator_step(jmi_t *jmi) {
    int i, flag;
    
    /* Loop over all the internal blocks */
    for (i = 0; i < jmi->n_dae_blocks; i++){
        jmi_block_residual_t* block_residual = jmi->dae_block_residuals[i]; 
        flag = jmi_block_residual_completed_integrator_step(block_residual);
        if (flag != 0) { 
            return flag; 
        }
    }
    return 0;
}


int jmi_init_delay_if(jmi_t* jmi, int n_delays, int n_spatialdists, jmi_generic_func_t init, jmi_generic_func_t sample, int n_delay_switches) {

    int i;
    jmi_real_t* switches;
    
    jmi->init_delay = init;
    jmi->sample_delay = sample;
    jmi->delay_event_mode = 0;

    jmi->n_delays = n_delays;
    jmi->delays = (jmi_delay_t *)calloc(n_delays, sizeof(jmi_delay_t));
    for (i=0; i < n_delays; i++) {
        jmi_delay_new(jmi, i);
    }

    jmi->n_spatialdists = n_spatialdists;
    jmi->spatialdists = (jmi_spatialdist_t *)calloc(n_spatialdists, sizeof(jmi_spatialdist_t));
    for (i=0; i < n_spatialdists; i++) {
        jmi_spatialdist_new(jmi, i);
    }

    switches = jmi_get_sw(jmi);
    for (i = jmi->n_state_sw - n_spatialdists - n_delay_switches; i < jmi->n_state_sw; i++) {
        switches[i] = JMI_DELAY_INITIAL_EVENT_SW;
    }

    return 0;
}

int jmi_destroy_delay_if(jmi_t* jmi) {
    int i;

    for (i=0; i < jmi->n_delays; i++) {
        jmi_delay_delete(jmi, i);
    }
    free(jmi->delays);

    for (i=0; i < jmi->n_spatialdists; i++) {
        jmi_spatialdist_delete(jmi, i);
    }
    free(jmi->spatialdists);

    return 0;
}

int jmi_generic_func(jmi_t *jmi, jmi_generic_func_t func) {
    int return_status;
    int depth = jmi_prepare_try(jmi);
    if (jmi_try(jmi, depth))
        return_status = -1;
    else
        return_status = func(jmi);
    jmi_finalize_try(jmi, depth);
    return return_status;
}

int jmi_ode_derivatives(jmi_t* jmi) {

    int return_status;
    jmi_real_t *t = jmi_get_t(jmi);
    jmi_log_node_t node={0};
    

    if ((jmi->jmi_callbacks.log_options.log_level >= 5)) {
        node = jmi_log_enter_fmt(jmi->log, logInfo, "EquationSolve", 
                                 "Model equations evaluation invoked at <t:%E>", t[0]);
        jmi_log_reals(jmi->log, node, logInfo, "States", jmi_get_real_x(jmi), jmi->n_real_x);
        jmi_log_reals(jmi->log, node, logInfo, "Inputs", jmi_get_real_u(jmi), jmi->n_real_u);
    }

    jmi->block_level = 0; /* to recover from errors */
    return_status = jmi_generic_func(jmi, jmi->model->ode_derivatives);

    if ((jmi->jmi_callbacks.log_options.log_level >= 5)) {
        jmi_log_reals(jmi->log, node, logInfo, "Derivatives", jmi_get_real_dx(jmi), jmi->n_real_x);
        jmi_log_fmt(jmi->log, node, logInfo, "Model equations evaluation finished");
        jmi_log_unwind(jmi->log, node);
    }

    return return_status;
}

int jmi_ode_derivatives_dir_der(jmi_t* jmi) {

    int return_status;
    jmi->block_level = 0; /* to recover from errors */
    
    return_status = jmi_generic_func(jmi, jmi->model->ode_derivatives_dir_der);

    return return_status;
}


int jmi_ode_initialize(jmi_t* jmi) {

    int return_status;
    jmi_real_t* t = jmi_get_t(jmi);
    jmi_log_node_t node={0};

    if ((jmi->jmi_callbacks.log_options.log_level >= 5)) {
        node = jmi_log_enter_fmt(jmi->log, logInfo, "EquationSolve", 
                                 "Model equations evaluation invoked at <t:%E>", t[0]);
    }

    return_status = jmi_generic_func(jmi, jmi->model->ode_initialize);

    if ((jmi->jmi_callbacks.log_options.log_level >= 5)) {
        jmi_log_fmt(jmi->log, node, logInfo, "Model equations evaluation finished");
        jmi_log_unwind(jmi->log, node);
    }
    return return_status;
}
int jmi_ode_next_time_event(jmi_t* jmi, jmi_time_event_t* event) {

    int return_status;
    int depth = jmi_prepare_try(jmi);

    if (jmi_try(jmi, depth)) {
        return_status = -1;
    } else {
        return_status = jmi->model->ode_next_time_event(jmi, event);
    }
    jmi_finalize_try(jmi, depth);
    return return_status;
}

int jmi_dae_R(jmi_t* jmi, jmi_real_t* res) {
    int return_status;
    int depth = jmi_prepare_try(jmi);

    if (jmi_try(jmi, depth)) {
        return_status = -1;
    }
    else {
        return_status = jmi->model->ode_event_indicators(jmi, &res);
    }

    jmi_finalize_try(jmi, depth);

    return return_status;
}

int jmi_dae_R_perturbed(jmi_t* jmi, jmi_real_t* res){
    int retval,i;
    jmi_real_t *switches;
    
    retval = jmi_dae_R(jmi,res);
    if (retval!=0){return -1;}
    
    switches = jmi_get_sw(jmi);
    
    for (i = 0; i < jmi->n_relations; i=i+1){
        if (switches[i] == 1.0){
            if (jmi->relations[i] == JMI_REL_GEQ){
                res[i] = res[i]+jmi->events_epsilon;
            }else if (jmi->relations[i] == JMI_REL_LEQ){
                res[i] = res[i]-jmi->events_epsilon;
            }else{
                res[i] = res[i];
            }
        }else{
            if (jmi->relations[i] == JMI_REL_GT){
                res[i] = res[i]-jmi->events_epsilon;
            }else if (jmi->relations[i] == JMI_REL_LT){
                res[i] = res[i]+jmi->events_epsilon;
            }else{
                res[i] = res[i];
            }
        }
    }
    return 0;
}

/* Local helper for reevaluating a jmi_generic_func_t if dirty flag is set */
int jmi_init_eval_generic(jmi_t* jmi,
        jmi_generic_func_t prerequisite, 
        int* dirty_flag, 
        jmi_generic_func_t eval_function, 
        const char* error_log_item, 
        const char* error_log_message) {

    int retval;
    if (prerequisite != NULL) {
        retval = prerequisite(jmi);
        if (retval != 0) {
            return retval;
        }
    }

    if (*dirty_flag == 1 && jmi->is_initialized == 0) {
        retval = jmi_generic_func(jmi, eval_function);
        if(retval != 0) {
            jmi_log_node(jmi->log, logError, error_log_item, error_log_message);
            return retval;
        }
        *dirty_flag = 0;
    }
    return 0;
}

void jmi_init_eval_independent_set_dirty(jmi_t* jmi) {
    jmi->recompute_init_independent = 1;
}

int jmi_init_eval_independent(jmi_t* jmi) {
    return jmi_init_eval_generic(jmi,
                            NULL,
                            &jmi->recompute_init_independent, 
                            jmi->model->init_eval_independent, 
                            "SetStartValuesFailed",
                            "Error evaluating independent parameters and start values");
}

void jmi_init_eval_dependent_set_dirty(jmi_t* jmi) {
    jmi->recompute_init_dependent = 1;
}

int jmi_init_eval_dependent(jmi_t* jmi) {
    return jmi_init_eval_generic(jmi,
                            jmi_init_eval_independent,
                            &jmi->recompute_init_dependent, 
                            jmi->model->init_eval_dependent, 
                            "DependentParametersEvaluationFailed",
                            "Error evaluating dependent parameters and start values");
}

int jmi_destruct_external_objects(jmi_t* jmi) {
    return jmi_generic_func(jmi, jmi_destruct_external_objs);
}

int jmi_init_delay_blocks(jmi_t* jmi) {
    return jmi_generic_func(jmi, jmi->init_delay);
}

int jmi_sample_delay_blocks(jmi_t* jmi) {
    return jmi_generic_func(jmi, jmi->sample_delay);
}
