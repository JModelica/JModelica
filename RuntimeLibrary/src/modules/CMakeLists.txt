cmake_minimum_required(VERSION 2.8)

# Add all subdirectories with CMakeLists.txt
file(GLOB children RELATIVE ${CMAKE_CURRENT_LIST_DIR} ${CMAKE_CURRENT_LIST_DIR}/*)
foreach(child ${children})
    if(EXISTS ${CMAKE_CURRENT_LIST_DIR}/${child}/CMakeLists.txt)
        add_subdirectory(${child})
    endif()
endforeach()
