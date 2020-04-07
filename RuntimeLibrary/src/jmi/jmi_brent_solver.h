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



/** \file jmi_kinsol_solver.h
 *  \brief Interface to the KINSOL solver.
 */

#ifndef _JMI_BRENT_SOLVER_H
#define _JMI_BRENT_SOLVER_H

#include "jmi_types.h"
#include "jmi_block_solver.h"

typedef struct jmi_brent_solver_t jmi_brent_solver_t;

/**< \brief Brent solver constructor function */
int jmi_brent_solver_new(jmi_brent_solver_t** solver, jmi_block_solver_t* block_solver);

/**< \brief Brent solver main solve function */
int jmi_brent_solver_solve(jmi_block_solver_t* block_solver);

/**< \brief Brent solver destructor */
void jmi_brent_solver_delete(jmi_block_solver_t* block_solver);

/**< \brief Newton before Brent */
int jmi_brent_newton(jmi_block_solver_t *block, jmi_real_t *x0, jmi_real_t *f0, jmi_real_t *d);

/**< \brief Notifies Brent that an integrator step has been accepted */
int jmi_brent_completed_integrator_step(jmi_block_solver_t* block_solver);

/**< \brief Test if the best guess is good enough */
int jmi_brent_test_best_guess(jmi_block_solver_t *block, jmi_real_t xBest, jmi_real_t fBest);

/**< \brief Data structure used by the Brent algorithm */
struct jmi_brent_solver_t {
    jmi_real_t y;              /**< \brief current/last iterate */
    jmi_real_t f;              /**< \brief Residual at "y" */

    jmi_real_t originalStart; /**< \brief The start value used during the first call */
    
    jmi_real_t y_pos_min;      /**< \brief Iteration variable value for minimal known positive f */
    jmi_real_t f_pos_min;       /**< \brief Residual at y_pos_min */
    jmi_real_t y_neg_max;       /**< \brief Iteration variable value for maximum known negativ f*/
    jmi_real_t f_neg_max;       /**< \brief Residual at y_neg_max */
};


#endif /* _JMI_BRENT_SOLVER_H */
