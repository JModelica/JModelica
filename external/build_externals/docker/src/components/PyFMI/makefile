
include default_config
include $(USER_CONFIG)
include ../utils/docker_targets.mk

$(TARGET)_dependencies: fmil

fmil:
	@echo "building fmil"
	cd $(BUILD_EXTERNALS)/$@ && make install USER_CONFIG=$(DOCKER_CONFIG_HOME)/$(USER_CONFIG) BUILD_DIR=$(DOCKER_BUILD_DIR) JM_HOME=$(JM_HOME_IN_DOCKER)

setup:
	test -n "${JM_HOME}" # $$JM_HOME
	test -n "${PATH_TO_MOUNT}" # $$PATH_TO_MOUNT
	@mkdir -p $(BUILD_DIR)
	@cp $(CONFIG_HOME)/default_config $(BUILD_DIR)
	@cp $(CONFIG_HOME)/$(USER_CONFIG) $(BUILD_DIR)

clean:
	@ rm -rf $(BUILD_DIR)


.PHONY:


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