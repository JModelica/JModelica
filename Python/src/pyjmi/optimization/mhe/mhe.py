#!/usr/bin/env python
# -*- coding: utf-8 -*-

#    Copyright (C) 2015 Modelon AB
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, version 3 of the License.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
import numpy as N
from collections import Iterable, OrderedDict
from casadi import MX
from pyjmi.optimization.casadi_collocation import ExternalData
from pyjmi.common.algorithm_drivers import OptionBase
import modelicacasadi_wrapper as mc

from ekf_arrival_cost import EKFArrivalCost
import check_mhe_inputs as check


class MHE(object):
    """
    An object used to perform Moving Horizon Estimation on a Modelica
    model.
    """
  
    def __init__(self, op, sample_time, horizon, x_0_guess, dx_0,
                 c_0, MHE_opts):
        """
        Initiates an MHE object. This includes creating an 
        EKFArrivalCost-object used for the arrival cost approximation 
        and adding the MHE problem formulation to the 
        OptimizationProblem object.
    
        Parameters::
            op --
                An OptimizationProblem object.
                
            sample_time --
                The sample time.
            
            horizon --
                The horizon of the MHE. Given as an integer.
            
            x_0_guess --
                A dict containing a guess of the initial state 
                values. Items are on the form ('name', value).
            
            dx_0 --
                The initial value of the derivative of the state 
                variables. Given as a list of tuples on the form 
                (varName, value).

            c_0 --
                The initial value of the algebraic variables. 
                Given as a list of tuples on the form 
                (varName, value).
            
            MHE_opts --
                A MHEOptions object. See the documentation of the 
                options object for more details.
        """
        #Extract information about the initial value guess from the input
        self._x_0_guess = x_0_guess.copy()
    
        #Extract information about the model from the parameters
        self.sample_time = sample_time
        self.horizon = horizon
        self.op = op
        
        #Replace the names of the alias variables with their model variable 
        #counterparts and check for any errors in the inputs
        dx_0, c_0 = self._check_inputs_and_replace_aliases(list(dx_0), 
                                                           list(c_0), 
                                                           MHE_opts)
        
        #Create a dict that keeps track of the original names sent in by 
        #the user, used when creating the return form the estimation
        self._state_alias_dict = self._create_alias_dict(x_0_guess)

        ###Sort the different name lists of input signals to make it 
        ##more convenient for the EKF arrival cost approximation
        #Sort the inputs so that the disturbed ones are last
        undisturbed = [name for name in self.MHE_opts['input_names'] \
                    if name not in self._process_noise_names]
        disturbed = [name for name in self.MHE_opts['input_names'] \
                if name in self._process_noise_names]
        self.MHE_opts['input_names'] = undisturbed + disturbed
        #Sort the process noise names so that the disturbed inputs are first
        non_control = [name for name in self._process_noise_names \
                       if name not in disturbed]
        self._process_noise_names = disturbed + non_control
        
        
        #Create a dictionary keeping track of the various dimensions
        self._size_dict = {'x':len(self._state_names),
                           'y':len(self._measured_var_names),
                           'u':len(self.MHE_opts['input_names']), 
                           'c':len(self._alg_var_names), 
                           'w':len(self._process_noise_names), 
                           'v':len(self._measured_var_names)}
        
        
        #Keep track of the input signals and the measurements by creating a 
        #dictionary that stores the row number a variable is stored in the 
        #array that stores its values
        input_list = [(name, k) for k, name in \
                      enumerate(self.MHE_opts['input_names'])]
        meas_list = [(name, k) for k, name in \
                     enumerate(self._measured_var_names)]
        self._input_row_map = dict(input_list + meas_list)
    
      
        #Keep track of the states, their derivatives and the algebraic 
        #variables  by creating a dictionary that stores the row number a 
        #variable is stored in the array that stores its values
        x_list = [(name, k) for k, name in enumerate(self._state_names)]
        dx_list = [('der(' + name + ')', k) for k, name in \
                   enumerate(self._state_names)]
        alg_list = [(name, k) for k, name in enumerate(self._alg_var_names)]
        self._variable_row_map = dict(x_list + dx_list + alg_list)
    
        self._dx_est = N.zeros((self._size_dict['x'], 1))
        for name, value in dx_0:
            row = self._variable_row_map[name]
            self._dx_est[row,0] = value
    
        self._c_est = N.zeros((self._size_dict['c'],1))
        for name, value in c_0:
            row = self._variable_row_map[name]
            self._c_est[row,0] = value
    
        self.x_est = N.zeros((self._size_dict['x'],1))
        for name, value in self._x_0_guess.items():
            row = self._variable_row_map[name]
            self.x_est[row,0] = value
        
        #Create the EKF-object
        self.EKF_object = EKFArrivalCost(self.op, 
                                         self.sample_time, 
                                         self._state_names, 
                                         self._alg_var_names, 
                                         self._process_noise_names,
                                         self._undefined_input_names, 
                                         self._measured_var_names, 
                                         self.MHE_opts)
    
    
        #Add the MHE problem formulation to the op
        self._add_optimization_problem_to_op()
        
        
        #Create a list of names of the actual inputs to the model
        #Some new inputs might have been swapped i.e. u0 inputs for u
        self._input_var_names = [var.getName() for var in self._input_vars]
        
        self._P_index_name_list = [(index_tuple, par.getName()) \
                                   for (index_tuple, par) in self._P0_vars]
    
    
        self.next_time_index = 1
        #Creates an array that keeps track of the time points
        self._time_vector = [0]
        #Creates the options object for the optimization
        self._opts = self.op.optimize_options()
        #Specifies backward Euler
        self._opts['n_cp'] = 1
        
        #Set the IPOPT options
        self._opts["IPOPT_options"] = self.MHE_opts['IPOPT_options']
        ###Dirty flag indicating change of the parameters
        self._dirty = False
            
         
    def _create_alias_dict(self, x_0_guess):
        """
        Creates a dictionary for the MHE object that has the model 
        names of the states as the keys and the names provided by the 
        user for that state as the value.
        
        The dictionary is created to keep track of the user provided 
        names, so that the user does not receive unexpected variable 
        names in the return variables.
        
        Parameters::
            x_0_guess --
                A dict containing a guess of the initial state 
                values. Items are on the form ('name', value).
                
        Returns::
            state_alias_dict --
                A dictionary that maps the names for the states 
                provided by the user to the names they have in the 
                model.
        """
        old_state_names = x_0_guess.keys()
        corresponding_model_names = [self.op.getModelVariable(name).getName() \
                                     for name in old_state_names]
        state_alias_dict = dict(zip(corresponding_model_names, old_state_names))
        return state_alias_dict
      
    def _check_inputs_and_replace_aliases(self, dx_0, c_0, MHE_opts):
        """
        Checks if the user provided inputs contain any 
        irregularities. Also replaces any alias variables, should 
        any such exist.
        
        Parameters::
            dx_0 --
                The initial value of the derivative of the state 
                variables. Given as a list of tuples on the form 
                (varName, value).

            c_0 --
                The initial value of the algebraic variables. 
                Given as a list of tuples on the form 
                (varName, value)
            
            MHE_opts --
                A MHEOptions object. See the documentation of the 
                options object for more details.
                
        Returns::
            new_dx_0 --
                The initial value of the derivative of the state 
                variables. Given as a list of tuples on the form 
                (varName, value). Any eventual aliases have been 
                replaced.
                
            new_c_0 --
                The initial value of the algebraic variables. 
                Given as a list of tuples on the form 
                (varName, value). Any eventual aliases have been 
                replaced.
        """
        #Check sample time and horizon
        self._check_sample_time_and_horizon()
        #Check options
        (self._process_noise_names, 
            self._measured_var_names, 
            self._undefined_input_names, 
            self.MHE_opts) = check.check_MHE_opts(self.op, MHE_opts)
        self._state_names = [var.getName() for var in \
                            self.op.getVariables(self.op.DIFFERENTIATED)]
        self._alg_var_names = [var.getName() for var in \
                              self.op.getVariables(self.op.REAL_ALGEBRAIC) \
                              if not var.isAlias()]

        #Check c_0 and generate a new list with the aliases replaced
        new_c_0 = check.check_tuple_list(self.op, 
                                         c_0, 
                                         self._alg_var_names, 
                                         'c_0')
        ##Check dx_0 and generate a new list with the aliases replaced
        #Remove 'der(' and ')'
        dx_0 = [(name[4:-1], value) for (name, value) in dx_0]
        (new_dx_0, 
         dx_0_names,
         dx_0_not_in_model, 
         dx_0_missing_names) = \
                    check.replace_aliases_in_tuple_list(self.op, 
                                                        dx_0, 
                                                        self._state_names)
        #Put back the 'der(' and ')'
        new_dx_0 = [('der(' + name + ')', value) for (name, value) in new_dx_0]
        dx_not_in_model = ['der(' + name + ')' for name in dx_0_not_in_model]
        dx_missing_names = ['der(' + name + ')' for name in dx_0_missing_names]
        dx_names = ['der(' + name + ')' for name in dx_0_names]
        
        #Check for errors in dx_0
        missing_list = [(dx_missing_names, 'dx_0')]
        check.report_missing_names(missing_list)
        not_in_model_list = [(dx_not_in_model, 'dx_0')]
        check.report_names_not_in_model(not_in_model_list)
        duplicate_list = [(dx_names, 'dx_0')]
        check.check_for_duplicates(duplicate_list)
        #Check x_0_guess and generate a new dict with the aliases replaced
        x_0_guess_items = check.check_tuple_list(self.op, 
                                                 self._x_0_guess.items(),
                                                 self._state_names,
                                                 'x_0_guess')
        self._x_0_guess = dict(x_0_guess_items)
        return(new_dx_0, new_c_0)
        
    def _check_sample_time_and_horizon(self):
        """
        Checks the sample_time and horizon inputs for errors.
        """
        #Not great but should be sufficient in this case, 
        #i.e. relatively small numbers
        if float(self.sample_time) != self.sample_time:
            raise TypeError("Error: Sample time must be a float")
        
        if int(self.horizon) != self.horizon:
            raise TypeError("Error: Sample time must be an integer")
            
        if self.sample_time < 0:
            raise ValueError("Error: Sample time must be greater than 0")
        
        if self.horizon < 0:
            raise ValueError("Error: Horizon must be greater than 0")
    
    def _add_optimization_problem_to_op(self):
        """
        Adds the MHE formulation to the OptimizationProblem object.
        
        Adds a number of objects to the MHE object:
        
        input_vars --
            A list of the input variables.
        
        initial_value_pars --
            A list of the initial state value parameters. 
        
        x_0_guess_pars --
            A list of the parameters for the initial guess.
        
        process_noise_vars --
            A list containing the process noise variables.
      
        measurement_noise_vars --
            A list containing the measurement noise variables.
        
        Q_vars --  
            A list containing the parameters of the Q-matrix 
            and their corresponding indices. The items in the 
            list is on the form (index_tuple, var), where var 
            is the variable and index_tuple is a tuple of the 
            index the parameter takes up in the matrix.
        
        R_vars --  
            A list containing the parameters of the R-matrix 
            and their corresponding indices. The items in the 
            list is on the form (index_tuple, var), where var 
            is the variable and index_tuple is a tuple of the 
            index the parameter takes up in the matrix.
        
        P0_vars --  
            A list containing the parameters of the P0-matrix 
            and their corresponding indices. The items in the 
            list is on the form (index_tuple, var), where var 
            is the variable and index_tuple is a tuple of the 
            index the parameter takes up in the matrix.
            
        beta_par --
            Parameter used as a forgetting factor to scale the 
            arrival cost part of the cost function.
        """
        #Set up the states and their initial values
        self._initial_value_pars = self._set_up_states_and_initial_values()
        
        #Set up the different inputs to the model
        (self._input_vars, self._process_noise_vars) = \
                        self._set_up_process_noise_and_input()
        
        #Set up the measurements of the model
        self._measurement_noise_vars = \
                self._set_up_measurement_noise_and_measurements()
      
        #Add and set parameters
        (self._Q_vars, self._R_vars, self._P0_vars, 
         self._x_0_guess_pars, self._sample_time_var) = \
                                    self._add_and_set_parameters()
        #Add masking signal
        self._mask_var = self._add_masking_signal()
        self._beta_par = self._add_real_parameter('_MHE_beta')
        self.op.set('_MHE_beta', 1.)
        #Set cost function
        self._set_objectives()
        
    def _set_up_states_and_initial_values(self):
        """
        Sets the initial values for the states and returns a list of 
        the names of the state initial value parameters.
        Returns::
            initial_value_pars --
                Returns a list containing the initial value 
                parameters.
        """
        #Find the names of the initial state value parameters
        initial_value_pars = [par for par in \
                              self.op.getVariables(
                                self.op.REAL_PARAMETER_INDEPENDENT) \
                              if par.getName().startswith('_start_')]
        initial_value_names = [par.getName() for par in initial_value_pars]
        #Remove the _start_ prefix
        states = [name[7:] for name in initial_value_names]
        #Substitute for the model variable names
        states = [self.op.getModelVariable(name).getName() for name in states]
        
        #Set the initial value parameters as free
        for var in initial_value_pars:
            var.setAttribute('free',True)
        
        initial_value_dict = dict(zip(states, initial_value_pars))
        initial_value_pars = [initial_value_dict[name] \
                              for name in self._state_names]
        return initial_value_pars

    def _set_up_process_noise_and_input(self):
        """
        Puts the process noise variables and the system inputs in 
        lists. Adds new noise and true input variables if the input 
        is regarded as disturbed(a superposition of noise and the 
        true input, i.e. u = u0 + w) and puts the original input as 
        a free variable.
        
        All the variables that are added that are part of the MHE 
        formulation have the '_MHE_' prefix. In the case of 
        disturbed inputs the naming convention is as follows:
        
        New process noises: '_MHE_w_' + varName
        New input: '_MHE_u0_' + varName
        where varName is the name of the original input signal.
        
        Returns::
            input_vars -- 
                A list containing the input variables.
          
            process_noise_vars --
                A list containing the process noise variables
        """
        process_noise_vars = []
        input_vars = []
        #Add the undisturbed inputs
        for name in self.MHE_opts['input_names']:
            if name not in self._process_noise_names:
                input_vars.append(self.op.getVariable(name))
        
        for name in self._process_noise_names:
            #For all process noise inputs add it to the list and set as free
            if name not in self.MHE_opts['input_names']:
                var = self.op.getVariable(name)
                process_noise_vars.append(var)
                var.setAttribute('free', True)
            else:
                var = self.op.getVariable(name)
                #Adds the noise variable
                w_string = '_MHE_w_' + name
                w_var = self._add_real_variable(w_string)
                process_noise_vars.append(w_var)     
                #Adds the new "true" input variable
                u0_string = '_MHE_u0_' + name
                u0_var = self._add_real_input(u0_string)
                input_vars.append(u0_var)
                #Creates the connecting equation
                lhs = var.getVar()
                rhs = u0_var.getVar() + w_var.getVar()
                self.op.addDaeEquation(mc.Equation(lhs, rhs))
                #Sets the original input as a free variable
                var.setAttribute('free', True)
        

        return (input_vars, process_noise_vars)
 
    def _set_up_measurement_noise_and_measurements(self):
        """
        Adds measurement noise variables and measurement variables. 
        Also creates the equations that connect the two.
        
        All the variables that are added that are part of the MHE 
        formulation have the '_MHE_' prefix. In the case of disturbed 
        inputs the naming convention is as follows:
        
        New measurement input signal: '_MHE_y_meas_' + varName
        New measurement noise: '_MHE_v_' + varName
        where varName is the name of the measured variable.
        
        Returns::
            measurement_noise_vars --
                A list containing the measurement noise variables
        """
        measurement_noise_vars = []
      
        for name in self._measured_var_names:
            meas_var = self.op.getVariable(name)
            #Creates the measurement and measurement noise variables
            v_string = '_MHE_v_' + name
            y_meas_string = '_MHE_y_meas_' + name
            var = self._add_real_variable(v_string)
            inp = self._add_real_input(y_meas_string)
        
            #Create the equation that connects them
            rhs = inp.getVar() - meas_var.getVar()
            lhs = var.getVar()
            self.op.addDaeEquation(mc.Equation(lhs, rhs))
        
            measurement_noise_vars.append(var)
        
        return measurement_noise_vars
 
    def _add_and_set_parameters(self):
        """
        Adds the parameters that are associated with the optimization 
        problem to the model and sets their values.
      
        Adds parameters for the inverted weight matrices Q, R and P0.
        
        Adds parameters for the initial guess of the states and the 
        sample time.
        
        Adds the parameters for the start and end time of the Optimica 
        problem.
        
        All the parameters that are added that are part of the MHE 
        formulation have the '_MHE_' prefix.
      
        Returns::
            Q_vars --
                A list with items on the form (index_tuple, par), 
                where index_tuple is a tuple of the index the 
                parameter par has in the inverted Q-matrix it 
                represents.
          
            R_vars --
                A list with items on the form (index_tuple, par), 
                where index_tuple is a tuple of the index the 
                parameter par has in the inverted R-matrix it 
                represents.
          
            P0_vars --
                A list with items on the form (index_tuple, par), 
                where index_tuple is a tuple of the index the 
                parameter par has in the inverted P0-matrix it 
                represents.
          
            x_0_guess_pars --
                A list of the parameters for the initial guess.
          
            sample_time_var --
                Variable of the sample time.
        """
        #Add the startTime and finalTime parameters if they do not already exist
        st_var = self.op.getVariable('startTime')
        if st_var == None:
            self._add_real_parameter('startTime')
        ft_var = self.op.getVariable('finalTime')
        if ft_var == None:
            self._add_real_parameter('finalTime')
        #Add and then set the sample time
        sample_time_var = self._add_real_parameter('_MHE_sample_time')
        self.op.set('_MHE_sample_time', self.sample_time)
        
        #Add the process noise covariance matrix parameters
        Qinv_vars = \
          self._add_and_set_inverse_matrix(self._process_noise_names, 
                                           self.MHE_opts['process_noise_cov'], 
                                           '_MHE_Qinv')
        #Add the measurement noise covariance matrix parameters
        Rinv_vars = \
          self._add_and_set_inverse_matrix(self._measured_var_names,
                                           self.MHE_opts['measurement_cov'],
                                           '_MHE_Rinv')
        
        #Add the error covariance matrix parameters in P0_cov
        P0inv_vars = \
            self._add_and_set_inverse_matrix(self._state_names,
                                             self.MHE_opts['P0_cov'],
                                             '_MHE_P0inv')
        #Add the parameters not in P0_cov
        P0inv_vars = self._fill_P0_inverse(self._state_names, P0inv_vars)
        
        #Add the guess parameters
        x_0_guess_pars = []
        for name in self._state_names:
            value = self._x_0_guess[name]
            string = '_MHE_x_0_guess_' + name
            par = self._add_real_parameter(string)
            self.op.set(string, value)
            x_0_guess_pars.append(par)
        return (Qinv_vars, Rinv_vars, P0inv_vars, 
                x_0_guess_pars, sample_time_var)
    
    def _add_and_set_inverse_matrix(self, name_list, cov_list, matrix_name):
        """
        Creates a list on the form (index_tuple, par), where 
        index_tuple is a tuple of the index the parameter has in 
        the matrix it represents and par is the parameter object.
        
        Parameters::
            name_list --
                A list of names of the variables. Used to determine 
                the order the variables have in the problem 
                formulation.
            
            cov_list --
                A list with items on the form (name_list, covariance). 
                Where 'name_list' is a list or a tuple with the names 
                of variables having a covariance_matrix of 
                'covariance_matrix'. In the case of a one dimensional 
                the list may be a single string and the matrix itself 
                can be given as float.
                
            matrix_name --
                A string of the desired matrix base name, e.g. 
                '_MHE_Qinv'.
                
        Returns::
            matrix_index_par_list --
                A list on the form (index_tuple, par), where 
                index_tuple is a tuple consisting of the index 
                the parameter has in the matrix it represents and 
                par is the parameter object.
        """
        matrix_index_par_list = []
        for (list, cov_matrix) in cov_list:
            if isinstance(list, basestring):
                par_string = matrix_name + '_' + list
                #Check if parameter already exists
                par = self.op.getVariable(par_string)
                if par == None:
                    par = self._add_real_parameter(par_string)
                index = name_list.index(list)
                matrix_index_par_list.append(((index, index), par))
                self.op.set(par_string, 1./cov_matrix)
            else:
                dim = len(list)
                I = N.identity(dim)
                #Converts a possible float to an array
                if dim == 1:
                    cov_matrix = cov_matrix*I
                cov_inv = N.linalg.solve(cov_matrix, I)
                index_list = [name_list.index(name) for name in list]
                for i in range(dim):
                    for j in range(dim):
                        if i == j:
                            par_string = matrix_name + '_' + list[i]
                            #Check if parameter already exists
                            par = self.op.getVariable(par_string)
                            if par == None:
                                par = self._add_real_parameter(par_string)
                            matrix_index_par_list.append(((index_list[i],
                                                           index_list[j]), 
                                                           par))
                            self.op.set(par_string, cov_inv[i, j])
                        else:
                            n1 = list[i]
                            n2 = list[j]
                            par_string = matrix_name + '_' + n1 + '_' + n2
                            #Check if parameter already exists
                            par = self.op.getVariable(par_string)
                            if par == None:
                                par = self._add_real_parameter(par_string)
                            matrix_index_par_list.append(((index_list[i], 
                                                           index_list[j]), 
                                                           par))
                            self.op.set(par_string, cov_inv[i, j])
        return matrix_index_par_list
    
    def _fill_P0_inverse(self, name_list, index_par_list):
        """
        Adds covariances of zero for the unspecified elements of 
        the error covariance matrix. This is done since the sparsity
        of the P0-matrix can not be guaranteed once the estimation 
        has begun.
        
        Parameters::
            name_list --
                A list of names of the variables. Used to determine 
                the order the variables have in the problem 
                formulation.
            
            index_par_list --
                A list on the form (index_tuple, par), where 
                index_tuple is a tuple consisting of the index 
                the parameter has in the matrix it represents and 
                par is the parameter object.
                
        Returns::
            index_par_list --
                A list on the form (index_tuple, par), where 
                index_tuple is a tuple consisting of the index 
                the parameter has in the matrix it represents and 
                par is the parameter object. Now contains parameters 
                for all indices.
        """
        matrix_name = '_MHE_P0'
        dim = self._size_dict['x']
        existing_indices = [index_tuple for (index_tuple, _) in index_par_list]
        for i in range(dim):
            n1 = name_list[i]
            for j in range(dim):
                if (i, j) not in existing_indices:
                    if i == j:
                        par_string = matrix_name + '_' + n1
                    else:
                        n2 = name_list[j]
                        par_string = matrix_name + '_' + n1 + '_' + n2
                    par = self._add_real_parameter(par_string)
                    self.op.set(par_string, 0.)
                    index_par_list.append(((i, j), par))
        return index_par_list
                
    def _add_masking_signal(self):
        """
        Adds the masking signal that is used to eliminate the influence of 
        the measurement in the last sample in the cost function.
        Returns::
            mask_var --
                The variable of the mask signal
        """
        mask_var = self._add_real_input("_MHE_mask")
        return mask_var
 
    def _set_objectives(self):
        """
        Adds the cost function to the model. The cost function is on the 
        form:
      
        sum(w^(T)Q^(-1)w + v^(T)R^(-1)v) + beta*Z(T-N)
      
        Where Z(T) is the arrival cost, w the process noise, Q its 
        covariance matrix, v the measurement noise and R its covariance
        matrix.
        
        The parameter beta is a forgetting factor that can be used to 
        ensure that the arrival cost part does not cause divergence.
      
        The cost function in the optimization problem is divided in to two 
        parts, the objective part and the objective integrand part. In the 
        objective integrand most of the sum is expressed. The first index 
        of the sum must however be stored in the objective part due to the 
        approximation of the sum as an integral. The objective part also 
        stores the arrival cost.
        """
        objective_integrand = \
                self._get_objective_integrand(self._process_noise_vars, 
                                              self._measurement_noise_vars,
                                              self._Q_vars, 
                                              self._R_vars, 
                                              self._sample_time_var, 
                                              self._mask_var)
        objective = self._get_objective(self._process_noise_vars, 
                                        self._measurement_noise_vars, 
                                        self._initial_value_pars,
                                        self._x_0_guess_pars, 
                                        self._Q_vars, 
                                        self._R_vars, 
                                        self._P0_vars,
                                        self._beta_par,
                                        self._sample_time_var)
        self.op.setObjectiveIntegrand(objective_integrand)
        self.op.setObjective(objective)

    def _get_objective_integrand(self, w_vars, v_vars, Q_vars, R_vars, 
                                 sample_time_var, mask_var):
        """
        Sets up the objectiveIntegrand part of the cost function.
      
        Parameters::
            w_vars --
                A list containing the process noise variables.
          
            v_vars --
                A list containing the measurement noise variables.
        
            Q_vars --
                A list with items on the form (index_tuple, par), 
                where index_tuple is a tuple of the index the 
                parameter par has in the inverted Q-matrix it 
                represents.
          
            R_vars --
                A list with items on the form (index_tuple, par), 
                where index_tuple is a tuple of the index the 
                parameter par has in the inverted R-matrix it 
                represents.
        
            sample_time_var --
                The variable for the sample time.
                
            mask_var --
                The variable of the masking signal.
        
        Returns::
            objectiveIntegrand --
                The objective integrand part of the cost function.
        """
        w_part = self._objective_loop(w_vars, Q_vars)
        #Multiply with 1/sample_time to convert the Q-matrix inverse to 
        #its discrete counter part
        w_part = w_part/sample_time_var.getVar()
        v_part = self._objective_loop(v_vars, R_vars)
        #Multiply with sample_time to convert the R-matrix inverse to 
        #its discrete counter part
        v_part = v_part * sample_time_var.getVar()
        objective_integrand = (w_part + mask_var.getVar()*v_part)/ \
                             (sample_time_var.getVar())
        return objective_integrand
    
    def _objective_loop(self, vars, matrix_pars):
        """
        Multiplies the variable in the vars array with the 
        corresponding parameter in the matrix_pars list to generate 
        a part of the cost function.
        
        Parameters::
            vars --
                A list of the variables associated with the matrix 
                described by the parameters in the other input.
                
            matrix_pars --
                A list with items on the form (index_tuple, par), 
                where index_tuple is a tuple of the index the 
                parameter par has in the inverted matrix it 
                represents.
                
        Returns::
            x --
                An MX-expression of the part of the cost function 
                generated.
        """
        x = MX(0.)
        #Get the MX variables
        vars = [var.getVar() for var in vars]
        for ((i,j), par) in matrix_pars:
            var1 = vars[i]
            var2 = vars[j]
            x = x + var1*var2*par.getVar()
        return x
    
    def _get_objective(self, w_vars, v_vars, initial_value_pars, guess_vars, 
                       Q_vars, R_vars, P0_vars, beta_par, sample_time_var):
        """
        Creates the objective part of the cost function. Consists of 
        two parts a part with timed variables to compensate for the 
        sum-integral approximation and a part containing the arrival 
        cost. Adds a parameter that scales the arrival cost part of 
        the cost function.
      
        Parameters::
            w_vars --
                List containing the process noise variables.
          
            v_vars --
                A list containing the measurement noise variables.
          
            initial_value_pars --
                A list of the initial state value parameters.
          
            guess_vars --
                A list of the variables of the guesses of the initial 
                states.
          
            Q_vars --
                A list with items on the form (index_tuple, par), 
                where index_tuple is a tuple of the index the 
                parameter par has in the inverted Q-matrix it 
                represents.
          
            R_vars --
                A list with items on the form (index_tuple, par), 
                where index_tuple is a tuple of the index the 
                parameter par has in the inverted R-matrix it 
                represents.
            
            P0_vars --
                A list with items on the form (index_tuple, par), 
                where index_tuple is a tuple of the index the 
                parameter par has in the inverted P0-matrix it 
                represents.
            
            beta_par --
                Parameter used as a forgetting factor to scale the 
                arrival cost part of the cost function.
            
            sample_time_var --
                Variable of the sample time.
        
        Returns::
            objective --
                The objective part of the cost function.
        """
        
        objective = \
            self._get_arrival_cost_part_of_objective(initial_value_pars, 
                                                     guess_vars, P0_vars)
        objective = beta_par.getVar()*objective + \
                    self._objective_timed_variables(w_vars, 
                                                    v_vars, 
                                                    Q_vars, 
                                                    R_vars,
                                                    sample_time_var)
        return objective
      
    def _get_arrival_cost_part_of_objective(self, initial_value_pars, 
                                            guess_vars, P0_vars):
        """
        Returns the arrival cost part of the cost function.
        
        Parameters::
            initial_value_pars --
                A list of the initial state value parameters.
          
            guess_vars --
                A list of the variables of the guesses of the initial 
                states.
          
            P0_vars --
                A list with items on the form (index_tuple, par), 
                where index_tuple is a tuple of the index the 
                parameter par has in the inverted P0-matrix it 
                represents.
                
        Returns::
            x --
                The arrival cost part of the cost function as a MX 
                expression.
        """
        iv_minus_guess_list = []
        for k in range(self._size_dict['x']):
            iv_minus_guess_list.append(initial_value_pars[k].getVar() - \
                                       guess_vars[k].getVar())
        x = MX(0.)
        for ((i, j), par) in P0_vars:
            x = x + iv_minus_guess_list[i]*iv_minus_guess_list[j]*par.getVar()
        return x
    
    def _objective_timed_variables(self, w_vars, v_vars, Q_vars, 
                                   R_vars, sample_time_var):
        """
        Creates the part of the objective(which in turn is part of 
        the cost function) that contains timed variables. This part 
        makes up for the part of the cost function that is lost in 
        the objectiveIntegrand part due to the sum to integral 
        approximation.
      
        Parameters:
            op --
                The optimization problem 
          
            w_vars --
                List containing the process noise variables.
          
            v_vars --
                A list containing the measurement noise variables.
                
            Q_vars --
                A list with items on the form (index_tuple, par), 
                where index_tuple is a tuple of the index the 
                parameter par has in the inverted Q-matrix it 
                represents.
          
            R_vars --
                A list with items on the form (index_tuple, par), 
                where index_tuple is a tuple of the index the 
                parameter par has in the inverted R-matrix it 
                represents.
                
            sample_time_var --
                Variable of the sample time.
                
        Returns::
            timed_part --   
                Returns the MX-expression containing the part of the 
                objective that contains timed variables.
        """
        w_timed_vars = [self._add_timed_variable_start_time(var) \
                        for var in w_vars]
        v_timed_vars = [self._add_timed_variable_start_time(var) \
                        for var in v_vars]
        w_timed_part = self._objective_loop(w_timed_vars, Q_vars)
        #Multiply with 1/sample_time to convert the Q-matrix inverse to 
        #its discrete counter part
        w_timed_part = w_timed_part / sample_time_var.getVar()
        v_timed_part = self._objective_loop(v_timed_vars, R_vars)
        #Multiply with sample_time to convert the R-matrix inverse to 
        #its discrete counter part
        v_timed_part = v_timed_part * sample_time_var.getVar()
        timed_part = w_timed_part + v_timed_part
        return timed_part
    
    def step(self, u, y):
        """
        Estimates the state vector at the next sample using the 
        input and measurement vector at the current sample and 
        returns it.
        
        Parameters::
            u --
                The control signal for the current sample, given as 
                a list of tuples on the form (name, value) where 'name' 
                is the name of the control signal and 'value' its 
                value.
            
            y --
                The measurement for the current sample, given as a 
                list of tuples on the form (name, value) where 'name' 
                is the name of the measured variable and 'value' its 
                value.
                
        Returns::
            x_est_dict --
                A dictionary with the state names defined by the user 
                as keys and the state estimates at the next sample as 
                values.
        """
        #Add the time of the next sample to the time vector
        self._time_vector.append(self.next_time_index*self.sample_time)
        #Check the input and measurement names for errors and aliases
        (u, y) = self._check_u_and_y(u, y)
        self._append_new_data(u,y)
        if self.next_time_index <= self.horizon:
            startTime = 0.
        else:
            #Check if the derivative functions need to be regenerated
            if self._dirty:
                self.EKF_object.recalculate_jacobian_functions()
                self._dirty = False
            #LINEARIZE
            u_lin = []
            x_lin = []
            dx_lin = []
            alg_lin = []
            t0 = self._time_vector[0]
      
            for k, name in enumerate(self._state_names):
                x_lin.append((name, self.x_est[k,0]))
      
            for k, name in enumerate(self.MHE_opts['input_names']):
                u_lin.append((name, self.u[k,0]))
            
            #Add undefined inputs
            for name in self._undefined_input_names:
                u_lin.append((name, 0.))
            
            for k, name in enumerate(self._state_names):
                dx_lin.append(('der(' + name + ')', self._dx_est[k,0]))
      
            for k, name in enumerate(self._alg_var_names):
                alg_lin.append((name, self._c_est[k,0]))
      
            P = self.EKF_object.get_next_P(t0, x_lin, dx_lin, u_lin , 
                                            alg_lin)
            Pinv = N.linalg.inv(P)
            for (index, name) in self._P_index_name_list:
                self.op.set(name, Pinv[index])
      
            #Remove the oldest data
            self._remove_old_data()
            
            
            for (k, name) in enumerate(self._state_names):
                self.op.set('_MHE_x_0_guess_' + name, self.x_est[k,0])
      
            startTime = self._time_vector[0]
    
        finalTime = self._time_vector[-1]
        #Send relevant time params to the model
        self.op.setStartTime(MX(startTime))
        self.op.set('startTime',startTime)
        self.op.setFinalTime(MX(finalTime))
        self.op.set('finalTime',finalTime)
        #Number of elements
        n_e = (len(self._time_vector) - 1)
        self._opts['n_e'] = n_e
        self._opts['blocking_factors'] = [1] * (n_e)
        t_interval = self._time_vector
        y_interval = self.y
        u_interval = self.u
        external_data = self._create_external_data(t_interval, 
                                                   y_interval, 
                                                   u_interval)
        self._opts['external_data'] = external_data
        res = self.op.optimize(options = self._opts)
        x_est_dict = self._append_results(res)
        self.next_time_index += 1
        return x_est_dict
          
    def _append_new_data(self, u, y):
        """
        Appends the input for the next sample to the arrays that 
        keep track of them.
    
        Parameters::
        u --
            The control signal for the next sample, given as a list 
            of tuples on the form (name, value) where name is the name 
            of the control signal and value is its value.
        
        y --
            The measurement for the next sample, given as a list of 
            tuples on the form (name, value) where name is the name 
            of the measured variable and value is its value.
        """
        #Check if first time step, if so create the arrays used to save the 
        #data, otherwise add the new data to the already existing arrays
        if self.next_time_index == 1:
            self.y = N.zeros((self._size_dict['y'],1))
            for name, value in y:
                row = self._input_row_map[name]
                self.y[row,0] = value
            
            self.u = N.zeros((self._size_dict['u'],1))
            for name, value in u:
                row = self._input_row_map[name]
                self.u[row,0] = value
        else:
            #Append y-data
            y_t = N.zeros((self._size_dict['y'],1))
            for name, value in y:
                row = self._input_row_map[name]
                y_t[row,0] = value
            self.y = N.hstack([self.y, y_t])
            #Append u-data  
            u_t = N.zeros((self._size_dict['u'],1))
            for name, value in u:
                row = self._input_row_map[name]
                u_t[row,0] = value
            self.u = N.hstack([self.u, u_t])
    
    def _check_u_and_y(self, u, y):
        """
        Check the measurements and inputs for errors and 
        replace aliases.
        
        Parameters::
            u --
                The control signal for the next sample, given as 
                a list of tuples on the form (name, value) where name 
                is the name of the control signal and value is its 
                value.
            
            y --
                The measurement for the next sample, given as a 
                list of tuples on the form (name, value) where name 
                is the name of the measured variable and value is its 
                value.
                
        Returns::
            u --
                The control signal for the next sample, given as 
                a list of tuples on the form (name, value) where name 
                is the name of the control signal and value is its 
                value. All aliases replaced.
            
            y --
                The measurement for the next sample, given as a 
                list of tuples on the form (name, value) where name 
                is the name of the measured variable and value is its 
                value. All aliases replaced.
        """
        new_u = check.check_tuple_list(self.op, 
                                       u, 
                                       self.MHE_opts['input_names'], 
                                       'u')
        new_y = check.check_tuple_list(self.op, 
                                       y, 
                                       self._measured_var_names, 
                                       'y')
        return (new_u, new_y)
    
    def _remove_old_data(self):
        """
        Removes the data at the oldest time sample.
        """
        self._time_vector = self._time_vector[1:]
        self.u = self.u[:,1:]
        self.y = self.y[:,1:]
        self.x_est = self.x_est[:,1:]
        self._dx_est = self._dx_est[:,1:]
        self._c_est = self._c_est[:,1:]
    
    def _append_results(self, res):
        """
        Adds the latest set of results to the arrays containing the 
        estimated variables. And returns the estimate for the next 
        time point.
        
        Parameters::
          res --  
            A result object from the solved optimization problem.
            
        Results::
            x_est_dict --
                A dictionary with the state names defined by the user 
                as keys and the state estimates at the next sample as 
                values.
        """
        x_est_t = N.zeros((self._size_dict['x'],1))
        x_est_dict = {}
        for k, name in enumerate(self._state_names):
            value = res[name][-1]
            x_est_dict[self._state_alias_dict[name]] = value
            x_est_t[k,0] = value 
        self.x_est = N.hstack((self.x_est, x_est_t))
    
        dx_est_t = N.zeros((self._size_dict['x'],1))
        for k, name in enumerate(self._state_names):
            dx_name = 'der(' + name + ')'
            dx_est_t[k,0] = res[dx_name][-1]
        self._dx_est = N.hstack((self._dx_est,dx_est_t))
    
        c_est_t = N.zeros((self._size_dict['c'],1))
        for k, name in enumerate(self._alg_var_names):
            c_est_t[k,0] = res[name][-1]
        self._c_est = N.hstack((self._c_est,c_est_t))
        return x_est_dict
  
    def _create_external_data(self, t, y, u):
        """
        Creates the ExternalData object that is used to eliminate 
        inputs in the optimization. The input signals and the 
        measurements are extended by one to account for the next 
        sample. The masking signal removes the importance of 
        the last measurement by adopting the appropriate values. 
        
        Also eliminates the unspecified input signals by putting them 
        to zero.
    
        Parameters::
          t --
            1D numpy array containing the time points that are to be 
            eliminated.
          
          y --
            2D numpy array of the measurements that are to be 
            eliminated. Each row corresponds to a measured variable.
            
          u --
            2D numpy array of the control signal that are to be 
            eliminated. Each row corresponds to an input.
            
        Returns::
          external_data --
            The ExternalData object used to eliminate inputs in 
            the optimization.
        """
        eliminated = OrderedDict()
        #Extend the input signals
        u = N.vstack((u.T, u[:,-1])).T
    
        #Eliminate input signals 
        for (k, input_name) in enumerate(self._input_var_names):
            self._add_eliminated_row(t, u[k,:], input_name, eliminated)
        #Eliminate the unspecified input signals
        for name in self._undefined_input_names:
            self._add_eliminated_row(t, N.zeros(N.shape(t)), name, eliminated)
        
        #Extend the measurement signal
        y = N.vstack((y.T, y[:,-1])).T
        
        #Eliminate measurements
        for (k, name) in enumerate(self._measured_var_names):
            meas_name = '_MHE_y_meas_' + name
            self._add_eliminated_row(t, y[k,:], meas_name, eliminated)
        
        #Create the masking signal. Currently backward euler 
        #is used meaning that the signal is simply ones except 
        #for the last index where it is 0
        mask = N.ones(N.shape(t))
        mask[-1] = 0.
        self._add_eliminated_row(t, mask, "_MHE_mask", eliminated)
        external_data = ExternalData(eliminated=eliminated)
        return external_data

    def _add_eliminated_row(self, t, x, varName, dict):
        """
        Adds one eliminated variable to the dictionary used to 
        eliminate the inputs from the optimization.
        
        Parameters::
            t --
                1D numpy array containing the time points that are to 
                be eliminated

            x --
                1D numpy array containing the data of the variable 
                that is to be eliminated.
        
            varName --
                The name of the variable that is to be eliminated.
                
            dict --
                The OrderedDict that is used to store the data used 
                to eliminate variables from the optimization.
        """
        data = N.vstack([t, x])
        dict[varName] = data
    
    def set_beta(self, value):
        """
        Sets the value of the beta parameter that scales the arrival 
        cost part of the cost function. Defined for values between
        0 and 1.
        
        Parameters::
            value --
                New value of the beta parameter. Between 0 and 1.
        """
        if value > 1. or value < 0.:
            raise ValueError('Error: Value not between 0 and 1')
        else:
            self.op.set('_MHE_beta', value)
    
    def set_process_noise_covariance_matrix(self, process_noise_cov):
        """
        Sets the process noise covariance matrix according to a 
        new covariance list describing the process noise covariance 
        matrix in continuous time.
        
        Also makes sure that the process noise covariance matrix is 
        changed in the arrival cost object.
        
        Parameters::
            process_noise_cov --
                A list describing the covariance structure of the 
                continuous process noise. Items are on the form 
                (names, covariance_matrix). Names is a list, tuple or 
                string of the variable names which have a covariance 
                matrix given by covariance_matrix. If names is a list 
                or tuple of length 1 or a string the covariance_matrix 
                can be given as a float or a 1D or 2D numpy array. For 
                lists or tuple of length greater than 1 covariance_matrix 
                is given as a 2D numpy array. 
        """
        process_noise_cov = check.check_cov_list(self.op, 
                                                 process_noise_cov, 
                                                 'process_noise_cov')
        #Change the options object
        self.MHE_opts['process_noise_cov'] = process_noise_cov
        #Get the new Q-vars
        self._Q_vars = \
                  self._add_and_set_inverse_matrix(self._process_noise_names, 
                                                   process_noise_cov, 
                                                   '_MHE_Qinv')
        #Set the objective
        self._set_objectives()
        #Change the matrix in the EKF_object
        self.EKF_object.update_process_noise_covariance_matrix(
                                                       process_noise_cov)
        
    def set_measurement_noise_covariance_matrix(self, measurement_cov):
        """
        Sets the measurement covariance matrix according to a new 
        covariance list describing the measurement noise covariance 
        matrix in continuous time.
        
        Also makes sure that the measurement covariance matrix is 
        changed in the arrival cost object.
        
        Parameters::
            measurement_cov --
                A list describing the covariance structure of the 
                continuous measurement noise. Items are on the form 
                (names, covariance_matrix). Names is a list, tuple or 
                string of the variable names which have a covariance 
                matrix given by covariance_matrix. If names is a list 
                or tuple of length 1 or a string the covariance_matrix 
                can be given as a float or a 1D or 2D numpy array. For 
                lists or tuple of length greater than 1 covariance_matrix 
                is given as a 2D numpy array.
            """
        measurement_cov = check.check_cov_list(self.op, 
                                               measurement_cov, 
                                               'measurement_cov')
        #Change the options object
        self.MHE_opts['measurement_cov'] = measurement_cov
        #Get the new R-vars
        self._R_vars = \
                  self._add_and_set_inverse_matrix(self._measured_var_names, 
                                                   measurement_cov, 
                                                   '_MHE_Rinv')
        #Set the objective
        self._set_objectives()
        #Change the matrix in the EKF_object
        self.EKF_object.update_measurement_noise_covariance_matrix(
                                                            measurement_cov)
        
    def set_dirty(self):
        """
        Sets the dirty flag to True. This indicates that the 
        functions used in the linearization need to be recalculated.
        This needs to be done if one parameter or more in the DAEs 
        have been changed.
        """
        self._dirty = True
    
    def _add_real_parameter(self, name):
        """
        Adds a real parameter to the optimization problem object.
      
        Parameters::
            name --
                The name of the new parameter.
          
        Returns::
            par --
                The parameter variable
        """
        par = mc.RealVariable(self.op, MX.sym(name), 
                              mc.Variable.INTERNAL, 
                              mc.Variable.PARAMETER)
        self.op.addVariable(par)
        return par
        
    def _add_real_variable(self, name):
        """
        Adds a real variable to the optimization problem object.
      
        Parameters::
            name --
                The name of the new variable. Given as a string
          
        Returns::
            var --
                The added variable
        """
        var = mc.RealVariable(self.op, MX.sym(name), 
                              mc.Variable.INTERNAL, 
                              mc.Variable.CONTINUOUS)
        self.op.addVariable(var)
        return var
 
    def _add_timed_variable_start_time(self, original_var):
        """
        Adds a timed variable for the start time, if there does not 
        already exist one in which case that variable is returned.
        Assumes that the optimization object contains a parameter for 
        the start time named 'startTime'.
        Parameters: 
            original_var -- 
                The original variable
                
        Returns::
            timed_var --
                The timed variable at time startTime of the original_var.
        """
        name = original_var.getName() + '(startTime)'
        timed_vars = self.op.getTimedVariables()
        timed_var_names = [var.getName() for var in timed_vars]
        if name not in timed_var_names:
            time_var = (self.op.getVariable('startTime')).getVar()
            timed_var = mc.TimedVariable(self.op, MX.sym(name), 
                                         original_var, 
                                         time_var)
            self.op.addTimedVariable(timed_var)
        else:
            index = timed_var_names.index(name)
            timed_var = timed_vars[index]
        return timed_var
 
    def _add_real_input(self, name):
        """
        Adds a new real input to the optimization problem object.
      
        Parameters::
            name --
                The name of the new input. Given as a string
          
        Returns::
            input --
                The added input variable
        """
        input = mc.RealVariable(self.op, MX.sym(name), 
                                mc.Variable.INPUT, 
                                mc.Variable.CONTINUOUS)
        self.op.addVariable(input)
        return input
 
class MHEOptions(OptionBase):
    """
    Option class for using MHE. Extends the OptionBase class.
    
    MHE Options::
        input_names --
            A list of the input signals which are control signals, 
            i.e. does not include the names of inputs that are used 
            exclusively to insert process noise.
            Default: Empty list.
            
        process_noise_cov --
            A list describing the covariance structure of the 
            continuous process noise. Items are on the form 
            (names, covariance_matrix). Names is a list, tuple or 
            string of the variable names which have a covariance 
            matrix given by covariance_matrix. If names is a list 
            or tuple of length 1 or a string the covariance_matrix 
            can be given as a float or a 1D or 2D numpy array. For 
            lists or tuple of length greater than 1 covariance_matrix 
            is given as a 2D numpy array.
            Default: Empty list.
            
        measurement_cov --
            A list describing the covariance structure of the 
            continuous measurement noise. Items are on the form 
            (names, covariance_matrix). Names is a list, tuple or 
            string of the variable names which have a covariance 
            matrix given by covariance_matrix. If names is a list 
            or tuple of length 1 or a string the covariance_matrix 
            can be given as a float or a 1D or 2D numpy array. For 
            lists or tuple of length greater than 1 covariance_matrix 
            is given as a 2D numpy array.
            Default: Empty list.
            
        P0_cov --   
            A list describing the covariance structure of the 
            guess of the initial state values. Items are on the form 
            (names, covariance_matrix). Names is a list, tuple or 
            string of the variable names which have a covariance 
            matrix given by covariance_matrix. If names is a list 
            or tuple of length 1 or a string the covariance_matrix 
            can be given as a float or a 1D or 2D numpy array. For 
            lists or tuple of length greater than 1 covariance_matrix 
            is given as a 2D numpy array.
            Default: Empty list.
            
        IPOPT_options --
            IPOPT options for solution of NLP. See IPOPT's 
            documentation for available options.
            Default: Empty dictionary.
    """
    def __init__(self, *args, **kw):
        _defaults = {'input_names':[],
                     'process_noise_cov':[],
                     'measurement_cov':[],
                     'P0_cov':[],
                     'IPOPT_options':{}}
        super(MHEOptions, self).__init__(_defaults)
        self.update(*args, **kw)

