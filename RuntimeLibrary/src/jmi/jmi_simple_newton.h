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



/** \file jmi_simple_newton.h
 *  \brief Basic Newton solver
 **/

#ifndef _JMI_SIMPLE_NEWTON_H
#define _JMI_SIMPLE_NEWTON_H

#include "jmi_block_solver.h"

int jmi_simple_newton_solve(jmi_block_solver_t *block);

void jmi_simple_newton_delete(jmi_block_solver_t *block);

int jmi_simple_newton_jac(jmi_block_solver_t *block);

#endif
