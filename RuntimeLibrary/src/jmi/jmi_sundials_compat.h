#ifndef JMI_SUNDIALS_COMPAT_H
#define JMI_SUNDIALS_COMPAT_H

#include <sundials/sundials_types.h>

/* Define realtype if missing (Sundials 7.x might use sunrealtype) */
typedef double realtype;

/* Define DlsMat for compatibility with newer Sundials versions (which removed it) */
#ifndef JMI_SUNDIALS_COMPAT_DLSMAT
#define JMI_SUNDIALS_COMPAT_DLSMAT
#pragma message "Defining DlsMat manually"

/*
 * ==================================================================
 * Type definitions
 * ==================================================================
 */

/*
 * -----------------------------------------------------------------
 * Type : DlsMat
 * -----------------------------------------------------------------
 * The type DlsMat is defined to be a pointer to a structure
 * with various sizes, a data field, and an array of pointers to
 * the columns which defines a dense matrix for use in direct
 * linear solvers. The M and N fields indicates the number of
 * rows and columns, respectively. The data field is a one
 * dimensional array used for component storage. The cols
 * field stores the pointers in data for the beginning of each
 * column.
 * -----------------------------------------------------------------
 */

typedef struct _DlsMat {
  int type;
  long int M;
  long int N;
  long int ldim;
  double *data;
  long int ldata;
  double **cols;
} *DlsMat;

/* Data types for the DlsMat type */
#define SUNDIALS_DENSE 1
#define SUNDIALS_BAND  2

#endif /* JMI_SUNDIALS_COMPAT_DLSMAT */





/* Legacy Constants removed in Sundials 7.x */
#ifndef CV_ADAMS
#define CV_ADAMS 1
#endif
#ifndef CV_BDF
#define CV_BDF 2
#endif

#ifndef CV_FUNCTIONAL
#define CV_FUNCTIONAL 1
#endif
#ifndef CV_NEWTON
#define CV_NEWTON 2
#endif

#ifndef UNIT_ROUNDOFF
#if defined(DBL_EPSILON)
#define UNIT_ROUNDOFF DBL_EPSILON
#else
#define UNIT_ROUNDOFF 1.1102230246251565e-16
#endif
#endif

/* Legacy Macros */
#ifndef DENSE_ELEM
#define DENSE_ELEM(A,i,j) ((A)->cols[j][i])
#endif

/* Compatibility Wrappers for Sundials 7.x */
#ifdef __cplusplus
extern "C" {
#endif

/* Initialize/Free global SUNContext */
void jmi_sundials_init_context();
void jmi_sundials_free_context();

/* Global SUNContext (needed for macros) */
#include <sundials/sundials_context.h>
extern SUNContext jmi_sundials_ctx;

/* N_Vector wrapper */
#include <nvector/nvector_serial.h>
#define N_VNew_Serial(N) N_VNew_Serial(N, jmi_sundials_ctx)

/* Define N_Vector accessors (Sundials 7.x compatibility) */
/* Force definition to ensure we use the macro version */
#ifdef N_VGetArrayPointer
#undef N_VGetArrayPointer
#endif
#define N_VGetArrayPointer(v) NV_DATA_S(v)

#ifdef N_VSetArrayPointer
#undef N_VSetArrayPointer
#endif
#define N_VSetArrayPointer(data, v) (NV_DATA_S(v) = (data))

/* CVodeCreate wrapper */
void* jmi_cvode_create_compat(int lmm, int iter);
#define CVodeCreate jmi_cvode_create_compat

/* CVDense wrapper */
int jmi_cvdense_compat(void *cvode_mem, int N);
#define CVDense jmi_cvdense_compat

/* CVodeSetErrHandlerFn wrapper */
int jmi_cvode_set_err_handler_fn_compat(void *cvode_mem, void (*ehfun)(int, const char*, const char*, char*, void*), void *eh_data);
#define CVodeSetErrHandlerFn jmi_cvode_set_err_handler_fn_compat

#ifdef __cplusplus
}
#endif

#endif /* JMI_SUNDIALS_COMPAT_H */
