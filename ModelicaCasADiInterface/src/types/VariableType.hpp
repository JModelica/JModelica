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

#ifndef _MODELICACASADI_VARIABLE_TYPE
#define _MODELICACASADI_VARIABLE_TYPE
//System includes
#include <iostream>
#include <map>
#include <string>

//Other
#include "casadi/casadi.hpp"
#include "boost/flyweight.hpp"

//ModelicaCasADi
#include "RefCountedNode.hpp"

namespace ModelicaCasADi 
{
/** 
 * Abstract class for types, which models the default attributes of
 * Modelica and Optimica variables, or user defined types. 
 * 
 */
class VariableType : public RefCountedNode {
    public:
        typedef std::string AttributeKey; 
        typedef casadi::MX AttributeValue;
    protected:
        typedef boost::flyweights::flyweight<std::string> AttributeKeyInternal; 
        typedef std::map<AttributeKeyInternal,AttributeValue> attributeMap;  
        attributeMap attributes;
    public: 
        /**
         * @param An AttributeKey
         * @return An AttributeValue, returns NULL if not present. 
         */ 
        virtual AttributeValue* getAttribute(const AttributeKey key) = 0; 
        /** @return A string */
        virtual const std::string getName() const = 0; 
        /** @return A bool */
        virtual bool hasAttribute(const AttributeKey key) const = 0;
        /** Allows the use of the operator << to print this class to a stream, through Printable */
        virtual void print(std::ostream& os) const;

        MODELICACASADI_SHAREDNODE_CHILD_PUBLIC_DEFS
};
}; // End namespace
#endif
