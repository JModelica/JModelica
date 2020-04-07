#!/usr/bin/env python
# -*- coding: utf-8 -*-

#    Copyright (C) 2014 Modelon AB
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, version 3 of the License.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
"""
Internal module, interface to Java classes
"""
import string
import os

import jpype

import pymodelica as pym

_jm_home = pym.environ['JMODELICA_HOME']

#start JVM
# note that startJVM() fails after shutdownJVM(), hence, only one start
if not jpype.isJVMStarted():
    _jvm_args = string.split(pym.environ['JVM_ARGS'],' ')
    _jvm_class_path = pym.environ['COMPILER_JARS']
    _jvm_ext_dirs = pym.environ['BEAVER_PATH']
    jpype.startJVM(pym.environ['JPYPE_JVM'], 
        '-Djava.class.path=%s' % os.pathsep.join([_jvm_class_path]),
        *_jvm_args)
    org = jpype.JPackage('org')
    print "JVM started."


# Compilers
ModelicaCompilerInterface = None
OptimicaCompilerInterface = None
if pym._modelica_class:
    ModelicaCompilerInterface = jpype.JClass(pym._modelica_class)
if pym._optimica_class:
    OptimicaCompilerInterface = jpype.JClass(pym._optimica_class)

# Options registry
OptionRegistryInterface = org.jmodelica.common.options.OptionRegistry

# Exceptions
UnknownOptionException = jpype.JClass(
    'org.jmodelica.common.options.AbstractOptionRegistry$UnknownOptionException')
    
InvalidOptionValueException = jpype.JClass(
    'org.jmodelica.common.options.AbstractOptionRegistry$InvalidOptionValueException')

IllegalLogStringException = org.jmodelica.util.logging.IllegalLogStringException

CompilerException = org.jmodelica.util.exceptions.CompilerException
IllegalCompilerArgumentException = org.jmodelica.util.exceptions.IllegalCompilerArgumentException
ModelicaClassNotFoundException = org.jmodelica.util.exceptions.ModelicaClassNotFoundException
ModelicaCCodeCompilationException = org.jmodelica.modelica.compiler.CcodeCompilationException
OptimicaCCodeCompilationException = org.jmodelica.optimica.compiler.CcodeCompilationException

SAXException = org.xml.sax.SAXException
SAXNotRecognizedException = org.xml.sax.SAXNotRecognizedException
SAXNotSupportedException = org.xml.sax.SAXNotSupportedException
SAXParseException = org.xml.sax.SAXParseException
