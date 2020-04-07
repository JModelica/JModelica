#!/bin/bash
set -o nounset
set -o errexit

# Based on https://svn.jmodelica.org/branches/20160331.x/ThirdParty/MSL/setup.sh

svn co https://svn.modelica.org/projects/Modelica/tags/v3.2.2+build.3-release .
#We have nothing to merge from trunk right now, but in the event that we have, this is how it is done!
# svn merge --accept base -1234,1235 https://svn.modelica.org/projects/Modelica/trunk

rm -r .svn
rm -r ModelicaTest
rm -r ModelicaReference
rm ObsoleteModelica3.mo

#Patch specific models
patch -i tightenTolRoomCOControls.patch -p0
patch -i updateStartInverseParameterization.patch -p0
patch -i decreasesHeightTanksWithOverflow.patch -p0
patch -i fluxTubesStateselect.patch -p0
patch -i ActuatorWithNoiseStateSelect.patch -p0
patch -i modelicaRandomMutex.patch -p0
patch -i visualstudio2015.patch -p0
patch -i dynamicSelect.patch -p0
