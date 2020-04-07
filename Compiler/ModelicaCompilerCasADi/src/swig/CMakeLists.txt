cmake_minimum_required(VERSION 2.8.6)
project(ModelicaCompilerCasADi CXX)

#	swig -outdir $(MC_SRC)/src/generated/modelica/java/casadi \
#             -o $(MC_SRC)/src/cpp-generated/java_casadi_wrap.cxx \
#	     -java -package casadi -c++ -I$(CASADI_HOME) $(MC_SRC)/src/swig/java_casadi.i


# copied from ModelicaCasadiInterface/CMakeLists.txt

find_library(CASADI_DLL
  NAMES libcasadi_core.so libcasadi_core.dll
  PATHS ${CASADI_BUILD_DIR}/lib
  NO_DEFAULT_PATH
)

if(" ${CMAKE_C_FLAGS} " MATCHES " -m64 " AND CMAKE_HOST_WIN32)
    add_definitions(-DMS_WIN64)
    message(STATUS "Adding MS_WIN64 definition")
endif()

#JNI
find_package(JNI REQUIRED)
include_directories(${JNI_INCLUDE_DIRS})


set(CPPFLAGS -fPIC -shared -D_REENTRANT)
if(WIN32)
  set(LINKFLAGS "-shared -Wl,--add-stdcall-alias")
else(WIN32)
  set(LINKFLAGS -shared)
endif(WIN32)


set(MODULE_NAME ifcasadi)
set(IFCASADI_DEPS casadi_wrap.i ifcasadi.hpp ifcasadi.cpp)

add_definitions(${CPPFLAGS})
include_directories(.)
include_directories(${CASADI_HOME})
include_directories(${CASADI_HOME}/swig)
include_directories(${CASADI_BUILD_DIR})

set(CMAKE_SWIG_OUTDIR "${IFCASADI_OUTDIR}/src/generated/modelica/java/ifcasadi")

find_package(SWIG REQUIRED)
include(UseSWIG)

set(CMAKE_SWIG_FLAGS -package ifcasadi)

set_source_files_properties(java_casadi.i PROPERTIES CPLUSPLUS ON)
set(SWIG_MODULE_${MODULE_NAME}_EXTRA_DEPS ${IFCASADI_DEPS})

swig_add_module(${MODULE_NAME} java java_casadi.i)
swig_link_libraries(${MODULE_NAME} ${CASADI_DLL})

if(WIN32)
  set_target_properties(${SWIG_MODULE_${MODULE_NAME}_REAL_NAME}
    PROPERTIES PREFIX "")
endif(WIN32)
  
set_target_properties(${SWIG_MODULE_${MODULE_NAME}_REAL_NAME}
  PROPERTIES LINK_FLAGS "${LINKFLAGS}")


# Expose the SWIG module under a nicely named build target
add_custom_target(swig-ifcasadi
  DEPENDS ${SWIG_MODULE_${MODULE_NAME}_REAL_NAME})
