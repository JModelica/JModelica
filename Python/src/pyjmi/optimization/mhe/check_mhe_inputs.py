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
Module containing methods for checking the inputs to the 
MHE-related functions and reporting eventual errors found in 
them.
"""

def check_MHE_opts(op, MHE_opts):
    """
    Checks if a MHEOptions object contains any errors or alias 
    variables. Replaces alias variables and returns a copied 
    MHEOptions object with all the aliases replaced. Also 
    returns lists of names of the process noise sources, 
    the measured variables and the inputs not defined by the user.
    
    Parameters::
        op --
            An OptimizationProblem object.
            
        MHE_opts --
            A MHEOptions object. See the documentation of the 
            options object for more details.
            
    Returns::
        process_noise_names --
            A list of all the names of the variables affected by 
            process noise.
        
        measured_var_names --
            A list of the names of the measured variables.
        
        undefined_input_names -- 
            A list of the names of the inputs that were not defined 
            by the user.
        
        opts --
            A new MHEOptions object where the aliases have been 
            replaced.
    """
    all_input_names = [var.getName() for var in \
                       op.getVariables(op.REAL_INPUT) \
                       if not var.isAlias()]
    opts = MHE_opts.copy()
    #Replace aliases in process_noise_cov
    (pn_new_cov_list, process_noise_names, pn_not_in_model) = \
            _replace_aliases_in_cov_list(op, MHE_opts['process_noise_cov'])
    opts['process_noise_cov'] = pn_new_cov_list
    
    #Replace aliases in measurement_cov
    (meas_new_cov_list, measured_var_names, meas_not_in_model) = \
            _replace_aliases_in_cov_list(op, MHE_opts['measurement_cov'])
    opts['measurement_cov'] = meas_new_cov_list
    
    #Replace aliases in P0_cov
    (P0_new_cov_list, P0_names, P0_not_in_model) = \
            _replace_aliases_in_cov_list(op, MHE_opts['P0_cov'])
    opts['P0_cov'] = P0_new_cov_list
    
    #Replace the aliases in input names and check for errors
    new_input_names= []
    input_not_in_model = []
    for name in MHE_opts['input_names']:
        var = op.getVariable(name)
        if var == None:
            input_not_in_model.append(name)
        elif var.isAlias():
            new_name = var.getModelVariable().getName()
            new_input_names.append(new_name)
        else:
            new_input_names.append(name)
    MHE_opts['input_names'] = new_input_names
    #Report names not in model
    not_in_model_list = [(pn_not_in_model, 'process_noise_cov'),
                         (meas_not_in_model,'measurement_cov'),
                         (P0_not_in_model, 'P0_cov'), 
                         (input_not_in_model, 'input_names')]
    report_names_not_in_model(not_in_model_list)
    
    #Check for duplicates in the different structures
    duplicate_list = [(process_noise_names, 'process_noise_cov'),
                     (measured_var_names,'measurement_cov'),
                     (P0_names, 'P0_cov'), 
                     (new_input_names, 'input_names')]
    check_for_duplicates(duplicate_list)
    
    undefined_input_names = [name for name in all_input_names \
                             if name not in MHE_opts['input_names'] \
                             and name not in process_noise_names]
    return(process_noise_names, measured_var_names, 
           undefined_input_names, opts)
    
def report_names_not_in_model(not_in_model_list):
    """
    Print error messages for variables named in the inputs that 
    are not in the model.

    Parameters::
        not_in_model_list --
            A list with items on the form (list, structure_name), 
            where list is a list of names that were found in the 
            structure with the name structure_name, but could not 
            be found in the model.
    """
    stop = False
    for (list, structure_name) in not_in_model_list:
        if len(list) != 0:
            error_message = "Error: The following given variable names" +\
                             " in " + structure_name + " were not found " +\
                             "in the model:"
            for name in list:
                error_message = error_message + name + "\n"
                
            raise NameError(error_message)

def report_missing_names(missing_names_list):
    """
    Prints error messages for names that were expected in the 
    inputs but not found.

    Parameters::
        missing_names_list --
            A list with items on the form (list, structure_name), 
            where list is a list of names that were not found in 
            the structure with the name structure_name, but could 
            not be found in the model.
    """
    stop = False
    for (list, structure_name) in missing_names_list:
        if len(list) != 0:
            error_message = "Error: The following variables or " +\
                            "their aliases were not found in " +\
                            structure_name + ":"
            for name in list:
                error_message = error_message + name + "\n"
            
            raise ValueError(error_message)

def check_for_duplicates(list):
    """
    Checks for duplicates and prints error messages for the input 
    structures where the duplicates were found.

    Parameters::
        list --
            A list with items on the form (list, structure_name), 
            where list is a list of all the names  found in 
            the structure with the name structure_name.
    """
    stop = False
    
    for (names, structure_name) in list:
        if len(names) > len(set(names)):
            stop = True
            error_message = "Error: Duplicate found in: " + structure_name
            raise RuntimeError(error_message)


def check_tuple_list(op, list, model_names, structure_name):
    """
    Checks a list of tuples with tuples on the form (name, value) and 
    replaces any alias names found.
    
    Parameters::
        op --
            An OptimizationProblem object.
            
        list --
            The tuple list with items on the form (name, value).
            
        model_names --
            A list of all the names of the variables of the 
            corresponding type.
            
        structure_name --
            The name of the structure the list comes from.
            For example 'x_0_guess' or 'u'.
            
    Returns::
        new_list --
            The tuple list with alias variable names replaced with 
            the model names.  
    """
    (new_list, names, not_in_model, missing_names) = \
            replace_aliases_in_tuple_list(op, list, model_names)
    missing_list = [(missing_names, structure_name)]
    report_missing_names(missing_list)
    not_in_model_list = [(not_in_model, structure_name)]
    report_names_not_in_model(not_in_model_list)
    duplicate_list = [(names, structure_name)]
    check_for_duplicates(duplicate_list)
    return new_list
    
def check_cov_list(op, cov_list, structure_name):
    """
    Checks a covariance list with items on the form 
    (names, covariance_matrix) for errors. Also replaces any 
    alias variable names and returns a corrected list.
    
    Parameters::
        op --
            An OptimizationProblem object.
    
        cov_list --
            A covariance list with items on the form 
            (names, covariance_matrix). Names is a list, tuple or 
            string of the variable names which have a covariance 
            matrix given by covariance_matrix. If names is a list 
            or tuple of length 1 or a string the covariance_matrix 
            can be given as a float or a 1D or 2D numpy array. For 
            lists or tuple of length greater than 1 
            covariance_matrix is given as a 2D numpy array. 
            
        structure_name --
            The name of the structure the list comes from.
            For example 'measurement_cov'.
            
    Returns::
        new_cov_list --
            The same covariance list but with all the alias variable 
            names replaced with the model names.
    """
    (new_cov_list, names, not_in_model) = \
                    _replace_aliases_in_cov_list(op, cov_list)
    not_in_model_list = [(not_in_model, structure_name)]
    report_names_not_in_model(not_in_model_list)
    duplicate_list = [(names, structure_name)]
    check_for_duplicates(duplicate_list)
    return new_cov_list
        
def replace_aliases_in_tuple_list(op, list, model_names):
    """
    Replaces the aliases in a list with items on the form 
    (name, value). Where name is the name of a variable and 
    value its value. Also creates a list of the names in the 
    new list and lists of missing variables and names not found 
    in the model.

    Parameters::
        op --
            An OptimizationProblem object.
        
        list --
            A list with items on the form 
            (name, value). 
            
        model_names --
            A list of all the names of the variables of the 
            corresponding type.
            
    Returns::
        new_list --
            The tuple list with alias variable names replaced with 
            the model names. 
            
        names --
            A list of all the names found in the tuple list.
            
        not_in_model --
            A list of all the names in the tuple list not found 
            in the model.
            
        missing_names --
            A list of all the names that were expected but not 
            found in the tuple list.
    """
    new_list = []
    not_in_model = []
    names = []
    for (name, value) in list:
        var = op.getVariable(name)
        if var == None:
            not_in_model.append(name)
            new_name = 'NONE'
        elif var.isAlias():
            new_name = var.getModelVariable().getName()
            names.append(new_name)
        else:
            new_name = name
            names.append(new_name)
        new_list.append((new_name, value))

    missing_names = []
    if len(model_names) != len(names):
        for name in model_names:
            if name not in names:
                missing_names.append(name)
    return(new_list, names, not_in_model, missing_names)

def _replace_aliases_in_cov_list(op, cov_list):
    """
    Replaces all the alias variable names found in the covariance 
    list. 
    
    Parameters::
        op --
            An OptimizationProblem object.
    
        cov_list --
            A covariance list with items on the form 
            (names, covariance_matrix). Names is a list, tuple or 
            string of the variable names which have a covariance 
            matrix given by covariance_matrix. If names is a list 
            or tuple of length 1 or a string the covariance_matrix 
            can be given as a float or a 1D or 2D numpy array. For 
            lists or tuple of length greater than 1 
            covariance_matrix is given as a 2D numpy array.
            
    Returns::
        new_cov_list --
            The same covariance list but with all the alias variable 
            names replaced with the model names.
            
        names --
            A list of all the names found in the covariance list.
            
        not_in_model --
            A list of all the names in the covariance list not found 
            in the model.
    """
    new_cov_list = []
    not_in_model = []
    names = []
    for (list, cov_matrix) in cov_list:
        #Check if the list is a string
        if isinstance(list, basestring):
            var = op.getVariable(list)
            if var == None:
                not_in_model.append(list)
                new_list = 'None'
            elif var.isAlias():
                name = var.getModelVariable().getName()
                new_list = name
                names.append(name)
                
            else:
                new_list = list
                names.append(list)
        else:
            new_list = []
            for name in list:
                var = op.getVariable(name)
                if var == None:
                    not_in_model.append(name)
                    new_list.append('NONE')
                elif var.isAlias():
                    name = var.getModelVariable().getName()
                    new_list.append(name)
                    names.append(name)
                else:
                    new_list.append(name)
                    names.append(name)
        new_cov_list.append((new_list, cov_matrix))
    return(new_cov_list, names, not_in_model)
