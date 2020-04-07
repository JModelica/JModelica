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



/** \file jmi_array_none.h
 *  \brief Handling of arrays in the JMI interface, version without AD.
 *
 *  Note that arrays are only used in functions at this point.
 */

#ifndef _JMI_ARRAY_NONE_H
#define _JMI_ARRAY_NONE_H

#include <stdlib.h>
#include "jmi_dyn_mem.h"

/**
 * Copy src to dest. Use local_block memory allocation if available, otherwise malloc.
 */
void jmi_set_str(char **dest, const char* src, jmi_local_dynamic_function_memory_t* local_block);

/*
 * Array type declaration macro.
 * Used for primitive types here and record types in generated code.
 */
#define JMI_ARRAY_TYPE(rec, arr) \
    typedef struct _##arr {\
        int* size;\
        int  num_dims;\
        int  num_elems;\
        int  num_elems_alloced;\
        rec* var;\
    } arr;

/* Array structs for primitive types */
JMI_ARRAY_TYPE(jmi_real_t  , jmi_array_t)
JMI_ARRAY_TYPE(jmi_int_t   , jmi_int_array_t)
JMI_ARRAY_TYPE(jmi_string_t, jmi_string_array_t)
JMI_ARRAY_TYPE(jmi_extobj_t, jmi_extobj_array_t)

/* Size macro - gives the size of array arr for dimension d */
#define jmi_array_size(arr, d) ((arr)->size[(int) d])

/* Array decl macro, delegates*/
#define JMI_ARR(dyn, type, arr, name, ne, nd) \
    JMI_ARRAY_DECL_##dyn(type, arr, name, ne, nd)

/* Array init macro, delegates*/
#define JMI_ARRAY_INIT(dyn, type, arr, name, ne, nd) \
    JMI_ARRAY_INIT_##dyn(type, arr, name, ne, nd)

/* Stack array declaration macro */
#define JMI_ARRAY_DECL_STACK(type, arr, name, ne, nd) \
    int  name##_size[nd];\
    type name##_var[(ne == 0) ? 1 : ne] = {0};\
    arr  name##_obj = { NULL, (int) (nd), (int) (ne), 0, NULL };\
    arr* name = &name##_obj;

/* Data section array declaration macro */
#define JMI_ARRAY_DECL_DATA(type, arr, name, ne, nd) \
    static int  name##_size[nd];\
    static arr  name##_obj = { name##_size, (int) (nd), (int) (ne), 0, name##_var};\
    static arr* name = &name##_obj;

/* Heap array declaration macro */
#define JMI_ARRAY_DECL_HEAP(type, arr, name, ne, nd) \
    arr* name = NULL;

/* Stack array initialization macros */
#define JMI_ARRAY_INIT_STACK(type, arr, name, ne, nd) \
    name->size = name##_size; \
    name->var = name##_var;

/* Data section initialization */
#define JMI_ARRAY_INIT_DATA(type, arr, name, ne, nd) \
    ;

/* Heap array initialization macros.
 * Might be called several times for the same name. */
#define JMI_ARRAY_INIT_HEAP(type, arr, name, ne, nd) \
    if (name == NULL) {\
        char *tmp_ptr = jmi_dynamic_function_pool_alloc(&dyn_mem, 1*sizeof(arr)+nd*sizeof(int)+ne*sizeof(type), TRUE);\
        name            = (arr*) tmp_ptr;\
        name->num_dims  = (int)  (nd);\
        name->size      = (int*) (tmp_ptr+sizeof(arr));\
        name->num_elems = (int) (ne);\
        name->num_elems_alloced = (int) (ne);\
        name->var = (type*) (tmp_ptr+sizeof(arr)+(int)nd*sizeof(int));\
    } else if ((name->num_elems = (int) (ne)) > name->num_elems_alloced) {\
        name->var = (type*) jmi_dynamic_function_pool_alloc(&dyn_mem, name->num_elems*sizeof(type), TRUE);\
        name->num_elems_alloced = name->num_elems;\
    }

#define JMI_ARRAY_INIT_1(dyn, type, arr, name, ne, nd, d1) \
    JMI_ARRAY_INIT(dyn, type, arr, name, ne, nd) \
    name->size[0] = (int) (d1);
#define JMI_ARRAY_INIT_2(dyn, type, arr, name, ne, nd, d1, d2) \
    JMI_ARRAY_INIT_1(dyn, type, arr, name, ne, nd, d1)\
    name->size[1] = (int) (d2);
#define JMI_ARRAY_INIT_3(dyn, type, arr, name, ne, nd, d1, d2, d3) \
    JMI_ARRAY_INIT_2(dyn, type, arr, name, ne, nd, d1, d2)\
    name->size[2] = (int) (d3);
#define JMI_ARRAY_INIT_4(dyn, type, arr, name, ne, nd, d1, d2, d3, d4) \
    JMI_ARRAY_INIT_3(dyn, type, arr, name, ne, nd, d1, d2, d3)\
    name->size[3] = (int) (d4);
#define JMI_ARRAY_INIT_5(dyn, type, arr, name, ne, nd, d1, d2, d3, d4, d5) \
    JMI_ARRAY_INIT_4(dyn, type, arr, name, ne, nd, d1, d2, d3, d4)\
    name->size[4] = (int) (d5);
#define JMI_ARRAY_INIT_6(dyn, type, arr, name, ne, nd, d1, d2, d3, d4, d5, d6) \
    JMI_ARRAY_INIT_5(dyn, type, arr, name, ne, nd, d1, d2, d3, d4, d5)\
    name->size[5] = (int) (d6);
#define JMI_ARRAY_INIT_7(dyn, type, arr, name, ne, nd, d1, d2, d3, d4, d5, d6, d7) \
    JMI_ARRAY_INIT_6(dyn, type, arr, name, ne, nd, d1, d2, d3, d4, d5, d6)\
    name->size[6] = (int) (d7);
#define JMI_ARRAY_INIT_8(dyn, type, arr, name, ne, nd, d1, d2, d3, d4, d5, d6, d7, d8) \
    JMI_ARRAY_INIT_7(dyn, type, arr, name, ne, nd, d1, d2, d3, d4, d5, d6, d7)\
    name->size[7] = (int) (d8);
#define JMI_ARRAY_INIT_9(dyn, type, arr, name, ne, nd, d1, d2, d3, d4, d5, d6, d7, d8, d9) \
    JMI_ARRAY_INIT_8(dyn, type, arr, name, ne, nd, d1, d2, d3, d4, d5, d6, d7, d8)\
    name->size[8] = (int) (d9);
#define JMI_ARRAY_INIT_10(dyn, type, arr, name, ne, nd, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10) \
    JMI_ARRAY_INIT_9(dyn, type, arr, name, ne, nd, d1, d2, d3, d4, d5, d6, d7, d8, d9)\
    name->size[9] = (int) (d10);
#define JMI_ARRAY_INIT_11(dyn, type, arr, name, ne, nd, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11) \
    JMI_ARRAY_INIT_10(dyn, type, arr, name, ne, nd, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10)\
    name->size[10] = (int) (d11);
#define JMI_ARRAY_INIT_12(dyn, type, arr, name, ne, nd, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12) \
    JMI_ARRAY_INIT_11(dyn, type, arr, name, ne, nd, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11)\
    name->size[11] = (int) (d12);
#define JMI_ARRAY_INIT_13(dyn, type, arr, name, ne, nd, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13) \
    JMI_ARRAY_INIT_12(dyn, type, arr, name, ne, nd, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12)\
    name->size[12] = (int) (d13);
#define JMI_ARRAY_INIT_14(dyn, type, arr, name, ne, nd, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14) \
    JMI_ARRAY_INIT_13(dyn, type, arr, name, ne, nd, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13)\
    name->size[13] = (int) (d14);
#define JMI_ARRAY_INIT_15(dyn, type, arr, name, ne, nd, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15) \
    JMI_ARRAY_INIT_14(dyn, type, arr, name, ne, nd, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14)\
    name->size[14] = (int) (d15);
#define JMI_ARRAY_INIT_16(dyn, type, arr, name, ne, nd, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16) \
    JMI_ARRAY_INIT_15(dyn, type, arr, name, ne, nd, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15)\
    name->size[15] = (int) (d16);
#define JMI_ARRAY_INIT_17(dyn, type, arr, name, ne, nd, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17) \
    JMI_ARRAY_INIT_16(dyn, type, arr, name, ne, nd, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16)\
    name->size[16] = (int) (d17);
#define JMI_ARRAY_INIT_18(dyn, type, arr, name, ne, nd, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18) \
    JMI_ARRAY_INIT_17(dyn, type, arr, name, ne, nd, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17)\
    name->size[17] = (int) (d18);
#define JMI_ARRAY_INIT_19(dyn, type, arr, name, ne, nd, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19) \
    JMI_ARRAY_INIT_18(dyn, type, arr, name, ne, nd, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18)\
    name->size[18] = (int) (d19);
#define JMI_ARRAY_INIT_20(dyn, type, arr, name, ne, nd, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20) \
    JMI_ARRAY_INIT_19(dyn, type, arr, name, ne, nd, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19)\
    name->size[19] = (int) (d20);
#define JMI_ARRAY_INIT_21(dyn, type, arr, name, ne, nd, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21) \
    JMI_ARRAY_INIT_20(dyn, type, arr, name, ne, nd, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20)\
    name->size[20] = (int) (d21);
#define JMI_ARRAY_INIT_22(dyn, type, arr, name, ne, nd, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22) \
    JMI_ARRAY_INIT_21(dyn, type, arr, name, ne, nd, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21)\
    name->size[21] = (int) (d22);
#define JMI_ARRAY_INIT_23(dyn, type, arr, name, ne, nd, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22, d23) \
    JMI_ARRAY_INIT_22(dyn, type, arr, name, ne, nd, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22)\
    name->size[22] = (int) (d23);
#define JMI_ARRAY_INIT_24(dyn, type, arr, name, ne, nd, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22, d23, d24) \
    JMI_ARRAY_INIT_23(dyn, type, arr, name, ne, nd, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22, d23)\
    name->size[23] = (int) (d24);
#define JMI_ARRAY_INIT_25(dyn, type, arr, name, ne, nd, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22, d23, d24, d25) \
    JMI_ARRAY_INIT_24(dyn, type, arr, name, ne, nd, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22, d23, d24)\
    name->size[24] = (int) (d25);

/* Record array access macros */
#define jmi_array_rec_1(arr, i1) (&((arr)->var[(int) _JMI_ARR_I_1(arr, i1)]))
#define jmi_array_rec_2(arr, i1, i2) (&((arr)->var[(int) _JMI_ARR_I_2(arr, i1, i2)]))
#define jmi_array_rec_3(arr, i1, i2, i3) (&((arr)->var[(int) _JMI_ARR_I_3(arr, i1, i2, i3)]))
#define jmi_array_rec_4(arr, i1, i2, i3, i4) (&((arr)->var[(int) _JMI_ARR_I_4(arr, i1, i2, i3, i4)]))
#define jmi_array_rec_5(arr, i1, i2, i3, i4, i5) (&((arr)->var[(int) _JMI_ARR_I_5(arr, i1, i2, i3, i4, i5)]))
#define jmi_array_rec_6(arr, i1, i2, i3, i4, i5, i6) (&((arr)->var[(int) _JMI_ARR_I_6(arr, i1, i2, i3, i4, i5, i6)]))
#define jmi_array_rec_7(arr, i1, i2, i3, i4, i5, i6, i7) (&((arr)->var[(int) _JMI_ARR_I_7(arr, i1, i2, i3, i4, i5, i6, i7)]))
#define jmi_array_rec_8(arr, i1, i2, i3, i4, i5, i6, i7, i8) (&((arr)->var[(int) _JMI_ARR_I_8(arr, i1, i2, i3, i4, i5, i6, i7, i8)]))
#define jmi_array_rec_9(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9) (&((arr)->var[(int) _JMI_ARR_I_9(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9)]))
#define jmi_array_rec_10(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10) (&((arr)->var[(int) _JMI_ARR_I_10(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10)]))
#define jmi_array_rec_11(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11) (&((arr)->var[(int) _JMI_ARR_I_11(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11)]))
#define jmi_array_rec_12(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12) (&((arr)->var[(int) _JMI_ARR_I_12(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12)]))
#define jmi_array_rec_13(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13) (&((arr)->var[(int) _JMI_ARR_I_13(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13)]))
#define jmi_array_rec_14(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14) (&((arr)->var[(int) _JMI_ARR_I_14(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14)]))
#define jmi_array_rec_15(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15) (&((arr)->var[(int) _JMI_ARR_I_15(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15)]))
#define jmi_array_rec_16(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16) (&((arr)->var[(int) _JMI_ARR_I_16(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16)]))
#define jmi_array_rec_17(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17) (&((arr)->var[(int) _JMI_ARR_I_17(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17)]))
#define jmi_array_rec_18(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18) (&((arr)->var[(int) _JMI_ARR_I_18(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18)]))
#define jmi_array_rec_19(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19) (&((arr)->var[(int) _JMI_ARR_I_19(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19)]))
#define jmi_array_rec_20(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20) (&((arr)->var[(int) _JMI_ARR_I_20(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20)]))
#define jmi_array_rec_21(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21) (&((arr)->var[(int) _JMI_ARR_I_21(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21)]))
#define jmi_array_rec_22(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22) (&((arr)->var[(int) _JMI_ARR_I_22(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22)]))
#define jmi_array_rec_23(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23) (&((arr)->var[(int) _JMI_ARR_I_23(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23)]))
#define jmi_array_rec_24(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23, i24) (&((arr)->var[(int) _JMI_ARR_I_24(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23, i24)]))
#define jmi_array_rec_25(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23, i24, i25) (&((arr)->var[(int) _JMI_ARR_I_25(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23, i24, i25)]))

/* Access macros */
#define jmi_array_val_1(arr, i1) (arr)->var[(int) _JMI_ARR_I_1(arr, i1)]
#define jmi_array_val_2(arr, i1, i2) (arr)->var[(int) _JMI_ARR_I_2(arr, i1, i2)]
#define jmi_array_val_3(arr, i1, i2, i3) (arr)->var[(int) _JMI_ARR_I_3(arr, i1, i2, i3)]
#define jmi_array_val_4(arr, i1, i2, i3, i4) (arr)->var[(int) _JMI_ARR_I_4(arr, i1, i2, i3, i4)]
#define jmi_array_val_5(arr, i1, i2, i3, i4, i5) (arr)->var[(int) _JMI_ARR_I_5(arr, i1, i2, i3, i4, i5)]
#define jmi_array_val_6(arr, i1, i2, i3, i4, i5, i6) (arr)->var[(int) _JMI_ARR_I_6(arr, i1, i2, i3, i4, i5, i6)]
#define jmi_array_val_7(arr, i1, i2, i3, i4, i5, i6, i7) (arr)->var[(int) _JMI_ARR_I_7(arr, i1, i2, i3, i4, i5, i6, i7)]
#define jmi_array_val_8(arr, i1, i2, i3, i4, i5, i6, i7, i8) (arr)->var[(int) _JMI_ARR_I_8(arr, i1, i2, i3, i4, i5, i6, i7, i8)]
#define jmi_array_val_9(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9) (arr)->var[(int) _JMI_ARR_I_9(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9)]
#define jmi_array_val_10(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10) (arr)->var[(int) _JMI_ARR_I_10(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10)]
#define jmi_array_val_11(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11) (arr)->var[(int) _JMI_ARR_I_11(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11)]
#define jmi_array_val_12(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12) (arr)->var[(int) _JMI_ARR_I_12(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12)]
#define jmi_array_val_13(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13) (arr)->var[(int) _JMI_ARR_I_13(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13)]
#define jmi_array_val_14(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14) (arr)->var[(int) _JMI_ARR_I_14(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14)]
#define jmi_array_val_15(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15) (arr)->var[(int) _JMI_ARR_I_15(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15)]
#define jmi_array_val_16(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16) (arr)->var[(int) _JMI_ARR_I_16(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16)]
#define jmi_array_val_17(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17) (arr)->var[(int) _JMI_ARR_I_17(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17)]
#define jmi_array_val_18(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18) (arr)->var[(int) _JMI_ARR_I_18(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18)]
#define jmi_array_val_19(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19) (arr)->var[(int) _JMI_ARR_I_19(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19)]
#define jmi_array_val_20(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20) (arr)->var[(int) _JMI_ARR_I_20(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20)]
#define jmi_array_val_21(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21) (arr)->var[(int) _JMI_ARR_I_21(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21)]
#define jmi_array_val_22(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22) (arr)->var[(int) _JMI_ARR_I_22(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22)]
#define jmi_array_val_23(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23) (arr)->var[(int) _JMI_ARR_I_23(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23)]
#define jmi_array_val_24(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23, i24) (arr)->var[(int) _JMI_ARR_I_24(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23, i24)]
#define jmi_array_val_25(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23, i24, i25) (arr)->var[(int) _JMI_ARR_I_25(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23, i24, i25)]

/* Reference macros */
#define jmi_array_ref_1  jmi_array_val_1
#define jmi_array_ref_2  jmi_array_val_2
#define jmi_array_ref_3  jmi_array_val_3
#define jmi_array_ref_4  jmi_array_val_4
#define jmi_array_ref_5  jmi_array_val_5
#define jmi_array_ref_6  jmi_array_val_6
#define jmi_array_ref_7  jmi_array_val_7
#define jmi_array_ref_8  jmi_array_val_8
#define jmi_array_ref_9  jmi_array_val_9
#define jmi_array_ref_10 jmi_array_val_10
#define jmi_array_ref_11 jmi_array_val_11
#define jmi_array_ref_12 jmi_array_val_12
#define jmi_array_ref_13 jmi_array_val_13
#define jmi_array_ref_14 jmi_array_val_14
#define jmi_array_ref_15 jmi_array_val_15
#define jmi_array_ref_16 jmi_array_val_16
#define jmi_array_ref_17 jmi_array_val_17
#define jmi_array_ref_18 jmi_array_val_18
#define jmi_array_ref_19 jmi_array_val_19
#define jmi_array_ref_20 jmi_array_val_20
#define jmi_array_ref_21 jmi_array_val_21
#define jmi_array_ref_22 jmi_array_val_22
#define jmi_array_ref_23 jmi_array_val_23
#define jmi_array_ref_24 jmi_array_val_24
#define jmi_array_ref_25 jmi_array_val_25

/* Index macros - only for use in definitions of jmi_array_* functions & macros */
#define _JMI_ARR_I_1(arr, i1) (i1-1)
#define _JMI_ARR_I_2(arr, i1, i2) (_JMI_ARR_I_1(arr, i1)*(arr)->size[1]+i2-1)
#define _JMI_ARR_I_3(arr, i1, i2, i3) (_JMI_ARR_I_2(arr, i1, i2)*(arr)->size[2]+i3-1)
#define _JMI_ARR_I_4(arr, i1, i2, i3, i4) (_JMI_ARR_I_3(arr, i1, i2, i3)*(arr)->size[3]+i4-1)
#define _JMI_ARR_I_5(arr, i1, i2, i3, i4, i5) (_JMI_ARR_I_4(arr, i1, i2, i3, i4)*(arr)->size[4]+i5-1)
#define _JMI_ARR_I_6(arr, i1, i2, i3, i4, i5, i6) (_JMI_ARR_I_5(arr, i1, i2, i3, i4, i5)*(arr)->size[5]+i6-1)
#define _JMI_ARR_I_7(arr, i1, i2, i3, i4, i5, i6, i7) (_JMI_ARR_I_6(arr, i1, i2, i3, i4, i5, i6)*(arr)->size[6]+i7-1)
#define _JMI_ARR_I_8(arr, i1, i2, i3, i4, i5, i6, i7, i8) (_JMI_ARR_I_7(arr, i1, i2, i3, i4, i5, i6, i7)*(arr)->size[7]+i8-1)
#define _JMI_ARR_I_9(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9) (_JMI_ARR_I_8(arr, i1, i2, i3, i4, i5, i6, i7, i8)*(arr)->size[8]+i9-1)
#define _JMI_ARR_I_10(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10) (_JMI_ARR_I_9(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9)*(arr)->size[9]+i10-1)
#define _JMI_ARR_I_11(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11) (_JMI_ARR_I_10(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10)*(arr)->size[10]+i11-1)
#define _JMI_ARR_I_12(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12) (_JMI_ARR_I_11(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11)*(arr)->size[11]+i12-1)
#define _JMI_ARR_I_13(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13) (_JMI_ARR_I_12(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12)*(arr)->size[12]+i13-1)
#define _JMI_ARR_I_14(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14) (_JMI_ARR_I_13(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13)*(arr)->size[13]+i14-1)
#define _JMI_ARR_I_15(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15) (_JMI_ARR_I_14(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14)*(arr)->size[14]+i15-1)
#define _JMI_ARR_I_16(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16) (_JMI_ARR_I_15(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15)*(arr)->size[15]+i16-1)
#define _JMI_ARR_I_17(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17) (_JMI_ARR_I_16(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16)*(arr)->size[16]+i17-1)
#define _JMI_ARR_I_18(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18) (_JMI_ARR_I_17(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17)*(arr)->size[17]+i18-1)
#define _JMI_ARR_I_19(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19) (_JMI_ARR_I_18(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18)*(arr)->size[18]+i19-1)
#define _JMI_ARR_I_20(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20) (_JMI_ARR_I_19(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19)*(arr)->size[19]+i20-1)
#define _JMI_ARR_I_21(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21) (_JMI_ARR_I_20(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20)*(arr)->size[20]+i21-1)
#define _JMI_ARR_I_22(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22) (_JMI_ARR_I_21(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21)*(arr)->size[21]+i22-1)
#define _JMI_ARR_I_23(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23) (_JMI_ARR_I_22(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22)*(arr)->size[22]+i23-1)
#define _JMI_ARR_I_24(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23, i24) (_JMI_ARR_I_23(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23)*(arr)->size[23]+i24-1)
#define _JMI_ARR_I_25(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23, i24, i25) (_JMI_ARR_I_24(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23, i24)*(arr)->size[24]+i25-1)

#define JMI_DEF(TYPE, NAME) \
    JMI_DEF_##TYPE(NAME)
#define JMI_DEF_REA(NAME) \
    jmi_real_t NAME = 0;
#define JMI_DEF_INT(NAME) \
    JMI_DEF_REA(NAME)
#define JMI_DEF_BOO(NAME) \
    JMI_DEF_REA(NAME)
#define JMI_DEF_ENU(NAME) \
    JMI_DEF_REA(NAME)
#define JMI_DEF_STR(NAME) \
    jmi_string_t NAME = "";
#define JMI_DEF_EXO(NAME) \
    jmi_extobj_t NAME = NULL;

#define JMI_DEF_REA_EXT(NAME) \
    JMI_DEF_REA(NAME)
#define JMI_DEF_INT_EXT(NAME) \
    jmi_int_t NAME = 0;
#define JMI_DEF_BOO_EXT(NAME) \
    JMI_DEF_INT_EXT(NAME)
#define JMI_DEF_ENU_EXT(NAME) \
    JMI_DEF_INT_EXT(NAME)
#define JMI_DEF_STR_EXT(NAME) \
    JMI_DEF_STR(NAME)
#define JMI_DEF_EXO_EXT(NAME) \
    JMI_DEF_EXO(NAME)

/* Max allowed length of strings */
#define JMI_STR_MAX 16 * 1024 - 1

/* Declaration for string */
#define JMI_DEF_STR_STAT(NAME, LEN) \
    size_t NAME##_len = JMI_MIN(LEN, JMI_STR_MAX) + 1; \
    char NAME[JMI_MIN(LEN, JMI_STR_MAX) + 1];
#define JMI_DEF_STR_DYNA(NAME) \
    size_t NAME##_len; \
    jmi_string_t NAME;

/* Initialization of strings from expressions */
#define JMI_INI_STR_STAT(NAME) \
    NAME[0] = '\0';
#define JMI_INI_STR_DYNA(NAME, LEN) \
    NAME##_len = JMI_MIN(LEN, JMI_STR_MAX) + 1; \
    NAME = jmi_dynamic_function_pool_alloc(&dyn_mem, JMI_MIN(LEN, JMI_STR_MAX) + 1, TRUE); \
    JMI_INI_STR_STAT(NAME)

/* Initialization of function variables */
#define JMI_INI(TYPE, NAME) \
    JMI_INI_##TYPE(NAME)
#define JMI_INI_STR(NAME) \
    NAME = "";

/* Assign (copy) SRC to DEST */
#define JMI_ASG(TYPE, DEST, SRC) \
    JMI_ASG_##TYPE(DEST, SRC)
#define JMI_ASG_GEN(DEST, SRC) \
	DEST = SRC;
#define JMI_ASG_GEN_ARR(DEST, SRC) \
    { \
      int i; \
      for (i = 1; i <= DEST->num_elems; i++) { \
        jmi_array_ref_1(DEST,i) = jmi_array_val_1(SRC,i); \
      }\
    }

/* Assign string not in z vector */
#define JMI_ASG_STR(DEST,SRC) \
    jmi_set_str(&(DEST), SRC, &dyn_mem);

/* Assign string in z vector */
#define JMI_ASG_STR_Z(DEST,SRC) \
    free(DEST); \
    jmi_set_str(&(DEST), SRC, NULL);
    
/* Assign string array not in z vector */
#define JMI_ASG_STR_ARR(DEST, SRC) \
    { \
      int i; \
      for (i = 1; i <= DEST->num_elems; i++) { \
        JMI_ASG_STR(jmi_array_ref_1(DEST,i), jmi_array_val_1(SRC,i)) \
      }\
    }
    
/* Swap values between scalars. DEST is in z vector, SRC is not */
#define JMI_SWAP(TYPE,DEST,SRC) \
    JMI_SWAP_##TYPE(DEST,SRC)
#define JMI_SWAP_GEN(DEST,SRC) \
    jmi_swap_real(&(DEST), &(SRC));
#define JMI_SWAP_STR(DEST,SRC) \
    jmi_swap_string(&(DEST), &(SRC));

/*
 * Swap the values of the reals.
 */
void jmi_swap_real(jmi_real_t *dest, jmi_real_t *src);

/*
 * Swap the values of the strings.
 * We don't swap the pointers because they were allocated using different
 * schemes. dest is in the z-vector and was allocated using plain malloc
 * and we need to free it explicitly.
 * src uses the dynamic memory handling and will be deallocated
 * automatically upon JMI_DYNAMIC_FREE
 */
void jmi_swap_string(jmi_string_t *dest, jmi_string_t *src);

/* Handle return value */
#define JMI_RET(TYPE, DEST, SRC) \
    if (DEST != NULL) { JMI_RET_##TYPE(DEST, SRC) }
    
/* Put return value in return variable in function */
#define JMI_RET_GEN(DEST, SRC) *DEST = SRC;
#define JMI_RET_STR(DEST, SRC) JMI_RET_GEN(DEST, SRC)

#define JMI_RET_STR_ARR(DEST, SRC) \
    { \
      int i; \
      for (i = 1; i <= DEST->num_elems; i++) { \
        JMI_RET_STR(&jmi_array_ref_1(DEST,i), jmi_array_val_1(SRC,i)) \
      }\
    }

/* Length of string */
#define JMI_LEN(NAME) strlen(NAME)
    
/* Pointer to end of string */
#define JMI_STR_END(DEST) DEST + JMI_LEN(DEST)
    
/* Number of empty bytes at end of string */
#define JMI_STR_LEFT(DEST) DEST##_len - JMI_LEN(DEST)

/**
 * Set dest to value. Assumes dimension of dest is equal to dimension of arr.
 */
#define JMI_SET(TYPE,DEST,SRC,ARR,OFFSET) \
    JMI_SET_##TYPE(DEST,SRC,ARR,OFFSET)
#define JMI_SET_GEN(DEST,SRC,ARR,OFFSET) \
    DEST[OFFSET] = SRC;
#define JMI_SET_GEN_ARR(DEST,SRC,ARR,OFFSET) \
    jmi_set(DEST, SRC, ARR, OFFSET);

void jmi_set(jmi_real_t* dest, jmi_real_t src, jmi_array_t* arr, size_t offset);

#define JMI_COPY(TYPE,DIR,PTR,ARR,OFFSET) \
    JMI_COPY_##TYPE(DIR,PTR,ARR,OFFSET)
#define JMI_COPY_GEN(DIR,PTR,ARR,OFFSET) \
	JMI_COPY_GEN_##DIR(PTR,ARR,OFFSET)
#define JMI_COPY_GEN_L(PTR,ARR,OFFSET) \
    PTR[OFFSET] = ARR;
#define JMI_COPY_GEN_R(PTR,ARR,OFFSET) \
    ARR = PTR[OFFSET];
#define JMI_COPY_GEN_ARR(DIR,PTR,ARR,OFFSET) \
	JMI_COPY_GEN_ARR_##DIR(PTR,ARR,OFFSET)
#define JMI_COPY_GEN_ARR_L(PTR,ARR,OFFSET) \
    jmi_copy_to_ptr(PTR, ARR, OFFSET);
#define JMI_COPY_GEN_ARR_R(PTR,ARR,OFFSET) \
    jmi_copy_to_arr(ARR, PTR, OFFSET);

void jmi_copy_to_arr(jmi_array_t* dest, jmi_real_t* src, size_t offset);
void jmi_copy_to_ptr(jmi_real_t* dest, jmi_array_t* src, size_t offset);

void jmi_transpose_matrix(jmi_array_t* arr, jmi_real_t* src, jmi_real_t* dest);
void jmi_transpose_matrix_to_int(jmi_array_t* arr, jmi_real_t* src, jmi_int_t* dest);
void jmi_transpose_matrix_from_int(jmi_array_t* arr, jmi_int_t* src, jmi_real_t* dest);
void jmi_copy_matrix_to_int(jmi_array_t* arr, jmi_real_t* src, jmi_int_t* dest);
void jmi_copy_matrix_from_int(jmi_array_t* arr, jmi_int_t* src, jmi_real_t* dest);

#endif /* _JMI_ARRAY_NONE_H */
