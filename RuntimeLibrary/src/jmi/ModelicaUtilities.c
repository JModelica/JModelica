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

#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include "ModelicaUtilities.h"
#include "jmi_global.h"


#define BUF_SIZE 1024
#define BUF_OVERRUN_TAG "..."
#define BUF_OVERRUN_TAG_LEN sizeof(BUF_OVERRUN_TAG)

void ModelicaMessage(const char* string) 
{
    /* TODO: This is an informative message, not a warning, but is rather important. Change once log level is made separate from message category. */
    jmi_global_log(1, "ModelicaMessage", "<msg:%s>", string);
}

void ModelicaFormatMessage(const char* string, ...)
{
    va_list arg_ptr;
    va_start(arg_ptr, string);
    ModelicaVFormatMessage(string, arg_ptr);
    va_end(arg_ptr);
}

void ModelicaVFormatMessage(const char* string, va_list arg_ptr) 
{
    char buf[BUF_SIZE];
    int n;

    n = vsnprintf(buf, BUF_SIZE, string, arg_ptr);
    if (n == -1 || n >= BUF_SIZE)
    	strcpy(BUF_OVERRUN_TAG, buf + BUF_SIZE - BUF_OVERRUN_TAG_LEN);
    ModelicaMessage(buf);
}

void ModelicaError(const char* string)
{
    jmi_global_log(1, "ModelicaError", "<msg:%s>", string);
    jmi_throw();
    jmi_global_log(1, "Error", "<msg:%s>", "Could not throw an exception from ModelicaError");
}

void ModelicaFormatError(const char* string, ...)
{
    va_list arg_ptr;
    va_start(arg_ptr, string);
    ModelicaVFormatError(string, arg_ptr);
    va_end(arg_ptr);
}

void ModelicaVFormatError(const char* string, va_list arg_ptr)
{
    char buf[BUF_SIZE];
    int n;

    n = vsnprintf(buf, BUF_SIZE, string, arg_ptr);
    if (n == -1 || n >= BUF_SIZE)
        strcpy(BUF_OVERRUN_TAG, buf + BUF_SIZE - BUF_OVERRUN_TAG_LEN);
    ModelicaError(buf);
}

char* ModelicaAllocateString(size_t len) 
{
    char* c = ModelicaAllocateStringWithErrorReturn(len);
    if (c == NULL) {
        ModelicaFormatError("Could not allocate memory for string with length %d.", len);
    }
    return c;

}

char* ModelicaAllocateStringWithErrorReturn(size_t len) 
{
    char* res = (char*) jmi_global_calloc(len + 1, sizeof(char));
    return res;
}
