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

%include "Ref.hpp"

// Create input typemaps for Ref<T> and const vector< Ref<T> >&,
// and ouput typemaps for Ref<T> and vector< Ref<T> >
%define %instantiate_Ref(N,T)
%_instantiate_Ref(%arg(ModelicaCasADi::Ref< N::T >), %arg(N::T), %arg(N##__##T))
%enddef


%{
#include "numpy/arrayobject.h"
%}

// Dummy definition to allow to instantiate std::vector.
// May collide with std_vector.i
namespace std {
    template<class _Tp, class _Alloc = std::allocator< _Tp > >
    class vector {};
}

// NB: We have this feature on SharedNode, but the actual implementation on
// SharedNode throws an error, since we should only work with statically known
// subclasses of it.
%feature("ref")   ModelicaCasADi::SharedNode "ModelicaCasADi::incRefNode($this);"
%feature("unref") ModelicaCasADi::SharedNode "ModelicaCasADi::decRefNode($this);"


// For internal use. RefT should be ModelicaCasADi::Ref< T >
%define %_instantiate_Ref(RefT, T, SWIGT)

// -------- Typemaps for Ref<T> --------

%typemap(in) RefT {
    T *node;
    {
        T *$1;
        $typemap(in, T *)
        node = $1;
    }
    $1.setNode(node);
}

%typemap(typecheck,precedence=SWIG_TYPECHECK_POINTER) RefT {
    $typemap(typecheck, T *)
}

%typemap(in) const RefT & (RefT ref) {
    T *node;
    {
        T *$1;
        $typemap(in, T *)
        node = $1;
    }
    ref.setNode(node);
    $1 = &ref;
}

%typemap(typecheck,precedence=SWIG_TYPECHECK_POINTER) const RefT &{
    $typemap(typecheck, T *)
}

//%typemap(out, fragment="GetSWIGType"{T}) RefT {
%typemap(out) RefT {
    T *node = $1.getNode();
    incRefNode(node);
//    $result = SWIG_NewPointerObj(SWIG_as_voidptr(node), $descriptor(T *), SWIG_POINTER_OWN);
    $result = SWIG_NewPointerObj(SWIG_as_voidptr(node),
        node ? (swig_type_info *)node->_get_swig_p_type() : $descriptor(T *),
        SWIG_POINTER_OWN);
}

/*
%fragment("GetSWIGType"{T}, "header") {
void *T::_get_swig_p_type() {
    // return (void *)$descriptor(T *); // should work with new enough SWIG
    return (void *)(SWIGTYPE_p_ ## SWIGT);
}
}
*/

%header {
void *T::_get_swig_p_type() {
    // return (void *)$descriptor(T *); // should work with new enough SWIG
    return (void *)(SWIGTYPE_p_ ## SWIGT);
}
}


// -------- Typemaps for vector< Ref<T> > --------

%typemap(in) const std::vector< RefT > & (std::vector< RefT > vec) {
    PyArray_Descr *dtype = PyArray_DescrFromType(NPY_OBJECT);
    PyArrayObject *array = (PyArrayObject *)PyArray_FromAny($input, dtype, 
        1, 1, NPY_IN_ARRAY, NULL);
    if (!array) SWIG_fail;
    
    size_t size =  PyArray_DIM(array, 0);
    vec.reserve(size);

    std::vector< RefT > &dest = *$1;
    PyObject **data = (PyObject **)PyArray_DATA(array);
    for (int k=0; k < size; k++) {
        // Invoke in typemap for T *
        PyObject *$input = data[k];
        T *$1;

        $typemap(in, T *)

        vec.push_back(RefT($1));
    }

    Py_DECREF(array); // PyArray_FromAny created a new reference
    $1 = &vec;
}

%typemap(typecheck, precedence=SWIG_TYPECHECK_VECTOR) const std::vector< RefT > &{
    // Assume that anything that is iterable or is a sequence can be
    // converted to a vector
    $1 = PyIter_Check($input) || PySequence_Check($input);
}

%typemap(out) std::vector< RefT > {
    size_t size = $1.size();
    PyObject *array;

    npy_intp shape[1] = {size};
    array = PyArray_SimpleNew(1, shape, NPY_OBJECT);
    if (!array) SWIG_fail;
    
    PyObject **data = (PyObject **)PyArray_DATA(array);
    std::vector< RefT > &vec = $1;
    for (int k=0; k < size; k++) {
        // Invoke out typemap for Ref<T>
        RefT &$1 = vec[k];
        PyObject *$result;

        $typemap(out, RefT)

        data[k] = $result;
    }

    $result = array;
}


// -------- Template instantiations --------

%template() RefT;
%template() std::vector< RefT >;

%enddef
