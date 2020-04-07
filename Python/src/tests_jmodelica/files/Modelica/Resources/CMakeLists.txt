#    Copyright (C) 2014 Modelon AB

#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License version 3 as published
#    by the Free Software Foundation, or optionally, under the terms of the
#    Common Public License version 1.0 as published by IBM.

#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License, or the Common Public License, for more details.

#    You should have received copies of the GNU General Public License
#    and the Common Public License along with this program.  If not,
#    see <http://www.gnu.org/licenses/> or
#    <http://www.ibm.com/developerworks/library/os-cpl.html/> respectively.

# NOTE: CMake 2.8.6 is required since this is the version used in development.
# The script is KNOWN NOT TO WORK WITH 2.8.3 and below (ExternalProject 
# interface changes). CMake 2.8.4 and 2.8.5 are not tested.
cmake_minimum_required (VERSION 2.8.6 FATAL_ERROR)

project (TestLibraries)

#Make the directory for header files to be installed in. 
install(CODE "file(MAKE_DIRECTORY $ENV{DESTDIR}${JMODELICA_INSTALL_DIR}/Python/tests_jmodelica/files/Modelica/Resources/Include/)")

#Make the directory for lib files to be installed in.
if(" ${JM_PLATFORM} " MATCHES " win64 ")
    set(TEST_LIBRARY_INSTALL_DIR ${JMODELICA_INSTALL_DIR}/Python_64/tests_jmodelica/files/Modelica/Resources/Library/${JM_PLATFORM})
else ()
    set(TEST_LIBRARY_INSTALL_DIR ${JMODELICA_INSTALL_DIR}/Python/tests_jmodelica/files/Modelica/Resources/Library/${JM_PLATFORM})
endif ()
install(CODE "file(MAKE_DIRECTORY  $ENV{DESTDIR}${TEST_LIBRARY_INSTALL_DIR})")

#Add test libraries
include_directories(Include)
include_directories(${TOP_SRC}/RuntimeLibrary/src/jmi)

set(ADDNUMBERS_Sources
    src/addNumbers.c
    Include/addNumbers.h
)

set(ARRAYFUNCTIONS_Sources
    src/arrayFunctions.c
    Include/arrayFunctions.h
)

set(EXTERNALFUNCTIONSC_Sources
    src/externalFunctionsC.c
    Include/externalFunctionsC.h
)

set(EXTOBJECTS_Sources
    src/extObjects.c
    Include/extObjects.h
)

set(USEMODELICAERROR_Sources
    src/useModelicaError.c
    Include/useModelicaError.h
)

#Don't build Fortran lib if MSVC
if(NOT MSVC)
    set(EXTERNALFUNCTIONSFORTRAN_Sources
        src/externalFunctionsFortran.f
    )
endif()

#Build addNumbers library
add_library(addNumbers STATIC ${ADDNUMBERS_Sources})
if(NOT MSVC)
    set_target_properties(addNumbers PROPERTIES COMPILE_FLAGS "-Wall -g -std=c89 -pedantic -Werror -O2")
endif()

#Build arrayFunctions library
add_library(arrayFunctions STATIC ${ARRAYFUNCTIONS_Sources})
if(NOT MSVC)
    set_target_properties(arrayFunctions PROPERTIES COMPILE_FLAGS "-Wall -g -std=c89 -pedantic -Werror -O2")
endif()

#Build externalFunctionsC library
add_library(externalFunctionsC STATIC ${EXTERNALFUNCTIONSC_Sources})
if(NOT MSVC)
    set_target_properties(externalFunctionsC PROPERTIES COMPILE_FLAGS "-Wall -g -std=c89 -pedantic -Werror -O2")
endif()

#Build extObjects library
add_library(extObjects STATIC ${EXTOBJECTS_Sources})
if(NOT MSVC)
    set_target_properties(extObjects PROPERTIES COMPILE_FLAGS "-Wall -g -std=c89 -pedantic -Werror -O2")
endif()

#Build useModelicaError library
add_library(useModelicaError STATIC ${USEMODELICAERROR_Sources})
if(NOT MSVC)
    set_target_properties(useModelicaError PROPERTIES COMPILE_FLAGS "-Wall -g -std=c89 -pedantic -Werror -O2")
endif()

#Build externalFunctionsFortran library (if not MSVC)
if(NOT MSVC)
    add_library(externalFunctionsFortran STATIC ${EXTERNALFUNCTIONSFORTRAN_Sources})
endif()

#Install the libraries
install(TARGETS addNumbers DESTINATION "${TEST_LIBRARY_INSTALL_DIR}")
install(TARGETS arrayFunctions DESTINATION "${TEST_LIBRARY_INSTALL_DIR}")
install(TARGETS externalFunctionsC DESTINATION "${TEST_LIBRARY_INSTALL_DIR}")
install(TARGETS extObjects DESTINATION "${TEST_LIBRARY_INSTALL_DIR}")
install(TARGETS useModelicaError DESTINATION "${TEST_LIBRARY_INSTALL_DIR}")
if(NOT MSVC)
    install(TARGETS externalFunctionsFortran DESTINATION "${TEST_LIBRARY_INSTALL_DIR}")
endif()