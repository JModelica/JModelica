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

add_subdirectory(jcc)

set(CXX_FLAGS "")
# Switch flag to debug for debuggind purposes 
set(CMAKE_BUILD_TYPE Release)

# source files
set(TYPES_CPP
  types/RealType.cpp
  types/IntegerType.cpp
  types/BooleanType.cpp
  types/UserType.cpp
  types/PrimitiveType.cpp
  types/VariableType.cpp
)
set(TYPES_HPP
  types/RealType.hpp
  types/IntegerType.hpp
  types/BooleanType.hpp
  types/UserType.hpp
  types/PrimitiveType.hpp
  types/VariableType.hpp
)

set(MC_CPP
  BooleanVariable.cpp
  CompilerOptionsWrapper.cpp
  Constraint.cpp
  DerivativeVariable.cpp
  TimedVariable.cpp
  Equation.cpp
  RefCountedNode.cpp
  IntegerVariable.cpp
  Model.cpp
  ModelFunction.cpp
  OptimizationProblem.cpp
  Printable.cpp
  RealVariable.cpp
  sharedTransferFunctionality.cpp
  transferModelica.cpp
  transferOptimica.cpp
  Variable.cpp
  Block.cpp
  Equations.cpp
  FlatEquations.cpp
  BLT.cpp
  ${TYPES_CPP}
  jcc/initjcc.cpp
  jcc/jccutils.cpp
  ${JCC_SRC_DIR}/JCCEnv.cpp
  ${JCC_SRC_DIR}/JObject.cpp
  ${JCC_GEN_DIR}/__wrap__.cpp
)
# MC_HPP is used by the parent script for SWIG dependencies as well
set(MC_HPP
  BooleanVariable.hpp
  CompilerOptionsWrapper.hpp
  Constraint.hpp
  DerivativeVariable.hpp
  TimedVariable.hpp
  Equation.hpp
  IntegerVariable.hpp
  ModelFunction.hpp
  Model.hpp
  OptimizationProblem.hpp
  Printable.hpp
  RealVariable.hpp
  Ref.hpp
  SharedNode.hpp
  RefCountedNode.hpp
  OwnedNode.hpp
  sharedTransferFunctionality.hpp
  transferModelica.hpp
  transferOptimica.hpp
  Variable.hpp
  Block.hpp
  Equations.hpp
  FlatEquations.hpp
  BLT.hpp
  ${TYPES_HPP}
  jcc/initjcc.h
  jcc/jccutils.h
  jcc/mxwrap.hpp
  jcc/mxvectorwrap.hpp
  jcc/mxfunctionwrap.hpp
  ${JCC_SRC_DIR}/JCCEnv.h
  ${JCC_SRC_DIR}/JObject.h
  ${JCC_SRC_DIR}/JArray.h
)

# Make the paths absolute since they are exported to the parent script
make_paths_absolute(MC_HPP "${MC_HPP}")


# compiler options
if(CMAKE_COMPILER_IS_GNUCXX)
  set(CXX_FLAGS ${CXX_FLAGS} -fPIC)
endif(CMAKE_COMPILER_IS_GNUCXX)

set_source_files_properties(${JCC_GEN_DIR}/__wrap__.cpp PROPERTIES
  GENERATED ON)

add_library(ModelicaCasADi ${MC_CPP} ${MC_HPP})
set_target_properties(ModelicaCasADi PROPERTIES COMPILE_FLAGS ${CXX_FLAGS})
set_target_properties(ModelicaCasADi PROPERTIES COMPILE_DEFINITIONS MODELICACASADI_WITH_SWIG)
add_dependencies(ModelicaCasADi jcc_gen)

add_executable(develope_interface ${MC_CPP} ${MC_HPP} develope_interface.cpp)
set_target_properties(develope_interface PROPERTIES COMPILE_FLAGS ${CXX_FLAGS})
add_dependencies(develope_interface jcc_gen)
target_link_libraries(develope_interface ${CASADI_DLL})
target_link_libraries(develope_interface pthread)
target_link_libraries(develope_interface dl)
