/*
    Copyright (C) 2016 Modelon AB

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

#include "jmi_types.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

jmi_matrix_sparse_csc_t *jmi_linear_solver_create_sparse_matrix(jmi_int_t rows, jmi_int_t cols, jmi_int_t nnz) {
    jmi_matrix_sparse_csc_t *A = calloc(1, sizeof(jmi_matrix_sparse_csc_t));
    if (!A) { return NULL; }
    A->type.type = JMI_MATRIX_SPARSE_CSC;
    A->nbr_rows = rows;
    A->nbr_cols = cols;
    A->nnz = nnz;
    A->col_ptrs = calloc(cols+1, sizeof(jmi_int_t));
    A->row_ind = calloc(nnz, sizeof(jmi_int_t));
    A->x = calloc(nnz, sizeof(double));
    return A;
}

void jmi_linear_solver_delete_sparse_matrix(jmi_matrix_sparse_csc_t *A) {
    free(A->col_ptrs);
    free(A->row_ind);
    free(A->x);
    free(A);
}
