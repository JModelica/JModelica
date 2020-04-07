#!/bin/bash

set -e


yum update -y python
yum install -y numpy # this also installs setuptools
yum --enablerepo=extras install -y epel-release # to enable repo with pip
yum install -y python-pip
pip install wheel Cython # Cython version is 0.29

yum install -y python-devel # For headers such as Python.h

yum install -y numpy-f2py # For assimulo setup.py