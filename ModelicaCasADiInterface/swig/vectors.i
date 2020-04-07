
%include "std_string.i"

// -------- Typemaps for vector< double > --------

%typemap(in) const std::vector< double > & (std::vector< double > vec) {
    PyArrayObject *array = (PyArrayObject *)PyArray_FROMANY($input, NPY_DOUBLE, 1, 1, NPY_IN_ARRAY);
    if (!array) SWIG_fail;
    
    size_t size = PyArray_DIM(array, 0);
    vec.reserve(size);

    std::vector< double > &dest = *$1;
    double *data = (double *)PyArray_DATA(array);
    for (int k=0; k < size; k++) {
        vec.push_back(data[k]);
    }

    Py_DECREF(array); // PyArray_FROMANY created a new reference
    $1 = &vec;
}

%typemap(typecheck, precedence=SWIG_TYPECHECK_VECTOR) const std::vector< double > &{
    // Assume that anything that is iterable or is a sequence can be
    // converted to a vector
    $1 = PyIter_Check($input) || PySequence_Check($input);
}

%typemap(out) std::vector< double > {
    size_t size = $1.size();
    PyObject *array;

    npy_intp shape[1] = {size};
    array = PyArray_SimpleNew(1, shape, NPY_DOUBLE);
    if (!array) SWIG_fail;
    
    double *data = (double *)PyArray_DATA(array);
    std::vector< double > &vec = $1;
    for (int k=0; k < size; k++) {
        data[k] = $1[k];
    }

    $result = array;
}


// -------- Typemaps for vector< std::string > --------

%typemap(in) const std::vector< std::string > & (std::vector< std::string > vec) {
    PyArrayObject *array = (PyArrayObject *)PyArray_FROMANY($input, NPY_OBJECT, 1, 1, NPY_IN_ARRAY);
    if (!array) SWIG_fail;
    
    size_t size =  PyArray_DIM(array, 0);
    vec.reserve(size);

//    std::vector< std::string > &dest = *$1;
    PyObject **data = (PyObject **)PyArray_DATA(array);
    for (int k=0; k < size; k++) {
        // Invoke in typemap for std::string
        PyObject *$input = data[k];
        std::string $1;

        $typemap(in, std::string)

        vec.push_back($1);
    }

    Py_DECREF(array); // PyArray_FROMANY created a new reference
    $1 = &vec;
}

%typemap(typecheck, precedence=SWIG_TYPECHECK_VECTOR) const std::vector< std::string > &{
    // Assume that anything that is iterable or is a sequence can be
    // converted to a vector
    $1 = PyIter_Check($input) || PySequence_Check($input);
}

%typemap(out) std::vector< std::string > {
    size_t size = $1.size();
    PyObject *array;

    npy_intp shape[1] = {size};
    array = PyArray_SimpleNew(1, shape, NPY_OBJECT);
    if (!array) SWIG_fail;
    
    PyObject **data = (PyObject **)PyArray_DATA(array);
    std::vector< std::string > &vec = $1;
    for (int k=0; k < size; k++) {
        // Invoke out typemap for std::string
        const std::string &$1 = vec[k];
        PyObject *$result;

        $typemap(out, std::string)

        data[k] = $result;
    }

    $result = array;
}
