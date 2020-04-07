/*
    Copyright (C) 2013-2018 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the Common Public License as published by
    IBM, version 1.0 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY. See the Common Public License for more details.

    You should have received a copy of the Common Public License
    along with this program. If not, see
    <http://www.ibm.com/developerworks/library/os-cpl.html/>.
*/

/* Run-time. */
#include "stdio.h"
#include "stdlib.h"
#include "math.h"
#include "jmi.h"
#include "ModelicaUtilities.h"
#include "ModelicaStandardTables.h"

#include "fmi2_me.h"
#include "fmi2_cs.h"
#include "fmi2Functions.h"
#include "fmi2FunctionTypes.h"
#include "fmi2TypesPlatform.h"

/* Helper function for instantiating the FMU. */
int can_instantiate(fmi2Type fmuType, fmi2String instanceName,
                    const fmi2CallbackFunctions* functions) {
    if (fmuType == fmi2CoSimulation) {
#ifndef FMUCS20
        functions->logger(0, instanceName, fmi2Error, "ERROR", "The model is not compiled as a Co-Simulation FMU.");
        return 0;
#endif
    } else if (fmuType == fmi2ModelExchange) {
#ifndef FMUME20
        functions->logger(0, instanceName, fmi2Error, "ERROR", "The model is not compiled as a Model Exchange FMU.");
        return 0;
#endif
    }
    return 1;
}

/* FMI Funcitons. */
$INCLUDE: fmi2_functions_common_template.c$
#ifdef FMUME20
$INCLUDE: fmi2_functions_me_template.c$
#endif
#ifdef FMUCS20
$INCLUDE: fmi2_functions_cs_template.c$
#endif
