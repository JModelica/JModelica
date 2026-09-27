#ifndef JMI_SUNDIALS_COMPAT_H
#define JMI_SUNDIALS_COMPAT_H

#include <sundials/sundials_config.h>
#include <sundials/sundials_types.h>

#ifdef __has_include
#if __has_include(<sundials/sundials_version.h>)
#include <sundials/sundials_version.h>
#endif
#else
/* Fallback if __has_include is not available (e.g. old GCC), assume header exists if version >= 2.7.0 */
#include <sundials/sundials_version.h>
#endif

#if SUNDIALS_VERSION_MAJOR >= 6
/* Define realtype if missing (Sundials 7.x might use sunrealtype) */
typedef double realtype;

/* Define DlsMat for compatibility with newer Sundials versions (which removed it) */
#if !defined(JMI_SUNDIALS_COMPAT_DLSMAT)

#if SUNDIALS_VERSION_MAJOR == 6
#include <sundials/sundials_direct.h>
/* Do not redefine DlsMat or _DlsMat, just use what sundials_direct.h provides */

#elif SUNDIALS_VERSION_MAJOR >= 7
#define JMI_SUNDIALS_COMPAT_DLSMAT
#pragma message "Defining DlsMat manually"

/*
 * ==================================================================
 * Type definitions
 * ==================================================================
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
#endif

#endif /* JMI_SUNDIALS_COMPAT_DLSMAT */
#else
#include <sundials/sundials_direct.h>
/* Ensure DlsMat is defined properly if not done by sundials_direct.h (unlikely for < 7) */
#endif

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

#if SUNDIALS_VERSION_MAJOR >= 6
/* Initialize/Free global SUNContext */
void jmi_sundials_init_context(void);
void jmi_sundials_free_context(void);

/* Global SUNContext (needed for macros) */
#include <sundials/sundials_context.h>
extern SUNContext jmi_sundials_ctx;

/* N_Vector wrapper */
#include <nvector/nvector_serial.h>
#endif

#if SUNDIALS_VERSION_MAJOR >= 6
#ifndef JMI_COMPAT_IMPL
/* Define N_Vector accessors (Sundials 7.x compatibility) */
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
#if SUNDIALS_VERSION_MAJOR >= 7
typedef SUNErrHandlerFn CVErrHandlerFnCompat;
#else
typedef void (*CVErrHandlerFnCompat)(int error_code, const char *module, const char *function, char *msg, void *eh_data);
#endif
int jmi_cvode_set_err_handler_fn_compat(void *cvode_mem, CVErrHandlerFnCompat ehfun, void *eh_data);
#define CVodeSetErrHandlerFn jmi_cvode_set_err_handler_fn_compat
#endif /* JMI_COMPAT_IMPL */

#else
/* For Sundials < 6 */
#define jmi_sundials_init_context()
#define jmi_sundials_free_context()
#endif

#ifdef __cplusplus
}
#endif

#endif /* JMI_SUNDIALS_COMPAT_H */
