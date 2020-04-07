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

/** \file jmi_callbacks.h
 *  \brief jmi_callbacks struct is utilized to propagate base line callbacks and info in different modules.
 */

#ifndef _JMI_CALLBACKS_H
#define _JMI_CALLBACKS_H

#include <stdlib.h>

typedef struct jmi_callbacks_t jmi_callbacks_t;           /**< \brief Forward declaration of struct. */

/**
 * \brief Types of log messages.
 * Higher value = less severe
 */
typedef enum jmi_log_category_t {
    logError,
    logWarning,
    logInfo
/* NB: Enum values should currently be <= 3 due to log level handling as category */
} jmi_log_category_t;

const char* jmi_callback_log_category_to_string(jmi_log_category_t c);

typedef void (*jmi_callback_emit_log_ft) (jmi_callbacks_t* c, jmi_log_category_t category, jmi_log_category_t severest_category, char* message);

typedef int (*jmi_callback_is_log_category_emitted_ft) (jmi_callbacks_t* c, jmi_log_category_t category);
                                          
typedef void* (*jmi_callback_allocate_memory_ft) (size_t nobj, size_t size);

typedef void (*jmi_callback_free_memory_ft) (void* nobj);

/**
* \brief Options controlling logging from run-time.
*/
typedef struct jmi_log_options_t {
    char                         logging_on_flag;       /** < \brief The logging on / off attribute. */
    int                          log_level ;            /** < \brief Log level for jmi_log 0 - none, 1 - fatal error, 2 - error, 3 - warning, 4 - info, 5 -verbose, 6 - debug */
    int copy_log_to_file_flag; /**< \brief Copy log messages to a separate output file */
} jmi_log_options_t;

/**
 * \brief Data structure for representing the callback functions and other
 * pointers the jmi interface may need.
 */
struct jmi_callbacks_t {
    jmi_log_options_t log_options;               /** < \brief Options controlling logging */

    jmi_callback_emit_log_ft        emit_log;                        /** < \brief Logger function */
    jmi_callback_is_log_category_emitted_ft is_log_category_emitted; /** < \brief Check if specified category is logged */

    jmi_callback_allocate_memory_ft allocate_memory;  /** < \brief Allocate memory function. */
    jmi_callback_free_memory_ft     free_memory;      /** < \brief Free allocated memory function. */

    const char*                  model_name;       /**< \brief Name of the model (corresponds to a fixed compiled unit name) */
    const char*                  instance_name;    /** < \brief Name of this model instance. */
    void*                        model_data;       /**< \brief Opaque application model pointer for propagating additional information */
};

#endif
