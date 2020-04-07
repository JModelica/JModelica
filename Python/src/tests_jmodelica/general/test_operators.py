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

from tests_jmodelica.general.base_simul import *
from tests_jmodelica import testattr
from assimulo.solvers.sundials import CVodeError
from pyfmi.fmi import FMUException
from pymodelica.compiler_exceptions import CompilerError

class TestHomotopy(SimulationTest):
    """
    Basic test of Modelica operators.
    """

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base('OperatorTests.mo', 
            'OperatorTests.HomotopyTest')

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=0.5, time_step=0.01)
        self.run()

    @testattr(stddist_full = True)
    def test_trajectories(self):
        """
        Test that results match the expected ones.
        """
        self.assert_end_value('x', 0.5)

class TestSemiLinear(SimulationTest):
    """
    Basic test of Modelica operators.
    """

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base('OperatorTests.mo', 
            'OperatorTests.SemiLinearTest')

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=2.0, time_step=0.01)
        self.run()
        self.load_expected_data('OperatorTests_SemiLinearTest_result.txt')

    @testattr(stddist_full = True)
    def test_trajectories(self):
        """
        Test that results match the expected ones.
        """
        self.assert_all_trajectories(['x', 'y'])

class TestDiv(SimulationTest):
    """
    Basic test of Modelica operators.
    """

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base('OperatorTests.mo', 
            'OperatorTests.DivTest')

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=2.0, time_step=0.01)
        self.run()
        self.load_expected_data('OperatorTests_DivTest_result.txt')

    @testattr(stddist_full = True)
    def test_trajectories(self):
        """
        Test that results match the expected ones.
        """
        self.assert_all_trajectories(['x', 'y'])

class TestMod(SimulationTest):
    """
    Basic test of Modelica operators.
    """

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base('OperatorTests.mo', 
            'OperatorTests.ModTest')

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=2.0, time_step=0.01)
        self.run()
        self.load_expected_data('OperatorTests_ModTest_result.txt')

    @testattr(stddist_full = True)
    def test_trajectories(self):
        """
        Test that results match the expected ones.
        """
        self.assert_all_trajectories(['x', 'y'])

class TestRem(SimulationTest):
    """
    Basic test of Modelica operators.
    """

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base('OperatorTests.mo', 
            'OperatorTests.RemTest')

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=2.0, time_step=0.01)
        self.run()
        self.load_expected_data('OperatorTests_RemTest_result.txt')

    @testattr(stddist_full = True)
    def test_trajectories(self):
        """
        Test that results match the expected ones.
        """
        self.assert_all_trajectories(['x', 'y'])

class TestCeil(SimulationTest):
    """
    Basic test of Modelica operators.
    """

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base('OperatorTests.mo', 
            'OperatorTests.CeilTest')

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=2.0, time_step=0.01)
        self.run(cvode_options={'atol':1.0e-6,'rtol':1.0e-4,'maxh':0.1})
        self.load_expected_data('OperatorTests_CeilTest_result.txt')

    @testattr(stddist_full = True)
    def test_trajectories(self):
        """
        Test that results match the expected ones.
        """
        self.assert_all_trajectories(['x', 'y'])

class TestFloor(SimulationTest):
    """
    Basic test of Modelica operators.
    """

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base('OperatorTests.mo', 
            'OperatorTests.FloorTest')

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=2.0, time_step=0.01)
        self.run(cvode_options={'atol':1.0e-6,'rtol':1.0e-4,'maxh':0.1})
        self.load_expected_data('OperatorTests_FloorTest_result.txt')

    @testattr(stddist_full = True)
    def test_trajectories(self):
        """
        Test that results match the expected ones.
        """
        self.assert_all_trajectories(['x', 'y'])

class TestInteger(SimulationTest):
    """
    Basic test of Modelica operators.
    """

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base('OperatorTests.mo', 
            'OperatorTests.IntegerTest')

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=2.0, time_step=0.01)
        self.run(cvode_options={'atol':1.0e-6,'rtol':1.0e-4,'maxh':0.1})
        self.load_expected_data('OperatorTests_IntegerTest_result.txt')

    @testattr(stddist_full = True)
    def test_trajectories(self):
        """
        Test that results match the expected ones.
        """
        self.assert_all_trajectories(['x', 'y'])

class TestNested(SimulationTest):
    """
    Tests nested event generating builtins.
    """

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base('OperatorTests.mo', 
            'OperatorTests.NestedTest')

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=2.0, time_step=0.01)
        self.run(cvode_options={'atol':1.0e-6,'rtol':1.0e-4,'maxh':0.1})
        self.load_expected_data('OperatorTests_NestedTest_result.txt')

    @testattr(stddist_full = True)
    def test_trajectories(self):
        """
        Test that results match the expected ones.
        """
        self.assert_all_trajectories(['x', 'y'])

class TestSign(SimulationTest):
    """
    Basic test of Modelica operators.
    """

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base('OperatorTests.mo', 
            'OperatorTests.SignTest')

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=2.0, time_step=0.1)
        self.run()

    @testattr(stddist_full = True)
    def test_trajectories(self):
        """
        Test that results match the expected ones.
        """
        self.assert_end_value('x[1,1]', -1.0)
        self.assert_end_value('x[1,2]', 1.0)
        self.assert_end_value('x[2,1]', 1.0)
        self.assert_end_value('x[2,2]', -1.0)
        self.assert_end_value('y', -1.0)
        self.assert_end_value('z', 0)

class TestEdge(SimulationTest):
    """
    Basic test of Modelica operators.
    """

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base('OperatorTests.mo', 
            'OperatorTests.EdgeTest')

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=2.0, time_step=0.01)
        self.run()
        self.load_expected_data('OperatorTests_EdgeTest_result.txt')

    @testattr(stddist_full = True)
    def test_trajectories(self):
        """
        Test that results match the expected ones.
        """
        self.assert_all_trajectories(['x','y'])

class TestChange(SimulationTest):
    """
    Basic test of Modelica operators.
    """

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base('OperatorTests.mo', 
            'OperatorTests.ChangeTest')

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=2.0, time_step=0.01)
        self.run()
        self.load_expected_data('OperatorTests_ChangeTest_result.txt')

    @testattr(stddist_full = True)
    def test_trajectories(self):
        """
        Test that results match the expected ones.
        """
        self.assert_all_trajectories(['x','y'])

class TestReinitME(SimulationTest):
    """
    Basic test of reinit() for ME.
    """

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base('BouncingBall.mo', 'BouncingBall', target="me")

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=10.0, time_step=0.02)
        self.run()
        self.load_expected_data('BouncingBall_result_ME.txt')

    @testattr(stddist_full = True)
    def test_trajectories(self):
        """
        Test that results match the expected ones.
        """
        self.assert_all_trajectories(['h','v'])
        
class TestReinitCS(SimulationTest):
    """
    Basic test of reinit() for CS.
    """

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base('BouncingBall.mo', 'BouncingBall', target="cs")

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(start_time=0.0, final_time=10.0, time_step=0.02)
        self.run()
        self.load_expected_data('BouncingBall_result_CS.txt')

    @testattr(stddist_full = True)
    def test_trajectories(self):
        """
        Test that results match the expected ones.
        """
        self.assert_all_trajectories(['h','v'])

class TestStringExpConstant(SimulationTest):
    """
    Basic test of Modelica string operator.
    """

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base('OperatorTests.mo', 
            'OperatorTests.StringExpConstant')

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base()
        self.run()

    @testattr(stddist_full = True)
    def test_trajectories(self):
        """
        Test that results match the expected ones.
        """
        # Tested with asserts in model

class TestStringExpParameter(SimulationTest):
    """
    Basic test of Modelica string operator.
    """

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base('OperatorTests.mo', 
            'OperatorTests.StringExpParameter')

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base()
        self.run()

    @testattr(stddist_full = True)
    def test_trajectories(self):
        """
        Test that results match the expected ones.
        """
        # Tested with asserts in model

class TestLoadResource(SimulationTest):
    """
    Basic test of loadResource().
    """

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base('LoadResourceTest/package.mo', 'LoadResourceTest.LoadResource', 
            options={'variability_propagation':False})

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base()
        self.run()

    @testattr(stddist_full = True)
    def test_trajectories(self):
        """
        Test that results match the expected ones.
        """
        self.assert_end_value('x', 9)
        self.assert_end_value('y', 9)
        self.assert_end_value('z', 9)

class TestLoadResourceError1(SimulationTest):
    """
    Test compiler error from resource loading.
    """

    @testattr(stddist_full = True)
    def test_compilation_error(self):
        try:
            SimulationTest.setup_class_base('LoadResourceTest/package.mo', 'LoadResourceTest.LoadResourceError1')
            fail()
        except CompilerError as e:
            assert(len(e.get_noncompliance_errors()) == 2, "Expected 2 errors")
            assert(str(e).find("loadResource()"), "Expected loadResource() errors")

class TestOutOfRangeOps(SimulationTest):
    """
    Tests out of range on exp,log,log10,sinh,cosh,tan
    """

    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base('OperatorTests.mo', 'OperatorTests.OutOfRange')

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(final_time=1.0)
        self.run()

    @testattr(stddist_full = True)
    def test_trajectories(self):
        """
        Test that results match the expected ones.
        """
        self.assert_end_value('x1', float('Inf'))
        self.assert_end_value('x2', -float('Inf'))
        self.assert_end_value('x3', -float('Inf'))
        self.assert_end_value('x4', float('Inf'))
        self.assert_end_value('x5', float('Inf'))
        self.assert_end_value('x6', float('Inf'))
        self.assert_end_value('x7', float('Inf'))
        
class TestAssertEqu1(SimulationTest):
    '''Test assert in equation without event'''
    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'Asserts.mo',
            'Asserts.AssertEqu1')

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(final_time=3)
        
    @testattr(stddist_full = True)
    def test_simulate(self):
        try:
            self.run(cvode_options={"minh":1e-15})
            assert False, 'Simulation not stopped by failed assertions'
        except CVodeError, e:
            self.assert_equals('Simulation stopped at wrong time', e.t, 2.0)
    
class TestAssertEqu2(SimulationTest):
    '''Test assert in equation with event'''
    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'Asserts.mo',
            'Asserts.AssertEqu2')

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(final_time=3)
        
    @testattr(stddist_full = True)
    def test_simulate(self):
        try:
            self.run()
            assert False, 'Simulation not stopped by failed assertions'
        except FMUException, e:
            self.assert_equals('Simulation stopped at wrong time', self.model.time, 2.0)
        
class TestAssertFunc(SimulationTest):
    
    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'Asserts.mo',
            'Asserts.AssertFunc')

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(final_time=3)
        
    @testattr(stddist_full = True)
    def test_simulate(self):
        try:
            self.run(cvode_options={"minh":1e-15})
            assert False, 'Simulation not stopped by failed assertions'
        except CVodeError, e:
            self.assert_equals('Simulation stopped at wrong time', e.t, 2.0)

     
class TestTerminateWhen(SimulationTest):
    
    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'Asserts.mo',
            'Asserts.TerminateWhen')

    @testattr(stddist_full = True)
    def setUp(self):
        self.setup_base(final_time=3)
        self.run()

    @testattr(stddist_full = True)
    def test_end_values(self):
        self.assert_end_value('time', 2.0)
        self.assert_end_value('x', 2.0)
