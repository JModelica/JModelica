/*
    Copyright (C) 2011 Modelon AB

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

/** \file fmi1_cs.h
 *  \brief The public FMI co-simulation interface.
 **/

#ifndef fmi1_cs_h
#define fmi1_cs_h

#include "fmi1_functions.h"
#include "jmi.h"
#include "jmi_cs.h"

/**
 * \defgroup fmi_cs_public Public functions of the Functional Mock-up Interface for co-simulation.
 *
 * \brief Documentation of the public functions and data structures
 * of the Functional Mock-up Interface for co-simulation.
 */

/* @{ */

typedef struct fmi1_cs_t fmi1_cs_t;

struct fmi1_cs_t {
    jmi_ode_problem_t* ode_problem;      /**< \brief A jmi ode problem pointer. */
    jmi_cs_data_t* cs_data;              /**< \brief A jmi cs data pointer. */
    
    fmiString instance_name;             /**< \brief The fmi1_cs instance name. */
    fmiString encoded_instance_name;     /**< \brief The encoded instance name provided to the fmi1_me instance. */
    fmiString GUID;                      /**< \brief The GUID identifier. */
    fmiCallbackFunctions callback_functions;    /**< \brief The callback functions provided by the user. */
    fmiCallbackFunctions me_callback_functions; /**< \brief The modified callbacks provided to the fmi1_me instance. */
    fmiBoolean logging_on;                      /** < \brief The logging on / off attribute. */
    int initialize_solver;               /** < \brief Flag indicating if the solver shall be initialized. */
};

/**
 * \brief Returns the compatible platforms.
 *
 * This methods returns the set of compatible platforms for which the FMU was
 * compiled for.
 * 
 * @return The set of compatible platforms.
 */
const char* fmi1_cs_get_types_platform();

/**
 * \brief Returns the version of the header file.
 * 
 * @return The version of fmiModelFunctions.h.
 */
const char* fmi1_cs_get_version();

/**
 * \brief Performs a time-step.
 * 
 * @param c The FMU struct.
 * @param currentCommunicationPoint The current communication point.
 * @param communicationStepSize The length of the step to perform.
 * @param newStep If the last step was accepted.
 * @return Error code.
 */
fmiStatus fmi1_cs_do_step(fmiComponent c,
                         fmiReal currentCommunicationPoint,
                         fmiReal communicationStepSize,
                         fmiBoolean   newStep);
                         
/**
 * \brief Dispose of the slave instance.
 * 
 * @param c The FMU struct.
 */
void fmi1_cs_free_slave_instance(fmiComponent c);

/**
 * \brief Instantiates the slave FMU.
 * 
 * @param instanceName The name of the instance.
 * @param GUID The GUID identifier.
 * @param fmuLocation Access path to the FMU.
 * @param mimeType The mime type of the simulator.
 * @param timeout The communucation time-out interval.
 * @param visible Indicates if the simulator application windows should be visible.
 * @param interactive If the simulation needs to be manually started.
 * @param functions Callback functions for logging, allocation and deallocation.
 * @param loggingOn Turn of or on logging, fmiBoolean.
 * @return An instance of a model.
 */
fmiComponent fmi1_cs_instantiate_slave(fmiString instanceName, fmiString GUID, fmiString fmuLocation, fmiString mimeType, 
                                   fmiReal timeout, fmiBoolean visible, fmiBoolean interactive, fmiCallbackFunctions functions, 
                                   fmiBoolean loggingOn);

/**
 * \brief Dellocates all memory since the call to the initialization method.
 * 
 * @param c The FMU struct.
 * @return Error code.
 */
fmiStatus fmi1_cs_terminate_slave(fmiComponent c);

/**
 * \brief Initialize the slave FMU.
 * 
 * @param c The FMU struct.
 * @param tStart Start-time of the simulation.
 * @param StopTimeDefined If tStop is defined.
 * @param tStop Stop-time of the simulation.
 * @return Error code.
 */
fmiStatus fmi1_cs_initialize_slave(fmiComponent c, fmiReal tStart,fmiBoolean StopTimeDefined, fmiReal tStop);

/**
 * \brief Cancel a pending step.
 * 
 * @param c The FMU struct.
 * @return Error code.
 */
fmiStatus fmi1_cs_cancel_step(fmiComponent c);

/**
 * \brief Resets the slave FMU.
 * 
 * @param c The FMU struct.
 * @return Error code.
 */
fmiStatus fmi1_cs_reset_slave(fmiComponent c);

/**
 * \brief Gets the derivative of the outputs
 * 
 * @param c The FMU struct.
 * @param vr The value reference(s)
 * @param nvr The length of vr
 * @param order The order of the output derivative
 * @param value The value(s) to set.
 * @return Error code.
 */
fmiStatus fmi1_cs_get_real_output_derivatives(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiInteger order[], fmiReal value[]);

/**
 * \brief Sets the derivative of the outputs
 * 
 * @param c The FMU struct.
 * @param vr The value reference(s)
 * @param nvr The length of vr
 * @param order The derivative order
 * @param value The value(s) to set.
 * @return Error code.
 */
fmiStatus fmi1_cs_set_real_input_derivatives(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiInteger order[], const fmiReal value[]);

/**
 * \brief Retrieve status information from the FMU
 * 
 * @param c The FMU struct.
 * @param s The kind of status information.
 * @param value The output information
 * @return Error code.
 */
fmiStatus fmi1_cs_get_status(fmiComponent c, const fmiStatusKind s, fmiStatus* value);

/**
 * \brief Retrieve (real) status information from the FMU
 * 
 * @param c The FMU struct.
 * @param s The kind of status information.
 * @param value The output information
 * @return Error code.
 */
fmiStatus fmi1_cs_get_real_status(fmiComponent c, const fmiStatusKind s, fmiReal* value);

/**
 * \brief Retrieve (integer) status information from the FMU
 * 
 * @param c The FMU struct.
 * @param s The kind of status information.
 * @param value The output information
 * @return Error code.
 */
fmiStatus fmi1_cs_get_integer_status(fmiComponent c, const fmiStatusKind s, fmiInteger* value);

/**
 * \brief Retrieve (boolean) status information from the FMU
 * 
 * @param c The FMU struct.
 * @param s The kind of status information.
 * @param value The output information
 * @return Error code.
 */
fmiStatus fmi1_cs_get_boolean_status(fmiComponent c, const fmiStatusKind s, fmiBoolean* value);

/**
 * \brief Retrieve (string) status information from the FMU
 * 
 * @param c The FMU struct.
 * @param s The kind of status information.
 * @param value The output information
 * @return Error code.
 */
fmiStatus fmi1_cs_get_string_status(fmiComponent c, const fmiStatusKind s, fmiString* value);

/**
 * \brief Set Real values.
 * 
 * @param c The FMU struct.
 * @param vr Array of value-references.
 * @param nvr Number of array elements.
 * @param value Array of variable values.
 * @return Error code.
 */
fmiStatus fmi1_cs_set_real(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiReal value[]);

/**
 * \brief Set Integer values.
 * 
 * @param c The FMU struct.
 * @param vr Array of value-references.
 * @param nvr Number of array elements.
 * @param value Array of variable values.
 * @return Error code.
 */
fmiStatus fmi1_cs_set_integer (fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiInteger value[]);

/**
 * \brief Set Boolean values.
 * 
 * @param c The FMU struct.
 * @param vr Array of value-references.
 * @param nvr Number of array elements.
 * @param value Array of variable values.
 * @return Error code.
 */
fmiStatus fmi1_cs_set_boolean (fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiBoolean value[]);

/**
 * \brief Set String values.
 * 
 * @param c The FMU struct.
 * @param vr Array of value-references.
 * @param nvr Number of array elements.
 * @param value Array of variable values.
 * @return Error code.
 */
fmiStatus fmi1_cs_set_string(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiString value[]);

/**
 * \brief Get Real values.
 * 
 * @param c The FMU struct.
 * @param vr Array of value-references.
 * @param nvr Number of array elements.
 * @param value (Output) Array of variable values.
 * @return Error code.
 */
fmiStatus fmi1_cs_get_real(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiReal value[]);

/**
 * \brief Get Integer values.
 * 
 * @param c The FMU struct.
 * @param vr Array of value-references.
 * @param nvr Number of array elements.
 * @param value (Output) Array of variable values.
 * @return Error code.
 */
fmiStatus fmi1_cs_get_integer(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiInteger value[]);

/**
 * \brief Get Boolean values.
 * 
 * @param c The FMU struct.
 * @param vr Array of value-references.
 * @param nvr Number of array elements.
 * @param value (Output) Array of variable values.
 * @return Error code.
 */
fmiStatus fmi1_cs_get_boolean(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiBoolean value[]);

/**
 * \brief Get String values.
 * 
 * @param c The FMU struct.
 * @param vr Array of value-references.
 * @param nvr Number of array elements.
 * @param value (Output) Array of variable values.
 * @return Error code.
 */
fmiStatus fmi1_cs_get_string(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiString  value[]);

/**
 * \brief Turns on or off debugging.
 * 
 * @param c The FMU struct.
 * @param loggingOn A fmiBoolean.
 * @return Error code.
 */
fmiStatus fmi1_cs_set_debug_logging(fmiComponent c, fmiBoolean loggingOn);

/* @} */

#endif
