#include <math.h>
#include "arrayFunctions.h"

double sumArrayElements(double* a, size_t len)
{
    double sum = 0.0;
    int i;
    for (i = 0; i < len; i++) {
        sum = sum + a[i];
    }
    
    return sum;
}

void transposeMatrix(double* a, size_t a_rows, size_t a_cols, double* b, size_t b_rows, size_t b_cols)
{
    int i;
    int j;
    int a_index = 0;
    
    for (i = 0; i < a_rows; i++) {
        for (j = 0; j < a_cols; j++) {
            b[j * b_cols + i] = a[a_index];
            a_index++;
        }
    }
}

void extFunc1(double m, double* a, size_t a1, size_t a2, size_t a3, int* b, size_t b1, size_t b2, size_t b3, int* c, size_t c1, size_t c2, double* sum, 
    double* o, size_t o1, size_t o2, size_t o3, double* step, size_t step1)
{
    size_t i1,i2,i3,t1,t2,i;
    *sum = 0;
    i = 0;
    for (i1 = 0; i1 < a1; i1++) {
        for (i2 = 0; i2 < a2; i2++) {
            t1 = i1*a2+i2;
            for (i3 = 0; i3 < a3; i3++) {
                t2 = t1*a3 + i3;
                o[t2] = m*a[t2] / b[t2];
                if (c[t1])
                    *sum += o[t2];
                step[i] = *sum;
                i = i + 1;
            }
        }
    }
}

void extFunc2(double m, double* a, size_t a1, size_t a2, size_t a3, int* b, size_t b1, size_t b2, size_t b3, int* c, size_t c1, size_t c2, double* sum, 
    double* o, size_t o1, size_t o2, size_t o3, double* step, size_t step1)
{
    size_t i1,i2,i3,t1,t2,i;
    *sum = 0;
    i = 0;
    for (i1 = 0; i1 < a1; i1++) {
        for (i2 = 0; i2 < a2; i2++) {
            t1 = i1*a2+i2;
            for (i3 = 0; i3 < a3; i3++) {
                t2 = t1*a3 + i3;
                o[t2] = m*(exp(a[t2]) + exp(b[t2]));
                if (c[t1])
                    *sum += o[t2];
                step[i] = *sum;
                i = i + 1;
            }
        }
    }
}

void copyBoolArray(int* bin, size_t bin_size, int* bout, size_t bout_size)
{
    size_t i1;
    for (i1 = 0; i1 < bin_size; i1++) {
		if (bin[i1])
			bout[i1] = 1;
		else
			bout[i1] = 0;
    }
}

double whileTrue(double a)
{
    while (1);
    return a;
}
