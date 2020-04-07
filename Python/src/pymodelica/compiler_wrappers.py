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
Interfaces to the JModelica.org Modelica and Optimica compilers.

"""
import jpype

import pymodelica as pym
from compiler_interface import *
from compiler_logging import CompilerLogHandler, LogHandlerThread
from pymodelica.common.core import list_to_string
from compiler_exceptions import *


class ModelicaCompiler(object):
    """ 
    User class for accessing the Java ModelicaCompiler class. 
    """
    
    jm_home = pym.environ['JMODELICA_HOME']

    def __init__(self):
        """ 
        Create a Modelica compiler. The compiler can be used to compile pure 
        Modelica models. A compiler instance can be used multiple times.
        """
        try:
            options = ModelicaCompilerInterface.createOptions()
        except jpype.JavaException as ex:
            self._handle_exception(ex)
            
        options.setStringOption('MODELICAPATH',pym.environ['MODELICAPATH'])
        
        self._compiler = pym._create_compiler(ModelicaCompilerInterface, options)
        
    def set_options(self, compiler_options):
        """
        Set compiler options. See available options in the file options.xml.
        
        Parameters::
        
            compiler_options --
                A dict of options where the key specifies which option to modify 
                and the value the new value for the option.
        
        Raises::
        
            JMIException if the value of the option is not one of the allowed 
            types (float, boolean, string, integer or list).
        """
        # set compiler options
        for key, value in compiler_options.iteritems():
            if isinstance(value, bool):
                self.set_boolean_option(key, value)
            elif isinstance(value, basestring):
                self.set_string_option(key,value)
            elif isinstance(value, int):
                self.set_integer_option(key,value)
            elif isinstance(value, float):
                self.set_real_option(key,value)
            else:
                raise JMIException("Unknown compiler option type for key: %s. \
                Should be of the following types: boolean, string, integer, \
                float or list" %key)

    def set_compiler_logger(self, log_string):
        """ 
        Set the logger. 
        
        Parameters::
        
            log_string --
                Configuration string for the logger.
        """
        try:
            self._compiler.setLogger(log_string)
        except jpype.JavaException as ex:
            self._handle_exception(ex)

    def get_modelicapath(self):
        """ 
        Get the path to Modelica libraries set for this compiler.
        
        Returns::
        
            Path to Modelica libraries set.
        """
        return self._compiler.getModelicapath()
    
    def set_modelicapath(self, path):
        """ 
        Set the path to Modelica libraries for this compiler instance. 
        
        Parameters::
        
            path --
                The path to Modelica libraries.
        """
        self._compiler.setModelicapath(path)

    def create_target_object(self, target, version):
        """ 
        Creates a target object.
        
        Parameters::
        
            target --
                The target type.
            
            version --
                The version in case of a fmu
        
        """
        try:
            target_obj = self._compiler.createTargetObject(target, version)
        except jpype.JavaException as ex:
            self._handle_exception(ex)
        return target_obj

    def get_boolean_option(self, key):
        """ 
        Get the boolean option set for the specific key. 
        
        Parameters::
        
            key --
                Get the boolean option for this key.
        
        Raises::
        
            UnknownOptionError if the option does not exist.
        """
        try:
            option = self._compiler.getBooleanOption(key)
        except jpype.JavaException as ex:
            self._handle_exception(ex)
        return bool(option)
    
    def set_boolean_option(self, key, value):
        """ 
        Set the boolean option with key to value. If the option does not exist 
        an exception will be raised. 
        
        Parameters::
        
            key --
                Key for the boolean option.
                
            value --
                Boolean option.
                
        Raises::
        
            UnknownOptionError if the option does not exist.
        """
        try:
            self._compiler.setBooleanOption(key, value)
        except jpype.JavaException as ex:
            self._handle_exception(ex)
        
    def get_integer_option(self, key):
        """ 
        Get the integer option set for the specific key. 
        
        Parameters::
        
            key --
                Get the integer option for this key.
        
        Raises::
        
            UnknownOptionError if the option does not exist.
        """
        try:
            option = self._compiler.getIntegerOption(key)
        except jpype.JavaException as ex:
            self._handle_exception(ex)
        return option
    
    def set_integer_option(self, key, value):
        """ 
        Set the integer option with key to value. If the option does not exist 
        an exception will be raised. 
        
        Parameters::
        
            key --
                Key for the integer option.
                
            value --
                Integer option.
                
        Raises::
        
            UnknownOptionError if the options does not exist.
        """
        try:
            self._compiler.setIntegerOption(key, value)
        except jpype.JavaException as ex:
            self._handle_exception(ex)
        
    def get_real_option(self, key):
        """ 
        Get the real option set for the specific key. 
        
        Parameters::
        
            key --
                Get the real option for this key.
        
        Raises::
        
            UnknownOptionError if the option does not exist.
        """
        try:
            option = self._compiler.getRealOption(key)
        except jpype.JavaException as ex:
            self._handle_exception(ex)
        return option
    
    def set_real_option(self, key, value):
        """ 
        Set the real option with key to value. If the option does not exist an 
        exception will be raised.
        
        Parameters::
        
            key --
                Key for the real option.
                
            value --
                Real option.
                
        Raises::
        
            UnknownOptionError if the options does not exist.
        """
        try:
            self._compiler.setRealOption(key, value)
        except jpype.JavaException as ex:
            self._handle_exception(ex)
                    
    def get_string_option(self, key):
        """ 
        Get the string option set for the specific key. 
        
        Parameters::
        
            key --
                Get the string option for this key.
                
        Raises::
        
            UnknownOptionError if the option does not exist.
        """
        try:
            option = self._compiler.getStringOption(key)
        except jpype.JavaException as ex:
            self._handle_exception(ex)
        return str(option)
        
    def set_string_option(self, key, value):
        """ 
        Set the string option with key to value. If the option does not exist an 
        exception will be raised.
        
        Parameters::
        
            key --
                Key for the string option.
                
            value --
                String option.
                
        Raises::
        
            UnknownOptionError if the options does not exist.
        """
        try:
            self._compiler.setStringOption(key, value)
        except jpype.JavaException as ex:
            self._handle_exception(ex)
        
    def get_warnings(self):
        """ 
        Get the warnings that have been collected in the compiler since
        last call to this method.
        
        Returns::
        
            A list of warnings
        """
        java_warnings = self._compiler.retrieveAndClearWarnings()
        warnings = []
        for java_warning in java_warnings:
            warnings.append(CompilationWarning( \
                java_warning.identifier(), \
                java_warning.kind().toString(), \
                java_warning.fileName(), \
                java_warning.beginLine(), \
                java_warning.beginColumn(), \
                java_warning.message() \
            ));
        return warnings
        
    def set_target_platforms(self, platforms):
        if isinstance(platforms, basestring):
            platforms = [platforms]
        self._compiler.targetPlatforms = platforms
        
    def compile_Unit(self, class_name, file_name, target, version, compile_to):
        """
        Compiles a model (parsing, instantiating, flattening, code generation 
        and binary file generation) and creates an FMU on the file system. Set 
        target to specify which type of FMU should be created. The different 
        targets are "me" and "cs". 
        
        Note: target must currently be set to 'model_fmume'.
        
        Parameters::
        
            class_name --
                Name of model class in the model file to compile.
            
            file_name --
                Path to file or list of paths to files or libraries 
                in which the model is contained.
                
            target --
                The build target. Valid options are 'me' and 'cs'.
                
            version --
                The FMI version. Valid options are '1.0' and '2.0'.
                
            compile_to --
                Specify location of the compiled FMU. Directory will be created 
                if it does not exist.
        
        Returns::
        
            A list of warnings given by the compiler
        """
        self._compiler.retrieveAndClearWarnings() # Remove old warnings
        unit = None
        try:
            unit = self._compiler.compileUnit(class_name, file_name, target, version, compile_to)
            self._compiler.closeLogger()
        except jpype.JavaException as ex:
            self._handle_exception(ex)
        from compiler import CompilerResult
        return CompilerResult(unit, self.get_warnings())

    def parse_model(self,model_file_name):
        """ 
        Parse a model.

        Parse a model and return a reference to the source tree representation.

        Parameters::
            
            model_file_name -- 
                Path to file or list of paths to files or libraries 
                in which the model is contained.

        Returns::
        
            Reference to the root of the source tree representation of the 
            parsed model.

        Raises::
        
            CompilerError if one or more error is found during compilation.
            
            IOError if the model file is not found, can not be read or any other 
            IO related error.
            
            Exception if there are general errors related to the parsing of the 
            model.
            
            JError if there was a runtime exception thrown by the underlying 
            Java classes.
        """        
        if isinstance(model_file_name, basestring):
            model_file_name = [model_file_name]
        try:
            sr = self._compiler.parseModel(model_file_name)
            return sr        
        except jpype.JavaException as ex:
            self._handle_exception(ex)

    def instantiate_model(self, source_root, model_class_name, target):
        """ 
        Generate an instance tree representation for a model.

        Generate an instance tree representation for a model using the 
        source tree belonging to the model which must first be created 
        with parse_model.

        Parameters::
          
            source_root -- 
                Reference to the root of the source tree representation.
                
            model_class_name -- 
                Name of model class in the model file to compile.
            
            target --
                Compilation target object returned by create_target_object()

        Returns::
        
            Reference to the instance AST node representing the model instance. 

        Raises::
        
            CompilerError if one or more error is found during compilation.
            
            ModelicaClassNotFoundError if the model class is not found.
            
            JError if there was a runtime exception thrown by the underlying 
            Java classes.
        """    
        try:
            ipr = self._compiler.instantiateModel(source_root, model_class_name, target)
            return ipr    
        except jpype.JavaException as ex:
            self._handle_exception(ex)

    def flatten_model(self, inst_class_decl, target):
        """ 
        Compute a flattened representation of a model. 

        Compute a flattened representation of a model using the instance tree 
        belonging to the model which must first be created with 
        instantiate_model.

        Parameters::
          
            inst_class_decl -- 
                Reference to a model instance. 
            
            target --
                Compilation target object returned by create_target_object()

        Returns::
        
            Object (FClass) representing the flattened model. 

        Raises::
        
            CompilerError if one or more error is found during compilation.
            
            ModelicaClassNotFoundError if the model class is not found.
            
            IOError if the model file is not found, can not be read or any 
            other IO related error.
            
            JError if there was a runtime exception thrown by the underlying 
            Java classes.
        """
        try:
            fclass = self._compiler.flattenModel(inst_class_decl, target, None)
            return fclass    
        except jpype.JavaException as ex:
            self._handle_exception(ex)

    def generate_code(self, fclass, target):
        """ 
        Generate code for a model.

        Generate code for a model c and xml code for a model using the FClass 
        represenation created with flatten_model and template files located in 
        the JModelica installation folder. Default output folder is the current 
        folder from which this module is run.

        Parameters::
        
            fclass -- 
                Reference to the flattened model object representation.  
            
            target --
                Compilation target object returned by create_target_object()

        Raises::
        
            IOError if the model file is not found, can not be read or any other 
            IO related error.
                
            JError if there was a runtime exception thrown by the underlying 
            Java classes.
        """
        try:
            self._compiler.generateCode(fclass, target)
        except jpype.JavaException as ex:
            self._handle_exception(ex)
            
    def _handle_exception(self, ex):
        """ 
        Catch and handle all expected Java Exceptions that the 
        underlying Java classes might throw. Raises an appropriate Python error 
        or the default JError.
        """
        if ex.javaClass() is CompilerException:
            arraylist = ex.__javaobject__.getProblems()
            itr = arraylist.iterator()

            errors = []
            warnings = []
            while itr.hasNext():
                problem = itr.next()
                if str(problem.severity()).lower() == 'warning':
                    warnings.append(CompilationWarning( \
                        problem.identifier(), \
                        str(problem.kind()).lower(), \
                        problem.fileName(), \
                        problem.beginLine(), \
                        problem.beginColumn(), \
                        problem.message() \
                    ))
                else:
                    errors.append(CompilationError( \
                        problem.identifier(), \
                        str(problem.kind()).lower(), \
                        problem.fileName(), \
                        problem.beginLine(), \
                        problem.beginColumn(), \
                        problem.message() \
                    ))
            raise CompilerError(errors, warnings)
        
        if ex.javaClass() is IllegalCompilerArgumentException:
            raise IllegalCompilerArgumentError(
                str(ex.__javaobject__.getMessage()))
        
        if ex.javaClass() is ModelicaClassNotFoundException:
            raise ModelicaClassNotFoundError(
                str(ex.__javaobject__.getClassName()))
        
        if ex.javaClass() is IllegalLogStringException:
            raise IllegalLogStringError(
                str(ex.__javaobject__.getMessage()))
        
        if ex.javaClass() is jpype.java.io.FileNotFoundException:
            raise IOError(
                '\nMessage: '+ex.message().encode('utf-8')+\
                '\nStacktrace: '+ex.stacktrace().encode('utf-8'))
        
        if ex.javaClass() is jpype.java.io.IOException:
            raise IOError(
                '\nMessage: '+ex.message().encode('utf-8')+\
                '\nStacktrace: '+ex.stacktrace().encode('utf-8'))
        
        if ex.javaClass() is jpype.javax.xml.xpath.XPathExpressionException:
            raise XPathExpressionError(
                '\nMessage: '+ex.message().encode('utf-8')+\
                '\nStacktrace: '+ex.stacktrace().encode('utf-8'))
        
        if ex.javaClass() is jpype.javax.xml.parsers.ParserConfigurationException:
            raise ParserConfigurationError(
                '\nMessage: '+ex.message().encode('utf-8')+\
                '\nStacktrace: '+ex.stacktrace().encode('utf-8'))
        
        if ex.javaClass() is SAXException or \
            ex.javaClass() is SAXNotRecognizedException or \
            ex.javaClass() is SAXNotSupportedException or \
            ex.javaClass() is SAXParseException:
            raise SAXError(
                '\nMessage: '+ex.message().encode('utf-8')+\
                '\nStacktrace: '+ex.stacktrace().encode('utf-8'))
    
        if ex.javaClass() is UnknownOptionException:
            raise UnknownOptionError(
                ex.message().encode('utf-8')+'\nStacktrace: '+\
                    ex.stacktrace().encode('utf-8'))

        if ex.javaClass() is InvalidOptionValueException:
            raise InvalidOptionValueError(
                ex.message().encode('utf-8')+'\nStacktrace: '+\
                    ex.stacktrace().encode('utf-8'))
        
        if ex.javaClass() is jpype.java.lang.Exception:
            raise Exception(
                '\nMessage: '+ex.message().encode('utf-8')+\
                '\nStacktrace: '+ex.stacktrace().encode('utf-8'))
        
        if ex.javaClass() is jpype.java.lang.NullPointerException:
            raise JError(ex.stacktrace().encode('utf-8'))
        
        if ex.javaClass() is ModelicaCCodeCompilationException or \
            ex.javaClass() is OptimicaCCodeCompilationException:
            raise CcodeCompilationError(
                '\nMessage: '+ex.message().encode('utf-8')+\
                '\nStacktrace: '+ex.stacktrace().encode('utf-8'))
        
        raise JError(ex.stacktrace().encode('utf-8'))

class OptimicaCompiler(ModelicaCompiler):
    """ 
    User class for accessing the Java OptimicaCompiler class. 
    """

    jm_home = pym.environ['JMODELICA_HOME']

    def __init__(self):
        """ 
        Create an Optimica compiler. The compiler can be used to compile both 
        Modelica and Optimica models. A compiler instance can be used multiple 
        times.
        """
        try:
            options = OptimicaCompilerInterface.createOptions()
        except jpype.JavaException as ex:
            self._handle_exception(ex)
            
        options.setStringOption('MODELICAPATH',pym.environ['MODELICAPATH'])
        
        self._compiler = pym._create_compiler(OptimicaCompilerInterface, options)

    def set_boolean_option(self, key, value):
        """ 
        Set the boolean option with key to value. If the option does not exist 
        an exception will be raised. 
        
        Parameters::
        
            key --
                Key for the boolean option.
                
            value --
                Boolean option.
                
        Raises::
        
            UnknownOptionError if the options does not exist.
        """
        try:
            self._compiler.setBooleanOption(key, value)
        except jpype.JavaException as ex:
            self._handle_exception(ex)
