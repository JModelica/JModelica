#    Copyright (C) 2018 Modelon AB, all rights reserved.

cmake_minimum_required (VERSION 2.8.6 FATAL_ERROR)

#Inputs through flags
add_definitions(-DTOP_SRC)
add_definitions(-DMSL_DIR)
option(WITH_TDM "WITH_TDM" OFF)

# Get the JModelica install directory
if(CMAKE_INSTALL_DIR)
    set(JMODELICA_INSTALL_DIR ${CMAKE_INSTALL_DIR})
else()
    set(JMODELICA_INSTALL_DIR ${TOP_SRC}/../install)
    message(STATUS "Install dir not defined, using ${JMODELICA_INSTALL_DIR}")
endif() 
set(RTLIB_INCLUDE_DIR ${JMODELICA_INSTALL_DIR}/include/RuntimeLibrary)
set(MSLCSOURCES ${TOP_SRC}/ThirdParty/MSL/Modelica/Resources/C-Sources)
set(MSLRESOURCES ${MSL_DIR}/Modelica/Resources/Library)


set(JMI_JMODELICA_SRC_DIR ${TOP_SRC}/RuntimeLibrary)

# Source files for ModelicaExternalC
set(MODELICAEXTERNALCSources
    ${JMI_JMODELICA_SRC_DIR}/src/jmi/jmi_global.h
    ${JMI_JMODELICA_SRC_DIR}/src/jmi/ModelicaUtilities.h
    
    ${JMI_JMODELICA_SRC_DIR}/src/jmi/jmi_global.c
    ${JMI_JMODELICA_SRC_DIR}/src/jmi/ModelicaUtilities.c
    
    ${MSLCSOURCES}/ModelicaInternal.c
    ${MSLCSOURCES}/ModelicaStrings.c
    ${MSLCSOURCES}/ModelicaRandom.c
    ${MSLCSOURCES}/ModelicaFFT.c
)

# Source files for Zlib
set(ZLIB_SOURCES
    ${MSLCSOURCES}/zlib/adler32.c
    ${MSLCSOURCES}/zlib/compress.c
    ${MSLCSOURCES}/zlib/crc32.c
    ${MSLCSOURCES}/zlib/deflate.c
    ${MSLCSOURCES}/zlib/gzclose.c
    ${MSLCSOURCES}/zlib/gzlib.c
    ${MSLCSOURCES}/zlib/gzread.c
    ${MSLCSOURCES}/zlib/gzwrite.c
    ${MSLCSOURCES}/zlib/infback.c
    ${MSLCSOURCES}/zlib/inffast.c
    ${MSLCSOURCES}/zlib/inflate.c
    ${MSLCSOURCES}/zlib/inftrees.c
    ${MSLCSOURCES}/zlib/trees.c
    ${MSLCSOURCES}/zlib/uncompr.c
    ${MSLCSOURCES}/zlib/zutil.c
)



if(NOT MSVC)
else()
    
	# With C89 we're forced to use non-secure functions
	ADD_DEFINITIONS (/D _CRT_SECURE_NO_WARNINGS)
    
    # Force linking with static run-time library
	set(replace_from "/MD")
	set(replace_to "/MT")
	foreach(flag_var
		CMAKE_CXX_FLAGS CMAKE_CXX_FLAGS_DEBUG CMAKE_CXX_FLAGS_RELEASE
		CMAKE_CXX_FLAGS_MINSIZEREL CMAKE_CXX_FLAGS_RELWITHDEBINFO
		CMAKE_C_FLAGS CMAKE_C_FLAGS_DEBUG CMAKE_C_FLAGS_RELEASE
		CMAKE_C_FLAGS_MINSIZEREL CMAKE_C_FLAGS_RELWITHDEBINFO)
		if(${${flag_var}} MATCHES "${replace_from}")
			string(REPLACE "${replace_from}" "${replace_to}" tmp "${${flag_var}}")
			set(${flag_var} ${tmp} CACHE STRING "compiler flags" FORCE)
		endif()
	endforeach(flag_var)
    
    # disable incremental linking that prevents DLLs from being loaded with LoadLibrary
	foreach(flag_var
			CMAKE_MODULE_LINKER_FLAGS_DEBUG CMAKE_MODULE_LINKER_FLAGS_RELWITHDEBINFO
			CMAKE_SHARED_LINKER_FLAGS_DEBUG CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO)
			string(REPLACE "/INCREMENTAL:NO" " " tmp "${${flag_var}}")
			string(REPLACE "/INCREMENTAL:YES" " " tmp "${tmp}")
			string(REPLACE "/INCREMENTAL" " " tmp "${tmp}")
			set(${flag_var} "${tmp} /INCREMENTAL:NO" CACHE STRING "linker flags" FORCE)
	endforeach(flag_var)
endif()

if(NOT MSVC)
    if (WIN32)
        include_directories(${TOP_SRC}/ThirdParty/pthreads/include)
    endif()
endif()

#Build ModelicaExternalC library
include_directories(${MSLCSOURCES})
include_directories(${MSLCSOURCES}/zlib)
add_library(ModelicaExternalC STATIC ${MODELICAEXTERNALCSources})
if(NOT MSVC)
    set_target_properties(ModelicaExternalC PROPERTIES COMPILE_FLAGS "-Wall -g -std=c89 -pedantic")
endif()

#Build ModelicaStandardTables library
add_definitions("-DDUMMY_FUNCTION_USERTAB -DHAVE_ZLIB")
add_library(ModelicaStandardTables STATIC ${MSLCSOURCES}/ModelicaStandardTables.c)
if(NOT MSVC)
    set_target_properties(ModelicaStandardTables PROPERTIES COMPILE_FLAGS "-Wall -g")
endif()

#Build ModelicaIO library
add_library(ModelicaIO STATIC ${MSLCSOURCES}/ModelicaIO.c)
if(NOT MSVC)
    set_target_properties(ModelicaIO PROPERTIES COMPILE_FLAGS "-Wall -g")
endif()

#Build ModelicaMatIO library
add_library(ModelicaMatIO STATIC ${MSLCSOURCES}/ModelicaMatIO.c)
if(NOT MSVC)
    set_target_properties(ModelicaMatIO PROPERTIES COMPILE_FLAGS "-Wall -g")
endif()

#Build Zlib library
add_library(zlib STATIC ${ZLIB_SOURCES})
if(NOT MSVC)
    set_target_properties(ModelicaStandardTables PROPERTIES COMPILE_FLAGS "-Wall -g")
endif()

if(" ${CMAKE_C_FLAGS} " MATCHES " -m64 ")
    set(BITS 64)
elseif(" ${CMAKE_C_FLAGS} " MATCHES " -m32 ")
    set(BITS 32)
else()
    if(CMAKE_SIZEOF_VOID_P EQUAL 4)
        set(BITS 32)
    else()
        set(BITS 64)
    endif()
endif()


if(CMAKE_HOST_WIN32) #Set to true when the host system is Windows and on cygwin.
    set(FMI_PLATFORM win)
elseif(CMAKE_HOST_APPLE) #Set to true when the host system is Apple OSX. 
    set(FMI_PLATFORM darwin)
elseif(CMAKE_HOST_UNIX) #Set to true when the host system is UNIX or UNIX like (i.e. APPLE and CYGWIN). 
    set(FMI_PLATFORM linux)
else(CMAKE_HOST_WIN32)
    message(SEND_ERROR "Target platform is not supported")
    set(FMI_PLATFORM not_supported)
endif()
set(FMI_PLATFORM "${FMI_PLATFORM}${BITS}")

if(MSVC)
    if(MSVC_VERSION EQUAL 1500)
        set(SUB_DIR "vs2008")
    elseif(MSVC_VERSION EQUAL 1600)
        set(SUB_DIR "vs2010")
    elseif(MSVC_VERSION EQUAL 1700)
        set(SUB_DIR "vs2012")
    elseif(MSVC_VERSION EQUAL 1800)
        set(SUB_DIR "vs2013")
    elseif(MSVC_VERSION EQUAL 1900)
        set(SUB_DIR "vs2015")
    elseif(MSVC_VERSION EQUAL 1910)
        set(SUB_DIR "vs2017")
    endif()
else()
    if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
        set(SUB_DIR "gcc")
        if(WITH_TDM)
            set(SUB_DIR "${SUB_DIR}tdm")
        endif()
        string(REPLACE "." "" GCC_VERSION "${CMAKE_CXX_COMPILER_VERSION}")
        set(SUB_DIR "${SUB_DIR}${GCC_VERSION}")
    else()
        set(SUB_DIR "")
    endif()        
endif()

message(STATUS MSLResourcesDestination="${MSLRESOURCES}/${FMI_PLATFORM}/${SUB_DIR}")
#Install the libraries
install(TARGETS ModelicaExternalC ModelicaStandardTables ModelicaIO ModelicaMatIO zlib
    DESTINATION "${MSLRESOURCES}/${FMI_PLATFORM}/${SUB_DIR}")

install(DIRECTORY "${MSLCSOURCES}/"
    DESTINATION "${RTLIB_INCLUDE_DIR}"
    FILES_MATCHING PATTERN "*.h")