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

include default_config
include $(USER_CONFIG)

.PHONY: install

install: $(BLAS_BUILD_DIR)
	cd $(BLAS_BUILD_DIR) && make install DESTDIR=

$(BLAS_BUILD_DIR):
	mkdir -p $(BLAS_BUILD_DIR); \
	cd $(BLAS_BUILD_DIR); \
	cmake $(GENERATOR) -DCMAKE_Fortran_FLAGS=$(FORTRAN_FLAGS) -DCMAKE_INSTALL_DIR=$(BLAS_INSTALL_DIR) $(EXTRA_CMAKE_BLAS_FLAGS) $(BLAS_SRC_DIR)

clean:
	rm -rf $(BLAS_BUILD_DIR)

clean_install: clean install