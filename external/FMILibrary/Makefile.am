FMIL_BUILD_DIR=$(abs_builddir)/../../FMIL_build
FMIL_BUILD_DIR64=$(abs_builddir)/../../FMIL_build64

# This is to ensure that the install target of the FMI Library
# make system is run whenever make all is run. This is needed
# in order to trigger a complete install, local in the build
# directory, early in the build process.

$(FMIL_BUILD_DIR):
	mkdir -p $(FMIL_BUILD_DIR) && \
	cd $(FMIL_BUILD_DIR) && \
	case $(build) in \
	*-cygwin*) \
	cmake -G "MSYS Makefiles" -DCMAKE_C_FLAGS="-m32" -DCMAKE_CXX_FLAGS="-m32" -DCMAKE_SHARED_LINKER_FLAGS="-m32" -DCMAKE_EXE_LINKER_FLAGS="-m32" -DFMILIB_INSTALL_PREFIX:PATH=$(abs_builddir)/../../FMIL_install $(abs_top_srcdir)/external/FMILibrary/FMILibrary/ ;; \
  	*-mingw*) \
	cmake -G "MSYS Makefiles" -DCMAKE_C_FLAGS="-m32" -DCMAKE_CXX_FLAGS="-m32" -DCMAKE_SHARED_LINKER_FLAGS="-m32" -DCMAKE_EXE_LINKER_FLAGS="-m32" -DFMILIB_INSTALL_PREFIX:PATH=$(abs_builddir)/../../FMIL_install $(abs_top_srcdir)/external/FMILibrary/FMILibrary/ ;; \
  	*-apple*) \
	cmake -DFMILIB_INSTALL_PREFIX:PATH=$(abs_builddir)/../../FMIL_install $(abs_top_srcdir)/external/FMILibrary/FMILibrary/ ;; \
  	*) \
	cmake -DFMILIB_INSTALL_PREFIX:PATH=$(abs_builddir)/../../FMIL_install $(abs_top_srcdir)/external/FMILibrary/FMILibrary/ ;; \
	esac

if JM_WIN64

$(FMIL_BUILD_DIR64):
	mkdir -p $(FMIL_BUILD_DIR64)
	cd $(FMIL_BUILD_DIR64) && \
	cmake -G "MSYS Makefiles" -DCMAKE_C_FLAGS="-m64 -fPIC" -DCMAKE_CXX_FLAGS="-m64 -fPIC" -DCMAKE_SHARED_LINKER_FLAGS="-m64 -fPIC" -DCMAKE_EXE_LINKER_FLAGS="-m64 -fPIC" -DFMILIB_INSTALL_PREFIX:PATH=$(abs_builddir)/../../FMIL_install64 $(abs_top_srcdir)/external/FMILibrary/FMILibrary/
  	
all-local: $(FMIL_BUILD_DIR) $(FMIL_BUILD_DIR64)
	cd $(FMIL_BUILD_DIR) && make $(AM_MAKEFLAGS) install DESTDIR=
	cd $(FMIL_BUILD_DIR64) && make $(AM_MAKEFLAGS) install DESTDIR=

else !JM_WIN64

all-local: $(FMIL_BUILD_DIR)
	cd $(FMIL_BUILD_DIR) && make $(AM_MAKEFLAGS) install DESTDIR=

endif !JM_WIN64

check-local:
	cd $(FMIL_BUILD_DIR) && $(MAKE) $(AM_MAKEFLAGS) test

clean-local:
	-cd $(FMIL_BUILD_DIR) && $(MAKE) $(AM_MAKEFLAGS) clean

