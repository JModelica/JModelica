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
"""
Tests for the UKF, UKFOptions and ScaledVariable classes.
"""
import sys
from pyjmi.ukf import UKF, ScaledVariable, UKFOptions
from tests_jmodelica import testattr, get_files_path
from pymodelica import compile_fmu
from pyfmi import load_fmu
import numpy as N
import random
import os
from pyfmi.common.algorithm_drivers import OptionBase, InvalidAlgorithmOptionException, UnrecognizedOptionError
from nose.tools import assert_raises


fmu = None
def get_fmu():
    global fmu
    if fmu is None:
    #Compile model used in tests to fmu
        fmu = compile_fmu('VDP_pack.VDP',get_files_path()+'/Modelica/VDP.mop', separate_process = True)
    return fmu


@testattr(stddist_full = True)
class Test_ScaledVariable:
    def setUp(self):
        self.var = ScaledVariable('x',100,8)
    
    def tearDown(self):
        self.var = None
        
    def test_get(self):  
        #Test get-methods
        assert self.var.get_name() == 'x'
        assert self.var.get_scaled_value() == 12.5
        assert self.var.get_actual_value() == 100.0
        assert self.var.get_nominal_value() == 8.0
    
    def test_set_actual(self):
        #Test setting new actual value
        self.var.set_actual_value(200)
        assert self.var.get_name() == 'x'
        assert self.var.get_scaled_value() == 25.0
        assert self.var.get_actual_value() == 200.0
        assert self.var.get_nominal_value() == 8.0
        
    def test_set_scaled(self):
        #Test setting new scaled value
        self.var.set_scaled_value(12.5)
        assert self.var.get_name() == 'x'
        assert self.var.get_scaled_value() == 12.5
        assert self.var.get_actual_value() == 100
        assert self.var.get_actual_value() == 100.0
        assert self.var.get_nominal_value() == 8
        assert self.var.get_nominal_value() == 8.0
        
    def test_string(self):
        #Test string representation
        assert str(self.var) == '{x | Value : 100.0 | Nominal : 8.0}\n'


@testattr(stddist_full = True)
class Test_UKFOptions:
    def setUp(self):
        self.opt = UKFOptions()
    
    def tearDown(self):
        self.opt = None
        
    def test_setitem_correct_args(self):
        #Test setting float and int values on parameters and covariances
        self.opt.__setitem__('alpha', 1)
        self.opt.__setitem__('beta', 3)
        self.opt.__setitem__('kappa', -0.3)
        self.opt.__setitem__('P_0', {'x1':0.1, 'x2':3.5})
        self.opt.__setitem__('P_v', {'x1':0.3, 'x2':3.7})
        self.opt.__setitem__('P_n', {'measurement':10})
       
        assert self.opt['alpha'] == 1.0
        assert type(self.opt['alpha']) == float
        assert self.opt['beta'] == 3.0
        assert type(self.opt['beta']) == float
        assert self.opt['kappa'] == -0.3
        assert self.opt['P_0']['x1'] == 0.1
        assert self.opt['P_0']['x2'] == 3.5
        assert self.opt['P_v']['x1'] == 0.3
        assert self.opt['P_v']['x2'] == 3.7
        assert self.opt['P_n']['measurement'] == 10.0
        assert type(self.opt['P_n']['measurement']) == float

    def test_setitem_incorrect_args(self):
        #Test setting string value instead of float/int
        assert_raises(InvalidAlgorithmOptionException, self.opt.__setitem__, 'alpha', 'a')
        
        #Test setting list instead of dict
        assert_raises(InvalidAlgorithmOptionException, self.opt.__setitem__, 'P_0', ['x1','1.0'])
        
        #Test setting non-existent argument
        assert_raises(UnrecognizedOptionError, self.opt.__setitem__, 'P', {'x1':0.3})
        
        #Test setting wrong value in covariance dict
        assert_raises(InvalidAlgorithmOptionException, self.opt.__setitem__, 'P_0', {'x1':'a'})

    def test_update_correct_args(self):
        #Test updating float and int values on parameters and covariances
        self.opt.update(alpha=1)
        self.opt.update(beta=3)
        self.opt.update(kappa=-0.3)
        self.opt.update(P_0= {'x1':0.1, 'x2':3.5})
        self.opt.update(P_v={'x1':0.3, 'x2':3.7})
        self.opt.update(P_n={'measurement':10})
       
        assert self.opt['alpha'] == 1.0
        assert type(self.opt['alpha']) == float
        assert self.opt['beta'] == 3.0
        assert type(self.opt['beta']) == float
        assert self.opt['kappa'] == -0.3
        assert self.opt['P_0']['x1'] == 0.1
        assert self.opt['P_0']['x2'] == 3.5
        assert self.opt['P_v']['x1'] == 0.3
        assert self.opt['P_v']['x2'] == 3.7
        assert self.opt['P_n']['measurement'] == 10.0
        assert type(self.opt['P_n']['measurement']) == float


    def test_update_incorrect_args(self):
        #Test setting string value instead of float/int
        assert_raises(InvalidAlgorithmOptionException, self.opt.update, alpha='a')
        
        #Test setting list instead of dict
        assert_raises(InvalidAlgorithmOptionException, self.opt.update, P_0=['x1','1.0'])
        
        #Test setting non-existent argument
        assert_raises(UnrecognizedOptionError, self.opt.update, P={'x1':0.3})
        
        #Test setting wrong value in covariance dict
        assert_raises(InvalidAlgorithmOptionException, self.opt.update, P_0={'x1':'a'})


@testattr(stddist_full = True)
class Test_Create_UKF:
    def setUp(self):
        self.model = load_fmu(get_fmu())
        self.x_0 = {'x2':0, 'x1':1}
        measurements = ['x1']
        h = 0.01
        self.options = UKFOptions()
        self.options.update(P_0={'x2':1, 'x1':2})
        self.options.update(P_v={'x2':1e-3, 'x1':1e-1})
        self.options.update(P_n={'x1':1e-4})
        self.ukf = UKF(self.model, self.x_0, measurements, h, self.options)
        
    def tearDown(self):
        self.model = None
        self.ukf = None
        self.x_0 = None
        self.options = None
        
    def test_create_ukf(self):
        
        #Test that initialization of scaled state estimate vector is correct
        names = []
        for state in self.ukf.x:
            names = names + [state.get_name()]
        assert names == ['x1','x2']
        
        for state in self.ukf.x:
            assert state.get_actual_value() == self.x_0[state.get_name()]
            assert type(state.get_actual_value()) == float 
            assert state.get_nominal_value() == self.model.get_variable_nominal(state.get_name())
            assert type(state.get_nominal_value()) == float
        
        #Test that initialization of measurement vector is correct
        names = []
        for meas in self.ukf.mes:
            names = names + [meas.get_name()]
        assert names == ['x1']
        
        for meas in self.ukf.mes:
            assert meas.get_nominal_value() == self.model.get_variable_nominal(meas.get_name())
            assert type(meas.get_nominal_value()) == float
        
        #Test that initialization of covariance matrices is correct
        assert N.all(self.ukf.P == N.array([[2.0/self.model.get_variable_nominal('x1'), 0.0],[0.0, 1.0/self.model.get_variable_nominal('x2')]]))
        assert N.all(self.ukf.P_v == N.array([[1e-1/self.model.get_variable_nominal('x1'), 0.0],[0.0, 1e-3/self.model.get_variable_nominal('x2')]]))
        assert N.all(self.ukf.P_n == N.array([1e-4/self.model.get_variable_nominal('x1')]))
        
    def test_calc_weights(self):
        #Test that the weights are calculated correctly
        [Wm, Wc] = self.ukf._calc_weights(self.options)
        assert N.all(Wm == N.array([-9.999989999712444e05, 2.499999999928111e05, 2.499999999928111e05,
            2.499999999928111e05, 2.499999999928111e05]))
        assert N.all(Wc == N.array([-9.999959999722444e+05, 2.499999999928111e05, 2.499999999928111e05,
            2.499999999928111e05, 2.499999999928111e05]))
        
    def test_update_options(self):
        #Test that weights and covariances are updated correctly
        self.ukf.update_options(alpha=1.0, beta=0.0, P_v={'x2':1e-2, 'x1':1e-3})
        assert N.all(self.ukf.Wm == N.array([0.0, 0.25, 0.25, 0.25, 0.25]))
        assert N.all(self.ukf.Wc == N.array([0.0, 0.25, 0.25, 0.25, 0.25]))
        assert N.all(self.ukf.P_v == N.array([[1e-3/self.model.get_variable_nominal('x1'), 0.0],[0.0, 1e-2/self.model.get_variable_nominal('x2')]]))
        
    def test_get_options(self):
        assert self.options == self.ukf.get_options()

      
@testattr(stddist_full = True)
class Test_AlgorithmMethods_UKF:
    def setUp(self):
        self.model = load_fmu(get_fmu())
        self.x_0 = {'x2':0, 'x1':1}
        measurements = ['x1']
        h = 0.01
        self.options = UKFOptions()
        self.options.update(P_0={'x2':1, 'x1':2})
        self.options.update(P_v={'x2':1e-3, 'x1':1e-1})
        self.options.update(P_n={'x1':1e-4})
        self.ukf = UKF(self.model, self.x_0, measurements, h, self.options)
        
    def tearDown(self):
        self.model = None
        self.ukf = None
        self.x_0 = None
        self.options = None 
    
    def test_calc_sigma(self):
        #Test that sigma points are calculated correctly
        sigma = self.ukf._calc_sigma(self.ukf.x, self.ukf.P, self.ukf.P_v, 
            self.ukf.P_n, self.ukf.options)
        assert N.allclose(sigma, N.array([[1.0,   1.002000000000029, 1.0,  0.997999999999971, 1.0],
            [0.0, 0.0,   0.001414213562393, 0.0, -0.001414213562393]]))
            
    def test_update_private(self):
        #Test that the private update method is performed correctly
        K = N.array([[0.1], [0.3]])
        xp = N.array([[1.2],[0.1]])
        yp = N.array([[1.18]])
        y = N.array([[1.24]])
        assert N.allclose(self.ukf._update(y, xp, yp, K), N.array([[1.206000000000000],
            [0.118000000000000]]))
    
    def test_update_public(self):
        #Test that the public update method calculates estimates correctly
        self.ukf.K = N.array([[0.1], [0.3]])
        self.ukf.xp = N.array([[1.2],[0.1]])
        self.ukf.yp = N.array([[1.18]])
        x = self.ukf.update({'x1':1.24})
        assert N.allclose(x['x1'], 1.206000000000000)
        assert N.allclose(x['x2'], 0.118000000000000)
    
    def test_predict_private(self):
        #Produce sigma points
        sigma = self.ukf._calc_sigma(self.ukf.x, self.ukf.P, self.ukf.P_v, 
            self.ukf.P_n, self.ukf.options)
        #Have a constant input of 0.1 over the sample interval
        u = (['u'], N.transpose(N.vstack((0.0,0.1))))
        #No known state values
        known_values = {}
        #Do prediction
        [xp, yp, K, P] = self.ukf._predict(sigma, self.ukf.model, self.ukf.x, u, 
            known_values, self.ukf.P_v, self.ukf.P_n, self.ukf.currTime, self.ukf.h, 
            self.ukf.mes, self.ukf.Wm, self.ukf.Wc)
        
        #Assert predicted mean and measurement
        assert N.allclose(xp, [[1.00988634], [0.0172094]])
        assert N.allclose(yp, N.array([[1.00988634]]))
        
        #Assert covariance and gain
        assert N.allclose(K, [[0.99995099], [0.00497003]])
        assert N.allclose(P, [[1.00099995e-01, 4.97003235e-07],
                              [4.97003235e-07, 1.00115269e+00]])
    
    def test_predict_public(self):
        #Have a constant input of 0.1 over the sample interval
        u = (['u'], N.transpose(N.vstack((0.0,0.1))))
        #No known state values
        known_values = {}
        self.ukf.predict(u, known_values)
        #Assert predicted mean and measurement
        assert N.allclose(self.ukf.xp, [[1.00988634], [0.0172094]])
        assert N.allclose(self.ukf.yp, [[1.00988634]])
        
        #Assert covariance and gain
        assert N.allclose(self.ukf.K, [[0.99995099], [0.00497003]])
        assert N.allclose(self.ukf.P, [[1.00099995e-01, 4.97003235e-07],
                                       [4.97003235e-07, 1.00115269e+00]])
