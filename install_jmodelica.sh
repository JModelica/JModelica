#!/bin/bash
#
# Ubuntu Linux installation script for JModelica (https://jmodelica.org/)
#
# Original code taken from https://jmodelica.org/downloads/UsersGuide-2.4.pdf,
# modified by Christian Kral based on
# https://stackoverflow.com/questions/55230042/jmodelica-on-ubuntu-18-04.
#
# This script is hosted at https://gitlab.com/christiankral/install_jmodelica/.
#
# Version history
# 2019-08-22 Now works under Ubuntu 18.04 and Java 8
# 2017-03-02 Inital version for Ubuntu 16.04

# Set work directory variable, which may be replaced by ~/work or ~/tmp for
# most users. This directory shall be created before running this script.
export WORK=/work
# Local installation directory with read + write + exectue access of the current
# user. This directory shall be created before running this script.
export INSTALLDIR=~/bin
# Branch to be checked out from JModelica.org,
# see https://trac.jmodelica.org/browser/
export JMODELICABRANCH=2.14

# Install required packages
sudo apt install -y  g++
sudo apt install -y  subversion
sudo apt install -y  gfortran
sudo apt install -y  ipython
sudo apt install -y  cmake
sudo apt install -y  swig
sudo apt install -y  ant
sudo apt install -y  openjdk-8-jdk
sudo apt install -y  python-dev
sudo apt install -y  python-numpy
sudo apt install -y  python-scipy
sudo apt install -y  python-matplotlib
sudo apt install -y  cython
sudo apt install -y  python-lxml
sudo apt install -y  python-nose
sudo apt install -y  python-jpype
sudo apt install -y  zlib1g-dev
sudo apt install -y  libboost-dev
sudo apt install -y  jcc
sudo apt install -y  libblas-dev

# Install IPOPT
cd ${WORK}
# Remove directory from previous installation attempt
sudo rm -fr Ipopt-3.10.2
# Version to be installed see install PDF at http://www.jmodelica.org/page/236
wget http://www.coin-or.org/download/source/Ipopt/Ipopt-3.10.2.tgz
tar zxvf Ipopt-3.10.2.tgz

cd Ipopt-3.10.2/ThirdParty/Blas
sed -i 's/ftp/http/g' ./get.Blas
./get.Blas

cd ../Lapack
sed -i 's/ftp/http/g' ./get.Lapack
./get.Lapack

cd ../Mumps
# Not (yet ?) required
# sed -i 's/ftp/http/g' ./get.Mumps
./get.Mumps

cd ../Metis
# Not (yet ?) required
# sed -i 's/ftp/http/g' ./get.Metis
./get.Metis
cd ../../

mkdir build
cd build
# Remove previously installed ipopt
rm -fr ${INSTALLDIR}/ipopt
../configure --prefix=${INSTALLDIR}/ipopt
make install

# Create date in a variable
DATE=`date +%Y%m%d`
# Remove existing directory from work, if existing
sudo rm -fr ${WORK}/jmodelica
# Export data from jmodelica repository
# A copy of Jmodelica is now hosted on GitHub
# at https://github.com/JModelica/JModelica
# Original source code was retrieved by
# svn export https://svn.jmodelica.org/${JMODELICABRANCH} ${WORK}/jmodelica
cd ${WORK}
git clone https://github.com/JModelica/JModelica.git
mv JModelica jmodelica

cd ${WORK}/jmodelica
# Checkout indicated branch
git checkout ${JMODELICABRANCH}
# configure is not executable
chmod +x ./configure
# Replace solver_object.output with solver_object.getOutput See
# https://stackoverflow.com/questions/55230042/jmodelica-on-ubuntu-18-04 and
# https://stackoverflow.com/questions/6758963/find-and-replace-with-sed-in-directory-and-sub-directories?noredirect=1
find ./ -type f -exec sed -i -e 's/solver_object.output/solver_object.getOutput/g' {} \;

mkdir build
cd build
../configure --prefix=${INSTALLDIR}/jmodelica${DATE} --with-ipopt=${INSTALLDIR}/ipopt
export LD_LIBRARY_PATH=/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64/:/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64/server
export PATH=$PATH:/usr/lib/jvm/java-8-openjdk-amd64/bin
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
export JRE_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre/
export J2SDKDIR=/usr/lib/jvm/java-8-openjdk-amd64/
export J2REDIR=/usr/lib/jvm/java-8-openjdk-amd64/jre/
make install
make casadi_interface

echo -e '#!/bin/bash' >${INSTALLDIR}/jmodelica${DATE}.sh
echo "export WORK=${WORK}" >>${INSTALLDIR}/jmodelica${DATE}.sh
echo "cd ${WORK}" >>${INSTALLDIR}/jmodelica${DATE}.sh
echo "export MODELICAPATH=${WORK}:${INSTALLDIR}/jmodelica${DATE}/ThirdParty/MSL/" >>${INSTALLDIR}/jmodelica${DATE}.sh
echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/" >>${INSTALLDIR}/jmodelica${DATE}.sh
echo "export JRE_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre/" >>${INSTALLDIR}/jmodelica${DATE}.sh
echo "export J2SDKDIR=/usr/lib/jvm/java-8-openjdk-amd64/" >>${INSTALLDIR}/jmodelica${DATE}.sh
echo "export J2REDIR=/usr/lib/jvm/java-8-openjdk-amd64/jre/" >>${INSTALLDIR}/jmodelica${DATE}.sh
echo "${INSTALLDIR}/jmodelica${DATE}/bin/jm_python.sh" >>${INSTALLDIR}/jmodelica${DATE}.sh
chmod +x ${INSTALLDIR}/jmodelica${DATE}.sh

ln -sf ${INSTALLDIR}/jmodelica${DATE}.sh ${INSTALLDIR}/jmodelica.sh

echo ""
echo "Installation completed"
echo "Start script is: ${INSTALLDIR}/jmodelica.sh"
echo "Being an alias of: ${INSTALLDIR}/jmodelica${DATE}.sh"
