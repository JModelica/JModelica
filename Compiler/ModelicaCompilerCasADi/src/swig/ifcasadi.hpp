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

#ifndef _IFCASADI_HPP
#define _IFCASADI_HPP

#include <vector>
#include "casadi/core/shared_object.hpp"
#include "casadi/casadi.hpp"

void ifcasadi_register_instance(std::vector<casadi::MX> *newobject, int source);
void ifcasadi_register_instance(casadi::SharedObject *newobject, int source);
void ifcasadi_free_instances(int verbosity=0);

#endif
