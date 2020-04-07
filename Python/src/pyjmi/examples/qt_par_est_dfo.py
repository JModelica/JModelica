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

from pymodelica import compile_fmu
from pyfmi import load_fmu
from pyjmi.optimization import dfo

def run_demo(with_plots=True):
    """
    This example demonstrates how to solve parameter estimation problems
    using derivative-free optimization methods.

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
        plt.show()

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
        plt.show()

    # Build input trajectory matrix for use in simulation
    u = N.transpose(N.vstack((t_meas,u1,u2)))

    # compile FMU
    fmu_name = compile_fmu('QuadTankPack.Sim_QuadTank', 
        curr_dir+'/files/QuadTankPack.mo')

    # Load model
    model = load_fmu(fmu_name)
    
    # Create options object and set verbosity to zero to disable printouts
    opts = model.simulate_options()
    opts['CVode_options']['verbosity'] = 0

    # Simulate model response with nominal parameters
    res = model.simulate(input=(['u1','u2'],u),start_time=0.,final_time=60,options=opts)

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
        plt.show()
    
    # ESTIMATION OF 2 PARAMETERS
    
    # Define the objective function
    def f1(x):

        model = load_fmu(fmu_name)

        # We need to scale the inputs x down since they are scaled up 
        # versions of a1 and a2 (x = scalefactor*[a1 a2])
        a1 = x[0]/1e6
        a2 = x[1]/1e6
        
        # Set new values for a1 and a2 into the model 
        model.set('qt.a1',a1)
        model.set('qt.a2',a2)
        
        # Create options object and set verbosity to zero to disable printouts
        opts = model.simulate_options()
        opts['CVode_options']['verbosity'] = 0
        
        # Simulate model response with new parameters a1 and a2
        res = model.simulate(input=(['u1','u2'],u),start_time=0.,final_time=60,options=opts)
        
        # Load simulation result
        x1_sim = res['qt.x1']
        x2_sim = res['qt.x2']
        t_sim  = res['time']
        
        # Evaluate the objective function
        y_meas = N.vstack((y1_meas,y2_meas))
        y_sim = N.vstack((x1_sim,x2_sim))
        obj = dfo.quad_err(t_meas,y_meas,t_sim,y_sim)
        
        return obj

    # Choose starting point (initial estimation)
    x0 = 0.03e-4*N.ones(2)

    # Choose lower and upper bounds (optional)
    lb = x0 - 1e-6
    ub = x0 + 1e-6

    # Solve the problem using the Nelder-Mead method
    # Scale x0, lb and ub to get order of magnitude 1
    x_opt,f_opt,nbr_iters,nbr_fevals,solve_time = dfo.fmin(f1,xstart=x0*1e6,lb=lb*1e6,
                                                           ub=ub*1e6,alg=1)
    # alg = 1: Nelder-Mead method
    # alg = 2: Sequential barrier method using Nelder-Mead
    # alg = 3: OpenOpt solver "de" (Differential evolution method)

    # Optimal point (don't forget to scale down)
    [a1_opt,a2_opt] = x_opt/1e6

    # Print optimal parameter values and optimal function value
    print 'Optimal parameter values:'
    print 'a1 = ' + str(a1_opt*1e4) + ' cm^2'
    print 'a2 = ' + str(a2_opt*1e4) + ' cm^2'
    print 'Optimal function value: ' + str(f_opt)
    print ' '

    model = load_fmu(fmu_name)

    # Set optimal values for a1 and a2 into the model
    model.set('qt.a1',a1_opt)
    model.set('qt.a2',a2_opt)
    
    # Create options object and set verbosity to zero to disable printouts
    opts = model.simulate_options()
    opts['CVode_options']['verbosity'] = 0

    # Simulate model response with optimal parameters a1 and a2
    res = model.simulate(input=(['u1','u2'],u),start_time=0.,final_time=60,options=opts)

    # Load optimal simulation result
    x1_opt = res['qt.x1']
    x2_opt = res['qt.x2']
    x3_opt = res['qt.x3']
    x4_opt = res['qt.x4']
    u1_opt = res['qt.u1']
    u2_opt = res['qt.u2']
    t_opt  = res['time']
    
    assert N.abs(res.final('qt.x1') - 0.07060188) < 1e-3
    assert N.abs(res.final('qt.x2') - 0.06654621) < 1e-3
    assert N.abs(res.final('qt.x3') - 0.02736549) < 1e-3
    assert N.abs(res.final('qt.x4') - 0.02789857) < 1e-3
    assert N.abs(res.final('qt.u1') - 6.0)        < 1e-3
    assert N.abs(res.final('qt.u2') - 5.0)        < 1e-3


    # Plot
    if with_plots:
        font = FontProperties(size='x-small')
        plt.figure(1)
        plt.subplot(2,2,1)
        plt.plot(t_opt,x3_opt,'k')
        plt.subplot(2,2,2)
        plt.plot(t_opt,x4_opt,'k')
        plt.subplot(2,2,3)
        plt.plot(t_opt,x1_opt,'k')
        plt.subplot(2,2,4)
        plt.plot(t_opt,x2_opt,'k')
        plt.show()
    
    # ESTIMATION OF 4 PARAMETERS
    
    # Define the objective function
    def f2(x):                

        model = load_fmu(fmu_name)

        # We need to scale the inputs x down since they are scaled up 
        # versions of a1, a2, a3 and a4 (x = scalefactor*[a1 a2 a3 a4])
        a1 = x[0]/1e6
        a2 = x[1]/1e6
        a3 = x[2]/1e6
        a4 = x[3]/1e6
        
        # Set new values for a1, a2, a3 and a4 into the model 
        model.set('qt.a1',a1)
        model.set('qt.a2',a2)
        model.set('qt.a3',a3)
        model.set('qt.a4',a4)
        
        # Create options object and set verbosity to zero to disable printouts
        opts = model.simulate_options()
        opts['CVode_options']['verbosity'] = 0
        
        # Simulate model response with the new parameters
        res = model.simulate(input=(['u1','u2'],u),start_time=0.,final_time=60,options=opts)
        
        # Load simulation result
        x1_sim = res['qt.x1']
        x2_sim = res['qt.x2']
        x3_sim = res['qt.x3']
        x4_sim = res['qt.x4']
        t_sim  = res['time']
        
        # Evaluate the objective function
        y_meas = [y1_meas,y2_meas,y3_meas,y4_meas]
        y_sim = [x1_sim,x2_sim,x3_sim,x4_sim]
        obj = dfo.quad_err(t_meas,y_meas,t_sim,y_sim)
        
        return obj

    # Choose starting point (initial estimation)
    x0 = 0.03e-4*N.ones(4)

    # Lower and upper bounds
    lb = x0 - 1e-6
    ub = x0 + 1e-6

    # Solve the problem
    x_opt,f_opt,nbr_iters,nbr_fevals,solve_time = dfo.fmin(f2,xstart=x0*1e6,lb=lb*1e6,
                                                          ub=ub*1e6,alg=1)

    # Optimal point (don't forget to scale down)
    [a1_opt,a2_opt,a3_opt,a4_opt] = x_opt/1e6

    # Print optimal parameters and function value
    print 'Optimal parameter values:'
    print 'a1 = ' + str(a1_opt*1e4) + ' cm^2'
    print 'a2 = ' + str(a2_opt*1e4) + ' cm^2'
    print 'a3 = ' + str(a3_opt*1e4) + ' cm^2'
    print 'a4 = ' + str(a4_opt*1e4) + ' cm^2'
    print 'Optimal function value: ' + str(f_opt)
    print ' '

    model = load_fmu(fmu_name)
    
    # Set optimal values for a1, a2, a3 and a4 into the model
    model.set('qt.a1',a1_opt)
    model.set('qt.a2',a2_opt)
    model.set('qt.a3',a3_opt)
    model.set('qt.a4',a4_opt)
    
    # Create options object and set verbosity to zero to disable printouts
    opts = model.simulate_options()
    opts['CVode_options']['verbosity'] = 0

    # Simulate model response with the optimal parameters
    res = model.simulate(input=(['u1','u2'],u),start_time=0.,final_time=60,options=opts)

    # Load optimal simulation result
    x1_opt = res['qt.x1']
    x2_opt = res['qt.x2']
    x3_opt = res['qt.x3']
    x4_opt = res['qt.x4']
    u1_opt = res['qt.u1']
    u2_opt = res['qt.u2']
    t_opt  = res['time']
    
    assert N.abs(res.final('qt.x1') - 0.07059621) < 1e-3
    assert N.abs(res.final('qt.x2') - 0.06672873) < 1e-3
    assert N.abs(res.final('qt.x3') - 0.02723064) < 1e-3
    assert N.abs(res.final('qt.x4') - 0.02912602) < 1e-3
    assert N.abs(res.final('qt.u1') - 6.0)        < 1e-3
    assert N.abs(res.final('qt.u2') - 5.0)        < 1e-3
    

    # Plot
    if with_plots:
        font = FontProperties(size='x-small')
        plt.figure(1)
        plt.subplot(2,2,1)
        plt.plot(t_opt,x3_opt,'r')
        plt.subplot(2,2,2)
        plt.plot(t_opt,x4_opt,'r')
        plt.subplot(2,2,3)
        plt.plot(t_opt,x1_opt,'r')
        plt.subplot(2,2,4)
        plt.plot(t_opt,x2_opt,'r')
        plt.legend(('Measurement','Simulation nom. params','Simulation opt. params 2 dim','Simulation opt. params 4 dim'),loc=4,prop=font)
        plt.show()
