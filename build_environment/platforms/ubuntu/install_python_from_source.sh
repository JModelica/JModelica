#!/bin/bash

set -e


#TODO add check if compiled python version is already available on artifactory
# Below is IN PROGRESS, it compiles any given python version from source

PYTHON_VERSION=$1
# If we install python version X.Y.Z we get directory pythonX.Y, so we extract first two digits
SHORT_VER=${PYTHON_VERSION:0:3}

# build python 
URL="https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz"
cd /usr/src/
echo "Trying to access ${URL}"
wget "${URL}"
if [[ "$?" != 0 ]]; then
    echo "Error downloading Python ${PYTHON_VERSION}"
    exit 1
else
    echo "Successfully downloaded Python ${PYTHON_VERSION}"
fi
tar xzf Python-${PYTHON_VERSION}.tgz
cd Python-${PYTHON_VERSION}

#TODO check configure installation path
./configure
make altinstall
python${SHORT_VER} --version
echo "alias python=python${SHORT_VER}" >> ~/.bashrc
echo "export PYTHONPATH=/usr/local/bin/python${SHORT_VER}:/usr/local/lib/python${SHORT_VER}/:/usr/local/lib/python${SHORT_VER}/site-packages/:$PYTHONPATH" >> ~/.bashrc
echo "export PYTHONHOME=/usr/local/bin/:$PYTHONPATH" >> ~/.bashrc
source ~/.bashrc
. ~/.bashrc
