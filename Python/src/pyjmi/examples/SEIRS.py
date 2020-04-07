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
#
# Original code and model by: Niklas Andersson

import os.path

import numpy as N
import matplotlib.pyplot as plt
import nose

from pymodelica import compile_fmu
from pyfmi import load_fmu
from pyfmi.common.core import TrajectoryLinearInterpolation

def objectfun_fmu(theta,fmu_name,parnames,t0,tf,opts,times):
    model = load_fmu(fmu_name,enable_logging=False)
    opts["CVode_options"]["verbosity"] = 50
    
    model.set(parnames,theta)
    res = model.simulate(t0,tf, options=opts)

    E = res['E']                               
    E_traj = TrajectoryLinearInterpolation(res['time'],N.array([E]).T)

    Evals = E_traj.eval(times)
    return Evals.squeeze() 

def sensfunc(objectfun,theta0,xmu_name,parnames,t0,tf,opts,times):
    # Basic function to calculate sensitivities with finite differences
    resbase = objectfun(theta0,xmu_name,parnames,t0,tf,opts,times)
    dxdpnew = []
    for ipar in range(len(theta0)):
        thetabase = theta0.copy()
        val = theta0[ipar]
        if N.abs(val)<1e-16:
            newval = 1e-4
        else:
            newval = val*1.01
        dval = newval-val
        thetabase[ipar] = newval
        resnew = objectfun(thetabase,xmu_name,parnames,t0,tf,opts,times)
        dxdpnew.append((resnew-resbase)/dval)
    dxdpnew = N.array(dxdpnew).T
    return dxdpnew

def run_demo(with_plots=True):
    """
    Demonstrates how to use an JMODELICA generated FMU for sensitivity
    calculations and compares against finite differences. 
    
    Model and original code by Niklas Andersson
    """
    curr_dir = os.path.dirname(os.path.abspath(__file__));

    #Compile the model
    fmu_name = compile_fmu("SEIRSmodel", curr_dir+"/files/SEIRSmodel.mo")
    
    #Sensitivity parameters
    senspars = [5,6,7,8]
    parnames = ['p%d'%sp for sp in senspars]
    
    #Simulation interval
    t0 = 2002.
    tf = 2007.

    fmodel = load_fmu(fmu_name,enable_logging=False)

    # Get and set the options
    fopts = fmodel.simulate_options()
    fopts['CVode_options']['atol'] = 1.0e-6
    fopts['CVode_options']['rtol'] = 1.0e-6
    fopts['sensitivities'] = parnames
    fopts['ncp'] = 500

    #Simulate
    fres = fmodel.simulate(t0,tf, options=fopts)
    
    #Get the result
    dEdpt_fmu = N.array([fres['dE/dp%d' % (i)] for i in senspars]).T
            
    #Calculate Finite Differences
    theta0 = N.array([fmodel.get(name) for name in parnames])
    fopts['sensitivities'] = []
    fopts['ncp'] = 0
    dEdpt_findiff_fmu = sensfunc(objectfun_fmu,theta0,fmu_name,parnames,t0,tf,fopts,N.linspace(t0,tf,501.))
    
    #Maximum relative errors
    for ii,sp in enumerate(senspars):
        err = N.max(N.abs(dEdpt_fmu[:,ii]-dEdpt_findiff_fmu[:,ii])/N.max(dEdpt_fmu[:,ii]))
        assert err < 1.0, str(err) + " not less than " + str(1.0)
        
    #Plotting
    if with_plots:
        for ii,sp in enumerate(senspars):
            plt.figure(1)
            plt.subplot(len(senspars),1,ii)
            plt.hold(True)
            plt.plot(fres['time'],dEdpt_fmu[:,ii],'x-')
            plt.plot(fres['time'],dEdpt_findiff_fmu[:,ii],'o-')
            plt.legend(['fmu-sens','fmu-findiff'])
            plt.figure(2)
            plt.hold(True)
            plt.semilogy(fres['time'],N.abs(dEdpt_fmu[:,ii]-dEdpt_findiff_fmu[:,ii])/N.max(dEdpt_fmu[:,ii]),label=parnames[ii])
            plt.legend()
            plt.grid(True)
            plt.xlabel("Time [s]")
            plt.title("Comparison of sensitivities calculated by CVodes and by Finite differences")
        plt.show()

if __name__=="__main__":
    run_demo()
