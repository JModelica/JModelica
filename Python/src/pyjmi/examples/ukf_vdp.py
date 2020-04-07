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
Demo of the UKF class using the Van-der-Pol Oscillator model.
"""

# Import JModelica.org packages
from pymodelica import compile_fmu
from pyfmi import load_fmu
from tests_jmodelica import get_files_path

# Import numerical libraries
import matplotlib.pyplot as plt
import numpy as N
import random
random.seed(1.0)    #Set random seed
import os
import sys

from pyjmi.ukf import UKF, UKFOptions

def run_demo():    
    #Compile model used in tests to fmu
    fmu = compile_fmu('VDP_pack.VDP',get_files_path()+'/Modelica/VDP.mop', 
        separate_process = True)
    model = load_fmu(fmu)               #Observer model
    process = load_fmu(fmu)             #Actual process

    #Set options for UKF
    opt = UKFOptions()
    v1 = 1e-3
    v2 = 1e-3
    n1 = 0.5
    P_v = {'x1':v1, 'x2':v2} #Covariance of process noise
    P_n = {'x1':n1} #covariance of measurement noise
    P_0 = {'x1':1.0, 'x2':1.0}   #Initial state covariance
    alpha = 1.0
    beta = 2.0
    kappa = 0.0
    opt.update(alpha = alpha, beta = beta, kappa = kappa, P_0 = P_0, 
        P_v = P_v, P_n = P_n)

    #Set initial state estimate, measured variables, and sampling interval
    x1_0 = 1.0
    x2_0 = -1.0
    x_0 = {'x1':x1_0, 'x2': x2_0} 
    measurements = ['x1']
    h = 0.1 

    #Create a UKF object
    ukf = UKF(model, x_0, measurements, h, opt)

    #Retrieve simulation options for the process
    processOpt = process.simulate_options()
    processOpt['CVode_options']['atol'] = 1e-8
    processOpt['CVode_options']['rtol'] = 1e-6

    #Save time vectors and state values for post-processing
    t_sampled =  [0.0]
    t_sim = [0.0]
    x1_process_sim = [process.get('x1_0')[-1]]
    x2_process_sim = [process.get('x2_0')[-1]]
    x1_process = [process.get('x1_0')[-1]]
    x2_process = [process.get('x2_0')[-1]]
    x1_estimate = [x1_0]
    x2_estimate = [x2_0]
    measurement_vector = [x1_0]

    #Perform simulate iteratively for T samples, and estimate.
    T = 100
    tStart = 0.0

    for i in range(0,T):
        #Make a prediction with the UKF. No input or known state values
        ukf.predict()
        
        #Simulate process for one time-step
        simResProcess = process.simulate(start_time = tStart, 
            final_time = tStart + h, options = processOpt)
        
        #Retrieve last state value of simulation and apply 
            #gaussian process noise
        x1 = simResProcess['x1'][-1] + random.gauss(0, N.sqrt(v1)) 
        x2 = simResProcess['x2'][-1] + random.gauss(0, N.sqrt(v2))
        
        #Apply measurement noise to measurement. Form measurement input
        meas = x1 + random.gauss(0, N.sqrt(n1))
        y = {'x1': meas}
        
        #Perform a measurement update and retrieve the estimates
        x = ukf.update(y) 
        
        #Update the time-step
        tStart = tStart + h
        
        #Update post-processing vectors
        t_sampled = t_sampled + [tStart]
        t_sim = t_sim + simResProcess['time'].tolist()
        x1_process = x1_process + [x1]
        x2_process = x2_process + [x2]
        x1_process_sim = x1_process_sim + simResProcess['x1'].tolist()
        x2_process_sim = x2_process_sim + simResProcess['x2'].tolist()
        x1_estimate = x1_estimate + [x['x1']]
        x2_estimate = x2_estimate + [x['x2']]
        measurement_vector = measurement_vector + [meas]
        
        #Update process starting states for next iteration
        process.reset()
        process.set('x1_0',x1)
        process.set('x2_0',x2)
        
    #Compute MSE
    MSEx1 = N.sum(((N.array(x1_estimate) - N.array(x1_process))**2))/len(x1_estimate)
    MSEx2 = N.sum(((N.array(x2_estimate) - N.array(x2_process))**2))/len(x2_estimate)
    
    print
    print 'Mean square error x1: '+str(MSEx1)
    print 'Mean square error x2: '+str(MSEx2)
    print

    #Plot simulation results
    fig1 = plt.figure(1)
    fig1.clear()
    fig1.hold(True)
    ax1 = fig1.add_subplot(211)
    ax1.set_title('UKF Estimation of the VDP-process')
    actualx1, = ax1.plot(t_sim, x1_process_sim, 'b', label = 'true')
    estimatex1, = ax1.plot(t_sampled, x1_estimate, 'go', label = 'UKF')
    measurex1, = ax1.plot(t_sampled, measurement_vector, 'rx', label = 'Measurement')
    ax1.set_xlabel('time (sec)')
    ax1.set_ylabel('x1')
    ax1.set_xlim([0,h*T])
    ax1.legend([actualx1,estimatex1,measurex1], ["true", "UKF", "Measurement"])
    ax2 = fig1.add_subplot(212)
    ax2.plot(t_sim, x2_process_sim,'b')
    ax2.plot(t_sampled, x2_estimate, 'go')
    ax2.set_ylabel('x2')
    ax2.set_xlim([0,h*T])
    ax2.set_xlabel('time (sec)')
    fig1.show()

    fig2 = plt.figure(2)
    fig2.clear()
    fig2.hold(True)
    ax3 = fig2.add_subplot(211)
    ax3.set_title('Estimation Errors')
    x1err = ax3.plot(t_sampled, N.array(x1_estimate) - N.array(x1_process) , label='x1err')
    ax3.set_xlabel('time (sec)')
    ax3.set_ylabel('Error x1')
    ax3.set_xlim([0,h*T])
    ax4 = fig2.add_subplot(212)
    x2err = plt.plot(t_sampled, N.array(x2_estimate) - N.array(x2_process), label='x2err')
    ax4.set_ylabel('Error x2')
    ax4.set_xlim([0,h*T])
    ax4.set_xlabel('time (sec)')
    fig2.show()
    
if __name__ == "__main__":
    run_demo()