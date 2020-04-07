
include default_config
include $(USER_CONFIG)

.PHONY: wheel folder

test:
	nosetests tests/*.pyc tests/solvers/*.pyc

test_wheel: $(INSTALL_DIR_FOLDER)/$(subst test_,,$@)
	@pip install $(INSTALL_DIR_FOLDER)/$(subst test_,,$@)/*.whl
	nosetests $(WHEEL_INSTALL_DIR)/tests/*.pyc $(WHEEL_INSTALL_DIR)/tests/solvers/*.pyc

test_folder: $(INSTALL_DIR_FOLDER)/$(subst test_,,$@)
	nosetests $(ASSIMULO_FOLDER_INSTALL_DIR)/tests/*.pyc $(ASSIMULO_FOLDER_INSTALL_DIR)/tests/solvers/*.pyc

folder: $(INSTALL_DIR_FOLDER)/folder

$(INSTALL_DIR_FOLDER)/folder: 
	@$(eval TARGET_BUILD_DIR=$(BUILD_DIR)/folder_build)
	mkdir -p $(TARGET_BUILD_DIR)
	@$(eval TARGET_INSTALL_DIR=$(BUILD_DIR)/folder_install)
	mkdir -p $(TARGET_INSTALL_DIR)
	mkdir -p $@

	cd $(ASSIMULO_SRC) && \
	find . -type f | grep -v -E '/.svn|.pyc' |tar c -T - | tar x -C $(TARGET_BUILD_DIR)
	cd $(TARGET_BUILD_DIR); \
	$(PYTHONHOME)python setup.py install --superlu-home=$(SUPERLU_HOME) --sundials-home=$(SUNDIALS_HOME) --sundials-with-superlu=True --blas-home=$(BLAS_HOME) --lapack-home=$(LAPACK_HOME) $(EXTRA_SETUP_ARGS) --prefix=$(TARGET_INSTALL_DIR)
	
	cd $(TARGET_INSTALL_DIR)/$(PLATFORM_SITE_PACKAGES); \
	find $(TARGET_INSTALL_DIR)/$(PLATFORM_SITE_PACKAGES) -type d -name assimulo -exec cp -r {} $@/ \;
	rm -rf $(TARGET_BUILD_DIR) $(TARGET_INSTALL_DIR)

wheel: $(INSTALL_DIR_FOLDER)/wheel

$(INSTALL_DIR_FOLDER)/wheel:
	@$(eval TARGET_BUILD_DIR=$(BUILD_DIR)/wheel_build)
	mkdir -p $(TARGET_BUILD_DIR)
	mkdir -p $@
	cd $(ASSIMULO_SRC) && \
	find . -type f | grep -v -E '/.svn|.pyc' |tar c -T - -f - | tar x -C $(TARGET_BUILD_DIR)
	cd $(TARGET_BUILD_DIR); \
	$(PYTHONHOME)python setup.py bdist_wheel --superlu-home=$(SUPERLU_HOME) --sundials-home=$(SUNDIALS_HOME) --sundials-with-superlu=True --blas-home=$(BLAS_HOME) --lapack-home=$(LAPACK_HOME) $(EXTRA_SETUP_ARGS); \
	find -type f -name Assimulo*.whl -exec cp {} $@/ \;
	rm -rf $(TARGET_BUILD_DIR)

clean:
	rm -rf $(BUILD_DIR)

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
