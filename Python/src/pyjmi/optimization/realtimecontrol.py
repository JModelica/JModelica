import time
import random
from os import system, path
import pickle
from abc import ABCMeta, abstractmethod
import math
import copy

import numpy as N
import matplotlib.pyplot as plt

from pyjmi import transfer_optimization_problem
from pyjmi.optimization.mpc import MPC
from pyjmi.optimization.casadi_collocation import BlockingFactors
from casadi import ExternalFunction, NlpSolver
from pymodelica import compile_fmu
from pyfmi import load_fmu


class ParameterChanges(object):
    
    def __init__(self, par_change_dict={}, tol=1e-10):
        """
        Create a new ParameterChanges object.
        
        Parameters::
        
            par_change_dict --
                A dictionary containing times as keys and parameter
                name/value dictionaries as items.
                Default: Empty dictionary
                
            tol --
                The tolerance for time discrepancies when fetching a
                change. Due to floating point errors, the time values
                sent into get_new_pars may differ slightly from the
                expected ones; this parameter determines how much they
                are allowed to differ while still being treated as the
                same.
                Default: 1e-10
        """
        if par_change_dict == {}:
            self.pc_dict = {}
        else:
            self.pc_dict = copy.deepcopy(par_change_dict)
        self.tol = tol
        
    def add_change(self, time, par_dict):
        """
        Adds a parameter change.
        
        Parameters::
        
            time --
                The time when the parameter change should be applied.
                
            par_dict --
                A dictionary containing the names of parameters to be
                changed as keys, and their new values as values.
        """
        self.pc_dict[time] = par_dict.copy()
        
    def get_new_pars(self, time):
        """
        Fetches the new parameter values for a given time.
        
        Parameters::
        
            time --
                The time for which to fetch the parameter changes.
                
        Returns::
            
            A dictionary containing the parameter changes for the given
            time if it was found (within the tolerance set in the
            constructor), and None otherwise.
        """
        for t in self.pc_dict:
            if abs(t-time) < self.tol:
                return self.pc_dict[t]
        return None
      
      
class RealTimeBase(object):
    
    __metaclass__ = ABCMeta
    
    def __init__(self, dt, t_final, start_values, output_names, 
                 input_names, par_changes = ParameterChanges(), noise=0):
        
        self.n_steps = int(t_final/dt)
        self.dt = float(dt)
        self.start_values = start_values
        self.par_changes = par_changes
        self.outputs = output_names
        self.inputs = input_names
        self.noise = noise
        
        self.results = {}
        for name in self.outputs:
            self.results[name] = [start_values['_start_' + name]]
        for name in self.inputs:
            self.results[name] = [0]
        self.results['time'] = [dt*i for i in range(self.n_steps+1)]
        
        self.stats = []
        self.late_times = []
        self.wait_times = []
        self.solve_times = []
        
        self._ia = False
        self._already_run = False
        self._realtime = True
    
    @abstractmethod
    def send_control_signal(self, u_k):
        """
        Dummy method for sending a control signal to the process.
        
        In order to use this class, this method needs to be overridden.
        The override method should take take the control signal, convert
        if to a format understandable by the process if necessary, and
        pass it on to the process that shouldbe controlled.
        
        Parameters::
        
            u_k --
                The control signal. It consists of a pair where the
                first element is a list of input names, and the second
                is a function that takes the time and returns a Numpy
                array of values corresponding to those inputs.
        """
        pass
        
    def wait_and_get_measurements(self, next_time):
        """
        Wait until the given time, and then get measurements from
        the process and return them.
        
        Parameters::
        
            next_time --
                The system time until which to wait.
                
        Returns::
        
            A dictionary containing the measurements from the process.
        """
        
        start_wait_time = time.time()
        if self._realtime:
            time.sleep(max(0, next_time - time.time()))
        end_wait_time = time.time()
        data = self.get_measurements()
        late_time = end_wait_time - next_time
        self.late_times.append(late_time)
        self.wait_times.append(end_wait_time - start_wait_time)
        if late_time > self.dt/10.0:
            print 'WARNING: Sample late by', late_time, 's.'
        return data
        
    @abstractmethod
    def get_measurements(self):
        """
        Dummy method for getting measurements from the process.
        
        In order to use this class, this method needs to be overridden.
        The override method should get measurements from the process and
        return them in the form of a dictionary, where the keys are
        names of output variables prefixed by '_start_' and the values
        are their values.
        """
        pass
    
    def estimate_states(self, m_k, x_k_last):
        """
        Estimate the full output state dictionary.
        
        This method takes the measurements gotten from the process in this
        time step and the full state dictionary from the last step, and uses
        them to calculate an estimate of the full state vector for this
        time step. In the base class, all it does is return the measurement
        vector from the process, but if your process has non-observable
        states, you should override this method and use it to calculate
        those states.
        
        Parameters::
            
            m_k --
                The measurement dictionary gotten from the process with
                get_measurements(). The keys are variable names prefixed
                with '_start_', and the values are the values of those
                variables.
            x_k_last --
                The full state dictionary from the last time step. The
                format is the same as for x_k.
                
        Returns::
        
            An estimate of the full output state dictionary. The format is
            the same as for the inputs.
        """
        return m_k
        
    def get_results(self):
        """
        Return the results from the run.
        
        Returns::
        
            A dictionary where the keys are variable names and the values are
            lists of values.
        """
        
        if not self._already_run:
            raise RuntimeError(
                'Results can only be accessed after run() has been called')
        return self.results
        
    def plot_results(self, outputs=None, inputs=None, var_labels={},
                     title="", cols=1):
        """
        Plot the results of the run.
        
        Parameters::
        
            outputs --
                A list containing the names of the output variables to be
                plotted. If set to None, plots all outputs.
                Default: None
                
            inputs --
                A list containing the names of the input variables to be
                plotted. If set to None, plots all inputs.
                Default: None
            
            var_labels --
                A dictionary containing variable names as keys and the
                labels to use for their plots as values. If a variable
                name to be plotted isn't present in the dictionary, its
                name is used as the label.
                Default: {}
                
            title --
                The title of the plot.
                Default: ""
                
            cols --
                The number of columns to divide the subplots into.
                Default: 1
            
        """
        
        if not self._already_run:
            raise RuntimeError(
                'Results can only be plotted after run() has been called')
        
        if outputs == None:
            outputs = self.outputs
        if inputs == None:
            inputs = self.inputs
        
        t_res = self.results['time']
        names = outputs + inputs
        rows = len(names)/cols
        
        plt.close(1)
        plt.figure(1)
        plt.hold(True)

        for i in range(len(names)):
            plt.subplot(rows, cols, i+1)
            name = names[i]
            if name in inputs:
                plt.step(t_res, self.results[name])
            else:
                plt.plot(t_res, self.results[name])
            plt.grid()
            plt.xlabel('Time')
            if name in var_labels:
                plt.ylabel(var_labels[name])
            else:
                plt.ylabel(name)
        
        plt.suptitle(title)
        
        plt.show()


class RealTimeMPCBase(RealTimeBase):
    """
    A base class for performing real time MPC on a process. Note that
    this is an abstract class; to use it, you need to extend it with
    the functions send_control_signal and get_values.
    """
    
    def __init__(self, file_path, opt_name, dt, t_hor, t_final,
                 start_values, par_values, output_names, input_names, 
                 par_changes=ParameterChanges(), mpc_options={},
                 constr_viol_costs={}, noise=0):
        """
        Create a real time MPC object.
        
        Parameters::
        
            file_path --
                The path of the .mop file containing the model to be used for
                the MPC solver.
                
            opt_name --
                The name of the optimization in the file specified by file_path
                to be used by the MPC solver.
                
            dt --
                The time to wait in between each sample.
                
            t_hor --
                The horizon time for the MPC solver. Must be an even multiple
                of dt.
                
            t_final --
                The total time to run the real time MPC.
                
            start_values --
                A dictionary containing the initial state values for the process.
                
            par_values --
                A dictionary containing parameter values to be set in the model.
                
            output_names --
                A list of the names of all of the output variables used in the
                model.
                
            input_names --
                A list of the names of all of the input variables used in the
                model.
                
            par_changes --
                A ParameterChanges object containing parameter changes and the
                times they should be applied.
                Default: An empty ParameterChanges object
                
            mpc_options --
                A dictionary of options to be used for the MPC solver.
                
            constr_viol_costs --
                Constraint violation costs used by the MPC solver. See the
                documentation of the MPC class for more information.
                
            noise --
                Standard deviation of the noise to add to the input signals.
                Default: 0
        """
        
        super(RealTimeMPCBase, self).__init__(dt, t_final, start_values,
                                              output_names, input_names,
                                              par_changes, noise)
        horizon = int(t_hor/dt)
        n_e = horizon 
        
        self._setup_MPC_solver(file_path, opt_name, dt, horizon, n_e, par_values,
                               constr_viol_costs, mpc_options)
        
        self.range_ = []
        for i, name in enumerate(self.inputs):
            var = self.solver.op.getVariable(name)
            self.range_.append((var.getMin().getValue(), var.getMax().getValue()))
        
    def _setup_MPC_solver(self, file_path, opt_name, dt, horizon, n_e,
                         par_values, constr_viol_costs={}, mpc_options={}):
    
        op = transfer_optimization_problem(opt_name, file_path,
                                           compiler_options = {'state_initial_equations' : True,"common_subexp_elim":False})
        op.set(par_values.keys(), par_values.values())
                                           
        opt_opts = op.optimize_options()
        opt_opts['n_e'] = n_e
        opt_opts['n_cp'] = 2
        opt_opts['IPOPT_options']['tol'] = 1e-10
        opt_opts['IPOPT_options']['print_time'] = False
        
        if 'IPOPT_options' in mpc_options:
            opt_opts['IPOPT_options'].update(mpc_options['IPOPT_options'])
        for key in mpc_options:
            if key != 'IPOPT_options':
                opt_opts[key] = mpc_options[key]
        
        self.solver = MPC(op, opt_opts, dt, horizon, constr_viol_costs = constr_viol_costs)  
            
    def enable_codegen(self, name=None):
        """
        Enables use of generated C code for the MPC solver.
        
        Generates and compiles code for the NLP, gradient of f, Jacobian of g,
        and Hessian of the Lagrangian of g Function objects, and then replaces
        the solver object in the solver's collocator with a new one that makes
        use of the compiled functions as ExternalFunction objects.
        
        Parameters::
                
            name --
                A string that if it is not None, loads existing files
                nlp_[name].so, grad_f_[name].so, jac_g_[name].so and
                hess_lag_[name].so as ExternalFunction objects to be used
                by the solver rather than generating new code.
                Default: None
        """
        self.solver.collocator.enable_codegen(name)
            
    def enable_integral_action(self, mu, M, error_names=None, u_e=None):
        """
        Enables integral action for the inputs.
        
        If integral action is enabled, in each step the input error is
        calculated and used to update the estimation of the error. By
        default, the input error is calculated as the matrix M times the
        difference between the current state vector as predicted by the
        solver in the last time step and as measured from the process
        in the current time step; however, this can be changed by
        overriding the estimate_input_error method.
        
        The low-pass filter used to update the estimate is
        [new estimate] = mu*[old estimate] + (1-mu)*[current estimate]
        
        Parameters::
        
            mu --
                Controls the convergence rate of the error estimate. 
                See above.
                
            M --
                A matrix used for calculating the input error from the state
                error. See above.
                
            error_names --
                A list containing the names of the model variables for
                the input errors. If set to None, it is assumed be the
                same as the list of input variables with the prefix '_e'
                appended to each one.
                Default: None
            
            u_e --
                A list containing a set of values to be applied as
                stationary errors to the input signals. Used for
                simulating a stationary error where there otherwise wouldn't
                be one. If set to None, no stationary error is applied.
                Default: None.
        """
        self._ia = True
        self.mu = mu
        self.M = M
        if error_names == None:
            self.errors = [name + '_e' for name in self.inputs]
        else:
            self.errors = error_names
        if u_e == None:
            self.u_e = N.zeros(len(self.inputs))
        else:
            self.u_e = N.array(u_e)
        self.u_e_e = N.zeros(len(self.inputs))
        
    def run(self, save=False):
        """
        Run the real time MPC controller defined by the object.
        
        Parameters::
        
            save --
                Determines whether or not to save data after running. If set
                to False, the same data can still be saved manually by using
                the save_results function.
                Default: False
                
        Returns::
        
            The results and statistics from the run.
        """
        if self._already_run:
            raise RuntimeError('run can only be called once')
            
        self.e_e = []
        
        n_outputs = len(self.outputs)
        n_inputs = len(self.inputs)
            
        x_k = self.start_values.copy()
        x_k_last = x_k.copy()
        
        time1 = time.clock()
        time2 = time.time()
        time3 = 0
        
        for k in range(self.n_steps):
            new_pars = self.par_changes.get_new_pars(k*self.dt)
            if new_pars != None:
                self.solver.op.set(new_pars.keys(), new_pars.values())
            
            self.solver.update_state(x_k)
            u_k = self.solver.sample()
            u_k = self._apply_noise(u_k, std_dev = self.noise)
            if self._ia:
                u_k_e = self._apply_error(u_k)
            
            if time3 != 0:
                solve_time = time.time() - time3
                self.solve_times.append(solve_time)
                if solve_time > self.dt*0.2:
                    print 'WARNING: Control signal late by', solve_time, 's'
            if self._ia:
                self.send_control_signal(u_k_e)
            else:
                self.send_control_signal(u_k)
            if k == 0:
                next_time = time.time() + self.dt
            m_k = self.wait_and_get_measurements(next_time)
            next_time = time.time() + self.dt
            time3 = time.time()
            x_k = self.estimate_states(m_k, x_k_last)
            x_k_last = x_k.copy()
            if self._ia:
                self._update_error_estimate(x_k)
        
            for i in range(n_outputs):
                self.results[self.outputs[i]].append(x_k['_start_' + self.outputs[i]])
            for i in range(n_inputs):
                self.results[self.inputs[i]].append(u_k[1](0)[i])
            self.stats.append(self.solver.collocator.solver_object.getStats())
            
        self.ptime = time.clock()-time1
        self.rtime = time.time()-time2
        print 'Processor time:', self.ptime, 's'
        print 'Real time:', self.rtime, 's'
        
        if save:
            self.save_results()
            
        self._already_run = True
        
        return self.results, self.stats
    
    def _apply_noise(self, u_k, std_dev=0.0):
        if std_dev == 0:
            return u_k
        
        inputs = u_k[1](0)
        for n in range(len(inputs)):
            noise = N.random.normal(0.0, std_dev)
            inputs[n] += noise
            inputs[n] = max(self.range_[n][0], min(self.range_[n][1], inputs[n]))
        return (u_k[0], lambda t: inputs)
        
    def _apply_error(self, u_k):
        u_k_e = []
        for i in range(len(self.errors)):
            u_k_e.append(max(self.range_[i][0], min(self.range_[i][1],u_k[1](0)[i] + self.u_e[i])))
        return (u_k[0], lambda t: N.array(u_k_e))
        
    def _update_error_estimate(self, x_k):
        e_k = self._calculate_error(x_k)
        u_e_e_next = self.estimate_input_error(e_k)
        self.u_e_e = (1-self.mu)*self.u_e_e + self.mu*(u_e_e_next+self.u_e_e)
        for i in range(len(self.errors)):
            self.solver.set(self.errors[i], self.u_e_e[i])
        self.e_e.append(self.u_e_e)
            
    def estimate_input_error(self, e_k):
        """
        Estimates the input error given the state error.
        
        Parameters::
        
            e_k --
                The state error vector.
                
        Returns::
        
            The input error vector.
        """
        return self.M.dot(e_k)
        
    def _calculate_error(self, x_k):
        x_k_a = N.array([x_k['_start_' + name] for name in self.outputs])
        res = self.solver.get_results_this_sample()
        x_k_e = N.array([res[name][self.solver.options['n_cp']] for name in self.outputs])
        return x_k_a - x_k_e
        
    def print_stats(self):
        """
        Print statistics from the run.
        
        The times printed are the sums of the corresponding
        statistics from the NLP solver over all time steps.
        """        
        
        if not self._already_run:
            raise RuntimeError(
                'Stats can only be printed after run() has been called')
        stat_names = ['t_callback_fun', 't_callback_prepare', 't_eval_f',
                      't_eval_g', 't_eval_grad_f', 't_eval_h', 't_eval_jac_g',
                      't_mainloop']
                      
        total_times = {}
        for name in stat_names:
            total_times[name] = 0.

        for stat in self.stats:
            for name in stat_names:
                total_times[name] += stat[name]

        t_total = total_times['t_mainloop']
        print 'Total times:'
        for name in stat_names:
            print("%19s: %6.4f s (%7.3f%%)" %(name, total_times[name], total_times[name]/t_total*100))
    
    def save_results(self, filename=None):
        """
        Pickle and save data from the run to a file name either passed
        as an argument or entered by the user. If an empty string is
        entered as the file name, no data is saved.
        
        Parameters::
        
            filename --
                The file name to save as. If it is not provided, the
                user will be prompted to input it.
                Default: None
        """
        
        if not self._already_run:
            raise RuntimeError(
                'Results can only be saved after run() has been called')
        result_dict = {}
        result_dict['results'] = self.results
        result_dict['stats'] = self.stats
        result_dict['ptime'] = self.ptime
        result_dict['rtime'] = self.rtime
        result_dict['noise'] = self.noise
        result_dict['late_times'] = self.late_times
        result_dict['wait_times'] = self.wait_times
        result_dict['solve_times'] = self.solve_times
        save_to_file(result_dict, filename)


class MPCSimBase(RealTimeMPCBase):
    """
    Base class for running MPC on a simulated process.
    """
    
    def __init__(self, file_path, opt_name, model_name, dt, t_hor, t_final,
                 start_values, par_values, output_names, input_names, 
                 obs_var_names=None, par_changes=ParameterChanges(), 
                 mpc_options={},sim_options={}, constr_viol_costs={},
                 noise=0):
        
        """
        Creates an MPC object containing a simulated process to
        run it on.
        
        Parameters::
        
            file_path --
                The path of the .mop file containing the model to be used for
                the MPC solver.
                
            opt_name --
                The name of the optimization in the file specified by file_path
                to be used by the MPC solver.
                
            model_name --
                The name of the model in the file specified by file_path to be
                used for the simulated process.
                
            dt --
                The time to wait in between each sample.
                
            t_hor --
                The horizon time for the MPC solver. Must be an even multiple
                of dt.
                
            t_final --
                The total time to run the real time MPC.
                
            start_values --
                A dictionary containing the initial state values for the process.
                
            par_values --
                A dictionary containing parameter values to be set in the model.
                
            output_names --
                A list of the names of all of the output variables used in the
                model.
                
            input_names --
                A list of the names of all of the input variables used in the
                model.
                
            obs_var_names --
                A list of the names of all state variables that should be
                observable. If set to None, all state variables are assumed
                to be observable.
                Default: None
                
            par_changes --
                A ParameterChanges object containing parameter changes and the
                times they should be applied.
                Default: An empty ParameterChanges object
                
            mpc_options --
                A dictionary of options to be used for the MPC solver.
                
            sim_options --
                A dictionary of options to be used for the simulation.
                
            constr_viol_costs --
                Constraint violation costs used by the MPC solver. See the
                documentation of the MPC class for more information.
                
            noise --
                Standard deviation of the noise to add to the input signals.
                Default: 0
        """
        
        super(MPCSimBase, self).__init__(
            file_path, opt_name, dt, t_hor, t_final, start_values,
            par_values, output_names, input_names, par_changes,
            mpc_options, constr_viol_costs, noise)
            
        if obs_var_names is not None:
            self.obs_var_names = obs_var_names
        else:
            self.obs_var_names = output_names
            
        self.sim_options = {'initialize': False, 'CVode_options': {'verbosity': 50}}
        if 'CVode_options' in sim_options:
            self.sim_options['CVode_options'].update(sim_options['CVode_options'])
        for k in sim_options:
            if k != 'CVode_options':
                self.sim_options[k] = sim_options[k]
        
        sim_fmu = compile_fmu(model_name, file_path,
                              compiler_options = {'state_initial_equations' : True})
        self.model = load_fmu(sim_fmu)
        self.model.set(start_values.keys(), start_values.values())
        self.model.set(par_values.keys(), par_values.values())
        self.model.initialize()
        self.t = 0
        self._realtime = False
        
    def send_control_signal(self, u_k):
        """
        Send a control signal to the simulated process and use it to simulate
        the process for a single time step.
        
        Parameters::
            
            u_k --
                The control signal. It consists of a pair where the
                first element is a list of input names, and the second
                is a function that takes the time and returns a Numpy
                array of values corresponding to those inputs.
        """
        
        self.sim_res = self.model.simulate(self.t, self.t + self.dt,
                                           input = u_k,
                                           options = self.sim_options)

    def get_measurements(self):
        """
        Get measurements of the observable states from the process.
        
        Returns::
        
            A dictionary containing state variable names prefixed by '_start_'
            as keys and the values of the variables as values.
        """
        self.t += self.dt
        data = {'_start_' + name: self.sim_res.final(name) for name in self.obs_var_names}
        return data


class RealTimeLQRBase(RealTimeBase):
    """
    A base class for performing real time LQR on a process. Note that
    this is an abstract class; to use it, you need to extend it with
    the functions send_control_signal and get_values.
    """
    
    def __init__(self, K, dt, t_final, start_values, ctrl_point,
                 output_names, input_names, input_ranges,
                 par_changes=ParameterChanges(), noise=0):
        """
        Create a real time LQR object.
        
        Parameters::
        
            K --
                The linear gain feedback matrix used to calculate the control
                signal from the state vector.
                
            dt --
                The time to wait in between each sample.
                
            t_final --
                The total time to run the real time LQR.
                
            start_values --
                A dictionary containing the initial state values for the process.
                
            ctrl_point --
                A dictionary containing the initial control point, with the keys
                being state names and values their values.
                
            output_names --
                A list of the names of all of the output variables used in the
                model.
                
            input_names --
                A list of the names of all of the input variables used in the
                model.
            
            input_ranges --
                A list of the ranges to clamp the input control signals to,
                in the same order as in input_names. Each range should be a
                pair with the first element being the lower bound and the
                second being the upper.
                
            par_changes --
                A ParameterChanges object containing parameter changes and the
                times they should be applied.
                Default: An empty ParameterChanges object
                
            noise --
                Standard deviation of the noise to add to the input signals.
                Default: 0
        """
        
        super(RealTimeLQRBase, self).__init__(dt, t_final, start_values,
                                              output_names, input_names,
                                              par_changes, noise)
        self.K = K
        self.ctrl_point = ctrl_point
        self.range_ = input_ranges
    
    def enable_integral_action(self, mu, A, B, M, error_names=None, u_e=None):
        
        """
        Enables integral action for the inputs.
        
        If integral action is enabled, in each step the input error is
        calculated and used to update the estimation of the error. By
        default, the input error is calculated as the matrix M times the
        difference between the current state vector as predicted by the
        process model x[k+1] = A*x_k + B*u_k and as measured from the
        process in the current time step; however, this can be changed by
        overriding the estimate_input_error method.
        
        The low-pass filter used to update the estimate is
        [new estimate] = mu*[old estimate] + (1-mu)*[current estimate]
        
        Parameters::
        
            mu --
                Controls the convergence rate of the error estimate. 
                See above.
            
            A --
                A matrix used in the process model to calculate the predicted
                state vector. See above.
            
            B --
                A matrix used in the process model to calculate the predicted
                state vector. See above.
                
            M --
                A matrix used for calculating the input error from the state
                error. See above.
                
            error_names --
                A list containing the names of the model variables for
                the input errors. If set to None, it is assumed be the
                same as the list of input variables with the prefix '_e'
                appended to each one.
                Default: None
            
            u_e --
                A list containing a set of values to be applied as
                stationary errors to the input signals. Used for
                simulating a stationary error where there otherwise wouldn't
                be one. If set to None, no stationary error is applied.
                Default: None.
        """
        
        self._ia = True
        self.mu = mu
        self.A = A
        self.B = B
        self.M = M
        if error_names == None:
            self.errors = [name + '_e' for name in self.inputs]
        else:
            self.errors = error_names
        if u_e == None:
            self.u_e = N.zeros(len(self.inputs))
        else:
            self.u_e = N.array(u_e)
        self.u_e_e = N.zeros(len(self.inputs))
    
    def run(self, save=False):
        """
        Run the real time MPC controller defined by the object.
        
        Parameters::
        
            save --
                Determines whether or not to save data after running. If set
                to False, the same data can still be saved manually by using
                the save_results function.
                Default: False
                
        Returns::
        
            The results and statistics from the run.
        """
        
        if self._already_run:
            raise RuntimeError('already run')
        
        n_outputs = len(self.outputs)
        n_inputs = len(self.inputs)
            
        x_k = self.start_values.copy()
        x_k_last = x_k.copy()
        ctrl_point = self.ctrl_point.copy()
        
        time1 = time.clock()
        time2 = time.time()
        time3 = 0
        
        for k in range(self.n_steps):
            new_pars = self.par_changes.get_new_pars(k*self.dt)
            if new_pars != None:
                for name, value in new_pars.items():
                    ctrl_point[name] = value
                    
            for name, value in ctrl_point.items():
                if name in self.outputs:
                    x_k['_start_' + name] -= value
                    
            control_signal = -N.dot(self._x_to_array(x_k), self.K.T)
            if len(self.inputs) == 1:
                control_signal = [control_signal]
            for name, value in ctrl_point.items():
                if name in self.inputs:
                    i = self.inputs.index(name)
                    control_signal[i] += value
            
            if self._ia:
                u_k = (self.inputs, lambda t: control_signal - self.u_e_e)
            else:
                u_k = (self.inputs, lambda t: control_signal)
            
            u_k = self._apply_noise_and_range(u_k, std_dev = self.noise)
            if self._ia:
                u_k_e = self._apply_error(u_k)
            
            if time3 != 0:
                solve_time = time.time() - time3
                self.solve_times.append(solve_time)
                if solve_time > self.dt*0.2:
                    print 'WARNING: Control signal late by', solve_time, 's'
            if self._ia:
                self.send_control_signal(u_k_e)
            else:
                self.send_control_signal(u_k)
            if k == 0:
                next_time = time.time() + self.dt
            m_k = self.wait_and_get_measurements(next_time)
            next_time = time.time() + self.dt
            time3 = time.time()
            x_k = self.estimate_states(m_k, x_k_last)
            if self._ia:
                self._update_error_estimate(x_k, x_k_last, u_k, ctrl_point)
            x_k_last = x_k.copy()
        
            for i in range(n_outputs):
                self.results[self.outputs[i]].append(x_k['_start_' + self.outputs[i]])
            for i in range(n_inputs):
                self.results[self.inputs[i]].append(u_k[1](0)[i])
            
        self.ptime = time.clock()-time1
        self.rtime = time.time()-time2
        print 'Processor time:', self.ptime, 's'
        print 'Real time:', self.rtime, 's'
        
        if save:
            self.save_results()
            
        self._already_run = True
        
        return self.results
        
    def _apply_noise_and_range(self, u_k, std_dev=0.0):
        inputs = u_k[1](0)
        for n in range(len(inputs)):
            if std_dev != 0:
                noise = N.random.normal(0.0, std_dev)
                inputs[n] += noise
            inputs[n] = max(self.range_[n][0], min(self.range_[n][1], inputs[n]))
        return (u_k[0], lambda t: inputs)
        
    def _apply_error(self, u_k):
        u_k_e = []
        for i in range(len(self.errors)):
            u_k_e.append(max(self.range_[i][0], min(self.range_[i][1],u_k[1](0)[i] + self.u_e[i])))
        return (u_k[0], lambda t: N.array(u_k_e))
        
    def _x_to_array(self, x_k):
        return N.array([x_k['_start_' + name] for name in self.outputs])
        
    def _update_error_estimate(self, x_k, x_k_last, u_k, ctrl_point):
        e_k = self._calculate_error(x_k, x_k_last, u_k, ctrl_point)
        u_e_e_next = self.estimate_input_error(e_k)
        self.u_e_e = (1-self.mu)*self.u_e_e + self.mu*u_e_e_next
    
    def _calculate_error(self, x_k, x_k_last, u_k, ctrl_point):
        x_stat = [ctrl_point[name] for name in self.outputs]
        u_stat = [ctrl_point[name] for name in self.inputs]
        dx_k = self._x_to_array(x_k) - x_stat
        dx_k_last = self._x_to_array(x_k_last) - x_stat
        du_k = u_k[1](0) - u_stat
        return dx_k - (N.dot(self.A, dx_k_last) + N.dot(self.B, du_k))
            
    def estimate_input_error(self, e_k):
        """
        Estimates the input error given the state error.
        
        Parameters::
        
            e_k --
                The state error vector.
                
        Returns::
        
            The input error vector.
        """
        return self.M.dot(e_k)
    
    def save_results(self, filename=None):
        """
        Pickle and save data from the run to a file name either passed
        as an argument or entered by the user. If an empty string is
        entered as the file name, no data is saved.
        
        Parameters::
        
            filename --
                The file name to save as. If it is not provided, the
                user will be prompted to input it.
                Default: None
        """
        
        if not self._already_run:
            raise RuntimeError(
                'Results can only be saved after run() has been called')
        result_dict = {}
        result_dict['results'] = self.results
        result_dict['ptime'] = self.ptime
        result_dict['rtime'] = self.rtime
        result_dict['noise'] = self.noise
        result_dict['late_times'] = self.late_times
        result_dict['wait_times'] = self.wait_times
        result_dict['solve_times'] = self.solve_times
        save_to_file(result_dict, filename)


class LQRSimBase(RealTimeLQRBase):
    """
    Base class for running LQR on a simulated process.
    """
    
    def __init__(self, file_path, model_name, K, dt, t_final,
                 start_values, ctrl_point, output_names, input_names,
                 input_ranges, par_values={}, obs_var_names=None,
                 par_changes=ParameterChanges(), sim_options={}, noise=0):
        
        """
        Creates an LQR object containing a simulated process to
        run it on.
        
        Parameters::
        
            file_path --
                The path of the .mop file containing the model to be used for
                simulating the process.
                
            model_name --
                The name of the model in the file specified by file_path to be
                used for the simulated process.
        
            K --
                The linear gain feedback matrix used to calculate the control
                signal from the state vector.
                
            dt --
                The time to wait in between each sample.
                
            t_final --
                The total time to run the real time LQR.
                
            start_values --
                A dictionary containing the initial state values for the process.
                
            ctrl_point --
                A dictionary containing the initial control point, with the keys
                being state names and values their values.
                
            output_names --
                A list of the names of all of the output variables used in the
                model.
                
            input_names --
                A list of the names of all of the input variables used in the
                model.
            
            input_ranges --
                A list of the ranges to clamp the input control signals to,
                in the same order as in input_names. Each range should be a
                pair with the first element being the lower bound and the
                second being the upper.
                
            par_changes --
                A ParameterChanges object containing parameter changes and the
                times they should be applied.
                Default: An empty ParameterChanges object
                
            obs_var_names --
                A list of the names of all state variables that should be
                observable. If set to None, all state variables are assumed
                to be observable.
                Default: None
                
            sim_options --
                A dictionary of options to be used for the simulation.
                
            noise --
                Standard deviation of the noise to add to the input signals.
                Default: 0
        """
                     
        super(LQRSimBase, self).__init__(
            K, dt, t_final, start_values, ctrl_point, output_names,
            input_names, input_ranges, par_changes, noise)
        
        if obs_var_names is not None:
            self.obs_var_names = obs_var_names
        else:
            self.obs_var_names = output_names
            
        self.sim_options = {'initialize': False, 'CVode_options': {'verbosity': 50}}
        if 'CVode_options' in sim_options:
            self.sim_options['CVode_options'].update(sim_options['CVode_options'])
        for k in sim_options:
            if k != 'CVode_options':
                self.sim_options[k] = sim_options[k]
        
        sim_fmu = compile_fmu(model_name, file_path,
                              compiler_options = {'state_initial_equations' : True})
        self.model = load_fmu(sim_fmu)
        self.model.set(start_values.keys(), start_values.values())
        self.model.set(par_values.keys(), par_values.values())
        self.model.initialize()
        self.t = 0
        self._realtime = False
        
    def send_control_signal(self, u_k): 
        """
        Send a control signal to the simulated process and use it to simulate
        the process for a single time step.
        
        Parameters::
            
            u_k --
                The control signal. It consists of a pair where the
                first element is a list of input names, and the second
                is a function that takes the time and returns a Numpy
                array of values corresponding to those inputs.
        """
        
        self.sim_res = self.model.simulate(self.t, self.t + self.dt,
                                           input = u_k,
                                           options = self.sim_options)

    def get_measurements(self):
        """
        Get measurements of the observable states from the process.
        
        Returns::
        
            A dictionary containing state variable names prefixed by '_start_'
            as keys and the values of the variables as values.
        """
        
        self.t += self.dt
        data = {'_start_' + name: self.sim_res.final(name) for name in self.obs_var_names}
        return data


def save_to_file(data, filename=None):
    """
    Pickles and saves data to a file.
    
    Parameters::
    
        data --
            The object to save.
            
        filename --
            The name of the file to save the data to. If not given, the
            user will be prompted for it.
            Default: None
    """
    
    if filename is None:
        filename = raw_input('Enter file name to save as: ')
    if filename != '':
        if '.' not in filename:
            filename += '.pkl'
        with open(filename, 'wb') as outfile:
            pickle.dump(data, outfile)
    
        
def load_from_file(filename=None):
    """
    Unpickles and loads data from a file.
    
    Parameters::
            
        filename --
            The name of the file to load the data from. If not given, the
            user will be prompted for it.
            Default: None
    
    Returns::
    
        The object loaded from the file.
    """
    
    if filename is None:
        filename = raw_input('Enter file name to load: ')
    if '.' not in filename:
        filename += '.pkl'
    with open(filename, 'rb') as infile:
        data = pickle.load(infile)
        return data
