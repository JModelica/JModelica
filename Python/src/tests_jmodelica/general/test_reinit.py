#!/usr/bin/env python 
# -*- coding: utf-8 -*-

# Copyright (C) 2019 Modelon AB
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

import logging
import nose
import os
import numpy as N
import pylab as P
from scipy.io.matlab.mio import loadmat

from pymodelica.compiler import compile_fmu
from pyfmi.fmi import FMUModel, load_fmu, FMUException, TimeLimitExceeded
from tests_jmodelica import testattr, get_files_path

from tests_jmodelica.general.base_simul import SimulationTest

class Test_Reinit:
    @classmethod
    def setUpClass(cls):
        """
        Compile the test model.
        """
        file_name = os.path.join(get_files_path(), 'Modelica', 'Reinit.mo')

        compile_fmu("Reinit.ReinitWriteback", file_name)
    
    @testattr(stddist_full = True)
    def test_reinit_writeback(self):
        model = load_fmu("Reinit_ReinitWriteback.fmu")
        model.simulate(start_time=0, final_time=21)

class Test_Reinit_Block(SimulationTest):
    @classmethod
    def setUpClass(self):
        file_name = os.path.join(get_files_path(), 'Modelica', 'Reinit.mo')
        self.setup_class_base(file_name, "Reinit.ReinitBlock")
    
    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(final_time=2.0)
        self.run()
    
    @testattr(stddist_full = True)
    def test_reinit_block(self):
        self.assert_end_value("v", -0.546776830847)
