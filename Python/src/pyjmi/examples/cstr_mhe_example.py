import os

import numpy as N
from scipy import signal
import matplotlib.pyplot as plt

from pymodelica import compile_fmu
from pyfmi import load_fmu
from pyjmi import get_files_path, transfer_optimization_problem


import pyjmi.optimization.mhe.mhe_initial_values as initv
from pyjmi.optimization.mhe.mhe import MHE, MHEOptions



def run_demo(with_plots = True):
    """
    This example is based on the Hicks-Ray Continuously Stirred Tank 
    Reactors (CSTR) system. The system has two states, the 
    concentration and the temperature. The control input to the system 
    is the temperature of the cooling flow in the reactor jacket. The 
    chemical reaction in the reactor is exothermic, and also 
    temperature dependent; high temperature results in high reaction 
    rate.
    
    This example serves to illustrate some of the key features of the 
    CasADi-based Moving Horizon Estimator (MHE). 
    
    MHE solves a finite horizon optimization problem at every time 
    step to generate an estimate of the next value of the states.
    The cost function used by the MHE is on the form
    
    cost = sum_{k = T-N}^{N-1}(w_kQ_k^{-1}w_k^T + v_kR_k^{-1}v_k^T) + 
    Z(x_{T-N})
    
    where w is the process noise, v the measurement noise and Z(...) 
    the so called arrival cost term. The arrival cost term summarizes 
    the information outside of the finite horizon of data in the sum. 
    The arrival cost is approximated so that the size of the 
    optimization does not grow with the time. Currently the 
    approximation used is the EKF covariance update. Meaning that the 
    arrival cost approximation is on the form 
    
    Z^hat(x_{T-N}) = (x^bar_{T-N} - x^hat_{T-N})P_{T-N}^{-1}
    (x^bar_{T-N} - x^hat_{T-N})^T
    
    The example will demonstrate how one can use the MHE class to 
    perform state estimation using a FMUModel object to generate 
    measurement data.
    """
    #Get the name and location of the Modelica package
    file_path = os.path.join(get_files_path(), "CSTR.mop")
    
    #Transfer the OptimizationProblem object, using the 
    #"state_initial_equations" option to create new initial equations and new 
    #parameters for those equations. This is required by the MHE class
    op = transfer_optimization_problem('CSTR.CSTR', 
                                       file_path, 
                                       accept_model = True, 
                                       compiler_options= 
                                       {"state_initial_equations":True})
    
    #Compile the FMU with the same option as for the OptimizationProblem
    fmu = compile_fmu('CSTR.CSTR',
                      file_path, 
                      compiler_options={"state_initial_equations":True})
    #Load the FMU
    model = load_fmu(fmu)
    
    
    #Define the time interval and the number of points
    sim_time = 3.
    nbr_of_points = 31
    #Calculate the corresponding sample time
    sample_time = sim_time / (nbr_of_points -1)
    
    #Create an array of the time points
    time = N.linspace(0., sim_time,nbr_of_points)
    
    ###Create noise for the measurement data
    #Create the continuous covariance matrices
    Q = N.array([[2.]])
    R = N.array([[10., 0.],[0., 2.]])
    #The expectations
    w_my = N.array([0.])
    v_my = N.array([0.,0.])
    ##Get the noise sequences
    #Process noise
    #Use same seed for consistent results
    N.random.seed(2)
    w = N.transpose(N.random.multivariate_normal(w_my, Q, nbr_of_points))
    #Measurement noise
    N.random.seed(3)
    v = N.transpose(N.random.multivariate_normal(v_my, R, nbr_of_points))
    
    
    
    ###Chose a control signal
    u = 280. + 25.*signal.square(2.*N.pi*time)
    
    
    
    ###Define the inputs for the MHE object
    ##See the documentation of the MHEOptions for more details
    #Create the options object
    MHE_opts = MHEOptions()
    #Process noise covariance
    MHE_opts['process_noise_cov'] = [('Tc', 20.)]
    #The names of the input signals acting as control signals
    MHE_opts['input_names'] = ['Tc']
    #Chose what variables are measured and their covariance structure
    #The two definitions below are equivalent
    MHE_opts['measurement_cov'] = [('c',  10.),('T', 1.)]
    MHE_opts['measurement_cov'] = [(['c','T'], N.array([[1., 0.0], 
                                                        [0.0, 0.2]]))]
    #Error covariance matrix
    MHE_opts['P0_cov'] = [('c',10.),('T', 5.)]
    
    ##The initial guess of the states
    x_0_guess = dict([('c', 990.), ('T', 355.)])
    #Initial value of the simulation
    x_0 = dict([('c', 1000.), ('T', 350.)])
    
    
    ##Use mhe_initial_values module or some equivalent method to get the 
    #initial values of the state derivatives and the algebraic variables
    #Control signal for time step zero
    u_0 = {'Tc':u[0]}
    
    (dx_0, c_0) = initv.optimize_for_initial_values(op, x_0_guess, 
                                                    u_0, MHE_opts)
    
    #Decide the horizon length
    horizon = 8
    
    
    ##Create the MHE object
    MHE_object = MHE(op, sample_time, horizon, x_0_guess, dx_0, c_0, MHE_opts)
    
    #Create a structure for saving the estimates
    x_est = {'c':[x_0_guess['c']], 'T':[x_0_guess['T']]}
    #Create a structure for saving the simulated data
    x = {'c':[x_0['c']], 'T':[x_0['T']]}
    #Create the structure for the measured data
    y = {'c':[], 'T':[]}
    #Loop over estimation and simulation
    for t in range(1, nbr_of_points):
        #Create the measurement data from the simulated data and added noise
        y['c'].append(x['c'][-1] + v[0, t-1])
        y['T'].append(x['T'][-1] + v[1, t-1])
        #Create list of tuples with (name, measurement) structure
        y_t = [('c', y['c'][-1]), ('T', y['T'][-1])]
        #Create list of tuples with (name, input) structure
        u_t = [('Tc', u[t-1])]
        #Estimate
        x_est_t = MHE_object.step(u_t, y_t)
        
        #Add the results to x_est
        for key in x_est.keys():
            x_est[key].append(x_est_t[key])
        
        ###Prepare the simulation
        #Create the input object
        u_traj = N.transpose(N.vstack((0., u[t])))
        input_object = ('Tc', u_traj)
        
        #Set the initial values of the states
        for (key, list)in x.items():
            model.set('_start_' + key, list[-1])
        
        #Simulate with one communication point to get the value at the right point
        res = model.simulate(final_time=sample_time, 
                             input=input_object, 
                             options={'ncp':1})
    
        #Extract the state values from the result object
        for key in x.keys():
            x[key].append(res[key][-1])
        #reset the FMU
        model.reset()
    
    #Add the last measurement
    y['c'].append(x['c'][-1] + v[0, -1])
    y['T'].append(x['T'][-1] + v[1, -1])
    
    if with_plots:
        plt.close('MHE')
        plt.figure('MHE')
        plt.subplot(3, 1, 1)
        plt.plot(time, x_est['c'])
        plt.plot(time, x['c'], ls = '--', color = 'k')
        plt.plot(time, y['c'], ls = '-', marker = '+', 
                 mfc = 'k', mec = 'k', mew = 1.)
        plt.legend(('Concentration estimate', 
                    'Simulated concentration', 
                    'Measured concentration'))
        plt.grid()
        plt.ylabel('Concentration')

        plt.subplot(3, 1, 2)
        plt.plot(time, x_est['T'])
        plt.plot(time, x['T'], ls = '--', color = 'k')
        plt.plot(time, y['T'], ls = '-', marker = '+', 
                 mfc = 'k', mec = 'k', mew = 1.)
        plt.legend(('Temperature estimate', 
                    'Simulated temperature', 
                    'Measured temperature'))
        plt.grid()
        plt.ylabel('Temperature')

        plt.subplot(3, 1, 3)
        plt.step(time, u)
        plt.grid()
        plt.ylabel('Cooling temperature')
        plt.xlabel('time')
        plt.show()
    
if __name__=="__main__":
    run_demo()