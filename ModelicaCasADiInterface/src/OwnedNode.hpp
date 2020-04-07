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

#ifndef _MODELICACASADI_OWNEDNODE
#define _MODELICACASADI_OWNEDNODE

#include <cassert>

#include "SharedNode.hpp"
#include "RefCountedNode.hpp"


namespace ModelicaCasADi
{
class OwnedNode: public SharedNode {
        friend void incRefNode(OwnedNode *node);
        friend bool decRefNode(OwnedNode *node);
    public:
        OwnedNode(RefCountedNode *owner) { assert(owner != NULL); this->owner = owner; }

        bool isOwnedBy(RefCountedNode *owner) { return owner == this->owner; }

        MODELICACASADI_SHAREDNODE_CHILD_PUBLIC_DEFS
   protected:
        RefCountedNode *owner; // Should not be modified once the OwnedNode has been constructed.
};

inline void incRefNode(OwnedNode *node) { if (node) incRefNode(node->owner); }

/** \brief Decrease reference count; delete node and return true if it reached 0. */
inline bool decRefNode(OwnedNode *node) { 
    if (node != NULL) {
        // If the owner is released, it will release all of its owned nodes as well, including this one.
        return decRefNode(node->owner);
    }
    return false;
}
}; // End namespace

#endif
