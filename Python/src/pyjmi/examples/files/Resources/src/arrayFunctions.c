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
