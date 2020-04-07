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

%module ifcasadi

// Expose the swig-generated function getCPtr as public in the proxy objects;
// we need it to get back the underlying object.
SWIG_JAVABODY_METHODS(public, public, SWIGTYPE)

%{
#include <iostream>
#include <cstdlib>
#include "jni.h"

#include "casadi/casadi.hpp"

using namespace casadi;
using namespace std;
%}

%pragma(java) jniclasscode=%{
    static {
        System.loadLibrary("ifcasadi");
    }
%}

%include "casadi_wrap.i"

%casadi_wrap(casadi::PrintableObject)
%casadi_wrap(casadi::SharedObject)
%casadi_wrap(casadi::GenericType)
%casadi_wrap(casadi::OptionsFunctionality)
%casadi_wrap(casadi::MX)
%casadi_wrap(casadi::Function)
%casadi_wrap(casadi::MXFunction)

%casadi_wrap( std::vector<casadi::MX> )

%include "std_string.i"
%include "std_vector.i"
%include "std_pair.i"

%rename(__neg__) operator-;
%rename(_null) casadi::Sparsity::null;
%rename(toString) __repr__;
%rename(deref1)  casadi::MXFunction::operator->;
%rename(deref2)  casadi::Function::operator->;

#define CASADI_CORE_EXPORT

%include "casadi/core/printable_object.hpp"
%include "casadi/core/shared_object.hpp"
%include "casadi/core/generic_type.hpp"
%include "casadi/core/options_functionality.hpp"
%include "casadi/core/matrix/sparsity.hpp"
%include "casadi/core/mx/mx.hpp"
%include "casadi/core/mx/mx_tools.hpp"
%include "casadi/core/function/function.hpp"
%include "casadi/core/function/mx_function.hpp"


%include "ifcasadi.hpp"

namespace std {
    %template(MXVector) vector<casadi::MX>;
};

%inline %{
// Work around trouble with wrapping MX.sym
casadi::MX msym(const std::string &name) { return casadi::MX::sym(name); }
%}

%{
    // To avoid having to set up separate compilation of ifcasadi.cpp
    #include "ifcasadi.cpp"
%}
