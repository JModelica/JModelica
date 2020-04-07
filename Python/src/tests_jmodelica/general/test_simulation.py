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
Module for testing Simulation.
"""
import numpy as N
import nose

from tests_jmodelica.general.base_simul import *
from tests_jmodelica import testattr

class TestNominal(SimulationTest):

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
                'NominalTest.mo', 'NominalTests.NominalTest1',
                    options={"enable_variable_scaling":True})

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=10.0, 
            time_step = 0.1, abs_tol=1.0e-8)
        self.run()
        self.load_expected_data('NominalTests_NominalTest1_result.txt')

    @testattr(stddist_full = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['x', 'y', 'z', 'der(x)', 'der(y)'])
    
    @testattr(stddist_full = True)
    def test_get_nominal(self):
        from pymodelica import compile_fmu
        from pyfmi import load_fmu
        fmu = load_fmu(compile_fmu('NominalTests.NominalTest3', TestNominal.mo_path))
        n = fmu._get_nominal_continuous_states()
        nose.tools.assert_almost_equal(n[0], 1.0)
        nose.tools.assert_almost_equal(n[1], 1.0)
        nose.tools.assert_almost_equal(n[2], 2.0)
        nose.tools.assert_almost_equal(n[3], 6.0)
        nose.tools.assert_almost_equal(n[4], 5.0)
        
class TestRLCSquareCS(SimulationTest):
    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
                'RLC_Circuit.mo', 'RLC_Circuit_Square',target="cs")

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=10.0, 
            time_step = 0.01)
        self.run()
        self.load_expected_data('RLC_Circuit_Square_result.txt')

    @testattr(stddist_full = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['capacitor.v'])
        
class TestRLCSquareCSModified(SimulationTest):
    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
                'RLC_Circuit.mo', 'RLC_Circuit_Square',target="cs")

    @testattr(stddist_base = True)
    def setUp(self):
        """
        Note, this tests when an event is detected at the same time as the
        requested output time in the CS case.
        """
        self.setup_base(start_time=0.0, final_time=10.0, 
            time_step = 0.1,abs_tol=1.0e-3,rel_tol=1.0e-3)
        self.run()
        self.load_expected_data('RLC_Circuit_Square_result.txt')

    @testattr(stddist_base = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['capacitor.v'])
        
class TestRLCCS(SimulationTest):
    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
                'RLC_Circuit.mo', 'RLC_Circuit',target="cs")

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=10.0, 
            time_step = 0.01)
        self.run()
        self.load_expected_data('RLC_Circuit_result.txt')

    @testattr(stddist_full = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['capacitor.v'])
    
class TestFunction1(SimulationTest):

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'FunctionAR.mo', 'FunctionAR.UnknownArray1')

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=1.0, time_step = 0.002, 
            rel_tol=1.0e-2, abs_tol=1.0e-2)
        self.run()
        self.load_expected_data('UnknownArray.txt')

    @testattr(stddist_full = True)
    def test_trajectories(self):
        vars = ['x[%d]' % i for i in range(1, 4)]
        self.assert_all_trajectories(vars, same_span=True)


class TestFunction2(SimulationTest):

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'FunctionAR.mo', 'FunctionAR.FuncRecord1')

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=1.0, time_step = 0.002, 
            rel_tol=1.0e-2)
        self.run()
        self.load_expected_data('FuncRecord.txt')

    @testattr(stddist_full = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['x', 'r.a'], same_span=True)

class TestAlgo1(SimulationTest):

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'Algorithm.mo', 'Algorithm.AlgoTest1')

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=2.0, time_step = 0.05)
        self.run()
        self.load_expected_data('Algorithm_AlgoTest1_result.txt')

    @testattr(stddist_full = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['b', 'r', 'i'])
        
"""
class TestAlgo2(SimulationTest):

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'Algorithm.mo', 'Algorithm.AlgoTest2')
    
    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=2.0, time_step = 0.05)
        self.run()
        self.load_expected_data('Algorithm_AlgoTest2_result.txt')

    @testattr(stddist_full = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['y', 'z', 'a'])
"""
        
class TestAlgo3(SimulationTest):

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'Algorithm.mo', 'Algorithm.AlgoTest3')

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=2.0, time_step = 0.05)
        self.run(cvode_options={'store_event_points':False})
        self.load_expected_data('Algorithm_AlgoTest3_result.mat')

    @testattr(stddist_full = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['r'])

class TestAlgo4(SimulationTest):

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'Algorithm.mo', 'Algorithm.AlgoTest4')

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=2.0, time_step = 0.05)
        self.run()
        self.load_expected_data('Algorithm_AlgoTest4_result.txt')

    @testattr(stddist_full = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['x', 'y', 'd'])
        
class TestAlgo5(SimulationTest):

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'Algorithm.mo', 'Algorithm.AlgoTest5')

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=2.0, time_step = 0.05)
        self.run()
        self.load_expected_data('Algorithm_AlgoTest5_result.txt')

    @testattr(stddist_full = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['rs[1].inside', 'rs[2].inside', 'rs[3].inside', 'rs[4].inside', 'rs[5].inside'])


class TestAlgo6(SimulationTest):

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'Algorithm.mo', 'Algorithm.AlgoTest6')

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=2.0, time_step = 0.05)
        self.run(cvode_options={'atol':1.0e-6,'rtol':1.0e-4,'maxh':0.1})

    @testattr(stddist_full = True)
    def test_trajectories(self):
        self.assert_end_value('a', 2)
        self.assert_end_value('b', 7)

class TestStreams1(SimulationTest):

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'StreamExample.mo', 
            'StreamExample.Examples.Systems.HeatedGas_SimpleWrap',
            options={'enable_variable_scaling':True})

    @testattr(stddist_base = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=10, time_step = 0.1,)
        self.run()
        self.load_expected_data(
            'StreamExample_Examples_Systems_HeatedGas_SimpleWrap_result.txt')

    @testattr(stddist_base = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['linearResistanceWrap.port_a.m_flow',
                                      'linearResistanceWrap.linearResistance.port_a.p',
                                      'linearResistanceWrap.linearResistance.port_a.h_outflow',
                                      ], same_span=True, rel_tol=1e-2, abs_tol=1e-2)

class TestStreams2(SimulationTest):

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'StreamExample.mo', 'StreamExample.Examples.Systems.HeatedGas',
            options={'enable_variable_scaling':True})

    @testattr(stddist_base = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=10, time_step = 0.1,)
        self.run()
        self.load_expected_data(
            'StreamExample_Examples_Systems_HeatedGas_result.txt')

    @testattr(stddist_base = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['linearResistance.port_a.m_flow',
                                      'multiPortVolume.flowPort[1].h_outflow'
                                      ], same_span=True, rel_tol=1e-2, abs_tol=1e-2)
                                      
class TestHybrid1(SimulationTest):
    
    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'HybridTests.mo', 'HybridTests.WhenEqu2',
            options={'compliance_as_warning':True})

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=4, time_step = 0.01)
        self.run()
        self.load_expected_data(
            'HybridTests_WhenEqu2_result.txt')

    @testattr(stddist_full = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['x','y','z','w','v'], same_span=True, rel_tol=1e-3, abs_tol=1e-3)


class TestHybrid2(SimulationTest):
    
    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'HybridTests.mo', 'HybridTests.WhenEqu3',
            options={'compliance_as_warning':True})

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=4, time_step = 0.01)
        self.run()
        self.load_expected_data(
            'HybridTests_WhenEqu3_result.txt')

    @testattr(stddist_full = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['b1','x','y','z','w','v'], same_span=True, rel_tol=1e-3, abs_tol=1e-3)


class TestHybrid3(SimulationTest):
  
    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'HybridTests.mo', 'HybridTests.WhenEqu5',
            options={'compliance_as_warning':True})

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=2, time_step = 0.01,rel_tol=1e-6, abs_tol=1e-6)
        self.run()
        self.load_expected_data(
            'HybridTests_WhenEqu5_result.txt')

    @testattr(stddist_full = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['x','y','z','a','h1','h2'], same_span=True, rel_tol=1e-3, abs_tol=1e-3)


class TestHybrid4(SimulationTest):
    
    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'HybridTests.mo', 'HybridTests.WhenEqu8',
            options={'compliance_as_warning':True})

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=10, time_step = 0.01)
        self.run()
        self.load_expected_data(
            'HybridTests_WhenEqu8_result.txt')

    @testattr(stddist_full = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['x','y'], same_span=True, rel_tol=1e-3, abs_tol=1e-3)


class TestHybrid5(SimulationTest):
    
    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'HybridTests.mo', 'HybridTests.WhenEqu9',
            options={'compliance_as_warning':True})

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=10, time_step = 0.01)
        self.run()
        self.load_expected_data(
            'HybridTests_WhenEqu9_result.txt')

    @testattr(stddist_full = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['x','I'], same_span=True, rel_tol=1e-3, abs_tol=1e-3)

class TestHybrid6(SimulationTest):
    
    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'HybridTests.mo', 'HybridTests.WhenEqu10',
            options={'compliance_as_warning':True})

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=10, time_step = 0.01)
        self.run()
        self.load_expected_data(
            'HybridTests_WhenEqu10_result.txt')

    @testattr(stddist_full = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['x','y'], same_span=True, rel_tol=1e-3, abs_tol=1e-3)

class TestHybrid7(SimulationTest):
    
    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'HybridTests.mo', 'HybridTests.ZeroOrderHold1',
            options={'compliance_as_warning':True})

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=10, time_step = 0.01)
        self.run(cvode_options={'store_event_points':False})
        self.load_expected_data(
            'HybridTests_ZeroOrderHold1_result.txt')

    @testattr(stddist_full = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['expSine.y','sampler.y'], same_span=True, rel_tol=1e-3, abs_tol=1e-3)

class TestHybrid8(SimulationTest):
    
    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'HybridTests.mo', 'HybridTests.WhenEqu11')

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=10, time_step = 0.01)
        self.run()
        self.load_expected_data(
            'HybridTests_WhenEqu11_result.txt')

    @testattr(stddist_full = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['x','y'], same_span=True, rel_tol=1e-3, abs_tol=1e-3)
        
class TestHybrid9(SimulationTest):
    
    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'HybridTests.mo', 'HybridTests.WhenEqu12')

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=1e-9, time_step = 1e-11)
        self.run(cvode_options={'store_event_points':False})
        self.load_expected_data(
            'HybridTests_WhenEqu12_result.mat')

    @testattr(stddist_full = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['x'], same_span=True, rel_tol=1e-3, abs_tol=1e-3)

class TestInputInitializationFMU(SimulationTest):
    
    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'InputInitialization.mo', 'InputInitialization')

    @testattr(stddist_full = True)
    def setUp(self):
        u = ('u',N.array([[0., 1],[10.,2]]))
        self.setup_base(start_time=0.0, final_time=10, time_step = 0.01,input=u)
        self.run()
        self.load_expected_data(
            'InputInitialization_result.txt')

    @testattr(stddist_full = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['x','u'], same_span=True, rel_tol=1e-5, abs_tol=1e-5)

class TestIndexReduction1FMU(SimulationTest):
    
    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'Pendulum_pack_no_opt.mo', 'Pendulum_pack.PlanarPendulum')

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=10,rel_tol = 1.0e-6, abs_tol = 1.0e-6)
        self.ncp=50
        self.run()
        self.load_expected_data(
            'Pendulum_pack_PlanarPendulum_result.txt')

    @testattr(stddist_full = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['x','y'], same_span=True, rel_tol=1e-4, abs_tol=1e-4)

class TestIndexReduction2FMU(SimulationTest):
    
    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'IndexReductionTests.mo', 'IndexReductionTests.Mechanical1')

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=3, time_step=0.01)
        self.run()
        self.load_expected_data(
            'IndexReductionTests_Mechanical1_result.txt')

    @testattr(stddist_full = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['inertia1.w','inertia3.w'], same_span=True, rel_tol=1e-4, abs_tol=1e-4)

class TestIndexReduction3FMU(SimulationTest):
    
    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'IndexReductionTests.mo', 'IndexReductionTests.Electrical1')

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=3, time_step=0.01)
        self.run()
        self.load_expected_data(
            'IndexReductionTests_Electrical1_result.txt')

    @testattr(stddist_full = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['capacitor.i'], same_span=True, rel_tol=1e-4, abs_tol=1e-4)

class TestCoupledClutches(SimulationTest):
    
    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'Empty.mo',
            'Modelica.Mechanics.Rotational.Examples.CoupledClutches')

    @testattr(stddist_base = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=1.6,time_step=0.01,rel_tol=1e-6)
        self.run()
        self.load_expected_data(
            'Modelica_Mechanics_Rotational_Examples_CoupledClutches_result.txt')

    @testattr(stddist_base = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['J1.w','J2.w','J3.w','J4.w',
                                      'clutch1.sa','clutch2.sa','clutch3.sa'],
                                      rel_tol=1e-4, abs_tol=1e-4)

class TestDiode(SimulationTest):
    
    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'Diode.mo',
            'Diode')

    @testattr(stddist_base = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=10,time_step=0.05,rel_tol=1e-6)
        self.run()
        self.load_expected_data(
            'Diode_result.txt')

    @testattr(stddist_base = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['s','i0','i2'],rel_tol=1e-4, abs_tol=1e-4)


class TestDiodeModified(SimulationTest):
    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'Diode.mo',
            'Diode(R1=2, R2=3)')

    @testattr(stddist_base = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=10,time_step=0.05,rel_tol=1e-6)
        self.run()
        self.load_expected_data(
            'Diode_modified_result.txt')

    @testattr(stddist_base = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['s','i0','i2'],rel_tol=1e-4, abs_tol=1e-4)


class TestFriction(SimulationTest):
    
    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'Friction.mo',
            'Friction')

    @testattr(stddist_base = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=10,time_step=0.05,rel_tol=1e-6)
        self.run()
        self.load_expected_data(
            'Friction_result.txt')

    @testattr(stddist_base = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['v','a','f','sa'],rel_tol=1e-4, abs_tol=1e-4)


class TestTearing1(SimulationTest):
    
    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'TearingTests.mo',
            'TearingTests.TearingTest1',
            options={"automatic_tearing":True})

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=20,time_step=0.05,rel_tol=1e-6)
        self.run()
        self.load_expected_data(
            'TearingTests_TearingTest1_result.txt')

    @testattr(stddist_full = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['iL','u1'],rel_tol=1e-4, abs_tol=1e-4)

class TestTearing2(SimulationTest):
    
    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'TearingTests.mo',
            'TearingTests.Electro',
            options={"automatic_tearing":True,"eliminate_alias_variables":False})

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=0.996,time_step=0.002,rel_tol=1e-6)
        self.run()
        self.load_expected_data(
            'TearingTests_Electro_result.txt')

    @testattr(stddist_full = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['resistor3.i','resistor25.i'],rel_tol=1e-4, abs_tol=1e-4)

#class TestTearing3(SimulationTest):
#    
#    @classmethod
#    def setUpClass(cls):
#        SimulationTest.setup_class_base(
#            'TearingTests.mo',
#            'TearingTests.NonLinear.MultiSystems',
#            format='fmu',
#            options={"automatic_tearing":True})
#
#    @testattr(stddist_full = True)
#    def setUp(self):
#        self.setup_base(start_time=0.0, final_time=10,time_step=0.02,rel_tol=1e-6)
#        self.run()
#        self.load_expected_data(
#            'TearingTests_NonLinear_MultiSystems_result.txt')
#
#    @testattr(stddist_full = True)
#    def test_trajectories(self):
#        self.assert_all_trajectories(['R1.v','R1.i'],rel_tol=1e-4, abs_tol=1e-4)
#

class TestLocalLoop1(SimulationTest):
    
    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'TearingTests.mo',
            'TearingTests.TearingTest1',
            options={"automatic_tearing":True,"local_iteration_in_tearing":"all"})

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=20,time_step=0.05,rel_tol=1e-6)
        self.run()
        self.load_expected_data(
            'TearingTests_TearingTest1_result.txt')

    @testattr(stddist_full = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['iL','u1'],rel_tol=1e-4, abs_tol=1e-4)

class TestQR1(SimulationTest):
    
    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'QRTests.mo',
            'QRTests.QR1')

    @testattr(stddist_base = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=1,time_step=0.02,rel_tol=1e-6)
        self.run()
        self.load_expected_data(
            'QRTests_QR1_result.txt')

    @testattr(stddist_base = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['QR[1,1]','p[1]'],rel_tol=1e-4, abs_tol=1e-4)
        
class TestQR2(SimulationTest):
    
    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'QRTests.mo',
            'QRTests.QR2')

    @testattr(stddist_base = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=1,time_step=0.02,rel_tol=1e-6)
        self.run()
        self.load_expected_data(
            'QRTests_QR2_result.txt')

    @testattr(stddist_base = True)
    def test_trajectories(self):
        self.assert_all_trajectories(['Q[1,1]','p[1]'],rel_tol=1e-4, abs_tol=1e-4)

class TestWhenInLoop1(SimulationTest):
    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'WhenTests.mo',
            'WhenTests.WhenTest1')

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=1,time_step=0.02,rel_tol=1e-6)
        self.run()

    @testattr(stddist_full = True)
    def test_trajectories(self):
        self.assert_end_value('x', -1)
        self.assert_end_value('y', -0.4)

class TestWhenInLoop2(SimulationTest):
    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'WhenTests.mo',
            'WhenTests.WhenTest2')

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=1,time_step=0.02,rel_tol=1e-6)
        self.run()

    @testattr(stddist_full = True)
    def test_trajectories(self):
        self.assert_end_value('x', -0.75)
        self.assert_end_value('y', -0.25)
    
class TestWhenInLoop4(SimulationTest):
    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'WhenTests.mo',
            'WhenTests.WhenTest4')

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=1,time_step=0.02,rel_tol=1e-6)
        self.run()

    @testattr(stddist_full = True)
    def test_trajectories(self):
        self.assert_end_value('x', 1)
        self.assert_end_value('y', 3)
        self.assert_end_value('z', 2)


class TestEventOnFinalDoStep(SimulationTest):
    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'WhenTests.mo',
            'WhenTests.WhenTest6',
            target='cs')

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base()
        self.model.initialize()
        self.model.set("x", 0.0)
        self.model.do_step(0.0, 1.0)
        self.model.set("x", 2.0)
        self.model.do_step(1.0, 2.0)

    @testattr(stddist_full = True)
    def test_trajectories(self):
        assert self.model.get('y') == 1.0
        
class TestSetRealOnEvent(SimulationTest):
    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'HybridTests.mo',
            'HybridTests.IfTest1',
            target='cs')

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base()
        self.model.initialize()
        self.model.set("u", 0.0)
        self.model.do_step(0.0, 1.0)
        self.model.set("u", 2.0)
        self.model.do_step(1.0, 2.0)

    @testattr(stddist_full = True)
    def test_trajectories(self):
        assert self.model.get('der(x)') == 1.0
