#!/usr/bin/env python 
# -*- coding: utf-8 -*-

# Copyright (C) 2013 Modelon AB
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

""" Tests the KinSolver options and the debugging."""

import os.path

import nose.tools
import numpy as N
from pyfmi import load_fmu
from pymodelica import compile_fmu
from pyfmi.fmi import FMUException
from tests_jmodelica import testattr, get_files_path
from pyjmi.log import extract_jmi_log, parse_jmi_log, gather_solves


class TestInitOptions:
    """ Tests initializing with different options
    """
    @classmethod
    def setUpClass(cls):
        """Sets up the test class."""
        fpath = os.path.join(get_files_path(), 'Modelica', 'BouncingBounds.mo')
        compile_fmu('BouncingBounds', fpath, version="1.0")
        
    def setUp(self):
        """Test setUp. Load the test model."""
        # Load models
        curr_dir = get_files_path()
        self.log_file_name = os.path.join(curr_dir, 'Data', 'test_KINsolver_options_log.txt')
        self.model = load_fmu('BouncingBounds.fmu', log_file_name=self.log_file_name)
        self.model.set_debug_logging(True)
        self.model.set_log_level(5)
        self.model.set('_log_level', 5)
        
    @testattr(stddist_full = True)
    def test_inits(self):
        """
        test if model options are correctly initialized
        """
        nose.tools.assert_true(self.model.get('_enforce_bounds'))
        nose.tools.assert_equals(self.model.get('_iteration_variable_scaling'), 1)
        nose.tools.assert_equals(self.model.get('_residual_equation_scaling'), 1)
        nose.tools.assert_true(self.model.get('_rescale_after_singular_jac'))
        nose.tools.assert_equals(self.model.get('_block_solver_experimental_mode'), 0)
        nose.tools.assert_equals(self.model.get('_nle_solver_max_iter'), 100)
        
    @testattr(stddist_full = True)
    def test_variable_scaling(self):
        """
        test if user can set variable scaling.
        """
        self.model.set('_iteration_variable_scaling', 0)
        self.model.initialize()
        extract_jmi_log('test_KINsolver_log.xml', self.log_file_name)
        log = parse_jmi_log(self.log_file_name)
        solves = gather_solves(log)
        nose.tools.assert_true(N.array_equal(solves[0].block_solves[0].nominal,
                                             N.array([1.,1.])))
        
    @testattr(stddist_full = True)
    def test_equation_scaling(self):
        """
        test if user can set variable scaling.
        """
        self.model.set('_residual_equation_scaling',1)
        self.model.initialize()
        extract_jmi_log('test_KINsolver_log.xml', self.log_file_name)
        log = parse_jmi_log(self.log_file_name)
        solves = gather_solves(log)
        nose.tools.assert_false(N.array_equal(solves[0].block_solves[0].iterations[0].residual_scaling,
                                             N.array([1., 1.])))
        
#        self.setUp()
#        self.model.set('_residual_equation_scaling',2)
#        self.model.initialize()
#        extract_jmi_log('test_KINsolver_log.xml', self.log_file_name)
#        log = parse_jmi_log(self.log_file_name)
#        solves = gather_solves(log)
#        nose.tools.assert_true(N.array_equal(solves[0].block_solves[0].iterations[0].residual_scaling, 
#                               N.array([1., 3.])))
                               
        self.setUp()
        self.model.set('_residual_equation_scaling',0)
        self.model.initialize()
        extract_jmi_log('test_KINsolver_log.xml', self.log_file_name)
        log = parse_jmi_log(self.log_file_name)
        solves = gather_solves(log)
        #residual scaling is not logged when turned off.
        nose.tools.assert_false('residual_scaling' in solves[0].block_solves[0].iterations[0])
    
    @testattr(stddist_full = True)
    def test_max_iter(self):
        """
        test if maxiterations works. error propagation is tested.
        """
        #Test with too few iterations
        self.model.set('_nle_solver_max_iter', 3)
        nose.tools.assert_raises(FMUException, self.model.initialize)
        
        #Test with enough iterations
        self.setUp()
        self.model.set('_nle_solver_max_iter', 30)
        nose.tools.assert_equals(self.model.initialize(), None)
    
    @testattr(stddist_full = True)    
    def test_debbug_file(self):
        """
        That the correct amount of debug info is created.
        """
        self.model.set_debug_logging(True)
        self.model.set('_log_level',1)
        self.model.initialize()
        extract_jmi_log('test_KINsolver_log.xml', self.log_file_name)
        log = parse_jmi_log(self.log_file_name)
        solves = gather_solves(log)
        nose.tools.assert_equals(solves, [])
        
        self.setUp()
        self.model.set('_log_level',2)
        self.model.initialize()
        extract_jmi_log('test_KINsolver_log.xml', self.log_file_name)
        log = parse_jmi_log(self.log_file_name)
        solves = gather_solves(log)
        nose.tools.assert_equals(solves, [])
        
        self.setUp()
        self.model.set('_log_level',3)
        self.model.initialize()
        extract_jmi_log('test_KINsolver_log.xml', self.log_file_name)
        log = parse_jmi_log(self.log_file_name)
        solves = gather_solves(log)
        nose.tools.assert_equals(solves, [])
        
        self.setUp()
        self.model.set('_log_level',4)
        self.model.initialize()
        extract_jmi_log('test_KINsolver_log.xml', self.log_file_name)
        log = parse_jmi_log(self.log_file_name)
        solves = gather_solves(log)
        nose.tools.assert_equals(solves, [])
        
        self.setUp()
        self.model.set('_log_level',5)
        self.model.initialize()
        extract_jmi_log('test_KINsolver_log.xml', self.log_file_name)
        log = parse_jmi_log(self.log_file_name)
        solves = gather_solves(log)
        nose.tools.assert_equals(len(solves), 4)
        
        self.setUp()
        self.model.set('_log_level',6)
        self.model.initialize()
        extract_jmi_log('test_KINsolver_log.xml', self.log_file_name)
        log = parse_jmi_log(self.log_file_name)
        solves = gather_solves(log)
        nose.tools.assert_equals(len(solves), 4)
    
    @testattr(stddist_full = True)
    def test_debug_solution(self):
        """
        That the correct solution is stored in the debug file.
        """
        
        self.model.initialize()
        extract_jmi_log('test_KINsolver_log.xml', self.log_file_name)
        log = parse_jmi_log(self.log_file_name)
        solves = gather_solves(log)
        N.testing.assert_array_almost_equal(solves[0].block_solves[0].iterations[-1].ivs, N.array([N.sqrt(11), 5. ]))
        
        
class TestInitOptions20:
    """ Tests initializing with different options
    """
    @classmethod
    def setUpClass(cls):
        """Sets up the test class."""
        fpath = os.path.join(get_files_path(), 'Modelica', 'BouncingBounds.mo')
        compile_fmu('BouncingBounds', fpath, version="2.0")
        
    def setUp(self, log='test_KINsolver_options_log.txt'):
        """Test setUp. Load the test model."""
        # Load models
        curr_dir = get_files_path()
        self.log_file_name = os.path.join(curr_dir, 'Data', log)
        if os.path.exists(self.log_file_name):
            os.remove(self.log_file_name)
        self.model = load_fmu('BouncingBounds.fmu', log_file_name=self.log_file_name)
        self.model.set_debug_logging(True)
        self.model.set_log_level(5)
        self.model.set('_log_level', 5)
        
    @testattr(stddist_full = True)
    def test_inits(self):
        """
        test if model options are correctly initialized
        """
        nose.tools.assert_true(self.model.get('_enforce_bounds'))
        nose.tools.assert_equals(self.model.get('_iteration_variable_scaling'), 1)
        nose.tools.assert_equals(self.model.get('_residual_equation_scaling'), 1)
        nose.tools.assert_true(self.model.get('_rescale_after_singular_jac'))
        nose.tools.assert_equals(self.model.get('_block_solver_experimental_mode'), 0)
        nose.tools.assert_equals(self.model.get('_nle_solver_max_iter'), 100)
        
    @testattr(stddist_full = True)
    def test_variable_scaling(self):
        """
        test if user can set variable scaling.
        """
        self.model.set('_iteration_variable_scaling', 0)
        self.model.initialize()
        extract_jmi_log('test_KINsolver_log.xml', self.log_file_name)
        log = parse_jmi_log(self.log_file_name)
        solves = gather_solves(log)
        nose.tools.assert_true(N.array_equal(solves[0].block_solves[0].nominal,
                                             N.array([1.,1.])))
        
    @testattr(stddist_full = True)
    def test_equation_scaling(self):
        """
        test if user can set variable scaling.
        """
        self.model.set('_residual_equation_scaling',1)
        self.model.initialize()
        log = parse_jmi_log(self.log_file_name)
        solves = gather_solves(log)
        nose.tools.assert_false(N.array_equal(solves[0].block_solves[0].iterations[0].residual_scaling,
                                             N.array([1., 1.])))
        
#        self.setUp()
#        self.model.set('_residual_equation_scaling',2)
#        self.model.initialize()
#        extract_jmi_log('test_KINsolver_log.xml', self.log_file_name)
#        log = parse_jmi_log(self.log_file_name)
#        solves = gather_solves(log)
#        nose.tools.assert_true(N.array_equal(solves[0].block_solves[0].iterations[0].residual_scaling, 
#                               N.array([1., 3.])))
                               
        self.setUp('test_KINsolver_options_log_res0.txt')
        self.model.set('_residual_equation_scaling',0)
        self.model.initialize()
        log = parse_jmi_log(self.log_file_name)
        solves = gather_solves(log)
        #residual scaling is not logged when turned off.
        nose.tools.assert_false('residual_scaling' in solves[0].block_solves[0].iterations[0])
    
    @testattr(stddist_full = True)
    def test_max_iter(self):
        """
        test if maxiterations works. error propagation is tested.
        """
        #Test with too few iterations
        self.model.set('_nle_solver_max_iter', 3)
        nose.tools.assert_raises(FMUException, self.model.initialize)
        
        #Test with enough iterations
        self.setUp()
        self.model.set('_nle_solver_max_iter', 30)
        nose.tools.assert_equals(self.model.initialize(), None)
    
    @testattr(stddist_full = True)    
    def test_debug_file(self):
        """
        That the correct amount of debug info is created.
        """
        self.model.set_debug_logging(True)
        self.model.set('_log_level',1)
        self.model.initialize()
        log = parse_jmi_log(self.log_file_name)
        solves = gather_solves(log)
        nose.tools.assert_equals(solves, [])
        
        self.setUp('test_KINsolver_options_log_ll2.txt')
        self.model.set('_log_level',2)
        self.model.initialize()
        log = parse_jmi_log(self.log_file_name)
        solves = gather_solves(log)
        nose.tools.assert_equals(solves, [])
        
        self.setUp('test_KINsolver_options_log_ll3.txt')
        self.model.set('_log_level',3)
        self.model.initialize()
        log = parse_jmi_log(self.log_file_name)
        solves = gather_solves(log)
        nose.tools.assert_equals(solves, [])
        
        self.setUp('test_KINsolver_options_log_ll4.txt')
        self.model.set('_log_level',4)
        self.model.initialize()
        log = parse_jmi_log(self.log_file_name)
        solves = gather_solves(log)
        nose.tools.assert_equals(solves, [])
        
        self.setUp('test_KINsolver_options_log_ll5.txt')
        self.model.set('_log_level',5)
        self.model.initialize()
        log = parse_jmi_log(self.log_file_name)
        solves = gather_solves(log)
        nose.tools.assert_equals(len(solves), 2)
        
        self.setUp('test_KINsolver_options_log_ll6.txt')
        self.model.set('_log_level',6)
        self.model.initialize()
        log = parse_jmi_log(self.log_file_name)
        solves = gather_solves(log)
        print solves
        nose.tools.assert_equals(len(solves), 2)
    
    @testattr(stddist_full = True)
    def test_debug_solution(self):
        """
        That the correct solution is stored in the debug file.
        """
        
        self.model.initialize()
        extract_jmi_log('test_KINsolver_log.xml', self.log_file_name)
        log = parse_jmi_log(self.log_file_name)
        solves = gather_solves(log)
        N.testing.assert_array_almost_equal(solves[0].block_solves[0].iterations[-1].ivs, N.array([N.sqrt(11), 5. ]))
        
    
        
        
        
        
        
        
        

