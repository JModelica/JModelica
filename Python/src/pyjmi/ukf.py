#!/usr/bin/env python
# -*- coding: utf-8 -*-

#    Copyright (C) 2014 Modelon AB
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
Unscented Kalman Filter module
"""

import numpy as N
import scipy as S
import types 
from scipy.sparse import lil_matrix, linalg
from pyfmi.common.algorithm_drivers import OptionBase, InvalidAlgorithmOptionException, UnrecognizedOptionError
import collections
from pyfmi.fmi import FMUException
from assimulo.solvers.sundials import CVodeError 
import random

class UKF:
    """A class representing a Non-augmented Unscented Kalman Filter.
    
    The sigma point distribution is chosen according to the method described in 
    "Unscented Kalman Filter for Nonlinear Estimation" by E.A Wan and 
    R. van der Merwe (2000).
    
    The algorithm is the non-augmented version described in 
    "Unscented Kalman Filter using Augmented State in Presence of Additive Noise"
    by Fuming, S. et al. (2009)
    
    NOTES: 
    -All random disturbances are considered additive, uncorrelated and zero-mean.
    
    -All states and measurements are indexed in alphabetical order internally
    when represented in arrays.
    
    -Inputs must be in the form of a tuple according to FMI standard for simulation, example:
        input_traj = N.transpose(N.vstack((t, u1, u2))) #time, input 1 and input 2 in a matrix
        input = (['u1', 'u2'], input_traj)    #Input to predict step
        
    -All variables are scaled down internally with their nominal values
    
    Attributes:
        model -- Observer model (FMUModel)
        options -- UKF options containing covariances and weight parameters (UKFOptions)
        h -- Sampling interval in seconds (float)
        currTime -- The current time in the observer model (float)
        x  -- Contains the current state estimates, sorted alphabetically ([ScaledVariable])
        mes -- Contains the measured variables ([ScaledVariable])
        P --  Estimated state covariance matrix (numpy.array)
        P_v -- Assumed process noise covariance matrix (numpy.array)
        P_n -- Assumed measurement noise covariance matrix (numpy.array)
        Wm -- Weights for mean calculation (numpy.array)
        Wc -- Weights for covariance calculation (numpy.array)
        K -- Kalman filter gain (numpy.array)
        xp -- The a priori predicted state estimates (numpy.array)
        yp -- The a priori predicted measurements (numpy.array)
        fails -- Dict containing the number of failed sigma-point simulations at each time instance ({float:int})
    """
    
    def __init__(self, model, x_0, measurements, h, options):
        """Constructor
        
            Arguments:
            model -- Observer model (FMUModel)
            x_0  -- Initial state estimate vector ({string:float})
            measurements -- A list of the measured states ([string])
			h -- Sample interval (float)
			options -- UKF options containing initial covariances and parameters (UKFOptions)
            
        """
       
        #Assign attributes        
        self.model = model
        self.options = options.copy()
        self.h = h
        self.currTime = 0.0
       
        #Form sorted list of scaled state variables
        x = []
        for state in x_0:
            x = x + [ScaledVariable(state, x_0[state], model.get_variable_nominal(state))]
        self.x = sorted(x, key=ScaledVariable.get_name)
       
        #Form sorted list of scaled measurement variables
        mes = []
        for var in measurements:
            mes = mes + [ScaledVariable(var, 0.0, model.get_variable_nominal(var))]
        self.mes = sorted(mes, key=ScaledVariable.get_name)
        
        #Form the state covariance matrix with scaled covariances
        P = N.eye(len(options['P_0']))
        for i,state in enumerate(self.x):
            P[i,i] = options['P_0'][state.get_name()]/state.get_nominal_value()**2
        self.P = P
        
        #Form the process noise covariance matrix with scaled covariances
        P_v = N.eye(len(options['P_v']))
        for i,state in enumerate(self.x):
            P_v[i,i] = options['P_v'][state.get_name()]/state.get_nominal_value()**2
        self.P_v = P_v
        
        #Form the measurement noise covariance matrix with scaled covariances
        P_n = N.eye(len(options['P_n']))
        for i,measurement in enumerate(self.mes):
            P_n[i,i] = options['P_n'][measurement.get_name()]/measurement.get_nominal_value()**2
        self.P_n = P_n
        
        #Form Kalman gain, predicted state vector, predicted measurement vector and fails dict
        self.K = N.zeros((len(self.x),len(self.mes)))
        self.xp = N.zeros((len(self.x),1))
        self.yp = N.zeros((len(self.mes),1))
        self.fails = {}
        
        #Calculate and assign sigma point weights
        [Wm, Wc] = self._calc_weights(options)                                      
        self.Wm = Wm
        self.Wc = Wc 
        
        #Make sure the model is properly reset
        self.model.reset()
        
    def _calc_weights(self, options):
        """Calculate weights for sigma points. 
        Needs to be done only when changing parameters of alpha, beta and kappa
        
            Arguments:
            options -- current options for the UKF (UKFOptions)
            
            Returns:
            Wm -- Weights for mean calculation (numpy.array) 
            Wc -- Weights for covariance calculation (numpy.array)
            
        """
        
        L = len(options['P_0']) #Dimension of state vector
        lambd = (options['alpha']**2) * (L + options['kappa']) - L   
        c = L + lambd
        Wm = (0.5 / c) * N.ones(2 * L + 1)
        Wm[0] = lambd / c  
        Wc = N.copy(Wm)
        Wc[0] = Wc[0] + (1.0 - options['alpha']**2 + options['beta'])
        return [N.copy(Wm), N.copy(Wc)]
    
    def update_options(self, *args, **kw):
        """Updates the options and the sigma point weights
        
        """
        
        #Update options attribute
        self.options.update(*args, **kw)
        
        #Update weights
        [Wm, Wc] = self._calc_weights(self.options)
        self.Wm = Wm
        self.Wc = Wc
        
        #Update noise covariances
        P_v = N.eye(len(self.options['P_v']))
        for i,state in enumerate(self.x):
            P_v[i,i] = self.options['P_v'][state.get_name()]/state.get_nominal_value()**2
        self.P_v = P_v
        
        P_n = N.eye(len(self.options['P_n']))
        for i,measurement in enumerate(self.mes):
            P_n[i,i] = self.options['P_n'][measurement.get_name()]/measurement.get_nominal_value()**2
        self.P_n = P_n
        
    def get_options(self):
        """Returns a copy of the current options for the UKF.
        
            Returns:
            options -- The current options of the UKF (UKFOptions)
        
        """
        
        return self.options.copy()
        
    def _calc_sigma(self, x, P, P_v, P_n, options):
        """Calculates the sigma points for a state estimate vector.
            
            Arguments:
            x -- Current state estimate vector ([ScaledVariable])
            P -- Current scaled estimate of state covariance (numpy.array)
            P_v -- Scaled process noise covariance (numpy.array)
            P_n -- Scaled measurement noise covariance (numpy.array)
            options -- options containing weight parameters (UKFOptions)
            
            Returns:
            sigma -- the sigma matrix, whose columns corresponds to the sigma points.
       
       """
        
        #State vector dimension
        L = len(options['P_0'])                                              
        
        #Represent current state estimate as an array
        x_a = []
        for state in x:
            x_a = x_a + [state.get_scaled_value()]
        x_a = N.array(x_a)                                                                           
        
        #Calculate the cholesky decomposition of the covariance matrix
        P = P * (options['alpha']**2) * (L + options['kappa'])
        
        try:
            P_sqrt = S.linalg.cholesky(P, lower = True)
        except N.linalg.LinAlgError:
            print 'The covariance matrix was not positive definite:'
            print 'P = '
            print P
            raise
   
        #Calculate sigma matrix
        sigma = N.zeros((L, 2 * L + 1))
        sigma[:,0] = x_a                      #First sigma point is the estimated augmented state vector
        for i in range(1, L + 1):
            sigma[:,i] = x_a + P_sqrt[:,(i-1)]
        for i in range(L + 1, 2 * L + 1):
            sigma[:,i] = x_a - P_sqrt[:,i - (L + 1)] 
        return sigma
        
    def update(self,y):
        
        """Public method for updating the a priori estimate with info from the latest measurement.
        Calls _update.
            
            Argument:
            y -- Measurements (non-scaled) ({string:float})
            
            Returns:
            x -- State estimate (non-scaled) ({string:float})
        
        """
        
        #Sort measurements alphabetically and extract values into scaled form
        y = collections.OrderedDict(sorted(y.items(), key = lambda t: t[0]))
        y_scaled = []
        for measurement in self.mes:
            y_scaled = y_scaled + [y[measurement.get_name()]/measurement.get_nominal_value()]
        y_scaled = N.array(y_scaled)
        y_scaled = N.reshape(y_scaled, (-1,1))
    
        #Retrieve updated scaled state estimate vector
        x_scaled = self._update(y_scaled, self.xp, self.yp, self.K)  
   
        #Set new values in list of states, and return a dictionary with the actual values
        i = 0
        x_out = {}
        for state in self.x:    
            state.set_scaled_value(x_scaled[i,0])
            x_out[state.get_name()] = state.get_actual_value()
            i = i + 1
        return x_out
        
    def _update(self,y, xp, yp, K):
        
        """Updates the a priori estimate with info from the latest measurement.
        
            Arguments:
            y -- Scaled measurements (numpy.array)
            xp -- Scaled predicted state estimation vector (numpy.array)
            yp -- Scaled predicted measurement (numpy.array)
            K -- Scaled Kalman filter gain (numpy.array))
            
            Returns:
            x -- Updated scaled state estimation vector (numpy.array)
        
        """
        x = xp + K.dot(y - yp)
        
        return x
    
    def predict(self, u=(), known_values={}):
    
        """Public wrapper method for predicting the state estimate at the next sample instant.
        Calls _predict.
        
            Arguments:
            u -- Input trajectory to process model (([string], numpy.array))
            known_values -- A dict containing known state values ({string:float})
        """
    
        #Calculate sigma points
        sigma = self._calc_sigma(self.x, self.P, self.P_v, self.P_n, self.options)  
 
        #Do a prediction of states and measurements, and calculate Kalman filter gain
        [xp, yp, K, P] = self._predict(sigma, self.model, self.x, u, known_values, self.P_v, self.P_n, self.currTime, self.h, self.mes, self.Wm, self.Wc)
    
        #Update attributes
        self.currTime = self.currTime + self.h
        self.xp = xp
        self.yp = yp
        self.K = K
        self.P = P
    
    def _predict(self, sigma, model, x, u, known_values, P_v, P_n, currTime, h, measurements, Wm, Wc):
        """"Predict the state estimate at the next sample instant.
        
            Arguments:
            sigma -- the sigma matrix, whose columns corresponds to the sigma points of the
            augmented state vector. (numpy.array)
            model -- Observer model (FMUModel)
            x -- The current state estimates ([ScaledVariable])
            u -- Input trajectory to the process model (([string], numpy.array))
            known_values -- Known state values ({string:float})
            P_v -- Assumed process noise covariance matrix (numpy.array)
            P_n -- Assumed measurement noise covariance matrix (numpy.array)
            currTime -- Current time instant (float)
            h -- Sample interval in seconds (float)
            measurements -- Contains the measured variables ([ScaledVariable])
            Wm -- Weights for mean calculation (numpy.array) 
            Wc -- Weights for covariance calculation (numpy.array)
            
			Returns:
            xp -- The scaled a priori predicted states (numpy.array)
            yp -- The scaled a priori predicted measurements (numpy.array)
            K -- The scaled Kalman filter gain (numpy.array)
            P -- The scaled estimated state covariance matrix (numpy.array)
            
        """
        
        #Calculate sigma matrix and extract sigma points
        L_meas = len(measurements)      
     
        #Produce prediction of state estimate and measurement
        Xxp = N.zeros(sigma.shape)
        Y = N.zeros([L_meas, sigma.shape[1]])
        
        #Simulate each sigma point h seconds
        for i in range(0, sigma.shape[1]):
        
            #If sigma point simulation fails, try perturbing initial value and start again. Maximum 10 times,
            #then use the result of the last simulated sigma point.
            retry = True
            k = 1
			
            while retry:
                retry = False
                #Reset the observer model
                model.reset()
            
                #Set the initial states as the current sigma point
                for j, state in enumerate(x):
                    #If the sigma point has previously failed, try perturbing the state values
                    if k > 1:
                        dist = N.abs(sigma[j,0] - sigma[j,i])                #Distance in this coordinate to mean point
                        sigma[j,i] = sigma[j,i] + random.gauss(0, k*1e-3*dist) #Perturb with 0.1% of distance as std. Increase times k after each iteration.
                    model.set(state.get_name()+'_0', sigma[j,i]*state.get_nominal_value())
                    
                #Set known values
                for known in known_values:
                    model.set(known+'_0', known_values[known])
                    
                #Simulate and extract result
                opt = model.simulate_options()
                opt['CVode_options']['atol'] = 1e-8
                opt['CVode_options']['rtol'] = 1e-6
                print 'Simulating sigma-point '+str(i+1)+' out of '+str(sigma.shape[1])+' :'
                try:
                    result = model.simulate(start_time = currTime, final_time = currTime + h, options = opt, input = u)
                except (CVodeError, ValueError, FMUException) as e:
                    print e
                    retry = True
                    print 'Failed sigma point simulation'
                    if k == 1:
                        if currTime in self.fails.keys():
                            self.fails[currTime] = self.fails[currTime] + 1
                        else:
                            self.fails[currTime] = 1
                    if k == 10:
                        print 'Simulation failed 10 times, will use result from last sigma point instead'
                        break
                k = k + 1
			
            #Assign result to matrix, and add process noise. Initialize anew so that all variables are updated
            for k, state in enumerate(x):
                Xxp[k,i] = result[state.get_name()][-1]/state.get_nominal_value()             
     
            #Assign measurements and add measurement noise
            for k, meas in enumerate(measurements):
                Y[k,i] = result[meas.get_name()][-1]/meas.get_nominal_value()
        
        #Compute predictions and covariances
        xp = N.multiply(Wm, Xxp[:])                         #Multiply each point with corresponding weight
        yp = N.multiply(Wm, Y[:])
        xp = xp.sum(axis = 1)                               #Produce the weighted sum
        yp = yp.sum(axis = 1) 
        xp = N.reshape(xp, (-1,1))                          #Make them 2-D column vectors
        yp = N.reshape(yp, (-1,1))
        
        Pxx = N.zeros((Xxp.shape[0],Xxp.shape[0]))          #State covariance
        Pyy = N.zeros((Y.shape[0],Y.shape[0]))              #Measurement covariance
        Pxy = N.zeros((Xxp.shape[0],Y.shape[0]))            #Cross-covariance
        
        for i in range(0,Xxp.shape[1]):
            x_dev = N.reshape(Xxp[:,i],(-1,1)) - xp
            y_dev = N.reshape(Y[:,i], (-1,1))- yp     
            Pxx = Pxx + self.Wc[i] * N.outer(x_dev, x_dev)
            Pyy = Pyy + self.Wc[i] * N.outer(y_dev, y_dev)
            Pxy = Pxy + self.Wc[i] * N.outer(x_dev,y_dev)
        
        Pxx = Pxx + P_v
        Pyy = Pyy + P_n
     
        #Calculate Kalman filter gain
        if Pyy.shape[0] == 1 or Pyy.shape[1] == 1:
            invPyy = 1 / Pyy    
        else:
            invPyy = N.linalg.solve(Pyy,N.eye(Pyy.shape[0]))
        
        K = Pxy.dot(invPyy)
        
        #Calculate state covariance
        P = Pxx - K.dot(Pyy.dot(K.T))
        return [xp, yp, K, P]
        
class UKFOptions(OptionBase):
    """Class containing covariance matrices and weight parameters for the UKF.
    The covariance matrices are considered diagonal, with the variance of each
    state or disturbance on state/measurement represented in a dict with the 
    state/measurement name as key and variance as value.
    
    Extends pyfmi.common.algorithm_drivers.OptionsBase
    
    Attributes:
        P_0 -- Initial state estimate covariance matrix ({string:float})
        P_v -- Process noise covariance matrix ({string:float})
        P_n -- Measurement noise covariance matrix ({string:float})
        alpha -- Scaling parameter for distribution of sigma points, should be
            between 0 and 1 (float)
        beta -- Parameter for including prior knowledge of state variance, 
            where beta = 2 is optimal for Gaussian distributions (float)
        kappa -- Secondary scaling parameter, used to ensure semi-positive definiteness
            of covariance matrix. Usually set to zero (float)
    """
    
    def __init__(self, *args, **kw):
        """ Constructor
        """
      
        #Set default values, and then update to user input arguments
        defaults = {'P_0': {} , 'P_v': {}, 'P_n': {}, 'alpha': 1e-3, 'beta': 2.0, 'kappa':0.0}
        super(UKFOptions, self).__init__(defaults)
        
        #Update options with user input
        self.update(*args, **kw)
            
    def __setitem__(self, key, value):
        """Set a specific option for the UKF
        
            Arguments:
            key -- Specifies which parameter that should be updated (string)
            value -- The new value that should be assigned 
                ({string:float} for covariances, float for weights)
        """
        
        #Check if key is valid
        if key not in self:
            raise UnrecognizedOptionError(str(key)+' is not a valid option.')
        
        #If user put value as int, convert to float
        if (key == 'alpha' or key == 'beta' or key == 'kappa') and type(value) == int:
            value = float(value)
        
        if (key == 'P_0' or key == 'P_v' or key == 'P_n') and type(value) == dict:
            for var in value.keys():
                if type(value[var]) == int:
                    value[var] = float(value[var])
                elif type(value[var]) != float and type(value[var]) != N.float64:
                    raise InvalidAlgorithmOptionException('All values in '+str(key)+' must be floats or ints') 
        
        #Check for invalid option argument
        if not (type(self[key]) == type(value)):
            raise InvalidAlgorithmOptionException('Expected '+str(type(self[key]))+' for '+str(key)+' but got '+str(type(value)))   
        
        #Set the option
        super(UKFOptions, self).__setitem__(key, value)
    
    def update(self, *args, **kw):
        """Update the options for the UKF"""
        
        #Check for invalid options and arguments
        keys = kw.keys()
        for key in keys:
            value = kw[key]
            if key not in self:
                raise UnrecognizedOptionError(str(key)+' is not a valid option.')
            elif (key == 'alpha' or key == 'beta' or key == 'kappa') and type(value) == int:
                value = float(value)
            elif (key == 'P_0' or key == 'P_v' or key == 'P_n') and type(value) == dict:
                for var in value.keys():
                    if type(value[var]) == int:
                        value[var] = float(value[var])
                    elif type(value[var]) != float:
                        raise InvalidAlgorithmOptionException('All values in '+str(key)+' must be floats or ints') 
            if not type(self[key]) == type(value):
                raise InvalidAlgorithmOptionException('Expected '+str(type(self[key]))+' for '+str(key)+' but got '+str(type(kw[key])))   
     
            
        
        #Update the options
        super(UKFOptions, self).update(*args, **kw)
        
class ScaledVariable:
    
    """A class representing a state or measurement variable, scaled with its nominal value
    
    Attributes:
        name -- Name of variable (string)
        nominal_value -- Nominal value of the variable (float)
        actual_value -- Unscaled value of the variable (float)
    
    """
    
    def __init__(self, name, value, nominal_value):
        """Constructor
            Arguments:
            name -- Name of variable (string)
            value -- Unscaled value of variable (float)
            nominal_value -- Nominal value of variable (float)
        
        """
    
        self.name = name
        self.actual_value = float(value)
        self.nominal_value = float(nominal_value)
        
    def get_name(self):
        return self.name
    
    def __str__(self):
        return '{' +self.name + ' | Value : '+str(self.actual_value)+' | Nominal : '+str(self.nominal_value)+'}\n'
    
    def __repr__(self):
        return '{' +self.name + ' | Value : '+str(self.actual_value)+' | Nominal : '+str(self.nominal_value)+'}\n'
        
    def set_actual_value(self, actual_value):
        self.actual_value = float(actual_value)
        
    def set_scaled_value(self, scaled_value):
        self.actual_value = scaled_value * self.nominal_value
        
    def get_scaled_value(self):
        return self.actual_value/self.nominal_value
    
    def get_actual_value(self):
        return self.actual_value
    
    def get_nominal_value(self):
        return self.nominal_value
        
        