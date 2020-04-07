 /*
    Copyright (C) 2015 Modelon AB

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


/** \file jmi_chattering.h
 *  \brief Structures and functions for logging event chattering.
 */

#ifndef _JMI_CHATTERING_H
#define _JMI_CHATTERING_H

#include "jmi_types.h"

struct jmi_chattering_t {
    jmi_int_t chattering_detection_mode;
    jmi_int_t clear_counter;
    jmi_int_t logging_counter;
    jmi_real_t *pre_switches;
    jmi_int_t *chattering;
    jmi_int_t max_chattering;
};

void jmi_chattering_completed_integrator_step(jmi_t* jmi);
void jmi_chattering_check(jmi_t* jmi);
void jmi_chattering_delete(jmi_chattering_t* chattering);
jmi_chattering_t* jmi_chattering_create(jmi_int_t n_sw);
void jmi_chattering_init(jmi_t* jmi);

#endif /* _JMI_CHATTERING_H */
