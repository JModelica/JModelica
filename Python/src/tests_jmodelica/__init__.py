#!/usr/bin/env python 
# -*- coding: utf-8 -*-

# Copyright (C) 2010 Modelon AB
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

"""
JModelica test package.

This __init__.py file holds functions used to load
"""

import os
import sys
import os, os.path
import shutil
import platform

__all__ = ['general', 'initialization', 'optimization', 'simulation', 
           'test_compiler', 'test_core', 'test_examples_casadi',
           'test_examples_casadi_2', 'test_examples_fmi',
           'test_examples_jmi', 'test_fmi', 'test_fmi_jacobians', 'test_init',
           'test_io', 'test_jmi', 'test_linearization', 'test_xmlparser',
           'test_fmi_2', 'test_delay', 'test_symbolic_elimination',
           'test_discrete_inputs']

#create working directory for tests
if sys.platform == 'win32':
    _p = os.path.join(os.environ['JMODELICA_HOME'],'tests')
else:
    _p = os.path.join(os.environ['HOME'],'jmodelica.org','tests')

   
if os.path.exists(_p):
    shutil.rmtree(_p)
 
try:
    os.mkdir(_p)
except Exception:
        _p = ""
if _p:
    os.chdir(_p)


def testattr(**kwargs):
    """Add attributes to a test function/method/class.
    
    This function is needed to be able to add
      @attr(slow = True)
    for functions.
    
    """
    def wrap(func):
        func.__dict__.update(kwargs)
        return func
    return wrap


def get_files_path():
    """Get the absolute path to the test files directory."""
    
    jmhome = os.environ.get('JMODELICA_HOME')
    assert jmhome is not None, "You have to specify" \
                               " JMODELICA_HOME environment" \
                               " variable."
    pycompiler = platform.python_compiler()
    if "64 bit" in pycompiler and "win" in sys.platform:
        return os.path.join(jmhome, 'Python_64', 'tests_jmodelica', 'files')
    else:
        return os.path.join(jmhome, 'Python', 'tests_jmodelica', 'files')
