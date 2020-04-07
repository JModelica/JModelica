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

#ifndef _MODELICACASADI_MODEL_FUNCTION
#define _MODELICACASADI_MODEL_FUNCTION

#include <iostream> 
#include <vector>
#include "casadi/casadi.hpp"
#include "RefCountedNode.hpp"
namespace ModelicaCasADi 
{
class ModelFunction : public RefCountedNode {
    public:
        /** 
         * Create a ModelFunction, which is basically a wrapper around an MXFunction
         * that may be called and printed. 
         * @param A MXFunction 
         */
        ModelFunction(casadi::MXFunction myFunction); 
#ifndef SWIG
        // We don't have a useable SWIG typemap to take in a vector of MX right now,
        // the call can be done by going through getFunc instead.
        /**
         * Call the MXFunction kept in this class with a vector of MX as arguments.
         * Returns a vector of MX representing the outputs of the function call, if successful.
         * @param A vector of MX
         * @return A vector of MX
         */
        std::vector<casadi::MX> call(const std::vector<casadi::MX> &arg);
#endif
        /** Return the underlying MXFunction */
        casadi::MXFunction getFunc() const;
        /** Returns the name of the MXFunction */
        std::string getName() const;
        /** Allows the use of the operator << to print this class to a stream, through Printable */
        virtual void print(std::ostream& os) const;

        MODELICACASADI_SHAREDNODE_CHILD_PUBLIC_DEFS
    private:
        casadi::MXFunction myFunction;
};
inline ModelFunction::ModelFunction(casadi::MXFunction myFunction) : myFunction(myFunction) {}
inline casadi::MXFunction ModelFunction::getFunc() const { return myFunction; }
}; // End namespace
#endif


