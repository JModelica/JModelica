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
 * jmi_block_solver_test.c a simple test of the block solver.
 */

#include <assert.h>
#include <stdlib.h>
#include <stdio.h>

#include "jmi_log.h"
#include "jmi_block_solver.h"

void emit_log(jmi_callbacks_t* c, jmi_log_category_t category, jmi_log_category_t severest_category, char* message) {
    printf("[%s] %s", jmi_callback_log_category_to_string(category), message);
}

int is_log_category_emitted (jmi_callbacks_t* c, jmi_log_category_t category) {
    return 1;
}

/*
Solving:
FX = if(x < -1) 
        x + (x+1)*COEFF;
    else
        if(x > 1)
            x + (x - 1)*COEFF;
        else
            x;
    FX, COEFF defined below, INITX - initial X
*/
#define FX 2
#define COEFF 2
#define INITX -2

typedef struct switch_state_t {
    jmi_callbacks_t* cb;
    jmi_log_t* log;
    int iter;
    double sw[2];
    double x;
    double b;
} switch_state_t;

int f(switch_state_t *sw, double* x, double* res, int evaluation_mode) {
   if (evaluation_mode == JMI_BLOCK_NOMINAL) {
       x[0] = 10;
    } else if (evaluation_mode == JMI_BLOCK_MIN) {
        x[0] = -100;
    } else if (evaluation_mode == JMI_BLOCK_MAX) {
        x[0] = 100;
    } else if (evaluation_mode == JMI_BLOCK_VALUE_REFERENCE) {
        x[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_EQUATION_NOMINAL) {
        (res)[0] = 1;
    } else if (evaluation_mode == JMI_BLOCK_INITIALIZE) {
        x[0] = sw->x;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE) {
        double xx = *x;
        double v;
        if(sw->sw[0] != 0)
            v = xx + (xx + 1)*COEFF;
        else if(sw->sw[1] != 0)
            v = xx + (xx - 1)*COEFF;
        else
            v = xx;
       
        (res)[0] = sw->b - v;
    } else if (evaluation_mode == JMI_BLOCK_EVALUATE_NON_REALS) {
    } else if (evaluation_mode == JMI_BLOCK_WRITE_BACK) {
        sw->x = x[0];
    }
    return 0;
}

jmi_block_solver_status_t update_discrete_variables(switch_state_t *sw, int* non_reals_changed_flag) {
    switch_state_t sw_old;
    sw_old = *sw;
    sw->sw[0] = (sw->x < -1);
    sw->sw[1] = (sw->x >  1);
    jmi_log_reals(sw->log, jmi_log_get_current_node(sw->log), logInfo, "switches", sw->sw, 2);
    *non_reals_changed_flag = (sw->sw[0] != sw_old.sw[0]) || (sw->sw[1] != sw_old.sw[1]);
    sw->iter++;
    return jmi_block_solver_status_success;
}

int main() {
    jmi_block_solver_t* block_solver;
    jmi_block_solver_options_t options;
    jmi_block_solver_callbacks_t solver_callbacks;
    switch_state_t sw;
    jmi_callbacks_t cb;
    jmi_log_t* log;
    int flag;

    sw.b = FX;
    sw.x = INITX;

    cb.log_options.logging_on_flag = 1;
    cb.log_options.log_level = 5;
    cb.log_options.copy_log_to_file_flag = 1;
    cb.emit_log = emit_log;
    cb.is_log_category_emitted = is_log_category_emitted;

    cb.allocate_memory = calloc;
    cb.free_memory = free;
    cb.model_name = "test";
    cb.instance_name = "test_instance";  
    cb.model_data = &sw;      

    log = jmi_log_init(&cb);
    sw.log = log;
    sw.cb = &cb;
    jmi_block_solver_init_default_options(&options);
    update_discrete_variables(&sw, &flag);

    solver_callbacks = jmi_block_solver_default_callbacks();
    solver_callbacks.F = f;
    solver_callbacks.update_discrete_variables = update_discrete_variables;
    jmi_new_block_solver(&block_solver, 
                         &cb,
                         log,
                         solver_callbacks,
                         1,
                         &options,
                         &sw);
    jmi_block_solver_solve(block_solver, 0, 1, 0);
    jmi_delete_block_solver(&block_solver);
	if (JMI_ABS(sw.x - 1.3333333333) > 1e-4) {
        return -1; /* Something went wrong */
    }
    return 0;
}
