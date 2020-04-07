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

#include "IntegerVariable.hpp"
namespace ModelicaCasADi 
{
using casadi::MX;
IntegerVariable::IntegerVariable(Model *owner, MX var, Variable::Causality causality,
                           Variable::Variability variability, Ref<VariableType> declaredType /*= Ref<VariableType>()*/) :
  Variable(owner, var, causality, variability, declaredType) { 
    if (variability == Variable::CONTINUOUS) {
		throw std::runtime_error("An integer variable can not have continuous variability");
	}
}
const Variable::Type IntegerVariable::getType() const { return Variable::INTEGER; }
}; // End namespace
