#!/bin/bash

# This script is used with generate_dockerfile because it builds what generate_dockerfile
# generated. Before running docker build it also checks for the hash corresponding to given
# config and, if it already exists locally it will not build the docker image.
set -e 

RED="\e[31m"
GREEN="\e[32m"
RESET="\e[0m"

echo -e $GREEN "\tbuild_docker_image: Building docker image..." $RESET
echo -e $GREEN "\tbuild_docker_image: using CONFIG $CONFIG USER_CONFIG $USER_CONFIG and TAG_NAME $TAG_NAME" $RESET
echo -e $GREEN "\tbuild_docker_image: Current working directory is ${PWD}" $RESET

[[ -e "$CONFIG" ]] && source $CONFIG || echo -e $RED "build_docker_image: No such config $CONFIG" $RESET
[[ -e "$USER_CONFIG" ]] && source $USER_CONFIG || echo -e $RED "build_docker_image: No such user config $USER_CONFIG" $RESET

echo -e "\tbuild_docker_image: Generating hash..."
IMAGE_HASH="$(echo -n $PLATFORM $DIST_VERSION $TARGET $PYTHON_VERSION $DOCKER_NAME_SUFFIX | md5sum | awk '{print $1}')"

# build image if not found among images
if ! docker images | grep -q "$IMAGE_HASH" ; then
    mkdir -p $DOCKERFILE_DIR
    cp $(dirname "$0")/Dockerfile $DOCKERFILE_DIR

    echo -e $GREEN "\tbuild_docker_image: Running docker build with Dockerfile located in $DOCKERFILE_DIR..." $RESET
    echo -e $GREEN "\tbuild_docker_image: Tagging image with ${TAG_NAME}:${IMAGE_HASH}" $RESET
    DOCKER_TAG_LOWERCASE=$(echo "${TAG_NAME}" | tr '[:upper:]' '[:lower:]')
    echo ${DOCKER_TAG_LOWERCASE}
    docker build -t "${DOCKER_TAG_LOWERCASE}:${IMAGE_HASH}" -f $DOCKERFILE_DIR/Dockerfile .
else
    echo -e $GREEN "\tbuild_docker_image: Used cached image tagged with ${TAG_NAME}:${IMAGE_HASH}" $RESET
fi
DOCKER_ID=$(docker images | grep "$IMAGE_HASH" | awk '{print $3}')
echo -e $GREEN "\tDocker build finished and found DOCKER_ID=${DOCKER_ID}" $RESET

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
