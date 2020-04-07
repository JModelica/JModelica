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
LAPACK_BUILD_DIR=../../lapack_build
LAPACK_BUILD_DIR64=../../lapack_build64
LAPACK_INSTALL_DIR=$(abs_builddir)/../../lapack_install
LAPACK_INSTALL_DIR64=$(abs_builddir)/../../lapack_install64

$(LAPACK_BUILD_DIR):
	mkdir -p $(LAPACK_BUILD_DIR) && \
	cd $(LAPACK_BUILD_DIR) && \
	case $(build) in \
	*-cygwin*|*-mingw*) \
	cmake -G "MSYS Makefiles" -DCMAKE_Fortran_FLAGS="-fPIC -O3 -ffloat-store -m32" DCMAKE_Fortran_COMPILER="gfortran" -DCMAKE_INSTALL_DIR=$(LAPACK_INSTALL_DIR) $(abs_top_srcdir)/ThirdParty/Lapack/ ;; \
	*-apple*) \
	cmake -DCMAKE_Fortran_FLAGS="-fPIC -O3 -ffloat-store" -DCMAKE_INSTALL_DIR=$(LAPACK_INSTALL_DIR) $(abs_top_srcdir)/ThirdParty/Lapack/ ;; \
	*) \
	cmake -DCMAKE_Fortran_FLAGS="-fPIC -O3 -ffloat-store" -DCMAKE_INSTALL_DIR=$(LAPACK_INSTALL_DIR) $(abs_top_srcdir)/ThirdParty/Lapack/ ;; \
	esac

if JM_WIN64

$(LAPACK_BUILD_DIR64):
	mkdir -p $(LAPACK_BUILD_DIR64)
	cd $(LAPACK_BUILD_DIR64) && \
	cmake -G "MSYS Makefiles" -DCMAKE_Fortran_FLAGS="-fPIC -O3 -ffloat-store -m64" -DCMAKE_Fortran_COMPILER="gfortran" -DCMAKE_INSTALL_DIR=$(LAPACK_INSTALL_DIR64) $(abs_top_srcdir)/ThirdParty/Lapack/

all-local: $(LAPACK_BUILD_DIR) $(LAPACK_BUILD_DIR64)
	cd $(LAPACK_BUILD_DIR) && VERBOSE=1 make $(AM_MAKEFLAGS) install DESTDIR=
	cd $(LAPACK_BUILD_DIR64) && VERBOSE=1 make $(AM_MAKEFLAGS) install DESTDIR=

else !JM_WIN64

all-local: $(LAPACK_BUILD_DIR)
	cd $(LAPACK_BUILD_DIR) && VERBOSE=1 make $(AM_MAKEFLAGS) install DESTDIR=

endif !JM_WIN64

install-exec-local:
	mkdir -p $(DESTDIR)$(prefix)/lib/RuntimeLibrary
	cp $(LAPACK_INSTALL_DIR)/* $(DESTDIR)$(prefix)/lib/RuntimeLibrary
if JM_WIN64
	mkdir -p $(DESTDIR)$(prefix)/lib/RuntimeLibrary64 && cp $(LAPACK_INSTALL_DIR64)/* $(DESTDIR)$(prefix)/lib/RuntimeLibrary64
endif

check-local:
	cd $(LAPACK_BUILD_DIR) && $(MAKE) $(AM_MAKEFLAGS) test
if JM_WIN64
	cd $(LAPACK_BUILD_DIR64) && $(MAKE) $(AM_MAKEFLAGS) test
endif

clean-local:
	-cd $(LAPACK_BUILD_DIR) && $(MAKE) $(AM_MAKEFLAGS) clean
if JM_WIN64
	-cd $(LAPACK_BUILD_DIR64) && $(MAKE) $(AM_MAKEFLAGS) clean
endif

