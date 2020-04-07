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

echo "Setting up variables"
. ${USR_PATH}/Docker/build/settings.sh || exit $?
echo "STAGE 1/3: ADDING ASSIMULO"
. ${USR_PATH}/Docker/build/get_assimulo.sh
echo "Stage 2/3: BUILDING"
. ${USR_PATH}/Docker/build/build.sh
echo "STAGE 3/3: SKIPPED BUILDING CASADI"
# . Docker/build/build_casadi.sh 

