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

#include <vector>
#include "ifcasadi.hpp"

using std::vector;
using casadi::SharedObject;


#include <iostream>
using std::cout; using std::endl; using std::flush;

typedef std::vector<casadi::MX> MXVector;

static std::vector<casadi::SharedObject *> instances;
static std::vector<MXVector *> mxvector_instances;

void ifcasadi_register_instance(casadi::SharedObject *newobject, int source) {
    /*
    cout << char('A'+source) << ": " << flush;
    SharedObjectNode *node = newobject->get();

    cout << newobject << ":\t" << flush;
    cout << node << ": " << flush;
    cout << *newobject << ": " << flush;
    int refcount = node->getCount();
    cout << refcount << endl;
    */
    instances.push_back(newobject);
}

void ifcasadi_register_instance(std::vector<casadi::MX> *newobject, int source) {
    mxvector_instances.push_back(newobject);    
}


void ifcasadi_free_instances(int verbosity) {
    if (verbosity >= 3) {
        cout << "\n## Predisplay:\n" << endl;
        for(std::vector<casadi::SharedObject *>::iterator it = instances.begin(); it != instances.end(); ++it) {
            SharedObject *obj = *it;
            SharedObjectNode *node = obj->get();

            cout << obj << ":\t" << flush;
            cout << node << ": " << flush;
            cout << *obj << ": " << flush;
            int refcount = node->getCount();
            cout << refcount << endl;
        }        
        cout << "\n## Freeing:\n" << endl;
    }

    for(std::vector<casadi::SharedObject *>::iterator it = instances.begin(); it != instances.end(); ++it) {
        SharedObject *obj = *it;
        SharedObjectNode *node = obj->get();

        if (verbosity >= 1) cout << obj << ":\t" << flush;
        if (verbosity >= 1) cout << node << ": " << flush;
        if (verbosity >= 2) cout << *obj << ": " << flush;
        int refcount = node->getCount();
        if (verbosity >= 1) cout << refcount << flush;

        delete(*it);

        if (verbosity >= 1) {
            if (refcount > 0) cout << " --> " << node->getCount();
            cout << endl;
        }
    }
    instances.clear();

    for(std::vector<MXVector *>::iterator it = mxvector_instances.begin(); it != mxvector_instances.end(); ++it) {
        delete(*it);
    }
    mxvector_instances.clear();
}
