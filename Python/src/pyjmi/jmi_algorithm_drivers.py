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
Module for optimization, simulation and initialization algorithms to be used 
together with pyjmi.jmi.JMUModel.optimize, pyjmi.jmi.JMUModel.simulate and
pyjmi.jmi.JMUModel.initialize respectively.
"""

#from abc import ABCMeta, abstractmethod
import collections
import logging
import time
import numpy as N

from pyjmi.common.algorithm_drivers import AlgorithmBase, JMResultBase, AssimuloSimResult, OptionBase, InvalidAlgorithmOptionException, InvalidSolverArgumentException
from pyjmi.common.io import ResultDymolaTextual

from pyjmi.optimization import ipopt
from pyjmi.initialization.ipopt import InitializationOptimizer
from pyjmi.common.core import TrajectoryLinearInterpolation
from pyjmi.common.core import TrajectoryUserFunction

try:
    import pyjmi
    ipopt_present = pyjmi.environ['IPOPT_HOME']
except:
    ipopt_present = False

try:
    import casadi
    casadi_present = True
except:
    casadi_present = False
    
if casadi_present:
    from pyjmi.optimization.casadi_collocation import *
    from pyjmi.optimization import casadi_collocation
    from pyjmi.optimization.polynomial import *
    from pyjmi.common.xmlparser import XMLException

default_int = int
int = N.int32
N.int = N.int32


class IpoptInitResult(JMResultBase):
    pass
  

class LocalDAECollocationPrepareAlg(AlgorithmBase):
    """
    Carries out the setup parts of LocalDAECollocationAlg.
    """
    def __init__(self, op, options):
        """
        Create a LocalDAECollocationPrepareAlg

        Arguments are the same as for LocalDAECollocationAlg.
        """
        self.alg = LocalDAECollocationAlg(op, options)
        self.solver = self.alg.nlp.wrapper

    def solve(self):
        pass

    def get_result(self):
        return self.solver


class LocalDAECollocationAlg(AlgorithmBase):
    
    """
    The algorithm is based on orthogonal collocation and relies on the solver 
    IPOPT for solving the arising non-linear programming problem.
    """
    
    def __init__(self, op, options):
        """
        Create a LocalDAECollocationAlg algorithm.
        
        Parameters::
              
            op -- 
                OptimizationProblem from CasADiInterface

            options -- 
                The options that should be used by the algorithm. For 
                details on the options, see:
                
                model.optimize_options('LocalDAECollocationAlgOptions')
                
                or look at the docstring with help:
                
                help(pyjmi.jmi_algorithm_drivers.LocalDAECollocationAlgOptions)
                
                Valid values are: 
                - A dict that overrides some or all of the default values
                  provided by LocalDAECollocationAlgOptions. An empty
                  dict will thus give all options with default values.
                - A LocalDAECollocationAlgOptions object.
        """
        t0_init = time.clock()
        self.op = op
        model = op
        self.model = model

        # Check that model does not contain any unsupported variables
        var_kinds = [(model.BOOLEAN_DISCRETE, "Boolean discrete"),
                     (model.BOOLEAN_INPUT, "Boolean input"),
                     (model.INTEGER_DISCRETE, "integer discrete"),
                     (model.INTEGER_INPUT, "integer input"),
                     (model.REAL_DISCRETE, "real discrete"),
                     (model.STRING_DISCRETE, "string discrete"),
                     (model.STRING_INPUT, "string input")]
        error_str = ''
        for (kind, name) in var_kinds:
            variables = model.getVariables(kind)
            if len(variables) == 1:
                var_name = variables[0].getName()
                error_str += ("The following variable is %s, which " % name +
                              "is not supported: %s.\n\n" % var_name)
            elif len(variables) > 1:
                error_str += ("The following variables are %s, " % name +
                              "which is not supported: ")
                for var in variables[:-1]:
                    error_str += var.getName() + ", "
                error_str += variables[-1].getName() + ".\n\n"

        # Check for unsupported free parameters
        var_kinds = [(model.BOOLEAN_PARAMETER_DEPENDENT,
                      "Boolean parameter dependent"),
                     (model.BOOLEAN_PARAMETER_INDEPENDENT,
                      "Boolean parameter independent"),
                     (model.INTEGER_PARAMETER_DEPENDENT,
                      "integer parameter dependent"),
                     (model.INTEGER_PARAMETER_INDEPENDENT,
                      "integer parameter independent"),
                     (model.STRING_PARAMETER_DEPENDENT,
                      "string parameter dependent"),
                     (model.STRING_PARAMETER_INDEPENDENT,
                      "string parameter independent")]
        for (kind, name) in var_kinds:
            variables = [var for var in model.getVariables(kind)
                         if op.get_attr(var, "free")]
            if len(variables) == 1:
                var_name = variables[0].getName()
                error_str += ("The following parameter is %s and free, "%name +
                              "which is not supported: %s.\n\n" % var_name)
            elif len(variables) > 1:
                error_str += ("The following parameters are %s and " % name +
                              "free, which is not supported: ")
                for var in variables[:-1]:
                    error_str += var.getName() + ", "
                error_str += variables[-1].getName() + ".\n\n"
        if len(error_str) > 0:
            raise Exception(error_str)
        
        # handle options argument
        if isinstance(options, dict):
            # user has passed dict with options or empty dict = default
            self.options = LocalDAECollocationAlgOptions(options)
        elif isinstance(options, LocalDAECollocationAlgOptions):
            # user has passed LocalDAECollocationAlgOptions instance
            self.options = options
        else:
            raise InvalidAlgorithmOptionException(options)

        # set options
        self._set_options()
            
        if not casadi_present:
            raise Exception(
                    'Could not find CasADi. Check pyjmi.check_packages()')
        
        self.nlp = LocalDAECollocator(self.op, self.options)
            
        # set solver options
        self._set_solver_options()
        self.nlp.solver_object.init()

        # record the initialization time including initialization within the algorithm object
        self.nlp.times['init'] = time.clock() - t0_init
        
    def _set_options(self):
        """ 
        Set algorithm options and assert their validity.
        """
        self.__dict__.update(self.options)
        defaults = self.get_default_options()
        
        # Check validity of element lengths
        if self.hs != "free" and self.hs is not None:
            self.hs = list(self.hs)
            if len(self.hs) != self.n_e:
                raise ValueError("The number of specified element lengths " +
                                 "must be equal to the number of elements.")
            if not N.allclose(N.sum(self.hs), 1):
                raise ValueError("The sum of all elements lengths must be" +
                                 "(almost) equal to 1.")
        if self.h_bounds != defaults['h_bounds']:
            if self.hs != "free":
                raise ValueError("h_bounds is only used if algorithm " + \
                                 'option hs is set to "free".')
        
        # Check validity of free_element_lengths_data
        if self.free_element_lengths_data is None:
            if self.hs == "free":
                raise ValueError("free_element_lengths_data must be given " + \
                                 'if self.hs == "free".')
        if self.free_element_lengths_data is not None:
            if self.hs != "free":
                raise ValueError("free_element_lengths_data can only be " + \
                                 'given if self.hs == "free".')
        
        # Check validity of discr
        if self.discr == "LGL":
            raise NotImplementedError("Lobatto collocation is currently " + \
                                      "not supported.")
        elif self.discr != "LG" and self.discr != "LGR":
            raise ValueError("Unknown discretization scheme %s." % self.discr)
        
        # Check validity of quadrature_constraint
        if (self.discr == "LG" and self.eliminate_der_var and
            self.quadrature_constraint):
            raise NotImplementedError("quadrature_constraint is not " + \
                                      "compatible with eliminate_der_var.")

        # Check validity of init_dual
        if self.init_dual is not None and self.solver == "IPOPT":
            try:
                warm_start = self.IPOPT_options['warm_start_init_point']
            except KeyError:
                warm_start = False
            if not warm_start:
                print("Warning: The provided initial guess for the dual " +
                      "variables will not be used since warm start is not " +
                      "enabled for IPOPT.")

        # Check validity of blocking_factors
        if self.blocking_factors is not None:
            if isinstance(self.blocking_factors, collections.Iterable):
                if N.sum(self.blocking_factors) != self.n_e:
                    raise ValueError(
                            "The sum of blocking factors does not " +
                            "match the number of collocation elements.")
            elif isinstance(self.blocking_factors, BlockingFactors):
                for (name, facs) in self.blocking_factors.factors.iteritems():
                    var = self.op.getVariable(name)
                    if var is None:
                        raise ValueError('Variable %s not found in ' % name +
                                         'optimization problem.')
                    if var not in self.op.getVariables(self.op.REAL_INPUT):
                        raise ValueError(
                                "Blocking factors provided for variable " +
                                "%s, but %s is not a real " % (name, name) +
                                "input.")

                    # Check that factors correspond to number of elements
                    if N.sum(facs) != self.n_e:
                        raise ValueError(
                                "The sum of blocking factors for variable " +
                                "%s does not match the number of " % name +
                                "collocation elements.")

                    # Check if variable is in optimization problem
                    if var is None:
                        raise ValueError(
                                "Blocking factors provided for variable " +
                                "%s, but variable %s not " % (name, name) +
                                "found in optimization problem.")

                    # Check bound
                    if name in self.blocking_factors.du_bounds:
                        if self.blocking_factors.du_bounds[name] < 0:
                            raise ValueError("du bound for variable %s "%name+
                                             "is negative.")

                    # Replace alias variables
                    if var.isAlias():
                        mvar = var.getModelVariable()
                        self.blocking_factors.factors[mvar.getName()] = facs
                        del self.blocking_factors.factors[name]
                        if name in self.blocking_factors.du_bounds:
                            self.blocking_factors.du_bounds[mvar.getName()] = \
                                    self.blocking_factors.du_bounds[name]
                            del self.blocking_factors.du_bounds[name]
                        if name in self.blocking_factors.du_quad_pen:
                            self.blocking_factors.du_quad_pen[mvar.getName()]=\
                                    self.blocking_factors.du_quad_pen[name]
                            del self.blocking_factors.du_quad_pen[name]
            else:
                raise ValueError('blocking_factors must either be an ' +
                                 'iterable or an instance of BlockingFactors.')
        
        # Check validity of nominal_traj_mode
        for name in self.nominal_traj_mode.keys():
            if name != "_default_mode":
                var = self.op.getVariable(name)
                if var is None:
                    raise ValueError(
                            "Nominal mode provided for variable %s, " % name +
                            "but variable %s not found in " % name +
                            "optimization problem.")
                if var.isAlias():
                    mvar = var.getModelVariable()
                    self.nominal_traj_mode[mvar.getName()] = \
                            self.nominal_traj_mode[name]
                    del self.nominal_traj_mode[name]

        # Check validity of check point
        if self.checkpoint and self.blocking_factors is not None:
            raise NotImplementedError("Checkpoint does not work with " +
                                      "blocking factors.")

        # Check validity of order
        if self.order != "default" and not self.write_scaled_result:
            raise NotImplementedError("Reordering is only supported with enabled write_scaled_result.")
        
        # Solver options
        if self.solver == "IPOPT":
            self.solver_options = self.IPOPT_options
        elif self.solver == "WORHP":
            self.solver_options = self.WORHP_options
        else:
            raise ValueError('Unknown nonlinear programming solver %s.' %
                             self.solver)
        
    def _set_solver_options(self):
        """ 
        Helper function that sets options for the solver.
        """
        for (k, v) in self.solver_options.iteritems():
            self.nlp.set_solver_option(k, v)
            
    def solve(self):
        """ 
        Solve the optimization problem using ipopt solver. 
        """
        self.nlp.solve_and_write_result()

    def get_result(self):
        """ 
        Load result data and create a LocalDAECollocationAlgResult object.
        
        Returns::
        
            The LocalDAECollocationAlgResult object.
        """
        return self.nlp.get_result_object()

    @classmethod
    def get_default_options(cls):
        """ 
        Get an instance of the options class for the LocalDAECollocationAlg
        algorithm, prefilled with default values. (Class method.)
        """
        return LocalDAECollocationAlgOptions()
    
class LocalDAECollocationAlgOptions(OptionBase):
    
    """
    Options for optimizing CasADi models using a collocation algorithm. 

    Collocation algorithm standard options::
    
        n_e --
            Number of finite elements.
            
            Type: int
            Default: 50
        
        hs --
            Element lengths.
            
            Possible values: None, iterable of floats and "free"
            
            None: The element lengths are uniformly distributed.
            
            iterable of floats: Component i of the iterable specifies the
            length of element i. The lengths must be normalized in the sense
            that the sum of all lengths must be equal to 1.
            
            "free": The element lengths become optimization variables and are
            optimized according to the algorithm option
            free_element_lengths_data.
            WARNING: The "free" option is very experimental and will not always give
            desirable results.
            
            Type: None, iterable of floats or string
            Default: None
        
        n_cp --
            Number of collocation points in each element.
            
            Type: int
            Default: 3
        
        expand_to_sx --
            Whether to expand the CasADi MX graphs to SX graphs. Possible
            values: "NLP", "DAE", "no".

            "NLP": The entire NLP graph is expanded into SX. This will lead to
            high evaluation speed and high memory consumption.

            "DAE": The DAE, objective and constraint graphs for the dynamic
            optimization problem expressions are expanded into SX, but the full
            NLP graph is an MX graph. This will lead to moderate evaluation
            speed and moderate memory consumption.

            "no": All constructed graphs are MX graphs. This will lead to low
            evaluation speed and low memory consumption.
            
            Type: str
            Default: "NLP"
        
        init_traj --
            Variable trajectory data used for initialization of the NLP
            variables.
            
            Type: None or pyjmi.common.io.ResultDymolaTextual or
                  pyjmi.common.algorithm_drivers.JMResultBase
            Default: None
        
        nominal_traj --
            Variable trajectory data used for scaling of the NLP variables.
            This option is only applicable if variable scaling is enabled.
            
            Type: None or pyjmi.common.io.ResultDymolaTextual or
                  pyjmi.common.algorithm_drivers.JMResultBase
            Default: None
        
        blocking_factors --
            Blocking factors are used to enforce piecewise constant inputs. The
            inputs may only change values at some of the element boundaries.
            The option is either None (disabled), given as an instance of
            pyjmi.optimization.casadi_collocation.BlockingFactors or as a list
            of blocking factors.

            If the options is a list of blocking factors, then each element in
            the list specifies the number of collocation elements for which all
            of the inputs must be constant. For example, if blocking_factors ==
            [2, 2, 1], then the inputs will attain 3 different values (number
            of elements in the list), and it will change values between
            collocation element number 2 and 3 as well as number 4 and 5. The
            sum of all elements in the list must be the same as the number of
            collocation elements and the length of the list determines the
            number of separate values that the inputs may attain.

            See the documentation of the BlockingFactors class for how to use
            it.
            
            If blocking_factors is None, then the usual collocation polynomials
            are instead used to represent the controls.
            
            Type: None, iterable of ints, or instance of
                  pyjmi.optimization.casadi_collocation.BlockingFactors
            Default: None
        
        external_data --
            Data used to penalize, constrain or eliminate certain variables.
            
            Type: None or
            pyjmi.optimization.casadi_collocation.ExternalData
            Default: None

        delayed_feedback --
            Experimental feature used to add delay constraints to the
            optimization problem.

            If not None, should be a dict with mappings
            'delayed_var': ('undelayed_var', delay_ne).
            For each such pair, adds the the constraint that the variable
            'delayed_var' equals the value of the variable 'undelayed_var'
            delayed by delay_ne elements. The initial part of the trajectory
            for 'delayed_var' is fixed to its initial guess given by the
            init_traj option or the initialGuess attribute.

            'delayed_var' will typically be an input.
            This is an experimental feature and is subject to change.

            Type: None or dict
            Default: None

        solver --
            Specifies the nonlinear programming solver to be used. Possible
            choices are 'IPOPT' and 'WORHP'.

            Type: String
            Default: 'IPOPT'

        verbosity --
            Sets verbosity of algorithm output. 0 prints nothing, 3 prints everything.

            Type: int
            Default: 3

    Collocation algorithm experimental/debug options::

        free_element_lengths_data --
            Data used for optimizing the element lengths if they are free.
            Should be None when hs != "free".
            
            Type: None or
            pyjmi.optimization.casadi_collocation.FreeElementLengthsData
            Default: None

        discr --
            Determines the collocation scheme used to discretize the problem.
            
            Possible values: "LG" and "LGR".
            
            "LG": Gauss collocation (Legendre-Gauss).
            
            "LGR": Radau collocation (Legendre-Gauss-Radau).
            
            Type: str
            Default: "LGR"

        named_vars --
            If enabled, the solver will create a duplicated set of NLP
            variables which have names corresponding to the Modelica/Optimica
            variable names. Symbolic expressions of the NLP consisting of the
            named variables can then be obtained using the get_named_var_expr
            method of the collocator class.

            This option is only intended for investigative purposes.

            Type: bool
            Default: False

        init_dual --
            Dictionary containing vectors of initial guess for NLP dual
            variables. Intended to be obtained as the solution of an
            optimization problem which has an identical structure, which is
            stored in the dual_opt attribute of the result object.

            The dictionary has two keys, 'g' and 'x', containing vectors of the
            corresponding dual variable intial guesses.

            Note that when using IPOPT, the option warm_start_init_point has to
            be activated for this option to have an effect.

            Type: None or dict
            Default: None

        equation_scaling --
            Whether to scale the equations in collocated NLP.
            Many NLP solvers default to scaling the equations, but if it is
            done through this option the resulting scaling can be inspected.
            
            Type: bool
            Default: False

        variable_scaling --
            Whether to scale the variables according to their nominal values or
            the trajectories provided with the nominal_traj option.
            
            Type: bool
            Default: True
            
        variable_scaling_allow_update --
            Whether or not parameters should be included in the NLP so that
            the variable scaling can be updated on the returned solver
            object.
            
            Type: bool
            Default: False
        
        nominal_traj_mode --
            Mode for computing scaling factors for each variable based on
            nominal trajectories. Four possible modes:
            
            "attribute": Time-invariant, linear scaling based on Nominal
            attribute
            
            "linear": Time-invariant, linear scaling
            
            "affine": Time-invariant, affine scaling
            
            "time-variant": Time-variant, linear scaling
            
            Option is a dictionary with variable names as keys and
            corresponding scaling modes as values. For all variables
            not occuring in the keys of the dictionary, the mode specified by
            the "_default_mode" entry will be used, which by default is
            "linear".
            
            Type: {str: str}
            Default: {"_default_mode": "linear"}

        print_condition_numbers --
            Prints the condition numbers of the Jacobian of the constraints and
            of the simplified KKT matrix at the initial and optimal points.
            Note that this is only feasible for very small problems.

            Type: bool
            Default: False
        
        write_scaled_result --
            Return the scaled optimization result if set to True, otherwise
            return the unscaled optimization result. This option is only
            applicable when variable_scaling is enabled and is only intended
            for debugging.
            
            Type: bool
            Default: False
        
        result_file_name --
            Specifies the name of the file where the result is written. Setting
            this option to an empty string results in a default file name that
            is based on the name of the model class.

            Type: str
            Default: ""
        
        result_mode --
            Specifies the output format of the optimization result.
            
            Possible values: "collocation_points", "element_interpolation" and
            "mesh_points"
            
            "collocation_points": The optimization result is given at the
            collocation points as well as the start and final time point.
            
            "element_interpolation": The values of the variable trajectories
            are calculated by evaluating the collocation polynomials. The
            algorithm option n_eval_points is used to specify the
            evaluation points within each finite element.
            
            "mesh_points": The optimization result is given at the
            mesh points.
            
            Type: str
            Default: "collocation_points"
        
        n_eval_points --
            The number of evaluation points used in each element when the
            algorithm option result_mode is set to "element_interpolation". One
            evaluation point is placed at each element end-point (hence the
            option value must be at least 2) and the rest are distributed
            uniformly.
            
            Type: int
            Default: 20
        
        quadrature_constraint --
            Whether to use quadrature continuity constraints. This option is
            only applicable when using Gauss collocation. It is incompatible
            with eliminate_der_var set to True.
            
            True: Quadrature is used to get the values of the states at the
            mesh points.
            
            False: The Lagrange basis polynomials for the state collocation
            polynomials are evaluated to get the values of the states at the
            mesh points.
            
            Type: bool
            Default: True
            
        checkpoint --
            checkpoint is used to build the transcribed NLP with packed MX
            functions. Instead of calling the dae residual function, the 
            collocation equation function, and the lagrange term function 
            n_e\cdotn_cp times, the check point scheme builds an MXFunction 
            evaluating n_cp collocation points at the same time, so that the
            packed MXFunction is called only n_e times. This approach improves
            the code generation and it is expected to reduce the memory
            usage for constructing and solving the NLP.
            
            True: LocalDAECollocator builds the NLP with packed functions that
            are called for every element.
            
            False: LocalDAECollocator builds the NLP with common CasADi functions
            that are called for every collocation point in each element.
            
            Type: bool
            Default: False
        
        eliminate_der_var --
            True: The variables representing the derivatives are eliminated
            via the collocation equations and are thus not a part of the NLP,
            with the exception of \dot{x}_{1, 0}, which is not eliminated since
            the collocation equations are not enforced at t_0.
            
            False: The variables representing the derivatives are kept as NLP
            variables and the collocation equations enter as constraints.
            
            Type: bool
            Default: False
        
        eliminate_cont_var --
            True: Let the same variables represent both the values of the
            states at the start of each element and the end of the previous
            element.
            
            False:
            For Radau collocation, the extra variables x_{i, 0}, representing
            the states at the start of each element, are created and then
            constrained to be equal to the corresponding variable at the end of
            the previous element for continuity.
            
            For Gauss collocation, the extra variables x_{i, n_cp + 1},
            representing the states at the end of each element, are created
            and then constrained to be equal to the corresponding variable at
            the start of the succeeding element for continuity.
            
            Type: bool
            Default: False

        mutable_external_data --
            True: If the external_data option is used, the external data
            can be changed after discretization, e.g. during warm starting.

            Type: bool
            Default: True

        explicit_hessian --
            Explicitly construct the Lagrangian Hessian, rather than rely on
            CasADi to automatically generate it. This is only done to
            circumvent a bug in CasADi, see #4313, which rarely causes the
            automatic Hessian to be incorrect.

            Type: bool
            Default: False

        order --
            Order of variables and equations. Requires write_scaled_result!

            Possible values: "default", "reverse", and "random"

            Type: str
            Default: "default"

    Options are set by using the syntax for dictionaries::

        >>> opts = my_model.optimize_options()
        >>> opts['n_e'] = 100
    
    Options for the nonlinear programming solver can be provided in the option
    <solver name>_options, using the syntax for dictionaries::
        
        >>> opts['IPOPT_options']['max_iter'] = 500
    """
    
    def __init__(self, *args, **kw):
        _defaults = {
                'n_e': 50,
                'hs': None,
                'free_element_lengths_data': None,
                'h_bounds': (0.7, 1.3),
                'n_cp': 3,
                'discr': "LGR",
                'expand_to_sx': "NLP",
                'named_vars': False,
                'init_traj': None,
                'init_dual': None,
                'variable_scaling': True,
                'variable_scaling_allow_update': False,
                'equation_scaling': False,
                'nominal_traj': None,
                'nominal_traj_mode': {"_default_mode": "linear"},
                'result_file_name': "",
                'write_scaled_result': False,
                'print_condition_numbers': False,
                'result_mode': "collocation_points",
                'n_eval_points': 20,
                'blocking_factors': None,
                'quadrature_constraint': True,
                'eliminate_der_var': False,
                'eliminate_cont_var': False,
                'external_data': None,
                'mutable_external_data': True,
                'checkpoint': False,
                'delayed_feedback': None,
                'solver': 'IPOPT',
                'verbosity': 3,
                'explicit_hessian': False,
                'order': "default",
                'IPOPT_options': {'dual_inf_tol': 1e100,
                                  'constr_viol_tol': 1e100,
                                  'compl_inf_tol': 1e100,
                                  'acceptable_dual_inf_tol': 1e100,
                                  'acceptable_constr_viol_tol': 1e100,
                                  'acceptable_compl_inf_tol': 1e100},
                'WORHP_options': {}}
        
        super(LocalDAECollocationAlgOptions, self).__init__(_defaults)
        self._update_keep_dict_defaults(*args, **kw)
            
class MPCAlgResult(JMResultBase):
    def __init__(self, model=None, result_file_name=None, solver=None, 
                 result_data=None, options=None, times=None, nbr_samp=None, 
                 sample_period = None):
        super(MPCAlgResult, self).__init__(
                model, result_file_name, solver, result_data, options)

              
        #Print times 
        print("\nTotal time for %s samples (average time in parenthesis)." 
                %(nbr_samp))
        print("\nInitialization time: %.2f seconds" %times['init'])
        print("\nTotal time: %.2f seconds             (%.3f)" % (times['tot'], 
                times['tot']/(nbr_samp)))
        print("Pre-processing time: %.2f seconds    (%.3f)" % (times['update'],
                times['update']/(nbr_samp)))
        print("Solution time: %.2f seconds          (%.3f)" % (times['sol'], 
                times['sol']/(nbr_samp)))
        print("Post-processing time: %.2f seconds   (%.3f)" % 
                (times['post_processing'], times['post_processing']/(nbr_samp)))
        print("\nLargest total time for one sample (nbr %s): %.2f seconds" %
                (times['maxSample'], times['maxTime']))
        print("The sample period is %.2f seconds\n" %sample_period)
