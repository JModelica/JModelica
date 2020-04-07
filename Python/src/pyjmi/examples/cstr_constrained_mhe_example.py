import os

import numpy as N
from scipy import signal
import matplotlib.pyplot as plt

from pymodelica import compile_fmu
from pyfmi import load_fmu
from pyjmi import get_files_path, transfer_optimization_problem

import modelicacasadi_wrapper as mc
from casadi import MX

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
    
    This example serves to illustrate how constraints can be added 
    when using the CasADi-based Moving Horizon Estimator (MHE). 
    Shows the importance of constraints when working close to a 
    physical constraint by comparing the unconstrained MHE with 
    the constrained one.
    
    Constraints are added by simply extending a Modelica or Optimica 
    model and adding the constraint or by creating a Constraint to 
    the OptimizationProblem object using setPathConstraints. 
    The usage of point constraints is not supported and can give 
    unpredictable results.
    """
    #Get the name and location of the Modelica package
    file_path = os.path.join(get_files_path(), "CSTR.mop")
    
    #Transfer the unconstrained OptimizationProblem from the model 
    #using "state_initial_equations" and "accept_model"
    unconstr_op = transfer_optimization_problem('CSTR.CSTR_mhe_model', 
                        file_path, 
                        accept_model = True, 
                        compiler_options= {"state_initial_equations":True})
    #Transfer the constrained OptimizationProblem from the Optimica model
    #using "state_initial_equations"
    constr_op = transfer_optimization_problem('CSTR.CSTR_mhe', 
                                              file_path, 
                                              accept_model = False, 
                                              compiler_options= 
                                              {"state_initial_equations":True})
    #The constraint could instead have been added using the following:
    #c_var = op.getVariable('c').getVar()
    #constr = mc.Constraint(c_var, MX(0), mc.Constraint.GEQ)
    #op.setPathConstraints([constr])
    
    #Compile the FMU with the same option as for the OptimizationProblem
    fmu = compile_fmu('CSTR.CSTR_mhe_model',
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
    #Create the discrete covariance matrices
    Q = N.array([[20.]])
    R = N.array([[10., 0.],[0., 1.]])
    #The expectations
    w_my = N.array([0.])
    v_my = N.array([0.,0.])
    ##Get the noise sequences
    #Process noise
    #Use same seed for consistent results
    N.random.seed(3)
    w = N.transpose(N.random.multivariate_normal(w_my, Q, nbr_of_points))
    #Measurement noise
    N.random.seed(188)
    v = N.transpose(N.random.multivariate_normal(v_my, R, nbr_of_points))
    
    
    
    ###Chose a control signal
    u = 350.*N.ones(nbr_of_points)
    ###Define the inputs for the MHE object
    ##See the documentation of the MHEOptions for more details
    #Create the options object
    MHE_opts = MHEOptions()
    #Process noise covariance
    MHE_opts['process_noise_cov'] = [('Tc', 200.)]
    #The names of the input signals acting as control signals
    MHE_opts['input_names'] = ['Tc']
    #Chose what variables are measured and their covariance structure
    #The two definitions below are equivalent
    MHE_opts['measurement_cov'] = [('c',  1.),('T', 0.1)]
    MHE_opts['measurement_cov'] = [(['c','T'], N.array([[1., 0.0], 
                                                        [0.0, 0.1]]))]
    #Error covariance matrix
    MHE_opts['P0_cov'] = [('c',10.),('T', 5.)]
    
    ##The initial guess of the states
    x_0_guess = dict([('c', 0.), ('T', 352.)])
    #Initial value of the simulation
    x_0 = dict([('c', 0.), ('T', 350.)])
    
    
    ##Use mhe_initial_values module or some equivalent method to get the 
    #initial values of the state derivatives and the algebraic variables
    #Control signal for time step zero
    u_0 = {'Tc':u[0]}
    
    (dx_0, c_0) = initv.optimize_for_initial_values(unconstr_op, x_0_guess, 
                                                    u_0, MHE_opts)
    
    #Decide the horizon length
    horizon = 8
    
    
    ##Create the MHE objects
    unconstr_MHE_object = MHE(unconstr_op, sample_time, horizon, 
                              x_0_guess, dx_0, c_0, MHE_opts)
    constr_MHE_object = MHE(constr_op, sample_time, horizon, 
                            x_0_guess, dx_0, c_0, MHE_opts)
    #Create a structure for saving the estimates
    unconstr_x_est = {'c':[x_0_guess['c']], 'T':[x_0_guess['T']]}
    constr_x_est = {'c':[x_0_guess['c']], 'T':[x_0_guess['T']]}
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
        constr_x_est_t = constr_MHE_object.step(u_t, y_t)
        unconstr_x_est_t = unconstr_MHE_object.step(u_t, y_t)
        #Add the results to x_est
        for key in constr_x_est.keys():
            constr_x_est[key].append(constr_x_est_t[key])
        for key in unconstr_x_est.keys():
            unconstr_x_est[key].append(unconstr_x_est_t[key])
        ###Prepare the simulation
        #Create the input object
        u_traj = N.transpose(N.vstack((0., u[t])))
        input_object = ('Tc', u_traj)
        
        #Set the initial values of the states
        for (key, list)in x.items():
            model.set('_start_' + key, list[-1])
        
        #Simulate with one communication point to get the 
        #value at the right point
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
        plt.subplot(2, 1, 1)
        plt.plot(time, constr_x_est['c'])
        plt.plot(time, unconstr_x_est['c'])
        plt.plot(time, x['c'], ls = '--', color = 'k')
        plt.plot(time, y['c'], ls = '-', marker = '+', 
                 mfc = 'k', mec = 'k', mew = 1.)
        plt.legend(('Constrained concentration estimate', 
                    'Unconstrained concentration estimate', 
                    'Simulated concentration',
                    'Measured concentration'))
        plt.grid()
        plt.ylabel('Concentration')

        plt.subplot(2, 1, 2)
        plt.plot(time, constr_x_est['T'])
        plt.plot(time, unconstr_x_est['T'])
        plt.plot(time, x['T'], ls = '--', color = 'k')
        plt.plot(time, y['T'], ls = '-', marker = '+', 
                 mfc = 'k', mec = 'k', mew = 1.)
        plt.legend(('Constrained temperature estimate',
                    'Unconstrained temperature estimate',
                    'Simulated temperature', 
                    'Measured temperature'))
        plt.grid()
        plt.ylabel('Temperature')
        
        plt.show()
    
if __name__=="__main__":
    run_demo()
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    