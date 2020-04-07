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

%{
#include "ifcasadi.hpp"
%}

// Typemaps for CasADi types: don't allow java to finalize them, register in allocated-list instead
%define %casadi_wrap(T)

%typemap(out) T {
    $&1_ltype temp = new $1_ltype($1);
    *($&1_ltype*)&$result = temp;
    ifcasadi_register_instance(temp, 0);
}

%typemap(out) const T & {
    $1_ltype temp = new $*1_ltype(*$1);
    *($1_ltype*)&$result = temp;
    ifcasadi_register_instance(temp, 1);
}

//*($&1_ltype)&$result = $1;
//ifcasadi_register_instance($1, 2);
%typemap(out) T * {
    // Force a fresh copy, for safety and because we register it below
    $1_ltype temp = $owner ? $1 : new $*1_ltype(*$1);
    *($&1_ltype)&$result = temp;
    ifcasadi_register_instance(temp, 2 + $owner);
}

%typemap(out) T ** {
    %#error "Unsupported return type for java wrapper: T **"
}

%typemap(out) T & {
    %#error "Unsupported return type for java wrapper: T & "
}

%typemap(javafinalize) T ""

%enddef
