# Minimum required version of CMake
cmake_minimum_required(VERSION 3.0)

# Project name and version
project(MinpackProject VERSION 1.3.2)

# Specify the CMake module path if necessary
# set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/")

# Configure the build directory for Minpack
set(MINPACK_DIR "${CMAKE_BINARY_DIR}/minpack_build")
set(MINPACK_DIR64 "${CMAKE_BINARY_DIR}/minpack_build64")
set(MINPACK_INSTALL_DIR "${CMAKE_BINARY_DIR}/minpack_install")
set(MINPACK_LIB_INSTALL_DIR "${MINPACK_INSTALL_DIR}/lib")
set(MINPACK_INCLUDE_INSTALL_DIR "${MINPACK_INSTALL_DIR}/include")
set(CMINPACK_SOURCE_DIR "${CMAKE_SOURCE_DIR}/ThirdParty/Minpack/cminpack-${PROJECT_VERSION}")

# Option to build for 64-bit Windows
option(JM_WIN64 "Build for 64-bit Windows" OFF)

# Configuration for different platforms
if(WIN32 AND JM_WIN64)
    set(MINPACK_LIB_INSTALL_DIR "${MINPACK_INSTALL_DIR}/lib64")
    set(CMAKE_C_FLAGS "-m64")
    set(GENERATOR "MSYS Makefiles")
elseif(WIN32)
    set(CMAKE_C_FLAGS "-m32")
    set(GENERATOR "MSYS Makefiles")
endif()

# Include external project module
include(ExternalProject)

# Add Minpack as an external project
ExternalProject_Add(Minpack
    SOURCE_DIR ${CMINPACK_SOURCE_DIR}
    BINARY_DIR ${MINPACK_DIR}
    CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX=${MINPACK_INSTALL_DIR}
        -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
        -DCMINPACK_LIB_INSTALL_DIR=${MINPACK_LIB_INSTALL_DIR}
        -DCMINPACK_INCLUDE_INSTALL_DIR=${MINPACK_INCLUDE_INSTALL_DIR}
        -G ${GENERATOR}
    BUILD_ALWAYS 1
)

if(JM_WIN64)
    ExternalProject_Add(Minpack64
        SOURCE_DIR ${CMINPACK_SOURCE_DIR}
        BINARY_DIR ${MINPACK_DIR64}
        CMAKE_ARGS
            -DCMAKE_INSTALL_PREFIX=${MINPACK_INSTALL_DIR}
            -DCMAKE_C_FLAGS=-m64
            -DCMINPACK_LIB_INSTALL_DIR=${MINPACK_INSTALL_DIR}/lib64
            -DCMINPACK_INCLUDE_INSTALL_DIR=${MINPACK_INSTALL_DIR}/include
            -G "MSYS Makefiles"
        BUILD_ALWAYS 1
    )
endif()

# Custom target to build and install
add_custom_target(build_and_install
    ${CMAKE_COMMAND} --build ${MINPACK_DIR} --target install
    COMMENT "Building and installing Minpack"
)

if(JM_WIN64)
    add_custom_target(build_and_install64
        ${CMAKE_COMMAND} --build ${MINPACK_DIR64} --target install
        COMMENT "Building and installing Minpack64"
    )
endif()

# Add tests if necessary
enable_testing()
# add_test(NAME MyTest COMMAND TestCommand)

# Custom target for cleaning
add_custom_target(clean_minpack
    COMMAND ${CMAKE_COMMAND} --build ${MINPACK_DIR} --target clean
    COMMENT "Cleaning Minpack build directory"
)

if(JM_WIN64)
    add_custom_target(clean_minpack64
        COMMAND ${CMAKE_COMMAND} --build ${MINPACK_DIR64} --target clean
        COMMENT "Cleaning Minpack64 build directory"
    )
endif()
