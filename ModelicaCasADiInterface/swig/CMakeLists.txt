#Copyright (C) 2013 Modelon AB

#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, version 3 of the License.

#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.

#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.

set(MODULE_NAME modelicacasadi_wrapper)
set(CASADI_INTERFACE_DEPS doc.i ModelicaCasADi.i Ref.i vectors.i)


find_package(SWIG REQUIRED)
include(UseSWIG)

find_package(PythonLibs REQUIRED)
include_directories(${PYTHON_INCLUDE_PATH})

set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/../../ThirdParty/CasADi/CasADi/cmake)
find_package(NUMPY REQUIRED)
include_directories("${NUMPY_PATH}/..") # ${NUMPY_PATH} points to include/numpy/, we want just include/

set(CMAKE_SWIG_FLAGS "")

include_directories(${CASADI_HOME}/swig)

set_source_files_properties(casadi_interface.i PROPERTIES CPLUSPLUS ON)
set(SWIG_MODULE_${MODULE_NAME}_EXTRA_DEPS ${CASADI_INTERFACE_DEPS} ${MC_HPP})

swig_add_module(${MODULE_NAME} python casadi_interface.i)
swig_link_libraries(${MODULE_NAME} ModelicaCasADi ${PYTHON_LIBRARIES})
swig_link_libraries(${MODULE_NAME} ${CASADI_DLL})

set_target_properties(${SWIG_MODULE_${MODULE_NAME}_REAL_NAME}
  PROPERTIES LINK_FLAGS -shared)



# Expose the SWIG module under a nicely named build target
add_custom_target(modelicacasadi_wrapper
  DEPENDS ${SWIG_MODULE_${MODULE_NAME}_REAL_NAME})
set_target_properties(${SWIG_MODULE_${MODULE_NAME}_REAL_NAME}
  PROPERTIES LINK_FLAGS -shared)
  set_target_properties(${SWIG_MODULE_${MODULE_NAME}_REAL_NAME} 
  PROPERTIES COMPILE_DEFINITIONS MODELICACASADI_WITH_SWIG)
