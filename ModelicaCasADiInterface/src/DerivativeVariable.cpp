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

#include "DerivativeVariable.hpp"
namespace ModelicaCasADi {
using casadi::MX;
DerivativeVariable::DerivativeVariable(Model *owner, MX var, Ref<Variable> diffVar, 
                                       Ref<VariableType> declaredType /*= Ref<VariableType>()*/) :
  RealVariable(owner, var, Variable::INTERNAL, Variable::CONTINUOUS, declaredType) { 
    if( diffVar.getNode() != NULL) {
        if (diffVar.getNode()->getType() != Variable::REAL || diffVar.getNode()->getVariability() != Variable::CONTINUOUS ) {
            throw std::runtime_error("A state variable must have real type and continuous variability");
        }
    }
    myDifferentiatedVariable = diffVar.getNode();
}
bool DerivativeVariable::isDerivative() const { return true; }
const Ref<Variable> DerivativeVariable::getMyDifferentiatedVariable() const { return myDifferentiatedVariable; }
}; // End namespace
