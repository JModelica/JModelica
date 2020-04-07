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

project (Python)

#Enable Fortran if not MSVC
if(NOT MSVC)
  enable_language(Fortran)
else()
  message(STATUS "No Fortran support")
endif()

#Inputs through flags
add_definitions(-DTOP_SRC)
if(NOT TOP_SRC)
    set(TOP_SRC ${CMAKE_CURRENT_SOURCE_DIR}/../)
    message(STATUS "TOP_SRC was not defined, using ${TOP_SRC}")
endif()

# Get the JModelica install directory
if(CMAKE_INSTALL_DIR)
    set(JMODELICA_INSTALL_DIR ${CMAKE_INSTALL_DIR})
else()
    set(JMODELICA_INSTALL_DIR "${TOP_SRC}/../install")
    message(STATUS "Install dir not defined, using ${JMODELICA_INSTALL_DIR}")
endif()    
message(STATUS JMODELICA_INSTALL_DIR=${JMODELICA_INSTALL_DIR})

# Get platform information
if(CMAKE_HOST_WIN32) #Set to true when the host system is Windows and on cygwin.
    set(JM_PLATFORM win)
elseif(CMAKE_HOST_APPLE) #Set to true when the host system is Apple OSX. 
    set(JM_PLATFORM darwin)
elseif(CMAKE_HOST_UNIX) #Set to true when the host system is UNIX or UNIX like (i.e. APPLE and CYGWIN). 
    set(JM_PLATFORM linux)
else(CMAKE_HOST_WIN32)
    message(SEND_ERROR "Target platform is not supported by the tests")
set(JM_PLATFORM not_supported)
endif()
if(" ${CMAKE_C_FLAGS} " MATCHES " -m64 ")
    set(JM_PLATFORM "${JM_PLATFORM}64")
elseif(" ${CMAKE_C_FLAGS} " MATCHES " -m32 ")
    set(JM_PLATFORM "${JM_PLATFORM}32")
elseif(CMAKE_SIZEOF_VOID_P EQUAL 4)
    set(JM_PLATFORM "${JM_PLATFORM}32")
else()
    set(JM_PLATFORM "${JM_PLATFORM}64")
endif()

if(NOT(WIN32 OR CYGWIN OR APPLE))
    SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${CMAKE_SHARED_LIBRARY_C_FLAGS}")
    SET(WITH_PIC ON)
elseif(MSVC)
    set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} /MT")
    set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} /MTd")
    add_definitions(/D _CRT_SECURE_NO_WARNINGS)
endif()

add_subdirectory(src/tests_jmodelica/files/Modelica/Resources)
add_subdirectory(src/pyjmi/examples/files/Resources)
