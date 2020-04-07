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


/** \file jmi_block_log.h
 *  \brief Equiation block solver interface.
 */

#ifndef _JMI_BLOCK_LOG_H
#define _JMI_BLOCK_LOG_H

#include "jmi_block_solver.h"

/** \brief Check illegal inputs or outputs */
int jmi_check_illegal_values(int *error_indicator, jmi_real_t *nominal, jmi_real_t *inputs, int n, int* nans_present, int *infs_present, int *lim_vals_present);

/** \brief Log illegal input values detected by checl_illegal_values */
void jmi_log_illegal_input(jmi_log_t *log, int *error_indicator, int n, int nans_present, int infs_present, int lim_vals_present, jmi_real_t *inputs,
	jmi_string_t label, int is_iter_var_flag, int* value_references, int log_level, const char* label_type);

/** \brief Log illegal otput values detected by checl_illegal_values */
void jmi_log_illegal_output(jmi_log_t *log, int *error_indicator, int n_outputs, int n_inputs, jmi_real_t *inputs, jmi_real_t *outputs, int nans_present, int infs_present, int lim_vals_present, 
	jmi_string_t label, int is_iter_var_flag, int log_level, const char* label_type);

/** \brief Check and log illegal iv inputs */
int jmi_check_and_log_illegal_iv_input(jmi_block_solver_t* block, double* ivs, int N);

/** \brief Check and log illegal residual output(s) */
int jmi_check_and_log_illegal_residual_output(jmi_block_solver_t *block, double* f, double* ivs, double* heuristic_nominal,int N);

#endif /* _JMI_BLOCK_LOG_H */
