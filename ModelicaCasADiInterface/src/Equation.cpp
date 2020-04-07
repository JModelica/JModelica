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

#include "Equation.hpp"
using casadi::MX;
namespace ModelicaCasADi 
{
Equation::Equation(MX lhs, MX rhs) : lhs(lhs), rhs(rhs), tearing(false) {}
void Equation::print(std::ostream& os) const { 
    os << ModelicaCasADi::normalizeMXRespresentation(lhs);
    os << " = ";
    os << ModelicaCasADi::normalizeMXRespresentation(rhs); 
}
}; // End namespace
