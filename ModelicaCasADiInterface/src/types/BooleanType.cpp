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
#include <utility>
#include "casadi/casadi.hpp"
#include "types/BooleanType.hpp"
namespace ModelicaCasADi 
{
using std::string; using casadi::MX;
BooleanType::BooleanType() {
    // Default attributes for non parameter/constant Boolean type, according to
    // Modelica specification.
    attributes.insert(std::pair<AttributeKeyInternal, AttributeValue>(AttributeKeyInternal("quantity"), MX::sym("")));
    attributes.insert(std::pair<AttributeKeyInternal, AttributeValue>(AttributeKeyInternal("start"), MX(false)));
    attributes.insert(std::pair<AttributeKeyInternal, AttributeValue>(AttributeKeyInternal("fixed"), MX(false)));
}

VariableType::AttributeValue* BooleanType::getAttribute(const AttributeKey key) { 
    // If the attribute is in the map, return, otherwise return null. 
    return attributes.find(AttributeKeyInternal(key))!=attributes.end() ? &attributes.find(AttributeKeyInternal(key))->second : NULL;
}
const std::string BooleanType::getName() const { return "Boolean"; }
bool BooleanType::hasAttribute(const AttributeKey key) const { return attributes.find(AttributeKeyInternal(key))!=attributes.end(); }
}; // End namespace
