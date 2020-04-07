#Copyright (C) 2013 Modelon AB

#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, version 3 of the License.

#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.

#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.

import os
import sys
import platform
from pymodelica.compiler_exceptions import JError
from casadi import *
from modelicacasadi_wrapper import *
JVM_SET_UP=False


def transfer_model(model, class_name, file_name=[],
                   compiler_options={}, 
                   compiler_log_level='warning'):
    """ 
    Compiles and transfers a model to the ModelicaCasADi interface. 
    
    A destination model object and model class name must be passed, all other arguments have default values. 
    The different scenarios are:
    
    * Only class_name is passed: 
        - Class is assumed to be in MODELICAPATH.
    
    * class_name and file_name is passed:
        - file_name can be a single path as a string or a list of paths 
          (strings). The paths can be file or library paths.
    
    Library directories can be added to MODELICAPATH by listing them in a 
    special compiler option 'extra_lib_dirs', for example:
    
        compiler_options = 
            {'extra_lib_dirs':['c:\MyLibs1','c:\MyLibs2']}
        
    Other options for the compiler should also be listed in the compiler_options 
    dict.
    
        
    Parameters::

        model --
            A blank Model to be populated.
    
        class_name -- 
            The name of the model class.
            
        file_name -- 
            A path (string) or paths (list of strings) to model files and/or 
            libraries.
            Default: Empty list.
                        
        compiler_options --
            Options for the compiler.
            Note that MODELICAPATH is set to the standard for this
            installation if not given as an option.
            Default: Empty dict.
            
        compiler_log_level --
            Set the logging for the compiler. Valid options are:
            'warning'/'w', 'error'/'e', 'info'/'i' or 'debug'/'d'. 
            Default: 'warning'

    """
    _ensure_jvm()
    if isinstance(file_name, basestring):
        files = [file_name]
    else: 
        files = file_name
    # Work around that the JVM might not be aware of the current working directory
    files = map(os.path.abspath, files)
    if has_mop_file(files):
        return modelicacasadi_wrapper.transferModelFromOptimicaCompiler(model, class_name, files,
            _get_options_optimica(compiler_options), compiler_log_level)
    else:
        return modelicacasadi_wrapper.transferModelFromModelicaCompiler(model, class_name, files,
            _get_options_modelica(compiler_options), compiler_log_level)

def transfer_optimization_problem(ocp, class_name, 
                                  file_name=[],
                                  compiler_options={}, 
                                  compiler_log_level='warning',
                                  accept_model=False):
    """ 
    Compiles and transfers an optimization problem to the ModelicaCasADi interface. 
    
    A destination problem object and model class name must be passed, all other arguments have default values. 
    The different scenarios are:
    
    * Only class_name is passed: 
        - Class is assumed to be in MODELICAPATH.
    
    * class_name and file_name is passed:
        - file_name can be a single path as a string or a list of paths 
          (strings). The paths can be file or library paths.
    
    Library directories can be added to MODELICAPATH by listing them in a 
    special compiler option 'extra_lib_dirs', for example:
    
        compiler_options = 
            {'extra_lib_dirs':['c:\MyLibs1','c:\MyLibs2']}
        
    Other options for the compiler should also be listed in the compiler_options 
    dict.
    
        
    Parameters::
    
        ocp --
            A blank OptimizationProblem to be populated.

        class_name -- 
            The name of the model class.
            
        file_name -- 
            A path (string) or paths (list of strings) to model files and/or 
            libraries.
            Default: Empty list.

        compiler_options --
            Options for the compiler.
            Note that MODELICAPATH is set to the standard for this
            installation if not given as an option.
            Default: Empty dict.
            
        compiler_log_level --
            Set the logging for the compiler. Valid options are:
            'warning'/'w', 'error'/'e', 'info'/'i' or 'debug'/'d'. 
            Default: 'warning'

        accept_model --
            If true, allows to transfer a model. Only the model parts of the
            OptimizationProblem will be initialized.

    """
    _ensure_jvm()
    if isinstance(file_name, basestring):
        files = [file_name]
    else: 
        files = file_name
    # Work around that the JVM might not be aware of the current working directory
    files = map(os.path.abspath, files)
    if has_mop_file(files):
        if not accept_model:
            return _transfer_optimica(ocp, class_name, files,
                                      _get_options_optimica(compiler_options), compiler_log_level)
        else:
            return modelicacasadi_wrapper.transferModelFromOptimicaCompiler(ocp, class_name, files,
                               _get_options_optimica(compiler_options), compiler_log_level)            
        
    else:
        if not accept_model:
            raise JError("Trying to transfer optimization problem, but no .mop files given.\n" +
                         "Use accept_model=True if you want to create an optimization problem from a model.")
        return modelicacasadi_wrapper.transferModelFromModelicaCompiler(ocp, class_name, files,
                                  _get_options_modelica(compiler_options), compiler_log_level)
        

def _ensure_jvm():
    global JVM_SET_UP
    if not JVM_SET_UP:
        setUpJVM()
        JVM_SET_UP=True

def _transfer_modelica(model, class_name, files, options, log_level):
    return modelicacasadi_wrapper._transferModelicaModel(model, class_name, files, options, log_level)
    
def _transfer_optimica(ocp, class_name, files, options, log_level):
    return modelicacasadi_wrapper._transferOptimizationProblem(ocp, class_name, files, options, log_level)


def _get_options_modelica(compiler_options):
    return _get_options(compiler_options, ModelicaOptionsWrapper())


def _get_options_optimica(compiler_options):
    return _get_options(compiler_options, OptimicaOptionsWrapper())

def _get_options(compiler_options, options_wrapper):
    """
    Initialize an instance of the ModelicaOptionsWrapper or OptimicaOptionsWrapper
    for ModelicaCasADi. 

    Note that MODELICAPATH is set to the standard for this
    installation if not given as an option.

    Parameters::

        compiler_options --
            A dict of options where the key specifies which option to modify 
            and the value the new value for the option.

    Returns::

        The initialized options_wrapper argument. --
            
    """
    if not compiler_options.has_key("MODELICAPATH"):
        options_wrapper.setStringOption("MODELICAPATH", os.path.join(os.environ['JMODELICA_HOME'],'ThirdParty','MSL'))
    else:
        options_wrapper.setStringOption("MODELICAPATH", compiler_options["MODELICAPATH"])
        
    #Makes equation_sorting false by default in casadi_interface
    if not compiler_options.has_key("equation_sorting"):
        options_wrapper.setBooleanOption("equation_sorting", False)
        
    #Makes automatic_tearing false by default in casadi_interface
    if not compiler_options.has_key("automatic_tearing"):
        options_wrapper.setBooleanOption("automatic_tearing", False) 
        
    #Makes automatic_tearing false by default in casadi_interface
    if not compiler_options.has_key("generate_runtime_option_parameters"):
        options_wrapper.setBooleanOption("generate_runtime_option_parameters", False)    
     

    # set compiler options
    for key, value in compiler_options.iteritems():
        if isinstance(value, bool):
            options_wrapper.setBooleanOption(key, value)
        elif isinstance(value, basestring):
            options_wrapper.setStringOption(key,value)
        elif isinstance(value, int):
            options_wrapper.setIntegerOption(key,value)
        elif isinstance(value, float):
            options_wrapper.setRealOption(key,value)
        elif isinstance(value, list):
            options_wrapper.setStringOption(key, _list_to_string(value))
    return options_wrapper

def printCompilerOptions():
    _ensure_jvm()
    options_wrapper = ModelicaOptionsWrapper()
    options_wrapper.printOpts()

def has_mop_file(files):
    for f in files:
        basename, ext = os.path.splitext(f)
        if ext == '.mop':
            return True
    return False

def _list_to_string(item_list):
    """
    Helper function that takes a list of items, which are typed to str and 
    returned as a string with the list items separated by platform dependent 
    path separator. For example: 
        (platform = win)
        item_list = [1, 2, 3]
        return value: '1;2;3'
    """
    ret_str = ''
    for l in item_list:
        ret_str =ret_str+str(l)+os.pathsep
    return ret_str
