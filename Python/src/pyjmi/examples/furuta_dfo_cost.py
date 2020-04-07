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

from pyfmi import load_fmu
from pyjmi.optimization import dfo

curr_dir = os.path.dirname(os.path.abspath(__file__));

# Load measurement data from file
data = loadmat(os.path.join(curr_dir, '..', 'examples', 'files', 'FurutaData.mat') ,appendmat=False)
    
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
    
    model = load_fmu(os.path.join(curr_dir, '..', 'examples', 'files', 'FMUs', 'Furuta.fmu'))

    # Set new parameter values into the model 
    model.set('armFriction', armFrictionCoefficient)
    model.set('pendulumFriction', pendulumFrictionCoefficient)
    
    # Create options object and set verbosity to zero to disable printouts
    opts = model.simulate_options()
    opts['CVode_options']['verbosity'] = 0
    
    # Simulate model response with new parameter values
    res = model.simulate(start_time=0., final_time=40, options=opts)
    
    # Load simulation result
    phi_sim = res['armJoint.phi']
    theta_sim = res['pendulumJoint.phi']
    t_sim  = res['time']
    
    # Evaluate the objective function
    y_meas = N.vstack((phi_meas, theta_meas))
    y_sim = N.vstack((phi_sim, theta_sim))
    obj = dfo.quad_err(t_meas, y_meas, t_sim, y_sim)

    return obj
