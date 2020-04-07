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

#include "ModelFunction.hpp"
using std::ostream; using std::vector; using std::string;
using casadi::MX;  using casadi::MXFunction;

namespace ModelicaCasADi 
{
 
vector<MX> ModelFunction::call(const vector<MX> &arg) {
    return myFunction.call(arg);
}

string ModelFunction::getName() const {
    return myFunction.getOption("name");
}

void ModelFunction::print(ostream& os) const { 
    os << "ModelFunction : " << myFunction << "\n";
    myFunction.print(os);
}

}; // End namespace
