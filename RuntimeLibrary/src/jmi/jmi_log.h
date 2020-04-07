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

/** \file jmi_log.h
    \brief Logging utilities for the JMI runtime.

    Logs are composed of nested log nodes.
    Depending on their type, nodes can contain either
     * a single scalar value, (type: `value`)
     * a vector of scalar values, (type: `vector`)
     * a matrix of scalar values, (type: `matrix`) or
     * other nodes. (all other types, preferably with initial capital letter)

    Every log entry has an associated log category, described by the jmi_log_category_t type.
    Log calls either take a category (`logError`, `logWarning`, or `logInfo`), 
    or use the category of the current node.

    Nodes are entered with one of the functions `jmi_log_enter`, `jmi_log_enter_fmt`, and `jmi_log_enter_`,
    and must be left in reverse order (innermost first) with `jmi_log_leave` or `jmi_log_leave_`,
    supplying the `jmi_log_node_t` that was returned when the node was entered.
    This is to keep track of that log nodes don't become unbalanced. If an unbalance is detected,
    `jmi_log_leave` will emit a warning comment to the log, and attempt leave the specified node.
    
    Apart from its type, a node may have a name, which is expected to be unique among its siblings.
    To help ensure that named nodes are not created by code that does not know if siblings with the
    same name already exist, the parent node is required as an argument to all calls that create named nodes.
    Named nodes may not have a more severe log category than their parents.
    
    Logging functions come in two flavors; row primitives and subrow primitives.
    The former will cause a new log message line to be sent to the log;
    the latter allow to build a line incrementally before emitting it. It can
    then be emitted to the log by a call to `jmi_log_emit` or a row primitive.
    Row primitives should be used when possible. A common use for subrow
    primitives is to log a vector that does not exist in memory, by
    incrementally feeding the elements.
*/    

#ifndef _JMI_LOG_H
#define _JMI_LOG_H

#include "jmi_callbacks.h"
#include "jmi_types.h"

typedef struct jmi_log_node_t jmi_log_node_t;
typedef struct jmi_log_t  jmi_log_t; /** opaque structure with information on the log. */

struct jmi_log_node_t {
    int inner_id;
};

/** \brief Allocate and initialize a log, with output to `jmi` */
jmi_log_t *jmi_log_init(jmi_callbacks_t* jmi_callbacks);

/** \brief Deallocate the log */
void jmi_log_delete(jmi_log_t *log);

/* Row primitives */

/** \brief Enter a new log node with given category and type. */
jmi_log_node_t jmi_log_enter(jmi_log_t *log, jmi_log_category_t c, const char *type);

/** \brief Get current log node. */
jmi_log_node_t jmi_log_get_current_node(jmi_log_t *log);

/** \brief Enter a new log node with given category and type, then call jmi_log_fmt with the remaining parameters. */
jmi_log_node_t jmi_log_enter_fmt(jmi_log_t *log, jmi_log_category_t c, const char *type, const char* fmt, ...);

/** \brief Leave the current log node, as returned by the `jmi_log_enterXXX` functions. */
void jmi_log_leave(jmi_log_t *log, jmi_log_node_t node);

/** \brief Leave log nodes until `node` is left. Use only upon abrupt return. */
void jmi_log_unwind(jmi_log_t *log, jmi_log_node_t node);

/** \brief Leave all open log nodes. Use only upon abrupt return from outermost log node. */
void jmi_log_leave_all(jmi_log_t *log);

/** \brief Create a new log node with contents given by invoking jmi_log_fmt. */
void jmi_log_node( jmi_log_t *log, jmi_log_category_t c, const char *type, const char* fmt, ...);


/** \brief Log comments and scalar attributes according to the format string `fmt`.
 *    
 *  The format string can contain
 *  * Comments, verbatim
 *  * Scalar attributes between angle brackets, in the form `<` *name* `:%` *format* `>` (e.g. `<t:%e>`, where
 *      * *name* is an identifier and
 *      * *format* is one of the printf format characters
 *          `diu` for `int`,
 *          `I` for `int`; mark it as an iv index (to be converted from 0- to 1-based by recipient if needed)
 *          `R` for `int`; mark it as a residual index (to be converted from 0- to 1-based by recipient if needed)
 *          `eEfFgG` for `jmi_real_t`, or
 *          `s` for `char *`.
 *        No format specifiers beyond the single character are supported;
 *        a default format is used for all reals, etc.
 *      * Whitespace is allowed before and after the `:` and is ignored.
 *  * Scalar attributes with a variable reference as value, in the form `<` *name* `:#` *type* `%d#>`
 *    (e.g. `<var:#r%d#>`), where `<type>` is one of the characters `ribs`.
 *  * Several scalar attributes can be listed within the same angle brackets, e.g. `<value:%g, index:%d>`
 *      * Commas and whitespace between attributes are passed through verbatim.
 * 
 *  The values for consecutive attributes should be supplied as additional arguments, just like for `printf`.
 */
void jmi_log_fmt(jmi_log_t *log, jmi_log_node_t node, jmi_log_category_t c, const char *fmt, ...);

/** \brief Log a comment inside the current node. */
void jmi_log_comment(jmi_log_t *log, jmi_log_category_t c, const char *msg);


/** \brief Log a vector of `n` reals. */
void jmi_log_reals(jmi_log_t *log,  jmi_log_node_t node,
                   jmi_log_category_t c, const char *name, const jmi_real_t *data, int n);

/** \brief Log a vector of `n` ints. */
void jmi_log_ints( jmi_log_t *log, jmi_log_node_t node,
                   jmi_log_category_t c, const char *name, const int *data, int n);

void jmi_log_strings(jmi_log_t *log,  jmi_log_node_t node,
                   jmi_log_category_t c, const char *name, const jmi_string_t *data, int n);

/** \brief Log a vector of `n` variable references of type `t`, which should be one of `ribs`. */
void jmi_log_vrefs(jmi_log_t *log, jmi_log_node_t node,
                   jmi_log_category_t c, const char *name, char t, const int *vrefs, int n);

/** \brief Log a matrix of `m x n` reals, stored in column major order. */
void jmi_log_real_matrix(jmi_log_t *log, jmi_log_node_t node,
                         jmi_log_category_t c, const char *name, const jmi_real_t *data, int m, int n);


/** \brief Emit the current accumulated log line to the logger callback. */
void jmi_log_emit(jmi_log_t *log);

/** \brief Enable or disable log message filtering by log level/category. Only disable during special circumstances! */
void jmi_log_set_filtering(jmi_log_t *log, int enabled);


/* Subrow primitives. End in _ since they don't emit a log message. */

/** \brief Supply a name for the next child of `node`. `name` must remain valid until the next `enter` call. */
void jmi_log_label_(jmi_log_t *log, jmi_log_node_t node, const char *name);

/** \brief Enter a new log node with given category and type, without ending the line. */
jmi_log_node_t jmi_log_enter_(jmi_log_t *log, jmi_log_category_t c, const char *type);

/** \brief Enter a new log node that is a vector of the given element type, without ending the line. */
jmi_log_node_t jmi_log_enter_vector_(jmi_log_t *log, jmi_log_node_t node,
                                     jmi_log_category_t c, const char *name);

/** \brief Enter a new log node that is a vector with indices of the given element type, without ending the line. */
jmi_log_node_t jmi_log_enter_index_vector_(jmi_log_t *log, jmi_log_node_t node, jmi_log_category_t c, 
                             const char *name, char index_type);

/** \brief Leave the current log node, as returned by the `jmi_log_enterXXX` functions, without ending the line. */
void jmi_log_leave_(jmi_log_t *log, jmi_log_node_t node);


/** \brief Log comments and scalar attributes according like jmi_log_fmt, without ending the line. */
void jmi_log_fmt_(jmi_log_t *log,  jmi_log_node_t node,
                  jmi_log_category_t c, const char *fmt, ...);

/** \brief Log a comment inside the current node, without ending the line. */
void jmi_log_comment_(jmi_log_t *log, jmi_log_category_t c, const char *msg);


/** \brief Log a string value, without ending the line. */
void jmi_log_string_(jmi_log_t *log, const char *x);

/** \brief Log a real value, without ending the line. */
void jmi_log_real_(  jmi_log_t *log, jmi_real_t x);

/** \brief Log an int value, without ending the line. */
void jmi_log_int_(   jmi_log_t *log, int x);

/** \brief Log a value reference of type `t` (one of `ribs`), without ending the line. */
void jmi_log_vref_(  jmi_log_t *log, char t, int vref);

char* jmi_log_get_build_date();

#endif
