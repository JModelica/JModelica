#!/usr/bin/env python 
# -*- coding: utf-8 -*-

# Copyright (C) 2014 Modelon AB, all rights reserved.

import os

from scipy.io.matlab.mio import loadmat
import numpy as N
import matplotlib.pyplot as plt
from pymodelica import compile_fmu
from pyfmi import load_fmu

curr_dir = os.path.dirname(os.path.abspath(__file__));

def run_demo(with_plots=True):
    # Load measurement data from file
    data = loadmat(os.path.join(curr_dir, 'files', 'FurutaData.mat'), appendmat=False)

    # Extract data series
    t_meas = data['time'][:,0]
    phi_meas = data['phi'][:,0]
    theta_meas = data['theta'][:,0]
    data = N.array([t_meas, phi_meas, theta_meas]).transpose()

    #Compile the model
    name = compile_fmu("Furuta", os.path.join(curr_dir, 'files', 'Furuta.mo'))

    model = load_fmu(name)

    res_opt = model.estimate(parameters=["armFriction", "pendulumFriction"],
                         measurements = (['armJoint.phi', 'pendulumJoint.phi'], data))

    # Set optimal parameter values into the model
    model.set('armFriction', res_opt["armFriction"])
    model.set('pendulumFriction', res_opt["pendulumFriction"])

    opts = model.simulate_options()
    opts['filter'] = ['armJoint.phi', 'pendulumJoint.phi']

    # Simulate model response with optimal parameter values
    res = model.simulate(start_time=0., final_time=40)

    # Load optimal simulation result
    phi_opt = res['armJoint.phi']
    theta_opt = res['pendulumJoint.phi']
    t_opt  = res['time']

    assert N.abs(res.final('armJoint.phi') + 0.313)      < 3e-3
    assert N.abs(res.final('pendulumJoint.phi') - 3.130) < 3e-3
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
