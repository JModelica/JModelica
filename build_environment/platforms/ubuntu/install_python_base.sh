#!/bin/bash
# This file is not in use at the moment but will be in future
# when we move to compiling Python from source
set -e

apt-get clean
apt-get update
apt-get install -y ca-certificates # need certificates for wget python
apt-get install -y --no-install-recommends wget

apt-get install -y libssl-dev #for pip, requires SSL/TLS
apt-get install -y zlib1g-dev # also for pip, it uses zipimport from this package
apt-get install -y --no-install-recommends make

apt-get install -y gcc # take recommends because installs neccessary headers

#apt-get install -y --no-install-recommends zlib1g-dev
#apt-get install -y libssl-dev zlib1g-dev libbz2-dev libsqlite3-dev # for python installations

#apt-get install -y --no-install-recommends python-pip #dont install this, it installs python2.7
#curl
#zlib1g-dev
#libssl-dev
# for centos we need openssl-devel