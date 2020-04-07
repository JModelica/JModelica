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

#ifndef _MODELICACASADI_USER_TYPE
#define _MODELICACASADI_USER_TYPE
#include <iostream>
#include <string>
#include <utility>
#include <map>

#include "types/VariableType.hpp"
#include "types/PrimitiveType.hpp"
#include "Ref.hpp"
namespace ModelicaCasADi 
{
/**
 * A class that models user defined types. A user defined type has a name and
 * attributes. A user defined type also has a primitive type that defines whatever
 * default attributes that the user defined type does not define. 
 */
class UserType : public VariableType {
    public:
        /**
         * Create a user defined type from a name and a primitive VariableType.
         * @param A string
         * @param A pointer to a PrimitiveType
         */
        UserType(std::string name, Ref<ModelicaCasADi::PrimitiveType> baseType); 
        /** @return A string */
        const std::string getName() const;
        /**
         * @param An AttributeKey
         * @param An AttributeValue
         */
        void setAttribute(AttributeKey key, AttributeValue val); 
        /** 
         * @param An AttributeKey
         * @return An AttributeValue, returns NULL if not present. 
         */
         AttributeValue* getAttribute(const AttributeKey key);
        /**
         * @param An AttributeKey
         * @return A bool
         */
        bool hasAttribute(const AttributeKey key) const;
        /** Allows the use of the operator << to print this class to a stream, through Printable */
        void print(std::ostream& os) const;

        MODELICACASADI_SHAREDNODE_CHILD_PUBLIC_DEFS
    private:
        const std::string name;
        Ref<ModelicaCasADi::PrimitiveType> baseType;
};

}; // End namespace
#endif
