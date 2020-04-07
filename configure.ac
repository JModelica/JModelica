# 
#    Copyright (C) 2009 Modelon AB
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the Common Public License as published by
#    IBM, version 1.0 of the License.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY. See the Common Public License for more details.
#
#    You should have received a copy of the Common Public License
#    along with this program.  If not, see
#     <http://www.ibm.com/developerworks/library/os-cpl.html/>.


#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ(2.62)
AC_INIT([jmodelica.org], 0.0.0, BUG-REPORT-ADDRESS)
AM_INIT_AUTOMAKE
AC_CONFIG_HEADER([config.h])
AC_CONFIG_MACRO_DIR([m4])


# =========== Helper macros =================

# Macros to detect if compiler accepts specific flag

# CXX_FLAG_CHECK [compiler flags]
# check whether compiler supports given C++ flags or not
AC_DEFUN([CXX_FLAG_CHECK], 
[ 
  AC_MSG_CHECKING([if $CXX supports $1])
  AC_LANG_PUSH([C++])
  ac_saved_cxxflags="$CXXFLAGS" 
  CXXFLAGS="-Werror $1" 
  AC_COMPILE_IFELSE([AC_LANG_PROGRAM([])], 
    [cxx_flag_check=yes], 
    [cxx_flag_check=no] 
  )
  AC_MSG_RESULT([$cxx_flag_check])
  CXXFLAGS="$ac_saved_cxxflags" 
  AC_LANG_POP([C++])
])

# C_FLAG_CHECK [compiler flags]
# check whether compiler supports given C flags or not
AC_DEFUN([C_FLAG_CHECK], 
[ 
  AC_MSG_CHECKING([if $CC supports $1])
  AC_LANG_PUSH([C])
  ac_saved_cflags="$CFLAGS" 
  CFLAGS="-Werror $1" 
  AC_COMPILE_IFELSE([AC_LANG_PROGRAM([])], 
    [c_flag_check=yes], 
    [c_flag_check=no] 
  )
  AC_MSG_RESULT([$c_flag_check])
  CFLAGS="$ac_saved_cflags" 
  AC_LANG_POP([C])
])  

# F77_FLAG_CHECK [compiler flags]
# check whether compiler supports given Fortran 77 flags or not
AC_DEFUN([F77_FLAG_CHECK], 
[ 
  AC_MSG_CHECKING([if $F77 supports $1])
  AC_LANG_PUSH([Fortran 77])
  ac_saved_fflags="$FFLAGS" 
  FFLAGS="-Werror $1" 
  AC_COMPILE_IFELSE([AC_LANG_PROGRAM([])], 
    [f77_flag_check=yes], 
    [f77_flag_check=no] 
  )
  AC_MSG_RESULT([$f77_flag_check])
  FFLAGS="$ac_saved_fflags" 
  AC_LANG_POP([Fortran 77])
])

# ALL_FLAG_CHECK [compiler flags]
# check whether compilers supports given flags or not for all of C, C++ and Fortran 77
AC_DEFUN([ALL_FLAG_CHECK], 
[
  C_FLAG_CHECK([$1])
  CXX_FLAG_CHECK([$1])
  F77_FLAG_CHECK([$1])
  AS_IF([test "$c_flag_check" = yes -a "$cxx_flag_check" = yes -a "$f77_flag_check" = yes],
        [all_flag_check=yes],
        [all_flag_check=no])
])

# ============= end of helper macros ===================
AC_OPENMP
AM_CONDITIONAL([WITH_OPENMP],[test "x$OPENMP_CFLAGS" != x])

# Checks for programs.
AC_PROG_CXX
AC_PROG_F77([gfortran])

# Acquire information about the platform
AC_CANONICAL_BUILD
AC_CANONICAL_HOST

# Different platforms use different standard name suffices for 
# shared libraries. Also the flag to gcc for creating a shared library
# differs. Also, on windows we need to make sure that we can build
# dll:s.
AC_SUBST(SHAREDEXT)
AC_SUBST(SHARED_LDFLAGS)
AC_SUBST(SEP)
SEP=':'
# Handle BSD-stype cp - TODO: detect other BSD systems than Mac
AC_SUBST(CP)
CP="cp -au"
AC_SUBST(CURR_DIR)
CURR_DIR=`pwd`
case $build in
  *-cygwin*)
    echo "Cygwin detected"   
    SHAREDEXT=".dll";
    SHARED_LDFLAGS=" -shared ";
    SEP='\;'
    AC_LIBTOOL_WIN32_DLL
    WIN32=yes
    AC_DEFINE([WIN32],[1],[Building on a win32 system (detected Cygwin).])
    ;;
  *-mingw*)
    echo "MinGW detected"   
    SHAREDEXT=".dll";
    SHARED_LDFLAGS=" -shared ";
    SEP='\;'
    AC_LIBTOOL_WIN32_DLL
    WIN32=yes
    AC_DEFINE([WIN32],[1],[Building on a win32 system (detected MinGW).])    
    ;;
  *-apple*)
    echo "Mac OS X detected"   
    WIN32=no
    AC_DEFINE([WIN32],[0],[Not a win32])    
    SHAREDEXT=".dylib";
    SHARED_LDFLAGS=" -dynamiclib ";
    CP="cp -a"
    ;;
  *)
    echo "Linux detected"   
    APP_LIBS="-lipopt -llapack -lblas -lm -lgfortranbegin -lgfortran"
    SHAREDEXT=".so";
    SHARED_LDFLAGS=" -shared ";
    # The fPIC flag is used to make the code independent of position in the
    # memory. This is needed on Linux x86_64 platforms.
    WIN32=no
    AC_DEFINE([WIN32],[0],[Not a win32])
    CFLAGS=" -fPIC $CFLAGS"
    CXXFLAGS=" -fPIC $CXXFLAGS"
    ;;  
esac
AC_PROG_LIBTOOL

AC_PREFIX_DEFAULT(["/usr/local/jmodelica"])

AS_IF([test "x$F77" != x],
      [AC_MSG_RESULT([gfortran seems to be working])],
      [AC_MSG_FAILURE([gfortran does not seem to be present or does not work properly])]) 

AS_IF([test "$WIN32" = yes], 
      [
          ALL_FLAG_CHECK([-m64])
          jm_win64=$all_flag_check
          AS_IF([test "$jm_win64" = yes],
                [AC_MSG_RESULT([Will compile 64-bit libs to support 64-bit FMUs.])],
                [AC_MSG_RESULT([Will not compile 64-bit libs - 64-bit FMUs not supported.])]
               )
      ])
AM_CONDITIONAL([JM_WIN64],[test "$jm_win64" = yes])

AC_DEFUN([IPOPT_ARG_CHECK],
[
# Checks for libraries.
AC_ARG_WITH([$1],
   [AS_HELP_STRING([--$2],
     [IPOPT installation directory @<:@default=check@:>@])],
   [$1=$withval],
   [$3=no])

AS_IF([test "x$$3" = xno],
      [AC_MSG_RESULT([ ])
       AC_MSG_RESULT([***********************************************************************])
       AC_MSG_RESULT([* --$2 option not specified - compiling without $4 support *])
       AC_MSG_RESULT([***********************************************************************])
       AC_MSG_RESULT([ ])],
       [AC_MSG_RESULT([ ])
       AC_MSG_RESULT([***********************************************************************])
       AC_MSG_RESULT([* --$2 option specified - compiling with $4 support        *])
       AC_MSG_RESULT([***********************************************************************])
       AC_MSG_RESULT([ ])
       AC_CHECK_FILE($$1/include/coin/IpStdCInterface.h,
                     [],
                     [AC_MSG_FAILURE([--$2 option was specified but does not seem to point at a valid IPOPT installation])])])

AM_CONDITIONAL([$8],[test "x$$3" != xno])

# Set output variables to be exported to the Makefiles
AC_SUBST($5)
AC_SUBST($6)
AC_SUBST($7)

$5=$$1/include/coin
$6=$$1/lib
$7=$$1
])

IPOPT_ARG_CHECK([ipopt], [with-ipopt], [with_ipopt], [IPOPT], [IPOPT_INC], [IPOPT_LIB], [IPOPT_HOME], [COMPILE_WITH_IPOPT])
IPOPT_ARG_CHECK([ipopt64], [with-ipopt64], [with_ipopt64], [IPOPT64], [IPOPT64_INC], [IPOPT64_LIB], [IPOPT64_HOME], [COMPILE_WITH_IPOPT64])


#------------- Configure python packages into build ----------------------------

AC_ARG_ENABLE([python],
  AS_HELP_STRING([--enable-python], [ use --enable-python=no to remove python modules from build]),
  [python=${enableval}],
  [python=yes])

AM_CONDITIONAL(PYTHON_ENABLED, test "$python" = "yes")
if test "$python" = "yes"; then
        echo configure: Python modules are enabled
else
        echo configure: Python modules are disabled
fi


#-----------------------------------------
AC_SUBST(WITH_CASADI)
AS_IF([test "x$with_casadi" != xno],
      [WITH_CASADI="true"],
      [WITH_CASADI="false"]) 

AC_ARG_WITH([casadi],
   [AS_HELP_STRING([--with-casadi],
     [CasADI Python-interface installation directory @<:@default=check@:>@])],
   [casadi=$withval],
   [with_casadi=no])

AS_IF([test "x$with_casadi" = xno],
      [AC_MSG_RESULT([CasADi installation not specified.])],
      [AC_CHECK_FILE($casadi/casadi/casadi.py,
                     [],
                     [AC_MSG_FAILURE([CasADi installation specifed, but seems to be corrupt!])])])

# Set output variables to be exported to the Makefiles
AC_SUBST(CASADI_HOME)

CASADI_HOME=$casadi

AC_SUBST(WITH_CASADI)
AS_IF([test "x$with_ipopt" != xno],
      [WITH_CASADI="true"],
      [WITH_CASADI="false"]) 

# Set output variables to be exported to the Makefiles
AC_SUBST(SUNDIALS_HOME)
SUNDIALS_HOME="$CURR_DIR/sundials_install"

AC_SUBST(MINPACK_HOME)
MINPACK_HOME="$CURR_DIR/minpack_install"

# Checks for mingw.
AC_ARG_WITH([mingw],
   [AS_HELP_STRING([--with-mingw],
     [MinGW installation directory. @<:@default=no@:>@])],
   [mingw=$withval],
   [with_mingw=no])

AS_IF([test "x$with_mingw" = xno],
      [mingw=["$MINGW_HOME"]])

AS_IF([test "x$MINGW_HOME" != x],
      [with_mingw=env])

AS_IF([test "x$with_mingw" = xno],
      [AC_MSG_RESULT([MinGW installation not specified.])],
      [AC_CHECK_FILE($mingw/bin/gcc.exe,
                     [],
                     [AC_MSG_FAILURE([MinGW installation specifed, but seems to be corrupt!])])])

AM_CONDITIONAL([WITH_MINGW],[test "x$with_mingw" != xno])

with_tdm=no
AS_IF([test "$with_mingw" != no],
      [ AC_MSG_CHECKING([for TDM-GCC])
        AS_IF([$CC -v 2>&1 | tail -n1 | grep -q "(tdm"],
              [with_tdm=yes])
        AC_MSG_RESULT([$with_tdm])
      ])

AM_CONDITIONAL([NUMPY_NO_MSVCR],[test "$with_mingw" != no -a "$with_tdm" = yes])
AM_CONDITIONAL([USE_TDM_GCC], [test "$with_tdm" = yes])


# Set output variables to be exported to the Makefiles
AC_SUBST(MINGW_HOME)
MINGW_HOME=$mingw

# Detect Java home directory
AC_SUBST(_JAVA_HOME_)

case $build in
  *-mingw*)
    # The SDK installer sets the environment variable JAVA_HOME, so there we don't need _JAVA_HOME_
	_JAVA_HOME_=
    ;;
  *)
	_JAVA_HOME_=`$(dirname $0)/run_java.sh org.jmodelica.util.GetJavaHome`
    ;;  
esac

AC_PATH_PROG([ANT], [ant], [])
AC_SUBST(ANT_OPTS)
ANT_OPTS="ANT_OPTS=-Xmx2g"

AM_CONDITIONAL([HAVE_ANT],[test "x$ANT" != x])

AS_IF([test "x$ANT" = x],
      [AC_MSG_FAILURE([Cannot find Apache Ant - please install in order to build compiler front-ends.])])

AC_DEFUN([PYTHON_DISTRO_CHECK],
[   
# Detect if Python installation is specified with environment var
AC_ARG_VAR($1, [Python $7 installation to use])
AS_IF([test "${$1}"],
      [
          $2="`cd ${$1}; pwd`"
          AC_MSG_RESULT([Using Python $7 installation ${$2}])
          $5="-DPYTHON_LIBRARY=${$2}/libs/libpython27.a"
          $6="-DPYTHON_INCLUDE_DIR=${$2}/include"
      ], [
          AS_IF([test "${$3}" && test "${$4}"], 
            [
                AC_MSG_RESULT([Using Python lib ${$3} and Python include ${$4}])
                $5="-DPYTHON_LIBRARY=${$3}"
                $6="-DPYTHON_INCLUDE_DIR=${$4}"
            ], [
                AC_MSG_RESULT([Python $7 installation not specified.])
                # Empty arguments will make cmake fail, so use dummies instead
                $5="-DPYTHON_LIBRARY_DUMMY="
                $6="-DPYTHON_INCLUDE_DIR_DUMMY="
            ])
      ])
AC_SUBST($5)
AC_SUBST($6)
AC_SUBST($1)
$1=$$2
])

PYTHON_DISTRO_CHECK([PYTHON_HOME], [PYTHON_HOME_ABS], [PYTHON_LIB], [PYTHON_INCLUDE], [CMAKE_PYTHON_LIB], [CMAKE_PYTHON_INCLUDE], [])
AC_SUBST(ORIG_PYTHON_HOME)
ORIG_PYTHON_HOME=$PYTHON_HOME_ABS
   
PYTHON_DISTRO_CHECK([PYTHON64_HOME], [PYTHON64_HOME_ABS], [PYTHON64_LIB], [PYTHON64_INCLUDE], [CMAKE_PYTHON64_LIB], [CMAKE_PYTHON64_INCLUDE], [64bit])
AM_CONDITIONAL([WITH_PYTHON64], [test "x$PYTHON64_HOME" != x])

AC_SUBST(ORIG_PATH)
ORIG_PATH=$PATH
AS_IF([test "x$JVMDLL_HOME" != x], 
[jvmdll_home=["$JVMDLL_HOME"]])
AC_SUBST(JVMDLL_HOME)
JVMDLL_HOME=$jvmdll_home
AS_IF([test "x$JVMDLL64_HOME" != x], 
[jvmdll64_home=["$JVMDLL64_HOME"]])
AC_SUBST(JVMDLL64_HOME)
JVMDLL64_HOME=$jvmdll64_home

# Checks for header files.
AC_HEADER_STDC
AC_CHECK_HEADERS([stdlib.h])

# Checks for typedefs, structures, and compiler characteristics.
AC_HEADER_STDBOOL
AC_C_CONST

#AC_CONFIG_SUBDIRS([ThirdParty/Sundials/sundials-2.5.0])

REQUIRE_IPOPT_HOME=True
REQUIRE_SUNDIALS_HOME=True
REQUIRE_COMPILER_JARS=True
REQUIRE_BEAVER_PATH=True
REQUIRE_MODELICAPATH=True
REQUIRE_JPYPE_JVM=True
REQUIRE_JVM_ARGS=False
REQUIRE_MINGW_HOME=True
REQUIRE_OPTIMICA_COMPILER=True

AC_SUBST(REQUIRE_IPOPT_HOME)
AC_SUBST(REQUIRE_SUNDIALS_HOME)
AC_SUBST(REQUIRE_COMPILER_JARS)
AC_SUBST(REQUIRE_BEAVER_PATH)
AC_SUBST(REQUIRE_MODELICAPATH)
AC_SUBST(REQUIRE_JPYPE_JVM)
AC_SUBST(REQUIRE_JVM_ARGS)
AC_SUBST(REQUIRE_MINGW_HOME)
AC_SUBST(REQUIRE_OPTIMICA_COMPILER)

AC_CONFIG_FILES([
 Makefile
 ThirdParty/Blas/Makefile
 ThirdParty/Lapack/Makefile
 ThirdParty/winpthreads/Makefile
 ThirdParty/SuperLU/Makefile
 ThirdParty/Sundials/Makefile
 ThirdParty/Minpack/Makefile
 ThirdParty/CasADi/Makefile
 ThirdParty/MSL/Makefile
 external/FMILibrary/Makefile
 Python/jm_ipython.sh
 Python/jm_python.sh
 Python/Makefile
 RuntimeLibrary/Makefile
 jm_tests
 Python/src/required_defaults.py
])

AC_OUTPUT

AC_MSG_RESULT([Configure completed successfully!])
