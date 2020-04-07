#!/usr/bin/env python
# -*- coding: utf-8 -*-

#    Copyright (C) 2015 Modelon AB
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, version 3 of the License.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
""" Test module for testing the MHE class
"""
import os
import nose
import numpy as N
from tests_jmodelica import testattr, get_files_path
from collections import Iterable

try:
    from casadi import substitute, MX
    from pyjmi import transfer_optimization_problem
    import modelicacasadi_wrapper as mc
    from pyjmi.optimization.mhe.mhe import MHEOptions, MHE
except (NameError, ImportError):
    pass


class TestMHE:

    @classmethod
    def setUpClass(self):
        ###CSTR
        #Path and name of the CSTR
        self.CSTR_fpath = os.path.join(get_files_path(), 'Modelica', 'CSTR.mop')
        self.CSTR_cpath = "CSTR.CSTR"
        #No algebraic variables in the model
        self.CSTR_c_0 = []
        #Doesn't really affect this model, still needed
        self.CSTR_dx_0 = [('der(c)', -16.6655326), ('der(T)', -1.76138051)]
        
        self.CSTR_x_0_guess = dict([('c', 1000), ('T', 350)])
        self.CSTR_MHE_opts = MHEOptions()
        #Process noise and input specifications
        self.CSTR_MHE_opts['process_noise_cov'] = [('Tc', 10.)]
        self.CSTR_MHE_opts['input_names'] = ['Tc']
        #Measurement properties
        self.CSTR_MHE_opts['measurement_cov'] = [(['c','T'], 
                                                  N.array([[1., 0.0], 
                                                           [0.0, 0.1]]))]
        #Error covariance matrix
        self.CSTR_MHE_opts['P0_cov'] = [('c',10.),('T', 5.)]
        
        #Values used to evaluate
        self.CSTR_value_dict = {'_MHE_w_Tc(startTime)':0.1, 
                                '_MHE_v_c(startTime)':0.01, 
                                '_MHE_v_T(startTime)':0.015, 
                                '_MHE_w_Tc':0.2, 
                                '_MHE_v_c':0.02, 
                                '_MHE_v_T':0.03, 
                                '_MHE_mask':1.}
        
        ##VDP
        #Path and name of the CSTR
        self.VDP_fpath = os.path.join(get_files_path(), 'Modelica', 'VDP.mop')
        self.VDP_cpath = "VDP_pack.VDP"

        #No algebraic variables in the model
        self.VDP_c_0 = []
        #Doesn't really affect this model, still needed
        self.VDP_dx_0 = [('der(x1)', 0), ('der(x2)', 0)]

        self.VDP_x_0_guess = dict([('x1', 0.), ('x2', 1.)])
        self.VDP_MHE_opts = MHEOptions()
        #Process noise and input specifications
        self.VDP_MHE_opts['process_noise_cov'] = [('u', 1.)]
        self.VDP_MHE_opts['input_names'] = ['u']
        #Measurement properties
        self.VDP_MHE_opts['measurement_cov'] = [(['x1','x2'], 
                                                 N.array([[0.01, 0.0], 
                                                          [0.0, 0.01]]))]
        #Error covariance matrix
        self.VDP_MHE_opts['P0_cov'] = [('x1',1.),('x2', 1.)]

        #Values used to evaluate
        self.VDP_value_dict = {'_MHE_w_u(startTime)':0.1, 
                               '_MHE_v_x1(startTime)':0.01, 
                               '_MHE_v_x2(startTime)':0.015, 
                               '_MHE_w_u':0.2, 
                               '_MHE_v_x1':0.02, 
                               '_MHE_v_x2':0.03, 
                               '_MHE_mask':1.}
        ###Algebraic variables model
        #Path and name of the model
        self.alg_fpath = os.path.join(get_files_path(), 'Modelica', 'MHETest.mop')
        self.alg_cpath = "MHETest.MHEAlgebraicVariables"
        #No algebraic variables in the model
        self.alg_c_0 = [('y1', 8.0), ('y3', 2.0)]
        #Doesn't really affect this model, still needed
        self.alg_dx_0 = [('der(x1)', -255.0), 
                         ('der(y2)', 0.0), 
                         ('der(x3)', -2.0)]
        
        self.alg_x_0_guess = dict([('x1', 4.), ('x2',1.), ('x3', 3.)])
        self.alg_MHE_opts = MHEOptions()
        #Process noise and input specifications
        self.alg_MHE_opts['process_noise_cov'] = [('u1', 1.), 
                                                  ('w2', 1.), 
                                                  ('u3', 1.)]
        self.alg_MHE_opts['input_names'] = ['u1', 'u2', 'u3']
        #Measurement properties
        self.alg_MHE_opts['measurement_cov'] = [(['y1','y2'], 
                                                N.array([[0.01, 0.0],
                                                         [0.0, 0.01]])),
                                                ('y3', 0.01)]
        #Error covariance matrix
        self.alg_MHE_opts['P0_cov'] = [('x1',1.),('x2', 1.), ('x3', 1.)]
        
        #Values used to evaluate
        self.alg_value_dict = {'_MHE_w_u1(startTime)':0.1, 
                               'w2(startTime)':0.15,
                               '_MHE_w_u3(startTime)':0.05, 
                               '_MHE_v_y1(startTime)':0.02, 
                               '_MHE_v_y2(startTime)':0.03, 
                               '_MHE_v_y3(startTime)':0.04, 
                               '_MHE_w_u1':0.12, 
                               'w2':0.14,
                               '_MHE_w_u3':0.13, 
                               '_MHE_v_y1':0.02, 
                               '_MHE_v_y2':0.09, 
                               '_MHE_v_y3':0.03,
                               '_MHE_mask':1.}
        
    @testattr(casadi_base = True)
    def test_init(self):
        """
        """
        self._CSTR_init()
        self._VDP_init()
        self._alg_init()
    
    def _CSTR_init(self):
        """
        """
        op = transfer_optimization_problem(self.CSTR_cpath, 
                                           self.CSTR_fpath, 
                                           accept_model = True, 
                                           compiler_options = \
                                           {"state_initial_equations":True,
                                            "common_subexp_elim":False})
        MHE_object = MHE(op, 0.1, 5, self.CSTR_x_0_guess, 
                         self.CSTR_dx_0, self.CSTR_c_0, self.CSTR_MHE_opts)
        (o_value, o_i_value) = \
                        self._evaluate_cost_function(op, MHE_object, 
                                                     self.CSTR_value_dict)
        
        
        small = 1e-4
        assert(N.abs(o_i_value - 0.4094) < small) == True
        assert(N.abs(o_value - 0.010235) < small) == True
        #Check if beta has the value one after initialization
        small = 1e-6
        assert(N.abs(op.get('_MHE_beta') - 1.) < small) == True
        
    def _VDP_init(self):
        """
        """
        op = transfer_optimization_problem(self.VDP_cpath, 
                                           self.VDP_fpath, 
                                           accept_model = True, 
                                           compiler_options = \
                                           {"state_initial_equations":True})
        MHE_object = MHE(op, 0.1, 5, self.VDP_x_0_guess, 
                         self.VDP_dx_0, self.VDP_c_0, self.VDP_MHE_opts)
        (o_value, o_i_value) = \
                        self._evaluate_cost_function(op, MHE_object, 
                                                     self.VDP_value_dict)
        small = 1e-4
        assert(N.abs(o_i_value - 4.1300000) < small) == True
        assert(N.abs(o_value - 0.103250000) < small) == True
        #Check if beta has the value one after initialization
        small = 1e-6
        assert(N.abs(op.get('_MHE_beta') - 1.) < small) == True
    
    def _alg_init(self):
        """
        """
        op = transfer_optimization_problem(self.alg_cpath, 
                                           self.alg_fpath, 
                                           accept_model = True, 
                                           compiler_options = \
                                           {"state_initial_equations":True})
        MHE_object = MHE(op, 0.1, 5, self.alg_x_0_guess, 
                         self.alg_dx_0, self.alg_c_0, self.alg_MHE_opts)
        (o_value, o_i_value) = \
                        self._evaluate_cost_function(op, MHE_object, 
                                                     self.alg_value_dict)
        small = 1e-4
        assert(N.abs(o_value - 26.379) < small) == True
        assert(N.abs(o_i_value - 6.03) < small) == True
        #Check if beta has the value one after initialization
        small = 1e-6
        assert(N.abs(op.get('_MHE_beta') - 1.) < small) == True
    
    @testattr(casadi_base = True)    
    def test_matrix_set(self):
        """
        """
        #CSTR
        op = transfer_optimization_problem(self.CSTR_cpath, 
                                           self.CSTR_fpath, 
                                           accept_model = True, 
                                           compiler_options = \
                                           {"state_initial_equations":True,
                                            "common_subexp_elim":False})
        MHE_object = MHE(op, 0.1, 5, 
                         self.CSTR_x_0_guess, 
                         self.CSTR_dx_0, 
                         self.CSTR_c_0, 
                         self.CSTR_MHE_opts)
        process_noise_cov = [('Tc', 30.)]
        measurement_cov = [(['c','T'], N.array([[0.5, 0.1], 
                                                [0.1, 0.2]]))]
        
        self._CSTR_test_matrix_set(op, MHE_object, process_noise_cov, 
                                   measurement_cov)
        ##VDP
        op = transfer_optimization_problem(self.VDP_cpath, 
                                           self.VDP_fpath, 
                                           accept_model = True, 
                                           compiler_options = \
                                           {"state_initial_equations":True})
        MHE_object = MHE(op, 0.1, 5, self.VDP_x_0_guess, 
                         self.VDP_dx_0, self.VDP_c_0, self.VDP_MHE_opts)
        process_noise_cov = [('u', 40.)]
        measurement_cov = [(['x1','x2'], N.array([[0.5, 0.1], 
                                                  [0.1, 0.4]]))]
        
        self._VDP_test_matrix_set(op, MHE_object, 
                                  process_noise_cov, measurement_cov)
        #alg model
        op = transfer_optimization_problem(self.alg_cpath, 
                                           self.alg_fpath, 
                                           accept_model = True, 
                                           compiler_options = \
                                           {"state_initial_equations":True})
        MHE_object = MHE(op, 0.1, 5, self.alg_x_0_guess, 
                         self.alg_dx_0, self.alg_c_0, self.alg_MHE_opts)
        process_noise_cov = [(['u1','w2'], N.array([[10., 1.], [1., 10.]])), ('u3', 30.)]
        measurement_cov = [('y1', 0.2),('y2', 0.11), ('y3', 0.2)]
        self._alg_test_matrix_set(op, MHE_object, process_noise_cov, 
                                  measurement_cov)
        
    def _CSTR_test_matrix_set(self, op, MHE_object, process_noise_cov, 
                              measurement_cov):
        """
        """
        ##R-matrix
        #Set the new measurement noise covariance matrix
        MHE_object.set_measurement_noise_covariance_matrix(measurement_cov)
        #Get the values of the cost function
        (o_value, o_i_value) = \
                        self._evaluate_cost_function(op, MHE_object, 
                                                     self.CSTR_value_dict)
        small = 1e-4
        assert(N.abs(o_value - 0.010113888888888891) <= small) == True
        assert(N.abs(o_i_value - 0.4045555555555556) <= small) == True
        
        #Test that the matrix was properly changed in the EKF_object as well
        P = self._CSTR_test_linearization(MHE_object)
        
        assert(N.abs(P - N.array([[3.16206941, 0.3185585],
                                  [0.3185585, 1.456125]])) \
                                  <= small).all() == True
        
        #Set the new Q-matrix
        MHE_object.set_process_noise_covariance_matrix(process_noise_cov)
        
        #Get the values of the cost function
        (o_value, o_i_value) = \
                    self._evaluate_cost_function(op, MHE_object, 
                                                 self.CSTR_value_dict)
        small = 1e-4
        assert(N.abs(o_value - 0.003447222222222223) <= small) == True
        assert(N.abs(o_i_value - 0.13788888888888892) <= small) == True
        
        #Test that the matrix was properly changed in the EKF_object as well
        P = self._CSTR_test_linearization(MHE_object)
        
        assert(N.abs(P - N.array([[1.86389567, 0.18102889],
                                  [0.18102889, 0.87240779]])) \
                                  <= small).all() == True
        
    def _VDP_test_matrix_set(self, op, MHE_object, process_noise_cov, measurement_cov):
        """
        """
        ##R-matrix
        #Set the new R-matrix
        MHE_object.set_measurement_noise_covariance_matrix(measurement_cov)
        
        #Get the values of the cost function
        (o_value, o_i_value) = \
                        self._evaluate_cost_function(op, MHE_object, 
                                                     self.VDP_value_dict)
        small = 1e-4
        assert(N.abs(o_value - 0.10006447368421055) <= small) == True
        assert(N.abs(o_i_value - 4.002578947368422) <= small) == True
        
        #Test that the matrix was properly changed in the EKF_object as well
        P = self._VDP_test_linearization(MHE_object)
        
        assert(N.abs(P - N.array([[0.81327388, 0.03694364],
                                  [0.03694364, 0.79235944]])) \
                                  <= small).all() == True
        
        #Set the new Q-matrix
        MHE_object.set_process_noise_covariance_matrix(process_noise_cov)
        
        #Get the values of the cost function
        (o_value, o_i_value) = \
                    self._evaluate_cost_function(op, MHE_object, 
                                                 self.VDP_value_dict)
        small = 1e-4
        assert(N.abs(o_value - 0.0025644736842105266) <= small) == True
        assert(N.abs(o_i_value - 0.10257894736842106) <= small) == True
        
        #Test that the matrix was properly changed in the EKF_object as well
        P = self._VDP_test_linearization(MHE_object)
        
        assert(N.abs(P - N.array([[0.71904518, 0.05646273],
                                  [0.05646273, 0.66221741]])) \
                                  <= small).all() == True
    
    def _alg_test_matrix_set(self, op, MHE_object, process_noise_cov, measurement_cov):
        """
        """
        ##R-matrix
        #Set the new R-matrix
        MHE_object.set_measurement_noise_covariance_matrix(measurement_cov)
        
        #Get the values of the cost function
        (o_value, o_i_value) = \
                        self._evaluate_cost_function(op, MHE_object, 
                                                     self.alg_value_dict)
        small = 1e-4
        assert(N.abs(o_value - 26.35181818181818) <= small) == True
        assert(N.abs(o_i_value - 5.170136363636364) <= small) == True
        
        #Test that the matrix was properly changed in the EKF_object as well
        P = self._alg_test_linearization(MHE_object)
        assert(N.abs(P - N.array([[0.00081936, 0., 0.], 
                                  [0., 0.71489952, -0.15744286], 
                                  [0., -0.15744286, 0.52480952]])) \
                                  <= small).all() == True
        
        #Set the new Q-matrix
        MHE_object.set_process_noise_covariance_matrix(process_noise_cov)
        
        #Get the values of the cost function
        (o_value, o_i_value) = \
                    self._evaluate_cost_function(op, MHE_object, 
                                                 self.alg_value_dict)
        small = 1e-4
        assert(N.abs(o_value - 26.032449494949496) <= small) == True
        assert(N.abs(o_i_value - 0.44596464646464645) <= small) == True
        
        #Test that the matrix was properly changed in the EKF_object as well
        P = self._alg_test_linearization(MHE_object)
        assert(N.abs(P - N.array([[2.65121645e-05, -1.48514851e-05,4.95049505e-05], 
                                  [-1.48514851e-05, 6.28200076e-01, -1.87292058e-01], 
                                  [4.95049505e-05, -1.87292058e-01, 3.61088895e-01]])) \
                                  <= small).all() == True
        
    def _evaluate_cost_function(self, op, MHE_object, value_dict):
        """
        """
        objective = op.getObjective() 
        objective_integrand = op.getObjectiveIntegrand()
        ##Substitute all the parameter values
        pars = [par for par in op.getVariables(op.REAL_PARAMETER_INDEPENDENT) \
                if par.getName().startswith('_MHE_') or \
                par.getName().startswith('_start_')]
        par_values = [op.get_attr(par, '_value') for par in pars]
        pars = [par.getVar() for par in pars]
        objective = substitute([objective], pars, par_values)
        objective_integrand = substitute([objective_integrand], 
                                                pars, 
                                                par_values)
        ##Substitute the non-parameter values
        timed_variables = op.getTimedVariables()
        timed_vars = [var.getVar() for var in timed_variables]
        timed_var_names = [var.getName() for var in timed_variables]

        values = [value_dict[name] for name in timed_var_names]
        o_value = substitute(objective, timed_vars, values)[0].getValue()


        base_variables = [var.getBaseVariable() for var in timed_variables]
        base_vars = [var.getVar() for var in base_variables]
        base_names = [var.getName() for var in base_variables]
        mask_var = op.getVariable('_MHE_mask').getVar()
        values = [value_dict[name] for name in base_names]
        vars = base_vars
        o_i_value = substitute(objective_integrand, 
                                      base_vars, 
                                      values)
        o_i_value = substitute(o_i_value, 
                                      [mask_var], 
                                      [value_dict['_MHE_mask']])[0].getValue()
        return (o_value, o_i_value)

    @testattr(casadi_base = True)
    def test_set_beta(self):
        """
        """
        self._CSTR_test_set_beta()
        self._VDP_test_set_beta()
        self._alg_test_set_beta()
    
    def _CSTR_test_set_beta(self):
        """
        """
        op = transfer_optimization_problem(self.CSTR_cpath, 
                                           self.CSTR_fpath, 
                                           accept_model = True, 
                                           compiler_options = \
                                           {"state_initial_equations":True,
                                            "common_subexp_elim":False})
        MHE_object = MHE(op, 0.1, 5, 
                         self.CSTR_x_0_guess, 
                         self.CSTR_dx_0, 
                         self.CSTR_c_0, 
                         self.CSTR_MHE_opts)
        MHE_object.set_beta(0.25)
        (o_value, o_i_value) = \
                    self._evaluate_cost_function(op, 
                                                 MHE_object, 
                                                 self.CSTR_value_dict)
        small = 1e-4
        assert(N.abs(o_value - 0.010235000000000003) < small) == True
        assert(N.abs(o_i_value - 0.4094000000000001) < small) == True
        
    def _VDP_test_set_beta(self):
        """
        """
        op = transfer_optimization_problem(self.VDP_cpath, 
                                           self.VDP_fpath, 
                                           accept_model = True, 
                                           compiler_options = \
                                           {"state_initial_equations":True})
        MHE_object = MHE(op, 0.1, 5, self.VDP_x_0_guess, 
                         self.VDP_dx_0, self.VDP_c_0, self.VDP_MHE_opts)
        MHE_object.set_beta(0.25)
        (o_value, o_i_value) = \
                    self._evaluate_cost_function(op, 
                                                 MHE_object, 
                                                 self.VDP_value_dict)
        small = 1e-4
        assert(N.abs(o_value - 0.10325000000000002) < small) == True
        assert(N.abs(o_i_value - 4.130000000000001) < small) == True
    
    def _alg_test_set_beta(self):
        """
        """
        op = transfer_optimization_problem(self.alg_cpath, 
                                           self.alg_fpath, 
                                           accept_model = True, 
                                           compiler_options = \
                                           {"state_initial_equations":True})
        MHE_object = MHE(op, 0.1, 5, self.alg_x_0_guess, 
                         self.alg_dx_0, self.alg_c_0, self.alg_MHE_opts)
        MHE_object.set_beta(0.25)
        (o_value, o_i_value) = \
                    self._evaluate_cost_function(op, 
                                                 MHE_object, 
                                                 self.alg_value_dict)
        small = 1e-4
        assert(N.abs(o_value - 6.879) < small) == True
        assert(N.abs(o_i_value - 6.029999999999999) < small) == True
       
    @testattr(casadi_base = True)
    def test_linearization(self):
        """
        """
        op = transfer_optimization_problem(self.CSTR_cpath, 
                                           self.CSTR_fpath, 
                                           accept_model = True, 
                                           compiler_options = \
                                           {"state_initial_equations":True,
                                            "common_subexp_elim":False})
        MHE_object = MHE(op, 0.1, 5, 
                         self.CSTR_x_0_guess, 
                         self.CSTR_dx_0, 
                         self.CSTR_c_0, 
                         self.CSTR_MHE_opts)

        P = self._CSTR_test_linearization(MHE_object)
        small = 1e-4
        assert(N.abs(P - N.array([[ 4.99522645, -0.10163129], 
                                  [-0.10163129,  0.87012425]])) \
                                  <= small).all() == True
        ##VDP
        op = transfer_optimization_problem(self.VDP_cpath, 
                                           self.VDP_fpath, 
                                           accept_model = True, 
                                           compiler_options = \
                                           {"state_initial_equations":True})
        MHE_object = MHE(op, 0.1, 5, self.VDP_x_0_guess, 
                         self.VDP_dx_0, self.VDP_c_0, self.VDP_MHE_opts)
        P = self._VDP_test_linearization(MHE_object)
        assert(N.abs(P - N.array([[9.09892969e-02, 9.80296049e-05], 
                                  [9.80296049e-05, 9.00188039e-02]])) \
                                  <= small).all() == True
        #alg model
        op = transfer_optimization_problem(self.alg_cpath, 
                                           self.alg_fpath, 
                                           accept_model = True, 
                                           compiler_options = \
                                           {"state_initial_equations":True})
        MHE_object = MHE(op, 0.1, 5, self.alg_x_0_guess, 
                         self.alg_dx_0, self.alg_c_0, self.alg_MHE_opts)
        P = self._alg_test_linearization(MHE_object)
        assert(N.abs(P - N.array([[6.22248895e-05, 0.00000000e+00, 0.00000000e+00],
                                  [0.00000000e+00, 1.00180909e-01, -2.75727273e-02],
                                  [0.00000000e+00, -2.75727273e-02, 9.19090909e-02]])) \
                                 <= small).all() == True
                   
    def _CSTR_test_linearization(self, MHE_object):
        """
        """
        t = 1.
        x = [('c',1000.),('T',350.)]
        dx = [('der(c)', -16.665532637956801), ('der(T)', -1.7613805165047101)]
        u = [('Tc', 350.)]
        c = []
        
        z0 = {'x':x,
              'dx':dx,
              'u':u + [],
              'c':c}
        small = 1e-4
        (E, A, B, C) = \
                MHE_object.EKF_object._evaluate_jacobian_functions(z0, t)
        
        assert(N.abs(A.toArray() - N.array([[-0.0166822, -1.1904],
                                            [0.00348651, 0.214034]])) \
                                            <= small).all() == True

        assert(N.abs(B.toArray() - N.array([[0.], [0.034986]])) \
                                            <= small).all() == True
        assert(N.abs(C.toArray() - N.array([[]])) <= small).all() == True

        assert(N.abs(E.toArray() - N.array([[1., 0.], 
                                            [0., 1.]])) \
                                            <= small).all() == True

        
        (A, B, C, G) = MHE_object.EKF_object._calculate_A_B_C_and_G(A, B, C, E)
        
        assert(N.abs(A.toArray() - N.array([[-0.0166822, -1.1904],
                                            [0.00348651, 0.214034]])) \
                                            <= small).all() == True
                                  
        assert(N.abs(B - N.array([[0.],[0.03498596]])) \
                                 <= small).all() == True
        
        assert(N.abs(C - N.array([[1., 0.],[0., 1.]])) \
                                  <= small).all() == True
        
        assert(N.abs(G - N.array([[0.],[0.03498596]])) \
                                  <= small).all() == True
        
        (Ad, Bd, Gd) = MHE_object.EKF_object._backward_euler_discretize(A, B, G)
        
        assert(N.abs(Ad - N.array([[9.98292290e-01, -1.21435364e-01], 
                                   [3.55668430e-04, 1.02182826e+00]])) \
                                  <= small).all() == True
        
        assert(N.abs(Bd - N.array([[-0.00042485], [0.00357496]])) \
                                  <= small).all() == True
        
        assert(N.abs(Gd - N.array([[-0.00042485], [0.00357496]])) \
                                  <= small).all() == True
        P = MHE_object.EKF_object.get_next_P(t, x, dx, u, c)
        return P
    
    def _VDP_test_linearization(self, MHE_object):
        """
        """
        t = 1.
        x = [('x1',0.),('x2',1.)]
        dx = [('der(x1)', 0), ('der(x2)', 0)]
        u = [('u', 1.)]
        c = []
        
        z0 = {'x':x,
              'dx':dx,
              'u':u + [],
              'c':c}
        small = 1e-4
        E, A, B, C = \
                MHE_object.EKF_object._evaluate_jacobian_functions(z0, t)
        assert(N.abs(A.toArray() - N.array([[0., -1.],
                                            [1., 0.]])) \
                                            <= small).all() == True
        assert(N.abs(B.toArray() - N.array([[1.], [0.]])) \
                                            <= small).all() == True
        assert(N.abs(C.toArray() - N.array([[]])) <= small).all() == True
        assert(N.abs(E.toArray() - N.array([[1., 0.], 
                                            [0., 1.]])) \
                                            <= small).all() == True
        
        A, B, C, G = MHE_object.EKF_object._calculate_A_B_C_and_G(A, B, C, E)
        assert(N.abs(A.toArray() - N.array([[0., -1.],
                                            [1., 0.]])) \
                                            <= small).all() == True                      
        assert(N.abs(B - N.array([[1.],[0.]])) \
                                 <= small).all() == True
        
        assert(N.abs(C - N.array([[1., 0.],[0., 1.]])) \
                                  <= small).all() == True
        assert(N.abs(G - N.array([[1.],[0.]])) \
                                  <= small).all() == True
        
        Ad, Bd, Gd = MHE_object.EKF_object._backward_euler_discretize(A, B, G)
        assert(N.abs(Ad - N.array([[0.99009901, -0.0990099 ], 
                                   [0.0990099, 0.99009901]])) \
                                  <= small).all() == True
        assert(N.abs(Bd - N.array([[0.0990099], [0.00990099]])) \
                                  <= small).all() == True
        assert(N.abs(Gd - N.array([[0.0990099], [0.00990099]])) \
                                  <= small).all() == True
        
        P = MHE_object.EKF_object.get_next_P(t, x, dx, u, c)
        return P
    
    def _alg_test_linearization(self, MHE_object):
        """
        """
        t = 1.
        x = [('x1', 4.), ('y2',1.), ('x3', 3.)]
        dx = [('der(x1)', -255.0), ('der(y2)', 0.0), 
              ('der(x3)', -2.0)]
        u = [('u1', 1.), ('u2', 2.), ('u3', 3.)]
        c = [('y1', 8.0), ('y3', 2.0)]
        
        z0 = {'x':x,
              'dx':dx,
              'u':u + [('w2', 0)],
              'c':c}
        small = 1e-4
        E, A, B, C = \
                MHE_object.EKF_object._evaluate_jacobian_functions(z0, t)        
        assert(N.abs(A.toArray() - N.array([[-192., 0., 0.],
                                            [0., 0., -3.],
                                            [0., 0., 0.],
                                            [2., 0., 0.],
                                            [0., 1., 0.]])) \
                                            <= small).all() == True
        assert(N.abs(B.toArray() - N.array([[ 0.,  1.,  0.,  0.],
                                            [ 1.,  0.,  0.,  1.],
                                            [ 0.,  0.,  0.,  0.],
                                            [ 0.,  0.,  0.,  0.],
                                            [ 0.,  0., -1.,  0.]])) \
                                            <= small).all() == True
        assert(N.abs(C.toArray() - N.array([[ 0.,  0.],
                                            [ 0.,  0.],
                                            [ 0., -1.],
                                            [-1.,  0.],
                                            [ 0., -1.]])) \
                                            <= small).all() == True
        assert(N.abs(E.toArray() - N.array([[ 1.,  0.,  0.],
                                            [ 0.,  0.,  1.],
                                            [ 0.,  1.,  0.],
                                            [ 0.,  0.,  0.],
                                            [ 0.,  0.,  0.]])) \
                                            <= small).all() == True
        
        A, B, C, G = MHE_object.EKF_object._calculate_A_B_C_and_G(A, B, C, E)
        assert(N.abs(A.toArray() - N.array([[-192.,    0.,    0.],
                                             [   0.,    0.,   -3.],
                                             [   0.,    0.,    0.]])) \
                                             <= small).all() == True                      
        assert(N.abs(B - N.array([[ 0.,  1.,  0.],
                                  [ 0.,  0.,  1.],
                                  [ 1.,  0.,  0.]])) \
                                  <= small).all() == True
        
        assert(N.abs(C - N.array([[ 2.,  0.,  0.], 
                                  [ 0.,  0.,  1.],
                                  [ 0.,  1.,  0.]])) \
                                  <= small).all() == True
        assert(N.abs(G - N.array([[ 1.,  0.,  0.],
                                  [ 0.,  1.,  0.],
                                  [ 0.,  0.,  1.]])) \
                                  <= small).all() == True
        
        Ad, Bd, Gd = MHE_object.EKF_object._backward_euler_discretize(A, B, G)
        assert(N.abs(Ad - N.array([[0.04950495, 0., 0.],
                                   [0., 1., -0.3],
                                   [0., 0., 1.]])) \
                                   <= small).all() == True
        assert(N.abs(Bd - N.array([[0., 0.0049505, 0.],
                                   [-0.03, 0., 0.1],
                                   [0.1, 0., 0.]])) \
                                   <= small).all() == True
        assert(N.abs(Gd - N.array([[0.0049505, 0., 0.],
                                   [0., 0.1, -0.03],
                                   [0., 0., 0.1]])) \
                                   <= small).all() == True
        
        P = MHE_object.EKF_object.get_next_P(t, x, dx, u, c)
        return P
    
    @testattr(casadi_base = True)
    def test_step(self):
        """
        """
        small = 1e-4
        #CSTR
        x_est = self._CSTR_test_step()
        
        assert(N.abs(x_est['c'] - 998.35374838150801) < small) == True
        assert(N.abs(x_est['T'] - 350.27058447932399) < small) == True
        #VDP
        x_est = self._VDP_test_step()
        assert(N.abs(x_est['x1'] - 0.20073576400026499) < small) == True
        assert(N.abs(x_est['x2'] - 0.92916448549107999) < small) == True
        
        #alg model
        x_est = self._alg_test_step()
        assert(N.abs(x_est['x1'] - 0.915262783242628) < small) == True
        assert(N.abs(x_est['x2'] - 1.00698173206459) < small) == True
        assert(N.abs(x_est['x3'] - 3.0786561264822101) < small) == True

    def _CSTR_test_step(self):
        """
        """
        op = transfer_optimization_problem(self.CSTR_cpath, 
                                           self.CSTR_fpath, 
                                           accept_model = True, 
                                           compiler_options = \
                                           {"state_initial_equations":True,
                                            "common_subexp_elim":False})
        MHE_object = MHE(op, 0.1, 5, self.CSTR_x_0_guess, 
                         self.CSTR_dx_0, self.CSTR_c_0, self.CSTR_MHE_opts)
        u = [('Tc', 350.)]
        y = [('c', 1000.1), ('T', 349.9)]
        x_est = MHE_object.step(u, y)
        return x_est
        
    def _VDP_test_step(self):
        """
        """
        op = transfer_optimization_problem(self.VDP_cpath, 
                                           self.VDP_fpath, 
                                           accept_model = True, 
                                           compiler_options = \
                                           {"state_initial_equations":True})
        MHE_object = MHE(op, 0.1, 5, self.VDP_x_0_guess, 
                         self.VDP_dx_0, self.VDP_c_0, self.VDP_MHE_opts)
        u = [('u', 2)]
        y = [('x1', 0.1),('x2', 0.9)]
        x_est = MHE_object.step(u, y)

        return x_est
    
    def _alg_test_step(self):
        """
        """
        op = transfer_optimization_problem(self.alg_cpath, 
                                           self.alg_fpath, 
                                           accept_model = True, 
                                           compiler_options = \
                                           {"state_initial_equations":True})
        MHE_object = MHE(op, 0.1, 5, self.alg_x_0_guess, 
                         self.alg_dx_0, self.alg_c_0, self.alg_MHE_opts)
        u = [('u1', 1.), ('u2', 2.), ('u3', 3.)]
        y = [('y1', 2.1),('y2', 0.9), ('y3', 0.1)]
        x_est = MHE_object.step(u, y)

        return x_est
    
    @testattr(casadi_base = True)
    def CSTR_test(self):
        """
        """
        #Input signal
        u = {'Tc': N.array([200., 230.90169944, 258.77852523, 280.90169944, 
                            295.10565163, 300., 295.10565163, 280.90169944, 
                            258.77852523, 230.90169944, 200.])}
        #Measurements
        y = {'T': N.array([350.49995133, 350.62330131, 348.36492738, 
                           350.66030448, 349.06684452, 350.30260073, 
                           350.88973306, 351.02143123,352.25379842, 
                           350.69031449, 350.52862786]),
             'c': N.array([1000.15989016, 995.19520286, 995.36670838, 
                           992.97568672, 994.39361231, 993.60003461, 
                           991.27116652, 984.54130088, 984.5513898 , 
                           987.03969368, 979.94914004])}
        #Results
        res = {'T': [350.0, 350.24521349614298, 350.40171944062098, 
                     349.82830663880299, 350.21239219430902, 
                     350.15708147543103, 350.33127417874198, 
                     350.53464913234399, 350.69615625115398, 
                     350.88877384044901, 350.71984245480701],
               'c': [1000.0, 998.38670418641595, 995.60046552439098, 
                     993.99813807458304, 992.06868215123302, 
                     990.84754450513105, 989.55213337744999, 
                     988.03069306229702, 985.88177811765695, 
                     983.90027897344601, 982.47929069888403]}
        #Define the time vector and sample_time
        nbr_of_points = 11
        sim_time = 1.0
        sample_time = sim_time/(nbr_of_points - 1)
        time = N.linspace(0.,sim_time,nbr_of_points)
        horizon = 5
        #Create the objects
        op = transfer_optimization_problem(self.CSTR_cpath, 
                                           self.CSTR_fpath, 
                                           accept_model = True, 
                                           compiler_options = \
                                           {"state_initial_equations":True,
                                            "common_subexp_elim":False})
        MHE_object = MHE(op, sample_time, horizon, self.CSTR_x_0_guess, 
                         self.CSTR_dx_0, self.CSTR_c_0, self.CSTR_MHE_opts)
        #Get the names for the inputs and measured variables
        meas_names = y.keys()
        input_names = u.keys()
        state_names = res.keys()
        #Tolerance
        small = 1e-4
        #Start estimating
        for k in range(1, nbr_of_points):
            y_in = []
            for name in meas_names:
                y_in.append((name, y[name][k-1]))
            u_in = []
            for name in input_names:
                u_in.append((name, u[name][k-1]))
            x_est_t = MHE_object.step(u_in, y_in)
            for name in state_names:
                #Check that the estimation match the expected values
                assert(N.abs(x_est_t[name] - res[name][k]) < small) == True
        
    @testattr(casadi_base = True)
    def VDP_test(self):
        """
        """
        #Input signal
        u = {'u': N.array([1., 1.1545085, 1.29389263, 1.4045085, 1.47552826, 
                           1.5, 1.47552826, 1.4045085, 1.29389263, 1.1545085, 
                           1.])}
        #Measurements
        y = {'x1': N.array([0.01598902, -0.30140151, -0.15680465, -0.13766548, 
                            0.16180561, 0.27355275, 0.27159278, -0.23342386, 
                            -0.07085041, 0.32829822, -0.20349616]),
             'x2': N.array([1.15809849, 1.22068836, 0.49781333, 1.19490247, 
                            0.6484263, 0.99125759, 1.13786648, 1.15703321, 
                            1.5473424, 1.08268968, 1.09604879])}
        #Results
        res = {'x1': [0.0, 0.000156491407211121, -0.12992856073970599,
                      -0.10429879988759901, -0.060223975986382898,
                      0.042528012851343097, 0.14201955985534201,
                      0.20740252201035, 0.17163305709875301,
                      0.14700156383853,  0.15223826240684701],
               'x2': [1.0, 1.1437415520743299, 1.16549857245914,
                      0.94046569055097795, 0.99679612768676396,
                      0.93520125209556404, 0.95931414435214302,
                      1.0038039602371001, 1.0381317315246399,
                      1.10442669390861, 1.1134208905326499]}
        #Define the time vector and sample_time
        nbr_of_points = 11
        sim_time = 1.0
        sample_time = sim_time/(nbr_of_points - 1)
        time = N.linspace(0.,sim_time,nbr_of_points)
        horizon = 7
        #Create the objects
        op = transfer_optimization_problem(self.VDP_cpath, 
                                           self.VDP_fpath, 
                                           accept_model = True, 
                                           compiler_options = \
                                           {"state_initial_equations":True,
                                            "propagate_derivatives":False})
        MHE_object = MHE(op, sample_time, horizon, self.VDP_x_0_guess, 
                         self.VDP_dx_0, self.VDP_c_0, self.VDP_MHE_opts)
        #Get the names for the inputs and measured variables
        meas_names = y.keys()
        input_names = u.keys()
        state_names = res.keys()
        #Tolerance
        small = 1e-4
        #Start estimating
        for k in range(1, nbr_of_points):
            y_in = []
            for name in meas_names:
                y_in.append((name, y[name][k-1]))
            u_in = []
            for name in input_names:
                u_in.append((name, u[name][k-1]))
            x_est_t = MHE_object.step(u_in, y_in)
            for name in state_names:
                #Check that the estimation match the expected values
                assert(N.abs(x_est_t[name] - res[name][k]) < small) == True
        
    @testattr(casadi_base = True)
    def alg_test(self):
        """
        """
        u = {'u1': N.array([1., 1., 1., 1., 1., -1., -1., -1., -1., -1., 1.]),
             'u2': N.array([1., 1., 1., 1., 1., -1., -1., -1., -1., -1., 1.]),
             'u3': N.array([1., 1., 1., 1., 1., -1., -1., -1., -1., -1., 1.])}
        
        y = {'y1': N.array([8.01598902, 3.82712444, 2.21602773, 1.52628288, 
                            1.78032074, 1.33556059, 1.13225052, 0.6815139, 
                            1.13774802, -0.19275658, 0.13232286]),
             'y2': N.array([1.15809849, 0.82365419, 1.12413813, 1.15862873, 
                            1.04868341, 0.60120574, 0.67870438, 0.60568444, 
                            0.56386917, 0.80902457, 0.62455872]),
             'y3': N.array([2.36059046, 1.55907985, 2.04010046, 0.76819435, 
                            0.86183064, 3.2406026, 2.78065519, 2.45997133, 
                            3.01811517,  1.68766116, 0.77830631])}
        
        res = {'x1': [4.0, 1.79487373403316, 1.2030866916434, 
                      0.95437321483937998, 0.82641593748389497, 
                      0.755144460966236, 0.48388025204384399, 
                      0.367184172540099, 0.25876721308679301, 
                      0.179216471837809, 0.052534023505977002],
               'x2': [1.0, 1.10778127286203, 1.0077859502873201, 
                      1.0215187920497899, 1.0261931441777401, 
                      1.02099539262494, 0.71534109941505997, 
                      0.59304949022098297, 0.48612225471033699, 
                      0.386737078433041, 0.31586596419808299],
               'x3': [3.0, 3.1018083085799599, 2.7038522200569499, 
                      2.6248079918145399, 2.3466929822733298, 
                      2.1720236625504001, 1.7379308335622801, 
                      1.49146989588815, 1.29732420562088, 
                      1.0772734530383401, 0.87799963868131903]}
        
        #Define the time vector and sample_time
        nbr_of_points = 11
        sim_time = 1.0
        sample_time = sim_time/(nbr_of_points - 1)
        time = N.linspace(0.,sim_time,nbr_of_points)
        horizon = 7
        #Create the objects
        op = transfer_optimization_problem(self.alg_cpath, 
                                           self.alg_fpath, 
                                           accept_model = True, 
                                           compiler_options = \
                                           {"state_initial_equations":True})
        MHE_object = MHE(op, sample_time, horizon, self.alg_x_0_guess, 
                         self.alg_dx_0, self.alg_c_0, self.alg_MHE_opts)
        #Get the names for the inputs and measured variables
        meas_names = y.keys()
        input_names = u.keys()
        state_names = res.keys() 
        #Tolerance
        small = 1e-4
        #Start estimating
        for k in range(1, nbr_of_points):
            y_in = []
            for name in meas_names:
                y_in.append((name, y[name][k-1]))
            u_in = []
            for name in input_names:
                u_in.append((name, u[name][k-1]))
            x_est_t = MHE_object.step(u_in, y_in)
            for name in state_names:
                #Check that the estimation match the expected values
                assert(N.abs(x_est_t[name] - res[name][k]) < small) == True
        
    @testattr(casadi_base = True)
    def test_recalculate_jacobian_functions(self):
        """
        """
        self._CSTR_test_recalculate_jacobian_functions()
        self._alg_test_recalculate_jacobian_functions()
    
    def _CSTR_test_recalculate_jacobian_functions(self):
        """
        """
        #Input signal
        u = {'Tc': N.array([200., 230.90169944, 258.77852523, 280.90169944, 
                            295.10565163, 300., 295.10565163, 280.90169944, 
                            258.77852523, 230.90169944, 200.])}
        #Measurements
        y = {'T': N.array([350.49995133, 350.62401787, 348.3661798, 
                           350.66098145, 349.06541948, 350.2972949, 
                           350.87884579, 351.00379213, 352.22900459, 
                           350.65896981,  350.49244085]),
             'c': N.array([1000.15989016, 995.21148013, 995.41536966, 
                           993.07288535, 994.55564675, 993.84341065, 
                           991.61258062, 984.99750895, 985.1390128, 
                           987.77496459, 980.84763984])}
        #Results
        res = {'T': [350.0, 350.242738407682, 350.39453469744097,
                     349.83968482689301, 350.21266458427601, 
                     350.16582145252301, 350.33387996763901, 
                     350.52528427428899, 350.672976930819, 
                     350.84086336190398, 350.66975859659698],
               'c': [1000.0, 998.40294343534504, 995.67484418947697, 
                     994.12258279148602, 992.27354195443297, 
                     991.11331294681395, 989.89425329968799, 
                     988.47657103391998, 986.49689990715797, 
                     984.68736633222295, 983.40354818470905]}
        
        #Get the names for the inputs and measured variables
        meas_names = res.keys()
        input_names = u.keys()
        #Define the time vector and sample_time
        nbr_of_points = 11
        sim_time = 1.0
        sample_time = sim_time/(nbr_of_points - 1)
        time = N.linspace(0.,sim_time,nbr_of_points)
        horizon = 5
        ##Create the objects
        op = transfer_optimization_problem(self.CSTR_cpath, 
                                           self.CSTR_fpath, 
                                           accept_model = True, 
                                           compiler_options = \
                                           {"state_initial_equations":True,
                                            "common_subexp_elim":False})
        MHE_object = MHE(op, sample_time, horizon, self.CSTR_x_0_guess, 
                         self.CSTR_dx_0, self.CSTR_c_0, self.CSTR_MHE_opts)
        
        #Change a parameter found in the DAEs
        op.set('F0', 10.)
        MHE_object.set_dirty()
        
        #Tolerance
        small = 1e-4
        #Start estimating
        for k in range(1, nbr_of_points):
            y_in = []
            for name in meas_names:
                y_in.append((name, y[name][k-1]))
            u_in = []
            for name in input_names:
                u_in.append((name, u[name][k-1]))
            x_est_t = MHE_object.step(u_in, y_in)
            for name in meas_names:
                #Check that the estimation match the expected values
                assert(N.abs(x_est_t[name] - res[name][k]) < small) == True
        
    def _alg_test_recalculate_jacobian_functions(self):
        """
        """
        u = {'u1': N.array([1., 1., 1., 1., 1., -1., -1., -1., -1., -1., 1.]),
             'u2': N.array([1., 1., 1., 1., 1., -1., -1., -1., -1., -1., 1.]),
             'u3': N.array([1., 1., 1., 1., 1., -1., -1., -1., -1., -1., 1.])}
        
        y = {'y1': N.array([16.01598902, 6.68600211, 3.97904519, 2.85570587, 
                            2.93475135, 2.12813742, 1.6448018, 0.9800175 , 
                            1.21791756,  -0.3872935 , 0.12330128]),
             'y2': N.array([1.15809849, 0.82365419, 1.12413813, 1.15862873, 
                            1.04868341, 0.60120574, 0.67870438, 0.60568444, 
                            0.56386917, 0.80902457, 0.62455872]),
             'y3': N.array([2.36059046, 1.55907985, 2.04010046, 0.76819435, 
                            0.86183064, 3.2406026, 2.78065519, 2.45997133, 
                            3.01811517,  1.68766116, 0.77830631])}
        
        res = {'x1': [4.0, 1.6082340988237001, 1.03842537507295, 
                      0.81393711193151896, 0.70236883797917204, 
                      0.64385660089544205, 0.38625429906362202, 
                      0.276829145593191, 0.16810181251937001, 
                      0.099215812402707895, -0.055450552944075103],
               'x2': [1.0, 1.10778127286203, 1.0077859502873201, 
                      1.0215187920497899, 1.0261931441777401, 
                      1.02099539262494, 0.71534109941505997, 
                      0.59304949022098297, 0.48612225471033699, 
                      0.386737078433041, 0.31586596419808299],
               'x3': [3.0, 3.1018083085799599, 2.7038522200569499, 
                      2.6248079918145399, 2.3466929822733298, 
                      2.1720236625504001, 1.7379308335622801, 
                      1.49146989588815, 1.29732420562088, 
                      1.0772734530383401, 0.87799963868131903]}
        
        #Define the time vector and sample_time
        nbr_of_points = 11
        sim_time = 1.0
        sample_time = sim_time/(nbr_of_points - 1)
        time = N.linspace(0.,sim_time,nbr_of_points)
        horizon = 7
        #Create the objects
        op = transfer_optimization_problem(self.alg_cpath, 
                                           self.alg_fpath, 
                                           accept_model = True, 
                                           compiler_options = \
                                           {"state_initial_equations":True})
        MHE_object = MHE(op, sample_time, horizon, self.alg_x_0_guess, 
                         self.alg_dx_0, self.alg_c_0, self.alg_MHE_opts)
        #Change the parameters
        op.set('a', 6.)
        op.set('b', 4.)
        MHE_object.set_dirty()
        
        
        #Get the names for the inputs and measured variables
        meas_names = y.keys()
        input_names = u.keys()
        state_names = res.keys() 
        #Tolerance
        small = 1e-4
        #Start estimating
        for k in range(1, nbr_of_points):
            y_in = []
            for name in meas_names:
                y_in.append((name, y[name][k-1]))
            u_in = []
            for name in input_names:
                u_in.append((name, u[name][k-1]))
            x_est_t = MHE_object.step(u_in, y_in)
            for name in state_names:
                #Check that the estimation match the expected values
                assert(N.abs(x_est_t[name] - res[name][k]) < small) == True
    
    def CSTR_constraint_test(self):
        """
        """
        u = {'Tc': N.array([400., 400., 400., 400., 400., 200., 
                            200., 200., 200., 200., 400.])}
        
        y = {'T': N.array([300.49995133, 304.07278006, 304.98920043, 
                           310.38656966, 311.62996958, 308.84942512, 
                           305.60494737, 302.02381573, 299.74799715, 
                           294.89779864, 298.47993723]),
             'c': N.array([0.15989016, -3.13268013, -1.2894751, -1.9982848,
                           1.1172196, 2.03957335, 1.44398726, -3.54175456, 
                           -1.78609084, 2.43710318, -2.94216934])}
        res = {'T': [300.0, 303.78362586438101, 307.15904038994398, 
                     309.68866013878602, 312.88648465066399, 
                     315.62856964498701, 305.18644828128902, 
                     301.67726459442002, 298.27365484150602, 
                     296.94067941504301, 295.19297682286498],
               'c': [0.0, 0.096574721981473793, 0.033309244848328499, 
                     0.049944280680111898, 0.066551912829378099, 
                     0.083128319764681893, 0.083182861094436802, 
                     0.23746748822993499, 0.083235494180686001, 
                     0.083247641811213399, 0.15918488599666999]}
        
        x_0_guess = dict([('c', 0.), ('T', 300.)])
        dx_0 = [('der(c)', 0.0166666666667671), ('der(T)', 0.00083333333331231396)]
        c_0 = []
        #Get the names for the inputs and measured variables
        meas_names = res.keys()
        input_names = u.keys()
        #Define the time vector and sample_time
        nbr_of_points = 11
        sim_time = 10.0
        sample_time = sim_time/(nbr_of_points - 1)
        time = N.linspace(0.,sim_time,nbr_of_points)
        horizon = 5
        ##Create the objects
        op = transfer_optimization_problem(self.CSTR_cpath, 
                                           self.CSTR_fpath, 
                                           accept_model = True, 
                                           compiler_options = \
                                           {"state_initial_equations":True,
                                            "propagate_derivatives":False,
                                            "common_subexp_elim":False})
        MHE_opts = MHEOptions()
        #Process noise and input specifications
        MHE_opts['process_noise_cov'] = [('Tc', 1.)]
        MHE_opts['input_names'] = ['Tc']
        #Measurement properties
        MHE_opts['measurement_cov'] = [(['c','T'], 
                                                  N.array([[10., 0.0], 
                                                           [0.0, 1.]]))]
        #Error covariance matrix
        MHE_opts['P0_cov'] = [('c',10.),('T', 5.)]
        MHE_object = MHE(op, sample_time, horizon, x_0_guess, 
                         dx_0, c_0, MHE_opts)
        #Add the constraint
        c_var = op.getVariable('c').getVar()
        constr = mc.Constraint(c_var, MX(0), 2)
        op.setPathConstraints([constr])
        
        #Tolerance
        small = 1e-4
        #Start estimating
        for k in range(1, nbr_of_points):
            y_in = []
            for name in meas_names:
                y_in.append((name, y[name][k-1]))
            u_in = []
            for name in input_names:
                u_in.append((name, u[name][k-1]))
            x_est_t = MHE_object.step(u_in, y_in)
            for name in meas_names:
                #Check that the estimation match the expected values
                assert(N.abs(x_est_t[name] - res[name][k]) < small) == True
    
        


