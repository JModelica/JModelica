#include "externalFunctionsC.h"

#include <string.h>
#include <ModelicaUtilities.h>
#include <time.h>

double fRealScalar(double in)
{
	return in*3.14;
}

void fRealArray(double* in, size_t in_d1, double* out, size_t out_d1)
{
	size_t i;
	for (i = 0; i < in_d1; i++)
		out[i] = in[in_d1 - 1 - i];
}

int fIntegerScalar(int in)
{
	return in*3;
}

void fIntegerArray(int* in, size_t in_d1, int* out, size_t out_d1)
{
	size_t i;
	for (i = 0; i < in_d1; i++)
		out[i] = in[in_d1 - 1 - i];
}

int fBooleanScalar(int in)
{
	return !in;
}

void fBooleanArray(int* in, size_t in_d1, int* out, size_t out_d1)
{
	size_t i;
	for (i = 0; i < in_d1; i++)
		out[i] = !in[i];
}

const char* fStringScalar(const char* in)
{
	char* c = ModelicaAllocateString(3);
	c[0] = in[3];
	c[1] = in[2];
	c[2] = in[1];
	return c;
}

const char* fStringScalarLit(const char* in)
{
    static char c[4];
    c[0] = in[2];
    c[1] = in[1];
    c[2] = in[0];
    c[3] = '\0';
    return c;
}

void fStringArray(const char** in, size_t in_d1, const char** out, size_t out_d1)
{
	size_t i;
	char **temp = malloc(sizeof(char*) * in_d1);
	
	for (i = 0; i < in_d1; i++)
		temp[i] = ModelicaAllocateString(strlen(in[i]));
	for (i = 0; i < in_d1; i++)
		strcpy(temp[i], in[i]);
	for (i = 1; i < in_d1; i++)
		temp[i][1] = temp[0][1];
	for (i = 0; i < in_d1; i++)
		out[i] = temp[i];
	free(temp);
}

int fEnumScalar(int in)
{
	return 2;
}

void fEnumArray(int* in, size_t in_d1, int* out, size_t out_d1)
{
	size_t i;
	for (i = 0; i < in_d1; i++)
		out[i] = in[in_d1 - 1 - i];
}

void fRecord(fRec_t *r, fRec_t *y)
{
    y->x = r->x;
}

int fStrlen(const char *str)
{
    return (int) strlen(str);
}

int get_time()
{
    time_t seconds;
    clock_t count = clock () + CLOCKS_PER_SEC;
    while (clock() < count){} /* Wait one second so that we are sure that two calls return different results (which is what we want to use in our testing */
    
    seconds = time(NULL);
    return seconds; 
}
