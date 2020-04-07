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

# OS 

if [ -f /etc/centos-release ]; then
	export LINUX_DISTRIBUTION=CENTOS
elif [ -f /etc/redhat-release ]; then 
	export LINUX_DISTRIBUTION=REDHAT
elif [ -f /etc/debian_version ]; then 
	export LINUX_DISTRIBUTION=DEBIAN
else 
	export LINUX_DISTRIBUTION=UNKNOWN 
fi

# IPOPT 

export IPOPT_VERSION=3.12.8
export IPOPT_LOCATION=/usr/local/Ipopt-${IPOPT_VERSION}
export IPOPT_INSTALLATION_LOCATION=${IPOPT_LOCATION}/install
