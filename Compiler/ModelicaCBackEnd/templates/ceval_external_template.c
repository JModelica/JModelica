/*
    Copyright (C) 2015-2018 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the Common Public License as published by
    IBM, version 1.0 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY. See the Common Public License for more details.

    You should have received a copy of the Common Public License
    along with this program. If not, see
    <http://www.ibm.com/developerworks/library/os-cpl.html/>.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "jmi.h"
#include "jmi_dyn_mem.h"
#include "ModelicaUtilities.h"
#include <fcntl.h>

$ECE_external_includes$
 
/* Manual debugging */
#define JMCEVAL_DEBUG 0
#define JMCEVAL_DBGP(x) if (JMCEVAL_DEBUG) { printf(x); fflush(stdout);}

/* Format specifier when printing jmi_real_t */
#define JMCEVAL_realFormat "%.16f"

/* Used record definitions */
$ECE_record_definitions$

/* Parses ND dimensions into dimension buffer d*/
#define JMCEVAL_parseArrayDims(ND) \
    for (di = 0; di < ND; di++) { scanf("%d",&d[di]); }

/* Parse/print basic types */
double JMCEVAL_parseReal() {
    /* Char buffer when reading jmi_real_t. This is necessary
       since "%lf" is not allowed in c89. */
    char buff[32];
    JMCEVAL_DBGP("Parse number: "); 
    scanf("%s",buff);
    return strtod(buff, 0);
}

void JMCEVAL_printReal(double x) {
    printf(JMCEVAL_realFormat, x); \
    printf("\n"); \
    fflush(stdout); \
}

char* JMCEVAL_parseString() {
    int d[1];
    char* str;
    size_t si,di;
    JMCEVAL_parseArrayDims(1);
    getchar();
    str = ModelicaAllocateString(d[0]);
    JMCEVAL_DBGP("Parse string: ");
    for (si = 0; si < d[0]; si++) str[si] = getchar();
    str[d[0]] = '\0';
    return str;
}

void JMCEVAL_printString(const char* str) {
    printf("%u\n%s\n", (unsigned)strlen(str), str);
    fflush(stdout);
}

#define JMCEVAL_parseInteger()  JMCEVAL_parseReal()
#define JMCEVAL_parseBoolean()  JMCEVAL_parseInteger()
#define JMCEVAL_parseEnum()     JMCEVAL_parseInteger()
#define JMCEVAL_printInteger(X) JMCEVAL_printReal(X)
#define JMCEVAL_printBoolean(X) JMCEVAL_printInteger(X)
#define JMCEVAL_printEnum(X)    JMCEVAL_printInteger(X)
#define JMCEVAL_parse(TYPE, X)  X = JMCEVAL_parse##TYPE()
#define JMCEVAL_print(TYPE, X)  JMCEVAL_print##TYPE(X)

/* Parse/print arrays */
#define JMCEVAL_parseArray(TYPE,ARR) for (vi = 1; vi <= ARR->num_elems; vi++) { JMCEVAL_parse(TYPE, jmi_array_ref_1(ARR,vi)); }
#define JMCEVAL_printArray(TYPE,ARR) for (vi = 1; vi <= ARR->num_elems; vi++) { JMCEVAL_print(TYPE, jmi_array_val_1(ARR,vi)); }

/* Used by ModelicaUtilities */
void jmi_global_log(int warning, const char* name, const char* fmt, const char* value)
{
    printf("LOG\n");
    JMCEVAL_printInteger((double)warning);
    JMCEVAL_printString(name);
    JMCEVAL_printString(fmt);
    JMCEVAL_printString(value);
}

jmp_buf jmceval_try_location;

#define JMCEVAL_try() (setjmp(jmceval_try_location) == 0)

void jmi_throw()
{
    longjmp(jmceval_try_location, 1);
}

jmi_dynamic_function_memory_t* dyn_fcn_mem = NULL;

jmi_dynamic_function_memory_t* jmi_dynamic_function_memory() {
    if (dyn_fcn_mem == NULL) { dyn_fcn_mem = jmi_dynamic_function_pool_create(1024*1024); }
    return dyn_fcn_mem;
}

void* jmi_global_calloc(size_t n, size_t s)
{
    return jmi_dynamic_function_pool_direct_alloc(dyn_fcn_mem, n*s, 1);
}

void JMCEVAL_setup() {
#ifdef _WIN32
    /* Prevent win from translating \n to \r\n */
    _setmode(fileno(stdout), _O_BINARY);
#endif
}

int JMCEVAL_cont(const char* word) {
    char l[10];
    char* s = fgets(l, 10, stdin);
    if (strlen(s) == 1) {
        s = fgets(l, 10, stdin); /* Extra call to fix stray newline */
    }
    if (s == NULL) {
        exit(2);
    }
    if (strlen(s) == strlen(word)) {
        return strncmp(l, word, strlen(word)) == 0;
    }
    return 0;
}

void JMCEVAL_check(const char* str) {
    printf("%s\n",str);
    fflush(stdout);
}

void JMCEVAL_failed() {
    JMCEVAL_check("ABORT");
}

/* Main */
int main(int argc, const char* argv[])
{
    /* Size buffer for reading array dimensions */
    int d[25];
    
    /* Indices for parsing/printing vars, dimensions */
    size_t vi,di;
    
$ECE_decl$
$ECE_setup_decl$

    JMCEVAL_setup(); /* This needs to happen first */

    JMCEVAL_check("START");
    if (JMCEVAL_try()) {
        JMI_DYNAMIC_INIT()
        /* Init phase */
$ECE_setup_init$
        JMI_DYNAMIC_FREE()
    } else {
        JMCEVAL_failed();
    }
    
    JMCEVAL_check("READY");
    while (JMCEVAL_cont("EVAL\n")) {
        JMI_DYNAMIC_INIT()
$ECE_calc_decl$
$ECE_calc_init$
        JMCEVAL_check("CALC");
        if (JMCEVAL_try()) {
            /* Calc phase */
$ECE_calc$
        } else {
            JMCEVAL_failed();
        }
$ECE_calc_free$
        JMI_DYNAMIC_FREE()
        JMCEVAL_check("READY");
    }

    if (JMCEVAL_try()) {
        /* End phase */
$ECE_free$
$ECE_setup_free$
    } else {
        JMCEVAL_failed();
    }
    jmi_dynamic_function_pool_destroy(dyn_fcn_mem);
    JMCEVAL_check("END");
    return 0;
}

