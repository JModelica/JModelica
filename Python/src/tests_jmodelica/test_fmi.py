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
from pyfmi.fmi import FMUModel, FMUException, FMUModelME1, FMUModelCS1, load_fmu, FMUModelCS2, FMUModelME2, PyEventInfo
import pyfmi.fmi_algorithm_drivers as ad
from pyfmi.common.core import get_platform_dir
from pyjmi.log import parse_jmi_log, gather_solves
from pyfmi.common.io import ResultHandler
import pyfmi.fmi as fmi

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

class Test_load_fmu: 
    """
    This test the functionality of load_fmu method.  
    """

    @testattr(stddist_full = True)
    def test_raise_exception(self):

        nose.tools.assert_raises(FMUException, load_fmu, "test.fmu")
        nose.tools.assert_raises(FMUException, FMUModelCS1, "Modelica_Mechanics_Rotational_Examples_CoupledClutches_ME.fmu",path_to_fmus_me1)
        nose.tools.assert_raises(FMUException, FMUModelME1, "Modelica_Mechanics_Rotational_Examples_CoupledClutches_CS.fmu",path_to_fmus_cs1)

    @testattr(windows_full = True)
    def test_correct_loading(self):

        model = load_fmu("Modelica_Mechanics_Rotational_Examples_CoupledClutches_ME.fmu",path_to_fmus_me1)
        assert isinstance(model, FMUModelME1)

        model = load_fmu("Modelica_Mechanics_Rotational_Examples_CoupledClutches_CS.fmu",path_to_fmus_cs1)
        assert isinstance(model, FMUModelCS1)


class Test_FMUModelBase:
    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        cls.negAliasFmu = compile_fmu("NegatedAlias",os.path.join(path_to_mofiles,"NegatedAlias.mo"), version=1.0)
        cls.enumFMU = compile_fmu('Parameter.Enum', os.path.join(path_to_mofiles,'ParameterTests.mo'), version=1.0)

    @testattr(windows_full = True)
    def test_get_erronous_nominals(self):
        
        model = load_fmu("NominalTest4.fmu",path_to_fmus_me1)
        
        nose.tools.assert_almost_equal(model.get_variable_nominal("x"), 2.0)
        nose.tools.assert_almost_equal(model.get_variable_nominal("y"), 1.0)

    @testattr(stddist_full = True)
    def test_version(self):
        negated_alias  = load_fmu(Test_FMUModelBase.negAliasFmu)
        
        assert negated_alias.get_version() == "1.0"

    @testattr(stddist_full = True)
    def test_caching(self):
        negated_alias  = load_fmu(Test_FMUModelBase.negAliasFmu)
        
        assert len(negated_alias.cache) == 0 #No starting cache
        
        vars_1 = negated_alias.get_model_variables()
        vars_2 = negated_alias.get_model_variables()
        assert id(vars_1) == id(vars_2)
        
        vars_3 = negated_alias.get_model_variables(filter="*")
        assert id(vars_1) != id(vars_3)
        
        vars_4 = negated_alias.get_model_variables(type=0)
        assert id(vars_3) != id(vars_4)
        
        vars_5 = negated_alias.get_model_time_varying_value_references()
        vars_7 = negated_alias.get_model_time_varying_value_references()
        assert id(vars_5) != id(vars_1)
        assert id(vars_5) == id(vars_7)
        
        negated_alias  = load_fmu(Test_FMUModelBase.negAliasFmu)
        
        assert len(negated_alias.cache) == 0 #No starting cache
        
        vars_6 = negated_alias.get_model_variables()
        assert id(vars_1) != id(vars_6)
        

    @testattr(stddist_full = True)
    def test_initialize_once(self):
        negated_alias  = load_fmu(Test_FMUModelBase.negAliasFmu)
        negated_alias.initialize()
        nose.tools.assert_raises(FMUException, negated_alias.initialize)

    @testattr(stddist_full = True)
    def test_set_get_negated_real(self):
        negated_alias  = load_fmu(Test_FMUModelBase.negAliasFmu)
        x,y = negated_alias.get("x"), negated_alias.get("y")
        nose.tools.assert_almost_equal(x,1.0)
        nose.tools.assert_almost_equal(y,-1.0)

        negated_alias.set("y",2)

        x,y = negated_alias.get("x"), negated_alias.get("y")
        nose.tools.assert_almost_equal(x,-2.0)
        nose.tools.assert_almost_equal(y,2.0)

        negated_alias.set("x",3)

        x,y = negated_alias.get("x"), negated_alias.get("y")
        nose.tools.assert_almost_equal(x,3.0)
        nose.tools.assert_almost_equal(y,-3.0)

    @testattr(stddist_full = True)
    def test_set_get_negated_integer(self):
        negated_alias  = load_fmu(Test_FMUModelBase.negAliasFmu)
        x,y = negated_alias.get("ix"), negated_alias.get("iy")
        nose.tools.assert_almost_equal(x,1.0)
        nose.tools.assert_almost_equal(y,-1.0)

        negated_alias.set("iy",2)

        x,y = negated_alias.get("ix"), negated_alias.get("iy")
        nose.tools.assert_almost_equal(x,-2.0)
        nose.tools.assert_almost_equal(y,2.0)

        negated_alias.set("ix",3)

        x,y = negated_alias.get("ix"), negated_alias.get("iy")
        nose.tools.assert_almost_equal(x,3.0)
        nose.tools.assert_almost_equal(y,-3.0)
        
    @testattr(stddist_full = True)
    def test_get_scalar_variable(self):
        negated_alias  = load_fmu(Test_FMUModelBase.negAliasFmu)
        
        sc_x = negated_alias.get_scalar_variable("x")
        
        assert sc_x.name == "x"
        assert sc_x.value_reference >= 0
        assert sc_x.type == fmi.FMI_REAL
        assert sc_x.variability == fmi.FMI_CONTINUOUS
        assert sc_x.causality == fmi.FMI_INTERNAL
        assert sc_x.alias == fmi.FMI_NO_ALIAS

        nose.tools.assert_raises(FMUException, negated_alias.get_scalar_variable, "not_existing")
        
    @testattr(stddist_full = True)
    def test_set_get_enumeration(self):
        tables = load_fmu(Test_FMUModelBase.enumFMU)
        assert tables.get("e") == 1 #Test that it works
        tables.set("e",2)
        
        assert tables.get("e") == 2
        
        var = tables.get_model_variables()["e"]
        
        tables.set_integer([var.value_reference],3)
        assert tables.get_integer([var.value_reference]) == 3


class Test_FMUModelCS1:
    """
    This class tests pyfmi.fmi.FMUModelCS1
    """

    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        cls.rlc_circuit = compile_fmu("RLC_Circuit",os.path.join(path_to_mofiles,"RLC_Circuit.mo"),target="cs", version="1.0")
        cls.rlc_circuit_square = compile_fmu("RLC_Circuit_Square",os.path.join(path_to_mofiles,"RLC_Circuit.mo"),target="cs", version="1.0")
        cls.no_state3 = compile_fmu("NoState.Example3",os.path.join(path_to_mofiles,"noState.mo"),target="cs", version="1.0")
        cls.simple_input = compile_fmu("Inputs.SimpleInput",os.path.join(path_to_mofiles,"InputTests.mo"),target="cs", version="1.0")
        cls.simple_input2 = compile_fmu("Inputs.SimpleInput2",os.path.join(path_to_mofiles,"InputTests.mo"),target="cs", version="1.0")
        cls.input_discontinuity = compile_fmu("Inputs.InputDiscontinuity",os.path.join(path_to_mofiles,"InputTests.mo"),target="cs", version="1.0")
        cls.terminate = compile_fmu("Terminate",os.path.join(path_to_mofiles,"Terminate.mo"),target="cs", version="1.0")
        cls.assert_fail = compile_fmu("AssertFail",os.path.join(path_to_mofiles,"Terminate.mo"),target="cs", version="1.0")
        cls.initialize_solver = compile_fmu("Inputs.DiscChange",os.path.join(path_to_mofiles,"InputTests.mo"),target="cs", version="1.0")
    
    @testattr(stddist_full = True)
    def test_reinitialize_solver(self):
        model = load_fmu(Test_FMUModelCS1.initialize_solver)
        
        model.initialize()

        model.set("u", 0.0)
        flag = model.do_step(0.0, 0.1)
        assert flag == 0
        model.set("u", 20)
        flag = model.do_step(0.1, 0.1)
        assert flag == 0
        
    
    @testattr(stddist_full = True)
    def test_asseert_fail(self):
        model = load_fmu(Test_FMUModelCS1.assert_fail)
        
        nose.tools.assert_raises(Exception, model.simulate)
    
    @testattr(stddist_full = True)
    def test_terminate(self):
        model = load_fmu(Test_FMUModelCS1.terminate)
        
        model.initialize()
        status = model.do_step(0,1)
        
        assert status == fmi.FMI_DISCARD
        assert abs(model.get_real_status(fmi.FMI1_LAST_SUCCESSFUL_TIME) - 0.5) < 1e-3
        
    @testattr(stddist_full = True)
    def test_terminate_2(self):
        model = load_fmu(Test_FMUModelCS1.terminate)
        
        res = model.simulate()
        
        assert res.status == fmi.FMI_DISCARD
        assert abs(res["time"][-1] - 0.5) < 1e-3
    
    @testattr(stddist_full = True)
    def test_custom_result_handler(self):
        model = load_fmu(Test_FMUModelCS1.rlc_circuit)

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
        model = load_fmu(Test_FMUModelCS1.rlc_circuit)

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
        model = load_fmu(Test_FMUModelCS1.no_state3)

        #Test CVode
        res = model.simulate(final_time=1.0)
        nose.tools.assert_almost_equal(res.final("x"),1.0)

        #Test Euler
        model.reset()
        model.set("_cs_solver",1)
        res = model.simulate(final_time=1.0)
        nose.tools.assert_almost_equal(res.final("x"),1.0)

    @testattr(stddist_full = True)
    def test_input_derivatives(self):
        model = load_fmu(Test_FMUModelCS1.simple_input)

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
        model = load_fmu(Test_FMUModelCS1.simple_input2)

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
        model = load_fmu(Test_FMUModelCS1.simple_input)

        model.initialize()
        model.set_input_derivatives("u",1.0, 1)
        model.set_input_derivatives("u",-1.0, 2)
        model.do_step(0, 1)
        nose.tools.assert_almost_equal(model.get("u"),0.5)

        model.do_step(1, 1)
        nose.tools.assert_almost_equal(model.get("u"),0.5)

    @testattr(stddist_full = True)
    def test_input_derivatives4(self):
        model = load_fmu(Test_FMUModelCS1.simple_input)

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
        model = load_fmu(Test_FMUModelCS1.input_discontinuity)

        model.initialize()
        model.do_step(0, 1)
        model.set("u", 1.0)
        nose.tools.assert_almost_equal(model.get("x"),0.0)
        model.do_step(1,0)
        nose.tools.assert_almost_equal(model.get("x"),1.0)

    @testattr(stddist_full = True)
    def test_version(self):
        """
        This tests the (get)-property of version.
        """
        rlc = load_fmu(Test_FMUModelCS1.rlc_circuit)
        assert rlc._get_version() == '1.0'

    @testattr(stddist_full = True)
    def test_valid_platforms(self):
        """
        This tests the (get)-property of types platform
        """
        rlc = load_fmu('RLC_Circuit.fmu')
        assert rlc._get_types_platform() == 'standard32'

    @testattr(stddist_full = True)
    def test_simulation_with_reset_cs_2(self):
        """
        Tests a simulation with reset of an JModelica generated CS FMU (final_time = 30).
        """
        rlc = load_fmu(Test_FMUModelCS1.rlc_circuit)
        res1 = rlc.simulate(final_time=30)
        resistor_v = res1['resistor.v']
        assert N.abs(resistor_v[-1] - 0.159255008028) < 1e-3
        rlc.reset()
        res2 = rlc.simulate(final_time=30)
        resistor_v = res2['resistor.v']
        assert N.abs(resistor_v[-1] - 0.159255008028) < 1e-3

    @testattr(stddist_full = True)
    def test_simulation_with_reset_cs_3(self):
        """
        Tests a simulation with reset of an JModelica generated CS FMU
        with events.
        """
        rlc_square = load_fmu(Test_FMUModelCS1.rlc_circuit_square)
        res1 = rlc_square.simulate()
        resistor_v = res1['resistor.v']
        print resistor_v[-1]
        assert N.abs(resistor_v[-1] + 0.233534539103) < 1e-3
        rlc_square.reset()
        res2 = rlc_square.simulate()
        resistor_v = res2['resistor.v']
        assert N.abs(resistor_v[-1] + 0.233534539103) < 1e-3
    
    @testattr(stddist_full = True)
    def test_simulation_with_reset_cs_4(self):
        rlc_square = load_fmu(Test_FMUModelCS1.rlc_circuit_square)
        res1 = rlc_square.simulate()
        
        rlc_square.reset()
        rlc_square.terminate()
        rlc_square.free_instance()


    @testattr(stddist_full = True)
    def test_simulation_using_euler(self):
        """
        Tests a simulation using Euler.
        """
        rlc_square = load_fmu(Test_FMUModelCS1.rlc_circuit_square)
        rlc_square.set("_cs_solver",1)

        res1 = rlc_square.simulate()
        resistor_v = res1['resistor.v']

        assert N.abs(resistor_v[-1] + 0.233534539103) < 1e-3

    @testattr(stddist_full = True)
    def test_unknown_solver(self):
        rlc = load_fmu(Test_FMUModelCS1.rlc_circuit)
        rlc.set("_cs_solver",2) #Does not exists

        nose.tools.assert_raises(FMUException, rlc.simulate)

    @testattr(windows_full = True)
    def test_simulation_cs(self):
        model = load_fmu("Modelica_Mechanics_Rotational_Examples_CoupledClutches_CS.fmu",path_to_fmus_cs1)
        res = model.simulate(final_time=1.5)
        assert (res.final("J1.w") - 3.245091100366517) < 1e-4

    @testattr(windows_full = True)
    def test_simulation_with_reset_cs(self):
        model = load_fmu("Modelica_Mechanics_Rotational_Examples_CoupledClutches_CS.fmu",path_to_fmus_cs1)
        res1 = model.simulate(final_time=1.5)
        assert (res1["J1.w"][-1] - 3.245091100366517) < 1e-4
        model.reset()
        res2 = model.simulate(final_time=1.5)
        assert (res2["J1.w"][-1] - 3.245091100366517) < 1e-4

    @testattr(windows_full = True)
    def test_default_experiment(self):
        model = load_fmu("Modelica_Mechanics_Rotational_Examples_CoupledClutches_CS.fmu",path_to_fmus_cs1)

        assert N.abs(model.get_default_experiment_start_time()) < 1e-4
        assert N.abs(model.get_default_experiment_stop_time()-1.5) < 1e-4
        assert N.abs(model.get_default_experiment_tolerance()-0.0001) < 1e-4

    @testattr(windows_full = True)
    def test_types_platform(self):
        model = load_fmu("Modelica_Mechanics_Rotational_Examples_CoupledClutches_CS.fmu",path_to_fmus_cs1)
        assert model.types_platform == "standard32"

    @testattr(windows_full = True)
    def test_exception_input_derivatives(self):
        model = load_fmu("Modelica_Mechanics_Rotational_Examples_CoupledClutches_CS.fmu",path_to_fmus_cs1)
        nose.tools.assert_raises(FMUException, model.set_input_derivatives, "u",1.0,1)

    @testattr(windows_full = True)
    def test_exception_output_derivatives(self):
        model = load_fmu("Modelica_Mechanics_Rotational_Examples_CoupledClutches_CS.fmu",path_to_fmus_cs1)
        nose.tools.assert_raises(FMUException, model.get_output_derivatives, "u",1)

    @testattr(windows_full = True)
    def test_default_simulation_stop_time(self):
        model = load_fmu("Modelica_Mechanics_Rotational_Examples_CoupledClutches_CS.fmu",path_to_fmus_cs1)
        res = model.simulate()
        assert N.abs(1.5 - res.final('time')) < 1e-4

    @testattr(stddist_full = True)
    def test_multiple_loadings_and_simulations(self):
        model = load_fmu("bouncingBall.fmu",path_to_fmus_cs1,enable_logging=False)
        res = model.simulate(final_time=1.0)
        h_res = res.final('h')

        for i in range(40):
            model = load_fmu("bouncingBall.fmu",os.path.join(path_to_fmus,"CS1.0"),enable_logging=False)
            res = model.simulate(final_time=1.0)
        assert N.abs(h_res - res.final('h')) < 1e-4

    @testattr(stddist_full = True)
    def test_log_file_name(self):
        model = load_fmu("bouncingBall.fmu",os.path.join(path_to_fmus,"CS1.0"))
        assert os.path.exists("bouncingBall_log.txt")
        model = load_fmu("bouncingBall.fmu",os.path.join(path_to_fmus,"CS1.0"),log_file_name="Test_log.txt")
        assert os.path.exists("Test_log.txt")
        model = FMUModelCS1("bouncingBall.fmu",os.path.join(path_to_fmus,"CS1.0"))
        assert os.path.exists("bouncingBall_log.txt")
        model = FMUModelCS1("bouncingBall.fmu",os.path.join(path_to_fmus,"CS1.0"),log_file_name="Test_log.txt")
        assert os.path.exists("Test_log.txt")

    @testattr(stddist_full = True)
    def test_result_name_file(self):

        #rlc_name = compile_fmu("RLC_Circuit",os.path.join(path_to_mofiles,"RLC_Circuit.mo"),target="cs")
        rlc = FMUModelCS1(Test_FMUModelCS1.rlc_circuit)

        res = rlc.simulate(options={"result_handling":"file"})

        #Default name
        assert res.result_file == "RLC_Circuit_result.txt"
        assert os.path.exists(res.result_file)

        rlc = FMUModelCS1("RLC_Circuit.fmu")
        res = rlc.simulate(options={"result_file_name":
                                    "RLC_Circuit_result_test.txt"})

        #User defined name
        assert res.result_file == "RLC_Circuit_result_test.txt"
        assert os.path.exists(res.result_file)

class Test_FMUModelME1:
    """
    This class tests pyfmi.fmi.FMUModelME1
    """

    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        cls.rlc_circuit = compile_fmu("RLC_Circuit",os.path.join(path_to_mofiles,"RLC_Circuit.mo"), version="1.0")
        cls.depPar1 = compile_fmu("DepParTests.DepPar1",os.path.join(path_to_mofiles,"DepParTests.mo"), version="1.0")
        cls.string1 = compile_fmu("StringModel1",os.path.join(path_to_mofiles,"TestString.mo"), version="1.0")
        cls.no_state_name = compile_fmu("NoState.Example1", os.path.join(path_to_mofiles,"noState.mo"), version="1.0")
        cls.alias1 = compile_fmu("Alias1",os.path.join(path_to_mofiles,"TestAlias.mo"), version="1.0")
        
    @testattr(stddist_full = True)
    def test_simulate_with_debug_option(self):
        coupled = load_fmu(self.rlc_circuit)

        opts=coupled.simulate_options()
        opts["logging"] = True
        
        #Verify that a simulation is successful
        res=coupled.simulate(options=opts)
        
        from pyfmi.debug import CVodeDebugInformation
        debug = CVodeDebugInformation(coupled.get_identifier()+"_debug.txt")
        
    @testattr(stddist_full = True)
    def test_simulate_with_debug_option_no_state(self):
        coupled = load_fmu(self.no_state_name)

        opts=coupled.simulate_options()
        opts["logging"] = True
        
        #Verify that a simulation is successful
        res=coupled.simulate(options=opts)
        
        from pyfmi.debug import CVodeDebugInformation
        debug = CVodeDebugInformation(coupled.get_identifier()+"_debug.txt")
    
    @testattr(stddist_full = True)
    def test_get_time_varying_variables(self):
        model = load_fmu(self.rlc_circuit)
        
        [r,i,b] = model.get_model_time_varying_value_references()
        [r_f, i_f, b_f] = model.get_model_time_varying_value_references(filter="*")
        
        assert len(r) == len(r_f)
        assert len(i) == len(i_f)
        assert len(b) == len(b_f)
    
    @testattr(stddist_full = True)
    def test_get_time_varying_variables_with_alias(self):
        model = load_fmu(self.alias1)
        
        [r,i,b] = model.get_model_time_varying_value_references(filter="y*")
        
        assert len(r) == 1
        assert r[0] == model.get_variable_valueref("y")
    
    @testattr(stddist_full = True)
    def test_get_string(self):
        model = load_fmu(self.string1)
        
        for i in range(100): #Test so that memory issues are detected
            assert model.get("str")[0] == "hej"
    
    @testattr(stddist_full = True)
    def test_check_against_unneccesary_derivatives_eval(self):
        name = compile_fmu("RLC_Circuit",os.path.join(path_to_mofiles,"RLC_Circuit.mo"), compiler_options={"generate_html_diagnostics":True, "log_level":6})
        
        model = load_fmu(name, log_level=6)
        model.set("_log_level", 6)
        model.initialize()
        
        len_log = len(model.get_log())
        model.time = 1e-4
        model.get_derivatives()
        assert len(model.get_log()) > len_log
        len_log = len(model.get_log())
        model.get_derivatives()
        len_log_diff = len(model.get_log())-len_log
        model.time = 1e-4
        len_log = len(model.get_log())
        model.get_derivatives()
        assert len(model.get_log())-len_log_diff == len_log
        len_log = len(model.get_log())
        model.continuous_states = model.continuous_states
        model.get_derivatives()
        assert len(model.get_log())-len_log_diff == len_log
        len_log = len(model.get_log())
        model.continuous_states = model.continuous_states+1
        model.get_derivatives()
        assert len(model.get_log())-len_log_diff > len_log
    
    @testattr(stddist_full = True)
    def test_custom_result_handler(self):
        model = load_fmu(Test_FMUModelME1.rlc_circuit)

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
        model = load_fmu(Test_FMUModelME1.rlc_circuit)

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
    def test_log_file_name(self):
        model = load_fmu("bouncingBall.fmu",path_to_fmus_me1)
        assert os.path.exists("bouncingBall_log.txt")
        model = load_fmu("bouncingBall.fmu",path_to_fmus_me1,log_file_name="Test_log.txt")
        assert os.path.exists("Test_log.txt")
        model = FMUModelME1("bouncingBall.fmu",path_to_fmus_me1)
        assert os.path.exists("bouncingBall_log.txt")
        model = FMUModelME1("bouncingBall.fmu",path_to_fmus_me1,log_file_name="Test_log.txt")
        assert os.path.exists("Test_log.txt")

    @testattr(stddist_full = True)
    def test_error_xml(self):
        nose.tools.assert_raises(FMUException,load_fmu,"bouncingBall_modified_xml.fmu",path_to_fmus_me1)
        nose.tools.assert_raises(FMUException,FMUModelME1,"bouncingBall_modified_xml.fmu",path_to_fmus_me1)

    @testattr(windows_full = True)
    def test_default_experiment(self):
        model = load_fmu("Modelica_Mechanics_Rotational_Examples_CoupledClutches_ME.fmu",path_to_fmus_me1)

        assert N.abs(model.get_default_experiment_start_time()) < 1e-4
        assert N.abs(model.get_default_experiment_stop_time()-1.5) < 1e-4
        assert N.abs(model.get_default_experiment_tolerance()-0.0001) < 1e-4

    @testattr(stddist_full = True)
    def test_get_variable_by_valueref(self):
        bounce = load_fmu('bouncingBall.fmu',path_to_fmus_me1)
        assert "der(v)" == bounce.get_variable_by_valueref(3)
        assert "v" == bounce.get_variable_by_valueref(2)

        nose.tools.assert_raises(FMUException, bounce.get_variable_by_valueref,7)

    @testattr(stddist_full = True)
    def test_multiple_loadings_and_simulations(self):
        model = load_fmu("bouncingBall.fmu",path_to_fmus_me1,enable_logging=False)
        res = model.simulate(final_time=1.0)
        h_res = res.final('h')

        for i in range(40):
            model = load_fmu("bouncingBall.fmu",path_to_fmus_me1,enable_logging=False)
            res = model.simulate(final_time=1.0)
        assert N.abs(h_res - res.final('h')) < 1e-4

    @testattr(stddist_full = True)
    def test_init(self):
        """
        This tests the method __init__.
        """
        pass

    @testattr(stddist_full = True)
    def test_model_types_platfrom(self):
        dep = load_fmu(Test_FMUModelME1.depPar1)
        assert dep.model_types_platform == "standard32"

    @testattr(stddist_full = True)
    def test_boolean(self):
        """
        This tests the functionality of setting/getting fmiBoolean.
        """
        dep = load_fmu(Test_FMUModelME1.depPar1)
        val = dep.get(["b1","b2"])

        assert val[0]
        assert not val[1]

        assert dep.get("b1")
        assert not dep.get("b2")

        dep.set("b1", False)
        assert not dep.get("b1")

        dep.set(["b1","b2"],[True,True])
        assert dep.get("b1")
        assert dep.get("b2")
        
        dep.initialize()
        dep.terminate()
        nose.tools.assert_raises(FMUException, dep.set, "b1", False)

    @testattr(stddist_full = True)
    def test_real(self):
        """
        This tests the functionality of setting/getting fmiReal.
        """
        bounce = load_fmu('bouncingBall.fmu',path_to_fmus_me1)
        const = bounce.get_real([3,4])

        nose.tools.assert_almost_equal(const[0],-9.81000000)
        nose.tools.assert_almost_equal(const[1],0.70000000)

        const = bounce.get(['der(v)','e'])

        nose.tools.assert_almost_equal(const[0],-9.81000000)
        nose.tools.assert_almost_equal(const[1],0.70000000)

    @testattr(stddist_full = True)
    def test_integer(self):
        """
        This tests the functionality of setting/getting fmiInteger.
        """
        dep = load_fmu(Test_FMUModelME1.depPar1)
        val = dep.get(["N1","N2"])

        assert val[0] == 1
        assert val[1] == 1

        assert dep.get("N1") == 1
        assert dep.get("N2") == 1

        dep.set("N1", 2)
        assert dep.get("N1") == 2

        dep.set(["N1","N2"],[3,2])
        assert dep.get("N1") == 3
        assert dep.get("N2") == 2

        dep.set("N1", 4.0)
        assert dep.get("N1")==4
        
        dep.initialize()
        dep.terminate()
        nose.tools.assert_raises(FMUException, dep.set, "N1", 4.0)

    @testattr(stddist_full = True)
    def test_string(self):
        """
        This tests the functionality of setting/getting fmiString.
        """
        #Cannot be tested with the current models.
        pass

    @testattr(stddist_full = True)
    def test_t(self):
        """
        This tests the functionality of setting/getting time.
        """
        bounce = load_fmu('bouncingBall.fmu',path_to_fmus_me1)
        bounce.initialize()
        assert bounce.time == 0.0
        
        dq = load_fmu('dq.fmu',path_to_fmus_me1)
        dq.initialize()
        assert dq.time == 0.0

        bounce.time = 1.0
        assert bounce.time == 1.0

        nose.tools.assert_raises(TypeError, bounce._set_time, N.array([1.0,1.0]))
        
        bounce.terminate()
        nose.tools.assert_raises(FMUException, bounce._set_time, N.array([1.0]))


    @testattr(stddist_full = True)
    def test_real_x(self):
        """
        This tests the property of the continuous_states.
        """
        bounce = load_fmu('bouncingBall.fmu',path_to_fmus_me1)
        bounce.initialize()
        
        dq = load_fmu('dq.fmu',path_to_fmus_me1)
        nose.tools.assert_raises(FMUException, bounce._set_continuous_states,N.array([1.]))
        nose.tools.assert_raises(FMUException, dq._set_continuous_states,N.array([1.0,1.0]))

        temp = N.array([2.0,1.0])
        bounce.continuous_states = temp

        nose.tools.assert_almost_equal(bounce.continuous_states[0],temp[0])
        nose.tools.assert_almost_equal(bounce.continuous_states[1],temp[1])
        
        bounce.terminate()
        nose.tools.assert_raises(FMUException, bounce._set_continuous_states, temp)


    @testattr(stddist_full = True)
    def test_real_dx(self):
        """
        This tests the method get_derivative.
        """
        #Bounce
        bounce = load_fmu('bouncingBall.fmu',path_to_fmus_me1)
        bounce.initialize()
        
        real_dx = bounce.get_derivatives()
        nose.tools.assert_almost_equal(real_dx[0], 0.00000000)
        nose.tools.assert_almost_equal(real_dx[1], -9.810000000)

        bounce.continuous_states = N.array([2.,5.])
        real_dx = bounce.get_derivatives()
        nose.tools.assert_almost_equal(real_dx[0], 5.000000000)
        nose.tools.assert_almost_equal(real_dx[1], -9.810000000)

        #DQ
        dq = load_fmu('dq.fmu',path_to_fmus_me1)
        dq.initialize()
        real_dx = dq.get_derivatives()
        nose.tools.assert_almost_equal(real_dx[0], -1.0000000)
        dq.continuous_states = N.array([5.])
        real_dx = dq.get_derivatives()
        nose.tools.assert_almost_equal(real_dx[0], -5.0000000)

    @testattr(stddist_full = True)
    def test_real_x_nominal(self):
        """
        This tests the (get)-property of nominal_continuous_states.
        """
        bounce = load_fmu('bouncingBall.fmu',path_to_fmus_me1)
        nominal = bounce.nominal_continuous_states

        assert nominal[0] == 1.0
        assert nominal[1] == 1.0
        
        dq = load_fmu('dq.fmu',path_to_fmus_me1)
        nominal = dq.nominal_continuous_states

        assert nominal[0] == 1.0

    @testattr(stddist_full = True)
    def test_version(self):
        """
        This tests the (get)-property of version.
        """
        bounce = load_fmu('bouncingBall.fmu',path_to_fmus_me1)
        assert bounce._get_version() == '1.0'
        dq = load_fmu('dq.fmu',path_to_fmus_me1)
        assert dq._get_version() == '1.0'

    @testattr(stddist_full = True)
    def test_valid_platforms(self):
        """
        This tests the (get)-property of model_types_platform
        """
        bounce = load_fmu('bouncingBall.fmu',path_to_fmus_me1)
        assert bounce.model_types_platform == 'standard32'
        dq = load_fmu('dq.fmu',path_to_fmus_me1)
        assert dq.model_types_platform == 'standard32'

    @testattr(stddist_full = True)
    def test_get_tolerances(self):
        """
        This tests the method get_tolerances.
        """
        bounce = load_fmu('bouncingBall.fmu',path_to_fmus_me1)
        [rtol,atol] = bounce.get_tolerances()

        assert rtol == 0.0001
        nose.tools.assert_almost_equal(atol[0],0.0000010)
        nose.tools.assert_almost_equal(atol[1],0.0000010)
        
        dq = load_fmu('dq.fmu',path_to_fmus_me1)
        [rtol,atol] = dq.get_tolerances()

        assert rtol == 0.0001
        nose.tools.assert_almost_equal(atol[0],0.0000010)

    @testattr(stddist_full = True)
    def test_event_indicators(self):
        """
        This tests the method get_event_indicators.
        """
        bounce = load_fmu('bouncingBall.fmu',path_to_fmus_me1)
        bounce.initialize()
        dq = load_fmu('dq.fmu',path_to_fmus_me1)
        
        assert len(bounce.get_event_indicators()) == 1
        assert len(dq.get_event_indicators()) == 0

        event_ind = bounce.get_event_indicators()
        nose.tools.assert_almost_equal(event_ind[0],1.0000000000)
        bounce.continuous_states = N.array([5.]*2)
        event_ind = bounce.get_event_indicators()
        nose.tools.assert_almost_equal(event_ind[0],5.0000000000)

    @testattr(stddist_full = True)
    def test_update_event(self):
        """
        This tests the functionality of the method event_update.
        """
        bounce = load_fmu('bouncingBall.fmu',path_to_fmus_me1)
        bounce.initialize()
        bounce.continuous_states = N.array([1.0,1.0])

        bounce.event_update()

        nose.tools.assert_almost_equal(bounce.continuous_states[0],1.0000000000)
        nose.tools.assert_almost_equal(bounce.continuous_states[1],-0.7000000000)

        bounce.event_update()

        nose.tools.assert_almost_equal(bounce.continuous_states[0],1.0000000000)
        nose.tools.assert_almost_equal(bounce.continuous_states[1],0.49000000000)

        eInfo = bounce.get_event_info()

        assert eInfo.nextEventTime == 0.0
        assert eInfo.upcomingTimeEvent == False
        assert eInfo.iterationConverged == True
        assert eInfo.stateValueReferencesChanged == False

    @testattr(stddist_full = True)
    def test_get_continuous_value_references(self):
        """
        This tests the functionality of the method get_state_value_references.
        """
        bounce = load_fmu('bouncingBall.fmu',path_to_fmus_me1)
        dq = load_fmu('dq.fmu',path_to_fmus_me1)
        
        ref = bounce.get_state_value_references()
        assert ref[0] == 0
        assert ref[1] == 2

        ref = dq.get_state_value_references()
        assert ref[0] == 0

    @testattr(stddist_full = True)
    def test_ode_get_sizes(self):
        """
        This tests the functionality of the method ode_get_sizes.
        """
        bounce = load_fmu('bouncingBall.fmu',path_to_fmus_me1)
        dq = load_fmu('dq.fmu',path_to_fmus_me1)
        
        [nCont,nEvent] = bounce.get_ode_sizes()
        assert nCont == 2
        assert nEvent == 1

        [nCont,nEvent] = dq.get_ode_sizes()
        assert nCont == 1
        assert nEvent == 0

    @testattr(stddist_full = True)
    def test_get_name(self):
        """
        This tests the functionality of the method get_name.
        """
        bounce = load_fmu('bouncingBall.fmu',path_to_fmus_me1)
        dq = load_fmu('dq.fmu',path_to_fmus_me1)
        
        assert bounce.get_name() == 'bouncingBall'
        assert dq.get_name() == 'dq'

    @testattr(stddist_full = True)
    def test_get_fmi_options(self):
        """
        Test that simulate_options on an FMU returns the correct options
        class instance.
        """
        bounce = load_fmu('bouncingBall.fmu',path_to_fmus_me1)
        assert isinstance(bounce.simulate_options(), ad.AssimuloFMIAlgOptions)

    @testattr(stddist_full = True)
    def test_instantiate_jmu(self):
        """
        Test that FMUModel can not be instantiated with a JMU file.
        """
        nose.tools.assert_raises(FMUException,FMUModelME1,'model.jmu')


class Test_FMI_Compile:
    """
    This class tests pymodelica.compile_fmu compilation functionality.
    """

    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        fpath = os.path.join(path_to_mofiles,'RLC_Circuit.mo')
        cls.fmuname = compile_fmu('RLC_Circuit',fpath, version="1.0")

    def setUp(self):
        """
        Sets up the test case.
        """
        self._model  = load_fmu(Test_FMI_Compile.fmuname)

    @testattr(stddist_full = True)
    def test_get_version(self):
        """ Test the version property."""
        nose.tools.assert_equal(self._model.version, "1.0")

    @testattr(stddist_full = True)
    def test_get_model_types_platform(self):
        """ Test the model types platform property. """
        nose.tools.assert_equal(self._model.model_types_platform, "standard32")

    @testattr(stddist_full = True)
    def test_set_compiler_options(self):
        """ Test compiling with compiler options."""
        libdir = os.path.join(get_files_path(), 'MODELICAPATH_test', 'LibLoc1',
            'LibA')
        co = {"index_reduction":True, "equation_sorting":True}
        compile_fmu('RLC_Circuit', [os.path.join(path_to_mofiles,'RLC_Circuit.mo'), libdir],
            compiler_options = co)

class TestDependentParameters(object):
    """
    Test that dependent variables are recomputed when an independent varaible is set.
    """
    
    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        fpath = os.path.join(get_files_path(), 'Modelica', "DepPar.mo")
        cpath = "DepPar.DepPar1"
        cls.fmu_name = compile_fmu(cpath, fpath, version="1.0")

    @testattr(stddist_full = True)
    def test_parameter_eval(self):
       """
       Test that the parameters are evaluated correctly.
       """
       model = load_fmu(TestDependentParameters.fmu_name)
       model.set('p1',2.0)

       p2 = model.get('p2')
       p3 = model.get('p3')

       nose.tools.assert_almost_equal(p2,4)
       nose.tools.assert_almost_equal(p3,12)

class Test_Logger:
    """
    This class tests the Python interface to the FMI runtime log
    """

    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        cls.fmu =  compile_fmu('LoggerTest',os.path.join(path_to_mofiles,'LoggerTest.mo'),compiler_log_level='e',
                compiler_options={'generate_only_initial_system':True}, version="1.0")

    def setUp(self):
        """
        Sets up the test case.
        """
        self.m = load_fmu(Test_Logger.fmu)
        self.m.set_debug_logging(True)
        self.m.set('_log_level',7)
        self.m.set("_nle_solver_use_last_integrator_step", False)
        self.m.set_log_level(5)

    @testattr(stddist_full = True)
    def test_log_file(self):
        """
        Test that the log file is parsable
        """

        self.m.set('u1',3)

        self.m.get('u1')
        self.m.set('y1',0.)
        self.m.initialize()
        self.m.get('u1')
        self.m.set('u1',4)
        self.m.get('u1')
        self.m.get_derivatives()
        self.m.set('y1',0.5)
        self.m.get('x1')
        self.m.set('p',0.5)
        self.m.get('x1')

        d = gather_solves(parse_jmi_log('LoggerTest_log.txt'))

        assert len(d)==7, "Unexpected number of solver invocations"
        assert len(d[0]['block_solves'])==3, "Unexpected number of block solves in first iteration"

    @testattr(stddist_full = True)
    def test_parse_log_file(self):
        """
        Test that a pregenerated log file is parsable
        """

        log = parse_jmi_log(os.path.join(path_to_fmu_logs, 'LoggerTest_log.txt'))

        assert log.find("EquationSolve")[0].t == 0.0
        
        d = gather_solves(log)

        assert len(d)==8, "Unexpected number of solver invocations"
        assert d[0].t==0.0
        assert len(d[0].block_solves)==4, "Unexpected number of block solves in first iteration"

        vars = d[0].block_solves[0].variables
        assert len(vars)==3
        assert all(vars==N.asarray(['x1', 'z1', 'y1']))
        
        assert N.array_equiv( d[0].block_solves[0].min,
                              N.asarray([-1.7976931348623157E+308, -1.7976931348623157E+308, -1.7976931348623157E+308]) )
        assert N.array_equiv( d[0].block_solves[0].max,
                              N.asarray([ 1.7976931348623157E+308,  1.7976931348623157E+308,  1.7976931348623157E+308]) )
        assert N.array_equiv( d[0].block_solves[0].initial_residual_scaling,
                              N.asarray([4.0, 1.0, 1.0]) )
        assert len(d[0].block_solves[0].iterations)==12

        assert N.array_equiv( d[0].block_solves[0].iterations[0].ivs,
                              N.asarray([0.0,  0.0,  1.4901161193847656E-08]) )
        assert N.array_equiv( d[0].block_solves[0].iterations[0].residuals,
                              N.asarray([-1.25, 1.1999999985098839E+01, 2.9999999850988388E+00]) )
        
        assert N.array_equiv( d[0].block_solves[0].iterations[0].jacobian,
                              N.asarray([[-1.0,  4.0,  0.0],
                                         [-1.0, -1.0, -1.0],
                                         [-1.0,  1.0, -1.0]]) )

        assert d[0].block_solves[0].iterations[0].jacobian_updated==True
        assert N.array_equiv( d[0].block_solves[0].iterations[0].residual_scaling,
                              N.asarray([ 4.0,  1.0,  1.0]) )
        assert d[0].block_solves[0].iterations[0].residual_scaling_updated==False
        nose.tools.assert_almost_equal( d[0].block_solves[0].iterations[0].scaled_residual_norm,
                                        1.2432316741177614E+01 )


class Test_SetDependentParameterError:
    """
    Test that setting dependent parameters results in exception
    """

    @classmethod
    def setUpClass(self):
        """
        Sets up the test class.
        """
        self.fmu =  compile_fmu('Parameter.Error.Dependent',os.path.join(path_to_mofiles,'ParameterTests.mo'), version="1.0")

    def setUp(self):
        """
        Sets up the test case.
        """
        self.m = load_fmu(self.fmu)

    @testattr(stddist_full = True)
    def test_dependent_parameter_setting(self):
        """
        Test that expeptions are thrown when dependent parameters are set.
        """
        self.m.set('pri',3)
        nose.tools.assert_raises(FMUException,self.m.set, 'prd', 5)
        nose.tools.assert_raises(FMUException,self.m.set, 'cr', 5)
        self.m.set('pii',3)
        nose.tools.assert_raises(FMUException,self.m.set, 'pid', 5)
        nose.tools.assert_raises(FMUException,self.m.set, 'ci', 5)
        self.m.set('pbi',True)
        nose.tools.assert_raises(FMUException,self.m.set, 'pbd', True)
        nose.tools.assert_raises(FMUException,self.m.set, 'cb', True)

class Test_DependentParameterEvaluationError:
    """
    Test that errors in evaluating dependent parameters results in exceptions
    """

    @classmethod
    def setUpClass(self):
        """
        Sets up the test class.
        """
        self.fmu =  compile_fmu('Parameter.Error.DependentCheck',os.path.join(path_to_mofiles,'ParameterTests.mo'), version="1.0")

    def setUp(self):
        """
        Sets up the test case.
        """
        self.m = load_fmu(self.fmu)

    @testattr(stddist_full = True)
    def test_dependent_parameter_eval(self):
        """
        Test that expeptions are thrown when dependent parameters evaluation fails.
        """
        nose.tools.assert_almost_equal( self.m.get('pd'),0.5) # test value after instantiate
        self.m.set('p',0.6)
        nose.tools.assert_almost_equal( self.m.get('pd'),0.6) # test value propagation
        self.m.set('p',5)
        nose.tools.assert_raises(FMUException,self.m.get, 'pd') # test that assert triggers

class Test_StructuralParameterError:
    """
    Test that setting structural independent parameters results in exception
    """

    @classmethod
    def setUpClass(self):
        """
        Sets up the test class.
        """
        self.fmu =  compile_fmu('Parameter.Error.Structural',os.path.join(path_to_mofiles,'ParameterTests.mo'), version="1.0")

    def setUp(self):
        """
        Sets up the test case.
        """
        self.m = load_fmu(self.fmu)

    @testattr(stddist_full = True)
    def test_dependent_parameter_setting(self):
        """
        Test that expeptions are thrown when dependent parameters are set.
        """
        nose.tools.assert_raises(FMUException,self.m.set, 'a', 1)
        nose.tools.assert_raises(FMUException,self.m.set, 'b', 1)
        nose.tools.assert_raises(FMUException,self.m.set, 'c', 1)
        nose.tools.assert_raises(FMUException,self.m.set, 'd', 1)

class Test_RaisesIfNonConverge:
    """
    Test that exception is raised if NLE solver does not converge
    """

    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        cls.fmu =  compile_fmu('InitTest1',os.path.join(path_to_mofiles,'InitTest.mo'), version="1.0")

    def setUp(self):
        """
        Sets up the test case.
        """
        self.m = load_fmu(Test_RaisesIfNonConverge.fmu)

    @testattr(stddist_full = True)
    def test_get_raises(self):
        """
        Test that expeptions are thrown when equation becomes non-solvable.
        """
        m = self.m
        m.set('_log_level',5)
        m.set_fmil_log_level(5)

        m.set('u1',3)

        print 'u1' + str(m.get('u1'))
        print 'x1' + str(m.get('x1'))
        print 'y1' + str(m.get('y1'))
        print 'z1' + str(m.get('z1'))

        m.set('y1',0.)

        m.initialize()

        print "model initialized"

        print 'u1' + str(m.get('u1'))
        print 'x1' + str(m.get('x1'))
        print 'y1' + str(m.get('y1'))
        print 'z1' + str(m.get('z1'))

        m.set('u1',4)

        print "Inpu1t set"

        print 'u1' + str(m.get('u1'))
        print 'x1' + str(m.get('x1'))
        print 'y1' + str(m.get('y1'))
        print 'z1' + str(m.get('z1'))

        m.get_derivatives()

        print "Set initial valu1e of y1"
        m.set('y1',0.5)

        print 'x1' + str(m.get('x1'))
        print 'y1' + str(m.get('y1'))
        print 'z1' + str(m.get('z1'))

        print "Set bad initial valu1e of p"
        m.set('p',0.5)
        #Why should this fail? NEEDS TO BE INVESTIGATED!
        #nose.tools.assert_raises(FMUException,m.get, 'x1')

        print "Set good p"
        m.set('p',4)
        print 'x1 = ' + str(m.get('x1'))
        print 'y1' + str(m.get('y1'))
        print 'z1' + str(m.get('z1'))

        print "Set large p & u1"
        m.set('p',1e300)
        m.set('u1',1e300)
        nose.tools.assert_raises(FMUException,m.get, 'z1')

