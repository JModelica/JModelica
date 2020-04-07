WINPTHREADS_DIR=../../winpthreads_build
WINPTHREADS_DIR64=../../winpthreads_build64
# This is to ensure that the install target of the Winpthreads
# make system is run whenever make all is run. This is needed
# in order to trigger a complete install, local in the build
# directory, early in the build process.

$(WINPTHREADS_DIR):
	mkdir -p $(WINPTHREADS_DIR) && \
	cd $(WINPTHREADS_DIR)
	cp -r $(abs_top_srcdir)/ThirdParty/winpthreads/winpthreads/* $(abs_builddir)/$(WINPTHREADS_DIR)/

if JM_WIN64

$(WINPTHREADS_DIR64):
	mkdir -p $(WINPTHREADS_DIR64)
	cd $(WINPTHREADS_DIR64)
	cp -r $(abs_top_srcdir)/ThirdParty/winpthreads/winpthreads/* $(abs_builddir)/$(WINPTHREADS_DIR64)/

all-local: $(WINPTHREADS_DIR) $(WINPTHREADS_DIR64)
	cd $(WINPTHREADS_DIR) && ./configure && make CFLAGS=-m32 LDFLAGS=-m32 RCFLAGS='-F pe-i386' $(AM_MAKEFLAGS) DESTDIR= && make CFLAGS=-m32 LDFLAGS=-m32 RCFLAGS='-F pe-i386' $(AM_MAKEFLAGS) DESTDIR=
	cd $(WINPTHREADS_DIR64) && ./configure && make $(AM_MAKEFLAGS) DESTDIR= && make $(AM_MAKEFLAGS) DESTDIR=

else !JM_WIN64

all-local: $(WINPTHREADS_DIR)
	case $(build) in \
	*-cygwin*|*-mingw*) \
	cd $(WINPTHREADS_DIR) && ./configure && make CFLAGS=-m32 LDFLAGS=-m32 RCFLAGS='-F pe-i386' $(AM_MAKEFLAGS) DESTDIR= && make CFLAGS=-m32 LDFLAGS=-m32 RCFLAGS='-F pe-i386' $(AM_MAKEFLAGS) DESTDIR= ;; \
	esac

endif !JM_WIN64

check-local:
	-cd $(WINPTHREADS_DIR) && $(MAKE) $(AM_MAKEFLAGS) test

clean-local:
	-cd $(WINPTHREADS_DIR) && $(MAKE) $(AM_MAKEFLAGS) clean
if JM_WIN64
	-cd $(WINPTHREADS_DIR64) && $(MAKE) $(AM_MAKEFLAGS) clean
endif
