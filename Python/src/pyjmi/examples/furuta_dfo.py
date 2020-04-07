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

import os

from scipy.io.matlab.mio import loadmat
import matplotlib.pyplot as plt
import numpy as N
from matplotlib.font_manager import fontManager, FontProperties

from pyfmi import load_fmu
from pyjmi.optimization import dfo

def run_demo(with_plots=True):
    """
    This example demonstrates how to solve a parameter estimation problem 
    using a derivative-free optimization method. The model to be calibrated
    is a model of a Furuta pendulum. The optimization algorithm used is
    an implementation of the Nelder-Mead simplex algorithm which uses 
    multiprocessing for the function evaluations.
    
    The file furuta_dfo_cost.py is also a part of this example. It contains
    the definition of the objective function.
    
    Note that when this example is run, sub-directories to the current one
    are created, where the function evaluations are performed. These 
    should be manually removed after a run.
    
    The data used in the example was recorded by Kristian Soltesz at the 
    Department of Automatic Control.
    """
    
    curr_dir = os.path.dirname(os.path.abspath(__file__));
    
    # Load measurement data from file
    data = loadmat(os.path.join(curr_dir, 'files', 'FurutaData.mat'), appendmat=False)
    
    # Extract data series
    t_meas = data['time'][:,0]
    phi_meas = data['phi'][:,0]
    theta_meas = data['theta'][:,0]
    
    # Plot measurements
    if with_plots:
        font = FontProperties(size='small')
        plt.figure(1)
        plt.clf()
        plt.subplot(2,1,1)
        plt.plot(t_meas, theta_meas, label='Measurements')
        plt.title('theta [rad]')
        plt.legend(prop=font, loc=1)
        plt.grid()
        plt.subplot(2,1,2)
        plt.plot(t_meas, phi_meas, label='Measurements')
        plt.title('phi [rad]')
        plt.legend(prop=font, loc=1)
        plt.grid()
        plt.show()
    
    # Load model
    model = load_fmu(os.path.join(curr_dir, 'files', 'FMUs', 'Furuta.fmu'))
    
    # Create options object and set verbosity to zero to disable printouts
    opts = model.simulate_options()
    opts['CVode_options']['verbosity'] = 0
    
    # Simulate model response with nominal parameters
    res = model.simulate(start_time=0., final_time=40, options=opts)
    
    # Load simulation result
    phi_sim = res['armJoint.phi']
    theta_sim = res['pendulumJoint.phi']
    t_sim  = res['time']
    
    # Plot simulation result
    if with_plots:
        plt.figure(1)
        plt.subplot(2,1,1)
        plt.plot(t_sim, theta_sim, '--', linewidth=2, label='Simulation nominal parameters')
        plt.legend(prop=font,loc=1)
        plt.subplot(2,1,2)
        plt.plot(t_sim,phi_sim, '--', linewidth=2, label='Simulation nominal parameters')
        plt.xlabel('t [s]')
        plt.legend(prop=font,loc=1)
        plt.show()
    
    # Choose starting point (initial estimation)
    x0 = N.array([0.012,0.002])
    
    # Choose lower and upper bounds (optional)
    lb = N.zeros(2)
    ub = x0 + 1e-2
    
    # Solve the problem using the Nelder-Mead method
    # Scale x0, lb and ub to get order of magnitude 1
    # alg = 1: Nelder-Mead method
    # alg = 2: Sequential barrier method using Nelder-Mead
    # alg = 3: OpenOpt solver "de" (Differential evolution method)
    x_opt,f_opt,nbr_iters,nbr_fevals,solve_time = dfo.fmin(os.path.join(curr_dir, 'furuta_dfo_cost.py'), 
                                                           xstart=x0*1e3, 
                                                           lb=lb*1e3, 
                                                           ub=ub*1e3, 
                                                           alg=1, 
                                                           nbr_cores=1, 
                                                           x_tol=1e-3, 
                                                           f_tol=1e-2)
    
    # Optimal point (don't forget to scale down)
    [armFrictionCoefficient_opt, pendulumFrictionCoefficient_opt] = x_opt/1e3
    
    # Print optimal parameter values and optimal function value
    print 'Optimal parameter values:'
    print 'arm friction coefficient = ' + str(armFrictionCoefficient_opt)
    print 'pendulum friction coefficient = ' + str(pendulumFrictionCoefficient_opt)
    print 'Optimal function value: ' + str(f_opt)
    print ' '
    
    # Load model
    model = load_fmu(os.path.join(curr_dir,'files','FMUs','Furuta.fmu'))
    
    # Set optimal parameter values into the model
    model.set('armFriction', armFrictionCoefficient_opt)
    model.set('pendulumFriction', pendulumFrictionCoefficient_opt)
    
    # Create options object and set verbosity to zero to disable printouts
    opts = model.simulate_options()
    opts['CVode_options']['verbosity'] = 0
    
    # Simulate model response with optimal parameter values
    res = model.simulate(start_time=0., final_time=40, options=opts)
    
    # Load optimal simulation result
    phi_opt = res['armJoint.phi']
    theta_opt = res['pendulumJoint.phi']
    t_opt  = res['time']

    assert N.abs(res.final('armJoint.phi') + 0.314)      < 2e-2
    assert N.abs(res.final('pendulumJoint.phi') - 3.137) < 2e-2
    assert N.abs(res.final('time') - 40.0)               < 1e-3

    # Plot
    if with_plots:
        plt.figure(1)
        plt.subplot(2,1,1)
        plt.plot(t_opt, theta_opt, '-.', linewidth=3, label='Simulation optimal parameters')
        plt.legend(prop=font, loc=1)
        plt.subplot(2,1,2)
        plt.plot(t_opt, phi_opt, '-.', linewidth=3, label='Simulation optimal parameters')
        plt.legend(prop=font, loc=1)
        plt.show()
        
if __name__=="__main__":
    run_demo()

