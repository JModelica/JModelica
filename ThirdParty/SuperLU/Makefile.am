SUPERLU_DIR=../../superlu_build
SUPERLU_DIR64=../../superlu_build64
# This is to ensure that the install target of the SuperLU
# make system is run whenever make all is run. This is needed
# in order to trigger a complete install, local in the build
# directory, early in the build process.

$(SUPERLU_DIR):
	mkdir -p $(SUPERLU_DIR) && \
	cd $(SUPERLU_DIR)
	cp -r $(abs_top_srcdir)/ThirdParty/SuperLU/superlu_mt_3.1/* $(abs_builddir)/../../superlu_build/

if JM_WIN64

$(SUPERLU_DIR64):
	mkdir -p $(SUPERLU_DIR64)
	cd $(SUPERLU_DIR64)
	cp -r $(abs_top_srcdir)/ThirdParty/SuperLU/superlu_mt_3.1/* $(abs_builddir)/../../superlu_build64/

all-local: $(SUPERLU_DIR) $(SUPERLU_DIR64)
	cd $(SUPERLU_DIR) && make blaslib EXTRA_CFLAGS=-m32 $(AM_MAKEFLAGS) DESTDIR= && make superlulib EXTRA_CFLAGS=-m32 $(AM_MAKEFLAGS) DESTDIR=
	cd $(SUPERLU_DIR64) && make blaslib $(AM_MAKEFLAGS) DESTDIR= && make superlulib $(AM_MAKEFLAGS) DESTDIR=

else !JM_WIN64

all-local: $(SUPERLU_DIR)
	case $(build) in \
	*-cygwin*|*-mingw*) \
	cd $(SUPERLU_DIR) && make blaslib EXTRA_CFLAGS=-m32 $(AM_MAKEFLAGS) DESTDIR= && make superlulib EXTRA_CFLAGS=-m32 $(AM_MAKEFLAGS) DESTDIR= ;; \
	*-apple*) \
	cd $(SUPERLU_DIR) && make blaslib $(AM_MAKEFLAGS) DESTDIR= && make superlulib $(AM_MAKEFLAGS) DESTDIR= ;; \
	*) \
	cd $(SUPERLU_DIR) && make blaslib $(AM_MAKEFLAGS) DESTDIR= && make superlulib $(AM_MAKEFLAGS) DESTDIR= ;; \
	esac

endif !JM_WIN64

check-local:
	cd $(SUPERLU_DIR) && $(MAKE) $(AM_MAKEFLAGS) test

clean-local:
	-cd $(SUPERLU_DIR) && $(MAKE) $(AM_MAKEFLAGS) clean
if JM_WIN64
	-cd $(SUPERLU_DIR64) && $(MAKE) $(AM_MAKEFLAGS) clean
endif
