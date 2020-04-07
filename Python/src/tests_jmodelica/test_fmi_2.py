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
import scipy.sparse.csc
from collections import OrderedDict

from tests_jmodelica import testattr, get_files_path
from pymodelica.compiler import compile_fmu
from pyfmi.fmi import FMUModel, FMUException, FMUModelME1, FMUModelCS1, load_fmu, FMUModelCS2, FMUModelME2, PyEventInfo
import pyfmi.fmi_algorithm_drivers as ad
from pyfmi.common.core import get_platform_dir
from pyjmi.log import parse_jmi_log, gather_solves
from pyfmi.common.io import ResultHandler
import pyfmi.fmi_util as fmi_util
import pyfmi.fmi as fmi

path_to_fmus = os.path.join(get_files_path(), 'FMUs')
path_to_fmus_me1 = os.path.join(path_to_fmus,"ME1.0")
path_to_fmus_cs1 = os.path.join(path_to_fmus,"CS1.0")
path_to_mofiles = os.path.join(get_files_path(), 'Modelica')

path_to_fmus_me2 = os.path.join(path_to_fmus,"ME2.0")
path_to_fmus_cs2 = os.path.join(path_to_fmus,"CS2.0")
ME2 = 'bouncingBall2_me.fmu'
CS2 = 'bouncingBall2_cs.fmu'
ME1 = 'bouncingBall.fmu'
CS1 = 'bouncingBall.fmu'

class Test_FMIUtil:
    
    @testattr(stddist_full = True)
    def test_cpr_seed(self):
        structure = OrderedDict([('der(inertia3.phi)', ['inertia3.w']),
             ('der(inertia3.w)', ['damper.phi_rel', 'inertia3.phi']),
             ('der(damper.phi_rel)', ['damper.w_rel']),
             ('der(damper.w_rel)',
              ['damper.phi_rel', 'damper.w_rel', 'inertia3.phi'])])
        
        states = ['inertia3.phi', 'inertia3.w', 'damper.phi_rel', 'damper.w_rel']
        
        groups = fmi_util.cpr_seed(structure, states)
        
        assert groups[0][5] == [1,2,3]
        assert groups[1][5] == [5,7]
        assert groups[2][5] == [8,9]
        assert groups[0][4] == [0,1,2]
        assert groups[1][4] == [3,4]
        assert groups[2][4] == [5,6]


class Test_FMUModelBase2:
    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        cls.negAliasFmu = compile_fmu("NegatedAlias",os.path.join(path_to_mofiles,"NegatedAlias.mo"), version=2.0)
        cls.enumeration3 = compile_fmu("Enumerations.Enumeration3",os.path.join(path_to_mofiles,"Enumerations.mo"), version=2.0)
        cls.enumeration4 = compile_fmu("Enumerations.Enumeration4",os.path.join(path_to_mofiles,"Enumerations.mo"), version=2.0)
        cls.nonlinear8 = compile_fmu("NonLinear.NonLinear8",os.path.join(path_to_mofiles,"NonLinear.mo"), version=2.0)
        cls.brentEnforce = compile_fmu("TestBrent.Bounds", os.path.join(path_to_mofiles,"TestBrent.mo"), version=2.0)
    
    @testattr(stddist_full = True)
    def test_enforce_bounds_brent(self):
        
        model = load_fmu(self.brentEnforce)

        model.set("_enforce_bounds", True)
        nose.tools.assert_raises(FMUException, model.initialize)
        
        model = load_fmu(self.brentEnforce)
        
        model.set("_enforce_bounds", False)
        model.initialize()
        
    @testattr(stddist_full = True)
    def test_brent_failure_message(self):
        
        model = load_fmu(Test_FMUModelBase2.nonlinear8)
        
        try:
            model.initialize()
        except FMUException:
            pass
        
        err_msg = ""
        for line in model.get_log():
            if "BrentBracketFailed" in line:
                err_msg = line
                break
        
        #Check that certain key attributes are in the error message
        assert "variable" in err_msg
        assert "min" in err_msg
        assert "max" in err_msg
    
    @testattr(stddist_full = True)
    def test_get_scalar_variable(self):
        negated_alias  = load_fmu(Test_FMUModelBase2.negAliasFmu)
        
        sc_x = negated_alias.get_scalar_variable("x")
        
        assert sc_x.name == "x"
        assert sc_x.value_reference >= 0
        assert sc_x.type == fmi.FMI2_REAL
        assert sc_x.variability == fmi.FMI2_CONTINUOUS
        assert sc_x.causality == fmi.FMI2_LOCAL

        nose.tools.assert_raises(FMUException, negated_alias.get_scalar_variable, "not_existing")
    
    @testattr(stddist_full = True)
    def test_declared_enumeration_type(self):
        enumeration_model = load_fmu(Test_FMUModelBase2.enumeration3)
        
        enum = enumeration_model.get_variable_declared_type("x")
        assert len(enum.items.keys()) == 2
        enum = enumeration_model.get_variable_declared_type("home")
        assert len(enum.items.keys()) == 4
        
        nose.tools.assert_raises(FMUException, enumeration_model.get_variable_declared_type, "z")
    
    @testattr(stddist_full = True)
    def test_set_enumeration(self):
        enumeration_model = load_fmu(Test_FMUModelBase2.enumeration4)
        
        assert enumeration_model.get("tsize")[0] == 2
        
        enumeration_model.set("tsize", "small")
        assert enumeration_model.get("tsize")[0] == 1
        
        enumeration_model.set("tsize", "large")
        assert enumeration_model.get("tsize")[0] == 3
        
        enumeration_model.set("tsize", 2)
        assert enumeration_model.get("tsize")[0] == 2
        
        nose.tools.assert_raises(FMUException, enumeration_model.set, "tsize", "hej")
    
    @testattr(stddist_full = True)
    def test_version(self):
        negated_alias  = load_fmu(Test_FMUModelBase2.negAliasFmu)
        
        assert negated_alias.get_version() == "2.0"

    @testattr(stddist_full = True)
    def test_caching(self):
        negated_alias  = load_fmu(Test_FMUModelBase2.negAliasFmu)
        
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
        
        negated_alias  = load_fmu(Test_FMUModelBase2.negAliasFmu)
        
        assert len(negated_alias.cache) == 0 #No starting cache
        
        vars_6 = negated_alias.get_model_variables()
        assert id(vars_1) != id(vars_6)


    @testattr(stddist_full = True)
    def test_set_get_negated_real(self):
        negated_alias  = load_fmu(Test_FMUModelBase2.negAliasFmu)
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
        negated_alias  = load_fmu(Test_FMUModelBase2.negAliasFmu)
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
    def test_set_additional_logger(self):
        messages = []
        def my_custom_logger(module, log_level, message):
            messages.append(message)
        log_level = 4
        model = load_fmu(Test_FMUModelBase2.negAliasFmu, log_level=log_level)
        model.set("_log_level", log_level)
        model.set_additional_logger(my_custom_logger)
        model.simulate()
        assert(len(messages) > 0)
        
    @testattr(windows_full = True)
    def test_get_erronous_nominals(self):
        
        model = load_fmu("NominalTest4.fmu",path_to_fmus_me2)
        
        nose.tools.assert_almost_equal(model.get_variable_nominal("x"), 2.0)
        nose.tools.assert_almost_equal(model.get_variable_nominal("y"), 1.0)

class Test_FMUModelCS2:
    """
    This class tests pyfmi.fmi.FMUModelCS2
    """
    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        cls.coupled_name = compile_fmu("Modelica.Mechanics.Rotational.Examples.CoupledClutches", target="cs", version="2.0", compiler_options={'eliminate_alias_constants':False})
        cls.bouncing_name = compile_fmu("BouncingBall",os.path.join(path_to_mofiles,"BouncingBall.mo"), target="cs", version="2.0", compiler_options={'eliminate_alias_constants':False})
        cls.terminate = compile_fmu("Terminate",os.path.join(path_to_mofiles,"Terminate.mo"),target="cs", version="2.0")
        cls.assert_fail = compile_fmu("AssertFail",os.path.join(path_to_mofiles,"Terminate.mo"),target="cs", version="2.0")
        cls.initialize_solver = compile_fmu("Inputs.DiscChange",os.path.join(path_to_mofiles,"InputTests.mo"),target="cs", version="2.0")
    
    @testattr(stddist_full = True)
    def test_reinitialize_solver(self):
        model = load_fmu(Test_FMUModelCS2.initialize_solver)
        
        model.initialize()

        model.set("u", 0.0)
        flag = model.do_step(0.0, 0.1)
        assert flag == 0
        model.set("u", 20)
        flag = model.do_step(0.1, 0.1)
        assert flag == 0
        
    @testattr(stddist_full = True)
    def test_assert_fail(self):
        model = load_fmu(Test_FMUModelCS2.assert_fail)
        
        nose.tools.assert_raises(Exception, model.simulate)
    
    @testattr(stddist_full = True)
    def test_terminate(self):
        model = load_fmu(Test_FMUModelCS2.terminate)
        
        model.initialize()
        status = model.do_step(0,1)
        
        assert status == fmi.FMI_DISCARD
        assert abs(model.get_real_status(fmi.FMI2_LAST_SUCCESSFUL_TIME) - 0.5) < 1e-3
        
    @testattr(stddist_full = True)
    def test_terminate_2(self):
        model = load_fmu(Test_FMUModelCS2.terminate)
        
        res = model.simulate()
        
        assert res.status == fmi.FMI_DISCARD
        assert abs(res["time"][-1] - 0.5) < 1e-3

    @testattr(stddist_full = True)
    def test_log_file_name(self):
        path, file_name = os.path.split(self.coupled_name)
        coupled = load_fmu(self.coupled_name)
        
        assert coupled.get_log_file_name() == file_name.replace(".","_")[:-4]+"_log.txt"
        
    @testattr(stddist_full = True)
    def test_part_log(self):
        model = load_fmu(self.coupled_name, log_level=6)
        
        model.set("_log_level", 6)
        
        model.simulate()
        
        num_lines = model.get_number_of_lines_log()
        assert num_lines > 50 #Assert big log
        
        log = model.get_log(start_lines=10)
        assert len(log) == 10
        log = model.get_log(end_lines=10)
        assert len(log) == 10
        log = model.get_log()
        assert len(log) == num_lines
        log = model.get_log(start_lines=10, end_lines=10)
        assert len(log) == 20
        log = model.get_log(start_lines=num_lines-10, end_lines=num_lines-10)
        assert len(log) == num_lines
    
    @testattr(windows_full = True)
    def test_init(self):
        """
        Test the method __init__ in FMUModelCS2
        """
        bounce = load_fmu(self.bouncing_name)

        assert bounce.get_identifier() == 'BouncingBall'
        nose.tools.assert_raises(FMUException, FMUModelCS2, fmu=ME2, path=path_to_fmus_me2)
        nose.tools.assert_raises(FMUException, FMUModelCS2, fmu=CS1, path=path_to_fmus_cs1)
        nose.tools.assert_raises(FMUException, FMUModelCS2, fmu=ME1, path=path_to_fmus_me1)

    @testattr(stddist_full = True)
    def test_instantiate_slave(self):
        """
        Test the method instantiate_slave in FMUModelCS2
        """
        bounce = load_fmu(self.bouncing_name)
        
        bounce.setup_experiment()
        bounce.initialize()

        bounce.reset() #Test multiple instantiation
        for i in range(0,10):
            name_of_slave = 'slave' + str(i)
            bounce.instantiate(name = name_of_slave)

    @testattr(stddist_full = True)
    def test_initialize(self):
        """
        Test the method initialize in FMUModelCS2
        """
        bounce = load_fmu(self.bouncing_name)

        for i in range(10):
            bounce.setup_experiment(tolerance= 10**-i)
            bounce.initialize()  #Initialize multiple times with different relTol
            bounce.reset()
            
        bounce.setup_experiment()
        bounce.initialize()    #Initialize with default options
        bounce.reset()

        bounce.setup_experiment(start_time=4.5)
        bounce.initialize()
        nose.tools.assert_almost_equal(bounce.time, 4.5)
    
    @testattr(stddist_full = True)
    def test_simulation_past_tstop(self):
        
        coupled = load_fmu(self.coupled_name)
        
        #Try to simulate past the defined stop
        coupled.setup_experiment(stop_time_defined=True, stop_time=1.0)
        coupled.initialize()
        
        step_size=0.1
        total_time=0
        for i in range(10):
            coupled.do_step(total_time, step_size)
            total_time += step_size
        status = coupled.do_step(total_time, step_size)
        assert status != 0

    @testattr(stddist_full = True)
    def test_reset_slave(self):
        """
        Test the method reset_slave in FMUModelCS2
        """
        bounce = load_fmu(self.bouncing_name)
        
        bounce.setup_experiment()
        bounce.initialize()

        bounce.reset()
        
        bounce.setup_experiment()
        bounce.initialize()
    
    @testattr(stddist_full = True)
    def test_reset_free_slave(self):
        bounce = load_fmu(self.bouncing_name)
        res = bounce.simulate()
        
        bounce.reset()
        bounce.terminate()
        bounce.free_instance()
        
    @testattr(stddist_full = True)
    def test_terminate(self):
        """
        Test the method terminate in FMUModelCS2
        """
        coupled = load_fmu(self.coupled_name)
        
        coupled.setup_experiment()
        coupled.initialize()
        coupled.terminate()

    @testattr(stddist_full = True)
    def test_the_time(self):
        """
        Test the time in FMUModelCS2
        """
        bounce = load_fmu(self.bouncing_name)
        
        bounce.setup_experiment()
        bounce.initialize()

        assert bounce.time == 0.0
        bounce._set_time(4.5)
        assert bounce._get_time() == 4.5
        bounce.time = 3
        assert bounce.time == 3.0

        bounce.reset()
        bounce.setup_experiment(start_time=2.5)
        bounce.initialize()
        assert bounce.time == 2.5

    @testattr(stddist_full = True)
    def test_version(self):
        bounce = load_fmu(self.bouncing_name)
        assert bounce.get_version() == "2.0"
        
        coupled = load_fmu(self.coupled_name)
        assert coupled.get_version() == "2.0"

    @testattr(stddist_full = True)
    def test_do_step(self):
        """
        Test the method do_step in FMUModelCS2
        """
        bounce = load_fmu(self.bouncing_name)
        
        bounce.setup_experiment()
        bounce.initialize()
        
        coupled = load_fmu(self.coupled_name)
        
        coupled.setup_experiment()
        coupled.initialize()

        new_step_size = 1e-1
        for i in range(1,30):
            current_time = bounce.time
            status = bounce.do_step(current_time, new_step_size, True)
            assert status == 0
            nose.tools.assert_almost_equal(bounce.time , current_time + new_step_size)

        for i in range(10):
            current_time = coupled.time
            status = coupled.do_step(current_time, new_step_size, True)
            assert status == 0
            nose.tools.assert_almost_equal(coupled.time , current_time + new_step_size)

    @testattr(stddist_full = True)
    def test_set_input_derivatives(self):
        """
        Test the method set_input_derivatives in FMUModelCS2
        """
        #Do the setUp
        coupled = load_fmu(self.coupled_name)

        nose.tools.assert_raises(FMUException, coupled.set_input_derivatives, 'J1.phi', 1.0, 0) #this is nou an input-variable
        nose.tools.assert_raises(FMUException, coupled.set_input_derivatives, 'J1.phi', 1.0, 1)
        nose.tools.assert_raises(FMUException, coupled.set_input_derivatives, 578, 1.0, 1)

    @testattr(stddist_full = True)
    def test_get_output_derivatives(self):
        """
        Test the method get_output_derivatives in FMUModelCS2
        """
        coupled = load_fmu(self.coupled_name)
        
        coupled.setup_experiment()
        coupled.initialize()

        coupled.do_step(0.0, 0.02)
        nose.tools.assert_raises(FMUException, coupled.get_output_derivatives, 'J1.phi', 1)
        nose.tools.assert_raises(FMUException, coupled.get_output_derivatives, 'J1.phi', -1)
        nose.tools.assert_raises(FMUException, coupled.get_output_derivatives, 578, 0)

    @testattr(stddist_full = True)
    def test_get_directional_derivative_capability(self):
        """
        Test the method get_directional_derivative in FMUModelCS2
        """
        
        # Setup
        bounce = load_fmu(self.bouncing_name)
        bounce.setup_experiment()
        bounce.initialize()
        
        # Bouncing ball don't have the capability, check that this is handled
        nose.tools.assert_raises(FMUException, bounce.get_directional_derivative, [1], [1], [1])
        
    @testattr(stddist_full = True)
    def test_simulate(self):
        """
        Test the main features of the method simulate() in FMUmodelCS2
        """
        #Set up for simulation
        bounce = load_fmu(self.bouncing_name)
        coupled = load_fmu(self.coupled_name)

        #Try simulate the bouncing ball
        res = bounce.simulate()
        sim_time = res['time']
        nose.tools.assert_almost_equal(sim_time[0], 0.0)
        nose.tools.assert_almost_equal(sim_time[-1], 1.0)
        bounce.reset()

        for i in range(5):
            res = bounce.simulate(start_time=0.1, final_time=1.0, options={'ncp':500})
            sim_time = res['time']
            nose.tools.assert_almost_equal(sim_time[0], 0.1)
            nose.tools.assert_almost_equal(sim_time[-1],1.0)
            assert sim_time.all() >= sim_time[0] - 1e-4   #Check that the time is increasing
            assert sim_time.all() <= sim_time[-1] + 1e-4  #Give it some marginal
            height = res['h']
            assert height.all() >= -1e-4 #The height of the ball should be non-negative
            nose.tools.assert_almost_equal(res.final('h'), 6.0228998448008104, 4)
            if i>0: #check that the results stays the same
                diff = height_old - height
                nose.tools.assert_almost_equal(diff[-1],0.0)
            height_old = height
            bounce.reset()

        #Try to simulate the coupled-clutches
        res_coupled = coupled.simulate()
        sim_time_coupled = res_coupled['time']
        nose.tools.assert_almost_equal(sim_time_coupled[0], 0.0)
        nose.tools.assert_almost_equal(sim_time_coupled[-1], 1.5)
        coupled.reset()


        for i in range(10):
            coupled = load_fmu(self.coupled_name)
            res_coupled = coupled.simulate(start_time=0.0, final_time=2.0)
            sim_time_coupled = res_coupled['time']
            nose.tools.assert_almost_equal(sim_time_coupled[0], 0.0)
            nose.tools.assert_almost_equal(sim_time_coupled[-1],2.0)
            assert sim_time_coupled.all() >= sim_time_coupled[0] - 1e-4   #Check that the time is increasing
            assert sim_time_coupled.all() <= sim_time_coupled[-1] + 1e-4  #Give it some marginal

            #val_J1 = res_coupled['J1.w']
            #val_J2 = res_coupled['J2.w']
            #val_J3 = res_coupled['J3.w']
            #val_J4 = res_coupled['J4.w']

            val=[res_coupled.final('J1.w'), res_coupled.final('J2.w'), res_coupled.final('J3.w'), res_coupled.final('J4.w')]
            if i>0: #check that the results stays the same
                for j in range(len(val)):
                    nose.tools.assert_almost_equal(val[j], val_old[j])
            val_old = val
            coupled.reset()
        
        """
        #Compare to something we know is correct
        cs1_model = load_fmu('Modelica_Mechanics_Rotational_Examples_CoupledClutches_CS.fmu',path_to_fmus_cs1)
        res1 = cs1_model.simulate(final_time=10, options={'result_file_name':'result1'})
        self._coupledCS2 = load_fmu(CoupledCS2, path_to_fmus_cs2)
        res2 = self._coupledCS2.simulate(final_time=10, options={'result_file_name':'result2'})
        diff1 = res1.final("J1.w") - res2.final("J1.w")
        diff2 = res1.final("J2.w") - res2.final("J2.w")
        diff3 = res1.final("J3.w") - res2.final("J3.w")
        diff4 = res1.final("J4.w") - res2.final("J4.w")
        nose.tools.assert_almost_equal(abs(diff1), 0.000, 1)
        nose.tools.assert_almost_equal(abs(diff2), 0.000, 1)
        nose.tools.assert_almost_equal(abs(diff3), 0.000, 1)
        nose.tools.assert_almost_equal(abs(diff4), 0.000, 1)
        """
        
    @testattr(windows_full = True)
    def test_simulate_extern(self):
        """
        Test the method simulate in FMUModelCS2 on FMU SDK bouncing ball
        """
        bounce  = load_fmu(fmu=CS2, path=path_to_fmus_cs2)

        #Try simulate the bouncing ball
        res = bounce.simulate()
        sim_time = res['time']
        nose.tools.assert_almost_equal(sim_time[0], 0.0)
        nose.tools.assert_almost_equal(sim_time[-1], 1.0)
        bounce.reset()

        for i in range(5):
            res = bounce.simulate(start_time=0.1, final_time=1.0, options={'ncp':500})
            sim_time = res['time']
            nose.tools.assert_almost_equal(sim_time[0], 0.1)
            nose.tools.assert_almost_equal(sim_time[-1],1.0)
            assert sim_time.all() >= sim_time[0] - 1e-4   #Check that the time is increasing
            assert sim_time.all() <= sim_time[-1] + 1e-4  #Give it some marginal
            height = res['h']
            assert height.all() >= -1e-4 #The height of the ball should be non-negative
            nose.tools.assert_almost_equal(res.final('h'), 0.40479334288121899, 4)
            if i>0: #check that the results stays the same
                diff = height_old - height
                nose.tools.assert_almost_equal(diff[-1],0.0)
            height_old = height
            bounce.reset()

    @testattr(stddist_full = True)
    def test_simulate_options(self):
        """
        Test the method simultaion_options in FMUModelCS2
        """
        #Do the setUp
        coupled = load_fmu(self.coupled_name)

        #Test the result file
        res = coupled.simulate(options={"result_handling":"file"})
        assert res.result_file == coupled.get_identifier()+'_result.txt'
        assert os.path.exists(res.result_file)

        coupled.reset()
        opts = {'result_file_name':'Modelica_Mechanics_Rotational_Examples_CoupledClutches_result_test.txt'}
        res = coupled.simulate(options=opts)
        assert res.result_file == 'Modelica_Mechanics_Rotational_Examples_CoupledClutches_result_test.txt'
        assert os.path.exists(res.result_file)

        #Test the option in the simulate method
        coupled.reset()
        opts={}
        opts['ncp'] = 250
        opts['initialize'] = False
        
        coupled.setup_experiment()
        coupled.initialize()
        res = coupled.simulate(options=opts)
        assert len(res['time']) == 251


class Test_FMUModelME2:
    """
    This class tests pyfmi.fmi.FMUModelME2
    """
    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        cls.coupled_name = compile_fmu("Modelica.Mechanics.Rotational.Examples.CoupledClutches", target="me", version="2.0", compiler_options={'eliminate_alias_constants':False})
        cls.bouncing_name = compile_fmu("BouncingBall",os.path.join(path_to_mofiles,"BouncingBall.mo"), target="me", version="2.0", compiler_options={'eliminate_alias_constants':False})
        cls.output2_name = compile_fmu("OutputTest2",os.path.join(path_to_mofiles,"OutputTest.mo"), target="me", version="2.0")
        cls.no_state_name = compile_fmu("NoState.Example1", os.path.join(path_to_mofiles,"noState.mo"), target="me", version="2.0")
        cls.enum_name = compile_fmu("Enumerations.Enumeration2", os.path.join(path_to_mofiles,"Enumerations.mo"), target="me", version="2.0")    
        cls.string1 = compile_fmu("StringModel1",os.path.join(path_to_mofiles,"TestString.mo"), target="me", version="2.0")
        cls.linear2 = compile_fmu("LinearTest.Linear2", os.path.join(path_to_mofiles,"Linear.mo"), target="me", version="2.0")
        
    def _get_discrete_inputs_results(self, model_name):
        """ 
            Used by test_model_bool_input_pre_operator_without_edge
            and
            test_model_bool_input_pre_operator_with_edge
        """
        rtol = 1e-6
        atol = rtol
        ncp = 500
        libpaths = [os.path.join(get_files_path(), 'Modelica', 'DiscreteInputTestModels.mo')]
        n = compile_fmu(model_name,
                        libpaths,
                        jvm_args='-Xmx6g')

        m = load_fmu(n)

        start = 0.400
        stop = 0.405

        m.initialize(start_time=start, tolerance=rtol)
        m.event_update()
        m.enter_continuous_time_mode()

        opts = m.simulate_options()

        opts["initialize"] = False
        opts["CVode_options"]["rtol"] = rtol
        opts["CVode_options"]["atol"] = atol
        opts['ncp'] = ncp

        ts = []
        inp = [True]
        results = []
        m.set("Bool_A", True)

        for h in N.linspace(start, stop, 21)[:-1]:
            ts.append(h)
            inp.append(not inp[-1])
            
            m.enter_event_mode()
            m.set("Bool_B", inp[-1])
            m.event_update()
            m.enter_continuous_time_mode()
            res_jm = m.simulate(h, h+0.00025, options=opts)
            
            results.extend(res_jm["Real_B"])
        
        return results


    def _discrete_inputs_get_reference_data(self, path_to_reference_data):
        """ 
            Used by test_model_bool_input_pre_operator_without_edge
            and
            test_model_bool_input_pre_operator_with_edge
        """
        ref_values = []
        with open(path_to_reference_data, 'r') as f:
            ref_values = f.readlines()

        # remove all newlines and convert elements to float since they are strings
        ref_values = map(lambda s: s.strip(), ref_values)
        ref_values = [float(x) for x in ref_values]
        return ref_values
    
    @testattr(stddist_full = True)
    def test_model_bool_input_pre_operator_without_edge(self):
        """Test boolean inputs used in a pre operator and without using edge"""
        model_name = 'DiscreteInputTestModels.boolInputInPreOperatorWithoutEdge'
        results_no_edge = self._get_discrete_inputs_results(model_name)

        path_to_reference_data = os.path.join(get_files_path(), 'Modelica', 'DiscreteInputTestValues.txt')
        ref_values = self._discrete_inputs_get_reference_data(path_to_reference_data)

        assert N.amax(N.array(ref_values) - results_no_edge) == 0.0

    @testattr(stddist_full = True)
    def test_model_bool_input_pre_operator_with_edge(self):
        """Test boolean inputs used in a pre operator and using edge"""
        model_name = 'DiscreteInputTestModels.boolInputInPreOperatorWithEdge'
        results_with_edge = self._get_discrete_inputs_results(model_name)

        path_to_reference_data = os.path.join(get_files_path(), 'Modelica', 'DiscreteInputTestValues.txt')
        ref_values = self._discrete_inputs_get_reference_data(path_to_reference_data)

        assert N.amax(N.array(ref_values) - results_with_edge) == 0.0

    @testattr(stddist_full = True)
    def test_relative_tolerance(self):
        model = load_fmu(self.linear2)
        
        opts = model.simulate_options()
        opts["CVode_options"]["rtol"] = 1e-8
        
        res = model.simulate(options=opts)
        
        assert res.options["CVode_options"]["atol"] == 1e-10
        
        model = load_fmu(self.no_state_name)
        
        opts = model.simulate_options()
        opts["CVode_options"]["rtol"] = 1e-8
        
        res = model.simulate(options=opts)
        
        assert res.options["CVode_options"]["atol"] == 1e-10
    
    @testattr(stddist_full = True)
    def test_get_time_varying_variables(self):
        model = load_fmu(self.coupled_name)
        
        [r,i,b] = model.get_model_time_varying_value_references()
        [r_f, i_f, b_f] = model.get_model_time_varying_value_references(filter="*")
        
        assert len(r) == len(r_f)
        assert len(i) == len(i_f)
        assert len(b) == len(b_f)
        
        vars = model.get_variable_alias("J4.phi")
        for var in vars:
            [r,i,b] = model.get_model_time_varying_value_references(filter=var)
            assert len(r) == 1
        
        [r,i,b] = model.get_model_time_varying_value_references(filter=vars.keys())
        assert len(r) == 1
    
    @testattr(stddist_full = True)
    def test_get_string(self):
        model = load_fmu(self.string1)
        
        for i in range(100): #Test so that memory issues are detected
            assert model.get("str")[0] == "hej"
    
    @testattr(stddist_full = True)
    def test_estimate_directional_derivatives_A(self):
        
        model = load_fmu(self.coupled_name)
        model.initialize()
        model.event_update()
        model.enter_continuous_time_mode()
        
        A = model._get_A(use_structure_info=True)
        B = model._get_A(use_structure_info=True, output_matrix=A)
        assert A is B #Test that the returned matrix is actually the same as the input
        N.allclose(A.toarray(),B.toarray())
        A = model._get_A(use_structure_info=False)
        B = model._get_A(use_structure_info=False, output_matrix=A)
        assert A is B
        N.allclose(A,B)
        C = model._get_A(use_structure_info=True, output_matrix=A)
        assert A is not C
        N.allclose(C.toarray(), A)
        D = model._get_A(use_structure_info=False, output_matrix=C)
        assert D is not C
        N.allclose(D, C.toarray())
    
    @testattr(stddist_full = True)
    def test_estimate_directional_derivatives_BCD(self):
        
        model = load_fmu(self.output2_name)
        model.initialize()
        model.event_update()
        model.enter_continuous_time_mode()
        
        for func in [model._get_B, model._get_C, model._get_C]:
            A = func(use_structure_info=True)
            B = func(use_structure_info=True, output_matrix=A)
            assert A is B #Test that the returned matrix is actually the same as the input
            N.allclose(A.toarray(),B.toarray())
            A = func(use_structure_info=False)
            B = func(use_structure_info=False, output_matrix=A)
            assert A is B
            N.allclose(A,B)
            C = func(use_structure_info=True, output_matrix=A)
            assert A is not C
            N.allclose(C.toarray(), A)
            D = func(use_structure_info=False, output_matrix=C)
            assert D is not C
            N.allclose(D, C.toarray())
    
    @testattr(stddist_full = True)
    def test_units(self):
        
        model = load_fmu(self.coupled_name)
        model_bb = load_fmu(self.bouncing_name)
        
        assert model.get_variable_unit("J1.w") == "rad/s"
        assert model.get_variable_unit("J1.phi") == "rad"
        
        nose.tools.assert_raises(FMUException, model.get_variable_unit, "clutch1.useHeatPort")
        nose.tools.assert_raises(FMUException, model.get_variable_unit, "clutch1.sss")
        nose.tools.assert_raises(FMUException, model.get_variable_unit, "clutch1.sss")
        nose.tools.assert_raises(FMUException, model_bb.get_variable_unit, "h")
    
    @testattr(stddist_full = True)
    def test_display_units(self):
        
        model = load_fmu(self.coupled_name)
        
        assert model.get_variable_display_unit("J1.phi") == "deg"
        nose.tools.assert_raises(FMUException, model.get_variable_display_unit, "J1.w")
        
    @testattr(stddist_full = True)
    def test_display_values(self):
        model = load_fmu(self.coupled_name)
        
        import scipy
        
        val = model.get_variable_display_value("J1.phi")
        val_ref = scipy.rad2deg(model.get("J1.phi"))
        
        nose.tools.assert_almost_equal(val, val_ref)
        
        model.simulate()
        
        val = model.get_variable_display_value("J1.phi")
        val_ref = scipy.rad2deg(model.get("J1.phi"))
        
        nose.tools.assert_almost_equal(val, val_ref)
    
    @testattr(stddist_full = True)
    def test_get_enum(self):
        model = load_fmu(self.enum_name)
        
        assert model.get("one") == 1
        
        model.set("one", 2)
        assert model.get("one") == 2

    @testattr(windows_full = True)
    def test_malformed_xml(self):
        nose.tools.assert_raises(FMUException, load_fmu, os.path.join(path_to_fmus_me2, "MalFormed.fmu"))

    @testattr(stddist_full = True)
    def test_log_file_name(self):
        path, file_name = os.path.split(self.coupled_name)
        coupled = load_fmu(self.coupled_name)
        
        assert coupled.get_log_file_name() == file_name.replace(".","_")[:-4]+"_log.txt"
    
    @testattr(stddist_full = True)
    def test_version(self):
        bounce = load_fmu(self.bouncing_name)
        assert bounce.get_version() == "2.0"
        
        coupled = load_fmu(self.coupled_name)
        assert coupled.get_version() == "2.0"
        
    @testattr(stddist_full = True)
    def test_variable_initial(self):
        coupled = load_fmu(self.coupled_name)
        
        assert coupled.get_variable_initial("sin1.y") == fmi.FMI2_INITIAL_CALCULATED
        vars = coupled.get_model_variables()
        assert vars["sin1.y"].initial == fmi.FMI2_INITIAL_CALCULATED
        
    
    @testattr(windows_full = True)
    def test_init(self):
        """
        Test the method __init__ in FMUModelME2
        """
        bounce = load_fmu(self.bouncing_name)

        assert bounce.get_identifier() == 'BouncingBall'
        nose.tools.assert_raises(FMUException, FMUModelME2, fmu=CS2, path=path_to_fmus_cs2)
        nose.tools.assert_raises(FMUException, FMUModelME2, fmu=CS1, path=path_to_fmus_cs1)
        nose.tools.assert_raises(FMUException, FMUModelME2, fmu=ME1, path=path_to_fmus_me1)

    @testattr(stddist_full = True)
    def test_instantiate_model(self):
        """
        Test the method instantiate_model in FMUModelME2
        """
        for i in range(5):
            bounce = load_fmu(self.bouncing_name)

    @testattr(stddist_full = True)
    def test_initialize(self):
        """
        Test the method initialize in FMUModelME2
        """
        bounce = load_fmu(self.bouncing_name)
        
        bounce.setup_experiment()
        bounce.initialize()
        nose.tools.assert_almost_equal(bounce.time, 0.0)

        bounce.reset()
        bounce.setup_experiment(tolerance=1e-7)
        bounce.initialize()

    @testattr(stddist_full = True)
    def test_reset(self):
        """
        Test the method reset in FMUModelME2
        """
        bounce = load_fmu(self.bouncing_name)

        bounce.setup_experiment()
        bounce.initialize()

        bounce.reset()

        assert bounce.time is None

    @testattr(stddist_full = True)
    def test_terminate(self):
        """
        Test the method terminate in FMUModelME2
        """
        coupled = load_fmu(self.coupled_name)
        
        coupled.setup_experiment()
        coupled.initialize()
        coupled.terminate()

    @testattr(stddist_full = True)
    def test_time(self):
        """
        Test the method get/set_time in FMUModelME2
        """
        bounce = load_fmu(self.bouncing_name)

        bounce.reset() #Currently results in a seg fault
        assert bounce.time is None
        
        bounce.setup_experiment()
        bounce.initialize()
        
        nose.tools.assert_almost_equal(bounce._get_time(), 0.0)
        bounce._set_time(2.71)
        nose.tools.assert_almost_equal(bounce.time , 2.71)
        bounce._set_time(1.00)
        nose.tools.assert_almost_equal(bounce._get_time() , 1.00)

        nose.tools.assert_raises(TypeError, bounce._set_time, '2.0')
        nose.tools.assert_raises(TypeError, bounce._set_time, N.array([1.0, 1.0]))

    @testattr(stddist_full = True)
    def test_get_event_info(self):
        """
        Test the method get_event_info in FMUModelME2
        """
        bounce = load_fmu(self.bouncing_name)
        
        bounce.setup_experiment()
        bounce.initialize()
        
        event = bounce.get_event_info()
        assert isinstance(event, PyEventInfo)

        assert event.newDiscreteStatesNeeded           == False
        assert event.nominalsOfContinuousStatesChanged == False
        assert event.valuesOfContinuousStatesChanged   == True
        assert event.terminateSimulation               == False
        assert event.nextEventTimeDefined              == False
        assert event.nextEventTime                     == 0.0

    @testattr(stddist_full = True)
    def test_get_event_indicators(self):
        """
        Test the method get_event_indicators in FMUModelME2
        """
        bounce = load_fmu(self.bouncing_name)
        coupled = load_fmu(self.coupled_name)
        
        bounce.setup_experiment()
        bounce.initialize()
        
        coupled.setup_experiment()
        coupled.initialize()

        assert len(bounce.get_event_indicators()) == 1
        assert len(coupled.get_event_indicators()) == 33

        event_ind = bounce.get_event_indicators()
        nose.tools.assert_almost_equal(event_ind[0],10.000000)
        bounce.continuous_states = N.array([5.]*2)
        event_ind = bounce.get_event_indicators()
        nose.tools.assert_almost_equal(event_ind[0],5.000000)

    @testattr(stddist_full = True)
    def test_get_tolerances(self):
        """
        Test the method get_tolerances in FMUModelME2
        """
        bounce = load_fmu(self.bouncing_name)
        
        bounce.setup_experiment()
        bounce.initialize()

        [rtol,atol] = bounce.get_tolerances()

        assert rtol == 0.0001
        nose.tools.assert_almost_equal(atol[0],0.0000010)
        nose.tools.assert_almost_equal(atol[1],0.0000010)

    @testattr(stddist_full = True)
    def test_continuous_states(self):
        """
        Test the method get/set_continuous_states in FMUModelME2
        """
        bounce = load_fmu(self.bouncing_name)
        coupled = load_fmu(self.coupled_name)
        
        bounce.setup_experiment()
        bounce.initialize()
        
        coupled.setup_experiment()
        coupled.initialize()

        nx = bounce.get_ode_sizes()[0]
        states = bounce._get_continuous_states()
        assert nx == len(states)

        nose.tools.assert_almost_equal(states[0],10.000000)
        nose.tools.assert_almost_equal(states[1],0.000000)

        bounce.continuous_states = N.array([2.,-3.])
        states = bounce.continuous_states

        nose.tools.assert_almost_equal(states[0],2.000000)
        nose.tools.assert_almost_equal(states[1],-3.000000)

        n_states=bounce._get_nominal_continuous_states()
        assert nx == len(n_states)
        nose.tools.assert_almost_equal(n_states[0], 1.000000)
        nose.tools.assert_almost_equal(n_states[1], 1.000000)


        nx = coupled.get_ode_sizes()[0]
        states = coupled._get_continuous_states()
        assert nx == len(states)
        coupled._set_continuous_states(N.array([5.]*nx))
        states = coupled.continuous_states
        nose.tools.assert_almost_equal(states[-1], 5.000000)

        n_states=coupled._get_nominal_continuous_states()
        nose.tools.assert_almost_equal(n_states[0], 0.0001)
        n_states=coupled.nominal_continuous_states
        nose.tools.assert_almost_equal(n_states[0], 0.0001)

    @testattr(stddist_full = True)
    def test_output_dependencies(self):
        model = load_fmu(self.output2_name)
        
        [state_dep, input_dep] = model.get_output_dependencies()
        
        assert state_dep["y1"][0] == "x1"
        assert state_dep["y1"][1] == "x2"
        assert state_dep["y2"][0] == "x2"
        assert state_dep["y3"][0] == "x1"
        assert input_dep["y1"][0] == "u1"
        assert input_dep["y3"][0] == "u1"
        assert len(input_dep["y2"]) == 0
        
    @testattr(stddist_full = True)
    def test_output_dependencies_2(self):
        model = load_fmu(self.coupled_name)
        
        [state_dep, input_dep] = model.get_output_dependencies()
        
        assert len(state_dep.keys()) == 0
        assert len(input_dep.keys()) == 0
        
    @testattr(stddist_full = True)
    def test_derivative_dependencies(self):
        model = load_fmu(self.no_state_name)
        
        [state_dep, input_dep] = model.get_derivatives_dependencies()
        
        assert len(state_dep.keys()) == 0
        assert len(input_dep.keys()) == 0

    @testattr(stddist_full = True)
    def test_get_derivatives(self):
        """
        Test the method get_derivatives in FMUModelME2
        """
        bounce = load_fmu(self.bouncing_name)
        coupled = load_fmu(self.coupled_name)
        
        bounce.setup_experiment()
        bounce.initialize()
        
        coupled.setup_experiment()
        coupled.initialize()

        nx = bounce.get_ode_sizes()[0]
        der=bounce.get_derivatives()
        assert nx == len(der)

        nose.tools.assert_almost_equal(der[0], 0.000000)
        nose.tools.assert_almost_equal(der[1], -9.820000)

        bounce.continuous_states = N.array([5.0, 2.0])
        der=bounce.get_derivatives()
        nose.tools.assert_almost_equal(der[0], 2.000000)

        der_list = coupled.get_derivatives_list()
        der_ref  = N.array([s.value_reference for s in der_list.values()])
        der = coupled.get_derivatives()
        diff = N.sort(N.array([coupled.get_real(i) for i in der_ref]))-N.sort(der)
        nose.tools.assert_almost_equal(N.sum(diff), 0.)

    @testattr(stddist_full = True)
    def test_get_directional_derivative_capability(self):
        """
        Test the method get_directional_derivative in FMUModelME2
        """
        
        # Setup
        bounce = load_fmu(self.bouncing_name)
        bounce.setup_experiment()
        bounce.initialize()
        
        # Bouncing ball don't have the capability, check that this is handled
        nose.tools.assert_raises(FMUException, bounce.get_directional_derivative, [1], [1], [1])
        
        
    @testattr(stddist_full = True)
    def test_simulate_with_debug_option(self):
        coupled = load_fmu(self.coupled_name)

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
    def test_simulate_options(self):
        """
        Test the method simulate_options in FMUModelME2
        """
        coupled = load_fmu(self.coupled_name)

        opts=coupled.simulate_options()
        assert opts['initialize']
        assert opts['with_jacobian'] == "Default"
        assert opts['ncp'] == 0

        #Test the result file
        res=coupled.simulate(options={"result_handling":"file"})
        assert res.result_file == coupled.get_identifier()+'_result.txt'
        assert os.path.exists(res.result_file)

        coupled.reset()
        opts = {'result_file_name':'Modelica_Mechanics_Rotational_Examples_CoupledClutches_result_test.txt'}
        res=coupled.simulate(options=opts)
        assert res.result_file == 'Modelica_Mechanics_Rotational_Examples_CoupledClutches_result_test.txt'
        assert os.path.exists(res.result_file)

        #Test the option in the simulate method
        coupled.reset()
        opts={}
        opts['ncp'] = 250
        opts['initialize'] = False
        
        coupled.setup_experiment()
        coupled.initialize()
        coupled.event_update()
        coupled.enter_continuous_time_mode()
        res=coupled.simulate(options=opts)
        assert len(res['time']) > 250
    
    @testattr(stddist_full = True)
    def test_simulate(self):
        """
        Test the method simulate in FMUModelME2
        """
        bounce  = load_fmu(self.bouncing_name)
        coupled = load_fmu(self.coupled_name)

        #Try simulate the bouncing ball
        res=bounce.simulate()
        sim_time = res['time']
        nose.tools.assert_almost_equal(sim_time[0], 0.0)
        nose.tools.assert_almost_equal(sim_time[-1], 1.0)
        bounce.reset()

        opts = bounce.simulate_options()
        opts["CVode_options"]["rtol"] = 1e-6
        opts["CVode_options"]["atol"] = 1e-6
        opts["ncp"] = 500

        for i in range(5):
            res=bounce.simulate(start_time=0.1, final_time=1.0, options=opts)
            sim_time = res['time']
            nose.tools.assert_almost_equal(sim_time[0], 0.1)
            nose.tools.assert_almost_equal(sim_time[-1],1.0)
            assert sim_time.all() >= sim_time[0] - 1e-4   #Check that the time is increasing
            assert sim_time.all() <= sim_time[-1] + 1e-4  #Give it some marginal
            height = res['h']
            assert height.all() >= -1e-4 #The height of the ball should be non-negative
            nose.tools.assert_almost_equal(res.final('h'), 6.0228998448008104, 4)
            if i>0: #check that the results stays the same
                diff = height_old - height
                nose.tools.assert_almost_equal(diff[-1],0.0)
            height_old = height
            bounce.reset()

        #Try to simulate the coupled-clutches
        res_coupled=coupled.simulate()
        sim_time_coupled = res_coupled['time']
        nose.tools.assert_almost_equal(sim_time_coupled[0], 0.0)
        nose.tools.assert_almost_equal(sim_time_coupled[-1], 1.5)
        coupled.reset()


        for i in range(10):
            res_coupled = coupled.simulate(start_time=0.0, final_time=2.0)
            sim_time_coupled = res_coupled['time']
            nose.tools.assert_almost_equal(sim_time_coupled[0], 0.0)
            nose.tools.assert_almost_equal(sim_time_coupled[-1],2.0)
            assert sim_time_coupled.all() >= sim_time_coupled[0] - 1e-4   #Check that the time is increasing
            assert sim_time_coupled.all() <= sim_time_coupled[-1] + 1e-4  #Give it some marginal

            #val_J1 = res_coupled['J1.w']
            #val_J2 = res_coupled['J2.w']
            #val_J3 = res_coupled['J3.w']
            #val_J4 = res_coupled['J4.w']

            val=[res_coupled.final('J1.w'), res_coupled.final('J2.w'), res_coupled.final('J3.w'), res_coupled.final('J4.w')]
            if i>0: #check that the results stays the same
                for j in range(len(val)):
                    nose.tools.assert_almost_equal(val[j], val_old[j])
            val_old = val
            coupled.reset()
        
        """
        #Compare to something we know is correct
        me1_model = load_fmu('Modelica_Mechanics_Rotational_Examples_CoupledClutches_ME.fmu',path_to_fmus_me1)
        res1 = me1_model.simulate(final_time=2., options={'result_file_name':'result1'})
        coupled = load_fmu(CoupledME2, path_to_fmus_me2)
        res2 = coupled.simulate(final_time=2., options={'result_file_name':'result2'})
        diff1 = res1.final("J1.w") - res2.final("J1.w")
        diff2 = res1.final("J2.w") - res2.final("J2.w")
        diff3 = res1.final("J3.w") - res2.final("J3.w")
        diff4 = res1.final("J4.w") - res2.final("J4.w")
        nose.tools.assert_almost_equal(abs(diff1), 0.0000, 2)
        nose.tools.assert_almost_equal(abs(diff2), 0.0000, 2)
        nose.tools.assert_almost_equal(abs(diff3), 0.0000, 2)
        nose.tools.assert_almost_equal(abs(diff4), 0.0000, 2)
        """
        
    @testattr(windows_full = True)
    def test_simulate_extern(self):
        """
        Test the method simulate in FMUModelME2 on FMU SDK bouncing ball
        """
        bounce  = load_fmu(fmu=ME2, path=path_to_fmus_me2)

        #Try simulate the bouncing ball
        res = bounce.simulate()
        sim_time = res['time']
        nose.tools.assert_almost_equal(sim_time[0], 0.0)
        nose.tools.assert_almost_equal(sim_time[-1], 1.0)
        bounce.reset()

        opts = bounce.simulate_options()
        opts["CVode_options"]["rtol"] = 1e-6
        opts["CVode_options"]["atol"] = 1e-6
        opts["ncp"] = 500

        for i in range(5):
            res=bounce.simulate(start_time=0.1, final_time=1.0, options=opts)
            sim_time = res['time']
            nose.tools.assert_almost_equal(sim_time[0], 0.1)
            nose.tools.assert_almost_equal(sim_time[-1],1.0)
            assert sim_time.all() >= sim_time[0] - 1e-4   #Check that the time is increasing
            assert sim_time.all() <= sim_time[-1] + 1e-4  #Give it some marginal
            height = res['h']
            assert height.all() >= -1e-4 #The height of the ball should be non-negative
            nose.tools.assert_almost_equal(res.final('h'), 0.40400192742719998, 4)
            if i>0: #check that the results stays the same
                diff = height_old - height
                nose.tools.assert_almost_equal(diff[-1],0.0)
            height_old = height
            bounce.reset()


class Test_Result_Writing:
    """
    This test the result writing functionality.
    """
    @classmethod
    def setUpClass(cls):
        file_name = os.path.join(get_files_path(), 'Modelica', 'Friction.mo')
        cls.enum_name = compile_fmu("Friction2", file_name, target="me", version="2.0")
        
    @testattr(stddist_full = True)
    def test_enumeration_file(self):
        
        model = load_fmu(self.enum_name)
        data_type = model.get_variable_data_type("mode")
        
        assert data_type == fmi.FMI2_ENUMERATION
        
        opts = model.simulate_options()
        
        res = model.simulate(options=opts)
        res["mode"] #Check that the enumeration variable is in the dict, otherwise exception
        
    @testattr(stddist_full = True)
    def test_enumeration_memory(self):
        
        model = load_fmu(self.enum_name)
        data_type = model.get_variable_data_type("mode")
        
        assert data_type == fmi.FMI2_ENUMERATION
        
        opts = model.simulate_options()
        opts["result_handling"] = "memory"
        
        res = model.simulate(options=opts)
        res["mode"] #Check that the enumeration variable is in the dict, otherwise exception
        
    @testattr(stddist_full = True)
    def test_enumeration_csv(self):
        
        model = load_fmu(self.enum_name)
        data_type = model.get_variable_data_type("mode")
        
        assert data_type == fmi.FMI2_ENUMERATION
        
        from pyfmi.common.io import ResultHandlerCSV
        opts = model.simulate_options()
        opts["result_handling"] = "custom"
        opts["result_handler"] = ResultHandlerCSV(model)
        
        res = model.simulate(options=opts)
        res["mode"] #Check that the enumeration variable is in the dict, otherwise exception
        

class Test_load_fmu2:
    """
    This test the functionality of load_fmu method.
    """
    @testattr(windows_full = True)
    def test_raise_exception(self):
        """
        This method tests the error-handling of load_fmu
        """
        nose.tools.assert_raises(FMUException, load_fmu, 'not_an_fmu.txt', path_to_fmus)                      #loading non-fmu file
        nose.tools.assert_raises(FMUException, load_fmu, 'not_existing_file.fmu', path_to_fmus_me2)           #loading non-existing file
        #nose.tools.assert_raises(FMUException, load_fmu, 'not_a_.fmu', path_to_fmus)                          #loading a non-real fmu
        nose.tools.assert_raises(FMUException, load_fmu, fmu=ME2, path=path_to_fmus_me2, kind='invalid_kind') #loading fmu with wrong argument
        nose.tools.assert_raises(FMUException, load_fmu, fmu=ME1, path=path_to_fmus_me1, kind='CS')           #loading ME1-model as a CS-model
        nose.tools.assert_raises(FMUException, load_fmu, fmu=CS1, path=path_to_fmus_cs1, kind='ME')           #loading CS1-model as ME-model
        nose.tools.assert_raises(FMUException, load_fmu, fmu=ME2, path=path_to_fmus_me2, kind='CS')           #loading ME2-model as a CS-model
        nose.tools.assert_raises(FMUException, load_fmu, fmu=CS2, path=path_to_fmus_cs2, kind='ME')           #loading CS2-model as ME-model

    @testattr(windows_full = True)
    def test_correct_loading(self):
        """
        This method tests the correct loading of FMUs
        """
        model = load_fmu(fmu=ME2, path=path_to_fmus_me2, kind='auto') #loading ME2-model correct
        assert isinstance(model, FMUModelME2)
        model = load_fmu(fmu=ME2, path=path_to_fmus_me2, kind='me')   #loading ME2-model correct
        assert isinstance(model, FMUModelME2)
        model = load_fmu(fmu=CS2, path=path_to_fmus_cs2, kind='auto') #loading CS2-model correct
        assert isinstance(model, FMUModelCS2)
        model = load_fmu(fmu=CS2, path=path_to_fmus_cs2, kind='cs')   #loading CS2-model correct
        assert isinstance(model, FMUModelCS2)


