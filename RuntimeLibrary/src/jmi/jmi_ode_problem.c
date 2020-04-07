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


#include <string.h>
#include "jmi_ode_solver.h"
#include "jmi_ode_problem.h"
#include "jmi_math.h"

static int default_rhs_fcn(jmi_real_t t, jmi_real_t *y, jmi_real_t *rhs, jmi_ode_sizes_t sizes, void* problem_data) {
    /* Default implementation, assumes there are no states */
    if (sizes.states == 0) {
        return 0;
    } else {
        return -1;
    }
}

static int default_root_fcn(jmi_real_t t, jmi_real_t *y, jmi_real_t *root, jmi_ode_sizes_t sizes, void* problem_data) {
    /* Default implementation, assumes there are no root function */
    if (sizes.event_indicators == 0) {
        return 0;
    } else {
        return -1;
    }
}

static int default_completed_integrator_step(char* step_event, char* terminate, void* problem_data) {
    /* Default implementation, assumes noting is done at completed step */
    *step_event = 0;
    *terminate = 0;
    return 0;
}

static jmi_ode_status_t default_event_update(jmi_ode_problem_t* problem) {
    /* Default implementation does nothing */
    return JMI_ODE_OK;
}

jmi_ode_callbacks_t jmi_ode_problem_default_callbacks() {
    jmi_ode_callbacks_t cb;
    
    cb.rhs_func = default_rhs_fcn;
    cb.root_func = default_root_fcn;
    cb.complete_step_func = default_completed_integrator_step;
    cb.event_update_func = default_event_update;
    return cb;
}

jmi_ode_problem_t* jmi_new_ode_problem(jmi_callbacks_t*     cb,
                                       void*                problem_data,
                                       jmi_ode_callbacks_t  ode_callbacks,
                                       jmi_ode_sizes_t      sizes,
                                       jmi_log_t*           log) {
    jmi_ode_problem_t* problem;
    
    problem = (jmi_ode_problem_t*)calloc(1,sizeof(jmi_ode_problem_t));
    if (problem == NULL) return NULL;
    
    problem->jmi_callbacks  = cb;
    problem->event_info.nominals_updated = FALSE;
    problem->event_info.exists_time_event = FALSE;
    problem->event_info.next_time_event = JMI_INF;
    problem->problem_data   = problem_data;
    problem->ode_callbacks  = ode_callbacks;
    problem->sizes          = sizes;
    problem->states         = (jmi_real_t*)calloc(sizes.states, sizeof(jmi_real_t));
    problem->nominals       = (jmi_real_t*)calloc(sizes.states, sizeof(jmi_real_t));
    problem->log = log;
    if (problem->states == NULL || problem->nominals == NULL) {
        jmi_free_ode_problem(problem);
        return NULL;
    }
    
    return problem;
}

void jmi_free_ode_problem(jmi_ode_problem_t* problem) {
    if (problem) {
        if (problem->states)    free(problem->states);
        if (problem->nominals)  free(problem->nominals);
        free(problem);
    }
}

void jmi_reset_ode_problem(jmi_ode_problem_t* problem) {
    problem->event_info.exists_time_event = FALSE;
    problem->event_info.next_time_event = JMI_INF;
    memset(problem->states, 0, problem->sizes.states * sizeof(jmi_real_t));
    memset(problem->nominals, 0, problem->sizes.states * sizeof(jmi_real_t));
}

