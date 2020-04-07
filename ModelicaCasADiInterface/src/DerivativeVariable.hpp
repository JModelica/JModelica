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

#ifndef _MODELICACASADI_DER_VAR
#define _MODELICACASADI_DER_VAR

#include "casadi/casadi.hpp"
#include "types/VariableType.hpp"
#include "Ref.hpp"
#include "RealVariable.hpp"

namespace ModelicaCasADi
{
class Model;

class DerivativeVariable : public RealVariable {
    public:
        /**
         * Create a derivative variable. A derivative variable takes a pointer to
         * its corresponding state variable as argument.
         * @param A symbolic MX
         * @param A pointer to a Variable
         * @param A VariableType, default is a reference to NULL. 
         */
        DerivativeVariable(Model *owner, casadi::MX var, Ref<Variable> diffVar, 
                           Ref<VariableType> declaredType = Ref<VariableType>()); 
        /** @return A pointer to a Variable */
        const Ref<Variable> getMyDifferentiatedVariable() const;
        /** @return True */
        bool isDerivative() const;

        MODELICACASADI_SHAREDNODE_CHILD_PUBLIC_DEFS
    private:
        Variable *myDifferentiatedVariable;
};

}; // End namespace
#endif
