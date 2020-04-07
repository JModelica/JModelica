/*
    Copyright (C) 2009 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License version 3 as published
    by the Free Software Foundation, or optionally, under the terms of the
    Common Public License version 1.0 as published by IBM.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License, or the Common Public License, for more details.

    You should have received copies of the GNU General Public License
    and the Common Public License along with this program.  If not,
    see <http://www.gnu.org/licenses/> or
    <http://www.ibm.com/developerworks/library/os-cpl.html/> respectively.
*/

#include "jmi_util.h"

void jmi_swap_real(jmi_real_t *dest, jmi_real_t *src) {
    jmi_real_t tmp;
    tmp = *dest;
    *dest = *src;
    *src = tmp;
}

void jmi_swap_string(jmi_string_t *dest, jmi_string_t *src) {
    JMI_DYNAMIC_INIT()
    jmi_string_t tmp;
    JMI_ASG_STR(tmp, *dest);
    JMI_ASG_STR_Z(*dest, *src);
    *src = tmp;
    /* JMI_DYNAMIC_FREE() Is called in surrounding context, src will be used there */
}

void jmi_set_str(char **dest, const char* src, jmi_local_dynamic_function_memory_t* local_block) {
    size_t len = JMI_MIN(JMI_LEN(src), JMI_STR_MAX) + 1;
    if (local_block == NULL) {
        *dest = calloc(len, sizeof(char));
    } else {
        *dest = jmi_dynamic_function_pool_alloc(local_block, len*sizeof(char), FALSE);
    }
    /* strncpy(*dest, src, len); */
    memmove(*dest, src, len*sizeof(char)); /* Handle overlapping regions */
    (*dest)[len-1] = '\0';
}


void jmi_set(jmi_real_t* dest, jmi_real_t src, jmi_array_t* arr, size_t offset) {
	size_t i;
	for(i=offset;i<(offset+arr->num_elems);i++) {
		dest[i] = src;
	}

}

void jmi_copy_to_arr(jmi_array_t* dest, jmi_real_t* src, size_t offset) {
	memcpy(dest->var, src+offset, dest->num_elems*sizeof(jmi_real_t));
}

void jmi_copy_to_ptr(jmi_real_t* dest, jmi_array_t* src, size_t offset) {
	memcpy(dest+offset, src->var, src->num_elems*sizeof(jmi_real_t));
}

#define TRANSPOSE_FUNC(name, src_type, dst_type, to_fortran) \
void name(jmi_array_t* arr, src_type* src, dst_type* dest) { \
    int i, j, tmp1, tmp2, k, n, dim, s; \
 \
    n = arr->num_elems; \
    dim = arr->num_dims; \
 \
    for (i = 0; i < n; i++) { \
        j = 0; \
        tmp1 = i; \
        tmp2 = 0; \
 \
        for (k = 0; k < dim; k++) { \
            s = arr->size[to_fortran ? k : dim - k - 1]; \
            tmp2 = tmp1 % s; \
            tmp1 /= s; \
            j *= s; \
            j += tmp2; \
        } \
 \
        dest[i] = (dst_type) src[j]; \
    } \
}

#define COPY_FUNC(name, src_type, dst_type) \
void name(jmi_array_t* arr, src_type* src, dst_type* dest) { \
    int i, n; \
 \
    n = arr->num_elems; \
    for (i = 0; i < n; i++) { \
        dest[i] = (dst_type) src[i]; \
    } \
}

TRANSPOSE_FUNC(jmi_matrix_to_fortran_real, jmi_real_t, jmi_real_t, 1)
TRANSPOSE_FUNC(jmi_matrix_from_fortran_real, jmi_real_t, jmi_real_t, 0)
TRANSPOSE_FUNC(jmi_matrix_to_fortran_int, jmi_real_t, jmi_int_t, 1)
TRANSPOSE_FUNC(jmi_matrix_from_fortran_int, jmi_int_t, jmi_real_t, 0)
COPY_FUNC(jmi_copy_matrix_to_int, jmi_real_t, jmi_int_t)
COPY_FUNC(jmi_copy_matrix_from_int, jmi_int_t, jmi_real_t)

