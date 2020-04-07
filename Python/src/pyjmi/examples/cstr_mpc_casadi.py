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
from pyjmi.optimization.mpc import MPC
from pyjmi.optimization.casadi_collocation import BlockingFactors
import copy

def run_demo(with_plots=True):
    """
    This example is based on the Hicks-Ray Continuously Stirred Tank Reactors 
    (CSTR) system. The system has two states, the concentration and the 
    temperature. The control input to the system is the temperature of the 
    cooling flow in the reactor jacket. The chemical reaction in the reactor is 
    exothermic, and also temperature dependent; high temperature results in 
    high reaction rate.

    The problem is solved using the CasADi-based collocation algorithm through 
    the MPC-class. FMI is used for initialization and simulation purposes.

    The following steps are demonstrated in this example:

    1.  How to generate an initial guess for a direct collocation method by
        means of simulation with a constant input. The trajectories resulting
        from the simulation are used to initialize the variables in the
        transcribed NLP, in the first sample(optimization).

    2.  An optimal control problem is defined where the objective is to 
        transfer the state of the system from stationary point A to point B. 
        An MPC object for the optimization problem is created. After each 
        sample the NLP is updated with an estimate of the states in the next 
        sample. The estimate is done by simulating the model for one sample 
        period with the optimal input calculated in the optimization as input.
        To each estimate a normally distributed noise, with the mean 0 
        and standard deviation 0.5% of the nominal value of each state, is 
        added. The MPC object uses the result from the previous optimization as
        initial guess for the next optimization (for all but the first 
        optimization, where the simulation result from #1 is used instead).

   (3.) If with_plots is True we compile the same optimization problem again 
        and define the options so that the op has the same options and 
        resolution as the op we solved through the MPC-class. By same 
        resolution we mean that both op should have the same mesh and blocking 
        factors. This allows us to compare the MPC-results to an open loop 
        optimization. Note that the MPC-results contains noise while the open 
        loop optimization does not. 

    """
    ### 1. Compute initial guess trajectories by means of simulation
    # Locate the Modelica and Optimica code
    file_path = os.path.join(get_files_path(), "CSTR.mop")

    # Compile and load the model used for simulation
    sim_fmu = compile_fmu("CSTR.CSTR_MPC_Model", file_path, 
                            compiler_options={"state_initial_equations":True})
    sim_model = load_fmu(sim_fmu)

    # Define stationary point A and set initial values and inputs
    c_0_A = 956.271352
    T_0_A = 250.051971
    sim_model.set('_start_c', c_0_A)
    sim_model.set('_start_T', T_0_A)
    sim_model.set('Tc', 280)
    init_res = sim_model.simulate(start_time=0., final_time=150)

    ### 2. Define the optimal control problem and solve it using the MPC class
    # Compile and load optimization problem
    op = transfer_optimization_problem("CSTR.CSTR_MPC", file_path,
                            compiler_options={"state_initial_equations":True})

    # Define MPC options
    sample_period = 3                           # s
    horizon = 33                                # Samples on the horizon
    n_e_per_sample = 1                          # Collocation elements / sample
    n_e = n_e_per_sample*horizon                # Total collocation elements
    finalTime = 150                             # s
    number_samp_tot = int(finalTime/sample_period)   # Total number of samples to do

    # Create blocking factors with quadratic penalty and bound on 'Tc'
    bf_list = [n_e_per_sample]*(horizon/n_e_per_sample)
    factors = {'Tc': bf_list}
    du_quad_pen = {'Tc': 500}
    du_bounds = {'Tc': 30}
    bf = BlockingFactors(factors, du_bounds, du_quad_pen)

    # Set collocation options
    opt_opts = op.optimize_options()
    opt_opts['n_e'] = n_e
    opt_opts['n_cp'] = 2
    opt_opts['init_traj'] = init_res
    opt_opts['blocking_factors'] = bf

    if with_plots:
        # Compile and load a new instance of the op to compare the MPC results 
        # with an open loop optimization 
        op_open_loop = transfer_optimization_problem(
            "CSTR.CSTR_MPC", file_path,
            compiler_options={"state_initial_equations":True})
        op_open_loop.set('_start_c', float(c_0_A))
        op_open_loop.set('_start_T', float(T_0_A)) 
        
        # Copy options from MPC optimization
        open_loop_opts = copy.deepcopy(opt_opts)
        
        # Change n_e and blocking_factors so op_open_loop gets the same 
        # resolution as op
        open_loop_opts['n_e'] = number_samp_tot
        
        bf_list_ol = [n_e_per_sample]*(number_samp_tot/n_e_per_sample)
        factors_ol = {'Tc': bf_list_ol}
        bf_ol = BlockingFactors(factors_ol, du_bounds, du_quad_pen)
        open_loop_opts['blocking_factors'] = bf_ol
        open_loop_opts['IPOPT_options']['print_level'] = 0

    constr_viol_costs = {'T': 1e6}

    # Create the MPC object
    MPC_object = MPC(op, opt_opts, sample_period, horizon, 
                    constr_viol_costs=constr_viol_costs, noise_seed=1)

    # Set initial state
    x_k = {'_start_c': c_0_A, '_start_T': T_0_A }

    # Update the state and optimize number_samp_tot times
    for k in range(number_samp_tot):

        # Update the state and compute the optimal input for next sample period
        MPC_object.update_state(x_k)
        u_k = MPC_object.sample()

        # Reset the model and set the new initial states before simulating
        # the next sample period with the optimal input u_k
        sim_model.reset()
        sim_model.set(x_k.keys(), x_k.values())
        sim_res = sim_model.simulate(start_time=k*sample_period, 
                                     final_time=(k+1)*sample_period, 
                                     input=u_k)

        # Extract state at end of sample_period from sim_res and add Gaussian
        # noise with mean 0 and standard deviation 0.005*(state_current_value)
        x_k = MPC_object.extract_states(sim_res, mean=0, st_dev=0.005)


    # Extract variable profiles
    MPC_object.print_solver_stats()
    complete_result = MPC_object.get_complete_results()
    c_res_comp = complete_result['c']
    T_res_comp = complete_result['T']
    Tc_res_comp = complete_result['Tc']
    time_res_comp = complete_result['time']

    # Verify solution for testing purposes
    try:
        import casadi
    except:
        pass
    else:
        Tc_norm = N.linalg.norm(Tc_res_comp) / N.sqrt(len(Tc_res_comp))
        assert(N.abs(Tc_norm - 311.7362) < 1e-3)
        c_norm = N.linalg.norm(c_res_comp) / N.sqrt(len(c_res_comp))
        assert(N.abs(c_norm - 653.5369) < 1e-3)
        T_norm = N.linalg.norm(T_res_comp) / N.sqrt(len(T_res_comp))
        assert(N.abs(T_norm - 328.0852) < 1e-3)
    
    # Plot the results
    if with_plots: 
        ### 3. Solve the original optimal control problem without MPC
        res = op_open_loop.optimize(options=open_loop_opts)
        c_res = res['c']
        T_res = res['T']
        Tc_res = res['Tc']
        time_res = res['time']
        
        # Get reference values
        Tc_ref = op.get('Tc_ref')
        T_ref = op.get('T_ref')
        c_ref = op.get('c_ref')

        # Plot
        plt.close('MPC')
        plt.figure('MPC')
        plt.subplot(3, 1, 1)
        plt.plot(time_res_comp, c_res_comp)
        plt.plot(time_res, c_res )
        plt.plot([time_res[0],time_res[-1]],[c_ref,c_ref],'--')
        plt.legend(('MPC with noise', 'Open-loop without noise', 'Reference value'))
        plt.grid()
        plt.ylabel('Concentration')
        plt.title('Simulated trajectories')

        plt.subplot(3, 1, 2)
        plt.plot(time_res_comp, T_res_comp)
        plt.plot(time_res, T_res)
        plt.plot([time_res[0],time_res[-1]],[T_ref,T_ref], '--')
        plt.grid()
        plt.ylabel('Temperature [C]')

        plt.subplot(3, 1, 3)
        plt.step(time_res_comp, Tc_res_comp)
        plt.step(time_res, Tc_res)
        plt.plot([time_res[0],time_res[-1]],[Tc_ref,Tc_ref], '--')
        plt.grid()
        plt.ylabel('Cooling temperature [C]')
        plt.xlabel('time')
        plt.show()
        

if __name__=="__main__":
    run_demo()
