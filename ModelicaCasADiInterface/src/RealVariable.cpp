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

#include "RealVariable.hpp"
namespace ModelicaCasADi 
{
RealVariable::RealVariable(Model *owner, casadi::MX var, Variable::Causality causality,
                           Variable::Variability variability, Ref<VariableType> declaredType /*= Ref<VariableType>()*/) :
  Variable(owner, var, causality, variability, declaredType) { 
    myDerivativeVariable = NULL;
}
const Variable::Type RealVariable::getType() const { return Variable::REAL; }
void RealVariable::setMyDerivativeVariable(Ref<Variable> diffVar) { 
	Ref<RealVariable> dVar = dynamic_cast< RealVariable* >(diffVar.getNode());
	if (dVar != Ref<RealVariable>(NULL)) {
		if( !dVar->isDerivative()) {
			throw std::runtime_error("A Variable that is set as a derivative variable must be a DerivativeVariable");
		}
	} else {
		throw std::runtime_error("A Variable that is set as a derivative variable must be a DerivativeVariable");
	}
    if (getVariability() != Variable::CONTINUOUS || isDerivative()) {
        throw std::runtime_error("A RealVariable that is a state variable must have continuous variability, and may not be a derivative variable.");
    }
    myDerivativeVariable = diffVar.getNode(); 	
}
const Ref<Variable> RealVariable::getMyDerivativeVariable() const { return myDerivativeVariable; }
bool RealVariable::isDerivative() const { return false; }
}; // End namespace
