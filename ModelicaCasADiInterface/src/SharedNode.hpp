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

#ifndef _MODELICACASADI_SHAREDNODE
#define _MODELICACASADI_SHAREDNODE

#include <stdexcept>

#include "Printable.hpp"

// MODELICACASADI_SHAREDNODE_CHILD_PUBLIC_DEFS should be used in the public
// section of all subclasses of SharedNode, which should also be used with
// %instantiate_Ref in the swig files.
#ifdef MODELICACASADI_WITH_SWIG
#define MODELICACASADI_SHAREDNODE_CHILD_PUBLIC_DEFS virtual void *_get_swig_p_type();
#else
#define MODELICACASADI_SHAREDNODE_CHILD_PUBLIC_DEFS
#endif

namespace ModelicaCasADi
{
class SharedNode: public Printable {
    public:
        virtual ~SharedNode() {}
#ifdef MODELICACASADI_WITH_SWIG
        virtual void *_get_swig_p_type();
#endif
};

inline void incRefNode(SharedNode *node) { 
    throw std::runtime_error("incRefNode is not allowed on SharedNode; only subclasses");
}
inline bool decRefNode(SharedNode *node) { 
    throw std::runtime_error("decRefNode is not allowed on SharedNode; only subclasses");
}

}; // End namespace

#endif
