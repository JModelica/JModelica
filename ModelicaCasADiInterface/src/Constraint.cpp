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

#include "Constraint.hpp"
using std::ostream; using casadi::MX;
namespace ModelicaCasADi{
Constraint::Constraint(MX lhs, MX rhs,
                   Constraint::Type ct) : lhs(lhs), rhs(rhs), ct(ct){ }

/** Allows the use of the operator << to print this class to a stream, through Printable */
void Constraint::print(std::ostream& os) const {
	using std::endl;
    switch(ct) {
        case Constraint::EQ:  {
            os << ModelicaCasADi::normalizeMXRespresentation(lhs);
            os << " = ";
            os << ModelicaCasADi::normalizeMXRespresentation(rhs);
            break;
        }
        case Constraint::LEQ: {
            os << ModelicaCasADi::normalizeMXRespresentation(lhs);
            os << " <= ";
            os << ModelicaCasADi::normalizeMXRespresentation(rhs);
            break;
        } 
        case Constraint::GEQ:  {
            os << ModelicaCasADi::normalizeMXRespresentation(lhs);
            os << " >= ";
            os << ModelicaCasADi::normalizeMXRespresentation(rhs);
            break;
        }
    }
}
}; // End namespace
