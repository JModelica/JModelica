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

#ifndef MXFUNCTIONWRAP_HPP
#define MXFUNCTIONWRAP_HPP

#include "casadi/casadi.hpp"
#include "ifcasadi/MXFunction.h"

typedef ifcasadi::MXFunction JMXFunction;

inline casadi::MXFunction toMXFunction(const JMXFunction &jmx) {
    jlong p = JMXFunction::getCPtr(jmx);
    return **(casadi::MXFunction **)&p;
}
#ifdef org_jmodelica_modelica_compiler_FFunctionDecl_H  // if JCC-generated FFunctionDecl.h included:
inline casadi::MXFunction toMXFunction(const org::jmodelica::modelica::compiler::FFunctionDecl &ex) { return toMXFunction(ex.toMXFunction()); }
#endif
#ifdef org_jmodelica_optimica_compiler_FFunctionDecl_H  // if JCC-generated FFunctionDecl.h included:
inline casadi::MXFunction toMXFunction(const org::jmodelica::optimica::compiler::FFunctionDecl &ex) { return toMXFunction(ex.toMXFunction()); }
#endif

inline JMXFunction toJMX(const casadi::MXFunction &ex) {
    casadi::MXFunction *px = new casadi::MXFunction(ex);
    return JMXFunction(*(jlong *)&px, (jboolean)true);
}

#endif
