#!/usr/bin/env python 
# -*- coding: utf-8 -*-

# Copyright (C) 2014 Modelon AB
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
from pyjmi import transfer_optimization_problem, get_files_path

def run_demo(with_plots=True):
    """
    This example is based on the Hicks-Ray Continuously Stirred Tank Reactors 
    (CSTR) system. The system has two states, the concentration and the 
    temperature. The control input to the system is the temperature of the 
    cooling flow in the reactor jacket. The chemical reaction in the reactor is 
    exothermic, and also temperature dependent; high temperature results in high 
    reaction rate.
    
    The problem is solved using the CasADi-based collocation algorithm. The
    steps performed correspond to those demonstrated in
    example pyjmi.examples.cstr, where the same problem is solved using the
    default JMI algorithm. FMI is used for initialization and simulation
    purposes.
    
    The following steps are demonstrated in this example:
    
    1.  How to solve the initialization problem. The initialization model has
        equations specifying that all derivatives should be identically zero,
        which implies that a stationary solution is obtained. Two stationary
        points, corresponding to different inputs, are computed. We call the
        stationary points A and B respectively. Point A corresponds to
        operating conditions where the reactor is cold and the reaction rate is
        low, whereas point B corresponds to a higher temperature where the
        reaction rate is high.
    
    2.  How to generate an initial guess for a direct collocation method by
        means of simulation with a constant input. The trajectories resulting
        from the simulation are used to initialize the variables in the
        transcribed NLP.
       
    3.  An optimal control problem is solved where the objective is to transfer 
        the state of the system from stationary point A to point B. The
        challenge is to ignite the reactor while avoiding uncontrolled
        temperature increase.

    4.  Finally the system is simulated using the optimal control profile. This
        step is important in order to verify that the approximation in the
        transcription step is sufficiently accurate.
    """
    ### 1. Solve the initialization problem
    # Locate the Modelica and Optimica code
    file_path = os.path.join(get_files_path(), "CSTR.mop")

    # Compile the stationary initialization model into an FMU
    init_fmu = compile_fmu("CSTR.CSTR_Init", file_path)
    
    # Load the FMU
    init_model = load_fmu(init_fmu)
    
    # Set input for Stationary point A
    Tc_0_A = 250
    init_model.set('Tc', Tc_0_A)

    # Solve the initialization problem using FMI
    init_model.initialize()

    # Store stationary point A
    [c_0_A, T_0_A] = init_model.get(['c', 'T'])

    # Print some data for stationary point A
    print(' *** Stationary point A ***')
    print('Tc = %f' % Tc_0_A)
    print('c = %f' % c_0_A)
    print('T = %f' % T_0_A)
    
    # Set inputs for Stationary point B
    init_model.reset() # reset the FMU so that we can initialize it again
    Tc_0_B = 280
    init_model.set('Tc', Tc_0_B)

    # Solve the initialization problem using FMI
    init_model.initialize()

    # Store stationary point B
    [c_0_B, T_0_B] = init_model.get(['c', 'T'])

    # Print some data for stationary point B
    print(' *** Stationary point B ***')
    print('Tc = %f' % Tc_0_B)
    print('c = %f' % c_0_B)
    print('T = %f' % T_0_B)
    
    ### 2. Compute initial guess trajectories by means of simulation
    # Compile the optimization initialization model
    init_sim_fmu = compile_fmu("CSTR.CSTR_Init_Optimization", file_path)

    # Load the model
    init_sim_model = load_fmu(init_sim_fmu)
    
    # Set initial and reference values
    init_sim_model.set('cstr.c_init', c_0_A)
    init_sim_model.set('cstr.T_init', T_0_A)
    init_sim_model.set('c_ref', c_0_B)
    init_sim_model.set('T_ref', T_0_B)
    init_sim_model.set('Tc_ref', Tc_0_B)
    
    # Simulate with constant input Tc
    init_res = init_sim_model.simulate(start_time=0., final_time=150.)

    # Extract variable profiles
    t_init_sim = init_res['time']
    c_init_sim = init_res['cstr.c']
    T_init_sim = init_res['cstr.T']
    Tc_init_sim = init_res['cstr.Tc']

    # Plot the initial guess trajectories
    if with_plots:
        plt.close(1)
        plt.figure(1)
        plt.hold(True)
        plt.subplot(3, 1, 1)
        plt.plot(t_init_sim, c_init_sim)
        plt.grid()
        plt.ylabel('Concentration')
        plt.title('Initial guess obtained by simulation')

        plt.subplot(3, 1, 2)
        plt.plot(t_init_sim, T_init_sim)
        plt.grid()
        plt.ylabel('Temperature')

        plt.subplot(3, 1, 3)
        plt.plot(t_init_sim, Tc_init_sim)
        plt.grid()
        plt.ylabel('Cooling temperature')
        plt.xlabel('time')
        plt.show()
    
    ### 3. Solve the optimal control problem
    # Compile and load optimization problem
    op = transfer_optimization_problem("CSTR.CSTR_Opt2", file_path)
    
    # Set reference values
    op.set('Tc_ref', Tc_0_B)
    op.set('c_ref', float(c_0_B))
    op.set('T_ref', float(T_0_B))
    
    # Set initial values
    op.set('cstr.c_init', float(c_0_A))
    op.set('cstr.T_init', float(T_0_A))
    
    # Set options
    opt_opts = op.optimize_options()
    opt_opts['n_e'] = 19 # Number of elements
    opt_opts['init_traj'] = init_res
    opt_opts['nominal_traj'] = init_res
    opt_opts['IPOPT_options']['tol'] = 1e-10
    opt_opts['verbosity'] = 1
    
    # Solve the optimal control problem
    res = op.optimize(options=opt_opts)
    
    # Extract variable profiles
    c_res = res['cstr.c']
    T_res = res['cstr.T']
    Tc_res = res['cstr.Tc']
    time_res = res['time']
    c_ref = res['c_ref']
    T_ref = res['T_ref']
    Tc_ref = res['Tc_ref']
    
    # Verify solution for testing purposes
    try:
        import casadi
    except:
        pass
    else:
        cost = float(res.solver.solver_object.output(casadi.NLP_SOLVER_F))
        assert(N.abs(cost/1.e3 - 1.86162353098) < 1e-3)

    # Plot the results
    if with_plots:
        plt.close(2)
        plt.figure(2)
        plt.hold(True)
        plt.subplot(3, 1, 1)
        plt.plot(time_res, c_res)
        plt.plot(time_res, c_ref, '--')
        plt.grid()
        plt.ylabel('Concentration')
        plt.title('Optimized trajectories')

        plt.subplot(3, 1, 2)
        plt.plot(time_res, T_res)
        plt.plot(time_res, T_ref, '--')
        plt.grid()
        plt.ylabel('Temperature')

        plt.subplot(3, 1, 3)
        plt.plot(time_res, Tc_res)
        plt.plot(time_res, Tc_ref, '--')
        plt.grid()
        plt.ylabel('Cooling temperature')
        plt.xlabel('time')
        plt.show()

    ### 4. Simulate to verify the optimal solution
    # Compile model
    sim_fmu = compile_fmu("CSTR.CSTR", file_path)

    # Load model
    sim_model = load_fmu(sim_fmu)

    # Get optimized input
    (_, opt_input) = res.get_opt_input()
    
    # Set initial values
    sim_model.set('c_init', c_0_A)
    sim_model.set('T_init', T_0_A)

    # Simulate using optimized input
    sim_opts = sim_model.simulate_options()
    sim_opts['CVode_options']['rtol'] = 1e-6
    sim_opts['CVode_options']['atol'] = 1e-8
    res = sim_model.simulate(start_time=0., final_time=150.,
                             input=('Tc', opt_input), options=sim_opts)

    # Extract variable profiles
    c_sim = res['c']
    T_sim = res['T']
    Tc_sim = res['Tc']
    time_sim = res['time']

    # Verify results
    N.testing.assert_array_less(abs(c_res[-1] - c_sim[-1])/c_res[-1], 5e-1)

    # Plot the results
    if with_plots:
        plt.close(3)
        plt.figure(3)
        plt.hold(True)
        plt.subplot(3, 1, 1)
        plt.plot(time_res, c_res, '--')
        plt.plot(time_sim, c_sim)
        plt.legend(('optimized', 'simulated'))
        plt.grid(True)
        plt.ylabel('Concentration')
        plt.title('Verification')
        
        plt.subplot(3, 1, 2)
        plt.plot(time_res, T_res, '--')
        plt.plot(time_sim, T_sim)
        plt.grid(True)
        plt.ylabel('Temperature')
        
        plt.subplot(3, 1, 3)
        plt.plot(time_res, Tc_res, '--')
        plt.plot(time_sim, Tc_sim)
        plt.grid(True)
        plt.ylabel('Cooling temperature')
        plt.xlabel('time')
        plt.show()

if __name__=="__main__":
    run_demo()
