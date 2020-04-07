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
Module containing the tests for the FMI interface.
"""

import nose
import os
import numpy as N
import sys as S

from tests_jmodelica import testattr, get_files_path
from pymodelica.compiler import compile_fmu
from pyfmi.fmi import FMUModel, FMUException, FMUModelME1, FMUModelCS1, FMUModelCS2, FMUModelME2, PyEventInfo
from pyfmi import FMUModelME1Extended
import pyfmi.fmi_algorithm_drivers as ad
from pyfmi.common.core import get_platform_dir
from pyjmi.log import parse_jmi_log, gather_solves
from pyfmi.common.io import ResultHandler

path_to_fmus = os.path.join(get_files_path(), 'FMUs')
path_to_fmus_me1 = os.path.join(path_to_fmus,"ME1.0")
path_to_fmus_cs1 = os.path.join(path_to_fmus,"CS1.0")
path_to_mofiles = os.path.join(get_files_path(), 'Modelica')
path_to_fmu_logs = os.path.join(get_files_path(), 'FMU_logs')

path_to_fmus_me2 = os.path.join(path_to_fmus,"ME2.0")
path_to_fmus_cs2 = os.path.join(path_to_fmus,"CS2.0")
ME2 = 'bouncingBall2_me.fmu'
CS2 = 'bouncingBall2_cs.fmu'
ME1 = 'bouncingBall.fmu'
CS1 = 'bouncingBall.fmu'
CoupledME2 = 'Modelica_Mechanics_Rotational_Examples_CoupledClutches_ME2.fmu'
CoupledCS2 = 'Modelica_Mechanics_Rotational_Examples_CoupledClutches_CS2.fmu'




class Test_FMUModelME1Extended:
    """
    This class tests pyfmi.fmi.FMUModelME1Extended
    """

    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        cls.rlc_circuit = compile_fmu("RLC_Circuit",os.path.join(path_to_mofiles,"RLC_Circuit.mo"), version="1.0")
        cls.rlc_circuit_square = compile_fmu("RLC_Circuit_Square",os.path.join(path_to_mofiles,"RLC_Circuit.mo"), version="1.0")
        cls.no_state3 = compile_fmu("NoState.Example3",os.path.join(path_to_mofiles,"noState.mo"), version="1.0")
        cls.simple_input = compile_fmu("Inputs.SimpleInput",os.path.join(path_to_mofiles,"InputTests.mo"), version="1.0")
        cls.simple_input2 = compile_fmu("Inputs.SimpleInput2",os.path.join(path_to_mofiles,"InputTests.mo"), version="1.0")
        cls.input_discontinuity = compile_fmu("Inputs.InputDiscontinuity",os.path.join(path_to_mofiles,"InputTests.mo"), version="1.0")

    @testattr(stddist_full = True)
    def test_custom_result_handler(self):
        model = FMUModelME1Extended(Test_FMUModelME1Extended.rlc_circuit)

        class A:
            pass
        class B(ResultHandler):
            def get_result(self):
                return None

        opts = model.simulate_options()
        opts["result_handling"] = "hejhej"
        nose.tools.assert_raises(Exception, model.simulate, options=opts)
        opts["result_handling"] = "custom"
        nose.tools.assert_raises(Exception, model.simulate, options=opts)
        opts["result_handler"] = A()
        nose.tools.assert_raises(Exception, model.simulate, options=opts)
        opts["result_handler"] = B()
        res = model.simulate(options=opts)

    @testattr(stddist_full = True)
    def test_filter(self):
        model = FMUModelME1Extended(Test_FMUModelME1Extended.rlc_circuit)

        opts = model.simulate_options()
        opts["filter"] = "resistor.*"
        res = model.simulate(final_time=0.1)
        nose.tools.assert_raises(Exception, res.result_data.get_variable_data("capacitor.v"))
        data = res["resistor.v"]

        model.reset()
        opts = model.simulate_options()
        opts["filter"] = "resistor.*"
        opts["result_handling"] = "memory"
        res = model.simulate(final_time=0.1)
        nose.tools.assert_raises(Exception, res.result_data.get_variable_data("capacitor.v"))
        data = res["resistor.v"]

        model.reset()
        opts = model.simulate_options()
        opts["filter"] = ["resistor.*", "capacitor.v"]
        res = model.simulate(final_time=0.1)
        data = res["capacitor.v"]
        data = res["resistor.v"]


    @testattr(stddist_full = True)
    def test_simulation_no_state(self):
        model = FMUModelME1Extended(Test_FMUModelME1Extended.no_state3)

        res = model.simulate(final_time=1.0)
        nose.tools.assert_almost_equal(res.final("x"),1.0)

    @testattr(stddist_full = True)
    def test_input_derivatives(self):
        model = FMUModelME1Extended(Test_FMUModelME1Extended.simple_input)

        model.initialize()

        model.set("u", 0.0)
        model.set_input_derivatives("u",2.0, 1)

        model.do_step(0, 1)
        nose.tools.assert_almost_equal(model.get("u"),2.0)

        model.do_step(1, 1)
        nose.tools.assert_almost_equal(model.get("u"),2.0)

        model.set_input_derivatives("u",2.0, 1)
        model.do_step(2, 1)
        nose.tools.assert_almost_equal(model.get("u"),4.0)

    @testattr(stddist_full = True)
    def test_input_derivatives2(self):
        model = FMUModelME1Extended(Test_FMUModelME1Extended.simple_input2)

        model.initialize()

        model.set_input_derivatives("u1",2.0, 1)
        model.do_step(0, 1)
        nose.tools.assert_almost_equal(model.get("u1"),2.0)
        nose.tools.assert_almost_equal(model.get("u2"),0.0)

        model.set_input_derivatives("u2",2.0, 1)
        model.do_step(1,1)
        nose.tools.assert_almost_equal(model.get("u2"),2.0)
        nose.tools.assert_almost_equal(model.get("u1"),2.0)

        model.set_input_derivatives(["u1","u2"], [1.0,1.0],[1,1])
        model.do_step(2,1)
        nose.tools.assert_almost_equal(model.get("u2"),3.0)
        nose.tools.assert_almost_equal(model.get("u1"),3.0)

    @testattr(stddist_full = True)
    def test_input_derivatives3(self):
        model = FMUModelME1Extended(Test_FMUModelME1Extended.simple_input)

        model.initialize()
        model.set_input_derivatives("u",1.0, 1)
        model.set_input_derivatives("u",-1.0, 2)
        model.do_step(0, 1)
        nose.tools.assert_almost_equal(model.get("u"),0.5)

        model.do_step(1, 1)
        nose.tools.assert_almost_equal(model.get("u"),0.5)

    @testattr(stddist_full = True)
    def test_input_derivatives4(self):
        model = FMUModelME1Extended(Test_FMUModelME1Extended.simple_input)

        model.initialize()
        model.set_input_derivatives("u",1.0, 1)
        model.set_input_derivatives("u",-1.0, 2)
        model.set_input_derivatives("u",6.0, 3)
        model.do_step(0, 2)
        nose.tools.assert_almost_equal(model.get("u"),8.0)

        model.do_step(1, 1)
        nose.tools.assert_almost_equal(model.get("u"),8.0)


    @testattr(stddist_full = True)
    def test_zero_step_size(self):
        model = FMUModelME1Extended(Test_FMUModelME1Extended.input_discontinuity)

        model.initialize()
        model.do_step(0, 1)
        model.set("u", 1.0)
        nose.tools.assert_almost_equal(model.get("x"),0.0)
        model.do_step(1,0)
        nose.tools.assert_almost_equal(model.get("x"),1.0)

    @testattr(stddist_full = True)
    def test_version(self):
        rlc  = FMUModelME1Extended(Test_FMUModelME1Extended.rlc_circuit)
        assert rlc._get_version() == '1.0'

    @testattr(stddist_full = True)
    def test_valid_platforms(self):
        rlc  = FMUModelME1Extended(Test_FMUModelME1Extended.rlc_circuit)
        assert rlc._get_types_platform() == 'standard32'

    @testattr(stddist_full = True)
    def test_simulation_with_reset_cs_2(self):
        rlc  = FMUModelME1Extended(Test_FMUModelME1Extended.rlc_circuit)
        res1 = rlc.simulate(final_time=30)
        resistor_v = res1['resistor.v']
        assert N.abs(resistor_v[-1] - 0.159255008028) < 1e-3
        rlc.reset()
        res2 = rlc.simulate(final_time=30)
        resistor_v = res2['resistor.v']
        assert N.abs(resistor_v[-1] - 0.159255008028) < 1e-3

    @testattr(stddist_full = True)
    def test_simulation_with_reset_cs_3(self):
        rlc_square  = FMUModelME1Extended(Test_FMUModelME1Extended.rlc_circuit_square)
        res1 = rlc_square.simulate()
        resistor_v = res1['resistor.v']
        print resistor_v[-1]
        assert N.abs(resistor_v[-1] + 0.233534539103) < 1e-3
        rlc_square.reset()
        res2 = rlc_square.simulate()
        resistor_v = res2['resistor.v']
        assert N.abs(resistor_v[-1] + 0.233534539103) < 1e-3

    @testattr(windows_full = True)
    def test_simulation_cs(self):

        model = FMUModelME1Extended("Modelica_Mechanics_Rotational_Examples_CoupledClutches_ME.fmu",path_to_fmus_me1)
        res = model.simulate(final_time=1.5)
        assert (res.final("J1.w") - 3.245091100366517) < 1e-4

    @testattr(windows_full = True)
    def test_simulation_with_reset_cs(self):

        model = FMUModelME1Extended("Modelica_Mechanics_Rotational_Examples_CoupledClutches_ME.fmu",path_to_fmus_me1)
        res1 = model.simulate(final_time=1.5)
        assert (res1["J1.w"][-1] - 3.245091100366517) < 1e-4
        model.reset()
        res2 = model.simulate(final_time=1.5)
        assert (res2["J1.w"][-1] - 3.245091100366517) < 1e-4

    @testattr(windows_full = True)
    def test_default_experiment(self):
        model = FMUModelME1Extended("Modelica_Mechanics_Rotational_Examples_CoupledClutches_ME.fmu",path_to_fmus_me1)

        assert N.abs(model.get_default_experiment_start_time()) < 1e-4
        assert N.abs(model.get_default_experiment_stop_time()-1.5) < 1e-4
        assert N.abs(model.get_default_experiment_tolerance()-0.0001) < 1e-4

    @testattr(windows_full = True)
    def test_types_platform(self):
        model = FMUModelME1Extended("Modelica_Mechanics_Rotational_Examples_CoupledClutches_ME.fmu",path_to_fmus_me1)
        assert model.types_platform == "standard32"

    @testattr(windows_full = True)
    def test_exception_input_derivatives(self):
        model = FMUModelME1Extended("Modelica_Mechanics_Rotational_Examples_CoupledClutches_ME.fmu",path_to_fmus_me1)
        nose.tools.assert_raises(FMUException, model.set_input_derivatives, "u",1.0,1)

    @testattr(windows_full = True)
    def test_exception_output_derivatives(self):
        model = FMUModelME1Extended("Modelica_Mechanics_Rotational_Examples_CoupledClutches_ME.fmu",path_to_fmus_me1)
        nose.tools.assert_raises(FMUException, model.get_output_derivatives, "u",1)

    @testattr(windows_full = True)
    def test_default_simulation_stop_time(self):
        model = FMUModelME1Extended("Modelica_Mechanics_Rotational_Examples_CoupledClutches_ME.fmu",path_to_fmus_me1)
        res = model.simulate()
        assert N.abs(1.5 - res.final('time')) < 1e-4

    @testattr(stddist_full = True)
    def test_multiple_loadings_and_simulations(self):
        model = FMUModelME1Extended("bouncingBall.fmu",path_to_fmus_me1,enable_logging=False)
        res = model.simulate(final_time=1.0)
        h_res = res.final('h')

        for i in range(40):
            model = FMUModelME1Extended("bouncingBall.fmu",path_to_fmus_me1,enable_logging=False)
            res = model.simulate(final_time=1.0)
        assert N.abs(h_res - res.final('h')) < 1e-4

    @testattr(stddist_full = True)
    def test_log_file_name(self):
        model = FMUModelME1Extended("bouncingBall.fmu",path_to_fmus_me1)
        assert os.path.exists("bouncingBall_log.txt")
        model = FMUModelME1Extended("bouncingBall.fmu",path_to_fmus_me1,log_file_name="Test_log.txt")
        assert os.path.exists("Test_log.txt")

    @testattr(stddist_full = True)
    def test_result_name_file(self):

        rlc = FMUModelME1Extended(Test_FMUModelME1Extended.rlc_circuit)
        res = rlc.simulate(options={"result_handling":"file"})

        #Default name
        assert res.result_file == "RLC_Circuit_result.txt"
        assert os.path.exists(res.result_file)

        rlc = FMUModelME1Extended("RLC_Circuit.fmu")
        res = rlc.simulate(options={"result_file_name":
                                    "RLC_Circuit_result_test.txt"})

        #User defined name
        assert res.result_file == "RLC_Circuit_result_test.txt"
        assert os.path.exists(res.result_file)
