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

#ifndef _MODELICACASADI_EQUATION
#define _MODELICACASADI_EQUATION

#include <iostream>
#include "casadi/casadi.hpp"
#include "RefCountedNode.hpp"
namespace ModelicaCasADi 
{
class Equation: public RefCountedNode {
    public:
        /** 
         * Create an equation with MX expressions for the left and right hand side
         * @param A MX
         * @param A MX
         */
        Equation(casadi::MX lhs, casadi::MX rhs); 
        /** @return A MX */
        casadi::MX getLhs() const;
        /** @return A MX */
        casadi::MX getRhs() const;
        
        void setLhs(casadi::MX nlhs);
        void setRhs(casadi::MX nrhs);
        
        /** 
         * Returns the residual on the form: left-hand-side - right-hand-side
         * @return A MX 
         */
        casadi::MX getResidual() const; 
        /** Allows the use of the operator << to print this class to a stream, through Printable */
        virtual void print(std::ostream& os) const;
        
        /** @param bool. */
        void setTearing(bool); 
        /** @return True if this variable is a tearing variable */
        bool getTearing() const;

        MODELICACASADI_SHAREDNODE_CHILD_PUBLIC_DEFS
    private:
        casadi::MX lhs;
        casadi::MX rhs;
        bool tearing;
};

inline casadi::MX Equation::getLhs() const { return lhs; }
inline casadi::MX Equation::getRhs() const { return rhs; }
inline casadi::MX Equation::getResidual() const { return lhs - rhs; }

inline void Equation::setLhs(casadi::MX nlhs) { lhs = nlhs; }
inline void Equation::setRhs(casadi::MX nrhs) { rhs = nrhs; }
inline void Equation::setTearing(bool ntearing) {
    this->tearing = ntearing; 
}
inline bool Equation::getTearing() const {return tearing;}

}; // End namespace
#endif
