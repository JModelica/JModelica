# -*- coding: utf-8 -*-

#    Copyright (C) 2016 Modelon AB
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

"""Default startup script for jmodelica.org

This script sets items in the 'jmodelica.environ' dictionary. The
values are set from system environment variables if defined, otherwise
to default values. 

Values can be overriden by a user startup script (optional):

  $HOME/.jmodelica.org/user_startup.py (unix)
  $USERPROFILE/.jmodelica.org/user_startup.py (win32)

Required keys:
  'JMODELICA_HOME' : Path to JModelica.org installation directory
  'IPOPT_HOME' : Path to Ipopt installation directory
  'SUNDIALS_HOME' : Path to Sundials installation directory
  'MINGW_HOME' : Path to mingw installation directory (only win32)
  'COMPILER_JARS' : Paths to compiler jar files (path-separated depending on operating system)
  'BEAVER_LIB' : Path to Beaver lib directory
  'CLASSPATH' : Java CLASSPATH
  'JYPE_JVM' : Path to JVM dll file
  'JVM_ARGS' : JVM arguments


This script and the user startup script are executed in the jmodelica
module global namespace. Therefore, please use a leading underscore on
all names that are used, unless it is explicitly desired that they are
available in this namespace (unlikely).
"""

import os, os.path
import sys
import logging
import jpype
from required_defaults import get_required_paths_dict as _get_required_paths_dict
from required_defaults import optimica_compiler_included as _optimica_compiler_included

_jm_home = os.environ['JMODELICA_HOME']
#exception here if jm_home not found
environ = {}
environ['JMODELICA_HOME'] = _jm_home

# Compiler jar-files
MC_JAR = os.path.join(_jm_home,'lib','ModelicaCompiler.jar')     #Path to ModelicaCompiler jar file
OC_JAR = os.path.join(_jm_home,'lib','OptimicaCompiler.jar')     #Path to OptimicaCompiler jar file
UTIL_JAR = os.path.join(_jm_home,'lib','util.jar')               #Path to org.jmodelica.Util jar file
COMPILER_JARS = MC_JAR + os.pathsep + UTIL_JAR
if _optimica_compiler_included():
    COMPILER_JARS = COMPILER_JARS + os.pathsep + OC_JAR

# Compiler classes
_modelica_class = 'org.jmodelica.modelica.compiler.ModelicaCompiler'
_optimica_class = None
if _optimica_compiler_included():
    _optimica_class = 'org.jmodelica.optimica.compiler.OptimicaCompiler'

# Compiler constructors
def _create_compiler(comp, options):
    return comp(options)

_reqired_path = _get_required_paths_dict()
_no_inst_msg = ' installation could not be found, some modules and examples will therefore not work properly.'
# Format of _expected_env item: (name, should_split, default, error_msg_if_not_set)  
_expected_env = [('IPOPT_HOME',    False, '', 'An IPOPT' + _no_inst_msg),
                 ('SUNDIALS_HOME', False, '', 'A SUNDIALS' + _no_inst_msg),
                 ('COMPILER_JARS', True,  COMPILER_JARS),
                 ('BEAVER_PATH',   False, os.path.join(_jm_home,'ThirdParty','Beaver','lib')),
                 ('MODELICAPATH',  True,  os.path.join(_jm_home,'ThirdParty','MSL')),
                 ('JPYPE_JVM',     False, jpype.getDefaultJVMPath() or ''),
                 ('JVM_ARGS',      False, '-Xmx700m')]

if sys.platform == 'win32':
    _expected_env.append(('MINGW_HOME', False, os.path.join(os.path.dirname(_jm_home), 'MinGW')))

# read values for system environment if possible, otherwise set default
for _e in _expected_env:
    try:
        environ[_e[0]] = os.environ[_e[0]]
    except KeyError:
        environ[_e[0]] = _e[2]
  
if sys.platform == 'win32':
    # add mingw to path (win32)
    os.environ['PATH'] = os.path.join(environ['MINGW_HOME'],'bin') + \
                         ';' + os.environ['PATH']

# read user startup script
if sys.platform == 'win32':
    _p = os.environ['USERPROFILE']
else:
    _p = os.environ['HOME']
    
try:
    execfile(os.path.join(_p,'.jmodelica.org','user_startup.py'))
except IOError:
    None

# check paths
_separator = ';' if sys.platform == 'win32' else ':'
for _e in _expected_env:
    if _reqired_path[_e[0]]:
        _value = environ[_e[0]]
        _msg = _e[3] if len(_e) > 3 else 'Environment may be corrupt.'
        if _e[1]:
            _paths = _value.split(_separator)
            for p in _paths:
                if not os.path.exists(p):
                    logging.warning('%s: Path "%s" does not exist. %s' % (_e[0], p, _msg))
        elif not os.path.exists(environ[_e[0]]):
            logging.warning('%s="%s": Path does not exist. %s' % (_e[0], environ[_e[0]], _msg))

def check_packages():
    import sys, time
    import pymodelica, pyjmi
    
    le=30
    le_short=15
    startstr = "Performing pymodelica/pyjmi package check"
    sys.stdout.write("\n")
    sys.stdout.write(startstr+" \n")
    sys.stdout.write("="*len(startstr))
    sys.stdout.write("\n\n")
    sys.stdout.flush()
    time.sleep(0.25)

    # check os
    platform = sys.platform
    sys.stdout.write(
        "%s %s" %("Platform".ljust(le,'.'),(str(platform)).ljust(le)+"\n\n"))
    sys.stdout.flush()
    time.sleep(0.25)
    
    #check python version
    pyversion = sys.version.partition(" ")[0]
    sys.stdout.write(
        "%s %s" % ("Python version:".ljust(le,'.'),pyversion.ljust(le)))
    sys.stdout.write("\n\n")
    sys.stdout.flush()
    time.sleep(0.25)
    
    #check pyjmi version
    pyjmiversion = pyjmi.__version__
    sys.stdout.write(
        "%s %s" % ("pymodelica/pyjmi version:".ljust(le,'.'),pyjmiversion.ljust(le)))
    sys.stdout.write("\n")
    sys.stdout.flush()
    time.sleep(0.25)
    
    import imp
    # Test dependencies
    sys.stdout.write("\n\n")
    sys.stdout.write("Dependencies: \n\n".rjust(0))
    modstr="Package"
    verstr="Version"
    sys.stdout.write("%s %s" % (modstr.ljust(le), verstr.ljust(le)))
    sys.stdout.write("\n")
    sys.stdout.write(
        "%s %s" % (("-"*len(modstr)).ljust(le), ("-"*len(verstr)).ljust(le)))
    sys.stdout.write("\n")

    packages=["assimulo", "casadi", "Cython", "jpype", "lxml", "matplotlib", "nose", "numpy", "scipy", "wxPython"]
    assimulo_path=os.path.join(pyjmi.environ['JMODELICA_HOME'],'Python', 'assimulo')
    
    if platform == "win32":
        packages.append("pyreadline")
        packages.append("setuptools")
    
    error_packages=[]
    warning_packages=[]
    fp = None
    for package in packages:
        try:
            vers="--"
            if package=='assimulo':
                fp, path, desc = imp.find_module('problem', [assimulo_path])
                mod = imp.load_module('problem', fp, path, desc)
            else:    
                fp, path, desc = imp.find_module(package)
                mod = imp.load_module(package, fp, path, desc)
                
            try:
                if package == "pyreadline":
                    vers = mod.release.version
                elif package == "lxml":
                    from lxml import etree
                    vers = etree.__version__
                else:
                    vers = mod.__version__
            except AttributeError as e:
                pass
            sys.stdout.write("%s %s" %(package.ljust(le,'.'), vers.ljust(le)))
        except ImportError as e:
            if package == "nose" or package == "assimulo" or package == "casadi" or package == "wxPython":
                sys.stdout.write("%s %s %s" % (package.ljust(le,'.'), vers.ljust(le_short), "Package missing - Warning issued, see details below".ljust(le_short)))
                warning_packages.append(package)
            else:
                sys.stdout.write("%s %s %s " % (package.ljust(le,'.'), vers.ljust(le_short), "Package missing - Error issued, see details below.".ljust(le_short)))
                error_packages.append(package)
            pass
        finally:
            if fp:
                fp.close()
        sys.stdout.write("\n")
        sys.stdout.flush()
        time.sleep(0.25)

        
    # Write errors and warnings
    # are there any errors?
    if len(error_packages) > 0:
        sys.stdout.write("\n")
        errtitle = "Errors"
        sys.stdout.write("\n")
        sys.stdout.write(errtitle+" \n")
        sys.stdout.write("-"*len(errtitle))
        sys.stdout.write("\n\n")
        sys.stdout.write("The package(s): \n\n")
        
        for er in error_packages:
            sys.stdout.write("   - "+str(er))
            sys.stdout.write("\n")
        sys.stdout.write("\n")
        sys.stdout.write("could not be found. It is not possible to run \
the pymodelica/pyjmi package without it/them.\n")
    
    if len(warning_packages) > 0:
        sys.stdout.write("\n")
        wartitle = "Warnings"
        sys.stdout.write("\n")
        sys.stdout.write(wartitle+" \n")
        sys.stdout.write("-"*len(wartitle))
        sys.stdout.write("\n\n")
        
        for w in warning_packages:
            if w == 'assimulo':
                sys.stdout.write("-- The package assimulo could not be found. \
This package is needed to be able to simulate FMUs. Also, some of the examples \
in pyfmi.examples will not work.")
            elif w == 'wxPython':
                sys.stdout.write("-- The package wxPython could not be found. \
This package is needed to be able to use the plot-GUI.")
            elif w == 'nose':
                sys.stdout.write("-- The package nose could not be found. You will not be able \
to run any tests in the tests_jmodelica package.")
            elif w == 'casadi':
                sys.stdout.write("-- The package casadi could not be found. This package is needed \
to be able to use the casadi_interface module and run some of the examples \
in the pyjmi.examples package")

            sys.stdout.write("\n\n")
