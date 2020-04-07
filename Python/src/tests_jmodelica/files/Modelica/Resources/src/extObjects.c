#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "ModelicaUtilities.h"
#include "extObjects.h"

void* cpy(void* src, size_t len) {
    void* res = malloc(len);
    memcpy(res, src, len);
    return res;
}

char*   cpystr(const char* src)         { return (char*)  cpy((void*)src, (strlen(src)+1)*sizeof(char)); }
double* cpydbl(double* src, size_t len) { return (double*)cpy((void*)src, len*sizeof(double)); }
int*    cpyint(int* src, size_t len)    { return (int*)   cpy((void*)src, len*sizeof(int)); }

void* constructor_string(const char* str) {
    void* res = malloc(strlen(str) + 1);
    strcpy(res, str);
    fprintf(stderr, "Constructing external object for file '%s'.\n", str);
    return res;
}

void* constructor_modelica_msg(const char* str) {
    void* res = malloc(strlen(str) + 1);
    strcpy(res, str);
    return res;
}

void* constructor_error_multiple_calls(const char* str) {
    static int count = 0;
    if (count > 0) {
        ModelicaError("Constructor called more than once");
    }
    count = count + 1;
    return constructor_modelica_msg(str);
}

double constant_extobj_func(void* o) {
    return 1.0;
}

void destructor_string_create_file(void* o) {
    FILE* f = fopen((char*) o, "w");
    fprintf(f, "Test file.");
    fclose(f);
    fprintf(stderr, "Destructing external object for file '%s'.\n", (char*)o);

    free(o);
}

void destructor_modelica_msg(void* o) {
    ModelicaFormatMessage("This should not lead to a segfault...\n");
    free(o);
}

void destructor(void* o) {
    free(o);
}
void* my_constructor1(double x, int y, int b, const char* s) {
    Obj1_t* res = malloc(sizeof(Obj1_t));
    res->s = cpystr(s);
    res->x = b ? x + y : -1;
    return res;
}
double use1(void* o1) {
    ModelicaFormatMessage("String mess: %s", ((Obj1_t*)o1)->s);
    return ((Obj1_t*)o1)->x;
}

void my_constructor2(double* x, int* y, void** o2, int* b, const char** s) {
    Obj2_t* res = malloc(sizeof(Obj2_t));
    res->x = cpydbl(x,2);
    res->y = cpyint(y,2);
    res->b = cpyint(b,2);
    res->s = malloc(sizeof(char*)*2);
    res->s[0] = cpystr(s[0]);
    res->s[1] = cpystr(s[1]);
    *o2 = res;
}
double use2(void* o2) {
    Obj2_t* o = (Obj2_t*) o2;
    return o->x[0] + o->x[1] + o->y[0] + o->y[1];
}

void my_constructor3(void* o1, void** o2, void** o3) {
    Obj3_t* res = malloc(sizeof(Obj3_t));
    res->x = use1(o1) + use2(o2[0]) + use2(o2[1]);
    ModelicaFormatMessage("%s", "O3 constructed");
    ModelicaFormatMessage("%s", "Testing\n\r\n some line breaks\n\r\n");
    *o3 = res;
}
double use3(void* o3) {
    Obj3_t* o = (Obj3_t*) o3;
    return o->x;
}

void* inc_int_con(int x) {
    inc_int_t* res;
    ModelicaMessage("Constructor message");
    res = malloc(sizeof(inc_int_t)); res->x = x;
    return res;
}
void inc_int_decon(void* o1) {
    free(o1);
}
int inc_int_use(void* o1) {
    inc_int_t* eo = (inc_int_t*) o1;
    eo->x += 1;
    return eo->x;
}
int inc_int_use2(void* o1) {
    return inc_int_use(o1);
}

void* crash_con(int x) {
    inc_int_t* res;
    exit(1);
    res = malloc(sizeof(inc_int_t)); res->x = x;
    return res;
}
void crash_decon(void* o1) {
    exit(1);
    free(o1);
}
int crash_use(void* o1) {
    inc_int_t* eo = (inc_int_t*) o1;
    eo->x += 1;
    exit(1);
    return eo->x;
}

void* error_con(int x) {
    inc_int_t* res;
    ModelicaError("Constructor error message");
    res = malloc(sizeof(inc_int_t)); res->x = x;
    return res;
}
void error_decon(void* o1) {
    ModelicaError("Deconstructor error message");
    free(o1);
}
int error_use(void* o1) {
    inc_int_t* eo = (inc_int_t*) o1;
    ModelicaError("Use error message");
    eo->x += 1;
    return eo->x;
}

void *eo_constructor_record(R1_t *r1) {
    double *res = malloc(sizeof(double));
    *res = r1->r2.x;
    return (void*)res;
}

void eo_destructor_record(void *eo) {
    free(eo);
}

double eo_use_record(void *eo) {
    return *((double*)eo);
}
