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

install: $(SUPERLU_BUILD_DIR)
	cd $(SUPERLU_BUILD_DIR) && make blaslib $(SUPERLU_EXTRA_CFLAGS) DESTDIR= && make superlulib $(SUPERLU_EXTRA_CFLAGS) DESTDIR=; \
	mkdir -p $(SUPERLU_INSTALL_DIR); \
	cp -r $(SUPERLU_BUILD_DIR)/* $(SUPERLU_INSTALL_DIR)/

$(SUPERLU_BUILD_DIR):
	mkdir -p $(SUPERLU_BUILD_DIR); \
	cd $(SUPERLU_SRC_DIR)/superlu_mt_3.1; \
	tar -c --exclude .svn . | tar x -C $(SUPERLU_BUILD_DIR)

clean: 
	rm -rf $(SUPERLU_BUILD_DIR)

clean_install: clean install