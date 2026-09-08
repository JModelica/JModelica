cmake_minimum_required(VERSION 3.20)
project(JModelica VERSION 1.0 LANGUAGES C CXX)

# Set C/C++ standards
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)

message(STATUS "========================================")
message(STATUS "JModelica Build Configuration")
message(STATUS "========================================")

# Conda environment detection
if(DEFINED ENV{CONDA_PREFIX})
    set(CONDA_PREFIX $ENV{CONDA_PREFIX})
    message(STATUS "Conda environment: ${CONDA_PREFIX}")
    
    # Add conda paths
    list(APPEND CMAKE_PREFIX_PATH 
        "${CONDA_PREFIX}"
        "${CONDA_PREFIX}/Library"
        "${CONDA_PREFIX}/lib/cmake"
        "${CONDA_PREFIX}/Library/lib/cmake"
    )
    
    # Set paths for finding libraries
    set(CMAKE_LIBRARY_PATH "${CONDA_PREFIX}/lib;${CONDA_PREFIX}/Library/lib")
    set(CMAKE_INCLUDE_PATH "${CONDA_PREFIX}/include;${CONDA_PREFIX}/Library/include")
    
    # Include and link directories
    include_directories("${CONDA_PREFIX}/include" "${CONDA_PREFIX}/Library/include")
    link_directories("${CONDA_PREFIX}/lib" "${CONDA_PREFIX}/Library/lib")
endif()

# Find Python
find_package(Python3 COMPONENTS Interpreter Development REQUIRED)
message(STATUS "Python: ${Python3_EXECUTABLE}")
message(STATUS "Python Include: ${Python3_INCLUDE_DIRS}")
message(STATUS "Python Libraries: ${Python3_LIBRARIES}")

# Java build is handled by Gradle directly
# find_package(Java 17 COMPONENTS Development REQUIRED)
# include(UseJava)

# Find Sundials
find_library(SUNDIALS_CVODE_LIB NAMES sundials_cvode REQUIRED)
find_library(SUNDIALS_IDA_LIB NAMES sundials_ida REQUIRED)
find_library(SUNDIALS_KINSOL_LIB NAMES sundials_kinsol REQUIRED)
find_library(SUNDIALS_NVECSERIAL_LIB NAMES sundials_nvecserial REQUIRED)
find_path(SUNDIALS_INCLUDE_DIR sundials/sundials_types.h REQUIRED)

set(SUNDIALS_LIBRARIES 
    ${SUNDIALS_CVODE_LIB}
    ${SUNDIALS_IDA_LIB}
    ${SUNDIALS_KINSOL_LIB}
    ${SUNDIALS_NVECSERIAL_LIB}
)

message(STATUS "Sundials Include: ${SUNDIALS_INCLUDE_DIR}")
message(STATUS "Sundials Libraries: ${SUNDIALS_LIBRARIES}")

include_directories(${SUNDIALS_INCLUDE_DIR})

# Find Ipopt (optional for now)
find_library(IPOPT_LIB NAMES ipopt)
find_path(IPOPT_INCLUDE_DIR coin-or/IpStdCInterface.h)

if(IPOPT_LIB AND IPOPT_INCLUDE_DIR)
    message(STATUS "Ipopt Include: ${IPOPT_INCLUDE_DIR}")
    message(STATUS "Ipopt Library: ${IPOPT_LIB}")
    include_directories(${IPOPT_INCLUDE_DIR})
else()
    message(STATUS "Ipopt: Not found (optional)")
endif()

# Set TOP_SRC for subprojects
set(TOP_SRC ${CMAKE_SOURCE_DIR})
set(JMODELICA_INSTALL_DIR ${CMAKE_BINARY_DIR}/install)
set(SUNDIALS_HOME ${SUNDIALS_INCLUDE_DIR}/..)
set(MINPACK_HOME ${TOP_SRC}/ThirdParty/Minpack/cminpack-1.3.2)

# Add RuntimeLibrary
add_subdirectory(RuntimeLibrary)

# Custom target for Java compiler
add_custom_target(compiler_build
    COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_SOURCE_DIR}/Compiler 
            $<IF:$<PLATFORM_ID:Windows>,gradlew.bat,./gradlew> build
    COMMENT "Building Java compiler with Gradle"
    VERBATIM
)

message(STATUS "========================================")
message(STATUS "Configuration Complete")
message(STATUS "Build targets:")
message(STATUS "  cmake --build . (build all)")
message(STATUS "  cmake --build . --target compiler_build (Java only)")
message(STATUS "========================================")
