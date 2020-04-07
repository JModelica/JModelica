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

""" Test module for testing the io module
"""

import os
import os.path

import numpy as N
import nose

from tests_jmodelica import testattr, get_files_path
from pymodelica.compiler import compile_fmu
from pyfmi.common.io import ResultDymolaTextual, ResultDymolaBinary, ResultWriterDymola, JIOError, ResultHandlerCSV, ResultCSVTextual, ResultHandlerBinaryFile
from pyjmi.common.io import VariableNotTimeVarying
from pyfmi.common.io import ResultHandlerFile as fmi_ResultHandlerFile
from pyjmi.optimization import ipopt
from pyfmi.fmi import FMUModel, load_fmu

path_to_fmus = os.path.join(get_files_path(), 'FMUs')
path_to_fmus_me1 = os.path.join(path_to_fmus,"ME1.0")
path_to_fmus_cs1 = os.path.join(path_to_fmus,"CS1.0")
path_to_results = os.path.join(get_files_path(), 'Results')

class test_ResultWriterDymola:
    """Tests the class ResultWriterDymola."""
    
    def setUp(self):
        """
        Sets up the test case.
        """
        self._bounce  = FMUModel('bouncingBall.fmu',path_to_fmus_me1)
        self._dq = FMUModel('dq.fmu',path_to_fmus_me1)
        self._bounce.initialize()
        self._dq.initialize()
        
    @testattr(stddist_full = True)
    def test_work_flow(self):
        """Tests the work flow of write_header, write_point, write_finalize."""
        
        
        bouncingBall = fmi_ResultHandlerFile(self._bounce)
        
        bouncingBall.set_options(self._bounce.simulate_options())
        bouncingBall.simulation_start()
        bouncingBall.initialize_complete()
        bouncingBall.integration_point()
        bouncingBall.simulation_end()
        
        res = ResultDymolaTextual('bouncingBall_result.txt')
        
        h = res.get_variable_data('h')
        derh = res.get_variable_data('der(h)')
        g = res.get_variable_data('g')

        nose.tools.assert_almost_equal(h.x, 1.000000, 5)
        nose.tools.assert_almost_equal(derh.x, 0.000000, 5)
#        nose.tools.assert_almost_equal(g.x, 9.810000, 5)

    @testattr(windows_full = True)
    def test_variable_alias(self):
        """ 
        Tests the variable with parameter alias is presented as variable in the 
        result.
        """
        simple_alias = load_fmu('SimpleAlias.fmu',path_to_fmus_me1)
        res = simple_alias.simulate()
        
        # test that res['y'] returns a vector of the same length as the time
        # vector
        nose.tools.assert_equal(len(res['y']),len(res['time']), 
            "Wrong size of result vector.")
            
        # test that y really is saved in result as a parameter
        res_traj = res.result_data.get_variable_data('y')
        nose.tools.assert_equal(len(res_traj.x), 2, 
            "Wrong size of y returned by result_data.get_variable_data")

class TestResultMemory:
    @classmethod
    def setUpClass(cls):
        model_file = os.path.join(get_files_path(), 'Modelica', 'NegatedAlias.mo')
        name = compile_fmu("NegatedAlias", model_file)
        model_file = os.path.join(get_files_path(), 'Modelica', 'ParameterAlias.mo')
        name = compile_fmu("ParameterAlias", model_file)
        
    @testattr(stddist_base = True)
    def test_only_parameters(self):
        model = load_fmu("ParameterAlias.fmu")
        
        opts = model.simulate_options()
        opts["result_handling"] = "memory"
        opts["filter"] = "p2"
        
        res = model.simulate(options=opts)
        
        nose.tools.assert_almost_equal(model.get("p2"), res["p2"][0])
        assert not isinstance(res.initial("p2"), N.ndarray)
        assert not isinstance(res.final("p2"), N.ndarray)

class TestResultCSVTextual:
    
    @classmethod
    def setUpClass(cls):
        model_file = os.path.join(get_files_path(), 'Modelica', 'NegatedAlias.mo')
        name = compile_fmu("NegatedAlias", model_file)
        name = compile_fmu("NegatedAlias", model_file, target="cs", compile_to="NegatedAliasCS.fmu")
        model_file = os.path.join(get_files_path(), 'Modelica', 'ParameterAlias.mo')
        name = compile_fmu("ParameterAlias", model_file)
    
    @testattr(stddist_full = True)
    def test_only_parameters(self):
        model = load_fmu("ParameterAlias.fmu")
        
        opts = model.simulate_options()
        opts["result_handling"] = "custom"
        opts["result_handler"] = ResultHandlerCSV(model)
        opts["filter"] = "p2"
        
        res = model.simulate(options=opts)
        
        nose.tools.assert_almost_equal(model.get("p2"), res["p2"][0])
    
    @testattr(stddist_full = True)
    def test_variable_alias(self):

        simple_alias = load_fmu("NegatedAlias.fmu")
        
        opts = simple_alias.simulate_options()
        opts["result_handling"] = "custom"
        opts["result_handler"] = ResultHandlerCSV(simple_alias)
        
        res = simple_alias.simulate(options=opts)
        
        # test that res['y'] returns a vector of the same length as the time
        # vector
        nose.tools.assert_equal(len(res['y']),len(res['time']), 
            "Wrong size of result vector.")
            
        x = res["x"]
        y = res["y"]
        
        for i in range(len(x)):
            nose.tools.assert_equal(x[i], -y[i])
            
    @testattr(stddist_full = True)
    def test_delimiter(self):
        
        res = ResultCSVTextual(os.path.join(get_files_path(), 'Results', 'TestCSV.csv'), delimiter=",")
        
        x = res.get_variable_data("fd.y")
        
        assert x.x[-1] == 1
    
    @testattr(stddist_full = True)
    def test_csv_options_me(self):
        
        simple_alias = load_fmu("NegatedAlias.fmu")
        
        opts = simple_alias.simulate_options()
        opts["result_handling"] = "csv"
        
        res = simple_alias.simulate(options=opts)
        
        # test that res['y'] returns a vector of the same length as the time
        # vector
        nose.tools.assert_equal(len(res['y']),len(res['time']), 
            "Wrong size of result vector.")
            
        x = res["x"]
        y = res["y"]
        
        for i in range(len(x)):
            nose.tools.assert_equal(x[i], -y[i])
            
    @testattr(stddist_full = True)
    def test_csv_options_cs(self):
        
        simple_alias = load_fmu("NegatedAliasCS.fmu")
        
        opts = simple_alias.simulate_options()
        opts["result_handling"] = "csv"
        
        res = simple_alias.simulate(options=opts)
        
        # test that res['y'] returns a vector of the same length as the time
        # vector
        nose.tools.assert_equal(len(res['y']),len(res['time']), 
            "Wrong size of result vector.")
            
        x = res["x"]
        y = res["y"]
        
        for i in range(len(x)):
            nose.tools.assert_equal(x[i], -y[i])
    


class TestResultFileBinary:
    
    @classmethod
    def setUpClass(cls):
        model_file = os.path.join(get_files_path(), 'Modelica', 'NegatedAlias.mo')
        name = compile_fmu("NegatedAlias", model_file)
        name = compile_fmu("NegatedAlias", model_file, target="cs", compile_to="NegatedAliasCS.fmu")
        name = compile_fmu("NegatedAlias", model_file, version=2.0, target="cs", compile_to="NegatedAliasCS2.fmu")
        model_file = os.path.join(get_files_path(), 'Modelica', 'ParameterAlias.mo')
        name = compile_fmu("ParameterAlias", model_file)
    
    @testattr(stddist_base = True)
    def test_read_all_variables(self):
        res = ResultDymolaBinary(os.path.join(get_files_path(), "Results", "DoublePendulum.mat"))
        
        for var in res.name:
            res.get_variable_data(var)
    
    @testattr(stddist_base = True)
    def test_only_parameters(self):
        model = load_fmu("ParameterAlias.fmu")
        
        opts = model.simulate_options()
        opts["result_handling"] = "custom"
        opts["result_handler"] = ResultHandlerBinaryFile(model)
        opts["filter"] = "p2"
        
        res = model.simulate(options=opts)
        
        nose.tools.assert_almost_equal(model.get("p2"), res["p2"][0])
        
    @testattr(stddist_base = True)
    def test_integer_start_time(self):
        model = load_fmu("NegatedAliasCS2.fmu")
        
        #Assert that there is no exception when reloading the file
        res = model.simulate(start_time=0)
    
    @testattr(stddist_base = True)
    def test_variable_alias(self):

        simple_alias = load_fmu("NegatedAlias.fmu")
        
        opts = simple_alias.simulate_options()
        opts["result_handling"] = "custom"
        opts["result_handler"] = ResultHandlerBinaryFile(simple_alias)
        
        res = simple_alias.simulate(options=opts)
        
        # test that res['y'] returns a vector of the same length as the time
        # vector
        nose.tools.assert_equal(len(res['y']),len(res['time']), 
            "Wrong size of result vector.")
            
        x = res["x"]
        y = res["y"]
        
        for i in range(len(x)):
            nose.tools.assert_equal(x[i], -y[i])
            
    @testattr(stddist_base = True)
    def test_binary_options_me(self):
        
        simple_alias = load_fmu("NegatedAlias.fmu")
        
        opts = simple_alias.simulate_options()
        opts["result_handling"] = "binary"
        
        res = simple_alias.simulate(options=opts)
        
        # test that res['y'] returns a vector of the same length as the time
        # vector
        nose.tools.assert_equal(len(res['y']),len(res['time']), 
            "Wrong size of result vector.")
            
        x = res["x"]
        y = res["y"]
        
        for i in range(len(x)):
            nose.tools.assert_equal(x[i], -y[i])
            
    @testattr(stddist_base = True)
    def test_binary_options_cs(self):
        
        simple_alias = load_fmu("NegatedAliasCS.fmu")
        
        opts = simple_alias.simulate_options()
        opts["result_handling"] = "binary"
        
        res = simple_alias.simulate(options=opts)
        
        # test that res['y'] returns a vector of the same length as the time
        # vector
        nose.tools.assert_equal(len(res['y']),len(res['time']), 
            "Wrong size of result vector.")
            
        x = res["x"]
        y = res["y"]
        
        for i in range(len(x)):
            nose.tools.assert_equal(x[i], -y[i])
    
