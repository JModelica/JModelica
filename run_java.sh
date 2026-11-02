#!/bin/bash
# Compile and run a Java class from the source files for the ModelicaCompiler package.
# This script must not be in $PATH! (Or at least not invoked without a path.)

# Relative path from this script to source dir.
REL=.
# Path to source dir (relative to cwd or absolute depending on $0)
SRC="$(dirname "$0")"/${REL}
CLS=$1

shift
FILE="${SRC}/Compiler/ModelicaFrontEnd/src/java/${CLS//.//}.java"
TEMP=$(mktemp -dq /tmp/runjava.XXXXXX)
javac -d ${TEMP} "${FILE}"
java -cp ${TEMP} ${CLS} "$@"
RES=$?
rm -rf ${TEMP}
exit ${RES}