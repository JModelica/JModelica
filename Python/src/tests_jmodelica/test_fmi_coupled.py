#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (C) 2017 Modelon AB
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
Module containing the tests for the coupled FMI classes.
"""

import nose
import os
import numpy as N
import sys as S

from tests_jmodelica import testattr, get_files_path
from pymodelica.compiler import compile_fmu
from pyfmi import CoupledFMUModelME2
from pyfmi import load_fmu
import pyfmi.fmi as fmi

path_to_fmus = os.path.join(get_files_path(), 'FMUs')
path_to_mofiles = os.path.join(get_files_path(), 'Modelica')

path_to_fmus_me2 = os.path.join(path_to_fmus,"ME2.0")
path_to_fmus_cs2 = os.path.join(path_to_fmus,"CS2.0")



class Test_CoupledFMUModelME2:
    """
    This class tests pyfmi.fmi_coupled.CoupledFMUModelME2
    """

    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        cls.cc_name = compile_fmu("Modelica.Mechanics.Rotational.Examples.CoupledClutches", version=2.0)
        
        cls.ls_full = compile_fmu("LinearStability.FullSystem" , os.path.join(path_to_mofiles,"CoupledME.mo"), version=2.0)
        cls.ls_sub1 = compile_fmu("LinearStability.SubSystem1" , os.path.join(path_to_mofiles,"CoupledME.mo"), version=2.0)
        cls.ls_sub2 = compile_fmu("LinearStability.SubSystem2" , os.path.join(path_to_mofiles,"CoupledME.mo"), version=2.0)
        
        cls.ls_event_full = compile_fmu("LinearStability.FullSystemWithEvents" , os.path.join(path_to_mofiles,"CoupledME.mo"), version=2.0)
        cls.ls_event_sub1 = compile_fmu("LinearStability.SubSystemWithEvents1" , os.path.join(path_to_mofiles,"CoupledME.mo"), version=2.0)
        cls.ls_event_sub2 = compile_fmu("LinearStability.SubSystemWithEvents2" , os.path.join(path_to_mofiles,"CoupledME.mo"), version=2.0)
        
        cls.ls_event_full_v2 = compile_fmu("LinearStability.FullSystemWithEvents_v2" , os.path.join(path_to_mofiles,"CoupledME.mo"), version=2.0)
        cls.ls_event_sub1_v2 = compile_fmu("LinearStability.SubSystemWithEvents1_v2" , os.path.join(path_to_mofiles,"CoupledME.mo"), version=2.0)
        cls.ls_event_sub2_v2 = compile_fmu("LinearStability.SubSystemWithEvents2_v2" , os.path.join(path_to_mofiles,"CoupledME.mo"), version=2.0)
        
        cls.qc_full = compile_fmu("QuarterCar.QuarterCarComplete", os.path.join(path_to_mofiles,"CoupledME.mo"), version="2.0")
        cls.qc_sub1 = compile_fmu("QuarterCar.QuarterCarWithoutFeedThrough1", os.path.join(path_to_mofiles,"CoupledME.mo"),version="2.0")
        cls.qc_sub2 = compile_fmu("QuarterCar.QuarterCarWithoutFeedThrough2", os.path.join(path_to_mofiles,"CoupledME.mo"),version="2.0")
        
        cls.piplant = compile_fmu("PIPlant", os.path.join(path_to_mofiles,"CoupledME.mo"), version="2.0")
        cls.pi      = compile_fmu("PI",      os.path.join(path_to_mofiles,"CoupledME.mo"), version="2.0")
        cls.plant   = compile_fmu("Plant",   os.path.join(path_to_mofiles,"CoupledME.mo"), version="2.0")
        
    @testattr(stddist_full = True)
    def test_loading(self):
        
        model_cc_1 = load_fmu(Test_CoupledFMUModelME2.cc_name)
        model_cc_2 = load_fmu(Test_CoupledFMUModelME2.cc_name)
        
        models = [model_cc_1, model_cc_2]
        connections = []
        
        nose.tools.assert_raises(fmi.FMUException, CoupledFMUModelME2, models, connections)
        
        models = [("First", model_cc_1), model_cc_2]
        nose.tools.assert_raises(fmi.FMUException, CoupledFMUModelME2, models, connections)
        
        models = [("First", model_cc_1), ("First", model_cc_2)]
        nose.tools.assert_raises(fmi.FMUException, CoupledFMUModelME2, models, connections)
        
        models = [("First", model_cc_1), ("Second", model_cc_2)]
        coupled = CoupledFMUModelME2(models, connections)
        
        connections = [("k")]
        nose.tools.assert_raises(fmi.FMUException, CoupledFMUModelME2, models, connections)
        
        connections = [(model_cc_1, "J1.phi", model_cc_2, "J2.phi")]
        nose.tools.assert_raises(fmi.FMUException, CoupledFMUModelME2, models, connections)
        
    @testattr(stddist_full = True)
    def test_basic_simulation(self):
        
        model_cc_1 = load_fmu(Test_CoupledFMUModelME2.cc_name)
        model_cc_2 = load_fmu(Test_CoupledFMUModelME2.cc_name)
        
        models = [("First", model_cc_1), ("Second", model_cc_2)]
        connections = []
        
        coupled = CoupledFMUModelME2(models, connections)
        
        res = coupled.simulate()
        
        nose.tools.assert_almost_equal(res.final("time"),1.5)
        nose.tools.assert_almost_equal(res.final("First.J1.w"),res.final("Second.J1.w"))
        nose.tools.assert_almost_equal(res.final("First.J1.w"), 3.2501079, places=3)
        
        coupled.reset()
        
        res = coupled.simulate()
        
        nose.tools.assert_almost_equal(res.final("time"),1.5)
        nose.tools.assert_almost_equal(res.final("First.J1.w"),res.final("Second.J1.w"))
        nose.tools.assert_almost_equal(res.final("First.J1.w"), 3.2501079, places=3)
        
    @testattr(stddist_full = True)
    def test_get_variable_valueref(self):
        
        model_cc_1 = load_fmu(Test_CoupledFMUModelME2.cc_name)
        model_cc_2 = load_fmu(Test_CoupledFMUModelME2.cc_name)
        
        models = [("First", model_cc_1), ("Second", model_cc_2)]
        connections = []
        
        coupled = CoupledFMUModelME2(models, connections)
        
        nose.tools.assert_raises(fmi.FMUException,  coupled.get_variable_valueref, "J1.w")
        
        vr_1 = coupled.get_variable_valueref("First.J1.w")
        vr_2 = coupled.get_variable_valueref("Second.J1.w")

        assert vr_1 != vr_2
        
        var_name_1 = coupled.get_variable_by_valueref(vr_1)
        var_name_2 = coupled.get_variable_by_valueref(vr_2)
        
        assert var_name_1 == "First.J1.w"
        assert var_name_2 == "Second.J1.w"
    
    @testattr(stddist_full = True)
    def test_ode_sizes(self):
        
        model_cc_1 = load_fmu(Test_CoupledFMUModelME2.cc_name)
        model_cc_2 = load_fmu(Test_CoupledFMUModelME2.cc_name)
        
        models = [("First", model_cc_1), ("Second", model_cc_2)]
        connections = []
        
        coupled = CoupledFMUModelME2(models, connections)
        
        [nbr_states, nbr_event_ind] = coupled.get_ode_sizes()
        
        assert nbr_states == 16
        assert nbr_event_ind == 66
        
    @testattr(stddist_full = True)
    def test_alias(self):
        
        model_cc_1 = load_fmu(Test_CoupledFMUModelME2.cc_name)
        model_cc_2 = load_fmu(Test_CoupledFMUModelME2.cc_name)
        
        models = [("First", model_cc_1), ("Second", model_cc_2)]
        connections = []
        
        coupled = CoupledFMUModelME2(models, connections)
        
        aliases = coupled.get_variable_alias("First.J4.phi")
        assert "First.J4.phi" in aliases.keys()
        assert coupled.get_variable_alias_base("First.J4.phi") == "First.J4.flange_a.phi"
        
    @testattr(stddist_full = True)
    def test_get_set_real(self):
        
        model_cc_1 = load_fmu(Test_CoupledFMUModelME2.cc_name)
        model_cc_2 = load_fmu(Test_CoupledFMUModelME2.cc_name)
        
        models = [("First", model_cc_1), ("Second", model_cc_2)]
        connections = []
        
        coupled = CoupledFMUModelME2(models, connections)
        
        nose.tools.assert_raises(fmi.FMUException,  coupled.get, "J1.w")
        
        coupled.set("First.J1.w", 3)
        coupled.set("Second.J1.w", 4)
        
        nose.tools.assert_almost_equal(coupled.get("First.J1.w"),3)
        nose.tools.assert_almost_equal(coupled.get("Second.J1.w"),4)
    
    @testattr(stddist_full = True)
    def test_variable_variability(self):
        
        model_cc_1 = load_fmu(Test_CoupledFMUModelME2.cc_name)
        model_cc_2 = load_fmu(Test_CoupledFMUModelME2.cc_name)
        
        models = [("First", model_cc_1), ("Second", model_cc_2)]
        connections = []
        
        coupled = CoupledFMUModelME2(models, connections)
        
        nose.tools.assert_raises(fmi.FMUException,  coupled.get_variable_variability, "J1.w")
        
        variability = coupled.get_variable_variability("First.J1.w")
        
        assert variability == model_cc_1.get_variable_variability("J1.w")
        
    @testattr(stddist_full = True)
    def test_variable_causality(self):
        
        model_cc_1 = load_fmu(Test_CoupledFMUModelME2.cc_name)
        model_cc_2 = load_fmu(Test_CoupledFMUModelME2.cc_name)
        
        models = [("First", model_cc_1), ("Second", model_cc_2)]
        connections = []
        
        coupled = CoupledFMUModelME2(models, connections)
        
        nose.tools.assert_raises(fmi.FMUException,  coupled.get_variable_causality, "J1.w")
        
        causality = coupled.get_variable_causality("First.J1.w")
        
        assert causality == model_cc_1.get_variable_causality("J1.w")
        
    @testattr(stddist_full = True)
    def test_model_variables(self):
        
        model_cc_1 = load_fmu(Test_CoupledFMUModelME2.cc_name)
        model_cc_2 = load_fmu(Test_CoupledFMUModelME2.cc_name)
        
        models = [("First", model_cc_1), ("Second", model_cc_2)]
        connections = []
        
        coupled = CoupledFMUModelME2(models, connections)
        
        vars = coupled.get_model_variables()
        vars_1 = model_cc_1.get_model_variables()
        vars_2 = model_cc_2.get_model_variables()
        
        assert len(vars) == len(vars_1) + len(vars_2)
        
        vars = coupled.get_model_variables(include_alias=False)
        vars_1 = model_cc_1.get_model_variables(include_alias=False)
        vars_2 = model_cc_2.get_model_variables(include_alias=False)
        
        assert len(vars) == len(vars_1) + len(vars_2)
        
        vars = coupled.get_model_variables(include_alias=False, type=fmi.FMI2_INTEGER)
        vars_1 = model_cc_1.get_model_variables(include_alias=False, type=fmi.FMI2_INTEGER)
        vars_2 = model_cc_2.get_model_variables(include_alias=False, type=fmi.FMI2_INTEGER)
        
        assert len(vars) == len(vars_1) + len(vars_2)

    @testattr(stddist_full = True)
    def test_states_list(self):
        
        model_cc_1 = load_fmu(Test_CoupledFMUModelME2.cc_name)
        model_cc_2 = load_fmu(Test_CoupledFMUModelME2.cc_name)
        
        models = [("First", model_cc_1), ("Second", model_cc_2)]
        connections = []
        
        coupled = CoupledFMUModelME2(models, connections)
        
        states = coupled.get_states_list()
        
        for state in states:
            assert state.startswith("First.") or state.startswith("Second.")
            var = coupled.get_variable_by_valueref(states[state].value_reference)
            alias_vars = coupled.get_variable_alias(var).keys()
            assert state in alias_vars
            
    @testattr(stddist_full = True)
    def test_derivatives_list(self):
        
        model_cc_1 = load_fmu(Test_CoupledFMUModelME2.cc_name)
        model_cc_2 = load_fmu(Test_CoupledFMUModelME2.cc_name)
        
        models = [("First", model_cc_1), ("Second", model_cc_2)]
        connections = []
        
        coupled = CoupledFMUModelME2(models, connections)
        
        states = coupled.get_derivatives_list()
        
        for state in states:
            assert state.startswith("First.") or state.startswith("Second.")
            var = coupled.get_variable_by_valueref(states[state].value_reference)
            alias_vars = coupled.get_variable_alias(var).keys()
            assert state in alias_vars

    @testattr(stddist_full = True)
    def test_reversed_connections(self):
        model_sub_1 = load_fmu(Test_CoupledFMUModelME2.ls_sub1)
        model_sub_2 = load_fmu(Test_CoupledFMUModelME2.ls_sub2)
        model_full  = load_fmu(Test_CoupledFMUModelME2.ls_full)
        
        models = [("First", model_sub_1), ("Second", model_sub_2)]
        connections = [(model_sub_2,"y1",model_sub_1,"u2"),
                       (model_sub_1,"y2",model_sub_2,"u1")]
        
        nose.tools.assert_raises(fmi.FMUException,  CoupledFMUModelME2, models, connections)
        
        connections = [(model_sub_2,"u2",model_sub_1,"y1"),
                       (model_sub_1,"u1",model_sub_2,"y2")]
                       
        nose.tools.assert_raises(fmi.FMUException,  CoupledFMUModelME2, models, connections)

    @testattr(stddist_full = True)
    def test_inputs_list(self):
        
        model_sub_1 = load_fmu(Test_CoupledFMUModelME2.ls_sub1)
        model_sub_2 = load_fmu(Test_CoupledFMUModelME2.ls_sub2)
        model_full  = load_fmu(Test_CoupledFMUModelME2.ls_full)
        
        models = [("First", model_sub_1), ("Second", model_sub_2)]
        connections = [(model_sub_1,"y1",model_sub_2,"u2"),
                       (model_sub_2,"y2",model_sub_1,"u1")]
        
        coupled = CoupledFMUModelME2(models, connections=connections)

        #Inputs should not be listed if they are internally connected
        vars = coupled.get_input_list().keys()
        assert len(vars) == 0
        
        coupled = CoupledFMUModelME2(models, connections=[])
        vars = coupled.get_input_list().keys()
        assert "First.u1" in vars
        assert "Second.u2" in vars

    @testattr(stddist_full = True)
    def test_linear_example(self):
        
        model_sub_1 = load_fmu(Test_CoupledFMUModelME2.ls_sub1)
        model_sub_2 = load_fmu(Test_CoupledFMUModelME2.ls_sub2)
        model_full  = load_fmu(Test_CoupledFMUModelME2.ls_full)
        
        models = [("First", model_sub_1), ("Second", model_sub_2)]
        connections = [(model_sub_1,"y1",model_sub_2,"u2"),
                       (model_sub_2,"y2",model_sub_1,"u1")]
        
        coupled = CoupledFMUModelME2(models, connections=connections)

        res = coupled.simulate()
        res_full = model_full.simulate()
        
        nose.tools.assert_almost_equal(res.final("First.x1"),res_full.final("p1.x1"))
        nose.tools.assert_almost_equal(res.final("Second.x2"),res_full.final("p2.x2"))
        nose.tools.assert_almost_equal(res.initial("First.x1"),res_full.initial("p1.x1"))
        nose.tools.assert_almost_equal(res.initial("Second.x2"),res_full.initial("p2.x2"))
        
        nose.tools.assert_almost_equal(res.final("First.u1"),res_full.final("p1.u1"))
        nose.tools.assert_almost_equal(res.final("Second.u2"),res_full.final("p2.u2"))
        nose.tools.assert_almost_equal(res.initial("First.u1"),res_full.initial("p1.u1"))
        nose.tools.assert_almost_equal(res.initial("Second.u2"),res_full.initial("p2.u2"))

    @testattr(stddist_full = True)
    def test_quarter_car(self):

        model = load_fmu(Test_CoupledFMUModelME2.qc_full)

        opts = model.simulate_options()

        opts["CVode_options"]["atol"] = 1e-8
        opts["CVode_options"]["rtol"] = 1e-8

        res_full = model.simulate(final_time=1, options=opts)

        model_chassi = load_fmu(Test_CoupledFMUModelME2.qc_sub1)
        model_wheel  = load_fmu(Test_CoupledFMUModelME2.qc_sub2)

        models = [("Chassi", model_chassi), ("Wheel", model_wheel)]
        connections = [(model_chassi,"x_chassi",model_wheel,"x_chassi"),
                       (model_chassi,"v_chassi",model_wheel,"v_chassi"),
                       (model_wheel,"x_wheel",model_chassi,"x_wheel"),
                       (model_wheel,"v_wheel",model_chassi,"v_wheel")]

        coupled = CoupledFMUModelME2(models, connections)

        res = coupled.simulate(final_time=1)
        
        nose.tools.assert_almost_equal(res.final("Wheel.x_wheel"),res_full.final("x_wheel"), places=4)
        nose.tools.assert_almost_equal(res.final("Chassi.x_chassi"),res_full.final("x_chassi"), places=4)
        nose.tools.assert_almost_equal(res.initial("Wheel.x_wheel"),res_full.initial("x_wheel"), places=4)
        nose.tools.assert_almost_equal(res.initial("Chassi.x_chassi"),res_full.initial("x_chassi"), places=4)
        
        nose.tools.assert_almost_equal(res.final("Wheel.v_wheel"),res_full.final("v_wheel"), places=4)
        nose.tools.assert_almost_equal(res.final("Chassi.v_chassi"),res_full.final("v_chassi"), places=4)
        nose.tools.assert_almost_equal(res.initial("Wheel.v_wheel"),res_full.initial("v_wheel"), places=4)
        nose.tools.assert_almost_equal(res.initial("Chassi.v_chassi"),res_full.initial("v_chassi"), places=4)
        
    @testattr(stddist_full = True)
    def test_linear_example_with_time_event(self):
        
        m_full      = load_fmu(Test_CoupledFMUModelME2.ls_event_full)

        res_full = m_full.simulate(final_time=0.6)

        m_primary   = load_fmu(Test_CoupledFMUModelME2.ls_event_sub1)
        m_secondary = load_fmu(Test_CoupledFMUModelME2.ls_event_sub2)

        models = [("First", m_primary), ("Second", m_secondary)]
        connections = [(m_primary,"y1",m_secondary,"u2"),
                   (m_secondary,"y2",m_primary,"u1")]
        
        master = CoupledFMUModelME2(models, connections=connections)

        res = master.simulate(final_time=0.6)

        nose.tools.assert_almost_equal(res.final("First.x1"),res_full.final("p1.x1"), places=4)
        nose.tools.assert_almost_equal(res.final("Second.x2"),res_full.final("p2.x2"), places=4)
        nose.tools.assert_almost_equal(res.initial("First.x1"),res_full.initial("p1.x1"), places=4)
        nose.tools.assert_almost_equal(res.initial("Second.x2"),res_full.initial("p2.x2"), places=4)
        
        nose.tools.assert_almost_equal(res.final("First.u1"),res_full.final("p1.u1"), places=4)
        nose.tools.assert_almost_equal(res.final("Second.u2"),res_full.final("p2.u2"), places=4)
        nose.tools.assert_almost_equal(res.initial("First.u1"),res_full.initial("p1.u1"), places=4)
        nose.tools.assert_almost_equal(res.initial("Second.u2"),res_full.initial("p2.u2"), places=4)

    @testattr(stddist_full = True)
    def test_linear_example_with_time_event_v2(self):
        
        m_full      = load_fmu(Test_CoupledFMUModelME2.ls_event_full_v2)

        res_full = m_full.simulate(final_time=0.2)

        m_primary   = load_fmu(Test_CoupledFMUModelME2.ls_event_sub1_v2)
        m_secondary = load_fmu(Test_CoupledFMUModelME2.ls_event_sub2_v2)

        models = [("First", m_primary), ("Second", m_secondary)]
        connections = [(m_primary,"y1",m_secondary,"u2"),
                   (m_secondary,"y2",m_primary,"u1")]
        
        master = CoupledFMUModelME2(models, connections=connections)

        res = master.simulate(final_time=0.2)

        nose.tools.assert_almost_equal(res.final("First.x1"),res_full.final("p1.x1"), places=4)
        nose.tools.assert_almost_equal(res.final("Second.x2"),res_full.final("p2.x2"), places=4)
        nose.tools.assert_almost_equal(res.initial("First.x1"),res_full.initial("p1.x1"), places=4)
        nose.tools.assert_almost_equal(res.initial("Second.x2"),res_full.initial("p2.x2"), places=4)
        
        nose.tools.assert_almost_equal(res.final("First.u1"),res_full.final("p1.u1"), places=4)
        nose.tools.assert_almost_equal(res.final("Second.u2"),res_full.final("p2.u2"), places=4)
        nose.tools.assert_almost_equal(res.initial("First.u1"),res_full.initial("p1.u1"), places=4)
        nose.tools.assert_almost_equal(res.initial("Second.u2"),res_full.initial("p2.u2"), places=4)


    @testattr(stddist_full = True)
    def test_example_with_events(self):

        pi      = load_fmu(Test_CoupledFMUModelME2.pi)
        plant   = load_fmu(Test_CoupledFMUModelME2.plant)
        piplant = load_fmu(Test_CoupledFMUModelME2.piplant)

        res_full = piplant.simulate(final_time=4) 

        connections = [(pi, "loadTorque", plant, "inputTorque"),
                       (plant, "speed", pi, "speed")]

        coupled_model = CoupledFMUModelME2([("pi",pi),("plant",plant)], connections)

        res = coupled_model.simulate(final_time=4)
        
        nose.tools.assert_almost_equal(res.final("plant.speed"),res_full.final("plant.speed"), places=3)
        nose.tools.assert_almost_equal(res.final("plant.inputTorque"),res_full.final("plant.inputTorque"), places=3)
        nose.tools.assert_almost_equal(res.initial("plant.speed"),res_full.initial("plant.speed"), places=3)
        nose.tools.assert_almost_equal(res.initial("plant.inputTorque"),res_full.initial("plant.inputTorque"), places=3)
        
