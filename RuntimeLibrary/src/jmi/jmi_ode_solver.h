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


/** \file jmi_ode_solver.h
 *  \brief Structures and functions for handling an ODE solver.
 */

#ifndef _JMI_ODE_SOLVER_H
#define _JMI_ODE_SOLVER_H

#include "jmi_types.h"
#include "jmi_log.h"

typedef enum {
    JMI_ODE_ERROR = -1,
    JMI_ODE_OK = 0,
    JMI_ODE_EVENT = 1,
    JMI_ODE_TERMINATE = 2
} jmi_ode_status_t;

/** \brief Integrator methods the solver can use */
typedef enum {
    JMI_ODE_CVODE,
    JMI_ODE_EULER
} jmi_ode_method_t;

/** \brief Solver options specific for the cvode integrator */
typedef struct {
    jmi_real_t rel_tol;
} jmi_ode_cvode_options_t;

/** \brief Solver options specific for the euler integrator */
typedef struct {
    jmi_real_t step_size;
} jmi_ode_euler_options_t;

/** \brief Experimental features in the solver */
typedef enum {
    jmi_cs_experimental_none = 0,
    jmi_cs_experimental_no_reinit_for_input_change = 1
} jmi_cs_experimental_mode_t;

/** \brief All solver options */
typedef struct {
    jmi_ode_method_t method;
    jmi_ode_cvode_options_t cvode_options;
    jmi_ode_euler_options_t euler_options;
    
    jmi_cs_experimental_mode_t experimental_mode;
} jmi_ode_solver_options_t;

/**
 * \brief Creates a new jmi_ode_solver_t instance.
 *
 * @param ode_problem A jmi_ode_problem_t struct.
 * @param method A jmi_ode_solver_options_t struct.
 * @return A jmi_ode_solver_t struct, NULL on failure.
  */
jmi_ode_solver_t* jmi_new_ode_solver(jmi_ode_problem_t* problem, jmi_ode_solver_options_t solver_options);

/**
 * \brief Deletes the jmi_ode_solver_t instance.
 *
 * @param solver A jmi_ode_solver_t struct.
  */
void jmi_free_ode_solver(jmi_ode_solver_t* solver);

/**
 * \brief Indicate that the ode solver need to event update the ode problem.
 *
 * @param solver A jmi_ode_solver_t struct.
  */
void jmi_ode_solver_external_event(jmi_ode_solver_t* solver);

/**
 * \brief Indicate that the ode solver need to (re)initialize.
 *
 * @param solver A jmi_ode_solver_t struct.
  */
void jmi_ode_solver_need_to_initialize(jmi_ode_solver_t* solver);

/**
 * \brief Solves the ODE problem given when creating the solver instance.
 *
 * @param solver A jmi_ode_solver_t struct.
 * @param final_time The final time the integrator will integrate to.
 * @return Error code, will not be JMI_ODE_EVENT.
  */
jmi_ode_status_t jmi_ode_solver_solve(jmi_ode_solver_t* solver, jmi_real_t final_time);

/**
 * \brief Returns a jmi_ode_solver_options_t struct with default values.
 *
 * @return A jmi_ode_solver_options_t struct with default values.
  */
jmi_ode_solver_options_t jmi_ode_solver_default_options(void);

#endif
