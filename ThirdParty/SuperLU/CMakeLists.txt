cmake_minimum_required(VERSION 3.10)
project(SuperLUProject)

# Define the directories
set(SUPERLU_DIR "${CMAKE_BINARY_DIR}/superlu_build")
set(SUPERLU_DIR64 "${CMAKE_BINARY_DIR}/superlu_build64")
set(SUPERLU_SOURCE_DIR "${CMAKE_SOURCE_DIR}/ThirdParty/SuperLU/superlu_mt_3.1")

# Option to toggle the 64-bit build
option(JM_WIN64 "Enable 64-bit build" OFF)

# Function to configure and build SuperLU
function(build_superlu target_dir extra_cflags)
    file(MAKE_DIRECTORY ${target_dir})
    file(COPY ${SUPERLU_SOURCE_DIR}/ DESTINATION ${target_dir})

    # Compile the blaslib and superlulib
    add_custom_target(blaslib_${target_dir}
        COMMAND ${CMAKE_COMMAND} -E chdir ${target_dir} make blaslib EXTRA_CFLAGS=${extra_cflags}
    )
    add_custom_target(superlulib_${target_dir}
        COMMAND ${CMAKE_COMMAND} -E chdir ${target_dir} make superlulib EXTRA_CFLAGS=${extra_cflags}
    )
    add_dependencies(superlulib_${target_dir} blaslib_${target_dir})
endfunction()

if(JM_WIN64)
    build_superlu(${SUPERLU_DIR64} "")
    set(ALL_TARGETS ${ALL_TARGETS} superlulib_${SUPERLU_DIR64})
else()
    build_superlu(${SUPERLU_DIR} "-m32")
    set(ALL_TARGETS ${ALL_TARGETS} superlulib_${SUPERLU_DIR})
endif()

# Create an all-local target equivalent
add_custom_target(all-local DEPENDS ${ALL_TARGETS})

# Check and clean rules
add_custom_target(check-local
    COMMAND ${CMAKE_COMMAND} -E chdir ${SUPERLU_DIR} make test
)

add_custom_target(clean-local
    COMMAND ${CMAKE_COMMAND} -E chdir ${SUPERLU_DIR} make clean
)
if(JM_WIN64)
    add_custom_command(
        TARGET clean-local
        COMMAND ${CMAKE_COMMAND} -E chdir ${SUPERLU_DIR64} make clean
    )
endif()

