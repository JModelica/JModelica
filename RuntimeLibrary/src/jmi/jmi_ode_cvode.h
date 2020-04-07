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
 *  \brief Structures and functions for handling an CVODE ODE solver.
 */

#ifndef _JMI_ODE_CVODE_H
#define _JMI_ODE_CVODE_H

#include "jmi_ode_solver.h"
#include "jmi_ode_problem.h"
#include <nvector/nvector_serial.h>

typedef struct jmi_ode_cvode_t jmi_ode_cvode_t;

int jmi_ode_cvode_new(jmi_ode_cvode_t** integrator_ptr, jmi_ode_solver_t* solver);

jmi_ode_status_t jmi_ode_cvode_solve(jmi_ode_solver_t* solver,realtype time_final, int initialize);

void jmi_ode_cvode_delete(jmi_ode_solver_t* solver);

struct jmi_ode_cvode_t {

    void *cvode_mem;
    int lmm;      /* Specifies the LMM (CV_ADAMS or CV_BDF) */
    int iter;     /* Specifies the nonlinear solver iterations (CV_NEWTON or CV_FUNCTIONAL) */
    realtype rtol; /* Specifies the relative tolerance */
    N_Vector atol; /* Specifies the absolute tolerance */
    N_Vector y_work;
};

#endif
