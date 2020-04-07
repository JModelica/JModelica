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
import numpy as N
import matplotlib.pyplot as plt

from pyfmi.fmi import FMUModelME1
from pyjmi.optimization import dfo

curr_dir = os.path.dirname(os.path.abspath(__file__));

# Load measurement data from file
data = loadmat(os.path.join(curr_dir, 'files', 'FurutaData.mat'), appendmat=False)

# Extract data series
t_meas = data['time'][:,0]
phi_meas = data['phi'][:,0]
theta_meas = data['theta'][:,0]

# Define the objective function
def furuta_dfo_cost(x):

    # We need to scale the inputs x down since they are scaled up 
    # versions of the parameters (x = scalefactor*[param1 param2])
    armFrictionCoefficient = x[0]/1e3
    pendulumFrictionCoefficient = x[1]/1e3
    
    model = FMUModelME1(os.path.join(curr_dir, 'files', 'FMUs', 'Furuta.fmu'))

    # Set new parameter values into the model 
    model.set('armFriction', armFrictionCoefficient)
    model.set('pendulumFriction', pendulumFrictionCoefficient)
    
    # Create options object and set verbosity to zero to disable printouts
    opts = model.simulate_options()
    opts['CVode_options']['verbosity'] = 50
    opts['ncp'] = 800
    opts['filter'] = ['armJoint.phi', 'pendulumJoint.phi'] 
    
    # Simulate model response with new parameter values
    res = model.simulate(start_time=0., final_time=40, options=opts)

    # Load simulation result
    phi_sim = res['armJoint.phi']
    theta_sim = res['pendulumJoint.phi']
    t_sim  = res['time']
    
    # Evaluate the objective function
    y_meas = N.vstack((phi_meas, theta_meas))
    y_sim = N.vstack((phi_sim, theta_sim))

    obj = dfo.quad_err_simple(t_meas, y_meas, t_sim, y_sim)

    return obj

def run_demo(with_plots=True):
    
    # Choose starting point (initial estimation)
    x0 = N.array([0.012,0.002])

    # Choose lower and upper bounds (optional)
    lb = N.zeros(2)
    ub = x0 + 1e-2

    x_opt,f_opt,nbr_iters,nbr_fevals,solve_time = dfo.nelme_modified(furuta_dfo_cost,xstart=x0*1e3,
                                                            lb=lb,ub=ub*1e3,
                                                            x_tol=1e-3,f_tol=1e-2,debug=False)
    [armFrictionCoefficient_opt,pendulumFrictionCoefficient_opt] = x_opt/1e3
    
    # Load model
    model = FMUModelME1(os.path.join(curr_dir, 'files', 'FMUs', 'Furuta.fmu'), enable_logging=False)
    
    # Set optimal parameter values into the model
    model.set('armFriction', armFrictionCoefficient_opt)
    model.set('pendulumFriction', pendulumFrictionCoefficient_opt)
    
    opts = model.simulate_options()
    opts['filter'] = ['armJoint.phi', 'pendulumJoint.phi']
    
    # Simulate model response with optimal parameter values
    res = model.simulate(start_time=0., final_time=40)
    
    # Load optimal simulation result
    phi_opt = res['armJoint.phi']
    theta_opt = res['pendulumJoint.phi']
    t_opt  = res['time']
    
    assert N.abs(res.final('armJoint.phi') + 0.309)      < 3e-2
    assert N.abs(res.final('pendulumJoint.phi') - 3.130) < 3e-2
    assert N.abs(res.final('time') - 40.0)               < 1e-3
    
    if with_plots:
        plt.figure(1)
        plt.subplot(2,1,1)
        plt.plot(t_opt, theta_opt, linewidth=1, label='Simulation optimal parameters')
        plt.plot(t_meas, theta_meas, linewidth=1, label='Physical data')
        plt.legend()
        plt.subplot(2,1,2)
        plt.plot(t_opt, phi_opt, linewidth=1, label='Simulation optimal parameters')
        plt.plot(t_meas, phi_meas, linewidth=1, label='Physical data')
        plt.legend()
        plt.show()

if __name__=="__main__":
    run_demo()
