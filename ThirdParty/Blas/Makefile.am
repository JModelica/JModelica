#
#	Copyright (C) 2009 Modelon AB
#
#	This program is free software: you can redistribute it and/or modify
#	it under the terms of the GNU General Public License version 3 as published 
#	by the Free Software Foundation, or optionally, under the terms of the 
#	Common Public License version 1.0 as published by IBM.
#
#	This program is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License, or the Common Public License, for more details.
#
#	You should have received copies of the GNU General Public License
#	and the Common Public License along with this program.  If not, 
#	see <http://www.gnu.org/licenses/> or 
#	<http://www.ibm.com/developerworks/library/os-cpl.html/> respectively.
#
BLAS_BUILD_DIR=../../blas_build
BLAS_BUILD_DIR64=../../blas_build64
BLAS_INSTALL_DIR=$(abs_builddir)/../../blas_install
BLAS_INSTALL_DIR64=$(abs_builddir)/../../blas_install64

$(BLAS_BUILD_DIR):
	mkdir -p $(BLAS_BUILD_DIR) && \
	cd $(BLAS_BUILD_DIR) && \
	case $(build) in \
	*-cygwin*|*-mingw*) \
	cmake -G "MSYS Makefiles" -DCMAKE_Fortran_FLAGS="-fPIC -O2 -m32" DCMAKE_Fortran_COMPILER="gfortran" -DCMAKE_INSTALL_DIR=$(BLAS_INSTALL_DIR) $(abs_top_srcdir)/ThirdParty/Blas/ ;; \
	*-apple*) \
	cmake -DCMAKE_Fortran_FLAGS="-fPIC -O3" -DCMAKE_INSTALL_DIR=$(BLAS_INSTALL_DIR) $(abs_top_srcdir)/ThirdParty/Blas/ ;; \
	*) \
	cmake -DCMAKE_Fortran_FLAGS="-fPIC -O2" -DCMAKE_INSTALL_DIR=$(BLAS_INSTALL_DIR) $(abs_top_srcdir)/ThirdParty/Blas/ ;; \
	esac

if JM_WIN64

$(BLAS_BUILD_DIR64):
	mkdir -p $(BLAS_BUILD_DIR64)
	cd $(BLAS_BUILD_DIR64) && \
	cmake -G "MSYS Makefiles" -DCMAKE_Fortran_FLAGS="-fPIC -O2 -m64" -DCMAKE_Fortran_COMPILER="gfortran" -DCMAKE_INSTALL_DIR=$(BLAS_INSTALL_DIR64) $(abs_top_srcdir)/ThirdParty/Blas/

all-local: $(BLAS_BUILD_DIR) $(BLAS_BUILD_DIR64)
	cd $(BLAS_BUILD_DIR) && VERBOSE=1 make $(AM_MAKEFLAGS) install DESTDIR=
	cd $(BLAS_BUILD_DIR64) && VERBOSE=1 make $(AM_MAKEFLAGS) install DESTDIR=

else !JM_WIN64

all-local: $(BLAS_BUILD_DIR)
	cd $(BLAS_BUILD_DIR) && VERBOSE=1 make $(AM_MAKEFLAGS) install DESTDIR=

endif !JM_WIN64

install-exec-local:
	mkdir -p $(DESTDIR)$(prefix)/lib/RuntimeLibrary
	cp $(BLAS_INSTALL_DIR)/* $(DESTDIR)$(prefix)/lib/RuntimeLibrary
if JM_WIN64
	mkdir -p $(DESTDIR)$(prefix)/lib/RuntimeLibrary64 && cp $(BLAS_INSTALL_DIR64)/* $(DESTDIR)$(prefix)/lib/RuntimeLibrary64
endif

check-local:
	cd $(BLAS_BUILD_DIR) && $(MAKE) $(AM_MAKEFLAGS) test
if JM_WIN64
	cd $(BLAS_BUILD_DIR64) && $(MAKE) $(AM_MAKEFLAGS) test
endif

clean-local:
	-cd $(BLAS_BUILD_DIR) && $(MAKE) $(AM_MAKEFLAGS) clean
if JM_WIN64
	-cd $(BLAS_BUILD_DIR64) && $(MAKE) $(AM_MAKEFLAGS) clean
endif
