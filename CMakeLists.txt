cmake_minimum_required(VERSION 3.5)
project(jmodelica)

# Compiler flags
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC")

# Platform-specific flags
if(WIN32)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -m32")
else()
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -m64")
endif()

# Find packages
# set(OpenMP_libomp_LIBRARY "C:\\tools\\msys64\\mingw64\\lib\gcc\\x86_64-w64-mingw32\\13.2.0\\include")
set(OpenMP_libomp_LIBRARY "C:\\tools\\msys64\\mingw64\\include")

find_package(OpenMP)
if (OPENMP_FOUND)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS}")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
endif()

set(OpenMP_C_LIB_NAMES "libomp")
set(OpenMP_CXX_LIB_NAMES "libomp")



# Assuming Python is required
find_package(PythonInterp REQUIRED)

# Add subdirectories for third-party libraries
# Note: You will need to add CMakeLists.txt in these directories or handle them appropriately
add_subdirectory(ThirdParty/winpthreads)
add_subdirectory(ThirdParty/SuperLU)
add_subdirectory(ThirdParty/Sundials)
add_subdirectory(ThirdParty/Minpack)
add_subdirectory(ThirdParty/Blas)
add_subdirectory(ThirdParty/Lapack)
add_subdirectory(ThirdParty/MSL)
add_subdirectory(external/FMILibrary)
add_subdirectory(RuntimeLibrary)

# ExternalProject_Add()

# Conditional compilation for Python
if(PYTHON_ENABLED)
    add_subdirectory(Python)
endif()

# Main executable target
# Replace ... with the actual source files for jm_tests
add_executable(jm_tests ...)

# Linking with third-party libraries
# Note: Specify the actual library names and variables
target_link_libraries(jm_tests
    winpthreads
    SuperLU
    Sundials
    Minpack
    Blas
    Lapack
    MSL
    FMILibrary
    ${Python_LIBRARIES}
    OpenMP::OpenMP_CXX
)

# Custom build steps can be added as custom commands or separate script files

# Installation commands
install(TARGETS jm_tests DESTINATION bin)
