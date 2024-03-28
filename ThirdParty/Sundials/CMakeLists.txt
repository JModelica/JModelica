cmake_minimum_required(VERSION 3.10)

# Project name and version
project(SundialsBuild)

# Check if we are on a 64-bit system and set a flag accordingly
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(JM_WIN64 ON)
endif()

# Set the Sundials version and directories
set(SUNDIALS_VERSION "2.7.0")
set(SUNDIALS_DIR "${CMAKE_CURRENT_BINARY_DIR}/sundials_build")
set(SUNDIALS_DIR64 "${CMAKE_CURRENT_BINARY_DIR}/sundials_build64")
set(SUPERLU_DIR "${CMAKE_SOURCE_DIR}/../../superlu_build")
set(SUPERLU_DIR64 "${CMAKE_SOURCE_DIR}/../../superlu_build64")

# Configure options for SUPERLU if needed
option(WITH_OPENMP "Enable OpenMP support for SUPERLU" OFF)

if(WITH_OPENMP)
    set(SUPERLU_ADDON "-DSUPERLUMT_THREAD_TYPE=OpenMP -DSUPERLUMT_ENABLE=ON -DSUPERLUMT_LIBRARY_DIR=${SUPERLU_DIR}/lib -DSUPERLUMT_INCLUDE_DIR=${SUPERLU_DIR}/SRC")
    set(SUPERLU_ADDON64 "-DSUPERLUMT_THREAD_TYPE=OpenMP -DSUPERLUMT_ENABLE=ON -DSUPERLUMT_LIBRARY_DIR=${SUPERLU_DIR64}/lib -DSUPERLUMT_INCLUDE_DIR=${SUPERLU_DIR64}/SRC")
else()
    set(SUPERLU_ADDON "")
    set(SUPERLU_ADDON64 "")
endif()

# Function to configure and build Sundials
function(configure_sundials SUNDIALS_DIR ADDON_FLAGS)
    file(MAKE_DIRECTORY ${SUNDIALS_DIR})
    set(CMAKE_ARGS -DEXAMPLES_ENABLE=OFF -DBUILD_SHARED_LIBS=OFF -DCMAKE_INSTALL_PREFIX=${CMAKE_SOURCE_DIR}/../../sundials_install)

    if(ADDON_FLAGS)
        list(APPEND CMAKE_ARGS ${ADDON_FLAGS})
    endif()

    if(WIN32 AND NOT CYGWIN)
        list(APPEND CMAKE_ARGS -G "MSYS Makefiles" -DCMAKE_C_FLAGS="-fPIC")
    elseif(APPLE)
        list(APPEND CMAKE_ARGS -DCMAKE_C_FLAGS="-fPIC")
    else()
        list(APPEND CMAKE_ARGS -DCMAKE_C_FLAGS="-fPIC")
    endif()

    include(ExternalProject)
    ExternalProject_Add(
        sundials_build
        SOURCE_DIR ${CMAKE_SOURCE_DIR}/ThirdParty/Sundials/sundials-${SUNDIALS_VERSION}
        BINARY_DIR ${SUNDIALS_DIR}
        CMAKE_ARGS ${CMAKE_ARGS}
        INSTALL_DIR ${CMAKE_SOURCE_DIR}/../../sundials_install
    )
endfunction()

# Configure Sundials builds
configure_sundials(${SUNDIALS_DIR} ${SUPERLU_ADDON})

if(JM_WIN64)
    configure_sundials(${SUNDIALS_DIR64} ${SUPERLU_ADDON64})
endif()

# Custom targets for make install and make test, if needed
add_custom_target(install-sundials
    COMMAND ${CMAKE_COMMAND} --build ${SUNDIALS_DIR} --target install
)

add_custom_target(test-sundials
    COMMAND ${CMAKE_COMMAND} --build ${SUNDIALS_DIR} --target test
)

add_custom_target(clean-sundials
    COMMAND ${CMAKE_COMMAND} --build ${SUNDIALS_DIR} --target clean
)

if(JM_WIN64)
    add_custom_target(clean-sundials64
        COMMAND ${CMAKE_COMMAND} --build ${SUNDIALS_DIR64} --target clean
    )
endif()
