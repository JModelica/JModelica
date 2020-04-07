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
Module for testing tables support.
"""
import os

import nose
from nose.tools import nottest

from pymodelica import compile_fmu
from pyfmi import load_fmu
from tests_jmodelica import testattr, get_files_path
from tests_jmodelica.general.base_simul import SimulationTest

path_to_mofiles = os.path.join(get_files_path(), 'Modelica')
path_to_results = os.path.join(get_files_path(), 'Results')

class TestCombiTable1DArray(SimulationTest):
    """
    Test simulation of a model with a 1D table array.
    """
    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
                'TablesTests.mo', 'TablesTest.Table1DfromArray')

    @testattr(stddist_base = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=1.0, time_step = 0.01)
        self.run()
        self.load_expected_data('Table1DfromArray_result.txt')

    @testattr(stddist_base = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['modelicaTable1D.y[1]', 'modelicaTable1D.u[1]'])

class TestCombiTable2DArray(SimulationTest):
    """
    Test simulation of a model with a 2D table array.
    """
    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
                'TablesTests.mo', 'TablesTest.Table2DfromArray')

    @testattr(stddist_base = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=1.0, time_step = 0.01)
        self.run()
        self.load_expected_data('Table2DfromArray_result.txt')
    
    @testattr(stddist_base = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['modelicaTable2D.y', 'modelicaTable2D.u1', 'modelicaTable2D.u2'])
       
class TestCombiTable1DFile(SimulationTest):
    """
    Test simulation of a model with a 1D table on file.
    """
    @classmethod
    def setUpClass(cls):
        cls.curr_dir = os.path.dirname(os.path.abspath(__file__))
        os.chdir(path_to_mofiles)
        SimulationTest.setup_class_base(
                'TablesTests.mo', 'TablesTest.Table1DfromFile')
    @classmethod
    def tearDownClass(cls):
        os.chdir(TestCombiTable1DFile.curr_dir)

    @testattr(stddist_base = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=1.0, time_step = 0.01)
        self.run()
        self.load_expected_data('Table1DfromFile_result.txt')

    @testattr(stddist_base = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['modelicaTable1D.y[1]', 'modelicaTable1D.u[1]'])
      
class TestCombiTable2DFile(SimulationTest):
    """
    Test simulation of a model with a 2D table on file.
    """
    @classmethod
    def setUpClass(cls):
        cls.curr_dir = os.path.dirname(os.path.abspath(__file__))
        os.chdir(path_to_mofiles)
        SimulationTest.setup_class_base(
                'TablesTests.mo', 'TablesTest.Table2DfromFile')
                
    @classmethod
    def tearDownClass(cls):
        os.chdir(TestCombiTable2DFile.curr_dir)

    @testattr(stddist_base = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=1.0, time_step = 0.01)
        self.run()
        self.load_expected_data('Table2DfromFile_result.txt')

    @testattr(stddist_base = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['modelicaTable2D.y', 'modelicaTable2D.u1', 'modelicaTable2D.u2'])
