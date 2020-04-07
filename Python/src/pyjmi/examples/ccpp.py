#!/usr/bin/env python 
# -*- coding: utf-8 -*-

# Copyright (C) 2012 Modelon AB
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

# Import library for path manipulations
import os.path

# Import numerical libraries
import numpy as N
import matplotlib.pyplot as plt

# Import the needed JModelica.org Python methods
from pymodelica import compile_fmu
from pyfmi import load_fmu
from pyjmi import get_files_path

def run_demo(with_plots=True):
    """
    This example is based on a combined cycle power plant (CCPP). The model has
    9 states, 128 algebraic variables and 1 control variable. The task is to
    minimize the time required to perform a warm start-up of the power plant.
    This problem has become highly industrially relevant during the last few
    years, due to an increasing need to improve power generation flexibility.
    
    The example consists of the following steps:
    
    1.  Simulating the system using a simple input trajectory.
    
    2.  Solving the optimal control problem using the result from the first
        step to initialize the non-linear program.
       
    3.  Verifying the result from the second step by simulating the system
        once more usng the optimized input trajectory.
    
    The model was developed by Francesco Casella and is published in
    @InProceedings{CFA2011,
      author = "Casella, Francesco and Donida, Filippo and {\AA}kesson, Johan",
      title = "Object-Oriented Modeling and Optimal Control: A Case Study in
               Power Plant Start-Up",
      booktitle = "18th IFAC World Congress",
      address = "Milano, Italy",
      year = 2011,
      month = aug
    }
    """
    ### 1. Compute initial guess trajectories by means of simulation
    # Locate the Modelica and Optimica code
    file_paths = (os.path.join(get_files_path(), "CombinedCycle.mo"),
                  os.path.join(get_files_path(), "CombinedCycleStartup.mop"))
    
    # Compile the optimization initialization model
    init_sim_fmu = compile_fmu("CombinedCycleStartup.Startup6Reference",
                               file_paths, separate_process=True)
    
    # Load the model
    init_sim_model = load_fmu(init_sim_fmu)
    
    # Simulate
    init_res = init_sim_model.simulate(start_time=0., final_time=10000.)
    
    # Extract variable profiles
    init_sim_plant_p = init_res['plant.p']
    init_sim_plant_sigma = init_res['plant.sigma']
    init_sim_plant_load = init_res['plant.load']
    init_sim_time = init_res['time']
    
    # Plot the initial guess trajectories
    if with_plots:
        plt.close(1)
        plt.figure(1)
        plt.subplot(3, 1, 1)
        plt.plot(init_sim_time, init_sim_plant_p * 1e-6)
        plt.ylabel('evaporator pressure [MPa]')
        plt.grid(True)
        plt.title('Initial guess obtained by simulation')
        
        plt.subplot(3, 1, 2)
        plt.plot(init_sim_time, init_sim_plant_sigma * 1e-6)
        plt.grid(True)
        plt.ylabel('turbine thermal stress [MPa]')
        
        plt.subplot(3, 1, 3)
        plt.plot(init_sim_time, init_sim_plant_load)
        plt.grid(True)
        plt.ylabel('input load [1]')
        plt.xlabel('time [s]')
    
    ### 2. Solve the optimal control problem
    # Compile model
    from pyjmi import transfer_to_casadi_interface
    op = transfer_to_casadi_interface("CombinedCycleStartup.Startup6",
                                      file_paths)
    
    # Set options
    opt_opts = op.optimize_options()
    opt_opts['n_e'] = 50 # Number of elements
    opt_opts['init_traj'] = init_res # Simulation result
    opt_opts['nominal_traj'] = init_res
    opt_opts['verbosity'] = 1
    
    # Solve the optimal control problem
    opt_res = op.optimize(options=opt_opts)
    
    # Extract variable profiles
    opt_plant_p = opt_res['plant.p']
    opt_plant_sigma = opt_res['plant.sigma']
    opt_plant_load = opt_res['plant.load']
    opt_time = opt_res['time']
    opt_input = N.vstack([opt_time, opt_plant_load]).T
    
    # Plot the optimized trajectories
    if with_plots:
        plt.close(2)
        plt.figure(2)
        plt.subplot(3, 1, 1)
        plt.plot(opt_time, opt_plant_p * 1e-6)
        plt.ylabel('evaporator pressure [MPa]')
        plt.grid(True)
        plt.title('Optimized trajectories')
        
        plt.subplot(3, 1, 2)
        plt.plot(opt_time, opt_plant_sigma * 1e-6)
        plt.grid(True)
        plt.ylabel('turbine thermal stress [MPa]')
        
        plt.subplot(3, 1, 3)
        plt.plot(opt_time, opt_plant_load)
        plt.grid(True)
        plt.ylabel('input load [1]')
        plt.xlabel('time [s]')
    
    # Verify solution for testing purposes
    try:
        import casadi
    except:
        pass
    else:
        cost = float(opt_res.solver.solver_object.output(casadi.NLP_SOLVER_F))
        N.testing.assert_allclose(cost, 17492.465548193624, rtol=1e-5)

    ### 3. Simulate to verify the optimal solution
    # Compile model
    sim_fmu = compile_fmu("CombinedCycle.Optimization.Plants.CC0D_WarmStartUp",
                          file_paths)

    # Load model
    sim_model = load_fmu(sim_fmu)
    
    # Simulate using optimized input
    sim_res = sim_model.simulate(start_time=0., final_time=4000.,
                                 input=('load', opt_input))
    
    # Extract variable profiles
    sim_plant_p = sim_res['p']
    sim_plant_sigma = sim_res['sigma']
    sim_plant_load = sim_res['load']
    sim_time = sim_res['time']
    
    # Plot the simulated trajectories
    if with_plots:
        plt.close(3)
        plt.figure(3)
        plt.subplot(3, 1, 1)
        plt.plot(opt_time, opt_plant_p * 1e-6, '--', lw=5)
        plt.hold(True)
        plt.plot(sim_time, sim_plant_p * 1e-6, lw=2)
        plt.ylabel('evaporator pressure [MPa]')
        plt.grid(True)
        plt.legend(('optimized', 'simulated'), loc='lower right')
        plt.title('Verification')
        
        plt.subplot(3, 1, 2)
        plt.plot(opt_time, opt_plant_sigma * 1e-6, '--', lw=5)
        plt.hold(True)
        plt.plot(sim_time, sim_plant_sigma * 1e-6, lw=2)
        plt.ylabel('turbine thermal stress [MPa]')
        plt.grid(True)
        
        plt.subplot(3, 1, 3)
        plt.plot(opt_time, opt_plant_load, '--', lw=5)
        plt.hold(True)
        plt.plot(sim_time, sim_plant_load, lw=2)
        plt.ylabel('input load [1]')
        plt.xlabel('time [s]')
        plt.grid(True)
        plt.show()
    
    # Verify solution for testing purposes
    N.testing.assert_allclose(opt_res.final('plant.p'),
                              sim_res.final('p'), rtol=5e-3)

if __name__ == "__main__":
    run_demo()
