SUNDIALS_DIR=../../sundials_build
SUNDIALS_DIR64=../../sundials_build64
# This is to ensure that the install target of the Sundials
# make system is run whenever make all is run. This is needed
# in order to trigger a complete install, local in the build
# directory, early in the build process.

if WITH_OPENMP
SUPERLU_ADDON=-DSUPERLUMT_THREAD_TYPE=OpenMP -DSUPERLUMT_ENABLE=ON -DSUPERLUMT_LIBRARY_DIR=$(abs_builddir)/../../superlu_build/lib -DSUPERLUMT_INCLUDE_DIR=$(abs_builddir)/../../superlu_build/SRC
SUPERLU_ADDON64=-DSUPERLUMT_THREAD_TYPE=OpenMP -DSUPERLUMT_ENABLE=ON -DSUPERLUMT_LIBRARY_DIR=$(abs_builddir)/../../superlu_build64/lib -DSUPERLUMT_INCLUDE_DIR=$(abs_builddir)/../../superlu_build64/SRC
else
SUPERLU_ADDON=
SUPERLU_ADDON64=
endif

$(SUNDIALS_DIR):
	mkdir -p $(SUNDIALS_DIR) && \
	cd $(SUNDIALS_DIR) && \
	case $(build) in \
	*-cygwin*|*-mingw*) \
	cmake -G "MSYS Makefiles" $(SUPERLU_ADDON) -DEXAMPLES_ENABLE=OFF -DBUILD_SHARED_LIBS=OFF -DCMAKE_C_FLAGS="-m32 -mincoming-stack-boundary=2 -fPIC" -DCMAKE_INSTALL_PREFIX:PATH=$(abs_builddir)/../../sundials_install $(abs_top_srcdir)/ThirdParty/Sundials/sundials-2.7.0/ ;; \
	*-apple*) \
	cmake -DEXAMPLES_ENABLE=OFF $(SUPERLU_ADDON) -DBUILD_SHARED_LIBS=OFF -DCMAKE_C_FLAGS="-fPIC" -DCMAKE_INSTALL_PREFIX:PATH=$(abs_builddir)/../../sundials_install $(abs_top_srcdir)/ThirdParty/Sundials/sundials-2.7.0/ ;; \
	*) \
	cmake -DEXAMPLES_ENABLE=OFF $(SUPERLU_ADDON) -DBUILD_SHARED_LIBS=OFF -DCMAKE_C_FLAGS="-fPIC" -DCMAKE_INSTALL_PREFIX:PATH=$(abs_builddir)/../../sundials_install $(abs_top_srcdir)/ThirdParty/Sundials/sundials-2.7.0/ ;; \
	esac

if JM_WIN64

$(SUNDIALS_DIR64):
	mkdir -p $(SUNDIALS_DIR64)
	cd $(SUNDIALS_DIR64) && \
	cmake -G "MSYS Makefiles" $(SUPERLU_ADDON64) -DEXAMPLES_ENABLE=OFF -DBUILD_SHARED_LIBS=OFF -DCMAKE_C_FLAGS="-m64 -fPIC" -DCMAKE_INSTALL_PREFIX:PATH=$(abs_builddir)/../../sundials_install64 $(abs_top_srcdir)/ThirdParty/Sundials/sundials-2.7.0/

all-local: $(SUNDIALS_DIR) $(SUNDIALS_DIR64)
	cd $(SUNDIALS_DIR) && make $(AM_MAKEFLAGS) install DESTDIR=
	cd $(SUNDIALS_DIR64) && make $(AM_MAKEFLAGS) install DESTDIR=

else !JM_WIN64

all-local: $(SUNDIALS_DIR)
	cd $(SUNDIALS_DIR) && make $(AM_MAKEFLAGS) install DESTDIR=

endif !JM_WIN64

check-local:
	cd $(SUNDIALS_DIR) && $(MAKE) $(AM_MAKEFLAGS) test

clean-local:
	-cd $(SUNDIALS_DIR) && $(MAKE) $(AM_MAKEFLAGS) clean
if JM_WIN64
	-cd $(SUNDIALS_DIR64) && $(MAKE) $(AM_MAKEFLAGS) clean
endif
