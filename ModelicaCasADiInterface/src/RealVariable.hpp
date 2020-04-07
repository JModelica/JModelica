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

#ifndef _MODELICACASADI_REAL_VAR
#define _MODELICACASADI_REAL_VAR

#include "casadi/casadi.hpp"
#include "types/VariableType.hpp"
#include "Ref.hpp"
#include "Variable.hpp"

namespace ModelicaCasADi
{
class Model;

class RealVariable : public Variable {
    public:
        /**
         * Create a RealVariable.
         * @param A symbolic MX.
         * @param An entry of the enum Causality
         * @param An entry of the enum Variability
         * @param A VariableType, default is a reference to NULL. 
         */
        RealVariable(Model *owner, casadi::MX var, Causality causality, 
                     Variability variability,
                     Ref<VariableType> declaredType = Ref<VariableType>());
        /**
         * @return The type Real.
         */
        const Type getType() const;
        /**
         * If this is a state variable, set its derivative variable
         * @param A pointer to a Variable. 
         */
        void setMyDerivativeVariable(Ref<Variable> derVar);
        /**
         * @return Returns a pointer, which may be NULL, to the derivative variable
         */
        const Ref<Variable> getMyDerivativeVariable() const;
        /** @return False */
        virtual bool isDerivative() const;

        MODELICACASADI_SHAREDNODE_CHILD_PUBLIC_DEFS
    private:
        Variable *myDerivativeVariable;
};

}; // End namespace
#endif
