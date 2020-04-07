#ifndef ARRAYFUNCTIONS_H
#define ARRAYFUNCTIONS_H

#include <stddef.h>

double sumArrayElements(double* a, size_t len);
void transposeMatrix(double* a, size_t a_rows, size_t a_cols, double* b, size_t b_rows, size_t b_cols);
void extFunc1(double m, double* a, size_t a1, size_t a2, size_t a3, int* b, size_t b1, size_t b2, size_t b3, int* c, size_t c1, size_t c2, double* sum, 
    double* o, size_t o1, size_t o2, size_t o3, double* step, size_t step1);
void extFunc2(double m, double* a, size_t a1, size_t a2, size_t a3, int* b, size_t b1, size_t b2, size_t b3, int* c, size_t c1, size_t c2, double* sum, 
    double* o, size_t o1, size_t o2, size_t o3, double* step, size_t step1);
void copyBoolArray(int* bin, size_t bin_size, int* bout, size_t bout_size);
double whileTrue(double a);
#endif
