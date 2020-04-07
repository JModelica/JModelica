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
#include "jmi_util.h"
#include <stdarg.h>
#include "jmi.h"
#include "jmi_log.h"
#include "jmi_global.h"
#include <stdio.h>
#include <assert.h>
#include "jmi_math.h"
#include "jmi_block_log.h"
#include "jmi_work_array.h"

void jmi_min_time_event(jmi_time_event_t* event, int def, int phase, jmi_real_t time) {
    if (JMI_TRUE == LOG_EXP_OR(
                        LOG_EXP_OR(
                            LOG_EXP_NOT(((jmi_real_t)(event->defined))),
                            SURELY_GT_ZERO(event->time - time)), 
                        LOG_EXP_AND(
                            ALMOST_ZERO(event->time - time), 
                            SURELY_GT_ZERO(event->phase - phase)))) {
        event->defined = def;
        event->phase = phase;
        event->time = time;
    }
}

void jmi_internal_error(jmi_t *jmi, const char msg[]) {
    jmi_log_node(jmi->log, logError, "Error", "Internal error <msg:%s>", msg);
    jmi_throw();
    jmi_log_node(jmi->log, logError, "Error", "Could not throw an exception after internal error", msg);
}

void jmi_flag_termination(jmi_t *jmi, const char* msg) {
    jmi->model_terminate = 1;
    /* TODO: This is an informative message, not a warning, but is rather important. Change once log level is made separate from message category. */
    jmi_log_node(jmi->log, logWarning, "SimulationTerminated", "<msg:%s>", msg);
}

int jmi_copy_pre_values(jmi_t *jmi) {
    int i;
    jmi_real_t* z;
    jmi_string_t *z_str;
    size_t start;
    size_t pre_start;
    
    z = jmi_get_z(jmi);
    for (i=jmi->offs_real_dx;i<jmi->offs_t;i++) {
        z[i - jmi->offs_real_dx + jmi->offs_pre_real_dx] = z[i];
    }
    for (i=jmi->offs_real_d;i<jmi->offs_pre_real_dx;i++) {
        z[i - jmi->offs_real_d + jmi->offs_pre_real_d] = z[i];
    }
    
    z_str     = jmi->z_t.strings.values;
    start     = jmi->z_t.strings.offs.w;
    pre_start = jmi->z_t.strings.offs.wp;
    for (i = 0; i < pre_start - start; i++) {
        JMI_ASG_STR_Z(z_str[pre_start + i], z_str[start + i]);
    }
    
    return 0;
}

jmi_real_t* jmi_get_z(jmi_t* jmi) {
    return *(jmi->z);
}

int jmi_get_z_size(jmi_t* jmi) {
    return jmi->n_z;
}

jmi_string_t* jmi_get_string_z(jmi_t* jmi) {
    return jmi->z_t.strings.values;
}

jmi_real_t* jmi_get_z_last(jmi_t* jmi) {
    return *(jmi->z_last);
}

jmi_real_t* jmi_get_real_ci(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_real_ci;
}

jmi_real_t* jmi_get_real_cd(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_real_cd;
}

jmi_real_t* jmi_get_real_pi(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_real_pi;
}

jmi_real_t* jmi_get_real_pd(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_real_pd;
}

jmi_real_t* jmi_get_integer_ci(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_integer_ci;
}

jmi_real_t* jmi_get_integer_cd(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_integer_cd;
}

jmi_real_t* jmi_get_integer_pi(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_integer_pi;
}

jmi_real_t* jmi_get_integer_pd(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_integer_pd;
}

jmi_real_t* jmi_get_boolean_ci(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_boolean_ci;
}

jmi_real_t* jmi_get_boolean_cd(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_boolean_cd;
}

jmi_real_t* jmi_get_boolean_pi(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_boolean_pi;
}

jmi_real_t* jmi_get_boolean_pd(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_boolean_pd;
}

jmi_real_t* jmi_get_real_dx(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_real_dx;
}

jmi_real_t* jmi_get_real_x(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_real_x;
}

jmi_real_t* jmi_get_real_u(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_real_u;
}

jmi_real_t* jmi_get_real_w(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_real_w;
}

jmi_real_t* jmi_get_t(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_t;
}

jmi_real_t* jmi_get_real_d(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_real_d;
}

jmi_real_t* jmi_get_integer_d(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_integer_d;
}

jmi_real_t* jmi_get_integer_u(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_integer_u;
}

jmi_real_t* jmi_get_boolean_d(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_boolean_d;
}

jmi_real_t* jmi_get_boolean_u(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_boolean_u;
}

jmi_real_t* jmi_get_sw(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_sw;
}

jmi_real_t* jmi_get_state_sw(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_state_sw;
}

jmi_real_t* jmi_get_time_sw(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_time_sw;
}

jmi_real_t* jmi_get_sw_init(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_sw_init;
}

void jmi_init_runtime_options(jmi_t *jmi, jmi_options_t* op) {
    jmi_block_solver_init_default_options(&op->block_solver_options);

    op->nle_solver_default_tol = 1e-10;           /**< \brief Default tolerance for the equation block solver */
    op->nle_solver_tol_factor = 0.0001;           /**< \brief Tolerance safety factor for the non-linear equation block solver. */
    op->events_default_tol = 1e-10;               /**< \brief Default tolerance for the event iterations. */        
    op->time_events_default_tol = JMI_ALMOST_EPS; /** <\brief Default tolerance for the time event iterations. */
    op->events_tol_factor = 0.0001;               /**< \brief Tolerance safety factor for the event iterations. */
    op->cs_solver = JMI_ODE_CVODE;                /**< \brief Option for changing the internal CS solver. */
    op->cs_rel_tol = 1e-6;                        /**< \brief Default tolerance for the adaptive solvers in the CS case. */
    op->cs_step_size = 1e-3;                      /**< \brief Default step-size for the non-adaptive solvers in the CS case. */   
    op->cs_experimental_mode = 0;

    op->log_options = &jmi->jmi_callbacks.log_options;
}

jmi_value_reference jmi_get_index_from_value_ref(jmi_value_reference vref) {
    /* Translate a ValueReference into variable index in z-vector. */
    return vref & VREF_INDEX_MASK;
}

jmi_type_t jmi_get_type_from_value_ref(jmi_value_reference vref) {
    /* Translate a ValueReference into variable type in z-vector. */    
    switch (vref & VREF_TYPE_MASK) {
        case REAL_TYPE_MASK: return JMI_REAL;
        case INT_TYPE_MASK:  return JMI_INTEGER;
        case BOOL_TYPE_MASK: return JMI_BOOLEAN;
        case STR_TYPE_MASK:  return JMI_STRING;
        default:
            return -1;
    }
}

jmi_value_reference jmi_value_ref_is_negated(jmi_value_reference vref) {
    /* Checks for a valueReference if it is negated. */
    return vref & VREF_NEGATE_MASK;
}

jmi_value_reference jmi_get_value_ref_from_index(int index, jmi_type_t type) {
    /* Translates an index together with a type to a value reference */
    switch (type) {
        case JMI_REAL:    return index + REAL_TYPE_MASK;
        case JMI_INTEGER: return index + INT_TYPE_MASK;
        case JMI_BOOLEAN: return index + BOOL_TYPE_MASK;
        case JMI_STRING:  return index + STR_TYPE_MASK;
        default:
            return -1;
    }
}

int jmi_compare_switches(jmi_real_t* sw_pre, jmi_real_t* sw_post, jmi_int_t size) {
    int i, all_switches_equal = 1;
    
    for (i = 0; i < size; i++){
        if (sw_pre[i] != sw_post[i]){
            all_switches_equal = 0;
            break;
        }
    }
    return all_switches_equal;
}

int jmi_compare_strings(jmi_string_t* str_pre, jmi_string_t* str_post, jmi_int_t size) {
    int i, all_strings_equal = 1;
    
    for (i = 0; i < size; i++){
        if (strcmp(str_pre[i], str_post[i]) != 0) {
            all_strings_equal = 0;
            break;
        }
    }
    return all_strings_equal;
}

int jmi_compare_discrete_reals(jmi_real_t* dr_pre, jmi_real_t* dr_post, jmi_real_t* nominals, jmi_int_t size) {
    int i, all_discrete_reals_equal = 1;
    
    for (i = 0; i < size; i++){
        if (JMI_ABS(dr_pre[i] - dr_post[i])/nominals[i] > JMI_ALMOST_EPS ){
            all_discrete_reals_equal = 0;
            break;
        }
    }
    return all_discrete_reals_equal;
}

jmi_real_t jmi_turn_switch(jmi_t* jmi, jmi_real_t ev_ind, jmi_real_t sw, int rel) {
    /* x >= 0
     * x >  0
     * x <= 0
     * x <  0
     */
    jmi_real_t eps = jmi->events_epsilon;
    if (eps == 0.0) {
        if (sw == 1.0) {
            if ((ev_ind <  0.0 && rel == JMI_REL_GEQ)   ||
                (ev_ind <= 0.0 && rel == JMI_REL_GT)    ||
                (ev_ind >  0.0 && rel == JMI_REL_LEQ)   ||
                (ev_ind >= 0.0 && rel == JMI_REL_LT))
            {
                sw = 0.0;
            }
        } else {
            if ((ev_ind >= 0.0 && rel == JMI_REL_GEQ)   ||
                (ev_ind >  0.0 && rel == JMI_REL_GT)    ||
                (ev_ind <= 0.0 && rel == JMI_REL_LEQ)   ||
                (ev_ind <  0.0 && rel == JMI_REL_LT))
            {
                sw = 1.0;
            }
        }
    } else {
        if (sw == 1.0) {
            if ((ev_ind <= -eps && rel == JMI_REL_GEQ)  ||
                (ev_ind <= 0.0  && rel == JMI_REL_GT)   ||
                (ev_ind >= eps  && rel == JMI_REL_LEQ)  ||
                (ev_ind >= 0.0  && rel == JMI_REL_LT))
            {
                sw = 0.0;
            }
        } else {
            if ((ev_ind >= 0.0  && rel == JMI_REL_GEQ)   ||
                (ev_ind >= eps  && rel == JMI_REL_GT)    ||
                (ev_ind <= 0.0  && rel == JMI_REL_LEQ)   ||
                (ev_ind <= -eps && rel == JMI_REL_LT))
            {
                sw = 1.0;
            }
        }
    }
    return sw;
}

jmi_real_t jmi_turn_switch_time(jmi_t* jmi, jmi_real_t ev_ind, jmi_real_t sw, int rel) {
    /* x >= 0
     * x >  0
     * x <= 0
     * x <  0
     */
    jmi_real_t t = jmi_get_t(jmi)[0];
    jmi_real_t eps = jmi->time_events_epsilon;
    eps = eps*jmi_max(1.0, t);
    if (sw == 1.0) {
        if ((ev_ind <  -eps && rel == JMI_REL_GEQ)  ||
            (ev_ind <=  eps && rel == JMI_REL_GT)   ||
            (ev_ind >   eps && rel == JMI_REL_LEQ)  ||
            (ev_ind >= -eps && rel == JMI_REL_LT))
        {
            sw = 0.0;
        }
    } else {
        if ((ev_ind >= -eps && rel == JMI_REL_GEQ)  ||
            (ev_ind >   eps && rel == JMI_REL_GT)   ||
            (ev_ind <=  eps && rel == JMI_REL_LEQ)  ||
            (ev_ind <  -eps && rel == JMI_REL_LT))
        {
            sw = 1.0;
        }
    }
    return sw;
}

jmi_real_t jmi_in_stream_eps(jmi_t* jmi) {
    return 1e-8;
}

int jmi_file_exists(const char* file) {
    FILE *fp;
    if (file && (fp = fopen(file,"r")))
        fclose(fp);
    else
        return 0;
    return 1;
}

int jmi_dir_exists(const char* dir) {
#ifdef NO_FILE_SYSTEM
    return 0;
#else
        struct stat finfo;
    #ifdef _WIN32
        if(dir && stat(dir, &finfo) == 0 && finfo.st_mode & S_IFDIR)
    #else
        if(dir && stat(dir, &finfo) == 0 && S_ISDIR(finfo.st_mode))
    #endif
            return 1;
        else
            return 0;
#endif
}

void jmi_load_resource(jmi_t *jmi, jmi_string_t res, const jmi_string_t file) {
    size_t len;
    jmi_string_t loc = jmi->resource_location;

    if (!loc) {
        jmi_log_node(jmi->log, logError, "Error", "Resource location unavailable.");
        strcpy(res,file);
        return;
    }
    if (!(jmi->resource_location_verified) && !jmi_dir_exists(loc)) {
        jmi_log_node(jmi->log, logError, "Error", "Resource location does not exist <Path:%s>", loc);
        strcpy(res,file);
        return;
    }
    jmi->resource_location_verified = 1;
    
    len = strlen(loc) + strlen(file);
    if (len >= JMI_PATH_MAX) {
        jmi_log_node(jmi->log, logError, "Error", "File path too long: <Path:%s, File:%s>", loc, file);
        return;
    }
    strcpy(res, loc);
    strcat(res, file);
    if (!jmi_file_exists(res))
        jmi_log_node(jmi->log, logError, "Error", "Could not locate resource <File:%s>", res);
}

/* Local helpers for fmi1_me_instantiate_model */
int jmi_find_parent_dir(char* path, const char* dir) {
    int found = 0;
    int dir_level = 3;
    int c_i = strlen(path) - 1;
    
    while(dir_level > 0 && !found) {
        while(c_i > 0 && path[c_i] != '\\' && path[c_i] != '/')
            c_i--;
        if (c_i <= 0)
            break;
        if (strcmp(&path[c_i+1],dir) == 0)
            found = 1;
        path[c_i]= '\0';
        c_i--;
        dir_level--;
    }
    
    return found;
}

union jmi_func_cast {
    void* x;
    char* (*y)();
};

void* jmi_func_to_voidp(char* (*y)()) {
    union jmi_func_cast jfc;
    assert(sizeof(jfc.x)==sizeof(jfc.y));
    jfc.y = y;
    return jfc.x;
}
 
char* jmi_locate_resources(void* (*allocateMemory)(size_t nobj, size_t size)) {
#ifdef NO_FILE_SYSTEM
    return NULL;
#else
    int found;
    char *resource_dir = "/resources";
    char *binary_dir = "binaries";
    char *res;
    char path[JMI_PATH_MAX];
    char *resolved = path;
    
    #ifdef _WIN32
        EXTERN_C IMAGE_DOS_HEADER __ImageBase;
        GetModuleFileName((HINSTANCE)&__ImageBase, path, MAX_PATH);
    #else
        Dl_info info;
        dladdr(jmi_func_to_voidp(jmi_locate_resources), &info);
        resolved = realpath(info.dli_fname, path);
        if (!resolved)
            return NULL;
    #endif
    
    found = jmi_find_parent_dir(resolved, binary_dir);
    
    if (!found)
        return NULL;
    
    strcat(resolved, resource_dir);
    
    if (!jmi_dir_exists(resolved))
        return NULL;
    
    res = allocateMemory(strlen(resolved)+1,sizeof(char));
    strcpy(res, resolved);
    return res;
#endif
}

jmi_string_t* jmi_create_strings(size_t n) {
    jmi_string_t* res;
    int i;
    char *empty = "";
    size_t defaultLen = strlen(empty) + 1;
    res = calloc(n, sizeof(jmi_string_t));
    for (i = 0; i < n; i++) {
        res[i] = calloc(defaultLen, sizeof(char));
        strcpy(res[i], empty);
    }
    return res;
}

void jmi_free_strings(jmi_string_t* s, size_t n) {
    int i;
    for (i = 0; i < n; i++) {
        free(s[i]);
    }
    free(s);
}

jmi_directional_derivative_callbacks_t* jmi_create_directional_derivative_callbacks(size_t n_input, size_t n_output) {
	jmi_directional_derivative_callbacks_t* res =
			(jmi_directional_derivative_callbacks_t*)calloc(1, sizeof(jmi_directional_derivative_callbacks_t));
	res->n_input = n_input;
	res->n_output = n_output;
	res->input = (jmi_real_t*)calloc(n_input, sizeof(jmi_real_t));
	res->d_input = (jmi_real_t*)calloc(n_input, sizeof(jmi_real_t));
	res->output = (jmi_real_t*)calloc(n_output, sizeof(jmi_real_t));
	res->d_output = (jmi_real_t*)calloc(n_output, sizeof(jmi_real_t));
    return res;
}

void jmi_init_directional_derivative_callbacks(jmi_directional_derivative_callbacks_t* dd, jmi_directional_derivative_attributes_func_t F_max,
	jmi_directional_derivative_attributes_func_t F_min,
	jmi_directional_derivative_attributes_func_t F_input_nominal,
	jmi_directional_derivative_attributes_func_t F_output_nominal,
	jmi_directional_derivative_base_func_t F,	
	jmi_string_t label) {
    dd->F_max = F_max;
    dd->F_min = F_min;
    dd->F_input_nominal = F_input_nominal;
    dd->F_output_nominal = F_output_nominal;
    dd->F = F;
	dd->label = label;

}

void jmi_free_directional_derivative_callbacks(jmi_directional_derivative_callbacks_t* dd) {
	free(dd->input);
	free(dd->d_input);
	free(dd->output);
	free(dd->d_output);
    free(dd);
}

int jmi_evaluate_directional_derivative(jmi_t* jmi, jmi_directional_derivative_callbacks_t* dd_callback, void* args) {
    int i,j;
    int nans_present, infs_present, lim_vals_present;
    int ef = 0;
    int n_input = dd_callback->n_input;
    int n_output = dd_callback->n_output;
    jmi_real_t* input = dd_callback->input;
    jmi_real_t* d_input = dd_callback->d_input;
    jmi_real_t* output = dd_callback->output;
    jmi_real_t* d_output = dd_callback->d_output;
    jmi_real_t inc, delta, sign;
    jmi_real_t* work_array = jmi_get_real_work_array(jmi->real_work, n_input*3+2*n_output);
    jmi_real_t* input_max = work_array;
    jmi_real_t* input_min = work_array + n_input;
    jmi_real_t* input_nominal = work_array + 2*n_input;
    jmi_real_t* output_nominal = work_array + 3*n_input;
    jmi_real_t* output_temp = work_array + 3*n_input+n_output;
    jmi_int_t* error_indicator = jmi_get_int_work_array(jmi->int_work, JMI_MAX(n_output, n_input));
    jmi_log_node_t log_node={0};
    int log_level_limit = 5;

    /* Setup max/min/nominal values for the inputs */
    ef = dd_callback->F_max(args, input_max);
    if (ef !=0) {
        jmi_log_node(jmi->log, logError, "DirectionalDerivative", "Could not retrieve max values for inputs in <function_finite_dir_der: %s>.", dd_callback->label);
        return ef;
    } 
    ef = dd_callback->F_min(args, input_min);
    if (ef !=0) {
        jmi_log_node(jmi->log, logError, "DirectionalDerivative", "Could not retrieve min values for inputs in <function_finite_dir_der: %s>.", dd_callback->label);
        return ef;
    } 
    ef = dd_callback->F_input_nominal(args, input_nominal);
    if (ef !=0) {
        jmi_log_node(jmi->log, logError, "DirectionalDerivative", "Could not retrieve nominal values for inputs in <function_finite_dir_der: %s>.", dd_callback->label);
        return ef;
    } 

    /* Check if input values are ok */
    ef = jmi_check_illegal_values(error_indicator, input_nominal, input, n_input, &nans_present, &infs_present, &lim_vals_present);
    jmi_log_illegal_input(jmi->log, error_indicator, n_input, nans_present, infs_present, lim_vals_present, input, dd_callback->label, 
        FALSE, NULL, jmi->jmi_callbacks.log_options.log_level, "function_finite_dir_der");
    if (ef !=0) {
        jmi_log_node(jmi->log, logError, "DirectionalDerivative", "Cannot evaluate directional derivatives with illegal input in <function_finite_dir_der: %s>.", dd_callback->label);
        return ef;
    } 

    /* get current output values */
    ef = dd_callback->F(args, input, output);
    if (ef != 0 ) {
        jmi_log_node(jmi->log, logError, "DirectionalDerivative", "Could not evaluate callback function for inputs given in <function_finite_dir_der: %s>", dd_callback->label);
        return ef;
    }

	/* Setup nominal values for the outputs */
	ef = dd_callback->F_output_nominal(args, output_nominal);
    if (ef !=0) {
        jmi_log_node(jmi->log, logError, "DirectionalDerivative", "Could not retrieve nominal values for outputs in <function_finite_dir_der: %s>.", dd_callback->label);
        return ef;
    }

    if (jmi->jmi_callbacks.log_options.log_level >= log_level_limit){
        log_node = jmi_log_enter_fmt(jmi->log, logInfo, "FiniteDifferenceFunction", 
                                     "Finite difference invoked for <function_finite_dir_der: %s>", dd_callback->label);
        jmi_log_reals(jmi->log, log_node, logInfo, "d_input", d_input, n_input);
        jmi_log_reals(jmi->log, log_node, logInfo, "input", input, n_input);
        jmi_log_reals(jmi->log, log_node, logInfo, "output", output, n_output);
        jmi_log_reals(jmi->log, log_node, logInfo, "max", input_max, n_input);
        jmi_log_reals(jmi->log, log_node, logInfo, "min", input_min, n_input);
        jmi_log_reals(jmi->log, log_node, logInfo, "nominal", input_nominal, n_input);
    }

    /* Make d_output be filled with zeroes from start */
    for (i = 0; i < n_output; i++) {
        d_output[i]    = 0.0;
        output_temp[i] = 0.0;
    }

    delta = sqrt(JMI_EPS);
    for (j = 0; j < n_input; j++) {
        jmi_real_t input_orig = input[j];
        /* No need to evaluate derivative in this direction since it will be multiplied by 0 anyway */
        if (d_input[j] == 0) {
            continue;
        }
        sign = (input_orig >= 0) ? 1 : -1;
        inc = JMI_MAX(JMI_ABS(input_orig), input_nominal[j])*sign*delta;
        input[j] += inc;

        /* Make sure we're inside the bounds */
        if (input[j] > input_max[j]) {
            inc = -inc;
            input[j] = input_orig + inc;
            if (input[j] < input_min[j]) {
                jmi_log_node(jmi->log, logError, "DirectionalDerivative", "Could not find a perturbation for <input: %I> that is within its bounds, <value: %d>, <max: %d>, <min: %d> in <function_finite_dir_der: %s>."
                    , j, input_orig, input_max[j], input_min[j], dd_callback->label);
                if (jmi->jmi_callbacks.log_options.log_level >= log_level_limit) jmi_log_leave(jmi->log, log_node);
                return -1;
            }
        }
        ef = dd_callback->F(args, input, output_temp);
        /* If failure, try other direction */
        if ( ef > 0 ) {
            jmi_log_node(jmi->log, logWarning, "DirectionalDerivative", "Could not evaluate callback function in <function_finite_dir_der: %s>. Trying other direction. ", dd_callback->label);
            input[j] = input_orig - inc;
            ef = dd_callback->F(args, input, output_temp);
        }

        if (ef !=0) {
            jmi_log_node(jmi->log, logError, "DirectionalDerivative", "Could not evaluate callback in <function_finite_dir_der: %s>.", dd_callback->label);
            if (jmi->jmi_callbacks.log_options.log_level >= log_level_limit) jmi_log_leave(jmi->log, log_node);
            return ef;
        }

        /* Check if output values are ok */
        ef = jmi_check_illegal_values(error_indicator, output_nominal, output_temp, n_output, &nans_present, &infs_present, &lim_vals_present);
        jmi_log_illegal_output(jmi->log, error_indicator, n_output, n_input, input, output, nans_present, infs_present, lim_vals_present, dd_callback->label, 
            FALSE, jmi->jmi_callbacks.log_options.log_level, "function_finite_dir_der");
        if (ef !=0) {
            jmi_log_node(jmi->log, logError, "DirectionalDerivative", "Illegal output from <function_finite_dir_der: %s>.", dd_callback->label);
            if (jmi->jmi_callbacks.log_options.log_level >= log_level_limit) jmi_log_leave(jmi->log, log_node);
            return ef;
        }

        /* Reset input vector */
        input[j] = input_orig;

        for (i = 0; i < n_output; i++) {
            d_output[i] += (output_temp[i]-output[i])/inc*d_input[j]; 
        }
    }

    if (jmi->jmi_callbacks.log_options.log_level >= log_level_limit) {
        jmi_log_reals(jmi->log, log_node, logInfo, "d_output", d_output, n_output);
        jmi_log_leave(jmi->log, log_node);
    }

    /* reevaluate so that we now that the original values are correct */
    ef = dd_callback->F(args, input, output);
    return ef;
}
