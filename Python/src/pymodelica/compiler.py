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
Module containing convenience functions for compiling models. Options which 
are user specific can be set either before importing this module by editing 
the file options.xml or interactively. If options are not changed the default 
option settings will be used.
"""

import os
import sys
import platform as plt
import logging
from subprocess import Popen, PIPE
import subprocess
from compiler_logging import CompilerLogHandler
from compiler_exceptions import JError
from compiler_exceptions import IllegalCompilerArgumentError
from compiler_exceptions import IllegalLogStringError

import pymodelica as pym
from pymodelica.common import xmlparser
from pymodelica.common.core import get_unit_name, list_to_string


def compile_fmu(class_name, file_name=[], compiler='auto', target='me', version='2.0', 
                platform='auto', compiler_options={}, compile_to='.', 
                compiler_log_level='warning', separate_process=True, jvm_args=''):
    """ 
    Compile a Modelica model to an FMU.
    
    A model class name must be passed, all other arguments have default values. 
    The different scenarios are:
    
    * Only class_name is passed: 
        - Class is assumed to be in MODELICAPATH.
    
    * class_name and file_name is passed:
        - file_name can be a single path as a string or a list of paths 
          (strings). The paths can be file or library paths.
        - Default compiler setting is 'auto' which means that the appropriate 
          compiler will be selected based on model file ending, i.e. 
          ModelicaCompiler if a .mo file and OptimicaCompiler if a .mop file is 
          found in file_name list.
    
    The compiler target is 'me' by default which means that the shared 
    file contains the FMI for Model Exchange API. Setting this parameter to 
    'cs' will generate an FMU containing the FMI for Co-Simulation API.
    
    Parameters::
    
        class_name -- 
            The name of the model class.
            
        file_name -- 
            A path (string) or paths (list of strings) to model files and/or 
            libraries.
            Default: Empty list.
            
        compiler -- 
            The compiler used to compile the model. The different options are:
              - 'auto': the compiler is selected automatically depending on 
                 file ending
              - 'modelica': the ModelicaCompiler is used
              - 'optimica': the OptimicaCompiler is used
            Default: 'auto'
            
        target --
            Compiler target. Possible values are 'me', 'cs' or 'me+cs'.
            Default: 'me'
            
        version --
            The FMI version. Valid options are '1.0' and '2.0'.
            Default: '2.0'
            
        platform --
            Set platform, controls whether a 32 or 64 bit FMU is generated. This 
            option is only available for Windows.
            Valid options are:
              - 'auto': platform is selected automatically. This is the only 
                valid option for linux and darwin.
              - 'win32': generate a 32 bit FMU
              - 'win64': generate a 64 bit FMU
            Default: 'auto'
            
        compiler_options --
            Options for the compiler.
            Default: Empty dict.
            
        compile_to --
            Specify target file or directory. If file, any intermediate directories 
            will be created if they don't exist. Furthermore, the Modelica model will
            be renamed to this name. If directory, the path given must exist and the model
            will keep its original name.
            Default: Current directory.

        compiler_log_level --
            Set the logging for the compiler. Takes a comma separated list with
            log outputs. Log outputs start with a flag :'warning'/'w',
            'error'/'e', 'verbose'/'v', 'info'/'i' or 'debug'/'d'. The log can
            be written to file by appended flag with a colon and file name.
            Default: 'warning'
        
        separate_process --
            Run the compilation of the model in a separate process. 
            Checks the environment variables (in this order):
                1. SEPARATE_PROCESS_JVM
                2. JAVA_HOME
            to locate the Java installation to use. 
            For example (on Windows) this could be:
                SEPARATE_PROCESS_JVM = C:\Program Files\Java\jdk1.6.0_37
            Default: True
            
        jvm_args --
            String of arguments to be passed to the JVM when compiling in a 
            separate process.
            Default: Empty string
            
            
    Returns::
    
        A compilation result, represents the name of the FMU which has been
        created and a list of warnings that was raised.
    
    """
    #Remove in JModelica.org version 2.3
    if compiler_options.has_key("extra_lib_dirs"):
        print "Warning: The option 'extra_lib_dirs' has been deprecated and will be removed. Please use the 'file_name' to pass additional libraries."
    
    if (target != "me" and target != "cs" and target != "me+cs"):
        raise IllegalCompilerArgumentError("Unknown target '" + target + "'. Use 'me', 'cs' or 'me+cs' to compile an FMU.")
    return _compile_unit(class_name, file_name, compiler, target, version,
                platform, compiler_options, compile_to, compiler_log_level,
                separate_process, jvm_args)       

def compile_fmux(class_name, file_name=[], compiler='auto', compiler_options={}, 
                 compile_to='.', compiler_log_level='warning', separate_process=True,
                 jvm_args=''):
    """ 
    Compile a Modelica model to an FMUX.
    
    A model class name must be passed, all other arguments have default values. 
    The different scenarios are:
    
    * Only class_name is passed: 
        - Class is assumed to be in MODELICAPATH.
    
    * class_name and file_name is passed:
        - file_name can be a single path as a string or a list of paths 
          (strings). The paths can be to files or libraries
    
    
    Parameters::
    
        class_name -- 
            The name of the model class.
            
        file_name -- 
            A path (string) or paths (list of strings) to model files and/or 
            libraries.
            Default: Empty list.
            
        compiler -- 
            The compiler used to compile the model.
            Default: 'auto'
            
        compiler_options --
            Options for the compiler.
            Default: Empty dict.
            
        compile_to --
            Specify target file or directory. If file, any intermediate directories 
            will be created if they don't exist. Furthermore, the Modelica model will
            be renamed to this name. If directory, the path given must exist and the model
            will keep its original name.
            Default: Current directory.

        compiler_log_level --
            Set the logging for the compiler. Takes a comma separated list with
            log outputs. Log outputs start with a flag :'warning'/'w',
            'error'/'e', 'verbose'/'v', 'info'/'i' or 'debug'/'d'. The log can
            be written to file by appended flag with a colon and file name.
            Default: 'warning'
        
        separate_process --
            Run the compilation of the model in a separate process. 
            Checks the environment variables (in this order):
                1. SEPARATE_PROCESS_JVM
                2. JAVA_HOME
            to locate the Java installation to use. 
            For example (on Windows) this could be:
                SEPARATE_PROCESS_JVM = C:\Program Files\Java\jdk1.6.0_37
            Default: True
            
        jvm_args --
            String of arguments to be passed to the JVM when compiling in a 
            separate process.
            Default: Empty string
            
    Returns::
    
        A compilation result, represents the name of the FMUX which has been
        created and a list of warnings that was raised.
    
    """
    return _compile_unit(class_name, file_name, compiler, 'fmux', None, 'auto',
                compiler_options, compile_to, compiler_log_level,
                separate_process, jvm_args)

def _compile_unit(class_name, file_name, compiler, target, version,
                platform, compiler_options, compile_to, compiler_log_level,
                separate_process, jvm_args):
    """
    Helper function for compile_fmu and compile_fmux.
    """
    for key, value in compiler_options.iteritems():
        if isinstance(value, list):
            compiler_options[key] = list_to_string(value)
    
    if isinstance(file_name, basestring):
        file_name = [file_name]
        
    if platform == 'auto':
        platform = _get_platform()
        
    if not separate_process:
        # get a compiler based on 'compiler' argument or files listed in file_name
        comp = _get_compiler(files=file_name, selected_compiler=compiler)
        # set compiler options
        comp.set_options(compiler_options)
        
        # set log level
        comp.set_compiler_logger(compiler_log_level)
        
        # set platform
        comp.set_target_platforms(platform)
        
        # compile unit in java
        return comp.compile_Unit(class_name, file_name, target, version, compile_to)

    else:
        return compile_separate_process(class_name, file_name, compiler, target, version, platform, 
                                        compiler_options, compile_to, compiler_log_level, jvm_args)

def compile_separate_process(class_name, file_name=[], compiler='auto', target='me', version='1.0', 
                             platform='auto', compiler_options={}, compile_to='.', 
                             compiler_log_level='warning', jvm_args=''):
    """
    Compile model in separate process.
    Requires environment variable SEPARATE_PROCESS_JVM to be set, otherwise defaults
    to JAVA_HOME.
    
    Parameters::
    
        class_name -- 
            The name of the model class.
            
        file_name -- 
            A path (string) or paths (list of strings) to model files and/or 
            libraries. Supports only be .mo files.
            Default: Empty list.
            
        compiler -- 
            The compiler used to compile the model. The different options are:
              - 'auto': the compiler is selected automatically depending on 
                 file ending
              - 'modelica': the ModelicaCompiler is used
              - 'optimica': the OptimicaCompiler is used
            Default: 'auto'
            
        target --
            Compiler target. Valid options are 'me', 'cs' or 'fmux'.
            Default: 'me'
            
        version --
            The FMI version. Valid options are '1.0' and '2.0'.
            Note: Must currently be set to '1.0'.
            
        platform --
            Set platform, controls whether a 32 or 64 bit FMU is generated. This 
            option is only available for Windows.
            Valid options are:
              - 'auto': platform is selected automatically. This is the only 
                valid option for linux and darwin.
              - 'win32': generate a 32 bit FMU
              - 'win64': generate a 64 bit FMU
            Default: 'auto'

        compiler_options --
            Options for the compiler.
            Default: Empty dict.
            
        compile_to --
            Specify target file or directory. If file, any intermediate directories 
            will be created if they don't exist. Furthermore, the Modelica model will
            be renamed to this name. If directory, the path given must exist and the model
            will keep its original name.
            Default: Current directory.
        
        compiler_log_level --
            Set the logging for the compiler. Takes a comma separated list with
            log outputs. Log outputs start with a flag :'warning'/'w',
            'error'/'e', 'verbose'/'v', 'info'/'i' or 'debug'/'d'. The log can
            be written to file by appended flag with a colon and file name.
            Default: 'warning'
        
        jvm_args --
            String of arguments to be passed to the JVM when compiling in a 
            separate process.
            Default: Empty string
        
    Returns::
        A CompilerResult object with the name of the generated unit (or 'None' if no unit was generated) 
        and a list of warnings given by the compiler.
    """
    cmd = []
    
    cmd.append(_get_separate_JVM())
    
    cmd.append('-cp')
    cmd.append(pym.environ['COMPILER_JARS'])
    
    for jvm_arg in pym.environ['JVM_ARGS'].split() + jvm_args.split():
        cmd.append(jvm_arg)
        
    if _which_compiler(file_name, compiler) is 'MODELICA':
        cmd.append(pym._modelica_class)
    else: 
        cmd.append(pym._optimica_class)
    
    cmd.append('-log=' + _gen_log_level(compiler_log_level))
    
    if compiler_options:
        cmd.append('-opt=' + _gen_compiler_options(compiler_options))
    
    cmd.append("-target=" + target)
    
    cmd.append("-version=" + str(version))  # str() in case it is None
    
    
    if platform == 'auto':
        platform = _get_platform()
    cmd.append("-platform=" + platform)
    
    cmd.append("-out=" + compile_to)
    
    cmd.append("-modelicapath=" + pym.environ['MODELICAPATH'])
    
    cmd.append(",".join(file_name))
    
    cmd.append(class_name)
    
    if plt.system() == "Windows":
        si = subprocess.STARTUPINFO()
        si.dwFlags |= subprocess.STARTF_USESHOWWINDOW
    else:
        si = None
    process = Popen(cmd, stderr=PIPE, startupinfo=si)
    log = CompilerLogHandler()
    log.start(process.stderr);
    try:
        process.wait();
    finally:
        return log.end();

def _gen_compiler_options(compiler_options):
    """
    Helper function. Takes compiler options dict and generates a string with 
    options so the Java compiler understands it.
    """
    # Save in opts in the form: opt1:val1,opt2:val2
    opts = ','.join(['%s:%s' %(k, v) for k, v in compiler_options.iteritems()])
    # Convert all Python True/False to Java true/false
    opts = opts.replace('True', 'true')
    opts = opts.replace('False', 'false')
    return opts
    
def _gen_log_level(log_string):
    """
    Helper function. Takes log level as accepted by Python and generates a string
    which is understood by the Java compiler.
    """
    if "|stderr" in log_string:
        raise IllegalLogStringError("Piping compiler log to stderr is not allowed in separate process.")
    if len(log_string) == 0:
        log_string = 'w'
    log_string += ",w|xml|stderr"
    return log_string
    
def _get_separate_JVM():
    """
    Helper function for getting the path to Java to use when compiling in a separate 
    process.
    """
    # Check if SEPARATE_PROCESS_JVM is set, otherwise return with an error
    separate_jvm = ''
    try:
        separate_jvm = os.environ['SEPARATE_PROCESS_JVM']
    except KeyError:
        try:
            logging.warning("The environment variable SEPARATE_PROCESS_JVM is not set. Trying JAVA_HOME instead.")
            separate_jvm = os.environ['JAVA_HOME']
        except KeyError:
            raise Exception("Neither SEPARATE_PROCESS_JVM nor JAVA_HOME is not set.")
    # Check that SEPARATE_PROCESS_JVM points at a Java
    # Accepted paths:
    # Full path to java executable
    # <JDK home>
    # <JRE home>
    separate_jvm = _ensure_path(separate_jvm, os.path.join('bin', 'java'))
    
    # Check that path exist
    # First make sure that all path separators are correct
    if _get_platform().startswith('win'):
        separate_jvm+= '.exe' 
    if not os.path.exists(separate_jvm):
        raise Exception("The path to Java %s does not exist." %(separate_jvm))
 
    return separate_jvm

def _ensure_path(start, end):
    """
    Helper function for building the correct path to Java. Handled cases:
    - Full path to Java executable
    - Path to JDK home
    - Path to JVM home
    """
    if start.endswith(end):
        return start
    endparts = end.split(os.path.sep)
    for e in endparts:
        if start.endswith(e):
            continue
        else:
            start = os.path.join(start, e)
            
    return start


def _get_compiler(files, selected_compiler='auto'):
    from compiler_wrappers import ModelicaCompiler, OptimicaCompiler
    
    comp = _which_compiler(files, selected_compiler)
    if comp is 'MODELICA':
        return ModelicaCompiler()
    else:
        return OptimicaCompiler()
            
    return comp

def _which_compiler(files, selection_mode='auto'):
    # if selection_mode is 'auto' - detect file suffix
    if selection_mode == 'auto':
        comp = 'MODELICA'
        for f in files:
            basename, ext = os.path.splitext(f)
            if ext == '.mop':
                comp = 'OPTIMICA'
                break
    else:
        if selection_mode.lower() == 'modelica':
            comp = 'MODELICA'
        elif selection_mode.lower() == 'optimica':
            comp = 'OPTIMICA'
        else:
            logging.warning("Invalid compiler selected: %s using OptimicaCompiler instead." %(selection_mode))
            comp = 'OPTIMICA'
            
    return comp     
    
def _get_platform():
    """ 
    Helper function. Returns string describing the platform on which jmodelica 
    is run. 
    
    Possible return values::
        
        win32
        win64
        darwin32
        darwin64
        linux32
        linux64
    """
    _platform = ''
    if sys.platform == 'win32':
        # windows
        _platform = 'win'
    elif sys.platform == 'darwin':
        # mac
        _platform = 'darwin'
    else:
        # assume linux
        _platform = 'linux'
    
    (bits, linkage) =  plt.architecture()
    if bits == '32bit':
        _platform = _platform +'32'
    else:
        _platform = _platform + '64'
    
    return _platform

class CompilerResult(str):
    """
    This class is returned after a successful compilation. The class extends
    the native python string class, so it is possible to manipulate this object
    as an string. The string equals the name of the generated object. It is also
    possible to retreive warnings that was given during compilation.
    """
    def __new__(cls, fmuName, warnings):
        """
        Creates a new result object.
        
        Parameters:
            fmuName --
                The name of the generated fmu.
            
            warnings --
                A list of compilation warnings.
        """
        obj = str.__new__(cls, fmuName)
        obj.warnings = warnings
        return obj
    
    def get_warnings(self):
        """
        Returns the list of warnings.
        """
        return self.warnings

