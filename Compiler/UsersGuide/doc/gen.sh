#!/bin/bash

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Generate options' documentation.                                                  #
#                                                                                   #
# This will be put in all places where the annotation ==OPTIONS-LIST== exists.      #
# @see org.jmodelica.util.documentation.OptionExporter                              #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# These two assignments should remain for all <Module>/doc/gen.sh scripts.
HOME="`dirname $0`"
JAVA_CP="$1"
DOC_DEST="$2"
echo "java -cp "${JAVA_CP}" 'org.jmodelica.modelica.compiler.OptionExporter' \
    -t "${HOME}/template/Options.xml" -d "${HOME}/Options.xml""
java -cp "${JAVA_CP}" 'org.jmodelica.modelica.compiler.OptionExporter' \
    -t "${HOME}/template/Options.xml" -d "${HOME}/Options.xml"