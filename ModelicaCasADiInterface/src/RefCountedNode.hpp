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

#ifndef _MODELICACASADI_REFCOUNTEDNODE
#define _MODELICACASADI_REFCOUNTEDNODE

#include <cassert>

//#define MODELICACASADI_RC_DEBUG(code) code
#define MODELICACASADI_RC_DEBUG(code)
#include <iostream> // if MODELICACASADI_RC_DEBUG

#include "SharedNode.hpp"


namespace ModelicaCasADi
{
class RefCountedNode: public SharedNode {
        friend void incRefNode(RefCountedNode *node);
        friend bool decRefNode(RefCountedNode *node);
    public:
        RefCountedNode() { refCount=0; }
        virtual ~RefCountedNode() { assert(refCount==0); }
        int getCount(){return refCount;}

        MODELICACASADI_SHAREDNODE_CHILD_PUBLIC_DEFS
   private:
        int refCount;
};

// todo: assert that node != NULL in these two?
inline void incRefNode(RefCountedNode *node) { 
    if (node) {
        node->refCount++;
        MODELICACASADI_RC_DEBUG(std::cout << "Increased refCount of " << *node << " to " << node->refCount << std::endl;)
    }        
    else {
        MODELICACASADI_RC_DEBUG(std::cout << "Tried to increase refcount of NULL" << std::endl;)
    }
}

/** \brief Decrease reference count; delete node and return true if it reached 0. */
inline bool decRefNode(RefCountedNode *node) { 
    if (node != NULL) {
        node->refCount--;
        if (node->refCount == 0) {
            MODELICACASADI_RC_DEBUG(std::cout << "Decreased refCount of " << *node << " to 0, deallocating" << std::endl;)
            delete node;
            return true;
        }            
        else {
            MODELICACASADI_RC_DEBUG(std::cout << "Decreased refCount of " << *node << " to " << node->refCount << std::endl;)
        }
    }
    return false;
}
}; // End namespace

#endif
