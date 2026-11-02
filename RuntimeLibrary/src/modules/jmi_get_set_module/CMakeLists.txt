cmake_minimum_required(VERSION 3.20 FATAL_ERROR)

set(JMIGetSetSource
    jmi_get_set.c)

add_library(jmi_get_set_default SHARED
            ${JMIGetSetSource})

if(NOT MSVC)
    set_target_properties(jmi_get_set_default PROPERTIES COMPILE_FLAGS "-Wall -g -std=c89 -pedantic -Werror -O2")
endif()

#Install the library
install(TARGETS jmi_get_set_default
    RUNTIME DESTINATION "${RTLIB_LIB_DIR}"
    LIBRARY DESTINATION "${RTLIB_LIB_DIR}"
    ARCHIVE DESTINATION "${RTLIB_LIB_DIR}")
