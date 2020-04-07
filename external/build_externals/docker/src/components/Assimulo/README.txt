REQUIREMENTS TO BUILD ASSIMULO WITH DOCKER:
1. svn checkout JModelica, note you need to checkout on C:/Users/yourusername/... as docker mount on windows requires it
2. cd to C:/Users/yourusername/JModelica/external/build_externals/docker/src/components/Assimulo
3. cp example_user_config my_user_config
4. edit my_user_config and follow directions in the file


HOW TO BUILD ASSIMULO INSTALL DIRECTORY:
1. run: cd C:/Users/yourusername/JModelica/external/build_externals/docker/src/components/Assimulo
2. run: make docker_assimulo_folder USER_CONFIG=my_user_config

HOW TO BUILD ASSIMULO WHEEL:
1. run: cd C:/Users/yourusername/JModelica/external/build_externals/docker/src/components/Assimulo
2. run: make docker_assimulo_wheel USER_CONFIG=my_user_config


HOW IT WORKS:
1. Builds a base image using ${PLATFORM}:${DIST_VERSION} containing make, cmake, gcc, fortran, ...
2. Using base image (1) builds assimulo dependencies sundials, blas, ...
3. Build ${PLATFORM}_assimulo_base image by installing python and copying the assimulo dependencies (2)
4. Using ${PLATFORM}_assimulo_base image we build assimulo (wheel or folder)
5. Using CI we archive the assimulo artifacts
