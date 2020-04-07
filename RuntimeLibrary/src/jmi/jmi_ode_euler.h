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


/** \file jmi_ode_cvode.h
 *  \brief Structures and functions for handling an explicit EULER ODE solver.
 */

#ifndef _JMI_ODE_EULER_H
#define _JMI_ODE_EULER_H

#include <string.h>
#include "jmi_ode_solver.h"

typedef struct jmi_ode_euler_t jmi_ode_euler_t;

int jmi_ode_euler_new(jmi_ode_euler_t** integrator_ptr, jmi_ode_solver_t* solver);

jmi_ode_status_t jmi_ode_euler_solve(jmi_ode_solver_t* solver, double time_final, int initialize);

void jmi_ode_euler_delete(jmi_ode_solver_t* solver);

struct jmi_ode_euler_t {
    jmi_real_t step_size;
};

#endif

