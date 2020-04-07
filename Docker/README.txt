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

Building 
========

For the latest version of Ubuntu, navigate to the folder with the Dockerfile, and run (including the final dot):

docker build -f ./Dockerfile_full_image --build-arg DOCKER_LINUX_DIST=jmodelica/ubuntu_base --build-arg DOCKER_DIST_TAG=18.04 .

For the CentOS version 7.4, run (including the final dot):

docker build -f ./Dockerfile_full_image --build-arg DOCKER_LINUX_DIST=jmodelica/centos_base --build-arg DOCKER_DIST_TAG=7.4 .

After build a docker image you can list all your local images by typing "docker images". By using the "IMAGE ID" visible
when typing "docker images", you can attach to them by

docker attach <IMAGE ID>

You can also run a simple command by

docker run -it <IMAGE ID> echo "hello"

Or also directly refer to the base image from its repository:

docker run -it jmodelica/ubuntu_base:18.04 apt list --installed
