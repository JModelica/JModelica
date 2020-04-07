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

set(FMI_CSSources

    fmiCSFunctions.h
	fmiCSPlatformTypes.h
    fmi1_cs.h
    
    fmi1_cs.c
)

#Build fmi_cs library
add_library(fmi1_cs STATIC ${FMI_CSSources})
if(NOT MSVC)
    set_target_properties(fmi1_cs PROPERTIES COMPILE_FLAGS "-Wall -g -std=c89 -pedantic -Werror -O2")
endif()

#Install the libraries
install(TARGETS fmi1_cs DESTINATION "${RTLIB_LIB_DIR}")

#Install header files
install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/"
    DESTINATION "${RTLIB_INCLUDE_DIR}"
    FILES_MATCHING PATTERN "*.h")
