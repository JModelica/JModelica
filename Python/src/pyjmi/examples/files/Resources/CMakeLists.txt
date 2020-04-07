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

project (pyjmi_TestLibraries)

#Make the directory for header files to be installed in.
if( " ${JM_PLATFORM} " MATCHES " win64 ")
install(CODE "file(MAKE_DIRECTORY $ENV{DESTDIR}${JMODELICA_INSTALL_DIR}/Python_64/pyjmi/examples/files/Resources/Include/)")
else () 
install(CODE "file(MAKE_DIRECTORY $ENV{DESTDIR}${JMODELICA_INSTALL_DIR}/Python/pyjmi/examples/files/Resources/Include/)")
endif ()

#Make the directory for lib files to be installed in.
if( " ${JM_PLATFORM} " MATCHES " win64 ")
set(TEST_LIBRARY_INSTALL_DIR ${JMODELICA_INSTALL_DIR}/Python_64/pyjmi/examples/files/Resources/Library/${JM_PLATFORM})
else ()
set(TEST_LIBRARY_INSTALL_DIR ${JMODELICA_INSTALL_DIR}/Python/pyjmi/examples/files/Resources/Library/${JM_PLATFORM})
endif ()
install(CODE "file(MAKE_DIRECTORY  $ENV{DESTDIR}${TEST_LIBRARY_INSTALL_DIR})")

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

#Build addNumbers library
add_library(pyjmi_addNumbers STATIC ${ADDNUMBERS_Sources})
set_target_properties(pyjmi_addNumbers PROPERTIES OUTPUT_NAME addNumbers)
if(NOT MSVC)
    set_target_properties(pyjmi_addNumbers PROPERTIES COMPILE_FLAGS "-Wall -g -std=c89 -pedantic -Werror -O2")
endif()

#Build arrayFunctions library
add_library(pyjmi_arrayFunctions STATIC ${ARRAYFUNCTIONS_Sources})
set_target_properties(pyjmi_arrayFunctions PROPERTIES OUTPUT_NAME arrayFunctions)
if(NOT MSVC)
    set_target_properties(pyjmi_arrayFunctions PROPERTIES COMPILE_FLAGS "-Wall -g -std=c89 -pedantic -Werror -O2")
endif()

#Install the libraries
install(TARGETS pyjmi_addNumbers DESTINATION "${TEST_LIBRARY_INSTALL_DIR}")
install(TARGETS pyjmi_arrayFunctions DESTINATION "${TEST_LIBRARY_INSTALL_DIR}")
