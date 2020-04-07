#!/usr/bin/env python
# -*- coding: utf-8 -*-

#    Copyright (C) 2014 Modelon AB
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
Module containing the CasADi interface Python wrappers.
"""

import os.path
import numpy as N
import sys

import casadi
from collections import OrderedDict, Iterable
from pyjmi.common.core import TrajectoryLinearInterpolation
import pyjmi.common.io
import pyfmi.common.io

from pyjmi.common.core import ModelBase, get_temp_location
from pyjmi.common import xmlparser
from pyjmi.common.xmlparser import XMLException
from pyfmi.common.core import (unzip_unit, get_platform_suffix,
                               get_files_in_archive, rename_to_tmp)
                            
from pyjmi.linearization import linearize_dae_with_simresult, linearize_dae_with_point

try:
    import modelicacasadi_wrapper as ci
    modelicacasadi_present = True
except ImportError:
    modelicacasadi_present = False
    
if modelicacasadi_present:
    from modelicacasadi_wrapper import OptimizationProblem as CI_OP
    from modelicacasadi_wrapper import Model as CI_Model
    from modelicacasadi_transfer import transfer_model as _transfer_model
    from modelicacasadi_transfer import transfer_optimization_problem as _transfer_optimization_problem 

def transfer_model(class_name, file_name=[],
                   compiler_options={}, compiler_log_level='warning'):
    """ 
    Compiles and transfers a model to the ModelicaCasADi interface. 
    
    A model class name must be passed, all other arguments have default values. 
    The different scenarios are:
    
    * Only class_name is passed: 
        - Class is assumed to be in MODELICAPATH.
    
    * class_name and file_name is passed:
        - file_name can be a single path as a string or a list of paths 
          (strings). The paths can be file or library paths.
    
        
    Parameters::
    
        class_name -- 
            The name of the model class.
            
        file_name -- 
            A path (string) or paths (list of strings) to model files and/or 
            libraries.
            Default: Empty list.
                        
        compiler_options --
            Options for the compiler.
            Note that MODELICAPATH is set to the standard for this
            installation if not given as an option.
            Default: Empty dict.
            
        compiler_log_level --
            Set the logging for the compiler. Valid options are:
            'warning'/'w', 'error'/'e', 'info'/'i' or 'debug'/'d'. 
            Default: 'warning'

                  
    Returns::
    
        A Model representing the class given by class_name.

"""
    model = Model() # no wrapper exists for Model yet
    _transfer_model(model, class_name=class_name, file_name=file_name,
                    compiler_options=compiler_options,
                    compiler_log_level=compiler_log_level)
    return model

def transfer_optimization_problem(class_name, file_name=[],
                                  compiler_options={}, compiler_log_level='warning',
                                  accept_model=False):
    """ 
    Compiles and transfers an optimization problem to the ModelicaCasADi interface. 
    
    A  model class name must be passed, all other arguments have default values. 
    The different scenarios are:
    
    * Only class_name is passed: 
        - Class is assumed to be in MODELICAPATH.
    
    * class_name and file_name is passed:
        - file_name can be a single path as a string or a list of paths 
          (strings). The paths can be file or library paths.
    
        
    Parameters::
    
        class_name -- 
            The name of the model class.
            
        file_name -- 
            A path (string) or paths (list of strings) to model files and/or 
            libraries.
            Default: Empty list.

        compiler_options --
            Options for the compiler.
            Note that MODELICAPATH is set to the standard for this
            installation if not given as an option.
            Default: Empty dict.
            
        compiler_log_level --
            Set the logging for the compiler. Valid options are:
            'warning'/'w', 'error'/'e', 'info'/'i' or 'debug'/'d'. 
            Default: 'warning'

        accept_model --
            If true, allows to transfer a model. Only the model parts of the
            OptimizationProblem will be initialized.


    Returns::
    
        An OptimizationProblem representing the class given by class_name.

    """
    op = OptimizationProblem()
    _transfer_optimization_problem(op, class_name=class_name, file_name=file_name,
                                   compiler_options=compiler_options,
                                   compiler_log_level=compiler_log_level,
                                   accept_model=accept_model)
    return op

def transfer_to_casadi_interface(*args, **kwargs):
    return transfer_optimization_problem(*args, **kwargs)

def convert_casadi_der_name(name):
    n = name.split('der_')[1]
    qnames = n.split('.')
    n = ''
    for i in range(len(qnames)-1):
        n = n + qnames[i] + '.'
    return n + 'der(' + qnames[len(qnames)-1] + ')' 

def unzip_fmux(archive, path='.'):
    """
    Unzip an FMUX.
    
    Looks for a model description XML file and returns the result in a dict with 
    the key words: 'model_desc'. If the file is not found an exception will be 
    raised.
    
    Parameters::
        
        archive --
            The archive file name.
            
        path --
            The path to the archive file.
            Default: Current directory.
            
    Raises::
    
        IOError the model description XML file is missing in the FMU.
    """
    tmpdir = unzip_unit(archive, path)
    fmux_files = get_files_in_archive(tmpdir)
    
    # check if all files have been found during unzip
    if fmux_files['model_desc'] == None:
        raise IOError('ModelDescription.xml not found in FMUX archive: '+str(archive))
    
    return fmux_files

if not modelicacasadi_present:
    # Dummy class so that OptimizationProblem won't give an error.
    # todo: exclude OptimizationProblem instead?
    class CI_OP:
        pass
    class CI_Model:
        pass

class Model(CI_Model):

    """
    Python wrapper for the CasADi Interface class Model.
    """

    def get_attr(self, var, attr):
        """
        Helper method for getting values of variable attributes.

        Parameters::

            var --
                Variable object to get attribute value from.

                Type: Variable

            attr --
                Attribute whose value is sought.

                If var is a parameter and attr == "_value", the value of the
                parameter is returned.

                Type: str

        Returns::

            Value of attribute attr of Variable var.
        """
        if attr == "_value":
            val = var.getAttribute('evaluatedBindingExpression')
            if val is None:
                val = var.getAttribute('bindingExpression')
                if val is None:
                    if var.getVariability() != var.PARAMETER:
                        raise ValueError("%s is not a parameter." %
                                         var.getName())
                    else:
                        raise RuntimeError("BUG: Unable to evaluate " +
                                           "value of %s." % var.getName())
            return val.getValue()
        elif attr == "comment":
            var_desc = var.getAttribute("comment")
            if var_desc is None:
                return ""
            else:
                return var_desc.getName()
        elif attr == "nominal":
            if var.isDerivative():
                var = var.getMyDifferentiatedVariable()
            val_expr = var.getAttribute(attr)
            return self.evaluateExpression(val_expr)
        else:
            val_expr = var.getAttribute(attr)
            if val_expr is None:
                if attr == "free":
                    return False
                elif attr == "initialGuess":
                    return self.get_attr(var, "start")
                else:
                    raise ValueError("Variable %s does not have attribute %s."
                                     % (var.getName(), attr))
            return self.evaluateExpression(val_expr)

    def augment_sensitivities(self, parameters):
        """
        Adds forward sensitivity variables and equations for all model variables with respect to given parameters.

        Parameters::

            parameters --
                List of parameter names for which to compute sensitivities.
        """
        ###################################################################
        ###           This code does not exploit DAE sparsity!          ###
        ### Although this will probably not affect online computations. ###
        ###################################################################

        # Get residuals and variables
        dae = self.getDaeResidual()
        init = self.getInitialResidual()
        var_kinds = {'dx': self.DERIVATIVE,
                     'x': self.DIFFERENTIATED,
                     'w': self.REAL_ALGEBRAIC}
        mvar_vectors = {'dx': N.array([var for var in self.getVariables(var_kinds['dx'])
                                       if (not var.isAlias() and not var.wasEliminated())]),
                        'x': N.array([var for var in self.getVariables(var_kinds['x'])
                                      if (not var.isAlias() and not var.wasEliminated())]),
                        'w': N.array([var for var in self.getVariables(var_kinds['w'])
                                      if (not var.isAlias() and not var.wasEliminated())])}
        mvar_par = N.array([self.getVariable(par) for par in parameters])

        # Add sensitivity variables
        for par in mvar_par:
            par_var = par.getVar()
            for mvar in mvar_vectors['x']:
                # States
                mvar_var = mvar.getVar()
                name = "d%s/d%s" % (mvar.getName(), par.getName())
                sens_var = casadi.MX.sym(name)
                sens = ci.RealVariable(self, sens_var, ci.RealVariable.INTERNAL, ci.RealVariable.CONTINUOUS)
                self.addVariable(sens)

                # State derivatives
                dx_mvar = mvar.getMyDerivativeVariable()
                dx_mvar_var = dx_mvar.getVar()
                dx_name = "der(d%s/d%s)" % (mvar.getName(), par.getName())
                dx_sens_var = casadi.MX.sym(dx_name)
                dx_sens = ci.DerivativeVariable(self, dx_sens_var, sens)
                self.addVariable(dx_sens)
            for mvar in mvar_vectors['w']:
                # Algebraics
                mvar_var = mvar.getVar()
                name = "d%s/d%s" % (mvar.getName(), par.getName())
                sens_var = casadi.MX.sym(name)
                sens = ci.RealVariable(self, sens_var, ci.RealVariable.INTERNAL, ci.RealVariable.CONTINUOUS)
                self.addVariable(sens)

        # Compute derivatives
        dfdx = {}
        df0dx = {}
        for vk in var_kinds:
            dfdx[vk] = {}
            df0dx[vk] = {}
            for mvar in mvar_vectors[vk]:
                mvar_var = mvar.getVar()
                dfdx[vk][mvar.getName()] = N.array([casadi.jacobian(dae_eq, mvar_var) for dae_eq in dae])
                df0dx[vk][mvar.getName()] = N.array([casadi.jacobian(init_eq, mvar_var) for init_eq in init])
        
        # Add sensitivity differential equations
        mx_zero = casadi.MX(0.)
        for par in mvar_par:
            for i in xrange(dae.numel()):
                eq = mx_zero
                for vk in var_kinds:
                    for mvar in mvar_vectors[vk]:
                        if vk == "dx":
                            name = "der(d%s/d%s)" % (mvar.getMyDifferentiatedVariable().getName(), par.getName())
                        else:
                            name = "d%s/d%s" % (mvar.getName(), par.getName())
                        sens_var = self.getVariable(name).getVar()
                        eq += dfdx[vk][mvar.getName()][i] * sens_var
                eq += casadi.jacobian(dae[i], par.getVar())
                sens_eq = ci.Equation(eq, mx_zero)
                self.addDaeEquation(sens_eq)

        # Add sensitivity initial equations
        for par in mvar_par:
            for i in xrange(init.numel()):
                init_eq = mx_zero
                for vk in var_kinds:
                    for mvar in mvar_vectors[vk]:
                        if vk == "dx":
                            name = "der(d%s/d%s)" % (mvar.getMyDifferentiatedVariable().getName(), par.getName())
                        else:
                            name = "d%s/d%s" % (mvar.getName(), par.getName())
                        sens_var = self.getVariable(name).getVar()
                        init_eq += df0dx[vk][mvar.getName()][i] * sens_var
                init_eq += casadi.jacobian(init[i], par.getVar())
                sens_init_eq = ci.Equation(init_eq, mx_zero)
                self.addInitialEquation(sens_init_eq)

class OptimizationProblem(Model, CI_OP, ModelBase):

    """
    Python wrapper for the CasADi Interface class OptimizationProblem.
    """

    def _default_options(self, algorithm):
        """ 
        Help method. Gets the options class for the algorithm specified in 
        'algorithm'.
        """
        base_path = 'pyjmi.jmi_algorithm_drivers'
        algdrive = __import__(base_path)
        algdrive = getattr(algdrive, 'jmi_algorithm_drivers')
        algorithm = getattr(algdrive, algorithm)
        return algorithm.get_default_options()

    def optimize_options(self, algorithm='LocalDAECollocationAlg'):
        """
        Returns an instance of the optimize options class containing options 
        default values. If called without argument then the options class for 
        the default optimization algorithm will be returned.
        
        Parameters::
        
            algorithm --
                The algorithm for which the options class should be returned. 
                Possible values are: 'LocalDAECollocationAlg' and
                'CasadiPseudoSpectralAlg'
                Default: 'LocalDAECollocationAlg'
                
        Returns::
        
            Options class for the algorithm specified with default values.
        """
        return self._default_options(algorithm)
    
    def optimize(self, algorithm='LocalDAECollocationAlg', options={}):
        """
        Solve an optimization problem.
            
        Parameters::
            
            algorithm --
                The algorithm which will be used for the optimization is 
                specified by passing the algorithm class name as string or class 
                object in this argument. 'algorithm' can be any class which 
                implements the abstract class AlgorithmBase (found in 
                algorithm_drivers.py). In this way it is possible to write 
                custom algorithms and to use them with this function.

                The following algorithms are available:
                - 'LocalDAECollocationAlg'. This algorithm is based on direct
                  collocation on finite elements and the algorithm IPOPT is
                  used to obtain a numerical solution to the problem.
                Default: 'LocalDAECollocationAlg'
                
            options -- 
                The options that should be used in the algorithm. The options
                documentation can be retrieved from an options object:
                
                    >>> myModel = CasadiModel(...)
                    >>> opts = myModel.optimize_options(algorithm)
                    >>> opts?

                Valid values are: 
                - A dict that overrides some or all of the algorithm's default
                  values. An empty dict will thus give all options with default
                  values.
                - An Options object for the corresponding algorithm, e.g.
                  LocalDAECollocationAlgOptions for LocalDAECollocationAlg.
                Default: Empty dict
            
        Returns::
            
            A result object, subclass of algorithm_drivers.ResultBase.
        """
        if algorithm != "LocalDAECollocationAlg":
            raise ValueError("LocalDAECollocationAlg is the only supported " +
                             "algorithm.")
        return self._exec_algorithm('pyjmi.jmi_algorithm_drivers',
                                    algorithm, options)

    # Make solve synonymous with optimize
    solve_options = optimize_options
    solve = optimize

    def prepare_optimization(self, algorithm='LocalDAECollocationPrepareAlg', options={}):
        """
        Prepare the solution of an optimization problem.

        The arguments are the same as for the optimize method.

        Returns::

            A solver object that can be used to solve the problem and change settings.
        """
        if algorithm != "LocalDAECollocationPrepareAlg":
            raise ValueError("LocalDAECollocationPrepareAlg is the only supported " +
                             "algorithm.")
        return self._exec_algorithm('pyjmi.jmi_algorithm_drivers',
                                    algorithm, options)

    def get_state_names(self):
        return [var.getName() for var in self.getVariables(self.DIFFERENTIATED)\
         if not var.isAlias()]

    def create_timed_sensitivities(self, outputs, parameters, time_points):
        """
        Creates variables for output sensitivities at time points.
        
        Adds timed variables to the optimization problem for the sensitivities of
        the outputs with respect to the parameters at the given time points.

        Parameters::

            outputs --
                List of output names for which to compute time sensitivities.

            parameters --
                List of parameter names for which to compute time sensitivities.

            time_points --
                List of time points for the computed sensitivities.

        Returns::

            timed_sens --
                List of 2-dimensional arrays. timed_sens[i][j, k] contains the
                sensitivity of output j with respect to parameter k at time point
                i.
        """
        time_points = map(casadi.MX, time_points)
        sensitivities = N.array([[self.getVariable('d%s/d%s' % (var, par)) for par in parameters] for var in outputs])
        timed_mx_vars = [N.array([[casadi.MX.sym(sens.getName() + "(%s)" % tp.getValue()) for sens in sensitivities[i]]
                                  for i in xrange(len(outputs))]) for tp in time_points]
        timed_sens = []
        for i in xrange(len(time_points)):
            timed_sens_i = []
            for j in xrange(len(outputs)):
                timed_sens_ij = []
                for k in xrange(len(parameters)):
                    tv = ci.TimedVariable(self, timed_mx_vars[i][j, k], sensitivities[j, k], time_points[i])
                    self.addTimedVariable(tv)
                    timed_sens_ij.append(tv)
                timed_sens_i.append(timed_sens_ij)
            timed_sens.append(N.array(timed_sens_i))
        return timed_sens

    def setup_oed(self, outputs, parameters, sigma, time_points, design="A"):
        """
        Transforms an Optimization Problem into an Optimal Experimental Design problem.

        Parameters::

            outputs --
                List of names for outputs.

                Type: [string]

            parameters --
                List of names for parameters to estimate.

                Type: [string]

            sigma --
                Experiment variance matrix.

                Type: [[float]]

            time_points --
                List of measurement time points.

                Type: [float]

            design --
                Design criterion.

                Possible values: "A", "T"
        """
        # Augment sensitivities and add timed variables
        self.augment_sensitivities(parameters)
        timed_sens = self.create_timed_sensitivities(outputs, parameters, time_points)
        
        # Create sensitivity and Fisher matrices
        Q = []
        for j in xrange(len(outputs)):
            Q.append(casadi.vertcat([casadi.horzcat([s.getVar() for s in timed_sens[i][j]])
                                     for i in xrange(len(time_points))]))
        Fisher = sum([sigma[i, j] * casadi.mul(Q[i].T, Q[j]) for i in xrange(len(outputs))
                      for j in xrange(len(outputs))])

        # Define the objective
        if design == "A":
            b = casadi.MX.sym("b", Fisher.shape[1], 1)
            Fisher_inv = casadi.jacobian(casadi.solve(Fisher, b), b)
            obj = casadi.trace(Fisher_inv)
        elif design == "T":
            obj = -casadi.trace(Fisher)
        elif design == "D":
            obj = -casadi.det(Fisher)
            raise NotImplementedError("D-optimal design is not supported.")
        else:
            raise ValueError("Invalid design %s." % design)
        old_obj = self.getObjective()
        self.setObjective(old_obj + obj)
         
class CasadiModel(ModelBase):
    
    """
    This class is obsolete.
    """
    
    def __init__(self, name, path='.', verbose=True, ode=False):
        raise DeprecationWarning('CasadiModel is obsolete. \n \
        The CasadiPseudoSpectralAlg and LocalDAECollocationAlgOld \n \
        are no longer supported. To solve an optimization problem \n \
        with CasADi use pyjmi.transfer_optimization_problem instead.')
        
