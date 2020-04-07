#
#	Copyright (C) 2018 Modelon AB
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


MSL_BUILD_DIR=$(abs_builddir)/MSLbuild
MSL_BUILD_DIR64=$(abs_builddir)/MSLbuild64
MSL_SRC_DIR=$(abs_top_srcdir)/ThirdParty/MSL

if USE_TDM_GCC
    MSL_COMMON_ARGS="-DCMAKE_INSTALL_DIR:PATH=$(prefix)" "$(MSL_SRC_DIR)" "-DTOP_SRC=$(abs_top_srcdir)" "-DMSL_DIR=${MSL_SRC_DIR}" "-DWITH_TDM=ON"
else !USE_TDM_GCC
    MSL_COMMON_ARGS="-DCMAKE_INSTALL_DIR:PATH=$(prefix)" "$(MSL_SRC_DIR)" "-DTOP_SRC=$(abs_top_srcdir)" "-DMSL_DIR=${MSL_SRC_DIR}"
endif

$(MSL_BUILD_DIR):
	mkdir -p $(MSL_BUILD_DIR) && \
	cd $(MSL_BUILD_DIR) && \
	case $(build) in \
	*-cygwin*|*-mingw*) \
	cmake -G "MSYS Makefiles" -DCMAKE_C_FLAGS="-m32" $(MSL_COMMON_ARGS) ;; \
	*-apple*) \
	cmake $(MSL_COMMON_ARGS) ;; \
	*) \
	cmake $(MSL_COMMON_ARGS) ;; \
	esac

if JM_WIN64

$(MSL_BUILD_DIR64):
	mkdir -p $(MSL_BUILD_DIR64)
	cd $(MSL_BUILD_DIR64) && \
	cmake -G "MSYS Makefiles" -DCMAKE_C_FLAGS="-m64" $(MSL_COMMON_ARGS)

all-local: $(MSL_BUILD_DIR) $(MSL_BUILD_DIR64)
	cd $(MSL_BUILD_DIR) && VERBOSE=1 make $(AM_MAKEFLAGS) install
	cd $(MSL_BUILD_DIR64) && VERBOSE=1 make $(AM_MAKEFLAGS) install

else !JM_WIN64

install-exec-local: $(MSL_BUILD_DIR)
	cd $(MSL_BUILD_DIR) && VERBOSE=1 make $(AM_MAKEFLAGS) install

endif !JM_WIN64

check-local:
	cd $(MSL_BUILD_DIR) && $(MAKE) $(AM_MAKEFLAGS) test
if JM_WIN64
	cd $(MSL_BUILD_DIR64) && $(MAKE) $(AM_MAKEFLAGS) test
endif

clean-local:
	-cd $(MSL_BUILD_DIR) && $(MAKE) $(AM_MAKEFLAGS) clean
if JM_WIN64
	-cd $(MSL_BUILD_DIR64) && $(MAKE) $(AM_MAKEFLAGS) clean
endif
