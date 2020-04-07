
#!/bin/bash

set -e

SHORT_VER=2.7

apt-get update # We update to find the repository with python-pip
apt-get install -y python-pip && echo "Installing numpy" && pip install numpy && pip install Cython wheel



