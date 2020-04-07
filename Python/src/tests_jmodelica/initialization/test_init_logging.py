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

""" Tests some log messages from the initialization solver. """

import os.path

import numpy as N
from nose.tools import assert_raises

from pyfmi import load_fmu
from pymodelica import compile_fmu
from pyfmi.fmi import FMUException
from tests_jmodelica import testattr, get_files_path
from pyjmi.log import parse_jmi_log

fpath = os.path.join(get_files_path(), 'Modelica', 'TestInitLogging.mo')
log_file_name = os.path.join(get_files_path(), 'Data', 'test_init_logging_log.txt')
    
def load_model(classname, log_file_name):
    log_level = 4
    options = {'generate_only_initial_system': True}
    options['log_level'] = log_level
    options['enforce_bounds'] = False

    name = compile_fmu(classname, fpath, compiler_options=options)

    model = load_fmu(name, log_file_name=log_file_name)
    model.set_debug_logging(True)
    model.set_log_level(log_level)
    model.set('_log_level', log_level)
    return model

@testattr(stddist_full = True)
def test_bounds_warnings():
    model = load_model('TestInit', log_file_name)

    model.initialize()
    assert abs(model.get('x')-2) < 1e-6
    log = parse_jmi_log(log_file_name)
    assert len(log.find("StartOutOfBounds")) == 0

    for xstart in [-20,20]:
        model = load_model('TestInit', log_file_name)        
#        model.reset() # todo: clear the old log file so that we can use reset instead of reloading the fmu
        model.set('x_start', xstart)
        model.initialize()
        assert abs(model.get('x')-2) < 1e-6
        log = parse_jmi_log(log_file_name)
        warns = log.find("StartOutOfBounds")
        assert len(warns) == 1
        warn = warns[0]
        assert warn.min == -10
        assert warn.max ==  10
        assert warn.iv  == "x"
        assert warn.start == xstart
        assert warn.clamped_start == min(10, max(-10, xstart))
