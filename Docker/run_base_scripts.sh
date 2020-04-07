#!/bin/sh
# 
#    Copyright (C) 2018 Modelon AB
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the Common Public License as published by
#    IBM, version 1.0 of the License.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY. See the Common Public License for more details.
#
#    You should have received a copy of the Common Public License
#    along with this program.  If not, see
#     <http://www.ibm.com/developerworks/library/os-cpl.html/>.

echo "STAGE 0/3: PREVENTING CACHE"
echo "STAGE 1/3: SETTING UP REQUIREMENTS"
. ${USR_PATH}/Docker/build/setup_requirements.sh
echo "STAGE 2/3: SETTING UP PYTHON PACKAGES"
. ${USR_PATH}/Docker/build/setup_python_packages.sh
echo "STAGE 3/3: SETTING UP IPOPT"
. ${USR_PATH}/Docker/build/setup_ipopt.sh