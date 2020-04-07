MINPACK_DIR=../../minpack_build
MINPACK_DIR64=../../minpack_build64
# This is to ensure that the install target of the Minpack
# make system is run whenever make all is run. This is needed
# in order to trigger a complete install, local in the build
# directory, early in the build process.

$(MINPACK_DIR):
	mkdir -p $(MINPACK_DIR) && \
	cd $(MINPACK_DIR) && \
	case $(build) in \
	*-cygwin*|*-mingw*) \
	cmake -G "MSYS Makefiles" -DCMAKE_C_FLAGS="-m32" -DCMAKE_INSTALL_PREFIX:PATH=$(abs_builddir)/../../minpack_install -DCMINPACK_LIB_INSTALL_DIR:PATH=$(abs_builddir)/../../minpack_install/lib -DCMINPACK_INCLUDE_INSTALL_DIR:PATH=$(abs_builddir)/../../minpack_install/include $(abs_top_srcdir)/ThirdParty/Minpack/cminpack-1.3.2/ ;; \
	*-apple*) \
	cmake -DCMAKE_INSTALL_PREFIX:PATH=$(abs_builddir)/../../minpack_install -DCMINPACK_LIB_INSTALL_DIR:PATH=$(abs_builddir)/../../minpack_install/lib -DCMINPACK_INCLUDE_INSTALL_DIR:PATH=$(abs_builddir)/../../minpack_install/include $(abs_top_srcdir)/ThirdParty/Minpack/cminpack-1.3.2/ ;; \
	*) \
	cmake -DCMAKE_INSTALL_PREFIX:PATH=$(abs_builddir)/../../minpack_install -DCMINPACK_LIB_INSTALL_DIR:PATH=$(abs_builddir)/../../minpack_install/lib -DCMINPACK_INCLUDE_INSTALL_DIR:PATH=$(abs_builddir)/../../minpack_install/include $(abs_top_srcdir)/ThirdParty/Minpack/cminpack-1.3.2/ ;; \
	esac

if JM_WIN64

$(MINPACK_DIR64):
	mkdir -p $(MINPACK_DIR64)
	cd $(MINPACK_DIR64) && \
	cmake -G "MSYS Makefiles" -DCMAKE_C_FLAGS="-m64" -DCMAKE_INSTALL_PREFIX:PATH=$(abs_builddir)/../../minpack_install -DCMINPACK_LIB_INSTALL_DIR:PATH=$(abs_builddir)/../../minpack_install/lib64 -DCMINPACK_INCLUDE_INSTALL_DIR:PATH=$(abs_builddir)/../../minpack_install/include $(abs_top_srcdir)/ThirdParty/Minpack/cminpack-1.3.2/

all-local: $(MINPACK_DIR) $(MINPACK_DIR64)
	cd $(MINPACK_DIR) && make $(AM_MAKEFLAGS)
	cd $(MINPACK_DIR64) && make $(AM_MAKEFLAGS)

install-exec-local: $(MINPACK_DIR) $(MINPACK_DIR64)
	cd $(MINPACK_DIR) && make $(AM_MAKEFLAGS) install DESTDIR=
	cd $(MINPACK_DIR64) && make $(AM_MAKEFLAGS) install DESTDIR=

else !JM_WIN64

all-local: $(MINPACK_DIR)
	cd $(MINPACK_DIR) && make $(AM_MAKEFLAGS)

install-exec-local: $(MINPACK_DIR)
	cd $(MINPACK_DIR) && make $(AM_MAKEFLAGS) install DESTDIR=

endif !JM_WIN64

check-local:
	cd $(MINPACK_DIR) && $(MAKE) $(AM_MAKEFLAGS) test
if JM_WIN64
	cd $(MINPACK_DIR64) && $(MAKE) $(AM_MAKEFLAGS) test
endif

clean-local:
	-cd $(MINPACK_DIR) && $(MAKE) $(AM_MAKEFLAGS) clean
if JM_WIN64
	-cd $(MINPACK_DIR64) && $(MAKE) $(AM_MAKEFLAGS) clean
endif
