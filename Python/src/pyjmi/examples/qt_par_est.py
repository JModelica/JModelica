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

from pymodelica import compile_fmu
from pyfmi import load_fmu
from pyjmi.common.core import TrajectoryLinearInterpolation

def run_demo(with_plots=True):
    """
    This example demonstrates how to solve parameter estimation problmes.

    The data used in the example was recorded by Kristian Soltesz at the 
    Department of Automatic Control. 
    """
    
    curr_dir = os.path.dirname(os.path.abspath(__file__));

    # Load measurement data from file
    data = loadmat(curr_dir+'/files/qt_par_est_data.mat',appendmat=False)

    # Extract data series
    t_meas = data['t'][6000::100,0]-60
    y1_meas = data['y1_f'][6000::100,0]/100
    y2_meas = data['y2_f'][6000::100,0]/100
    y3_meas = data['y3_d'][6000::100,0]/100
    y4_meas = data['y4_d'][6000::100,0]/100
    u1 = data['u1_d'][6000::100,0]
    u2 = data['u2_d'][6000::100,0]
        
    # Plot measurements and inputs
    if with_plots:
        plt.figure(1)
        plt.clf()
        plt.subplot(2,2,1)
        plt.plot(t_meas,y3_meas)
        plt.title('x3')
        plt.grid()
        plt.subplot(2,2,2)
        plt.plot(t_meas,y4_meas)
        plt.title('x4')
        plt.grid()
        plt.subplot(2,2,3)
        plt.plot(t_meas,y1_meas)
        plt.title('x1')
        plt.xlabel('t[s]')
        plt.grid()
        plt.subplot(2,2,4)
        plt.plot(t_meas,y2_meas)
        plt.title('x2')
        plt.xlabel('t[s]')
        plt.grid()

        plt.figure(2)
        plt.clf()
        plt.subplot(2,1,1)
        plt.plot(t_meas,u1)
        plt.hold(True)
        plt.title('u1')
        plt.grid()
        plt.subplot(2,1,2)
        plt.plot(t_meas,u2)
        plt.title('u2')
        plt.xlabel('t[s]')
        plt.hold(True)
        plt.grid()

    # Build input trajectory matrix for use in simulation
    u = N.transpose(N.vstack((t_meas,u1,u2)))

    # compile FMU
    fmu_name = compile_fmu('QuadTankPack.Sim_QuadTank', 
        curr_dir+'/files/QuadTankPack.mop')

    # Load model
    model = load_fmu(fmu_name)
    
    # Simulate model response with nominal parameters
    res = model.simulate(input=(['u1','u2'],u),start_time=0.,final_time=60)

    # Load simulation result
    x1_sim = res['qt.x1']
    x2_sim = res['qt.x2']
    x3_sim = res['qt.x3']
    x4_sim = res['qt.x4']
    t_sim  = res['time']
    
    u1_sim = res['u1']
    u2_sim = res['u2']

    # Plot simulation result
    if with_plots:
        plt.figure(1)
        plt.subplot(2,2,1)
        plt.plot(t_sim,x3_sim)
        plt.subplot(2,2,2)
        plt.plot(t_sim,x4_sim)
        plt.subplot(2,2,3)
        plt.plot(t_sim,x1_sim)
        plt.subplot(2,2,4)
        plt.plot(t_sim,x2_sim)

        plt.figure(2)
        plt.subplot(2,1,1)
        plt.plot(t_sim,u1_sim,'r')
        plt.subplot(2,1,2)
        plt.plot(t_sim,u2_sim,'r')


if __name__=="__main__":
    run_demo()
