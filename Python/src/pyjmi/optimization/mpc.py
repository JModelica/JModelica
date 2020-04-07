#!/usr/bin/env python
# -*- coding: utf-8 -*-

#    Copyright (C) 2015 Modelon AB, all rights reserved.
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
from pyjmi.common.io import ResultDymolaTextual
from pyjmi.jmi_algorithm_drivers import MPCAlgResult, LocalDAECollocationAlg, LocalDAECollocationAlgOptions
from pyjmi.optimization.casadi_collocation import BlockingFactors
import time, types
import numpy as N
import modelicacasadi_wrapper as ci
import casadi
from pyjmi.common.io import VariableNotFoundError as jmiVariableNotFoundError

#Check to see if pyfmi is installed so that we also catch the error generated
#from that package
from pymodelica.common.io import VariableNotFoundError as \
     pymodelicaVariableNotFoundError
try:
    from pyfmi.common.io import VariableNotFoundError as \
         fmiVariableNotFoundError
    VariableNotFoundError = (
        jmiVariableNotFoundError, pymodelicaVariableNotFoundError,
        fmiVariableNotFoundError)
except ImportError:
    VariableNotFoundError = (jmiVariableNotFoundError,
                             pymodelicaVariableNotFoundError)


class MPC(object):

    """
    Creates an MPC-object which allows a dynamic optimization problem to be 
    updated with estimates of the states (through measurements).  
    """

    def __init__(self, op, options, sample_period, horizon, 
                 initial_guess='shift', create_comp_result=True,
                 constr_viol_costs={}, warm_start_options={},
                 noise_seed=None):
        """
        Creates the NLP that corresponds to the op we want to solve with MPC.

        Parameters::

            op --
                The optimization problem we want to solve.

            options --
                The collocation options we want to use while solving.

            sample_period --
                The sample period i.e. the time between each optimization.

            horizon --
                The number of samples on the horizon. This is used to define
                the horizon_time. 
        
            initial_guess --
                Specifies which method to use to calculate the next initial 
                guess for the primal variables.
                'shift': Use the shift method to shift the NLP result vector 
                from the last successful optimization one collocation element.  
                'trajectory': Extract xx_init from the result reajectories of
                the last successful optimization.
                optimization.
                from a result file.
                'prev': Use the NLP result vector from the last successful 
                optimization as it is.
                Default: 'shift'
         
            create_comp_result --
                True: Save the result for the first sample of each optimization
                to create a patched together resultfile.
                False: Do not create the patched together result file.
                Default: True
            
            constr_viol_costs --
                The constraint violation costs to use when automatically 
                softening variable bounds.
                Default: {}
                
            warm_start_options --
                A dictionary with the solver options to use once the warm start
                has been initialized. The warm start is initiated in between 
                the first and the second samples.
                Default = {} 
                
            noise_seed --
                The seed to use for adding noise when using the method
                extract_states().
                Default: None
        """
        self._create_clock()
        self.op = op
        
        # handle options argument
        if isinstance(options, dict):
            # user has passed dict with options or empty dict = default
            self.options = LocalDAECollocationAlgOptions(options)
        elif isinstance(options, LocalDAECollocationAlgOptions):
            # user has passed LocalDAECollocationAlgOptions instance
            self.options = options
        else:
            raise InvalidAlgorithmOptionException(options)

        self.sample_period = sample_period
        self.horizon = horizon
        self.constr_viol_costs = constr_viol_costs
        self.initial_guess = initial_guess
        self.create_comp_result = create_comp_result
        self.warm_start_options = warm_start_options
        
        # Create complete result lists
        if self.create_comp_result:
            self.res= {}
            self.res['t'] = []
            self.res['dx'] = []
            self.res['x'] = []
            self.res['u'] = []
            self.res['w'] = []
            self.res['elim_vars'] = []

			
        # Create array to storage eliminated variables
        self.eliminated_variables = op.getEliminatedVariables()
           
        # Create lists for some solver statistics
        self.tot_times = []
        self.solver_stats = []
        
        # Define some things
        self._sample_nbr = 0
        self._mpc_result_file_name = op.getIdentifier()+'_mpc_result.txt'
        self.result_file_name = op.getIdentifier()
        self._init_traj_set_by_user = False

        self.startTime= self.op.get('startTime')
        if noise_seed:
            N.random.seed([noise_seed])
            
        # Check if sample_points coincide with meshpoints
        if self.options['n_e']%self.horizon != 0:
            raise ValueError("Choose 'n_e' as an integer times 'horizon'.")
        else:
            self.n_e_s = self.options['n_e']/self.horizon
        
        # Check if nominal trajectories provided
        if self.options['nominal_traj'] != None:
            print('Warning: Nominal trajectories will not work as intended '+\
                 'with the MPC class. The trajectories will not shift with '+\
                 'the shifting optimization horizon.') 
        
        # Check if external data provided
        if self.options['external_data'] != None:
            print('Warning: Using external_data to provide reference '+\
                 'trajectories will not work as intended with the MPC class.'+\
                 'The trajectories do not shift with the shifting '+\
                 'optimization horizon.') 
                 
        # Soften variable bounds and add u0-parameters for blockingfactors 
        self.extra_param = []
        self.original_model_inputs = self.op.getVariables(self.op.REAL_INPUT)
        if self.constr_viol_costs != {}:
            self._soften_constraints()
        self._add_u0()
            
        # Transcribe the DOP to a nlp
        self._create_nlp_object()

        self.collocator.result_file_name= self.result_file_name
        
        if self.options['solver'] == 'IPOPT':
            self.successful_optimization = ['Solve_Succeeded', 
                                            'Solved_To_Acceptable_Level']
            
        if self.options['solver'] == 'WORHP':
            self.successful_optimization = ['OptimalSolution', 
                                            'LowPassFilterOptimal', 
                                            'AcceptableSolution']
             
        # Save the initialization time
        self.times['init'] = time.clock() - self._startTime

    def _create_clock(self):
        """
        Creates a dictionary where times for different operations are stored.
        """
        self._startTime = time.clock()
        self.times = {}
        self.times['init'] = 0
        self.times['update'] = 0
        self.times['sol'] = 0
        self.times['post_processing'] = 0
        self.times['tot'] = 0
        self.times['maxTime'] = 0

    def _add_u0(self):
        """
        Adds neccessary variables to make blocking factors (du_quad_pen and 
        du_bounds) valid first sample.
        """
        bf = self.options['blocking_factors']
        if bf is not None:
            for key in bf.du_quad_pen.keys():
                var_par = casadi.MX.sym("%s_0" %key)
                var =  ci.RealVariable(self.op, var_par, 2, 1) 
                self.op.addVariable(var)
                self.op.set("%s_0" %key, 0)
                self.extra_param.append("%s_0" %key)
                
                # Find or create new timed variable
                var_startTime = self._getTimedVariable(key)
                
                if var_startTime is None:
                    var_startTime = casadi.MX.sym("%s(startTime)" %key)
                    st = self.op.getVariable('startTime').getVar()
                    variable = self.op.getVariable(key)
                    timedVar_startTime = ci.TimedVariable(self.op, 
                                                   var_startTime, variable, st)
                    self.op.addTimedVariable(timedVar_startTime)
                
                # Create new variable 
                du_quad_pen_par= casadi.MX.sym("%s_du_quad_pen" %key)
                du_quad_pen = ci.RealVariable(self.op, du_quad_pen_par, 2, 1)
                self.op.addVariable(du_quad_pen)
                self.op.set("%s_du_quad_pen" %key, 0)
                self.extra_param.append("%s_du_quad_pen" %key)
                
                extra_obj = du_quad_pen_par*(var_startTime-var_par)*\
                                                        (var_startTime-var_par)
                self.op.setObjective(self.op.getObjective() + extra_obj)
            

            # Save all pointconstraints
            pc = []
            for constr in self.op.getPointConstraints():
                pc.append(constr)

            for key in bf.du_bounds.keys():
                # Find or create new _0 parameter
                var_par = self.op.getVariable("%s_0" %key)
                if var_par is None:
                    var_par = casadi.MX.sym("%s_0" %key)
                    var =  ci.RealVariable(self.op, var_par, 2, 1) 
                    self.op.addVariable(var)
                    self.op.set("%s_0" %key, 0)
                    self.extra_param.append("%s_0" %key)
                else:
                    var_par = var_par.getVar()
                
                # Find or create new timed variable
                var_startTime = self._getTimedVariable(key)
                
                if var_startTime is None:
                    var_startTime = casadi.MX.sym("%s(startTime)" %key)
                    st = self.op.getVariable('startTime').getVar()
                    variable = self.op.getVariable(key)
                    timedVar_startTime = ci.TimedVariable(self.op, 
                                                   var_startTime, variable, st)
                    self.op.addTimedVariable(timedVar_startTime)
                
                # Create new parameter for pointconstraint bound
                du_bounds_par= casadi.MX.sym("%s_du_bounds" %key)
                du_bounds = ci.RealVariable(self.op, du_bounds_par, 2, 1)
                self.op.addVariable(du_bounds)
                self.op.set("%s_du_bounds" %key, 1e10) 
                self.extra_param.append("%s_du_bounds" %key)

                # Create new pointconstraints
                bf_constr = var_startTime - var_par
                poc1 = ci.Constraint(bf_constr, du_bounds_par, 1)
                poc2 = ci.Constraint(bf_constr, -du_bounds_par, 2)
                    
                # Append new pointconstraints to list    
                pc.append(poc1)
                pc.append(poc2)
                
            # Set new pointconstraints
            self.op.setPointConstraints(pc)

    def _getTimedVariable(self, name):
        """
        Returns the startTime timed variable for variable name if there is one,
        otherwise returns None.
        
        Parameters::

            name --
                The name of the variable whose startTime timed variable we're
                looking for.
        """
        tv = self.op.getTimedVariables()
        for var in tv:
            if var.getBaseVariable() == self.op.getVariable(name):
                if var.getTimePoint() ==\
                                    self.op.getVariable('startTime').getVar():
                    return var.getVar()
        return None

    def _soften_constraints(self):
        """
        Changes hard variable bounds to soft constraints for all variables for
        which the user provided a constraint violation cost when creating the
        MPC object.
        
        The softened constraint is accieved by adding a cost to the objective
        integrand corresponding to the constraint violation cost * the 1-norm 
        for each variable. 
         
        """
        # Save pathconstraints
        path_constr = []
        for constr in self.op.getPathConstraints():
            path_constr.append(constr)

        # Change bounds on variables to soft constraints 
        for name in self.constr_viol_costs.keys():
            var = self.op.getVariable(name)

            # Create slack variable
            slack_var= casadi.MX.sym("%s_slack" %name)
            slack = ci.RealVariable(self.op, slack_var, 0, 3) 
            slack.setMin(0)
            nominal = var.getNominal()

            # Check if nominal value is symbolic and find the value
            if nominal.isSymbolic():
                nominal = self.op.get(nominal.getName())
            else:
                nominal = nominal.getValue()

            if nominal == 0:
                print("Warning: Nominal value of base variable is 0. Setting \
                                nominal for slack variable to 1.")
                slack.setNominal(1) 
            else:
                slack.setNominal(0.0001*N.abs(nominal))

            self.op.addVariable(slack)

            # Add to Objective Integrand 
            oi = self.op.getObjectiveIntegrand()
            self.op.setObjectiveIntegrand(oi+\
                                        self.constr_viol_costs[name]*slack_var)

            # Obtain the bounds 
            var_min = self.op.get_attr(var, "min")
            var_max = self.op.get_attr(var, "max")

            # Add constraints and change bounds
            if var_min != -N.inf:
                var.setMin(-N.inf)
                pac_rh = var_min - slack_var
                pac_soft = ci.Constraint(var.getVar(), pac_rh, 2)
                path_constr.append(pac_soft) 
            if var_max != N.inf:
                var.setMax(N.inf)
                pac_rh = var_max + slack_var
                pac_soft = ci.Constraint(var.getVar(), pac_rh, 1)
                path_constr.append(pac_soft) 

        self.op.setPathConstraints(path_constr)   

    def _create_nlp_object(self):
        """
        Transcribes the DOP into a NLP. Grants access to an instance of 
        LocalDAECollocator: op.collocator        
        """
        self._set_blocking_options()
        self._set_horizon_time()
        self._calculate_nbr_values_sample()
        self.alg = LocalDAECollocationAlg(self.op, self.options)
        self.collocator = self.alg.nlp
        self.p_fixed = None
        self._get_states_and_initial_condition_parameters()
        self.collocator.solver_object.init()

    def _set_blocking_options(self):
        """
        Creates blocking factors for the input. Default blocking factors are:
        Constant input through each sample.
        """
        bf = self.options['blocking_factors']
        if  bf is None:
            n_e = self.options['n_e']
            bf_value = self.n_e_s
            bl_list = [bf_value]*(n_e/self.n_e_s)
            factors = {}
            print("Default blocking factors have been applied to all inputs.")
            for inp in self.original_model_inputs:  
                factors[inp.getName()] = bl_list
            bf = BlockingFactors(factors = factors)
            self.options['blocking_factors'] = bf

    def _set_horizon_time(self):
        """
        Checks that the first sample period coincides with a mesh point.
        """
        hs = self.options['hs']
         # Check option 'hs'
        if self.options['hs'] is not None:
            if self.options['hs'] == "free":
                raise NotImplementedError("The MPC-class does not support"+\
                                            " free element lengths.")
            else:
                bf = self.options['blocking_factors'].factors.values()[0]
                if bf[0] != self.n_e_s:
                    raise ValueError("The first value in the blocking factor"+\
                                     " vector does not equal the number of"+\
                                     " collocation elements per sample chosen.")
                self.horizon_time = self.sample_period/sum(hs[0:self.n_e_s])
        else:
            self.horizon_time = self.sample_period*self.horizon
            
        # Check if horizon_time equals finalTime
        if N.abs(self.op.get('finalTime')-self.op.get('startTime')-\
                                                self.horizon_time) > 1e-6:
			self.op.set('finalTime',self.op.get('startTime')+self.horizon_time)
            #print("Warning: The final time has been changed to %s" % op.get('finalTime'))
        print("The prediction horizon is %s" % self.horizon_time)

    def _calculate_nbr_values_sample(self):
        """
        Calculates number of values per sample.
        """

        if self.options['result_mode'] == 'collocation_points':
            self._nbr_values_sample = self.n_e_s*\
                self.options['n_cp']+1
        elif self.options['result_mode'] == 'mesh_points':
            self._nbr_values_sample = self.n_e_s+1
        else: 
            self._nbr_values_sample = self.n_e_s*\
                                        self.options['n_eval_points']

    def _get_states_and_initial_condition_parameters(self):
        """
        Saves the indices in the collocators _par_vals vector for the initial 
        condition parameters + start and final times.
        """

        # Retrieve the names of all the states 
        self.state_names = self.op.get_state_names()

        # Find and save the indices for each states initial condition parameter
        # + startTime and finalTime. 
        self.index = {}    
        for name in self.state_names:
            name_init = "_start_"+name
            (self.index[name_init], _) = self.collocator.name_map[name_init]

        for par in ['startTime', 'finalTime']:
            (self.index[par], _) = self.collocator.name_map[par]
                
        # Find and save the index for blocking factor parameters
        for par in self.extra_param:
            (self.index[par], _) = self.collocator.name_map[par]
        
    def _set_warm_start_options(self):
        """
        Sets the warm start options for the NLP solver. 
        
        Default warm start options for IPOPT are:
            'warm_start_init_point' = 'yes'
            'mu_init' = 1e-3
            'print_level' = 0
        Default warm start options for WORHP are:
            'InitialLMest' = False
            'NLPprint' = 0
        """  
        
        if self.options['solver'] == 'IPOPT':
            if self.options['IPOPT_options'].get('warm_start_init_point')\
                                                                    is None:
                self.collocator.solver_object.\
                                    setOption('warm_start_init_point', 'yes')
            if self.options['IPOPT_options'].get('mu_init') is None:
                self.collocator.solver_object.setOption('mu_init', 1e-3)
            if self.options['IPOPT_options'].get('print_level') is None:
                self.collocator.solver_object.setOption('print_level', 0)
                                                    
            for key in self.warm_start_options.keys():
                self.collocator.solver_object.setOption(key,\
                                                self.warm_start_options[key])

            self.collocator.solver_object.setOption('expand', False)
             
        elif self.options['solver'] == 'WORHP':
            self.collocator.solver_object.setOption('NLPprint', 0)
            self.collocator.solver_object.setOption('InitialLMest', False)
            
            for key in self.warm_start_options.keys():
                self.collocator.solver_object.setOption(key,\
                                                self.warm_start_options[key])

    def _append_to_result_file(self, sim_res):
        """
        Extracts the results in sim_res and appends it to the result lists.
        """
        var_type = ['dx', 'x', 'u', 'w']
        n_values = len(sim_res['time'])
        
        for k in range(n_values):
            self.res['t'].append(sim_res['time'][k])
        for k in range(n_values):
            for n in var_type:   
                n_var_type = self.collocator.n_var[n]
                
                if n_var_type == 0:
                    self.res[n].append([])
                    
                for i in range(n_var_type):
                    try:
                        res_var = sim_res[self.collocator.mvar_vectors[n][i].\
                                          getName()]
                    except VariableNotFoundError:
                        res_var = N.array([0]*n_values)
                    self.res[n].append(res_var[k])
                    
        elims = N.zeros(len(self.eliminated_variables))
        for k in range(n_values):
            for i,var in enumerate (self.eliminated_variables):
                elims[i] = sim_res[var.getName()][k]
			
            self.res['elim_vars'].append(elims)
       
    def _add_times(self):
        """
        Adds each samples times to the total times. Also keeps track of the 
        largest total time for one sample. 
        """
        sol_time = self.sol_time
        update_time = self.update_time 

        self.times['update'] += update_time
        self.times['sol'] += sol_time

        time_post = time.clock() - self.post_time
        self.time_tot = update_time + sol_time + time_post

        if  self.time_tot > self.times['maxTime']:
            self.times['maxTime'] = self.time_tot
            self.times['maxSample'] = self._sample_nbr

        self.times['tot'] += self.time_tot
        self.times['post_processing'] += time_post
        self.tot_times.append(self.time_tot)

    def _get_opt_input(self):
        """
        Returns the optimal inputs for the current sample_period.
        """
        names = []
        inputs =[]
        self._opt_input = {}

        for i, inp in enumerate(self.original_model_inputs):
            names.append(inp.getName())
            
            inputs.append(self.result[3][(self._nbr_values_sample-1)*\
                                            self.consec_fails+1][i])
            self._opt_input[inp.getName()] = self.result[3]\
                                            [(self._nbr_values_sample-1)*\
                                            self.consec_fails+1][i]

        def input_function(t):
            return N.array(inputs)

        return (names,input_function)

    def _extract_estimates_prev_opt(self):   
        """
        Returns an estimated value of the states, based on the result
        of the previous optimization. 
        """
        if self._sample_nbr == 1:
            return {};
        mean = 0
        st_dev = 0.005
        measurements = {} 
        if self._sample_nbr == 1:
            return measurements
        else:
            for name in self.state_names:
                name_init = "_start_"+name
                measurements[name_init] = self._result_object[name]\
                                    [self._nbr_values_sample-1]
                val = N.abs(measurements[name_init])
                if val != 0:
                    measurements[name_init] += N.random.normal(mean,\
                                                                st_dev*val, 1)
                    measurements[name_init] = measurements[name_init][0]
        return measurements

    def _shift_xx(self):
        """
        Shifts the result from the previous optimation and gives it as initial 
        guess for the next optimation.
        """

        xx_result = {}
        # If last optimization was successful, shift the result.
        # Otherwise shift the last successful result.
        if self.found_solution: 
            xx_result = self.collocator.primal_opt
        else:
            xx_result = self.shifted_xx
            
        #~ xx_result = self.collocator.named_xx  #Used for debugging 

        # Map with splited order
        split_map = dict()
        split_map['x'] = 0
        split_map['dx'] = 1
        split_map['w'] = 2
        split_map['unelim_u'] = 3     
        split_map['init_final'] = 4
        split_map['p_opt'] = 5

        # Fetch split indices and collocation options
        gsi = self.collocator.global_split_indices
        n_e = self.options['n_e']
        n_cp = self.options['n_cp']
        n_e_s= self.n_e_s
        # Create map for the shifted results
        shifted_xx = xx_result[0:0]

        is_x = 1

        # Shift x, dx and w
        
        for vk in ['x', 'dx', 'w']:
            start=gsi[split_map[vk]]
            end = gsi[split_map[vk]+1]

            n_var = self.collocator.n_var[vk]

            new_xx = xx_result[start+n_var*n_e_s*(n_cp+is_x):end]
            new_xx_extrapolate = xx_result[end-n_var:end]
            shifted_xx = N.concatenate((shifted_xx, new_xx))
            
            for i in range((n_cp+is_x)*n_e_s):
                shifted_xx = N.concatenate((shifted_xx, new_xx_extrapolate))
            is_x = 0

        # Shift inputs without blocking factors
        u_cont_names = [ var.getName() for var in 
                        self.collocator.mvar_vectors['unelim_u'] 
                        if var.getName() not in 
                        self.options['blocking_factors'].factors.keys()]
                    
        n_cont_u = len(u_cont_names) 
        start_cont_u=gsi[split_map['unelim_u']]
        end_cont_u = start_cont_u + n_cont_u*n_cp*n_e

        new_xx = xx_result[start_cont_u+n_cont_u*n_cp*n_e_s:end_cont_u]
        new_xx_extrapolate = xx_result[end_cont_u-n_cont_u:end_cont_u]
        shifted_xx = N.concatenate((shifted_xx, new_xx))

        for i in range(n_cp*n_e_s):
            shifted_xx = N.concatenate((shifted_xx, new_xx_extrapolate))

        # Shift inputs with blocking factors 
        n_bf_u = self.collocator.n_var['unelim_u'] - n_cont_u
        start_bf_u = end_cont_u

        for name in self.options['blocking_factors'].factors.keys():
            factors = self.options['blocking_factors'].factors[name]

            end_bf_u = start_bf_u + len(factors)

            new_xx = xx_result[start_bf_u+n_bf_u:end_bf_u]
            new_xx_extrapolate = xx_result[end_bf_u-n_bf_u:end_bf_u]
            
            shifted_xx = N.concatenate((shifted_xx, new_xx))
            shifted_xx = N.concatenate((shifted_xx, new_xx_extrapolate))
            start_bf_u = end_bf_u

        # Shift initial controls (without blocking factors)
        start_init_u = gsi[split_map['unelim_u']] + (n_cp*n_e_s-1)*n_cont_u
        end_init_u = start_init_u + n_cont_u

        new_xx = xx_result[start_init_u:end_init_u]
        shifted_xx = N.concatenate((shifted_xx, new_xx))

        # Shift initial dx, w
        for vk in ['dx', 'w']:
            n_var = self.collocator.n_var[vk]

            start=gsi[split_map[vk]] + (n_cp*n_e_s-1)*n_var
            end = start+n_var

            new_xx = xx_result[start:end]
            shifted_xx = N.concatenate((shifted_xx, new_xx))

        # Add p_opt
        start_p = gsi[split_map['p_opt']]
        end_p = gsi[split_map['p_opt']+1]
        
        new_xx = xx_result[start_p:end_p]
        shifted_xx = N.concatenate((shifted_xx, new_xx))
        
        # Save the shifted result in the collocator and locally
        self.collocator.xx_init = shifted_xx
        self.shifted_xx = shifted_xx
        
    def _recalculate_parameters(self):
        """
        Method that extracts and sets the parameter values from op.
        """
        par_vals = self.collocator._recalculate_model_parameters()
        if self.p_fixed is None:
            self.p_fixed = par_vals

    def update_state(self, x_k=None, start_time=None):
        """ 
        Updates the initial condition parameters for the next optimization 
        to the values in x_k. 
        Moves the start time  of the optimization one sample_period forward, 
        or to the value specified by start_time.

        Parameters::

            x_k --
                Either a dictionary containing the new values of the initial 
                condition parameters or None.
                If None values of the initial condition parameters will be 
                extracted automatically from the previous optimization result.
                Default: None 
            
            start_time --
                A float defining the start time of the next optimization. 
                If None the start time of the next optimization will be 
                calculated as the start time of the last optimization + 
                the sample period.
                Defaul: None
        """  
        # Update times and sample number
        self._t0 = time.clock()
        self._sample_nbr+=1

        # Check the type of sim_res and do accordingly
        if isinstance(x_k, dict):
            state_dict = x_k
        elif x_k == None:
            state_dict = self._extract_estimates_prev_opt()
        else:
            raise ValueError("x_k must be a dictionary or None.")

        # Updates states
        for key in state_dict.keys():
            if not self.index.has_key(key):
                raise ValueError("You are not allowed to change %s using this\
                                method. Use MPC.set()-method instead." %key)
            else:
                self.op.set(key, state_dict[key])

        # Define new startTime
        if start_time == None:
            if self._sample_nbr > 1:
                self.startTime += self.sample_period
        else:
            self.startTime = start_time
                
        # Update times and parameter values
        self.op.set('startTime', self.startTime)
        self.op.set('finalTime', self.startTime+self.horizon_time)

        self.collocator.t0 = self.startTime
        self.collocator.tf = self.startTime+self.horizon_time
        
        if self._sample_nbr > 1:
            for key in [var for var in self.extra_param if var.endswith('_0')]:
                self.op.set(key, self._opt_input[key.split('_0')[0]]) 
                
            # Update blocking_factor parameters
            if self._sample_nbr == 2:
                # Change w from blocking factors
                for key in [var for var in self.extra_param if 
                                                var.endswith('_du_quad_pen')]:
                    self.op.set(key, self.options['blocking_factors'].\
                                            du_quad_pen[key.split\
                                            ('_du_quad_pen')[0]])
            
                for key in [var for var in self.extra_param if \
                                                var.endswith('_du_bounds')]:
                    self.op.set(key, self.options['blocking_factors'].\
                                            du_bounds[key.split\
                                            ('_du_bounds')[0]])
                
    def sample(self):
        """
        Updates parameter values, shifts the optimization horizon, 
        redefines the initial guess of the primal variables (for all but the 
        first sample) and solves the NLP. 
        Warm start is initiated the second time sample is called.  
        """
        # Update parameter values
        self._recalculate_parameters()
        
        # Update timepoints
        if self.startTime != self.collocator.time[0]:
            coll_time = self.collocator.time+(self.startTime-self.collocator.time[0])
            self.collocator.time = coll_time
            
            
        # Set the next initial guesses for primal variables
        if self._init_traj_set_by_user:
                self._set_inittraj()
        else: 
            if self._sample_nbr > 1:
                if self.initial_guess == 'shift':
                    self._shift_xx()
                elif self.initial_guess == 'trajectory':
                    self._init_traj = self._result_object
                    self._set_inittraj()
                elif self.initial_guess == 'prev':
                    if self.status in self.successful_optimization: 
                        self.collocator.xx_init = self.collocator.primal_opt
                else:
                    print("Warning: A new initial guess for the primal " +\
                          "variables have not been specified for this sample.") 
       
        # Initiate the warm start 
        if self._sample_nbr == 2:            
            self.collocator.warm_start = True
            self._set_warm_start_options()
            self.collocator.solver_object.init()
            self.collocator._init_and_set_solver_inputs()
                    

        # Solve the NLP
        self.sol_time = self.collocator.solve_nlp()
        self.update_time = time.clock() - self._t0 - self.sol_time
        self.post_time = time.clock()

        # Check return status and if optimization was successful
        self.status = self.collocator.solver_object.getStat('return_status')
        if self.status in self.successful_optimization:
            self.found_solution = True
        else:
            self.found_solution = False
        
        if self.found_solution: 
            self.result = self.collocator.get_result()
            self.consec_fails = 0
            if self.initial_guess == 'trajectory':
                self.collocator.export_result_dymola(self.result_file_name)
                self.collocator.times['init'] = self.update_time
                self.collocator.times['sol'] = self.sol_time
                self.collocator.times['post_processing']= time.clock()-self.post_time 
                self._result_object = self.collocator.get_result_object()
        else:
            if self._sample_nbr == 1:
                raise RuntimeError("The solver was unable to find a "+\
                                "feasible solution.")
            self.consec_fails += 1
            if self.consec_fails >= self.options['n_e']:
                raise RuntimeError("The solver has not found a feasible " +\
                                    "solution for the last %s samples" 
                                    %self.consec_fails)
                #THROW SOMETHING CAUSE THIS AINT WORKING!
        
        self.t0_post = time.clock()
        self.solver_stats.append(self.collocator.get_solver_statistics())

        self._init_traj_set_by_user = False
        self._add_times()
        return self._get_opt_input()

    def extract_states(self, sim_res, mean=0, st_dev=0.000):
        """
		Extracts the last value of the states from a simulation result object 
        and adds a noise with mean and variance as defined. 
        If 'create_comp_result' is True the method also saves and concatenates 
        all sim_res to create a complete MPC simulation result file.

        Parameters::

            sim_res --
                The simulation result object from which the states are to be 
                extracted. If 'create_comp_result' is True, sim_res will be 
                added to the complete result. 

            mean --
                Mean value of the noise.
                Default: 0

            st_dev --
                Factor to be multiplied with the current value of each state to
                define the stanard deviation of the noise.
                Default: 0.000
		"""
        if self.create_comp_result:
            self._append_to_result_file(sim_res)
        states = {}
        for name in self.state_names:
            states["_start_"+name] = sim_res[name][-1]
            val = N.abs(states["_start_"+name])
            if st_dev == 0 or val == 0:
                random = N.array([0]) 
            else: 
                random = N.random.normal(mean, st_dev*val, 1)
            states["_start_"+name] += random
            states["_start_"+name] = states["_start_"+name][0]
        return states
        

    def get_results_this_sample(self):
        """
        Returns the results for the last optimization.
        (a LocalDAECollocationAlgResult-object). 
        """
        if self.initial_guess != 'trajectory':
             self.collocator.export_result_dymola(self.result_file_name)
             self.collocator.times['init'] = self.update_time
             self.collocator.times['sol'] = self.sol_time
             self.collocator.times['post_processing']= time.clock()-self.post_time 
             self._result_object = self.collocator.get_result_object()
             
        return self._result_object
        
    def get_complete_results(self):
        """
        Creates and returns the patched together resultfile from all 
        optimizations.
        """
        # Check if complete results have been saved
        if self.create_comp_result is False:
            raise  ValueError("'get_complete_results()' only works if" +\
                                "'create_comp_result' is True.")
        
        # Convert the complete restults lists to arrays
        self.res_t = N.array(self.res['t']).reshape([-1, 1])
        self.res_dx = N.array(self.res['dx']).reshape\
                                            ([-1, self.collocator.n_var['dx']])
        self.res_x = N.array(self.res['x']).reshape\
                                            ([-1, self.collocator.n_var['x']])
        self.res_u = N.array(self.res['u']).reshape\
                                            ([-1, self.collocator.n_var['u']])
        if self.collocator.n_var['w'] >= 1:
            self.res_w = N.array(self.res['w']).reshape\
                                            ([-1, self.collocator.n_var['w']])
        else:
            self.res_w = N.array(self.res['w'])
        res_p = N.array(0).reshape(-1)
        
        if len(self.eliminated_variables) == 0:
            self.res_elim_vars = N.ones([len(self.res['t']),0])	
        else:
            self.res_elim_vars = N.array(self.res['elim_vars']).reshape\
                                            ([-1, len(self.eliminated_variables)])                        
        res_p = N.array(0).reshape(-1)
        
        res = (self.res_t, self.res_dx, self.res_x, self.res_u, 
                        self.res_w, self.p_fixed, res_p, self.res_elim_vars) 

        self.collocator.export_result_dymola(self._mpc_result_file_name, 
                                                result=res)

        complete_res = ResultDymolaTextual(self._mpc_result_file_name)

        # Create and return result object
        self._result_object_complete = MPCAlgResult(self.op, 
                                self._mpc_result_file_name, self.collocator,
                                complete_res, self.options,
                                self.times, self._sample_nbr,
                                self.sample_period)
        
        return self._result_object_complete
        
    def set_inittraj(self, sim_result): 
        """ 
        Defines the initial guess to use for the next optimization.
        
        Parameters::
            
            sim_result --
                The result file from which the initial guess is to be
                extracted.
        """
        self._init_traj = sim_result
        self._init_traj_set_by_user = True
        
    def _set_inittraj(self): 
        """ 
        Internal method to define the initial guess for the next optimization.
        
        """

        self.collocator.init_traj = self._init_traj
        try:
            self.collocator.init_traj = self.collocator.init_traj.result_data
        except AttributeError:
            pass

        self.collocator._create_initial_trajectories()        
        self.collocator._compute_bounds_and_init()

    def set(self, name, value): 
        """ 
        Sets the specified parameters in names to the value in values. 
 	         
 	        Parameters:: 
	 	             
 	            names -- 
 	                List of parameter names whose values are to be changed.  
 	                 
 	                Type: [string] or string  
 	                 
 	            values -- 
 	                Corresponding new values for the parameters. 
 	                 
 	                Type: [float] or float 
        """ 
        self.op.set(name, value)
    
    def get(self, name):
        """
        Returns the value of the specified parameter.
        
        Parameters::

            name --
            The name of the parameter whose value is to be returned.
        """
        index = self.collocator.var_indices[name]
        return self.collocator._par_vals[index]
        
    def print_solver_stats(self):
        """ 
        Prints the return status, number of iterations and solution time 
        for each optimization.
        """
        for i, stat in enumerate(self.solver_stats): 
            print("%s: %s: %s iterations in %s seconds" %(i+1, stat[0], \
                                                stat[1], stat[3]))
    def get_solver_stats(self):
        """ 
        Returns the return status and number of iterations for each for each 
        optimization.
        """
        return (self.solver_stats, self.tot_times)
