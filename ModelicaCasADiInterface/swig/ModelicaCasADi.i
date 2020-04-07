/*
Copyright (C) 2013 Modelon AB

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, version 3 of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

%{
#include "Equation.hpp"
#include "Constraint.hpp"
#include "ModelFunction.hpp"

#include "types/VariableType.hpp"
#include "types/PrimitiveType.hpp"
#include "types/BooleanType.hpp"
#include "types/IntegerType.hpp"
#include "types/RealType.hpp"
#include "types/UserType.hpp"

#include "Variable.hpp"
#include "TimedVariable.hpp"
#include "RealVariable.hpp"
#include "DerivativeVariable.hpp"
#include "BooleanVariable.hpp"
#include "IntegerVariable.hpp"

#include "Block.hpp"


#include "Equations.hpp"
#include "FlatEquations.hpp"
#include "BLT.hpp"


#include "Model.hpp"
#include "OptimizationProblem.hpp"

#include "transferModelica.hpp"
#include "transferOptimica.hpp"

#include "CompilerOptionsWrapper.hpp"

#include "SharedNode.hpp"
#include "RefCountedNode.hpp"
#include "OwnedNode.hpp"
#include "Ref.hpp"
%}

%rename(_transferOptimizationProblem) transferOptimizationProblem;
%rename(print_) print;
// __repr__ and __str__ are overloaded to be used from Python instead
%ignore operator<<;
// Things that shouldn't be used from Python:
%ignore _get_swig_p_type;
%ignore ModelicaCasADi::Ref; 
%ignore ModelicaCasADi::incRefNode;
%ignore ModelicaCasADi::decRefNode;


%include "Ref.i" // Must be before %include "std_vector.i". Includes Ref.hpp
%include "vectors.i"

%include "doc.i"


%include "std_string.i"
%include "std_vector.i"


// Instantiate Ref<T> and vector<Ref<T>> along with apropriate typemaps.
// All %instantiate_Ref invocations must be afer "Ref.i"
// and before the header for the type T in question.

%instantiate_Ref(ModelicaCasADi, SharedNode)
%instantiate_Ref(ModelicaCasADi, RefCountedNode)
%instantiate_Ref(ModelicaCasADi, OwnedNode)

%instantiate_Ref(ModelicaCasADi, Equation)
%instantiate_Ref(ModelicaCasADi, Constraint)
%instantiate_Ref(ModelicaCasADi, ModelFunction)

%instantiate_Ref(ModelicaCasADi, VariableType)
%instantiate_Ref(ModelicaCasADi, PrimitiveType)
%instantiate_Ref(ModelicaCasADi, BooleanType)
%instantiate_Ref(ModelicaCasADi, IntegerType)
%instantiate_Ref(ModelicaCasADi, RealType)
%instantiate_Ref(ModelicaCasADi, UserType)

%instantiate_Ref(ModelicaCasADi, Variable)
%instantiate_Ref(ModelicaCasADi, TimedVariable)
%instantiate_Ref(ModelicaCasADi, RealVariable)
%instantiate_Ref(ModelicaCasADi, DerivativeVariable)
%instantiate_Ref(ModelicaCasADi, BooleanVariable)
%instantiate_Ref(ModelicaCasADi, IntegerVariable)

%instantiate_Ref(ModelicaCasADi, Block)


%instantiate_Ref(ModelicaCasADi, Equations)
%instantiate_Ref(ModelicaCasADi, FlatEquations)
%instantiate_Ref(ModelicaCasADi, BLT)

%instantiate_Ref(ModelicaCasADi, Model)

%instantiate_Ref(ModelicaCasADi, OptimizationProblem)

%instantiate_Ref(ModelicaCasADi, OptimicaOptionsWrapper)
%instantiate_Ref(ModelicaCasADi, ModelicaOptionsWrapper)

// These must be in dependency order!
// SWIG doesn't follow #includes in the header files
%include "Printable.hpp"
%include "SharedNode.hpp"
%include "RefCountedNode.hpp"
%include "OwnedNode.hpp"

%include "Equation.hpp"
%include "Constraint.hpp"
%include "ModelFunction.hpp"

%include "types/VariableType.hpp"
%include "types/PrimitiveType.hpp"
%include "types/BooleanType.hpp"
%include "types/IntegerType.hpp"
%include "types/RealType.hpp"
%include "types/UserType.hpp"

%include "Variable.hpp"
%include "TimedVariable.hpp"
%include "RealVariable.hpp"
%include "DerivativeVariable.hpp"
%include "BooleanVariable.hpp"
%include "IntegerVariable.hpp"

%include "Block.hpp"


%include "Equations.hpp"
%include "FlatEquations.hpp"
%include "BLT.hpp"

%include "Model.hpp"
%include "OptimizationProblem.hpp"

%include "sharedTransferFunctionality.hpp"

%include "CompilerOptionsWrapper.hpp"

%include "transferModelica.hpp"
%include "transferOptimica.hpp"

%extend ModelicaCasADi::SharedNode {
    // Should be ok to take the argument as a SharedNode * instead of a Ref<SharedNode>,
    // since we don't keep it and the caller must own references to both this and node.
    // On the other hand, Ref<SharedNode> is probably not functional, only Ref on its subclasses.
    bool __eq__(const SharedNode *node) {
        return $self == node;
    }
    bool __ne__(const SharedNode *node) {
        return $self != node;
    }
    bool __eq__(SWIG_Object obj) {
        return false; // Should only happen if obj is not a proxy for a SharedNode
    }   
    bool __ne__(SWIG_Object obj) {
        return true; // Should only happen if obj is not a proxy for a SharedNode
    }   

    // Technically, we should return a uintptr_t to be sure to be able to hold the whole pointer.
    // But size_t should be the same type on most modern platforms, and hashing still works if we
    // truncate the pointer, while uintptr_t seems to be C++11.
    size_t __hash__() {
        return (size_t)$self;
    }   
}

%extend ModelicaCasADi::Equation {
  std::string __repr__() { return $self->repr(); }
}
%extend ModelicaCasADi::Constraint {
  std::string __repr__() { return $self->repr(); }
}
%extend ModelicaCasADi::ModelFunction {
  std::string __repr__() { return $self->repr(); }
}

%extend ModelicaCasADi::VariableType {
  std::string __repr__() { return $self->repr(); }
}
%extend ModelicaCasADi::PrimitiveType {
  std::string __repr__() { return $self->repr(); }
}
%extend ModelicaCasADi::BooleanType {
  std::string __repr__() { return $self->repr(); }
}
%extend ModelicaCasADi::IntegerType {
  std::string __repr__() { return $self->repr(); }
}
%extend ModelicaCasADi::RealType {
  std::string __repr__() { return $self->repr(); }
}
%extend ModelicaCasADi::UserType {
  std::string __repr__() { return $self->repr(); }
}
%extend ModelicaCasADi::Variable {
  std::string __repr__() { return $self->repr(); }
}
%extend ModelicaCasADi::TimedVariable {
  std::string __repr__() { return $self->repr(); }
}
%extend ModelicaCasADi::RealVariable {
  std::string __repr__() { return $self->repr(); }
}
%extend ModelicaCasADi::DerivativeVariable {
  std::string __repr__() { return $self->repr(); }
}
%extend ModelicaCasADi::BooleanVariable {
  std::string __repr__() { return $self->repr(); }
}
%extend ModelicaCasADi::IntegerVariable {
  std::string __repr__() { return $self->repr(); }
}
%extend ModelicaCasADi::Model {
  std::string __repr__() { return $self->repr(); }
}
/*
%extend ModelicaCasADi::Block {
  std::string __repr__() { return $self->repr(); }
}
*/
%extend ModelicaCasADi::OptimizationProblem {
  std::string __repr__() { return $self->repr(); }
}
%extend ModelicaCasADi::ModelicaOptionsWrapper {
  std::string __repr__() { return $self->repr(); }
}
%extend ModelicaCasADi::OptimicaOptionsWrapper {
  std::string __repr__() { return $self->repr(); }
}
/*
#ifdef SWIG
    %extend ModelicaCasADi::Printable{
        std::string __repr__() { return $self->repr(); }
    }
#endif
*/
