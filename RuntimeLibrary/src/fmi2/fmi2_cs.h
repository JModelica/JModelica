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

#ifndef fmi2_cs_h
#define fmi2_cs_h

#include "fmi2Functions.h"
#include "fmi2_me.h"
#include "jmi_ode_problem.h"
#include "jmi_cs.h"

/** \file fmi2_me.h
 *  \brief The public FMI 2.0 model interface.
 **/

/* @{ */

typedef struct fmi2_cs_t fmi2_cs_t;      /**< \brief Forward declaration of struct. */

struct fmi2_cs_t {
    fmi2_me_t          fmi2_me;                     /**< \brief Must be the first one in this struct so that a fmi2_cs_t pointer can be used in place of a fmi2_me_t pointer. */
    jmi_ode_problem_t* ode_problem;                 /**< \brief A jmi ode problem pointer. */
    jmi_cs_data_t*     cs_data;                     /**< \brief A jmi CS data pointer. */
};

/**
 * \defgroup The Model Exchange public functions for FMI 2.0.
 * 
 * \brief Definitions of the functions for Model Exchange.
 */
 
 /* @{ */

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
fmi2Status fmi2_set_real_input_derivatives(fmi2Component c, 
                                           const fmi2ValueReference vr[],
                                           size_t nvr, const fmi2Integer order[],
                                           const fmi2Real value[]);

/**
 * \brief Gets the derivative of the outputs
 * 
 * @param c The FMU struct.
 * @param vr The value reference(s)
 * @param nvr The length of vr
 * @param order The order of the output derivative
 * @param value (Output) The value(s) to get.
 * @return Error code.
 */
fmi2Status fmi2_get_real_output_derivatives(fmi2Component c,
                                            const fmi2ValueReference vr[],
                                            size_t nvr, const fmi2Integer order[],
                                            fmi2Real value[]);

/**
 * \brief Performs a time-step.
 * 
 * @param c The FMU struct.
 * @param currentCommunicationPoint The current communication point.
 * @param communicationStepSize The length of the step to perform.
 * @param noSetFMUStatePriorToCurrentPoint A fmi2Boolean, can be used to 
 *                                         flush earlier saved FMU states.
 * @return Error code.
 */
fmi2Status fmi2_do_step(fmi2Component c, fmi2Real currentCommunicationPoint,
                        fmi2Real    communicationStepSize,
                        fmi2Boolean noSetFMUStatePriorToCurrentPoint);

/**
 * \brief Can be called in order to stop the current asynchronous execution.
 * 
 * @param c The FMU struct.
 * @return Error code.
 */
fmi2Status fmi2_cancel_step(fmi2Component c);

/**
 * \brief Retrieve status information from the FMU
 * 
 * @param c The FMU struct.
 * @param s The kind of status information.
 * @param value The output information
 * @return Error code.
 */
fmi2Status fmi2_get_status(fmi2Component c, const fmi2StatusKind s,
                           fmi2Status* value);

/**
 * \brief Retrieve (real) status information from the FMU
 * 
 * @param c The FMU struct.
 * @param s The kind of status information.
 * @param value The output information
 * @return Error code.
 */
fmi2Status fmi2_get_real_status(fmi2Component c, const fmi2StatusKind s,
                                fmi2Real* value);
                               
/**
 * \brief Retrieve (integer) status information from the FMU
 * 
 * @param c The FMU struct.
 * @param s The kind of status information.
 * @param value The output information
 * @return Error code.
 */
fmi2Status fmi2_get_integer_status(fmi2Component c, const fmi2StatusKind s,
                                   fmi2Integer* values);

/**
 * \brief Retrieve (boolean) status information from the FMU
 * 
 * @param c The FMU struct.
 * @param s The kind of status information.
 * @param value The output information
 * @return Error code.
 */
fmi2Status fmi2_get_boolean_status(fmi2Component c, const fmi2StatusKind s,
                                   fmi2Boolean* value);

/**
 * \brief Retrieve (string) status information from the FMU
 * 
 * @param c The FMU struct.
 * @param s The kind of status information.
 * @param value The output information
 * @return Error code.
 */
fmi2Status fmi2_get_string_status(fmi2Component c, const fmi2StatusKind s,
                                  fmi2String* value);


 /* @} */
 
 /* @} */

/**
 * \brief Instantiates the CS FMU, helper function for fmi2_instantiate.
 * 
 * @param c The FMU struct.
 * @param instanceName The name of the instance.
 * @param fmuType The fmi type to instanciate.
 * @param GUID The GUID identifier.
 * @param fmuResourceLocation The location of the resource directory.
 * @param functions Callback functions for logging, allocation and deallocation.
 * @param visible A fmi2Boolean, defines the amount of interaction with the user.
 * @param loggingOn Turn of or on logging, fmi2Boolean.
 * @return An instance of a model.
 */                 
fmi2Status fmi2_cs_instantiate(fmi2Component c,
                               fmi2String    instanceName,
                               fmi2Type      fmuType, 
                               fmi2String    fmuGUID, 
                               fmi2String    fmuResourceLocation, 
                               const fmi2CallbackFunctions* functions, 
                               fmi2Boolean                  visible,
                               fmi2Boolean                  loggingOn);

/**
 * \brief Dispose of the CS model instance, helper function for fmi2_free_instance.
 * 
 * @param c The FMU struct.
 */
void fmi2_cs_free_instance(fmi2Component c);

#endif
