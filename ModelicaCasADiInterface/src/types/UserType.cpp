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

#include "types/UserType.hpp"
using std::string; using std::ostream;
namespace ModelicaCasADi 
{
UserType::UserType(string name, Ref<PrimitiveType> baseType) : name(name), baseType(baseType) {
}

VariableType::AttributeValue* UserType::getAttribute(const AttributeKey key) { 
    return attributes.find(AttributeKeyInternal(key)) != attributes.end() ? &attributes.find(AttributeKeyInternal(key))->second : baseType.getNode()->getAttribute(key);
}


bool UserType::hasAttribute(const AttributeKey key) const { 
    return (attributes.find(AttributeKeyInternal(key)) != attributes.end() || baseType.getNode()->hasAttribute(key));
}

void UserType::print(ostream& os) const { 
    os << getName() << " type = " << baseType->getName() << " (";
    std::string sep("");
    for(attributeMap::const_iterator it = attributes.begin(); it != attributes.end(); ++it){
        os << sep << (it->first) << " = ";
        os << ModelicaCasADi::normalizeMXRespresentation(it->second);
        sep = ", ";
    }
    os << ");";
}
const std::string UserType::getName() const { return name; }
void UserType::setAttribute(AttributeKey key, AttributeValue val) { attributes.insert(std::pair<AttributeKeyInternal, AttributeValue>(AttributeKeyInternal(key), val)); }
}; 
