cmake_minimum_required(VERSION 2.8.6)
project(ModelicaCasADi CXX)


set(Python_ADDITIONAL_VERSIONS 2.7 2.6 2.5 2.4)

if(" ${CMAKE_CXX_FLAGS} " MATCHES " -m64 " AND CMAKE_HOST_WIN32)
    add_definitions(-DMS_WIN64)
    message(STATUS "Adding MS_WIN64 definition")
endif()

function(make_paths_absolute DEST_VAR DIRS)  
  set(ABS_DIRS "")
  foreach(DIR ${DIRS})
    get_filename_component(ABS_DIR ${DIR} ABSOLUTE)
    list(APPEND ABS_DIRS ${ABS_DIR})
  endforeach(DIR)
  set(${DEST_VAR} "${ABS_DIRS}" PARENT_SCOPE)
endfunction()

function(join OUTPUT GLUE VALUES)
  string (REPLACE ";" "${GLUE}" _TMP_STR "${VALUES}")
  set (${OUTPUT} "${_TMP_STR}" PARENT_SCOPE)
endfunction()

function(interleave_string_and_list DEST_VAR STRING)  
  set(RESULT "")
  foreach(ITEM ${ARGN})
    list(APPEND RESULT ${STRING} ${ITEM})
  endforeach(ITEM)
  set(${DEST_VAR} "${RESULT}" PARENT_SCOPE)
endfunction()

function(interleave_string_and_list DEST_VAR STRING)  
  set(RESULT "")
  foreach(ITEM ${ARGN})
    list(APPEND RESULT ${STRING} ${ITEM})
  endforeach(ITEM)
  set(${DEST_VAR} "${RESULT}" PARENT_SCOPE)
endfunction()


# Todo: better way to choose path separator?
if(WIN32)
  set(SEP ;)
else(WIN32)
  set(SEP :)
endif(WIN32)

# import environment variables
set(BOOST_HOME $ENV{BOOST_HOME})

# locate JCC installation, store in JCC_DIR
execute_process(
  COMMAND python -c "import os.path, inspect, jcc; print os.path.dirname(inspect.getfile(jcc)).replace(chr(92),'/');"
  RESULT_VARIABLE FIND_JCC_RESULT
  OUTPUT_VARIABLE JCC_DIR
  OUTPUT_STRIP_TRAILING_WHITESPACE
)
if(NOT FIND_JCC_RESULT EQUAL 0)
  message(SEND_ERROR "Failed to get JCC installation path")
  set(JCC_DIR "")
endif()
set(JCC_SRC_DIR "${JCC_DIR}/sources")
include_directories(${JCC_SRC_DIR})

# Add library path for libs
link_directories(${CASADI_BUILD_DIR}/lib) 
link_directories(${IPOPT_HOME}/lib) 

get_filename_component(ABS_MC_BUILD "${MC_BUILD}" REALPATH)

# Jar file location provided from environment
set(COMPILERS_DIR "${IFCASADI_JAR_BASE}")
set(THIRDPARTY_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../ThirdParty")

set(MC_JAR "${COMPILERS_DIR}/ModelicaCompilerCasADi/bin/ModelicaCompiler.jar")
set(OC_JAR "${COMPILERS_DIR}/OptimicaCompilerCasADi/bin/OptimicaCompiler.jar")
set(UTIL_JAR "${COMPILERS_DIR}/ModelicaCompilerCasADi/bin/util.jar")
set(BEAVER_JAR "${THIRDPARTY_DIR}/Beaver/beaver-0.9.6.1/lib/beaver.jar")
set(JARS ${MC_JAR} ${OC_JAR} ${UTIL_JAR} ${BEAVER_JAR})

message(STATUS "COMPILERS_DIR=${COMPILERS_DIR}")
message(STATUS "THIRDPARTY_DIR=${THIRDPARTY_DIR}")
message(STATUS "BEAVER_JAR=${BEAVER_JAR}")

find_library(CASADI_DLL
  NAMES libcasadi_core.so libcasadi_core.dll
  PATHS ${CASADI_BUILD_DIR}/lib
  NO_DEFAULT_PATH
)

interleave_string_and_list(CLASSPATH_WITH_PREFIX --classpath ${JARS})
if(WIN32)
  set(CLASSPATH ${JARS})
else(WIN32)
  join(CLASSPATH ":" "${JARS}")
endif(WIN32)

# Set up includes etc. used by both src/ and swig/
# Add library path for libs
link_directories(${MC_BUILD}/casadi/lib) 
link_directories(${IPOPT_HOME}/lib) 

include_directories(src src/jcc)
include_directories(${CASADI_HOME})
include_directories(${CASADI_BUILD_DIR})

#JNI
find_package(JNI REQUIRED)
include_directories(${JNI_INCLUDE_DIRS})

#Boost
include_directories(${BOOST_HOME})

set(JCC_GEN_DIR "${CMAKE_CURRENT_BINARY_DIR}/src/jcc/build")
include_directories(${JCC_GEN_DIR})
MESSAGE(STATUS "wrap = ${JCC_GEN_DIR}/__wrap__.cpp")


add_subdirectory(src)

get_directory_property(MC_HPP
  DIRECTORY src
  DEFINITION MC_HPP
)

add_subdirectory(swig EXCLUDE_FROM_ALL)



# INCLUDE_DIRS may be used by the parent script
# TODO: remove this once we only use a standalone python wrapper
get_directory_property(INCLUDE_DIRS
  DIRECTORY src
  INCLUDE_DIRECTORIES
)
make_paths_absolute(INCLUDE_DIRS "${INCLUDE_DIRS}")
