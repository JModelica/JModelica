cmake_minimum_required(VERSION 3.10)
project(FMILibraryBuild)

# Define the paths used in the Makefile.am
set(FMIL_BUILD_DIR "${CMAKE_BINARY_DIR}/FMIL_build")
set(FMIL_BUILD_DIR64 "${CMAKE_BINARY_DIR}/FMIL_build64")
set(FMIL_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/FMIL_install")
set(FMIL_INSTALL_PREFIX64 "${CMAKE_BINARY_DIR}/FMIL_install64")
set(FMIL_SOURCE_DIR "${CMAKE_SOURCE_DIR}/external/FMILibrary/FMILibrary")

# Option for 64-bit build, similar to JM_WIN64 in Makefile.am
option(JM_WIN64 "Build for 64-bit" OFF)

# Configuration for 32-bit or default build
file(MAKE_DIRECTORY ${FMIL_BUILD_DIR})
add_custom_target(FMILBuild32
    COMMAND cmake -G "MSYS Makefiles" -DCMAKE_C_FLAGS="-m32" -DCMAKE_CXX_FLAGS="-m32"
            -DCMAKE_SHARED_LINKER_FLAGS="-m32" -DCMAKE_EXE_LINKER_FLAGS="-m32"
            -DFMILIB_INSTALL_PREFIX:PATH=${FMIL_INSTALL_PREFIX} ${FMIL_SOURCE_DIR}
    WORKING_DIRECTORY ${FMIL_BUILD_DIR}
)
add_custom_target(install32
    COMMAND ${CMAKE_COMMAND} --build . --target install
    WORKING_DIRECTORY ${FMIL_BUILD_DIR}
)
add_dependencies(install32 FMILBuild32)

# Configuration for 64-bit build
if(JM_WIN64)
    file(MAKE_DIRECTORY ${FMIL_BUILD_DIR64})
    add_custom_target(FMILBuild64
        COMMAND cmake -G "MSYS Makefiles" -DCMAKE_C_FLAGS="-m64 -fPIC" -DCMAKE_CXX_FLAGS="-m64 -fPIC"
                -DCMAKE_SHARED_LINKER_FLAGS="-m64 -fPIC" -DCMAKE_EXE_LINKER_FLAGS="-m64 -fPIC"
                -DFMILIB_INSTALL_PREFIX:PATH=${FMIL_INSTALL_PREFIX64} ${FMIL_SOURCE_DIR}
        WORKING_DIRECTORY ${FMIL_BUILD_DIR64}
    )
    add_custom_target(install64
        COMMAND ${CMAKE_COMMAND} --build . --target install
        WORKING_DIRECTORY ${FMIL_BUILD_DIR64}
    )
    add_dependencies(install64 FMILBuild64)
endif()

# Test and clean targets could also be defined similarly using add_custom_target
