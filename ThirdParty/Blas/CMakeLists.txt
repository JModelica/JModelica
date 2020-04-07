cmake_minimum_required (VERSION 2.6)
project (BLAS)
enable_language (Fortran)

# Get the install directory
if(CMAKE_INSTALL_DIR)
    set(BLAS_INSTALL_DIR ${CMAKE_INSTALL_DIR})
else()
    set(BLAS_INSTALL_DIR ${CMAKE_BINARY_DIR}/../install)
    message(STATUS "Install dir not defined, using ${BLAS_INSTALL_DIR}")
endif()
message(STATUS BLAS_INSTALL_DIR=${BLAS_INSTALL_DIR})

set (blas_srcs
    dasum.f
    dcopy.f
    dgemm.f
    dnrm2.f
    drotm.f
    dscal.f
    dspr.f
    dsymm.f
    dsyr2.f
    dtbmv.f
    dtpsv.f
    dtrsm.f
    dznrm2.f
    xerbla.f
    daxpy.f
    ddot.f
    dgemv.f
    drot.f
    drotmg.f
    dsdot.f
    dspr2.f
    dsymv.f
    dsyr2k.f
    dtbsv.f
    dtrmm.f
    dtrsv.f
    idamax.f
    dcabs1.f
    dgbmv.f
    dger.f
    drotg.f
    dsbmv.f
    dspmv.f
    dswap.f
    dsyr.f
    dsyrk.f
    dtpmv.f
    dtrmv.f
    dzasum.f
    lsame.f
    )

add_library (blas STATIC ${blas_srcs})

install (TARGETS blas 
   LIBRARY DESTINATION ${BLAS_INSTALL_DIR} COMPONENT library
   ARCHIVE DESTINATION ${BLAS_INSTALL_DIR} COMPONENT library
   RUNTIME DESTINATION ${BLAS_INSTALL_DIR} COMPONENT library)
