# Minimum required version of CMake
cmake_minimum_required(VERSION 3.10)

# Project name and version
project(WinPthreads)

# Check if JM_WIN64 is defined (assuming it's passed via command line or environment)
option(JM_WIN64 "Build for Windows 64-bit" OFF)

# Set the directories for winpthreads sources and build outputs
set(WINPTHREADS_SRC_DIR ${CMAKE_SOURCE_DIR}/ThirdParty/winpthreads/winpthreads)
set(WINPTHREADS_BUILD_DIR ${CMAKE_BINARY_DIR}/winpthreads_build)
set(WINPTHREADS_BUILD_DIR64 ${CMAKE_BINARY_DIR}/winpthreads_build64)

# Define the build process for winpthreads
function(build_winpthreads TARGET_DIR FLAGS)
    # Create the target directory
    file(MAKE_DIRECTORY ${TARGET_DIR})
    
    # Copy the winpthreads source files to the build directory
    file(COPY ${WINPTHREADS_SRC_DIR}/ DESTINATION ${TARGET_DIR})
    
    # Add a custom target for configuring and building winpthreads
    add_custom_target(${TARGET_DIR} ALL
        COMMAND ./configure
        COMMAND make CFLAGS=${FLAGS} LDFLAGS=${FLAGS} RCFLAGS='-F pe-i386'
        WORKING_DIRECTORY ${TARGET_DIR}
    )
endfunction()

# Build for 32-bit or 64-bit based on JM_WIN64
if(JM_WIN64)
    build_winpthreads(${WINPTHREADS_BUILD_DIR64} "")
else()
    build_winpthreads(${WINPTHREADS_BUILD_DIR} "-m32")
endif()

# Test and clean targets (optional, for example purposes)
add_custom_target(check
    COMMAND $(MAKE) test
    WORKING_DIRECTORY ${WINPTHREADS_BUILD_DIR}
)

add_custom_target(clean
    COMMAND $(MAKE) clean
    WORKING_DIRECTORY ${WINPTHREADS_BUILD_DIR}
)
if(JM_WIN64)
    add_custom_target(clean64
        COMMAND $(MAKE) clean
        WORKING_DIRECTORY ${WINPTHREADS_BUILD_DIR64}
    )
endif()
