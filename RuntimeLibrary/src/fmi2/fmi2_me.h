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

#ifndef fmi2_me_h
#define fmi2_me_h

#include "fmi2Functions.h"
#include "jmi_util.h"
#include "jmi.h"
#include "jmi_me.h"

/** \file fmi2_me.h
 *  \brief The public FMI 2.0 model interface.
 **/

/* @{ */

/* Type definitions */
/* typedef */

typedef enum {
    initializationMode,
    eventMode,
    continuousTimeMode,
    instantiatedMode,
	slaveInitialized,
	terminated
} fmi2_mode_t;

typedef struct fmi2_me_t fmi2_me_t;  /**< \brief Forward declaration of struct. */

struct fmi2_me_t {
    jmi_t                        jmi;                   /**< \brief Must be the first one in this struct so that a fmi2_me_t pointer can be used in place of a jmi_t pointer. */
    fmi2_mode_t                  fmu_mode;              /**< \brief The FMUs mode it's currently in. */
    fmi2Type                     fmu_type;              /**< \brief The FMUs type selected at instantiation */
    fmi2String                   fmu_instance_name;     /**< \brief The FMUs instance name. */
    fmi2String                   fmu_GUID;              /**< \brief The FMUs GUID. */
    fmi2Boolean                  initial_logging_on;    /**< \brief The initial option for loggingOn at instantiation. */
    fmi2Real                     stopTime;              /**< \brief The stop time when simulating the FMU. */
    const fmi2CallbackFunctions* fmi_functions;         /**< \brief The fmi callback functions provided by the environment at instantiaton. */
    jmi_event_info_t*            event_info;            /**< \brief The event info struct that is propagated to the JMI runtime. */
    fmi2Real*                    work_real_array;       /**< \brief Work array for Real variables. */
    fmi2Integer*                 work_int_array;        /**< \brief Work array for Int variables. */
};

/**
 * \defgroup The shared public functions for FMI 2.0.
 * 
 * \brief Definitions of the shared functions for Model Exchange and Co-Simulation.
 */
 
 /* @{ */

/**
 * \brief Returns the platform types compiled for.
 *
 * This methods returns the string to uniquely identify the "fmi2TypesPlatform.h"
 * header file for which the FMU was compiled for.
 * 
 * @return The identifier of platform types compiled for.
 */
const char* fmi2_get_types_platform();

/**
 * \brief Returns the FMI version of the header file.
 * 
 * @return The FMI version of fmiFunctions.h.
 */
const char* fmi2_get_version();

/**
 * \brief Sets the logging settings.
 * 
 * @param c The FMU struct.
 * @param loggingOn A fmi2Boolean, sets logging on or off.
 * @param nCategories Number of categories.
 * @param categories The categories to be logging for.
 * @return Error code.
 */
fmi2Status fmi2_set_debug_logging(fmi2Component    c,
                                  fmi2Boolean      loggingOn, 
                                  size_t           nCategories, 
                                  const fmi2String categories[]);

/**
 * \brief Instantiates the FMU.
 * 
 * @param instanceName The name of the instance.
 * @param fmuType The fmi type to instanciate.
 * @param GUID The GUID identifier.
 * @param fmuResourceLocation The location of the resource directory.
 * @param functions Callback functions for logging, allocation and deallocation.
 * @param visible A fmi2Boolean, defines the amount of interaction with the user.
 * @param loggingOn Turn of or on logging, fmi2Boolean.
 * @return An instance of a model.
 */
fmi2Component fmi2_instantiate(fmi2String instanceName,
                               fmi2Type   fmuType, 
                               fmi2String fmuGUID, 
                               fmi2String fmuResourceLocation, 
                               const fmi2CallbackFunctions* functions, 
                               fmi2Boolean                  visible,
                               fmi2Boolean                  loggingOn);

/**
 * \brief Dispose of the model instance.
 * 
 * @param c The FMU struct.
 */
void fmi2_free_instance(fmi2Component c);

/**
 * \brief Informs the FMU to setup the experiment
 * 
 * @param c The FMU struct.
 * @param toleranceDefined A fmi2Boolean, states if the tolerance argument is valid.
 * @param tolerance The tolerance to use for the setup.
 * @param startTime The starting time of initializaton.
 * @param stopTimeDefined A fmi2Boolean, states if the stopTime argument is valid.
 * @param stopTime The stop time of the simulation.
 */
fmi2Status fmi2_setup_experiment(fmi2Component c, 
                                 fmi2Boolean   toleranceDefined, 
                                 fmi2Real      tolerance, 
                                 fmi2Real      startTime, 
                                 fmi2Boolean   stopTimeDefined, 
                                 fmi2Real      stopTime);

/**
 * \brief Makes the FMU go into Initialization Mode.
 * 
 * @param c The FMU struct.
 */
fmi2Status fmi2_enter_initialization_mode(fmi2Component c);

/**
 * \brief Makes the FMU exit Initialization Mode.
 * 
 * @param c The FMU struct.
 */
fmi2Status fmi2_exit_initialization_mode(fmi2Component c);

/**
 * \brief Terminates the simulation run of the FMU.
 * 
 * @param c The FMU struct.
 */
fmi2Status fmi2_terminate(fmi2Component c);

/**
 * \brief Resets the FMU after a simulation run.
 * 
 * @param c The FMU struct.
 */
fmi2Status fmi2_reset(fmi2Component c);

/**
 * \brief Get Real values.
 * 
 * @param c The FMU struct.
 * @param vr Array of value-references.
 * @param nvr Number of array elements.
 * @param value (Output) Array of variable values.
 * @return Error code.
 */
fmi2Status fmi2_get_real(fmi2Component c, const fmi2ValueReference vr[],
                         size_t nvr, fmi2Real value[]);

/**
 * \brief Get Integer values.
 * 
 * @param c The FMU struct.
 * @param vr Array of value-references.
 * @param nvr Number of array elements.
 * @param value (Output) Array of variable values.
 * @return Error code.
 */
fmi2Status fmi2_get_integer(fmi2Component c, const fmi2ValueReference vr[],
                            size_t nvr, fmi2Integer value[]);

/**
 * \brief Get Boolean values.
 * 
 * @param c The FMU struct.
 * @param vr Array of value-references.
 * @param nvr Number of array elements.
 * @param value (Output) Array of variable values.
 * @return Error code.
 */
fmi2Status fmi2_get_boolean(fmi2Component c, const fmi2ValueReference vr[],
                            size_t nvr, fmi2Boolean value[]);

/**
 * \brief Get String values.
 * 
 * @param c The FMU struct.
 * @param vr Array of value-references.
 * @param nvr Number of array elements.
 * @param value (Output) Array of variable values.
 * @return Error code.
 */
fmi2Status fmi2_get_string(fmi2Component c, const fmi2ValueReference vr[],
                           size_t nvr, fmi2String value[]);

/**
 * \brief Set Real values.
 * 
 * @param c The FMU struct.
 * @param vr Array of value-references.
 * @param nvr Number of array elements.
 * @param value Array of variable values.
 * @return Error code.
 */
fmi2Status fmi2_set_real(fmi2Component c, const fmi2ValueReference vr[],
                         size_t nvr, const fmi2Real value[]);

/**
 * \brief Set Integer values.
 * 
 * @param c The FMU struct.
 * @param vr Array of value-references.
 * @param nvr Number of array elements.
 * @param value Array of variable values.
 * @return Error code.
 */
fmi2Status fmi2_set_integer(fmi2Component c, const fmi2ValueReference vr[],
                            size_t nvr, const fmi2Integer value[]);

/**
 * \brief Set Boolean values.
 * 
 * @param c The FMU struct.
 * @param vr Array of value-references.
 * @param nvr Number of array elements.
 * @param value Array of variable values.
 * @return Error code.
 */
fmi2Status fmi2_set_boolean(fmi2Component c, const fmi2ValueReference vr[],
                            size_t nvr, const fmi2Boolean value[]);

/**
 * \brief Set String values.
 * 
 * @param c The FMU struct.
 * @param vr Array of value-references.
 * @param nvr Number of array elements.
 * @param value Array of variable values.
 * @return Error code.
 */
fmi2Status fmi2_set_string(fmi2Component c, const fmi2ValueReference vr[],
                          size_t nvr, const fmi2String value[]);


/**
 * \brief Get a copy of the FMU state.
 * 
 * @param c The FMU struct.
 * @param FMUstate (Output) A pointer to the FMU state.
 * @return Error code.
 */
fmi2Status fmi2_get_fmu_state(fmi2Component c, fmi2FMUstate* FMUstate);

/**
 * \brief Set the FMU state.
 * 
 * @param c The FMU struct.
 * @param FMUstate The FMU state.
 * @return Error code.
 */
fmi2Status fmi2_set_fmu_state(fmi2Component c, fmi2FMUstate FMUstate);

/**
 * \brief Free a FMU state.
 * 
 * @param c The FMU struct.
 * @param FMUstate A pointer to a FMU state.
 * @return Error code.
 */
fmi2Status fmi2_free_fmu_state(fmi2Component c, fmi2FMUstate* FMUstate);

/**
 * \brief Get the size of a byte vector needed for storing the FMU state.
 * 
 * @param c The FMU struct.
 * @param FMUstate A FMU state.
 * @param size (Output) The size of the FMU state. 
 * @return Error code.
 */
fmi2Status fmi2_serialized_fmu_state_size(fmi2Component c, fmi2FMUstate FMUstate,
                                          size_t* size);

/**
 * \brief Serialize a FMU state into a byte vector.
 * 
 * @param c The FMU struct.
 * @param FMUstate A FMU state.
 * @param serializedState (Output) The FMU state serialized.
 * @param size The size of the FMU state. 
 * @return Error code.
 */
fmi2Status fmi2_serialize_fmu_state(fmi2Component c, fmi2FMUstate FMUstate,
                                    fmi2Byte serializedState[], size_t size);

/**
 * \brief Deserialize a byte vector into a FMU state.
 * 
 * @param c The FMU struct.
 * @param serializedState The FMU state serialized.
 * @param size The size of the FMU state.
 * @param FMUstate (Output) A FMU state.
 * @return Error code.
 */
fmi2Status fmi2_de_serialize_fmu_state(fmi2Component c,
                                       const fmi2Byte serializedState[],
                                       size_t size, fmi2FMUstate* FMUstate);

/**
 * \brief Evaluate directional derivative of ODE.
 *
 * @param c An FMU instance.
 * @param vUnknown_ref Value references of the directional derivative result
 *                     vector dz. These are defined by a subset of the
 *                     derivative and output variable value references.
 * @param nUnknown Size of z_vref vector.
 * @param vKnown_ref Value reference of the input seed vector dv. These 
 *                   are defined by a subset of the state and input
 *                   variable value references.
 * @param nKnown Size of v_vref vector.
 * @param dvKnown Input argument containing the input seed vector.
 * @param dvUnknown Output argument containing the directional derivative vector.
 * @return Error code.
 */
fmi2Status fmi2_get_directional_derivative(fmi2Component c,
                const fmi2ValueReference vUnknown_ref[], size_t nUnknown,
                const fmi2ValueReference vKnown_ref[],   size_t nKnown,
                const fmi2Real dvKnown[], fmi2Real dvUnknown[]);

 /* @} */

/**
 * \defgroup The Model Exchange public functions for FMI 2.0.
 * 
 * \brief Definitions of the functions for Model Exchange.
 */
 
 /* @{ */


/**
 * \brief Makes the simulation go into event mode.
 * 
 * @param c The FMU struct.
 * @return Error code.
 */
fmi2Status fmi2_enter_event_mode(fmi2Component c);

/**
 * \brief Updates the FMU after an event. Does one event iteration.
 * 
 * @param c The FMU struct.
 * @param eventInfo (Output) An fmi2EventInfo struct.
 * @return Error code.
 */
fmi2Status fmi2_new_discrete_state(fmi2Component  c,
                                   fmi2EventInfo* fmiEventInfo);

/**
 * \brief Makes the simulation go into continuous time mode.
 * 
 * @param c The FMU struct.
 * @return Error code.
 */
fmi2Status fmi2_enter_continuous_time_mode(fmi2Component c);

/**
 * \brief Checks for step-events, can flush old FMU states and can terminate the simulation.
 * 
 * @param c The FMU struct.
 * @param noSetFMUStatePriorToCurrentPoint A fmi2Boolean, can be used to 
 *                                         flush earlier saved FMU states.
 * @param enterEventMode (Output) A fmi2Boolean.
 * @param terminateSimulation (Output) A fmi2Boolean.
 * @return Error code.
 */
fmi2Status fmi2_completed_integrator_step(fmi2Component c,
                                          fmi2Boolean   noSetFMUStatePriorToCurrentPoint, 
                                          fmi2Boolean*  enterEventMode, 
                                          fmi2Boolean*  terminateSimulation);

/**
 * \brief Set the current time.
 * 
 * @param c The FMU struct.
 * @param time The current time.
 * @return Error code.
 */
fmi2Status fmi2_set_time(fmi2Component c, fmi2Real time);

/**
 * \brief Set the current states.
 * 
 * @param c The FMU struct.
 * @param x Array of state values.
 * @param nx Number of states.
 * @return Error code.
 */
fmi2Status fmi2_set_continuous_states(fmi2Component c, const fmi2Real x[],
                                      size_t nx);

/**
 * \brief Calculates the derivatives.
 * 
 * @param c The FMU struct.
 * @param derivatives (Output) Array of the derivatives.
 * @param nx Number of derivatives.
 * @return Error code.
 */
fmi2Status fmi2_get_derivatives(fmi2Component c, fmi2Real derivatives[], size_t nx);

/**
 * \brief Get the event indicators (for state-events)
 * 
 * @param c The FMU struct.
 * @param eventIndicators (Output) The event indicators.
 * @param ni Number of event indicators.
 * @return Error code.
 */
fmi2Status fmi2_get_event_indicators(fmi2Component c, 
                                     fmi2Real eventIndicators[], size_t ni);
/**
 * \brief Get the current states.
 * 
 * @param c The FMU struct.
 * @param x (Output) Array of state values.
 * @param nx Number of states.
 * @return Error code.
 */
fmi2Status fmi2_get_continuous_states(fmi2Component c, fmi2Real x[], size_t nx);

/**
 * \brief Get the nominal values of the states.
 * 
 * @param c The FMU struct.
 * @param x_nominal (Output) The nominal values.
 * @param nx Number of nominal values.
 * @return Error code.
 */
fmi2Status fmi2_get_nominals_of_continuous_states(fmi2Component c, 
                                                  fmi2Real x_nominal[], 
                                                  size_t nx);

 /* @} */

/**
 * The Global Unique IDentifier is used to check that the XML file is compatible with the C functions.
 */
extern const char *C_GUID;

/**
 * \brief Instantiates the ME FMU, helper function for fmi2_instantiate.
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
fmi2Status fmi2_me_instantiate(fmi2Component c,
                               fmi2String    instanceName,
                               fmi2Type      fmuType, 
                               fmi2String    fmuGUID, 
                               fmi2String    fmuResourceLocation, 
                               const fmi2CallbackFunctions* functions, 
                               fmi2Boolean                  visible,
                               fmi2Boolean                  loggingOn);

/**
 * \brief Dispose of the ME model instance, helper function for fmi2_free_instance.
 * 
 * @param c The FMU struct.
 */
void fmi2_me_free_instance(fmi2Component c);

#endif
