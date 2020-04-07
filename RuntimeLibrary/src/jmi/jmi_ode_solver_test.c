/*
    Copyright (C) 2017 Modelon AB

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

#include <stdlib.h>
#include <stdio.h>

#include "jmi_ode_problem.h"
#include "jmi_ode_solver.h"

#define ABS_MACRO(X) ((X) > 0 ? (X): -(X))

static void assert_true(int should_be_true, char* message) {
    if (!should_be_true) {
        fprintf(stderr, message);
        exit(EXIT_FAILURE);
    }
}


static void emit_log(jmi_callbacks_t* c, jmi_log_category_t category, jmi_log_category_t severest_category, char* message) {
    printf("[%s] %s", jmi_callback_log_category_to_string(category), message);
}

static int is_log_category_emitted (jmi_callbacks_t* c, jmi_log_category_t category) {
    return 1;
}

static void jmi_free_default_callbacks(jmi_callbacks_t* cb) {
    free(cb);
}

static jmi_callbacks_t* jmi_get_default_callbacks() {
    jmi_callbacks_t* cb = (jmi_callbacks_t*)calloc(1, sizeof(jmi_callbacks_t));
    
    cb->log_options.logging_on_flag = 1;
    cb->log_options.log_level = 5;
    cb->log_options.copy_log_to_file_flag = 1;
    cb->emit_log = emit_log;
    cb->is_log_category_emitted = is_log_category_emitted;

    cb->allocate_memory = calloc;
    cb->free_memory = free;
    cb->model_name = "test";
    cb->instance_name = "test_instance"; 
    return cb;
}

jmi_real_t k = -5.0;

int simple_rhs(jmi_real_t t, jmi_real_t* y, jmi_real_t* rhs, jmi_ode_sizes_t sizes, void* problme_data) {
    assert_true(sizes.states == 1, "assuming 1 state");
    
    rhs[0] = k * y[0];
    return 0;
}

static void test_ode_solver_basic() {
    jmi_ode_sizes_t sizes;
    jmi_ode_callbacks_t ode_callbacks = jmi_ode_problem_default_callbacks();
    jmi_ode_solver_options_t ode_options = jmi_ode_solver_default_options();
    jmi_ode_problem_t* ode_problem;
    jmi_ode_solver_t* ode_solver;
    jmi_log_t* log;
    jmi_callbacks_t* cb;
    jmi_ode_status_t ret;
    
    /* Setup callbacks and log */
    cb = jmi_get_default_callbacks();
    log = jmi_log_init(cb);
    
    /* Setup ode problem */
    ode_callbacks.rhs_func = simple_rhs;
    sizes.states = 1;
    sizes.event_indicators = 0;
    ode_problem = jmi_new_ode_problem(cb, NULL, ode_callbacks, sizes, log);
    /* Setup initial conditons and nominals */
    ode_problem->time = 0.0;         /* t_0 := 0.0 */
    ode_problem->states[0] = 1.0;    /* x_0 := 1.0 */
    ode_problem->nominals[0] = 1.0;
    
    /* Setup solver and solve ode */
    ode_solver = jmi_new_ode_solver(ode_problem, ode_options);
    ret = jmi_ode_solver_solve(ode_solver, 1.0);
    assert_true(ret == JMI_ODE_OK, "solver expected to return ok");
    /* Should be true: x = e^-5 */
    assert_true(ABS_MACRO(ode_problem->states[0] - 0.006737946999085) < 1e-4,
        "solver did not return correct value");
    
    /* Cleanup */
    jmi_free_ode_solver(ode_solver);
    jmi_free_ode_problem(ode_problem);
    jmi_log_delete(log);
    jmi_free_default_callbacks(cb);
}

main() {
    test_ode_solver_basic();

    return EXIT_SUCCESS;
}
