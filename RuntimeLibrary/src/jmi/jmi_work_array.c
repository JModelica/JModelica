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

#include "jmi_work_array.h"
#include <stdlib.h>

jmi_real_work_array_t* jmi_create_real_work_array(jmi_int_t n) {
	jmi_real_work_array_t* real_work_array;
	real_work_array = (jmi_real_work_array_t*)calloc(1, sizeof(jmi_real_work_array_t));
	real_work_array->n = n;
	real_work_array->rwork = (jmi_real_t*)calloc(n, sizeof(jmi_real_t));
	return real_work_array;
}

jmi_int_work_array_t* jmi_create_int_work_array(jmi_int_t n) {
	jmi_int_work_array_t* int_work_array;
	int_work_array = (jmi_int_work_array_t*)calloc(1, sizeof(jmi_int_work_array_t));
	int_work_array->n = n;
	int_work_array->iwork = (jmi_int_t*)calloc(n, sizeof(jmi_int_t));
	return int_work_array;
}

jmi_real_t* jmi_get_real_work_array(jmi_real_work_array_t* real_work_array, jmi_int_t n) {
	if (n > real_work_array->n) { /* Not enough memory allocated */
		free(real_work_array->rwork);
		real_work_array->rwork = (jmi_real_t*)calloc(n, sizeof(jmi_real_t));
		real_work_array->n=n;
	}
	return real_work_array->rwork;
}
jmi_int_t* jmi_get_int_work_array(jmi_int_work_array_t* int_work_array, jmi_int_t n) {
	if (n > int_work_array->n) { /* Not enough memory allocated */
		free(int_work_array->iwork);
		int_work_array->iwork = (jmi_int_t*)calloc(n, sizeof(jmi_int_t));
		int_work_array->n=n;
	}
	return int_work_array->iwork;
}


void jmi_delete_real_work_array(jmi_real_work_array_t* real_work_array) {
	if (real_work_array == NULL) {
		return;
	}
	
	free(real_work_array->rwork);
	free(real_work_array);
}
void jmi_delete_int_work_array(jmi_int_work_array_t* int_work_array) {
	if (int_work_array == NULL) {
		return;
	}
	
	free(int_work_array->iwork);
	free(int_work_array);
}