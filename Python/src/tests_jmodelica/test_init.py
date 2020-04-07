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
Test module for functions directly in jmodelica Python packages.
"""

import os

import numpy as N
import nose
import nose.tools
import logging

from pymodelica.compiler import compile_fmu
from pyfmi import load_fmu
from tests_jmodelica import testattr, get_files_path
from pyjmi.common.algorithm_drivers import InvalidAlgorithmOptionException
from pyjmi.common.algorithm_drivers import InvalidSolverArgumentException
from pyjmi.common.algorithm_drivers import UnrecognizedOptionError

try:
    from assimulo.explicit_ode import *
except ImportError:
    logging.warning('Could not load Assimulo module. Check pyjmi.check_packages()')

try:
    ipopt_present = pyjmi.environ['IPOPT_HOME']
except:
    ipopt_present = False

int = N.int32
N.int = N.int32
    
class Test_init_std:
    """ Class which contains std tests for the init module. """
    
    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        pass
        
    def setUp(self):
        """
        Sets up the test case.
        """
        pass
    
    #@testattr(stddist_full = True)
    #def test_exception_raised(self):
        #""" Test compact functions without passing mofile raises exception."""
        #cpath = "Pendulum_pack.Pendulum"   
        #nose.tools.assert_raises(Exception, jmodelica.simulate, cpath)
        #nose.tools.assert_raises(Exception, jmodelica.optimize, cpath)
        
    @testattr(stddist_full = True)
    def test_inlined_switches(self):
        """ Test a model that need in-lined switches to initialize. """
        path = os.path.join(get_files_path(), 'Modelica', 'event_init.mo')
        fmu_name = compile_fmu('Init', path)
        model = load_fmu(fmu_name)
        model.initialize()
        assert N.abs(model.get("x") - (-2.15298995))              < 1e-3
        