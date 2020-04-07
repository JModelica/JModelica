/*
    Copyright (C) 2018 Modelon AB

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

/** \file jmi_work_array.h
 *  \brief Structures and functions for jmi work arrays.
 */
#ifndef _JMI_WORK_ARRAY_H
#define _JMI_WORK_ARRAY_H

#include "jmi_types.h"

/**
* \brief Work vector for reals in the jmi_struct
*/
typedef struct jmi_real_work_array_t {
	jmi_real_t* rwork;
	size_t n;
} jmi_real_work_array_t;


/**
* \brief Work vector for ints in the jmi_struct
*/
typedef struct jmi_int_work_array_t {
	jmi_int_t* iwork;
	size_t n;
} jmi_int_work_array_t;

jmi_real_work_array_t* jmi_create_real_work_array(jmi_int_t n);
jmi_int_work_array_t* jmi_create_int_work_array(jmi_int_t n);

void jmi_delete_real_work_array(jmi_real_work_array_t* real_work_array);
void jmi_delete_int_work_array(jmi_int_work_array_t* int_work_array);

jmi_real_t* jmi_get_real_work_array(jmi_real_work_array_t* real_work_array, jmi_int_t n);
jmi_int_t* jmi_get_int_work_array(jmi_int_work_array_t* int_work_array, jmi_int_t n);

#endif /* _JMI_WORK_ARRAY_H */