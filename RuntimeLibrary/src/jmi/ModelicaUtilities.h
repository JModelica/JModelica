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

/** \file ModelicaUtilities.h 
 *  \brief Utility functions which can be called by external Modelica functions.
 **/

#ifndef MODELICA_UTILITIES_H
#define MODELICA_UTILITIES_H

#include <stddef.h>
#include <stdarg.h>

/** 
 * \brief Output the message string (no format control).
 * 
 * @param string The message.
 */
void ModelicaMessage(const char* string);

/**
 * \brief Output the message under the same format control as the C-function 
 * printf.
 * 
 * @param string The formatted message.
 */
void ModelicaFormatMessage(const char* string,...);

/**
 * \brief Output the message under the same format control as the C-function 
 * vprintf.
 * 
 * @param string The formatted message.
 * @param arg_ptr Pointer to list of arguments.
 */
void ModelicaVFormatMessage(const char* string, va_list arg_ptr);

/**
 * \brief Output the error message string (no format control). This function 
 * never returns to the calling function, but handles the error similarly to an 
 * assert in the Modelica code.
 * 
 * @param string The error message.
 */
void ModelicaError(const char* string);

/**
 * \brief Output the error message under the same format control as the 
 * C-function printf. This function never returns to the calling function, but 
 * handles the error similarly to an assert in the Modelica code.
 * 
 * @param string The formatted error message.
 */ 
void ModelicaFormatError(const char* string,...);

/**
 * \brief Output the error message under the same format control as the 
 * C-function vprintf. This function never returns to the calling function, but 
 * handles the error similarly to an assert in the Modelica code.
 * 
 * @param string The formatted error message.
 * @param arg_ptr Pointer to list of arguments.
 */ 
void ModelicaVFormatError(const char* string, va_list arg_ptr);

/**
 * \brief Allocate memory for a Modelica string which is used as return argument 
 * of an external Modelica function. Note, that the storage for string arrays 
 * (= pointer to string array) is still provided by the calling program, as for 
 * any other array. If an error occurs, this function does not return, but calls 
 * "ModelicaError".
 * 
 * @param len Length of string to allocate.
 */ 
char* ModelicaAllocateString(size_t len);

/**
 * \brief Same as ModelicaAllocateString, except that in case of error, the 
 * function returns 0. This allows the external function to close files and free 
 * other open resources in case of error. After cleaning up resources use 
 * ModelicaError or ModelicaFormatError to signal the error.
 * 
 * @param len Length of string to allocate.
 */ 
char* ModelicaAllocateStringWithErrorReturn(size_t len);

#endif
