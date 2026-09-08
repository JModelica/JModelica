#define JMI_COMPAT_IMPL
#include "jmi_sundials_compat.h"

#if SUNDIALS_VERSION_MAJOR >= 6
#include <stdlib.h>
#include <sundials/sundials_context.h>

/* Global SUNContext */
SUNContext jmi_sundials_ctx = NULL;

void jmi_sundials_init_context(void) {
    if (jmi_sundials_ctx == NULL) {
        SUNContext_Create(NULL, &jmi_sundials_ctx);
    }
}

void jmi_sundials_free_context(void) {
    if (jmi_sundials_ctx != NULL) {
        SUNContext_Free(&jmi_sundials_ctx);
        jmi_sundials_ctx = NULL;
    }
}
#endif

#if SUNDIALS_VERSION_MAJOR >= 6
#include <cvode/cvode.h>
#include <sunmatrix/sunmatrix_dense.h>
#include <sunlinsol/sunlinsol_dense.h>

/* Undefine macros to avoid recursion/redefinition issues */
#undef CVodeCreate
#undef CVDense
#undef CVodeSetErrHandlerFn

/* Wrapper for CVodeCreate */
void* jmi_cvode_create_compat(int lmm, int iter) {
    jmi_sundials_init_context();
    /* iter argument is ignored in modern Sundials CVodeCreate, it's set by linear solver */
    return CVodeCreate(lmm, jmi_sundials_ctx);
}

/* Wrapper for CVDense */
int jmi_cvdense_compat(void *cvode_mem, int N) {
    /* Create dense matrix */
    SUNMatrix A;
    SUNLinearSolver LS;
    int flag;

    A = SUNDenseMatrix(N, N, jmi_sundials_ctx);
    if (A == NULL) return -1;

    /* Create dense linear solver */
    LS = SUNLinSol_Dense(NULL, A, jmi_sundials_ctx);
    if (LS == NULL) {
        SUNMatDestroy(A);
        return -1;
    }

    /* Attach to CVODE */
    flag = CVodeSetLinearSolver(cvode_mem, LS, A);
    
    return flag;
}

/* Wrapper for CVodeSetErrHandlerFn */
/* Legacy signature: int CVodeSetErrHandlerFn(void *cvode_mem, CVErrHandlerFn ehfun, void *eh_data); */
/* Modern: int CVodeSetErrHandlerFn(void *cvode_mem, CVErrHandlerFn ehfun, void *eh_data); */
int jmi_cvode_set_err_handler_fn_compat(void *cvode_mem, void (*ehfun)(int, const char*, const char*, char*, void*), void *eh_data) {
    /* Cast to modern type if needed */
#if SUNDIALS_VERSION_MAJOR >= 7
    CVodeSetErrHandlerFn(cvode_mem, (SUNErrHandlerFn)ehfun, eh_data);
#else
    CVodeSetErrHandlerFn(cvode_mem, (CVErrHandlerFn)ehfun, eh_data);
#endif
    return 0;
}
#endif
