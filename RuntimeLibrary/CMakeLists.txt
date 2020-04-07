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

project (SimulationRuntime)

#Inputs through flags
add_definitions(-DTOP_SRC)
add_definitions(-DSUNDIALS_HOME)
add_definitions(-DMINPACK_HOME)
if(NOT TOP_SRC)
    set(TOP_SRC ${CMAKE_CURRENT_SOURCE_DIR}/../)
    message(STATUS "TOP_SRC was not defined, using ${TOP_SRC}")
endif()

if(NOT MINPACK_HOME)
    set(MINPACK_HOME ${TOP_SRC}/ThirdParty/Minpack/cminpack-1.3.2/)
    message(STATUS "MINPACK_HOME was not defined, using ${MINPACK_HOME}")
endif()
include_directories(${MINPACK_HOME})

# Get the JModelica install directory
if(CMAKE_INSTALL_DIR)
    set(JMODELICA_INSTALL_DIR ${CMAKE_INSTALL_DIR})
else()
    set(JMODELICA_INSTALL_DIR ${TOP_SRC}/../install)
    message(STATUS "Install dir not defined, using ${JMODELICA_INSTALL_DIR}")
endif()    
message(STATUS JMODELICA_INSTALL_DIR=${JMODELICA_INSTALL_DIR})

#Make the directory for header files to be installed in.
set(RTLIB_INCLUDE_DIR ${JMODELICA_INSTALL_DIR}/include/RuntimeLibrary)
install(CODE "file(MAKE_DIRECTORY $ENV{DESTDIR}${RTLIB_INCLUDE_DIR})")
                
#Make the directory for lib files to be installed in.
# Add spaces around CMAKE_C_FLAGS so that we can check for " -m64 " with spaces around it
if(" ${CMAKE_C_FLAGS} " MATCHES " -m64 ")
    set(RTLIB_LIB_DIR ${JMODELICA_INSTALL_DIR}/lib/RuntimeLibrary64)
else()
    set(RTLIB_LIB_DIR ${JMODELICA_INSTALL_DIR}/lib/RuntimeLibrary)
endif()
install(CODE "file(MAKE_DIRECTORY $ENV{DESTDIR}${RTLIB_LIB_DIR})")

if(NOT(WIN32 OR CYGWIN OR APPLE))
    SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${CMAKE_SHARED_LIBRARY_C_FLAGS}")
    SET(WITH_PIC ON)
elseif(MSVC)
    add_definitions(/D _CRT_SECURE_NO_WARNINGS)
endif()

#Including Sundials.
message(STATUS SUNDIALS_HOME=${SUNDIALS_HOME})
include_directories(${SUNDIALS_HOME}/include)

set(RuntimeLibrary_BUILD ${SimulationRuntime_BINARY_DIR})

#Add jmi
add_subdirectory(src/jmi)

#Add fmi2
include_directories(src/jmi)
add_subdirectory(src/fmi2)

#Add fmi1_me
add_subdirectory(src/fmi1_me)

#Add fmi1_cs
include_directories(src/fmi1_me)
add_subdirectory(src/fmi1_cs)

#Add modules
include_directories(src/jmi/module_include)
add_subdirectory(src/modules)


if(EXTRA_RUNTIME_MODULES)
    set(index 1)
    foreach(module ${EXTRA_RUNTIME_MODULES})
        add_subdirectory(${module} "extra${index}")
        math(EXPR index "${index}+1")
    endforeach()
endif()

