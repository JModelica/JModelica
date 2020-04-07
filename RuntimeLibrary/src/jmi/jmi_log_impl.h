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

/** \file jmi_log_impl.h
    \brief Logging utilities for the JMI runtime private include file.
*/    

#ifndef _JMI_LOG_IMPL_H
#define _JMI_LOG_IMPL_H

#include "jmi_log.h"

typedef enum log_flag_t {
    logFlagIndex = 1,
    logFlagResidualIndex = 2
} log_flag_t;


/* convenience typedefs */
typedef jmi_log_node_t node_t;
typedef jmi_log_category_t category_t;
typedef jmi_log_t          log_t;

/** \brief Raw character buffer used by jmi_log_t. */
typedef struct {
    char *msg;
    int len, alloced;    
} buf_t;

/** \brief Log frame used by jmi_log_t. */
typedef struct {
    int id;
    jmi_log_category_t c;
    const char *type;

    jmi_log_category_t severest_category; /* among the node's contents */
} frame_t;

/** \brief Structured logger */ 
struct jmi_log_t {
    buf_t buf;

    BOOL filtering_enabled;
    FILE *log_file;  /**< \brief Destination for direct file logging, or NULL. */
    BOOL initialized;

    category_t c;  /** TODO: rename into category*/
    category_t severest_category;
    const char *next_name;
    int leafdim;   /**< \brief  -1 when top is not a leaf, otherwise dimension of the leaf. */

    frame_t *frames;
    int topindex;  /**< \brief  Index of the top frame in frames. */
    int alloced_frames;
    int id_counter;
    
    jmi_callbacks_t* jmi_callbacks;  /**< \brief  A pointer to a callbacks the logger needs. */
    jmi_log_options_t* options;          /**< \brief  A pointer to jmi options. */
    
    BOOL outstanding_comma;
};

/** \brief Return the one input that has the severest category. */
category_t severest(category_t c1, category_t c2);

/** \brief Check if specified category should be emitted */
static int emitted_category(log_t *log, category_t c);

/** \brief Logging the category and message. */
void file_logger(FILE *out, FILE *err, 
                        category_t category, category_t severest_category, 
                        const char *message);

#endif
