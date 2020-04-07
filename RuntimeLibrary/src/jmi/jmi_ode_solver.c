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

#include "jmi_ode_solver_impl.h"
#include "jmi_ode_problem.h"
#include "jmi_ode_euler.h"
#include "jmi_ode_cvode.h"
#include "jmi_math.h"

jmi_ode_solver_options_t jmi_ode_solver_default_options(void) {
    jmi_ode_solver_options_t options;
    
    options.experimental_mode = jmi_cs_experimental_none;
    options.method = JMI_ODE_CVODE;
    options.cvode_options.rel_tol = 1e-6;
    options.euler_options.step_size = 0.001;
    
    return options;
}

jmi_ode_solver_t* jmi_new_ode_solver(jmi_ode_problem_t* problem, jmi_ode_solver_options_t solver_options) {
    int flag = 0;
    jmi_ode_solver_t* solver;
    
    solver = (jmi_ode_solver_t*)calloc(1, sizeof(jmi_ode_solver_t));
    if(solver == NULL) return NULL;

    solver->states_derivative = calloc(problem->sizes.states, sizeof(jmi_real_t));
    solver->event_indicators_previous = calloc(problem->sizes.event_indicators, sizeof(jmi_real_t));
    solver->event_indicators = calloc(problem->sizes.event_indicators, sizeof(jmi_real_t));
    if (solver->states_derivative           == NULL ||
        solver->event_indicators            == NULL ||
        solver->event_indicators_previous   == NULL)
    {
        jmi_free_ode_solver(solver);
        return NULL;
    }

    solver->ode_problem = problem;
    solver->initialize_solver = TRUE;
    solver->need_event_update = FALSE;
    solver->experimental_mode = solver_options.experimental_mode;
    solver->step_size =solver_options.euler_options.step_size;
    solver->rel_tol = solver_options.cvode_options.rel_tol;
    
    switch(solver_options.method) {
    case JMI_ODE_CVODE: {
        jmi_ode_cvode_t* integrator;
        flag = jmi_ode_cvode_new(&integrator, solver);
        solver->integrator = integrator;
        solver->solve = jmi_ode_cvode_solve;
        solver->delete_solver = jmi_ode_cvode_delete;
    }
        break;
    case JMI_ODE_EULER: {
        jmi_ode_euler_t* integrator;    
        flag = jmi_ode_euler_new(&integrator, solver);
        solver->integrator = integrator;
        solver->solve = jmi_ode_euler_solve;
        solver->delete_solver = jmi_ode_euler_delete;
    }
        break;

    default:
        flag = -1;
    }

    if (flag == -1) {
        jmi_free_ode_solver(solver);
        return NULL;
    } else {
        return solver;
    }
}

void jmi_free_ode_solver(jmi_ode_solver_t* solver){
    if(solver){
        if (solver->states_derivative)          free(solver->states_derivative);
        if (solver->event_indicators_previous)  free(solver->event_indicators_previous);
        if (solver->event_indicators)           free(solver->event_indicators);
        if (solver->delete_solver)              solver->delete_solver(solver);
        free(solver);
    }
}

void jmi_ode_solver_external_event(jmi_ode_solver_t* solver) {
    solver->initialize_solver = TRUE;
    solver->need_event_update = TRUE;
}

void jmi_ode_solver_need_to_initialize(jmi_ode_solver_t* solver) {
    if (solver->experimental_mode != jmi_cs_experimental_no_reinit_for_input_change) {
        solver->initialize_solver = TRUE;
    }
}

static jmi_real_t jmi_ode_final_integration_time(jmi_ode_problem_t *p, jmi_real_t final_time) {
    if (p->event_info.exists_time_event &&
        p->event_info.next_time_event < final_time)
    {
        return p->event_info.next_time_event;
    }
    
    return final_time;
}

static int jmi_ode_not_finished(jmi_real_t time, jmi_real_t final_time) {
    return time + JMI_ALMOST_EPS*final_time < final_time;
}

/* At a time event if simulation ended successfully but integration stop time is not final time */
static int jmi_ode_at_time_event(jmi_ode_status_t s, jmi_real_t integrate_stop_time, jmi_real_t final_time) {
    return (s == JMI_ODE_OK && integrate_stop_time != final_time);
}

static int jmi_ode_check_event_indicators(jmi_real_t* event_indicators, jmi_real_t* event_indicators_previous, size_t dim) {
    size_t i;
    
    for (i = 0; i < dim; i++) {
        if ((event_indicators[i] >= 0.0 && event_indicators_previous[i] < 0.0) ||
            (event_indicators[i] < 0.0  && event_indicators_previous[i] >= 0.0)) {
            return 0;
        }
    }
    return 1;
}

jmi_ode_status_t jmi_ode_solver_solve(jmi_ode_solver_t* solver, jmi_real_t final_time) {
    jmi_ode_problem_t *p = solver->ode_problem;
    jmi_ode_status_t s = JMI_ODE_OK;
    jmi_real_t integrate_stop_time;
    
    if (solver->initialize_solver && !(solver->need_event_update)) {
        if (p->ode_callbacks.root_func(p->time, p->states, 
                                    solver->event_indicators, 
                                    p->sizes, p->problem_data) == -1) {
            jmi_log_node(p->log, logError, "StateEventEvaluationFailure", "Failed to compute the event indicators at the beginning of the solve function.");
            return JMI_ODE_ERROR;
        }
        
        if (jmi_ode_check_event_indicators(solver->event_indicators,
                                           solver->event_indicators_previous,
                                           p->sizes.event_indicators) == 0) {
            jmi_log_node(p->log, logInfo, "EventUpdate", "Detected changes in the event indicators between invocations of the solve method. Will perform an event update.");
            solver->need_event_update = TRUE;
        }
    }
    
    if (solver->need_event_update) {
        s = p->ode_callbacks.event_update_func(p);
        solver->need_event_update = FALSE;
        if (p->event_info.nominals_updated) {
            jmi_log_node(p->log, logError, "Error", "Changed nominals is currently unsupported.");
            return JMI_ODE_ERROR;
        }
    }

    /* while at event or ok but not finished */
    while (s == JMI_ODE_EVENT ||
        (s == JMI_ODE_OK && jmi_ode_not_finished(p->time, final_time)))
    {
        integrate_stop_time = jmi_ode_final_integration_time(p, final_time);
        s = solver->solve(solver, integrate_stop_time, solver->initialize_solver);
        solver->initialize_solver = FALSE;
        
        if (s == JMI_ODE_OK || s == JMI_ODE_EVENT) {
            /* Ensure that states and time is up to date in the model: */
            if (p->ode_callbacks.rhs_func(p->time, p->states,
                                          solver->states_derivative,
                                          p->sizes, p->problem_data) == -1) {
                return JMI_ODE_ERROR;
            }
        }
        
        if (s == JMI_ODE_EVENT || jmi_ode_at_time_event(s, integrate_stop_time, final_time)) {
            s = p->ode_callbacks.event_update_func(p);
            solver->initialize_solver = TRUE;
            if (p->event_info.nominals_updated) {
                jmi_log_node(p->log, logError, "Error", "Changed nominals is currently unsupported.");
                return JMI_ODE_ERROR;
            }
        }
    }
    
    if (p->event_info.exists_time_event && final_time == p->event_info.next_time_event) {
        solver->initialize_solver = TRUE;
        solver->need_event_update = TRUE;
        jmi_log_node(p->log, logInfo, "EventUpdate", "Detected time event at the final time. Will perform an event update in the beginning of the next invocation of the solve function.");
    }
    
    if (p->ode_callbacks.root_func(p->time, p->states, 
                                    solver->event_indicators_previous, 
                                    p->sizes, p->problem_data) == -1) {
        jmi_log_node(p->log, logError, "StateEventEvaluationFailure", "Failed to compute the event indicators at the end of the solve function.");
        return JMI_ODE_ERROR;
    }
    
    return s;
}
