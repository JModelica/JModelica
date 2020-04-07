 /*
    Copyright (C) 2013 Modelon AB

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



/** \file jmi_global.h
 *  \brief Thread-safe global data and exception handling.
 */

#ifndef _JMI_GLOBAL_H
#define _JMI_GLOBAL_H

#include <setjmp.h>

#include "jmi.h"


/**
 * \brief Set the current jmi struct.
 */
void jmi_set_current(jmi_t* jmi);

/**
 * \brief Get the current jmi struct.
 */
jmi_t* jmi_get_current();

/**
 * \brief Check if the current jmi struct is set.
 */
int jmi_current_is_set();

/**
 * \brief Prepare try buffer for calling jmi_try()
 * \returns Try depth to be submitted to jmi_try and jmi_finalize_try
 */
int jmi_prepare_try(jmi_t* jmi);

/**
*    \brief Cleans up try buffer after jmi_try returnes.
*/
void jmi_finalize_try(jmi_t* jmi, int depth);

/**
 * \brief Set up for exception handling.
 */
#define jmi_try(jmi,depth) setjmp((jmi)->try_location[(depth)])

/**
 * \brief Throw exception.
 */
void jmi_throw();


/**
 * \brief Print warning node with single attribute to logger, using saved jmi_t struct.
 */
void jmi_global_log(int warning, const char* name, const char* attr, const char* value);

/**
 * \brief Allocate memory with user-supplied function, if any. Otherwise use calloc().
 */
void* jmi_global_calloc(size_t n, size_t s);


/* For use as arguments to jmi_assert_failed(). */
#define JMI_ASSERT_ERROR   0
#define JMI_ASSERT_WARNING 1

/**
 * Signal a failed assertion.
 *
 * If warning is JMI_ASSERT_ERROR, then function will not return.
 */
void jmi_assert_failed(const char* msg, int warning);


#endif /* _JMI_GLOBAL_H */
