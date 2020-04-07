#!/usr/bin/env python 
# -*- coding: utf-8 -*-

# Copyright (C) 2018 Modelon AB
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

import os, subprocess, shutil
from os.path import join as path

import nose

from pymodelica import compile_fmu
from pymodelica.common.core import get_platform_dir, create_temp_dir
from pyfmi import load_fmu
from pyfmi.fmi import FMUException
from tests_jmodelica import testattr, get_files_path
from tests_jmodelica.general.base_simul import *
from assimulo.solvers.sundials import CVodeError

path_to_mofiles = os.path.join(get_files_path(), 'Modelica')

class TestParameterEvalDependentStart:
    
    @classmethod
    def setUpClass(cls):
        cls.fpath = path(path_to_mofiles, "ParameterEvalTests.mo")
        
    @testattr(stddist_full = True)
    def test_ParameterEval1(self):
        cpath = 'ParameterEvalTests.ParameterEval1'
        fmu_name = compile_fmu(cpath, TestParameterEvalDependentStart.fpath)
        model = load_fmu(fmu_name)
        model.set('p', 2)
        assert model.get('pd') == 3
        model.set('p', 3)
        assert model.get('pd') == 4
        assert model.get('x') == 4
        model.set('p', 4)
        assert model.get('pd') == 5
        assert model.get('x') == 5
