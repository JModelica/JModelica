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
#include "types/RealType.hpp"
namespace ModelicaCasADi 
{
using std::string; using casadi::MX;
RealType::RealType(){
    // Default attributes for non parameter/constant Real type, according to
    // Modelica specification.
    attributes.insert(std::pair<AttributeKeyInternal, AttributeValue>(AttributeKeyInternal("quantity"), MX::sym("")));
    attributes.insert(std::pair<AttributeKeyInternal, AttributeValue>(AttributeKeyInternal("nominal"), MX(1)));
    attributes.insert(std::pair<AttributeKeyInternal, AttributeValue>(AttributeKeyInternal("unit"), MX::sym("")));
    attributes.insert(std::pair<AttributeKeyInternal, AttributeValue>(AttributeKeyInternal("displayUnit"), MX::sym("")));
    attributes.insert(std::pair<AttributeKeyInternal, AttributeValue>(AttributeKeyInternal("min"), MX(-std::numeric_limits<double>::infinity())));
    attributes.insert(std::pair<AttributeKeyInternal, AttributeValue>(AttributeKeyInternal("max"), MX(std::numeric_limits<double>::infinity())));
    attributes.insert(std::pair<AttributeKeyInternal, AttributeValue>(AttributeKeyInternal("start"), MX(0)));
    attributes.insert(std::pair<AttributeKeyInternal, AttributeValue>(AttributeKeyInternal("fixed"), MX(false)));
    //attributes["stateSelect"] = NULL; // TODO
}

VariableType::AttributeValue* RealType::getAttribute(const AttributeKey key) { 
    // If the attribute is in the map, return, otherwise return null. 
    return attributes.find(AttributeKeyInternal(key))!=attributes.end() ? &attributes.find(AttributeKeyInternal(key))->second : NULL;
}
const std::string RealType::getName() const { return "Real"; }
bool RealType::hasAttribute(const AttributeKey key) const { return attributes.find(AttributeKeyInternal(key))!=attributes.end(); }
}; // End namespace
