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

if(NOT TOP_SRC)
    set(TOP_SRC ${CMAKE_CURRENT_SOURCE_DIR}/../../../)
    message(STATUS "TOP_SRC was not defined, using ${TOP_SRC}")
endif()
set(MSLCSOURCES ${TOP_SRC}/ThirdParty/MSL/Modelica/Resources/C-Sources)
message(STATUS MSLCSOURCES=${MSLCSOURCES})

set(JMICommonSources
    # Types
    jmi_types.h
    jmi_types.c
    
    # Math
    jmi_linear_algebra.h
    jmi_linear_algebra.c
    
    # Logging sources
    jmi_callbacks.h
    jmi_log.h
    jmi_log_impl.h
    jmi_log.c
)

set(JMIBlockSourcesPartial
    jmi_block_solver.h
    jmi_block_solver_impl.h
    jmi_block_log.h
    jmi_kinsol_solver.h
    jmi_brent_solver.h
    jmi_minpack_solver.h
    jmi_linear_solver.h
    jmi_realtime_solver.h
    jmi_simple_newton.h

    jmi_block_solver.c
    jmi_block_log.c
    jmi_kinsol_solver.c
    jmi_brent_solver.c
    jmi_minpack_solver.c
    jmi_linear_solver.c
    jmi_realtime_solver.c
    jmi_simple_newton.c
)

set(JMIODESolverSourcesPartial
    jmi_ode_cvode.h
    jmi_ode_euler.h
    jmi_ode_solver.h
    jmi_ode_solver_impl.h
    jmi_ode_problem.h
    
    jmi_ode_cvode.c
    jmi_ode_euler.c
    jmi_ode_solver.c
    jmi_ode_problem.c
)

set(JMIBlockSources     ${JMIBlockSourcesPartial}     ${JMICommonSources})
set(JMIODESolverSources ${JMIODESolverSourcesPartial} ${JMICommonSources})

set(JMISources   
    jmi.h
    jmi_array_none.h
    jmi_block_residual.h
    jmi_cs.h
    jmi_me.h
    jmi_util.h
    jmi_global.h
    jmi_delay.h
    jmi_delay_impl.h
    jmi_dynamic_state.h
    jmi_chattering.h
    jmi_work_array.h
    jmi_math.h
    jmi_math_ad.h
    jmi_types.h
    
    jmi_util.c
    jmi_global.c
    jmi.c
    jmi_array_none.c
    jmi_types.c
    jmi_dyn_mem.c
    jmi_dyn_mem_.c
    jmi_block_residual.c
    jmi_cs.c
    jmi_me.c
    jmi_delay.c
    jmi_dynamic_state.c
    jmi_chattering.c
    jmi_work_array.c
    jmi_math.c
    jmi_math_ad.c
    
    ${JMICommonSources}
    ${JMIBlockSourcesPartial}
    ${JMIODESolverSourcesPartial}
)

# Source files for ModelicaExternalC
set(MODELICAEXTERNALCSources
    jmi_global.h
    ModelicaUtilities.h
    
    jmi_global.c
    ModelicaUtilities.c
    
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

include_directories(module_include)

if(WIN32)
    #Flag that is needed for compiling lib togheter with MINPACK, no dll is created.
    add_definitions(-DCMINPACK_NO_DLL)
endif()
add_definitions(-DJMI_INCLUDE_MINPACK)

OPTION(BUILD_BLOCK_SOLVER_LIB "Build the block solver library" ON)
if (${BUILD_BLOCK_SOLVER_LIB})
    add_library(jmi_block_solver STATIC ${JMIBlockSources})
    if(NOT MSVC)
        set_target_properties(jmi_block_solver PROPERTIES COMPILE_FLAGS "-Wall -g -std=c89 -pedantic -Werror -Wno-long-long -O2 -msse2 -mfpmath=sse")
    endif()
    
    #Install the libraries
    install(TARGETS jmi_block_solver
        DESTINATION "${RTLIB_LIB_DIR}")
    
    if(JMI_SUNDIALS AND JMI_LAPACK AND JMI_MINPACK)
        add_executable(jmi_block_solver_test jmi_block_solver_test.c)
        target_link_libraries(jmi_block_solver_test jmi_block_solver ${JMI_SUNDIALS} ${JMI_LAPACK} ${JMI_MINPACK})
        add_test(NAME jmi_block_solver_test COMMAND jmi_block_solver_test)
    endif()
endif()

OPTION(BUILD_ODE_SOLVER_LIB "Build the ode solver library" ON)
if (${BUILD_ODE_SOLVER_LIB})
    add_library(jmi_ode_solver STATIC ${JMIODESolverSources})
    if(NOT MSVC)
        set_target_properties(jmi_ode_solver PROPERTIES COMPILE_FLAGS "-Wall -g -std=c89 -pedantic -Werror -Wno-long-long -O2 -msse2 -mfpmath=sse")
    endif()
    
    if(JMI_SUNDIALS)
        add_executable(jmi_ode_solver_test jmi_ode_solver_test.c)
        target_link_libraries(jmi_ode_solver_test jmi_ode_solver ${JMI_SUNDIALS})
        add_test(NAME jmi_ode_solver_test COMMAND jmi_ode_solver_test)
    endif()
endif()

OPTION(BUILD_JMI_LIB "Build the jmi library" ON)
if (${BUILD_JMI_LIB})
    add_library(jmi STATIC ${JMISources})
    if(NOT MSVC)
        set_target_properties(jmi PROPERTIES COMPILE_FLAGS "-Wall -g -std=c89 -pedantic -Werror -Wno-long-long -O2 -msse2 -mfpmath=sse")
    endif()
    include_directories(${TOP_SRC}/RuntimeLibrary/src/jmi)

    #Install the libraries
    install(TARGETS jmi
        DESTINATION "${RTLIB_LIB_DIR}")

    #Install header files
    install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/"
        DESTINATION "${RTLIB_INCLUDE_DIR}"
        FILES_MATCHING PATTERN "*.h")
endif()

OPTION(BUILD_MSL_EXTERNAL_LIBS "Build the MSL external libraries" ON)
if (${BUILD_MSL_EXTERNAL_LIBS})
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

    #Install the libraries
    install(TARGETS ModelicaExternalC ModelicaStandardTables ModelicaIO ModelicaMatIO zlib
        DESTINATION "${RTLIB_LIB_DIR}")

    install(DIRECTORY "${MSLCSOURCES}/"
        DESTINATION "${RTLIB_INCLUDE_DIR}"
        FILES_MATCHING PATTERN "*.h")
endif()

