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
The JModelica.org Python package for working with simulation and optimization of
FMUs <http:/www.jmodelica.org/>
"""

__all__ = ['common', 'initialization', 'optimization', 'examples', 'casadi_interface', 'linearization', 'symbolic_elimination', 'logger_util', 'log', 'ukf']

__version__=''

import os
import logging

try:
    _p = os.environ['JMODELICA_HOME']
    if not os.path.exists(_p):
        raise IOError
except (KeyError, IOError):
    raise EnvironmentError('The environment variable JMODELICA_HOME is not set \
or points to a non-existing location.')
    
# set version
f= None
try:
    _fpath=os.path.join(os.environ['JMODELICA_HOME'],'version.txt')
    f = open(_fpath)
    __version__=f.readline().strip()
except IOError:
    logging.warning('Version file not found. Environment may be corrupt.')
finally:
    if f is not None:
        f.close()   

try:
    _f = os.path.join(os.environ['JMODELICA_HOME'],'startup.py')
    execfile(_f)
except IOError:
    logging.warning('Startup script ''%s'' not found. Environment may be corrupt'
                  % _f)


import numpy as N

import pyjmi

int = N.int32
N.int = N.int32

try:
    ipopt_present = pyjmi.environ['IPOPT_HOME']
except:
    ipopt_present = False
    
#Import the model class allowing for users to type: from pyjmi import CasadiModel
try:
    import casadi
    casadi_present = True
except ImportError:
    casadi_present = False
if casadi_present:
    try:
        import modelicacasadi_wrapper
        modelicacasadi_present = True
    except ImportError:
        modelicacasadi_present = False
    if modelicacasadi_present:
        from casadi_interface import (OptimizationProblem,
                                      transfer_to_casadi_interface,
                                      transfer_optimization_problem,
                                      transfer_model,
                                      CasadiModel)

def get_files_path():
    """Get the absolute path to the example files directory."""
    jmhome = os.environ.get('JMODELICA_HOME')
    assert jmhome is not None, "You have to specify" \
                               " JMODELICA_HOME environment" \
                               " variable."
    return os.path.join(jmhome, 'Python', 'pyjmi', 'examples', 'files')
