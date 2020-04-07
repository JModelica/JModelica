 /*
    Copyright (C) 2016 Modelon AB

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

#ifndef _JMI_GET_SET_H_
#define _JMI_GET_SET_H_

#include "jmi.h"
#include "jmi_me.h"

int jmi_get_set_module_init(jmi_t *jmi);

void jmi_get_set_module_destroy(jmi_t *jmi);

int jmi_set_real_impl(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr,
                 const jmi_real_t value[]);

int jmi_set_integer_impl(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr,
                    const jmi_int_t value[]);

int jmi_set_boolean_impl(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr,
                    const jmi_boolean value[]);

int jmi_set_string_impl(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr,
                   const jmi_string value[]);

int jmi_get_real_impl(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr,
                 jmi_real_t value[]);

int jmi_get_integer_impl(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr,
                    jmi_int_t value[]);

int jmi_get_boolean_impl(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr,
                    jmi_boolean value[]);

int jmi_get_string_impl(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr,
                   jmi_string  value[]);

int jmi_set_time_impl(jmi_t* jmi, jmi_real_t time);

int jmi_set_continuous_states_impl(jmi_t* jmi, const jmi_real_t x[], size_t nx);

int jmi_get_event_indicators_impl(jmi_t* jmi, jmi_real_t eventIndicators[], size_t ni);

int jmi_get_derivatives_impl(jmi_t* jmi, jmi_real_t derivatives[] , size_t nx);

int jmi_save_last_successful_values(jmi_t *jmi);

int jmi_reset_last_successful_values(jmi_t *jmi);

int jmi_reset_last_internal_successful_values(jmi_t *jmi);

int jmi_reset_internal_variables(jmi_t* jmi);

#endif /* _JMI_GET_SET_H_ */
