cmake_minimum_required(VERSION 3.10)

# Set the project name and language
project(ODEPACK_Project Fortran)

# Allow the user to specify the Fortran compiler from the command line
if(NOT CMAKE_Fortran_COMPILER)
  set(CMAKE_Fortran_COMPILER gfortran)
endif()

# Set the Fortran compilation flags depending on the compiler
if (CMAKE_Fortran_COMPILER_ID MATCHES "GNU")
  set(dialect "-ffixed-line-length-none -fallow-argument-mismatch -w")
elseif (CMAKE_Fortran_COMPILER_ID MATCHES "Intel")
  set(dialect "/extend-source /Qdiag-disable:10448 /Qdiag-disable:warn")
endif()

set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} ${dialect}")

# Add the source files
set(source_files
  odepack_aux.f90
  opkda1.f
  opkda2.f
  opkdmain.f
)

add_library(odepack_solver SHARED ${source_files})