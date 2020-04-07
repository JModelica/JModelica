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

#ifndef _JMI_MINPACK_SOLVER_H
#define _JMI_MINPACK_SOLVER_H

#include "jmi_block_solver.h"

#include <cminpack.h>

#define real __cminpack_real__

typedef struct jmi_minpack_solver_t jmi_minpack_solver_t;

/**< \brief MINPACK solver constructor function */
int jmi_minpack_solver_new(jmi_minpack_solver_t** solver, jmi_block_solver_t* block_solver);

/**< \brief MINPACK solver main solve function */
int jmi_minpack_solver_solve(jmi_block_solver_t* block_solver);

/**< \brief MINPACK solver destructor */
void jmi_minpack_solver_delete(jmi_block_solver_t* block_solver);

struct jmi_minpack_solver_t {
    int lr;
    real ytol;
    real *yscale; 
    real *ytemp;
    
    real *qTf;
    real *qr;
    
    real *rwork1;
    real *rwork2;
    real *rwork3;
    real *rwork4;
    
    real *rworkj1;
    real *rworkj2;
};

#endif /* _JMI_MINPACK_SOLVER_H */
