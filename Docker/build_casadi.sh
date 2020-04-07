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

# Currently casadi does not exist as a package !
# TODO : Ask RedHat support to consturct a package 
# The following is just a work around 
if [ "$LINUX_DISTRIBUTION" = "CENTOS" ]; then
	CURRDIR=$PWD
	wget http://apache.mirrors.spacedump.net/lucene/pylucene/pylucene-4.10.1-1-src.tar.gz
	mv pylucene-4.10.1-1-src.tar.gz /usr/local/src/
	cd /usr/local/src/
	export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk/
	yum -y install vim 
	# Update the Makefile , the linux section 
	vim Makefile # TODO apply batch on make file 
	make 
	make install 
fi

cd JModelica.org/build
make casadi_interface
cd ../..