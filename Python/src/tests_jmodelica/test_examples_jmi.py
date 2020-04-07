#!/usr/bin/env python 
# -*- coding: utf-8 -*-

#    Copyright (C) 2012 Modelon AB
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, version 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
""" Test module for testing the examples.
 
"""

from tests_jmodelica import testattr
from pyjmi.examples import (blood_glucose,
                            crystallizer,
                            parameter_estimation_1,
                            qt_par_est,
                            bounds_kinsol,
                            furuta_dfo_using_algorithm_drivers)

@testattr(stddist_base = True)
def test_blood_glucose():
    """ Test the blood_glucose example. """    
    blood_glucose.run_demo(False)

@testattr(ipopt = True)
def test_crystallizer():
    """ Test the crystallizer example. """
    crystallizer.run_demo(False)

@testattr(ipopt = True)
def test_parameter_estimation_1():
    """ Test the parameter_estimation_1 example """
    parameter_estimation_1.run_demo(False) 

@testattr(ipopt = True)
def test_qt_par_est():
    """ Run parameter estimation example """
    qt_par_est.run_demo(False)

@testattr(stddist_base = True)
def bounds_kinsol_example():
    """ Test the bounds_kinsol example."""
    bounds_kinsol.run_demo(False)

@testattr(stddist_base = True)
def furuta_dfo_using_algorithm_drivers_example():
    """ Test the Furuta DFO example."""
    furuta_dfo_using_algorithm_drivers.run_demo(False)

