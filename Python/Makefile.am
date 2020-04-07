TESTLIBRARY_BUILD_DIR=$(abs_builddir)/build
TESTLIBRARY_SRC_DIR=$(abs_top_srcdir)/Python
TESTLIBRARY_BUILD_DIR64=$(abs_builddir)/build64

$(TESTLIBRARY_BUILD_DIR):
	mkdir -p $(TESTLIBRARY_BUILD_DIR) && \
	cd $(TESTLIBRARY_BUILD_DIR) && \
	case $(build) in \
	*-cygwin*) \
	cmake -G "MSYS Makefiles" -DCMAKE_C_FLAGS="-m32" -DCMAKE_Fortran_FLAGS="-m32" -DCMAKE_INSTALL_DIR:PATH=$(prefix) $(TESTLIBRARY_SRC_DIR) -DTOP_SRC=$(abs_top_srcdir) ;; \
	*-mingw*) \
	cmake -G "MSYS Makefiles" -DCMAKE_C_FLAGS="-m32" -DCMAKE_Fortran_FLAGS="-m32" -DCMAKE_INSTALL_DIR:PATH=$(prefix) $(TESTLIBRARY_SRC_DIR) -DTOP_SRC=$(abs_top_srcdir) ;; \
	*-apple*) \
	cmake -DCMAKE_INSTALL_DIR:PATH=$(prefix) $(TESTLIBRARY_SRC_DIR) -DTOP_SRC=$(abs_top_srcdir) ;; \
	*) \
	cmake -DCMAKE_INSTALL_DIR:PATH=$(prefix) $(TESTLIBRARY_SRC_DIR) -DTOP_SRC=$(abs_top_srcdir) ;; \
	esac

if JM_WIN64
if WITH_PYTHON64

${TESTLIBRARY_BUILD_DIR64}:
	mkdir -p $(TESTLIBRARY_BUILD_DIR64) && \
	cd $(TESTLIBRARY_BUILD_DIR64) && \
	cmake -G "MSYS Makefiles" -DCMAKE_C_FLAGS="-m64" -DCMAKE_Fortran_FLAGS="-m64" -DCMAKE_INSTALL_DIR:PATH=$(prefix) $(TESTLIBRARY_SRC_DIR) -DTOP_SRC=$(abs_top_srcdir)

all-local: $(TESTLIBRARY_BUILD_DIR) ${TESTLIBRARY_BUILD_DIR64}
	cd $(TESTLIBRARY_BUILD_DIR) && VERBOSE=1 make $(AM_MAKEFLAGS) install
	cd $(TESTLIBRARY_BUILD_DIR64) && VERBOSE=1 make $(AM_MAKEFLAGS) install
endif
endif

install-exec-local: $(TESTLIBRARY_BUILD_DIR)
	cd $(TESTLIBRARY_BUILD_DIR) && VERBOSE=1 make $(AM_MAKEFLAGS) install

check-local:
	cd $(TESTLIBRARY_BUILD_DIR) && $(MAKE) $(AM_MAKEFLAGS) clean
if JM_WIN64
if WITH_PYTHON64
	cd $(TESTLIBRARY_BUILD_DIR64) && $(MAKE) $(AM_MAKEFLAGS) clean
endif
endif

clean-local:
	-cd $(TESTLIBRARY_BUILD_DIR) && $(MAKE) $(AM_MAKEFLAGS) clean
if JM_WIN64
if WITH_PYTHON64
	cd $(TESTLIBRARY_BUILD_DIR64) && $(MAKE) $(AM_MAKEFLAGS) clean
endif
endif
