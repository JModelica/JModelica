#!/bin/bash

set -e

SHORT_VER=3.6
# We install python3-pip, it installs al the required tools and Python 3.6
apt-get update # We update to find the repository with python3-pip
apt-get install -y python3-pip && echo "Installing numpy" && pip3 install numpy && pip3 install Cython && pip3 install wheel
ln -s /usr/bin/python${SHORT_VER} /usr/bin/python

