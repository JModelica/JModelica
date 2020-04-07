/*
Copyright (C) 2017 Modelon AB

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

#include "Printable.hpp"

namespace ModelicaCasADi
{
void Printable::print(std::ostream& os) const {
    // Test code to help debug python printing problems. Todo: remove
    os << "<This is a Printable>";
}

std::string Printable::repr() {
    std::stringstream s;
    s << *this;
    return s.str();    
}
};