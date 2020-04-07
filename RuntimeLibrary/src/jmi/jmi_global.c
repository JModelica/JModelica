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



/** \file jmi_global.c
 *  \brief Thread-safe global data and exception handling.
 */

#include <stdlib.h>
#include <stdio.h>
#include "jmi_global.h"
#include "jmi_log.h"
#include "jmi.h"

#if !defined(NO_FILE_SYSTEM) && (defined(RT) || defined(NRT))
#define NO_FILE_SYSTEM
#endif

#ifdef _MSC_VER
/* Use Microsoft stuff. */

#include <Windows.h>
#include <WinBase.h>

/**
 * \brief Handle to thread-specific storage.
 */
DWORD jmi_tls_handle;

/**
 * \brief DLL entry/exit point.
 *
 * Used to set up and free thread-specific storage.
 */
BOOL WINAPI DllMain(HINSTANCE hinstDLL, DWORD fdwReason, LPVOID lpvReserved) {
    switch (fdwReason) {
    case DLL_PROCESS_ATTACH:
        jmi_tls_handle = TlsAlloc();
        if (jmi_tls_handle == TLS_OUT_OF_INDEXES) {
            DWORD error_id = GetLastError();
            fprintf(stderr, "FATAL: Failed to get a thread-local storage id (errno: %d)\n", error_id);
            return FALSE;
        }
        break;
    case DLL_PROCESS_DETACH:
        if (jmi_tls_handle != TLS_OUT_OF_INDEXES && TlsFree(jmi_tls_handle) == 0) {
            DWORD error_id = GetLastError();
            fprintf(stderr, "Failed to release a thread-local storage id (handle: %d) (errno: %d)\n", jmi_tls_handle, error_id);
        }
        break;
    default:
        break;
    }
    return TRUE;
}

/* Macro for function that sets thread-specific storage value. */
#define jmi_tls_set_value TlsSetValue

/* Macro for function that gets thread-specific storage value. */
#define jmi_tls_get_value TlsGetValue

#elif defined(NO_FILE_SYSTEM) /* ifdef _MSC_VER */
    
static void* jmi_tls_handle;

void jmi_tls_set_value(void *handle, jmi_t* jmi) {
    handle = (void*)jmi;
}

void* jmi_tls_get_value(void *handle) {
    return handle;
}
    
#else /* ifdef _MSC_VER */
/* Assume pthreads is available. */

#define _MULTI_THREADED
#ifdef _WIN32 /* MinGW only: define use static lib and specific include */
#define PTW32_STATIC_LIB
#endif
#include <pthread.h>
/**
 * \brief Handle to thread-specific storage.
 */
pthread_key_t jmi_tls_handle;

/**
 * \brief Called when shared library is loaded.
 *
 * Used to set up thread-specific storage.
 */
__attribute__((constructor)) static void jmi_init_tls() {
    /* TODO: Handle failure. */
    pthread_key_create(&jmi_tls_handle, NULL);
}

/**
 * \brief Called when shared library is unloaded.
 *
 * Used to free thread-specific storage.
 */
__attribute__((destructor)) static void jmi_free_tls() {
    pthread_key_delete(jmi_tls_handle);
}

/* Macro for function that sets thread-specific storage value. */
#define jmi_tls_set_value pthread_setspecific

/* Macro for function that gets thread-specific storage value. */
#define jmi_tls_get_value pthread_getspecific

#endif /* ifdef _MSC_VER */

/* TODO: Add version without multi-thread support, to be used where pthereads is unavailable. */


/**
 * \brief Set the current jmi struct.
 */
void jmi_set_current(jmi_t* jmi) {
    if (jmi != NULL && jmi_tls_get_value(jmi_tls_handle) != NULL)
        fprintf(stderr, "jmi_set_current(): current is not NULL\n");
    jmi_tls_set_value(jmi_tls_handle, jmi);
}

/**
 * \brief Get the current jmi struct.
 */
jmi_t* jmi_get_current() {
    jmi_t* res = (jmi_t*) jmi_tls_get_value(jmi_tls_handle);
    if (res == NULL)
        fprintf(stderr, "jmi_get_current(): current is NULL\n");
    return res;
}

/**
 * \brief Check if the current jmi struct is set.
 */
int jmi_current_is_set() {
    return jmi_tls_get_value(jmi_tls_handle) != NULL;
}

/* TODO: This version needs more consideration to support FMUs calling other FMUs. */

/**
 * \brief Prepare try buffer for calling jmi_try()
 * \returns Try depth to be submitted to jmi_try and jmi_finalize_try
 */
int jmi_prepare_try(jmi_t* jmi) {
    int depth;

    if (!jmi_current_is_set()) {
        jmi_set_current(jmi);
        jmi->current_try_depth = 0;
    }
    depth = jmi->current_try_depth;
    if (depth < JMI_MAX_EXCEPTION_DEPTH) 
        jmi->current_try_depth = depth + 1;
    return depth;
}

/**
*    \brief Cleans up try buffer after jmi_try returnes.
*/
void jmi_finalize_try(jmi_t* jmi, int depth) {
    if (depth < 0 || depth >= JMI_MAX_EXCEPTION_DEPTH) {
        fprintf(stderr, "jmi_finalize_try(): Unexpected try depth=%d, resetting to 0\n",depth);
        depth = 0;
    }
    jmi->current_try_depth = depth;
    if (depth == 0) {
        jmi_set_current(NULL);
    }
}

/**
 * \brief Set up for exception handling.
 */
void jmi_throw() {
    jmi_t* jmi;

    jmi = jmi_get_current();
    if (jmi && jmi->current_try_depth > 0) {
        longjmp(jmi->try_location[jmi->current_try_depth-1], 1);
    }
}


/**
 * \brief Print a node with single attribute to logger, using saved jmi_t struct.
 */
void jmi_global_log(int warning, const char* name, const char* fmt, const char* value) {
    jmi_t* jmi = jmi_get_current();
    jmi_log_node(jmi->log, warning ? logWarning : logInfo, name, fmt, value);
}

/**
 * \brief Allocate memory with user-supplied function, if any. Otherwise use calloc().
 */
void* jmi_global_calloc(size_t n, size_t s) {
    jmi_t* jmi = jmi_get_current();
    return jmi_dynamic_function_pool_direct_alloc(jmi->dyn_fcn_mem, n*s, TRUE);
}

/**
 * Signal a failed assertion.
 *
 * If level is JMI_ASSERT_ERROR, then function will not return.
 */
void jmi_assert_failed(const char* msg, int level) {
    if (level == JMI_ASSERT_WARNING) {
        jmi_global_log(1, "AssertionWarning", "<msg:%s>", msg);
    } else if (level == JMI_ASSERT_ERROR) {
        jmi_global_log(1, "AssertionError", "<msg:%s>", msg);
        jmi_throw();
        jmi_global_log(1, "Error", "<msg:%s>", "Could not throw an exception from Assert call");
    }
}
