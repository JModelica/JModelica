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
"""
Module providing a method for generating the initial values of state 
derivatives and algebraic variables for the MHE object.
"""
from casadi import MX
import modelicacasadi_wrapper as mc
from collections import OrderedDict
import numpy as N
from pyjmi.optimization.casadi_collocation import ExternalData
import check_mhe_inputs as check

def optimize_for_initial_values(op, x_0_guess, u_0, MHE_opts):
    """
    Solves an optimization from time zero to time zero to generate 
    initial values for the state derivatives and the algebraic 
    variables.
    
    The input 'op' is mutated. Parameters for startTime and finalTime 
    are added if they do not already exist. The values for these 
    parameters are set to zero.
    
    Parameters::
        op --
            An OptimizationProblem object.
        
        x_0_guess --
            A dict containing a guess of the initial state 
            values. Items are on the form ('name', value).
            
        u_0 --
            A dictionary on the form 
            dict([('input1', u1),...,('inputN', uN)]), 
            where 'inputX' is the name of the input and uX is the 
            value of the input at time zero. N is the number of control 
            signals and X goes from 1 to N.
        
        MHE_opts --
            A MHEOptions object. See the documentation of the 
            options object for more details.
            
    Returns::
        dx_0 --
            The initial value of the derivative of the state 
            variables. Given as a list of tuples on the form 
            (varName, value).

        c_0 --
            The initial value of the algebraic variables. 
            Given as a list of tuples on the form 
            (varName, value)
    """
    (x_0_guess, u_0, process_noise_names, undefined_input_names, MHE_opts) = \
                                _check_inputs(op, x_0_guess, u_0, MHE_opts)
    input_names = MHE_opts['input_names']
    #Check if there are parameters for start and final time, add if not
    st_var = op.getVariable('startTime')
    if st_var == None:
        par = mc.RealVariable(op, MX.sym('startTime'), 
                              mc.Variable.INTERNAL, 
                              mc.Variable.PARAMETER)
        op.addVariable(par)
    ft_var = op.getVariable('finalTime')
    if ft_var == None:
        par = mc.RealVariable(op, MX.sym('finalTime'), 
                              mc.Variable.INTERNAL, 
                              mc.Variable.PARAMETER)
        op.addVariable(par)
    #Set the times
    op.setStartTime(MX(0.))
    op.set('startTime', 0.)
    op.setFinalTime(MX(0.))
    op.set('finalTime', 0.)
    ##Set the options for the optimization
    opts = op.optimize_options()
    #Specifies implicit Euler
    opts['n_cp'] = 1
    #Set one element between two points
    opts['n_e'] = 1
    
    #REMOVE MAYBE
    opts["IPOPT_options"]["print_level"] = 0
    
    external_data = _get_eliminated_data_object(u_0, 
                                                process_noise_names, 
                                                undefined_input_names, 
                                                input_names)
    opts['external_data'] = external_data
    
    #Find the names of the initial state value parameters
    initial_value_names = [par.getName() for par in \
                           op.getVariables(op.REAL_PARAMETER_INDEPENDENT) \
                           if par.getName().startswith('_start_')]
    #Remove the _start_ prefix
    state_names = [name[7:] for name in initial_value_names]
    #Substitute for non alias variables
    state_names = [op.getModelVariable(name).getName() for name in state_names]
    
    
    for k in range(len(initial_value_names)):
        iv_name = initial_value_names[k]
        state_name = state_names[k]
        op.set(iv_name, x_0_guess[state_name])   
    res = op.optimize(options=opts)
    (dx_0, c_0) = _extract_results(op, res, state_names)
    return (dx_0, c_0)
    
def _get_eliminated_data_object(u_0, process_noise_names, 
                                undefined_input_names, input_names):    
    """
    Creates a ExternalData object used to eliminate the input 
    signals from the optimization by providing values for them.
    
    Parameters::
        u_0 --
            A dictionary on the form 
            dict([('input1', u1),...,('inputN', uN)]), 
            where 'inputX' is the name of the input and uX is the 
            value of the input at time zero. N is the number of 
            control signals and X goes from 1 to N.
            
        process_noise_names --
            A list of names of all the process noise inputs.
            
        input_names --
            A list of names of all the input signals who are not 
            pure process noise inputs.
            
    Returns::
        external_data --
            A ExternalData object used to eliminate the inputs.
    """
    eliminated = OrderedDict()
    #Eliminate process noise and undefined inputs
    for name in process_noise_names + undefined_input_names:
        data = N.vstack([0., 0.])
        eliminated[name] = data
    #Eliminate inputs 
    for name in input_names:
        data = N.vstack([0., u_0[name]])
        eliminated[name] = data
    
    external_data = ExternalData(eliminated=eliminated)
    return external_data
    
def _extract_results(op, res, state_names):
    """
    Extracts the relevant results from the result object.
    
    Parameters::
        op --
            The OptimizationProblem object.
            
        res --
            The result object.
            
        state_names --
            A list of names of the states.
            
    Returns::
        dx_0 --
            The initial value of the derivative of the state 
            variables. Given as a list of tuples on the form 
            (varName, value).

        c_0 --
            The initial value of the algebraic variables. 
            Given as a list of tuples on the form 
            (varName, value)
    """ 
    alg_var_names = [var.getName() for var in \
                     op.getVariables(op.REAL_ALGEBRAIC) \
                     if not var.isAlias()]
    c_0 = [(name, res[name][0]) for name in alg_var_names]
    dx_names = ['der(' + name + ')' for name in state_names]
    dx_0 = [(name, res[name][0]) for name in dx_names]
    return (dx_0, c_0)
    
def _check_inputs(op, x_0_guess, u_0, MHE_opts):
    """
    Checks the inputs for any errors and replaces all aliases.
    Also creates a list of the undefined input names, i.e. the 
    inputs whose value was not specified by the user. 
    
    A copy of the options object is created meaning that the 
    original is not mutated.
    
    If any error is found in the inputs the process is stopped 
    and an error message is printed describing where the error was 
    made.
    
    Parameters::
        op --
            A OptimizationProblem object.
        
        x_0_guess --
            A dict containing a guess of the initial state 
            values. Items are on the form ('name', value).
            
        u_0 --
            A dictionary on the form 
            dict([('input1', u1),...,('inputN', uN)]), 
            where 'inputX' is the name of the input and uX is the 
            value of the input at time zero. N is the number of 
            control signals and X goes from 1 to N.
        
        MHE_opts --
            A MHEOptions object. See the documentation of the 
            options object for more details.
            
    Returns::
        x_0_guess --
            A dict containing a guess of the initial state 
            values. Items are on the form ('name', value).
            All aliases have now been replaced
            
        u_0 --
            A dictionary on the form 
            dict([('input1', u1),...,('inputN', uN)]), 
            where 'inputX' is the name of the input and uX is the 
            value of the input at time zero. N is the number of 
            control signals and X goes from 1 to N. All aliases have 
            been replaced.
        
        undefined_input_names --
            A list of input names whose value was not specified by 
            the user.
        
        MHE_opts --
            A MHEOptions object. See the documentation of the 
            options object for more details.
    """
    (process_noise_names, measured_var_names, undefined_input_names, opts) = \
                                        check.check_MHE_opts(op, MHE_opts)
    #Get the state names of the system
    state_names = [var.getName() for var in op.getVariables(op.DIFFERENTIATED)]
    
    x_0_guess_items = check.check_tuple_list(op, 
                                             x_0_guess.items(), 
                                             state_names, 
                                             'x_0_guess')
    x_0_guess = dict(x_0_guess_items)
    
    u_0_items = check.check_tuple_list(op, 
                                       u_0.items(), 
                                       opts['input_names'], 
                                       'u_0')
    u_0 = dict(u_0_items)
    return(x_0_guess, u_0, process_noise_names, undefined_input_names, opts)
    
    
    
    
    
    
    
    
    
    
    
    