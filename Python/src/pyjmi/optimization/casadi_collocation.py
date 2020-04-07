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

import struct
import logging
import codecs
import operator
import itertools
import time
import copy
import types
import math
import os
from os import system, path
from operator import sub
from collections import OrderedDict, Iterable
from scipy.sparse import csc_matrix, csr_matrix

try:
    import casadi
    import casadi.tools as ct
except ImportError:
    logging.warning('Could not find CasADi package, aborting.')
import numpy as N

from pyjmi.optimization.polynomial import *
from pyjmi.common import xmlparser
from pyjmi.common.xmlparser import XMLException
from pyjmi.common.core import TrajectoryLinearInterpolation
from pyjmi.common.core import TrajectoryUserFunction

from pyjmi.common.io import VariableNotFoundError as jmiVariableNotFoundError
from pyjmi.casadi_interface import convert_casadi_der_name

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

from pyjmi.common.algorithm_drivers import JMResultBase
from pyjmi.common.io import ResultDymolaTextual

class CasadiCollocatorException(Exception):
    """
    A CasadiCollocator Exception.
    """
    pass

class CasadiCollocator(object):

    """
    Base class for implementation of collocation algorithms using CasadiModel.
    """

    UPPER = N.inf
    LOWER = -N.inf

    def __init__(self, model):
        # Store model and OCP object
        self.model = model
        self.ocp = model.get_casadi_ocp()

        # Update dependent parameters
        casadi.updateDependent(self.ocp)

        # Check if minimum time normalization has occured
        t0 = self.ocp.variable('startTime')
        tf = self.ocp.variable('finalTime')
        if (t0.getFree() and not self.ocp.t0_free or
            tf.getFree() and not self.ocp.tf_free):
            self._normalize_min_time = True
        else:
            self._normalize_min_time = False

        # Get start and final time
        if self._normalize_min_time:
            self.t0 = self.ocp.t0
            self.tf = self.ocp.tf
        else:
            self.t0 = t0.getStart()
            self.tf = tf.getStart()

        # Update OCP expressions
        self.model.update_expressions()

    def get_model(self):
        return self.model

    def get_model_description(self):
        return self.get_model().get_model_description()

    def get_cost(self):
        raise NotImplementedError

    def get_var_indices(self):
        return self.var_indices

    def get_time(self):
        return self.time

    def get_time_points(self):
        return self.time_points

    def get_xx(self):
        return self.xx

    def get_n_xx(self):
        return self.n_xx

    def get_xx_lb(self):
        return self.xx_lb

    def get_xx_ub(self):
        return self.xx_ub

    def get_xx_init(self):
        return self.xx_init

    def get_hessian(self):
        return None

    def get_inequality_constraint(self):
        """
        Get the inequality constraint g(x) <= 0.0
        """
        return casadi.SX()

    def get_equality_constraint(self):
        """
        Get the equality constraint h(x) = 0.0
        """
        return casadi.SX()

    def set_solver_option(self, k, v):
        """
        Sets nonlinear programming solver options.

            Parameters::

                k - Name of the option
                v - Value of the option (int, double, string)
        """
        self.solver_object.setOption(k,v)

    def _get_xml_variable_by_name(self, name):
        """
        Helper function for getting an XML variable by name.

        This method does not really belong here...
        """
        variables = self.model.xmldoc.get_model_variables()
        for var in variables:
            if var.get_name() == name:
                return var
        raise XMLException("Could not find XML variable with name: %s" % name)

    def export_result_dymola(self, file_name='', format='txt', 
                             write_scaled_result=False):
        """
        Export an optimization or simulation result to file in Dymolas result file 
        format. The parameter values are read from the z vector of the model object 
        and the time series are read from the data argument.

        Parameters::

            file_name --
                If no file name is given, the name of the model (as defined by 
                casadiModel.get_name()) concatenated with the string '_result' is used. 
                A file suffix equal to the format argument is then appended to the 
                file name.
                Default: Empty string.

            format --
                A text string equal either to 'txt' for textual format or 'mat' for 
                binary Matlab format.
                Default: 'txt'

            write_scaled_result --
                Set this parameter to True to write the result to file without
                taking scaling into account. If the value of write_sacled_result
                is False, then the variable scaling factors of the model are
                used to reproduced the unscaled variable values.
                Default: False

        Limitations::

            Currently only textual format is supported.
        """
        (t,dx_opt,x_opt,u_opt,w_opt,p_opt) = self.get_result()
        data = N.hstack((t,dx_opt,x_opt,u_opt,w_opt))

        if (format=='txt'):

            if file_name=='':
                file_name=self.model.get_identifier() + '_result.txt'

            # Open file
            f = codecs.open(file_name,'w','utf-8')

            # Write header
            f.write('#1\n')
            f.write('char Aclass(3,11)\n')
            f.write('Atrajectory\n')
            f.write('1.1\n')
            f.write('\n')

            md = self.model.get_model_description()

            # NOTE: it is essential that the lists 'names', 'aliases', 'descriptions' 
            # and 'variabilities' are sorted in the same order and that this order 
            # is: value reference order AND within the same value reference the 
            # non-alias variable must be before its corresponding aliases. Otherwise 
            # the header-writing algorithm further down will fail.
            # Therefore the following code is needed...

            # all lists that we need for later
            vrefs_alias = []
            vrefs = []
            names_alias = []
            names = []
            names_noalias = []
            aliases_alias = []
            aliases = []
            descriptions_alias = []
            descriptions = []
            variabilities_alias = []
            variabilities = []
            variabilities_noalias = []

            # go through all variables and split in non-alias/only-alias lists
            for var in md.get_model_variables():
                if var.get_alias() == xmlparser.NO_ALIAS:
                    vrefs.append(var.get_value_reference())
                    names.append(var.get_name())
                    aliases.append(var.get_alias())
                    descriptions.append(var.get_description())
                    variabilities.append(var.get_variability())
                else:
                    vrefs_alias.append(var.get_value_reference())
                    names_alias.append(var.get_name())
                    aliases_alias.append(var.get_alias())
                    descriptions_alias.append(var.get_description())
                    variabilities_alias.append(var.get_variability())

            # extend non-alias lists with only-alias-lists
            vrefs.extend(vrefs_alias)
            names.extend(names_alias)
            aliases.extend(aliases_alias)
            descriptions.extend(descriptions_alias)
            variabilities.extend(variabilities_alias)

            # start values (used in parameter writing)
            start = md.get_variable_start_attributes()
            start_values = dict([(start[i][0], start[i][1]) for i in range(len(start))])

            # if some parameters were optimized, store that value
            vr_map = self.model.get_vr_map()
            for var in self.ocp.pf:
                try:
                    vr = var.getValueReference()
                    start_values[vr] = p_opt[vr_map[vr][0]]
                except KeyError:
                    pass
            # add and calculate the dependent parameters
            for (_, vr, val) in self.model.get_pd_val():
                try:
                    start_values[vr] = val
                except KeyError:
                    pass

            # zip to list of tuples and sort - non alias variables are now
            # guaranteed to be first in list and all variables are in value reference 
            # order
            names = sorted(zip(
                tuple(vrefs), 
                tuple(names)), 
                           key=operator.itemgetter(0))
            aliases = sorted(zip(
                tuple(vrefs), 
                tuple(aliases)), 
                             key=operator.itemgetter(0))
            descriptions = sorted(zip(
                tuple(vrefs), 
                tuple(descriptions)), 
                                  key=operator.itemgetter(0))
            variabilities = sorted(zip(
                tuple(vrefs), 
                tuple(variabilities)), 
                                   key=operator.itemgetter(0))

            num_vars = len(names)

            # Find the maximum name and description length
            max_name_length = len('Time')
            max_desc_length = len('Time in [s]')

            for i in range(len(names)):
                name = names[i][1]
                desc = descriptions[i][1]

                if (len(name)>max_name_length):
                    max_name_length = len(name)

                if (len(desc)>max_desc_length):
                    max_desc_length = len(desc)

            f.write('char name(%d,%d)\n' % (num_vars + 1, max_name_length))
            f.write('time\n')

            # write names
            for name in names:
                f.write(name[1] +'\n')

            f.write('\n')

            f.write('char description(%d,%d)\n' % (num_vars + 1, max_desc_length))
            f.write('Time in [s]\n')

            # write descriptions
            for desc in descriptions:
                f.write(desc[1]+'\n')

            f.write('\n')

            # Write data meta information
            f.write('int dataInfo(%d,%d)\n' % (num_vars + 1, 4))
            f.write('0 1 0 -1 # time\n')

            cnt_1 = 1
            cnt_2 = 1

            n_parameters = 0
            params = []

            for i, name in enumerate(names):
                if variabilities[i][1] == xmlparser.PARAMETER or \
                   variabilities[i][1] == xmlparser.CONSTANT:
                    if aliases[i][1] == 0: # no alias
                        cnt_1 = cnt_1 + 1
                        n_parameters += 1
                        params += [name]
                        f.write('1 %d 0 -1 # ' % cnt_1 + name[1]+'\n')
                    else: # alias
                        if aliases[i][1] == 1:
                            neg = 1
                        else:
                            neg = -1 # negated alias
                        var = self._get_xml_variable_by_name(name[1])
                        if var.get_alias():
                            # Check whether the alias has the same variability
                            var_ali = md.get_aliases_for_variable(name[1])[0]
                            for aliass in var_ali:
                                aliass_var = \
                                    self._get_xml_variable_by_name(aliass)
                                if not aliass_var.get_alias():
                                    variab = aliass_var.get_variability()
                                    if (variab != xmlparser.PARAMETER and
                                        variab != xmlparser.CONSTANT):
                                        f.write('2 %d 0 -1 # ' % (neg*cnt_2) +
                                                name[1] +'\n')
                                    else:
                                        f.write('1 %d 0 -1 # ' % (neg*cnt_1) +
                                                name[1] +'\n')
                        else:
                            f.write('1 %d 0 -1 # ' % (neg*cnt_1) +
                                    name[1] +'\n')
                else:
                    if aliases[i][1] == 0: # noalias
                        cnt_2 = cnt_2 + 1
                        f.write('2 %d 0 -1 # ' % cnt_2 + name[1] +'\n')
                    else: # alias
                        if aliases[i][1] == 1:
                            neg = 1
                        else:
                            neg = -1 # negated alias
                        var = self._get_xml_variable_by_name(name[1])
                        if var.get_alias():
                            # Check whether the alias has the same variability
                            var_ali = md.get_aliases_for_variable(name[1])[0]
                            for aliass in var_ali:
                                aliass_var = \
                                    self._get_xml_variable_by_name(aliass)
                                if not aliass_var.get_alias():
                                    variab = aliass_var.get_variability()
                                    if (variab == xmlparser.PARAMETER or
                                        variab == xmlparser.CONSTANT):
                                        f.write('1 %d 0 -1 # ' % (neg*cnt_1) +
                                                name[1] +'\n')
                                    else:
                                        f.write('2 %d 0 -1 # ' % (neg*cnt_2) +
                                                name[1] +'\n')
                        else:
                            f.write('2 %d 0 -1 # ' % (neg*cnt_2) +
                                    name[1] +'\n')
            f.write('\n')

            # Write data
            # Write data set 1
            f.write('float data_1(%d,%d)\n' % (2, n_parameters + 1))
            f.write("%.14E" % data[0,0])
            str_text = ''
            for i in params:
                str_text += " %.14E" % (start_values[i[0]])#(0.0)#(z[ref])

            f.write(str_text)
            f.write('\n')
            f.write("%.14E" % data[-1,0])
            f.write(str_text)

            f.write('\n\n')

            # Write data set 2
            n_vars = len(data[0,:])
            n_points = len(data[:,0])
            f.write('float data_2(%d,%d)\n' % (n_points, n_vars))
            for i in range(n_points):
                str_text = ''
                for ref in range(n_vars):
                    str_text = str_text + (" %.14E" % data[i,ref])
                f.write(str_text+'\n')

            f.write('\n')

            f.close()

        else:
            raise Error('Export on binary Dymola result files not yet ' +
                        'supported.')

    def get_result(self):
        t_opt = self.get_time().reshape([-1, 1])
        dx_opt = N.empty([len(t_opt), self.model.get_n_x()])
        x_opt = N.empty([len(t_opt), self.model.get_n_x()])
        w_opt = N.empty([len(t_opt), self.model.get_n_w()])
        u_opt = N.empty([len(t_opt), self.model.get_n_u()])
        p_opt  = N.empty(self.model.get_n_p())

        p_opt[:] = self.primal_opt[self.get_var_indices()['p_opt']][:, 0]

        cnt = 0
        var_indices = self.get_var_indices()
        for i in xrange(1, self.n_e + 1):
            for k in self.time_points[i].keys():
                dx_opt[cnt, :] = self.primal_opt[var_indices[i][k]['dx']][:, 0]
                x_opt[cnt, :] = self.primal_opt[var_indices[i][k]['x']][:, 0]
                u_opt[cnt, :] = self.primal_opt[var_indices[i][k]['u']][:, 0]
                w_opt[cnt, :] = self.primal_opt[var_indices[i][k]['w']][:, 0]
                cnt += 1
        return (t_opt, dx_opt, x_opt, u_opt, w_opt, p_opt)

    def get_opt_input(self):
        """
        Get the optimized input variables as a function of time.

        The purpose of this method is to conveniently provide the optimized
        input variables to a simulator.

        Returns::

            input_names --
                Tuple consisting of the names of the input variables.

            input_interpolator --
                Collocation polynomials for input variables as a function of
                time.
        """
        # Consider: do we actually need to save _xi, _ti, and _hi in self?
        if self.hs == "free":
            self._hi = map(lambda h: self.horizon * h, self.h_opt)
        else:
            self._hi = map(lambda h: self.horizon * h, self.h)
        self._xi = self._u_opt[1:].reshape(self.n_e, self.n_cp, self.model.n_u)
        self._ti = N.cumsum([self.t0] + self._hi[1:])
        input_names = tuple([repr(u) for u in self.model.u])
        return (input_names, self._create_input_interpolator(self._xi, self._ti, self._hi))

    def _create_input_interpolator(self, xi, ti, hi):
        def _input_interpolator(t):
            i = N.clip(N.searchsorted(ti, t), 1, self.n_e)
            tau = (t - ti[i - 1]) / hi[i]

            x = 0
            for k in xrange(self.n_cp):
                x += xi[i - 1, k, :] * self.pol.eval_basis(k + 1, tau, False)
            return x
        return _input_interpolator

    def get_solver_statistics(self):
        """ 
        Get nonlinear programming solver statistics.

        Returns::

            return_status -- 
                Return status from nonlinear programming solver.

            nbr_iter -- 
                Number of iterations.

            objective -- 
                Final value of objective function.

            total_exec_time -- 
                Nonlinear programming solver execution time.
        """
        stats = self.solver_object.getStats()
        nbr_iter = stats['iter_count']
        objective = float(self.solver_object.output(casadi.NLP_SOLVER_F))
        total_exec_time = stats['t_mainloop']
        
        # 'Maximum_CPU_Time_Exceeded' and 'Feasible_Point_for_Square_Problem_Found' fail
                # to fill in stats['return_status'].
        if (self.solver_object.hasSetOption('max_cpu_time') and
            total_exec_time >= self.solver_object.getOption('max_cpu_time')):
            return_status = 'Maximum_CPU_Time_Exceeded'
        else:
            try:
                return_status = stats['return_status']
            except KeyError:
                return_status = 'Feasible_Point_for_Square_Problem_Found'
        return (return_status, nbr_iter, objective, total_exec_time)

    def _update_equation_scaling(self):
        """
        Update the equation scaling based on the residual Jacobian 
        """
        # Set all equation scalings to 1 initially
        offset = self.pp_offset['equation_scale']
        self._par_vals[offset:offset + self.n_c] = 1

        # Evaluate the Jacobian
        self.residual_jac_fcn.setInput(self.xx_init, casadi.NLP_SOLVER_X0)
        self.residual_jac_fcn.setInput(self._par_vals, casadi.NLP_SOLVER_P)
        self.residual_jac_fcn.evaluate()
        J = self.residual_jac_fcn.getOutput(0)
        J = csr_matrix(J.toCsc_matrix())
        
        # Row-wise maximum
        row_norms = N.maximum.reduceat(N.hstack((N.abs(J.data), 0)), J.indptr[0:-1])
        row_norms[N.diff(J.indptr) == 0] = 0
        # Set nonfinite row norms to 1
        row_norms[row_norms != row_norms] = 1

        # Calculate scales from row norms
        scales = N.maximum(1e-8, N.minimum(1, 100/row_norms))

        # Store the updated scaling factors
        self._par_vals[offset:offset + self.n_c] = scales

    def solve_nlp(self):
        """
        Calls the nonlinear programming solver.

        Returns::

            sol_time --
                Duration (seconds) of call to nonlinear programming solver.
                Type: float
        """
        t0_update = time.clock()
        if self.equation_scaling:
            self._update_equation_scaling()
        # Initialize solver
        if self.warm_start:
            # Initialize primal variables and set parameters
            self.solver_object.setInput(self.get_xx_init(), casadi.NLP_SOLVER_X0)
            self.solver_object.setInput(self._get_par_vals(),     casadi.NLP_SOLVER_P)

            # Initialize dual variables
            # The stored dual variables are unscaled, so that we can change
            # the scaling without invalidating them
            self.solver_object.setInput(self._inv_scale_residuals(self.dual_opt['g']),
                                        casadi.NLP_SOLVER_LAM_G0)
            self.solver_object.setInput(self.dual_opt['x'],
                                        casadi.NLP_SOLVER_LAM_X0)
        else:
            self._init_and_set_solver_inputs()
        # Solve the problem
        t0 = time.clock()
        self.extra_update = t0-t0_update
        self.times['update'] += self.extra_update # should be reset by warm start framework in each optimize, allows adding more update time from that
        self.solver_object.evaluate()

        # Get the result
        primal_opt = N.array(self.solver_object.output(casadi.NLP_SOLVER_X))
        self.primal_opt = primal_opt.reshape(-1)
        if self.order != "default":
            self.primal_opt = self.primal_opt[self.var_ordering]
        dual_g_opt = N.array(self.solver_object.output(casadi.NLP_SOLVER_LAM_G))
        # The stored dual variables are unscaled, so that we can change
        # the scaling without invalidating them
        dual_g_opt = self._scale_residuals(dual_g_opt.reshape(-1))
        dual_x_opt = N.array(self.solver_object.output(casadi.NLP_SOLVER_LAM_X))
        dual_x_opt = dual_x_opt.reshape(-1)
        self.dual_opt = {'g': dual_g_opt, 'x': dual_x_opt}
        sol_time = time.clock() - t0
        return sol_time

    def _calc_Lagrangian_Hessian(self):
        """
        Calculate the Hessian of the NLP Lagrangian.

        CasADi normally does this automatically, but in rare cases it does not
        work correctly. This is a workaround. See #4313
        """
        # Lagrange multipliers and objective function scaling
        unknown = casadi.MX.sym("unknown", 0)
        sigma = casadi.MX.sym("sigma")
        lam = casadi.MX.sym("lambda", self.c_e.numel() + self.c_i.numel())
        
        # Lagrangian
        constraints = casadi.vertcat([self.get_equality_constraint(),
                                      self.get_inequality_constraint()])
        lag_exp = sigma * self.cost + casadi.inner_prod(lam, constraints)
        L = casadi.MXFunction([self.xx, self.pp, sigma, lam], [lag_exp])
        L.init()

        # Calculate Hessian
        H_exp = casadi.jacobian(L.grad(), self.xx)
        self.H = casadi.MXFunction([self.xx, self.pp, sigma, lam], [H_exp, H_exp, H_exp, H_exp, H_exp])
        self.H.init()
        
    def _init_and_set_solver_inputs(self):
        # self.solver_object.init() # Already done in LocalDAECollocationAlg constructor

        # Primal initial guess and parameter values
        self.solver_object.setInput(self.get_xx_init(), casadi.NLP_SOLVER_X0)
        self.solver_object.setInput(self._get_par_vals(), casadi.NLP_SOLVER_P)

        # Dual initial guess
        if self.init_dual is not None:
            self.solver_object.setInput(self.init_dual['g'],
                                        casadi.NLP_SOLVER_LAM_G0)
            self.solver_object.setInput(self.init_dual['x'],
                                        casadi.NLP_SOLVER_LAM_X0)

        # Bounds on x
        self.solver_object.setInput(self.get_xx_lb(), casadi.NLP_SOLVER_LBX)
        self.solver_object.setInput(self.get_xx_ub(), casadi.NLP_SOLVER_UBX)

        # Bounds on the constraints
        self.solver_object.setInput(self._scale_residuals(self.gllb), casadi.NLP_SOLVER_LBG)
        self.solver_object.setInput(self._scale_residuals(self.glub), casadi.NLP_SOLVER_UBG)


def _create_trajectory_function(data):
    """
    Create an interpolation function from user supplied external data.

    The format of data is the same as expected for the data items in external_data.
    Returns a TrajectoryUserFunction or TrajectoryLinearInterpolation instance.
    """
    if (isinstance(data, types.FunctionType) or
        hasattr(data, '__call__')):
        return TrajectoryUserFunction(data)
    else:
        if data.shape[0] != 2:
            raise ValueError("If variable data is not a " +
                             "function, it must be a matrix " +
                             "with exactly two rows.")
        return TrajectoryLinearInterpolation(
            data[0], data[1].reshape([-1, 1]))

class ExternalData(object):

    """
    External data connected to variables.

    The data can for each variable be treated in three different ways.

    eliminated --
        The data for these inputs is used to eliminate the corresponding NLP
        variables.

    quad_pen --
        The NLP variables are kept, but a quadratic penalty on the deviation
        from the data is introduced.

    constr_quad_pen --
        The NLP variables are kept, but a quadratic penalty on the deviation
        from the data is introduced, as well as an equality constraint.

    eliminated and constr_quad_pen must be inputs, whereas quad_pen can be any
    kind of variable.

    The data for each variable is either a user-defined function of time, or
    a matrix with two rows where the first row is points in time and the
    second row is values for the variable at the corresponding points in time.
    In the second case, the given data is linearly interpolated to get the
    values at the collocation points.
    """

    def __init__(self, eliminated=OrderedDict(), quad_pen=OrderedDict(),
                 constr_quad_pen=OrderedDict(), Q=None):
        """
        The following quadratic cost is formed:

        .. math::

            f = \int_{t_0}^{t_f} (y(t) - y_m(t)) \cdot Q \cdot
            (y(t) - y_m(t))\,\mathrm{d}t,

        where y is the function created by gluing together the
        collocation polynomials for the variables with quadratic penalties at
        all the mesh points and y_m is a function providing the measured
        values at a given time point. If the variable data are a matrix, the
        data are linearly interpolated to create the function y_m. If the data
        are a function, then this function defines y_m.

        Parameters::

            eliminated --
                Ordered dictionary with variable names as keys and the values
                are the corresponding data used to eliminate the inputs.

                Type: OrderedDict
                Default: OrderedDict()

            quad_pen --
                Ordered dictionary with variable names as keys and the values
                are the corresponding data used to penalize the inputs.

                Type: OrderedDict
                Default: OrderedDict()

            constr_quad_pen --
                Dictionary with variable names as keys and the values are the
                corresponding data used to constraint and penalize the
                variables.

                Type: OrderedDict
                Default: OrderedDict()

            Q --
                Weighting matrix used to form the quadratic penalty for the
                uneliminated variables. The order of the variables is the same
                as the ordered dictionaries constr_quad_pen and quad_pen,
                with the constrained inputs coming first.

                Type: rank 2 ndarray
                Default: None
        """
        # Check dimension of Q
        Q_len = ((0 if constr_quad_pen is None else len(constr_quad_pen)) + 
                 (0 if quad_pen is None else len(quad_pen)))
        if Q_len > 0 and (Q.shape[0] != Q.shape[1] or Q.shape[0] != Q_len):
            raise ValueError("Weighting matrix Q must be square and have " +
                             "the same dimension as the total number of " +
                             "penalized variables.")

        # Transform data into trajectories
        eliminated = copy.deepcopy(eliminated)
        constr_quad_pen = copy.deepcopy(constr_quad_pen)
        quad_pen = copy.deepcopy(quad_pen)
        for variable_list in [eliminated, constr_quad_pen, quad_pen]:
            for (name, data) in variable_list.items():
                variable_list[name] = _create_trajectory_function(data)

        # Store data as attributes
        self.eliminated = eliminated
        self.constr_quad_pen = constr_quad_pen
        self.quad_pen = quad_pen
        self.Q = Q

class FreeElementLengthsData(object):

    """
    Data used to control the element lengths when they are free.

    The objective function f is adjusted to penalize large element lengths for
    elements with high state derivatives, resulting in the augmented objective
    function \hat{f} defined as follows:

    .. math::

        \hat{f} = f + c \cdot \sum_{i = 1}^{n_e} \left(h_i^a \cdot 
        \int_{t_i}^{t_{i+1}} \dot{x}(t) \cdot Q \cdot
        \dot{x}(t)\,\mathrm{d}t\right).
    """

    def __init__(self, c, Q, bounds=(0.7, 1.3), a=1.):
        """
        Parameters::

            c --
                The coefficient for the newly introduced cost term.

                Type: float

            Q --
                The coefficient matrix for weighting the various state
                derivatives.

                Type: ndarray with shape (n_x, n_x)

            bounds --
                Element length bounds. The bounds are given as a tuple (l, u),
                where the bounds are used in the following way:

                .. math::
                    l / n_e \leq h_i \leq u / n_e, \quad\forall i \in [1, n_e],

                where h_i is the normalized length of element i.

                Type: tuple
                Default: (0.7, 1.3)

            a --
                The exponent of the element length.

                Type: float
                Default: 1.
        """
        self.bounds = bounds
        self.c = c
        self.Q = Q
        self.a = a

class BlockingFactors(object):

    """
    Class used to specify blocking factors for CasADi collocators.

    This is used to enforce piecewise constant inputs. The inputs may only
    change at some element boundaries, specified by the blocking factors.

    This also enables the introduction of bounds and quadratic penalties on the
    difference of the inputs between element boundaries.
    """

    def __init__(self, factors, du_bounds={}, du_quad_pen={}):
        """
        Parameters::
            
            factors --
                Dictionary with variable names as keys and list of blocking
                factors as corresponding values.

                The blocking factors should be list of ints. Each element in
                the list specifies the number of collocation elements for which
                the input must be constant. For example, if blocking_factors ==
                [2, 2, 1], then the input will attain 3 different values
                (number of elements in the list), and it will change values
                between element number 2 and 3 and number 4 and 5. The sum of
                all elements in the list must be the same as the number of
                collocation elements and the length of the list determines the
                number of separate values that the inputs may attain.
                
                Type: {string: [int]}
            
            du_bounds --
                Dictionary with variables names as keys and bounds on the
                absolute value of the change in the corresponding input between
                the blocking factors.
                
                Type: {string: float}
                Default: {}

            du_quad_pen --
                This parameter adds a quadratic penalty on the change in u
                between blocking factors.
                
                The parameter should be a dictionary with variables names as
                keys. The values are the weights for the penalty term of the
                corresponding variable.

                Type: {string: float}
                Default: {}
        """
        # Check that factors exist for variables with bounds and penalties
        for name in du_bounds.keys():
            if name not in factors.keys():
                raise ValueError('Bound provided for variable %s' % name +
                                 'but no factors.')
        for name in du_quad_pen.keys():
            if name not in factors.keys():
                raise ValueError('Penalty weight provided for variable ' +
                                 '%s but no factors.' % name)

        # Store parameters as attributes
        self.factors = factors
        self.du_bounds = du_bounds
        self.du_quad_pen = du_quad_pen

class LocalDAECollocator(CasadiCollocator):

    """Solves a dynamic optimization problem using local collocation."""

    def __init__(self, op, options):
        # Check if init_traj is a JMResult
        try:
            options['init_traj'] = options['init_traj'].result_data
        except AttributeError:
            pass

        # Check if nominal_traj is a JMResult
        try:
            options['nominal_traj'] = options['nominal_traj'].result_data
        except AttributeError:
            pass

        # Get the options
        self.__dict__.update(options)
        self.options = options # save the options for the result object
        self.times = {}
        t0_init = time.clock()

        # Store OptimizationProblem object
        self.op = op

        # Evaluate dependent parameters
        op.calculateValuesForDependentParameters()

        # Check if minimum time normalization has occured
        t0 = op.getVariable('startTime')
        tf = op.getVariable('finalTime')
        if op.get_attr(t0, "free") or op.get_attr(tf, "free"):
            if not op.getNormalizedTimeFlag():
                # Change this once #3438 has been fixed
                raise CasadiCollocatorException(
                    "Problems with free time horizons are only " +
                    "supported if time has been normalized.")
            self._normalize_min_time = True
        else:
            self._normalize_min_time = False

        # Get start and final time
        if self._normalize_min_time:
            self.t0 = op.getStartTime().getValue()
            self.tf = op.getFinalTime().getValue()
        else:
            self.t0 = op.get_attr(t0, "_value")
            self.tf = op.get_attr(tf, "_value")

        # Define element lengths
        self.horizon = self.tf - self.t0
        if self.hs != "free":
            self.h = [N.nan] # Element 0
            if self.hs is None:
                self.h += self.n_e * [1. / self.n_e]
            else:
                self.h += list(self.hs)

        # Define polynomial for representation of solutions
        if self.discr == "LG":
            self.pol = GaussPol(self.n_cp)
        elif self.discr == "LGR":
            self.pol = RadauPol(self.n_cp)
        else:
            raise CasadiCollocatorException("Unknown discretization scheme %s."
                                            % self.discr)
        self.warm_start = False
        # Get to work
        self._create_nlp()

        # Create the canonical OptimizationSolver that should always be used
        # to work against this collocator instance
        self.wrapper = OptimizationSolver(self)

        self.times['init'] = time.clock() - t0_init 
        self.times['update'] = 0
        
    def solve_and_write_result(self):
        """
        Solve the nonlinear program and write the results to a file.
        Called e.g. by LocalDAECollocationAlg.solve.
        """
        t0 = time.clock()
        # todo: account for preprocessing time within solve_nlp separately?
        self.times['sol'] = self.solve_nlp()
        self.result_file_name = self.export_result_dymola(self.result_file_name)
        self.times['post_processing'] = time.clock() - t0 - self.times['sol'] - self.extra_update

    def get_result_object(self, include_init = True):
        """ 
        Load result data saved in e.g. solve_and_write_result and create a LocalDAECollocationAlgResult object.

        Returns::

            The LocalDAECollocationAlgResult object.
        """
        t0 = time.clock()
        resultfile = self.result_file_name
        res = ResultDymolaTextual(resultfile)

        # Get optimized element lengths
        h_opt = self.get_h_opt()
    
        self.times['post_processing'] += time.clock() - t0
        self.times['tot'] = self.times['update'] + self.times['sol'] + self.times['post_processing']
        
        if include_init:
            self.times['tot'] += self.times['init']
            
        # Create and return result object
        return LocalDAECollocationAlgResult(self.op, resultfile, self,
                                            res, self.options, self.times,
                                            h_opt)

    def _create_nlp(self):
        """
        Wrapper for creating the NLP.
        """
        self._create_model_variable_structures()
        self._scale_variables()
        self._define_collocation()
        self._create_nlp_variables()
        self._count_constraints()
        self._create_constraints_and_cost()
        self._create_blocking_factors_constraints_and_cost()
        self._compute_bounds_and_init()
        self._assemble_back_tracking_info()
        self._create_solver()

    def _create_model_variable_structures(self):
        """
        Create model variable structures.

        Create vectorized model variables unless named_vars is enabled.
        """
        # Get model variable vectors
        op = self.op
        var_kinds = {'dx': op.DERIVATIVE,
                     'x': op.DIFFERENTIATED,
                     'u': op.REAL_INPUT,
                     'w': op.REAL_ALGEBRAIC}
        mvar_vectors = {'dx': N.array([var for var in
                                       op.getVariables(var_kinds['dx'])
                                       if (not var.isAlias() and not var.wasEliminated())]),
                        'x': N.array([var for var in
                                      op.getVariables(var_kinds['x'])
                                      if (not var.isAlias() and not var.wasEliminated())]),
                        'u': N.array([var for var in
                                      op.getVariables(var_kinds['u'])
                                      if (not var.isAlias() and not var.wasEliminated())]),
                        'w': N.array([var for var in
                                      op.getVariables(var_kinds['w'])
                                      if (not var.isAlias() and not var.wasEliminated())])}

        # Count variables (uneliminated inputs and free parameters are counted
        # later)
        n_var = {'dx': len(mvar_vectors["dx"]),
                 'x': len(mvar_vectors["x"]),
                 'u': len(mvar_vectors["u"]),
                 'w': len(mvar_vectors["w"])}

        # Exchange alias variables in external data
        if self.external_data is not None:
            eliminated = self.external_data.eliminated
            quad_pen = self.external_data.quad_pen
            constr_quad_pen = self.external_data.constr_quad_pen
            Q = self.external_data.Q
            variable_lists = [eliminated, quad_pen, constr_quad_pen]
            new_eliminated = OrderedDict()
            new_quad_pen = OrderedDict()
            new_constr_quad_pen = OrderedDict()
            new_variable_lists = [new_eliminated, new_quad_pen, new_constr_quad_pen]
            for i in xrange(3):
                for name in variable_lists[i].keys():
                    var = op.getVariable(name)
                    if var is None:
                        raise CasadiCollocatorException(
                            "Measured variable %s not " % name +
                            "found in model.")
                    if var.isAlias():
                        new_name = var.getModelVariable().getName()
                    else:
                        new_name = name
                    new_variable_lists[i][new_name] = variable_lists[i][name]
            self.external_data.eliminated = new_eliminated
            self.external_data.quad_pen = new_quad_pen
            self.external_data.constr_quad_pen = new_constr_quad_pen

        # Create eliminated and uneliminated input lists
        if (self.external_data is None or
            len(self.external_data.eliminated) == 0):
            elim_input_indices = []
        else:
            input_names = [u.getName() for u in mvar_vectors['u']]
            elim_names = self.external_data.eliminated.keys()
            elim_vars = [op.getModelVariable(elim_name)
                         for elim_name in elim_names]
            for (i, elim_var) in enumerate(elim_vars):
                if elim_var is None:
                    raise CasadiCollocatorException(
                        "Eliminated input %s is " % elim_names[i] +
                        "not a model variable.")
                if elim_var.getCausality() != elim_var.INPUT:
                    raise CasadiCollocatorException(
                        "Eliminated input %s is " % elim_var.getName() +
                        "not a model input.")
            elim_var_names = [elim_var.getName() for elim_var in elim_vars]
            elim_input_indices = [input_names.index(u) for u in elim_var_names]
        unelim_input_indices = [i for i in range(n_var['u']) if
                                i not in elim_input_indices]
        self._unelim_input_indices = unelim_input_indices
        self._elim_input_indices = elim_input_indices
        mvar_vectors["unelim_u"] = mvar_vectors['u'][unelim_input_indices]
        mvar_vectors["elim_u"] = mvar_vectors['u'][elim_input_indices]
        n_var['unelim_u'] = len(unelim_input_indices)
        n_var['elim_u'] = len(elim_input_indices)

        # Create lists of and count other external data variables
        if self.external_data is not None:
            for (vk, source) in (('constr_u', self.external_data.constr_quad_pen),
                                 ('quad_pen', self.external_data.quad_pen)):
                mvar_vectors[vk] = [op.getVariable(name) for (name, data) in source.iteritems()]
                n_var[vk] = len(mvar_vectors[vk])
        else:
            n_var['constr_u'] = n_var['quad_pen'] = 0

        # Create name map for external data
        if self.external_data is not None:
            self.external_data_name_map = {}
            for (vk, source) in (('elim_u', self.external_data.eliminated), 
                                 ('constr_u', self.external_data.constr_quad_pen),
                                 ('quad_pen', self.external_data.quad_pen)):
                for (j, name) in enumerate(source.iterkeys()):
                    self.external_data_name_map[name] = (j, vk)

        # Sort parameters
        par_kinds = [op.BOOLEAN_CONSTANT,
                     op.BOOLEAN_PARAMETER_DEPENDENT,
                     op.BOOLEAN_PARAMETER_INDEPENDENT,
                     op.INTEGER_CONSTANT,
                     op.INTEGER_PARAMETER_DEPENDENT,
                     op.INTEGER_PARAMETER_INDEPENDENT,
                     op.REAL_CONSTANT,
                     op.REAL_PARAMETER_INDEPENDENT,
                     op.REAL_PARAMETER_DEPENDENT]
        pars = reduce(list.__add__, [list(op.getVariables(par_kind)) for
                                     par_kind in par_kinds])
        mvar_vectors['p_fixed'] = [par for par in pars
                                   if not op.get_attr(par, "free")]
        n_var['p_fixed'] = len(mvar_vectors['p_fixed'])
        mvar_vectors['p_opt'] = [par for par in pars
                                 if op.get_attr(par, "free")]
        n_var['p_opt'] = len(mvar_vectors['p_opt'])

        # Create named symbolic variable structure
        named_mvar_struct = OrderedDict()
        named_mvar_struct["time"] = [op.getTimeVariable()]
        named_mvar_struct["x"] = [mvar.getVar() for mvar in mvar_vectors['x']]
        named_mvar_struct["unelim_u"] = \
            [mvar.getVar() for mvar in
             mvar_vectors['u'][unelim_input_indices]]
        named_mvar_struct["w"] = [mvar.getVar() for mvar in mvar_vectors['w']]
        named_mvar_struct["p_fixed"] = [mvar.getVar() for
                                        mvar in mvar_vectors['p_fixed']]
        named_mvar_struct["p_opt"] = [mvar.getVar() for
                                      mvar in mvar_vectors['p_opt']]
        named_mvar_struct["elim_u"] = \
            [mvar.getVar() for mvar in
             mvar_vectors['u'][elim_input_indices]]
        named_mvar_struct_dx = [mvar.getVar() for mvar in mvar_vectors['dx']]
        
        # Create structure for variable elimination handling
        elimination = casadi.MX()
        for var in op.getEliminatedVariables():
            elimination.append(op.getSolutionOfEliminatedVariable(var))        
        
        # Get optimization and model expressions
        initial = op.getInitialResidual()
        dae = op.getDaeResidual()
        path = casadi.vertcat([path_c.getResidual() for
                               path_c in op.getPathConstraints()])
        point = casadi.vertcat([point_c.getResidual() for
                                point_c in op.getPointConstraints()])
        mterm = op.getObjective()
        lterm = op.getObjectiveIntegrand()



        # Append name of variables into a list
        named_vars = reduce(list.__add__, named_mvar_struct.values() +
                            [named_mvar_struct_dx])           

        # Create data structure to handle different type of variables of the dynamic problem
        mvar_struct = OrderedDict()
        mvar_struct["time"] = casadi.MX.sym("time")
        mvar_struct["x"] = casadi.MX.sym("x", n_var['x'])
        mvar_struct["dx"] = casadi.MX.sym("dx", n_var['dx'])
        mvar_struct["unelim_u"] = casadi.MX.sym("unelim_u", n_var['unelim_u'])
        mvar_struct["w"] = casadi.MX.sym("w", n_var['w'])
        mvar_struct["elim_u"] = casadi.MX.sym("elim_u", n_var['elim_u'])
        mvar_struct["p_fixed"] = casadi.MX.sym("p_fixed", n_var['p_fixed'])
        mvar_struct["p_opt"] = casadi.MX.sym("p_opt", n_var['p_opt'])
        
        # Handy ordered structure for substitution
        svector_vars=[mvar_struct["time"]]


        # Create map from name to variable index and type
        name_map = {}
        for vt in ["x", "unelim_u", "w", "p_fixed", "p_opt", "elim_u", "dx"]:
            i = 0
            for var in mvar_vectors[vt]:
                name = var.getName()
                name_map[name] = (i, vt)
                svector_vars.append(mvar_struct[vt][i])
                i = i + 1
        
        # Add names to the eliminated variables
        i = 0
        for var in op.getEliminatedVariables():
            name = var.getName()
            name_map[name] = (i, "elim_var")
            i = i + 1

        # Substitute named variables with vector variables in expressions
        s_op_expressions = [initial, dae, path, point, mterm, lterm, elimination]
        [initial, dae, path, point, mterm, lterm, elimination] = casadi.substitute(
            s_op_expressions
            , named_vars, svector_vars)        
        self.mvar_struct = mvar_struct
        

        # Create BlockingFactors from self.blocking_factors
        if isinstance(self.blocking_factors, Iterable):
            factors = dict(zip(
                    [var.getName() for var in mvar_vectors['unelim_u']],
                    n_var['unelim_u'] * [self.blocking_factors]))
            self.blocking_factors = BlockingFactors(factors)

        # Store expressions and variable structures
        self.initial = initial
        self.dae = dae
        self.path = path
        self.point = point
        self.mterm = mterm
        self.lterm = lterm
        self.mvar_vectors = mvar_vectors
        self.n_var = n_var
        self.name_map = name_map
        self.elimination = elimination

    def _scale_variables(self):
        """
        Traditional variables scaling if there are no nominal trajectories.

        Timed variables are not scaled until _create_constraints, at
        which point the constraint points are known.
        """
        pass

    def _define_collocation(self):
        """
        Define collocation variables.

        The variables are used for either creating the collocation constraints
        or eliminating the derivative variables.
        """
        dx_i_k = [casadi.MX.sym("dx_i_k", self.n_var["x"])]
        h_i = casadi.MX.sym("h_i")
        x_i = [casadi.MX.sym("x_i", self.n_cp + 1, self.n_var["x"])]
        der_vals_k = casadi.MX.sym("der_vals[k]", self.n_cp + 1,
                                 self.n_var["x"])
        coll_der = casadi.sumRows(x_i[0] * der_vals_k) / h_i
        coll_der = [coll_der.T]
        coll_eq = casadi.sumRows(x_i[0]*der_vals_k) - h_i*dx_i_k[0].T
        coll_eq = coll_eq.T

        collocation = {}
        collocation['coll_der'] = coll_der
        collocation['coll_eq'] = coll_eq
        collocation['dx_i_k'] = dx_i_k
        collocation['x_i'] = x_i
        collocation['der_vals_k'] = der_vals_k
        collocation['h_i'] = h_i

        self._collocation = collocation

    def add_named_var(self, kind, var, i=-1, k=-1):
        """
        Append a named variable to named_xx/named_pp and record source information

        Should be called even if the named_vars option is off
        to record the source information.
        """
        if kind == 'xx':
            # Record back tracking information
            if var not in self.xx_dests:
                dest = self.xx_dests[var] = {'i':[], 'k':[], 'inds':[]}
            else:
                dest = self.xx_dests[var]

            dest['i'].append(i)
            dest['k'].append(k)
            dest['inds'].append(self.n_named_xx)
            
            self.n_named_xx += 1
        else:
            # Consider: do we want to record parameters tracking info as well?
            assert kind == 'pp'
            self.n_named_pp += 1

        if self.named_vars:
            if k == -1:
                if i == -1:
                    named_var = casadi.SX.sym(var.getName())
                else:
                    named_var = casadi.SX.sym(var.getName()+'_%d' % i)
            else:
                named_var = casadi.SX.sym(var.getName()+'_%d_%d' % (i, k))

            if kind == 'xx':
                self.named_xx.append(named_var)
                assert len(self.named_xx) == self.n_named_xx
            else:
                # assert kind == 'pp' # already checked
                self.named_pp.append(named_var)
                assert len(self.named_pp) == self.n_named_pp

    def add_named_xx(self, var, i=-1, k=-1):
        self.add_named_var('xx', var, i, k)

    def add_named_pp(self, var, i=-1, k=-1):
        self.add_named_var('pp', var, i, k)

    def _fill_checkpoint_map(self, varType, xx, n_var, initial_index, varKind='xx', n_add_points=0, move_zero=1):
        """
        Fill the checkpoint map for a given variable type with one sample per collocation point.

        Fills in self.var_map and self.var_indices, and appends to named_xx/named_pp if the named_vars option is on.
        Use varKind='pp' for parameters.
        
        Returns the number of scalar variables used - should be the same as the length of xx.
        """
        self.var_map[varType] = dict()
        self.var_indices[varType] = dict()
        self.var_map[varType]['all'] = xx
        
        n_discrete_points = self.n_cp + n_add_points

        if n_var == 0:
            # Handle the cases of empty variables
            for i in range(1, self.n_e+1):
                self.var_map[varType][i] = dict()
                self.var_indices[varType][i] = dict()
                self.var_map[varType][i]['all'] = xx[0:0]
                for k in xrange(n_discrete_points):
                    self.var_map[varType][i][k+move_zero] = dict()
                    self.var_indices[varType][i][k+move_zero] = list()
                    self.var_map[varType][i][k+move_zero]['all'] = xx[0:0]
            return 0

        counter = 0

        element_split2 = casadi.vertsplit(self.var_map[varType]['all'],
                                          n_var*n_discrete_points)
        # Builds element branch of the map
        for i in range(1, self.n_e+1):
            self.var_map[varType][i] = dict()
            self.var_map[varType][i]['all'] = element_split2[i-1]
            self.var_indices[varType][i] = dict()
            collocations_split2 = casadi.vertsplit(
                self.var_map[varType][i]['all'], n_var)
            # Builds collocation branch of the map
            for k in range(n_discrete_points):
                self.var_map[varType][i][k+move_zero] = dict()
                self.var_map[varType][i][k+move_zero]['all'] = collocations_split2[k]
                self.var_indices[varType][i][k+move_zero] = list()
                scalar_split = casadi.vertsplit(self.var_map[varType][i][k+move_zero]['all'])
                # Builds the individual variables branch of the map
                for (j, var) in enumerate(self.mvar_vectors[varType]):
                    self.var_map[varType][i][k+move_zero][j] = scalar_split[j]
                    self.var_indices[varType][i][k+move_zero].append(counter + initial_index)

                    self.add_named_var(varKind, var, i, k+move_zero)

                    counter += 1

        return counter

    def _create_nlp_variables(self):
        """
        Create the NLP variables and store them in a nested dictionary.
        """
        # Set model info
        nlp_n_var = copy.copy(self.n_var)
        del nlp_n_var['u']
        del nlp_n_var['elim_u']
        del nlp_n_var['constr_u']
        del nlp_n_var['quad_pen']
        if self.blocking_factors is not None:
            n_u = nlp_n_var['unelim_u']
            del nlp_n_var['unelim_u']
            n_bf_u = len(self.blocking_factors.factors)
            n_cont_u = n_u - n_bf_u
        if self.eliminate_der_var:
            del nlp_n_var['dx']
        n_popt = nlp_n_var['p_opt']
        del nlp_n_var['p_fixed']
        del nlp_n_var['p_opt']
        mvar_vectors = self.mvar_vectors

        # Count NLP variables
        n_xx = n_popt
        n_xx += (1 + self.n_e * self.n_cp) * N.sum(nlp_n_var.values())
        if self.eliminate_der_var:
            n_xx += nlp_n_var['x'] # dx_1_0
        if self.blocking_factors is not None:
            n_xx += (1 + self.n_e * self.n_cp) * n_cont_u
            for factors in self.blocking_factors.factors.values():
                n_xx += len(factors)
        if not self.eliminate_cont_var:
            n_xx += (self.n_e - 1) * nlp_n_var['x']
        self.is_gauss = (self.discr == "LG")
        if self.is_gauss:
            n_xx += (self.n_e - 1) * nlp_n_var['x'] # Mesh points
            n_xx += N.sum(nlp_n_var.values()) # tf
        if self.hs == "free":
            n_xx += self.n_e

        # Create NLP variables
        xx = casadi.MX.sym("xx", n_xx)
            
        # Map with indices of variables
        self.var_indices = var_indices = dict()
        # Map with different levels of packed mx variables
        self.var_map = var_map = dict()

        # Count the number of named variables to see that they match up even
        # if named_vars is off - also needed for back tracking of variables
        self.n_named_xx = 0
        # Create storage to track connection between nlp variables and model variables
        # NB: internal format of xx_dests is subject to change!
        self.xx_dests = {} # map from model variables to their xx instances

        if self.named_vars:
            self.named_xx = named_xx = []

        # Contains the indices at which xx is split
        # Those indices will let us split the xx as follows
        # [0, all_x, all_dx, all_w, all_unelimu, initial_final_points, popt, h_free]
        global_split_indices=[0]
        
        # Map with splited order
        split_map = dict()
        split_map['x'] = 0
        split_map['dx'] = 1
        split_map['w'] = 2
        split_map['unelim_u'] = 3
        split_map['init_final'] = 4
        split_map['p_opt'] = 5
        split_map['h'] = 6

        # Fill in global_split_indices structure
        for varType in ['x', 'dx', 'w', 'unelim_u']:
            if varType=='x':
                if self.discr == "LGR":
                    global_split_indices.append(
                        global_split_indices[-1]+\
                        nlp_n_var[varType]*(self.n_cp+1)*self.n_e)
                elif self.discr == "LG":
                    global_split_indices.append(
                        global_split_indices[-1]+\
                        nlp_n_var[varType]*(self.n_cp+2)*self.n_e)
                else:
                    raise CasadiCollocatorException(
                        "Unknown discretization scheme %s." % self.discr)
            elif varType=='unelim_u':
                if self.blocking_factors is not None:
                    count_us=(1+self.n_e * self.n_cp) * n_cont_u
                    for factors in self.blocking_factors.factors.values():
                        count_us += len(factors)
                    global_split_indices.append(
                        global_split_indices[-1]+\
                        count_us) 
                else:
                    global_split_indices.append(
                        global_split_indices[-1]+\
                        nlp_n_var[varType]*(self.n_cp)*self.n_e)                        
            else:
                global_split_indices.append(
                    global_split_indices[-1]+\
                    nlp_n_var[varType]*(self.n_cp)*self.n_e)
        # Append split index for final points 
        if self.discr == "LGR":
            if self.blocking_factors is not None:
                global_split_indices.append(
                    global_split_indices[-1]+\
                    nlp_n_var['dx']+\
                    nlp_n_var['w'])                     
            else:
                global_split_indices.append(
                    global_split_indices[-1]+\
                    nlp_n_var['dx']+\
                    nlp_n_var['unelim_u']+\
                    nlp_n_var['w'])
        elif self.discr == "LG":
            if self.blocking_factors is not None:
                global_split_indices.append(
                    global_split_indices[-1]+\
                    2*(nlp_n_var['dx']+\
                       nlp_n_var['w']))                    
            else:
                global_split_indices.append(
                    global_split_indices[-1]+\
                    2*(nlp_n_var['dx']+\
                       nlp_n_var['unelim_u']+\
                       nlp_n_var['w']))
        else:
            raise CasadiCollocatorException(
                "Unknown discretization scheme %s." % self.discr)                
        # Append split index for the free parameters 
        global_split_indices.append(global_split_indices[-1]+n_popt)
        n_freeh2 = self.n_e if self.hs == "free" else 0
        # Append index for the free elements
        global_split_indices.append(global_split_indices[-1]+n_freeh2) 
        
        # Split MX variables accordingly
        global_split=casadi.vertsplit(xx,global_split_indices)
        counter_s = 0
        
        # Define the order of the loop for building the check_point map 
        if self.blocking_factors is not None:
            variable_type_list = ['x','dx','w']
        else:
            variable_type_list = ['x','dx','w','unelim_u'] 
        # Build the check_point map
        for varType in variable_type_list:
            add=0
            move_zero=1
            if varType=='x':
                move_zero=0
                if self.discr == "LG":
                    add=2
                else:
                    add=1
            counter_s += self._fill_checkpoint_map(varType, global_split[split_map[varType]],
                                                   nlp_n_var[varType], counter_s, 
                                                   'xx', add, move_zero)

        if self.blocking_factors is not None:
            varType = 'unelim_u'
            # Index controls without blocking factors
            var_map[varType] = dict()
            var_indices[varType] = dict() 
            
            # Creates auxiliary list
            aux_list = [counter_s]*n_u
            
            u_cont_vars = [
                var for var in mvar_vectors['unelim_u']
                if var.getName() not in
                self.blocking_factors.factors.keys()]
            
            var_indices['u_cont'] = dict()
            for i in xrange(1, self.n_e + 1):
                var_indices['u_cont'][i]=dict()
                for k in xrange(1, self.n_cp + 1):
                    new_index = counter_s + n_cont_u
                    var_indices['u_cont'][i][k] = range(counter_s, new_index)
                    counter_s = new_index

                    for var in u_cont_vars:
                        self.add_named_xx(var, i, k)

            # Create index storage for inputs with blocking factors
            var_indices['u_bf'] = dict()
            for i in xrange(1, self.n_e + 1):
                var_indices['u_bf'][i] = dict()
                for k in xrange(1, self.n_cp + 1):
                    var_indices['u_bf'][i][k]= []
                    
                    
            # Index controls with blocking factors
            for name in self.blocking_factors.factors.keys():
                var = self.op.getVariable(name)
                element = 1
                factors = self.blocking_factors.factors[name]
                for (factor_i, factor) in enumerate(factors):
                    for i in xrange(element, element + factor):
                        for k in xrange(1, self.n_cp + 1):
                            var_indices['u_bf'][i][k].append(counter_s)

                    self.add_named_xx(var, element)

                    counter_s += 1
                    element += factor
                    
            # Weave indices for inputs with and without blocking factors
            for i in xrange(1, self.n_e + 1):
                var_indices[varType][i]=dict()
                for k in xrange(1, self.n_cp + 1):
                    i_cont = 0
                    i_bf = 0
                    indices = []
                    for var in self.mvar_vectors['unelim_u']:
                        if var.getName() in self.blocking_factors.factors:
                            indices.append(var_indices['u_bf'][i][k][i_bf])
                            i_bf += 1
                        else:
                            indices.append(var_indices['u_cont'][i][k][i_cont])
                            i_cont += 1
                    var_indices[varType][i][k] = indices                    
                del var_indices['u_bf'][i]
                del var_indices['u_cont'][i]
            
            del var_indices['u_bf']
            del var_indices['u_cont'] 
            
            # Add inputs to variable map
            for i in xrange(1, self.n_e + 1):
                var_map[varType][i] = dict()
                for k in xrange(1, self.n_cp + 1):
                    var_map[varType][i][k] = \
                        global_split[split_map['unelim_u']][
                            map(sub, var_indices[varType][i][k], 
                                aux_list)]
                    
            # Index initial controls separately if blocking_factors is not None       
            # Find indices of inputs with blocking factors
            bf_indices = []
            cont_indices = []
            for var in mvar_vectors['unelim_u']:
                name = var.getName()
                (idx, _) = self.name_map[name]
                if name in self.blocking_factors.factors:
                    bf_indices.append(idx)
                else:
                    cont_indices.append(idx)
            bf_indices = N.array(bf_indices, dtype=int)
            cont_indices = N.array(cont_indices, dtype=int)
            
            # Index initial controls with blocking factors
            var_indices['unelim_u'][1][0] = N.empty(n_u, dtype=int)
            var_indices['unelim_u'][1][0][bf_indices] = \
                [var_indices['unelim_u'][1][1][bf_i] for
                 bf_i in bf_indices]
            
            # Index initial controls without blocking factors
            new_index = counter_s + n_cont_u
            var_indices['unelim_u'][1][0][cont_indices] = \
                         range(counter_s, new_index)
            var_indices['unelim_u'][1][0] = \
                         list(var_indices['unelim_u'][1][0])
            counter_s = new_index
            
            # Insert initial controls into variable map                
            var_map['unelim_u'][1][0] = xx[var_indices['unelim_u'][1][0]]
            for var in mvar_vectors['unelim_u']:
                if var.getName() not in self.blocking_factors.factors:
                    self.add_named_xx(var, i=1, k=0)

        # Creates check_point map entry for initial points
        split_indices=[0,nlp_n_var['dx']]
        if self.blocking_factors is not None:
            varType='w'
            split_indices.append(split_indices[-1]+nlp_n_var[varType])
            inter_split=casadi.vertsplit(
                global_split[split_map['init_final']],
                nlp_n_var['dx']+\
                nlp_n_var['w'])  
            variable_type_list = ['dx','w']
        else:
            for varType in ['w','unelim_u']:
                split_indices.append(split_indices[-1]+nlp_n_var[varType])                
            inter_split=casadi.vertsplit(
                global_split[split_map['init_final']],
                nlp_n_var['dx']+\
                nlp_n_var['unelim_u']+\
                nlp_n_var['w'])            
            variable_type_list = ['dx', 'w', 'unelim_u']
        
        split_init=casadi.vertsplit(inter_split[0], split_indices)
        for zt,varType in enumerate(variable_type_list):
            var_map[varType][1][0] = dict()
            var_indices[varType][1][0]=list() 
            if nlp_n_var[varType]!=0:
                var_map[varType][1][0]['all']=split_init[zt]                    
                tmp_split=casadi.vertsplit(var_map[varType][1][0]['all'])
                for var in mvar_vectors[varType]:
                    name = var.getName()
                    (var_index, _) = self.name_map[name]
                    var_map[varType][1][0][var_index] = \
                              tmp_split[var_index]
                    var_indices[varType][1][0].append(counter_s)

                    self.add_named_xx(var, i=1, k=0)

                    counter_s+=1
            else:
                var_map[varType][1][0]['all']=xx[0:0]
                           
        # Creates check_point map entry for final points
        if self.discr == "LG":
            split_end=casadi.vertsplit(inter_split[1], split_indices)
            ii=self.n_e
            kk=self.n_cp+1 
            for zt,varType in enumerate(variable_type_list):
                var_map[varType][ii][kk] = dict()
                var_indices[varType][ii][kk]=list()
                if nlp_n_var[varType]!=0:
                    var_map[varType][ii][kk]['all']=split_end[zt]
                    tmp_split=casadi.vertsplit(
                        var_map[varType][ii][kk]['all'])
                    for var in mvar_vectors[varType]:
                        name = var.getName()
                        (var_index, _) = self.name_map[name]
                        var_map[varType][ii][kk][var_index] = \
                                  tmp_split[var_index]
                        var_indices[varType][ii][kk].append(counter_s)

                        self.add_named_xx(var, ii, kk)

                        counter_s+=1
                else:
                    var_map[varType][ii][kk]['all']=xx[0:0]

        # Creates check_point map entry parameters
        var_map['p_opt'] = dict()
        var_map['p_opt']['all'] = \
                  global_split[split_map['p_opt']]
        var_indices['p_opt']=range(counter_s,counter_s+n_popt)
        if n_popt!=0:
            tmp_split=casadi.vertsplit(var_map['p_opt']['all'])
            for par in mvar_vectors['p_opt']:
                name = par.getName()
                (var_index, _) = self.name_map[name] 
                var_map['p_opt'][var_index] = tmp_split[var_index]
                
                self.add_named_xx(par)

                counter_s+=1
                                   
        # Creates check_point map entry free elements
        var_map['h'] = dict()
        var_map['h']['all'] = \
                  global_split[split_map['h']]
        var_indices['h']=range(counter_s,counter_s+n_freeh2)
        if n_freeh2!=0:
            tmp_split=casadi.vertsplit(var_map['h']['all'])
            for i in range(self.n_e):
                var_map['h'][i+1] = tmp_split[i]

                self.n_named_xx += 1 # increment since we don't call add_named_xx
                if self.named_vars:
                    named_xx.append(casadi.SX.sym('h_%d' % i+1))

                counter_s+=1                     

        # Update h_i for free elements length
        if self.hs == "free":
            var_indices['h'] =[ N.nan ]+ var_indices['h']
            self.h = casadi.vertcat([N.nan,var_map['h']['all']])
        else:
            # Make sure self.h can be indexed with vectors
            # (just as the result from casadi.vertcat above can)
            self.h = N.array(self.h)

        assert(counter_s == n_xx)
        
        # Save variables and indices as data attributes
        self.xx = xx
        assert self.n_named_xx == n_xx
        if self.named_vars:
            assert(len(named_xx) == n_xx)
            self.named_xx = casadi.vertcat(self.named_xx)
            
        self.global_split_indices = global_split_indices
        self.n_xx = n_xx
    
    def _count_constraints(self):
        """
        Count the number of constraints in the final NLP,
        so that we can allocate scaling factors for them.
        """
        n_c_e = n_c_i = 0

        n_tp = 1 + self.n_e * (self.n_cp + (1 if self.is_gauss else 0))

        n_c_e += self.initial.numel() # initial equations
        n_c_e += self.dae.numel() * (1 + self.n_e * self.n_cp) # dae equations

        # todo: save!
        if self.blocking_factors is None:
            inp_list = [inp.getName() for inp in self.mvar_vectors['unelim_u']]
        else:
            inp_list = [inp.getName() for inp in self.mvar_vectors['unelim_u'] 
                   if not self.blocking_factors.factors.has_key(inp.getName())]

        n_c_e += len(inp_list) # u_1_0

        if self.is_gauss:
            # Continuity constraints for x_{i, n_cp + 1}
            n_c_e += self.n_e * self.n_var['x']
            
            n_c_e += self.n_var['unelim_u'] + self.n_var['w']  # terminal
            if not self.eliminate_der_var:
                n_c_e += self.n_var['x'] # terminal_dx

        if self.hs == "free":
            n_c_e += 1 # h_sum

        # Path constraints
        for cnstr in self.op.getPathConstraints():
            if cnstr.getType() == cnstr.EQ:
                n_c_e += n_tp
            else:
                if self.is_gauss:
                    n_c_i += n_tp - self.n_e + 1
                else:
                    n_c_i += n_tp

        # Point constraints
        for cnstr in self.op.getPointConstraints():
            if cnstr.getType() == cnstr.EQ:
                n_c_e += 1
            else:
                n_c_i += 1

        if not self.eliminate_der_var: # collocation constraints
            n_c_e += self.n_e * self.n_cp * self.n_var['x']

        if not self.eliminate_cont_var: # continuity constraints
            n_c_e += (self.n_e - 1) * self.n_var['x']

        # Bounds on du
        if self.blocking_factors is not None:
            for var in self.mvar_vectors['unelim_u']:
                name = var.getName()
                if ((name in self.blocking_factors.factors) and
                    (name in self.blocking_factors.du_bounds)):
                    n_c_i += 2*(len(self.blocking_factors.factors[name])-1)

        # Equality constraints for constrained inputs
        if self.external_data is not None:
            n_c_e += self.n_e * self.n_cp * len(self.external_data.constr_quad_pen)

        # Equality constraints for delayed feedback
        if self.delayed_feedback is not None:
            n_c_e += self.n_e * self.n_cp * len(self.delayed_feedback)

        self.n_c_e, self.n_c_i = n_c_e, n_c_i
        self.n_c = n_c_e + n_c_i

    def _create_nlp_parameters(self):
        """
        Create parameter symbols that will be used in the final nlp,
        and record values for them.
        """
        # Turn off the mutable_external_data unless there is external data to work with
        if self.external_data is None: self.mutable_external_data = False

        # Count parameters
        n_pp_unvarying = self.n_var['p_fixed']
        n_pp_kinds = [n_pp_unvarying] # total number of parameters of each kind
        n_var_pp = {}                 # number of variables of each kind in the continuous time model
        pp_kinds = ['p_fixed']        # corresponding kinds. 'p_fixed' expected to be first        

        if self.discr == "LG":
            n_add_points=2
        else:
            n_add_points=1

        ext_data_kinds = ['elim_u', 'quad_pen', 'constr_u']
        if self.mutable_external_data:
            nv = N.array([len(self.external_data.eliminated),
                          len(self.external_data.quad_pen),
                          len(self.external_data.constr_quad_pen)])
            for (kind, n) in zip(ext_data_kinds, nv):
                n_var_pp[kind] = n
            n_pp_kinds.extend(nv * (self.n_e * (self.n_cp + n_add_points)))
            pp_kinds.extend(ext_data_kinds)

        n_c = self.n_c_e + self.n_c_i
        if self.equation_scaling:
            n_pp_kinds.append(n_c)
            pp_kinds.append('equation_scale')
        if self.variable_scaling and self.variable_scaling_allow_update:
            n_pp_kinds.append(self._var_sf_count*2) #Account for (d,e) pair
            pp_kinds.append('variable_scale')

        n_pp = N.sum(n_pp_kinds)
        pp_offset = N.hstack((0, N.cumsum(n_pp_kinds)))
        pp_offset_end = N.hstack((N.cumsum(n_pp_kinds), -1))
        # CasADi's vertsplit seems to be having trouble with taking pp_offset
        # as a numpy array of dtype=int64
        pp_offset = [offset for offset in pp_offset]

        #Create parameter symbols
        self.pp = casadi.MX.sym("par", n_pp, 1)
        if len(pp_kinds) > 1:
            pp_split = casadi.vertsplit(self.pp, pp_offset)
            self.pp_unvarying = pp_split[0]

            self.pp_split  = dict(zip(pp_kinds, pp_split))
            self.pp_offset = dict(zip(pp_kinds, pp_offset))
        else:
            self.pp_unvarying = self.pp

        # Get parameter values and symbols
        par_vars = [par.getVar() for par in self.mvar_vectors['p_fixed']]
        pp_unvarying_vals = [self.op.get_attr(par, "_value")
                             for par in self.mvar_vectors['p_fixed']]
        par_vals = N.hstack([pp_unvarying_vals, N.zeros(n_pp - n_pp_unvarying)])
        if self.equation_scaling:
            # set all equation scalings to 1 initially
            offset = self.pp_offset['equation_scale']
            par_vals[offset:offset + n_c] = 1
        if self.variable_scaling and self.variable_scaling_allow_update:
            offset = self.pp_offset['variable_scale']
            for i in range(self._var_sf_count):
                pass
                #par_vals[offset + i*2]   = 1.0 #d
                #par_vals[offset + i*2+1] = 0.0 #e
        self._par_vals = N.asarray(par_vals)

        # Count the number of named variables to see that they match up even
        # if named_vars is off - also needed for back tracking of variables
        self.n_named_pp = 0
        #Create list of parameter names
        if self.named_vars:
            self.named_pp = named_pp = []

        for para in par_vars:
            self.add_named_pp(para)

        # Add p_fixed to var_map and var_indices
        self.var_map['p_fixed'] = dict()
        self.var_map['p_fixed']['all'] = self.pp_unvarying
        self.var_indices['p_fixed']=range(0, self.n_var['p_fixed'])
        if self.n_var['p_fixed'] != 0:
            tmp_split=casadi.vertsplit(self.var_map['p_fixed']['all'])
            for par in self.mvar_vectors['p_fixed']:
                name = par.getName()
                (var_index, _) = self.name_map[name] 
                self.var_map['p_fixed'][var_index] = tmp_split[var_index]

        # Fill in var_map, var_indices, and named_pp for time-varying nlp parameters
        if self.mutable_external_data:
            for kind in ext_data_kinds:
                self._fill_checkpoint_map(kind, self.pp_split[kind],
                    n_var_pp[kind], self.pp_offset[kind],
                    'pp', n_add_points=n_add_points, move_zero=0)

        if self.equation_scaling:
            self.n_named_pp += n_c
            if self.named_vars:
                for j in range(self.n_c_e):
                    self.named_pp.append(casadi.SX.sym('eq_scale_%d' % j))
                for j in range(self.n_c_i):
                    self.named_pp.append(casadi.SX.sym('ineq_scale_%d' % j))
                    
        if self.variable_scaling and self.variable_scaling_allow_update:
            self.n_named_pp += self._var_sf_count*2
            if self.named_vars:
                for vt in ['x', 'dx', 'unelim_u', 'w']:
                    for var in self.mvar_vectors[vt]:
                        name = var.getName()
                        if self._var_sf_mode[name] != "time-variant":
                            d = casadi.SX.sym("%s_d_sf"%(name))
                            e = casadi.SX.sym("%s_e_sf"%(name))
                            self.named_pp.append(d)
                            self.named_pp.append(e)
                        else:
                            for i in range(1, self.n_e+1):
                                for k in self.time_points[i]:
                                    d = casadi.SX.sym("%s_%d_%d_d_sf"%(name,i,k))
                                    e = casadi.SX.sym("%s_%d_%d_e_sf"%(name,i,k))
                                    self.named_pp.append(d)
                                    self.named_pp.append(e)
                for var in self.mvar_vectors["p_opt"]:
                    name = var.getName()
                    d = casadi.SX.sym("%s_d_sf"%(name))
                    e = casadi.SX.sym("%s_e_sf"%(name))
                    self.named_pp.append(d)
                    self.named_pp.append(e)

        # Finalize named_pp
        assert self.n_named_pp == n_pp
        if self.named_vars:
            assert(len(self.named_pp) == n_pp)
            self.named_pp = casadi.vertcat(self.named_pp)

    def _recalculate_model_parameters(self):
        """
        Recalculate the model's parameters and set them in self._par_vals
        """
        self.op.calculateValuesForDependentParameters()
        
        pp_unvarying_vals = [self.op.get_attr(par, "_value")
                             for par in self.mvar_vectors['p_fixed']]
        pp_unvarying_vals = N.array(pp_unvarying_vals).reshape(-1)
        self._par_vals[0:self.n_var['p_fixed']] = pp_unvarying_vals
        return pp_unvarying_vals

    def _get_z_l0(self,i,k,with_der=True):
        """
        Returns a vector with all the NLP variables at a collocation point.

        Parameters::

            i --
                Element index.
                Type: int

            k --
                Collocation point.
                Type: int

            with_der --
                Appends the derivatives to the returning vector

        Returns::

            z --
                NLP variable vector.
                Type: MX or SX
        """
        z = []
        for vk in self.mvar_struct.iterkeys(): #Dangerous need to verify that variable types are added in correct order
            if vk == 'time':
                if self._normalize_min_time:
                    z.append(self.time_points[i][k]*(self._denorm_tf-self._denorm_t0))
                else:
                    z.append(self.time_points[i][k])
            elif vk == 'dx' and not with_der:
                pass
            elif vk in ['p_fixed', 'p_opt']:
                if self.n_var[vk]>0:
                    z.append(self.var_map[vk]['all'])
            else:
                if self.n_var[vk]>0:
                    if self.blocking_factors is None:
                        z.append(self.var_map[vk][i][k]['all'])
                    else:
                        if vk != 'unelim_u':
                            z.append(self.var_map[vk][i][k]['all'])
                        else:
                            z.append(self.var_map[vk][i][k])


        return z

    def _get_z_l1(self,i,with_der=True):
        """
        Returns a vector with all the NLP variables at an element.

        Parameters::

            i --
            Element index.
            Type: int

            with_der --
            Appends the derivatives to the returning vector

        Returns::

            z --
            NLP variable vector.
            Type: MX or 
        """
        z = []
        for vk in self.mvar_struct.iterkeys():
            if vk == 'time':
                times = [self.time_points[i][k] for k in range(1, self.n_cp+1)]
                if self._normalize_min_time:
                    times *= (self._denorm_tf-self._denorm_t0) 
                z.append(casadi.MX(times))
            elif vk == 'dx' and not with_der:
                pass
            elif vk in ['p_fixed', 'p_opt']:
                if self.n_var[vk]>0:
                    z.append(self.var_map[vk]['all'])
            else:
                if self.n_var[vk]>0:
                    z.append(self.var_map[vk][i]['all'])

        return z

    def get_point_time(self, i, k):
        """
        Get the time of a point (i, k)
        """
        return self.element_times[i] + self.horizon * self.h[i] * self.coll_p[k]

    def _compute_time_points(self):
        """
        Return a vector with the corresponding times at the collocation points

        Returns::

            time --
                time vector.
                Type float
        """
        # Calculate start and end times of elements
        self.element_times = N.zeros(self.n_e+2,
            dtype = object if self.hs == "free" else float)
        self.element_times[0] = N.nan # element 0 is unused
        t = self.t0
        for i in xrange(1, self.n_e + 1):
            self.element_times[i] = t
            t = t + self.horizon * self.h[i]
        self.element_times[self.n_e + 1] = t

        if self.is_gauss:
            self.coll_p = N.hstack((self.pol.p, 1))
        else:
            self.coll_p = self.pol.p

        # Now it's ok to call get_point_time

        # Calculate time points
        self.time_points = {}
        time = []

        for i in xrange(1, self.n_e + 1):
            self.time_points[i] = {}
            k0 = 0 if i == 1 else 1
            k1 = self.n_cp + (2 if self.is_gauss and i == self.n_e else 1)
            for k in xrange(k0, k1):
                t = self.get_point_time(i, k)
                self.time_points[i][k] = t
                time.append(t)

        if self.hs != "free":
            assert(N.allclose(time[-1], self.tf))

        return time

    def _compute_collocation_constrained_points(self,time):
        """
        Create dictionary for the collocation points with timed variables.

        Parameters::

            time --
                  Vector with all the time points
                  Type: list(float)

        Returns::

             collocation_constraint_points --
                                            dictionary with the timed points
                                            Type dictionary
        """
        if self.op.getTimedVariables().size > 0 and self.hs == "free":
            raise CasadiCollocatorException("Point constraints can not be " +
                                            "combined with free element " +
                                            "lengths.")
        cnstr_points_expr = [timed_var.getTimePoint() for timed_var
                             in self.op.getTimedVariables()]
        if self._normalize_min_time:
            for expr in cnstr_points_expr:
                if not self._check_linear_comb(expr):
                    raise CasadiCollocatorException(
                        "Constraint point %s is not a " % repr(expr) +
                        "convex combination of startTime and finalTime.")
            t0_var = self.op.getVariable('startTime').getVar()
            tf_var = self.op.getVariable('finalTime').getVar()

            # Map time points to constraint points
            cnstr_points_f = self._FXFunction(
                [t0_var, tf_var], [casadi.vertcat(cnstr_points_expr)])
            cnstr_points_f.init()
            cnstr_points_f.setInput(0., 0)
            cnstr_points_f.setInput(1., 1)
            cnstr_points_f.evaluate()
            constraint_points = cnstr_points_f.output().toArray().reshape(-1)
            constraint_points = sorted(set(constraint_points))
        else:
            constraint_points = sorted(set([self.op.evaluateExpression(expr)
                                            for expr in cnstr_points_expr]))

        collocation_constraint_points = {}
        for constraint_point in constraint_points:
            tp_index = None
            if self.is_gauss:
                time_enumeration = enumerate(time[1:-1])
            else:
                time_enumeration = enumerate(time[1:])
            for (index, time_point) in time_enumeration:
                if N.allclose(constraint_point, time_point):
                    tp_index = index
                    break
            if tp_index is None:
                if N.allclose(constraint_point, self.t0):
                    collocation_constraint_points[constraint_point] = \
                        (1, 0)
                elif (self.is_gauss and
                      N.allclose(constraint_point, self.tf)):
                    collocation_constraint_points[constraint_point] = \
                        (self.n_e, self.n_cp + 1)
                else:
                    raise CasadiCollocatorException(
                        "Constraint point " + `constraint_point` +
                        " does not coincide with a collocation point.")
            else:
                (e, cp) = divmod(tp_index, self.n_cp)
                collocation_constraint_points[constraint_point] = \
                    (e + 1, cp + 1)
        return collocation_constraint_points

    def _store_and_scale_timed_vars(self,time):
        """
        store collocation points that are constrained due to 
        timed variables.  It also scale accordingly to the 
        scaling mode the expressions that involve timed vars.
            self.path, 
            self.point, 
            self.mterm
        Parameters::

            time --
                  Vector with all the time points
                  Type: list(float)
        """
        # Map constraint points to collocation points
        nlp_timed_variables = []
        if self.hs == "free":
            timed_variables = []
        else:
            # Compute constraint points
            self._collocation_constraint_points = \
                self._compute_collocation_constrained_points(time)

            # Compose timed variables and corresponding scaling factors and
            # NLP variables
            timed_variables = []
            for tv in self.op.getTimedVariables():
                timed_variables.append(tv.getVar())
                tp = tv.getTimePoint()
                if self._normalize_min_time:
                    cp = self._tp2cp(tp)
                else:
                    cp = self.op.evaluateExpression(tp)
                (i, k) = self._collocation_constraint_points[cp]
                name = tv.getBaseVariable().getName()
                (index, vt) = self.name_map[name]
                if vt == "elim_u":
                    raise CasadiCollocatorException(
                        "Point constraints may not depend on eliminated " +
                        "input %s" % name)
                nlp_timed_variables.append(self.var_map[vt][i][k][index])

        self._timed_variables = timed_variables
        self._nlp_timed_variables = nlp_timed_variables 

    def _denormalize_times(self):
        """
        Denormalize time for minimum time problems
        """
        if self._normalize_min_time:
            t_init = {}
            t_nom = {}
            if self.init_traj is not None:
                intraj_gvd = self.init_traj.get_variable_data
            if self.nominal_traj is not None:
                nomtraj_gvd = self.nominal_traj.get_variable_data
            for t_name in ['startTime', 'finalTime']:
                t_var = self.op.getVariable(t_name)
                if self.op.get_attr(t_var, "free"):
                    if t_name == 'startTime':
                         t0_index = self.name_map['startTime'][0]
                         self._denorm_t0 = self.var_map['p_opt'][t0_index]
                    else:
                        tf_index = self.name_map['finalTime'][0]
                        self._denorm_tf = self.var_map['p_opt'][tf_index]
                    var_init_guess = self.op.get_attr(t_var, "initialGuess")
                    if self.init_traj is None:
                        t_init[t_name] = var_init_guess
                    else:
                        try:
                            data = self.init_traj.get_variable_data(t_name)
                        except VariableNotFoundError:
                            if (var_init_guess in [0., 1.]):
                                if self.options['verbosity'] >= 2:
                                    print("Warning: Could not find initial " +
                                          "guess for %s in initial " % t_name +
                                          "trajectories. Using end-point of " +
                                          "provided time horizon instead.")
                                if t_name == "startTime":
                                    t_init[t_name] = intraj_gvd("time").t[0]
                                elif t_name == "finalTime":
                                    t_init[t_name] = intraj_gvd("time").t[-1]
                                else:
                                    raise CasadiCollocatorException(
                                        "BUG: Please contact the developers.")
                            else:
                                if self.options['verbosity'] >= 2:
                                    print("Warning: Could not find initial " +
                                          "guess for %s in initial " % t_name +
                                          "trajectories. Using initialGuess " +
                                          "attribute value instead.")
                                t_init[t_name] = var_init_guess
                        else:
                            t_init[t_name] = data.x[0]
                    if self.nominal_traj is None:
                        t_nom[t_name] = self.op.get_attr(t_var, "nominal")
                    else:
                        try:
                            mode = self.nominal_traj_mode[t_name]
                        except KeyError:
                            mode = self.nominal_traj_mode["_default_mode"]
                        if mode == "attribute":
                            t_nom[t_name] = self.op.get_attr(t_var, "nominal")
                        else:
                            try:
                                data = self.nominal_traj.get_variable_data(
                                    t_name)
                            except VariableNotFoundError:
                                if self.options['verbosity'] >= 2:
                                    print("Warning: Could not find nominal " +
                                          "value for %s in nominal t" % t_name +
                                          "rajectories. Using end-point of " +
                                          "provided time horizon instead.")
                                if t_name == "startTime":
                                    t_nom[t_name] = nomtraj_gvd("time").t[0]
                                elif t_name == "finalTime":
                                    t_nom[t_name] = nomtraj_gvd("time").t[-1]
                                else:
                                    raise CasadiCollocatorException(
                                        "BUG: Please contact the developers.")
                            else:
                                t_nom[t_name] = data.x[0]
                else:
                    t_init[t_name] = self.op.get_attr(t_var, "start")
                    t_nom[t_name] = self.op.get_attr(t_var, "start")
                    if t_name == 'startTime':
                        self._denorm_t0 = self.t0
                    else: 
                        self._denorm_tf = self.tf
            self._denorm_t0_init = t_init["startTime"]
            self._denorm_tf_init = t_init["finalTime"]
            self._denorm_t0_nom = t_nom["startTime"]
            self._denorm_tf_nom = t_nom["finalTime"]

    def _create_nominal_trajectories(self):
        """
        Returns a dictionary that contains the trajectories. Must be called after time has 
        been denormalized and self._denorm_t0_init etc have been set

        Returns::

             nom_traj --
                    dictionary with all trajectories
                    Type dictionary
        """
        # Create nominal trajectories
        mvar_vectors = self.mvar_vectors
        name_map = self.name_map
        nom_traj = {}
        if self.variable_scaling and self.nominal_traj is not None:
            n = len(self.nominal_traj.get_data_matrix()[:, 0])
            for vt in ["dx", 'x', 'unelim_u', 'w']:
                nom_traj[vt] = {}
                for var in mvar_vectors[vt]:
                    data_matrix = N.empty([n, len(mvar_vectors[vt])])
                    name = var.getName()
                    (var_index, _) = name_map[name]
                    try:
                        data = self.nominal_traj.get_variable_data(name)
                    except VariableNotFoundError:
                        # It is possibly to treat missing variable trajectories
                        # more efficiently, especially in the case of MX
                        if self.options['verbosity'] >= 2:
                            print("Warning: Could not find nominal trajectory " +
                                  "for variable " + name + ". Using nominal " +
                                  "attribute value instead.")
                        self.nominal_traj_mode[name] = "attribute"
                        abscissae = N.array([0])
                        nom_val = self.op.get_attr(var, "nominal")
                        constant_sf = N.abs(nom_val)
                        ordinates = N.array([[constant_sf]])
                    else:
                        abscissae = N.asarray(data.t)
                        ordinates = N.asarray(data.x)
                        nonfinite_ind = N.nonzero(N.isfinite(ordinates) == 0.)[0]
                        if len(nonfinite_ind) > 0:
                            if self.options['verbosity'] >= 1:
                                print("Warning: Nominal trajectory for variable " + name +
                                      " contains nonfinite values. Using nominal attribute " +
                                      "value for these instead.")
                            ordinates[nonfinite_ind] = self.op.get_attr(var, "nominal")
                        ordinates = ordinates.reshape([-1, 1])
                    nom_traj[vt][var_index] = \
                        TrajectoryLinearInterpolation(abscissae, ordinates)
        return nom_traj
        
    def _create_variable_scaling_struct(self):
        var_sf_map = {}
        var_sf_count = 0
        var_sf_nbr_vars = 0
        var_sf_mode = {}
        var_sf = {"n_variant": 0}
        
        if self.variable_scaling:
            # Loop over all variables
            for vt in ['x', 'dx', 'unelim_u', 'w']:
                var_sf_map[vt] = {}
                var_sf["n_variant_%s"%vt] = 0
                
                #Setup struct
                for i in xrange(1, self.n_e + 1):
                    var_sf_map[vt][i] = {}
                    for k in self.time_points[i]:
                        var_sf_map[vt][i][k] = {}
                
                for var in self.mvar_vectors[vt]:
                    name = var.getName()
                    (var_index, _) = self.name_map[name]
                    var_sf_nbr_vars += 1
                    
                    try:
                        mode = self.nominal_traj_mode[name]
                    except KeyError:
                        mode = self.nominal_traj_mode["_default_mode"]
                        
                    var_sf_mode[name] = mode
                    
                    if mode != "time-variant":
                        var_sf_map[vt][name] = (2*var_sf_count, 2*var_sf_count+1)
                        var_sf_count += 1
                        continue
                        
                    var_sf["n_variant_%s"%vt] += 1
                    var_sf["n_variant"] += 1
                    
                    #Setup struct
                    for i in xrange(1, self.n_e + 1):
                        for k in self.time_points[i]:
                            var_sf_map[vt][i][k][var_index] = (2*var_sf_count, 2*var_sf_count+1)
                            var_sf_count += 1
            
            # Handle free parameters
            var_sf_map["p_opt"] = {}
            var_sf["n_variant_p_opt"] = 0
            for var in self.mvar_vectors['p_opt']:
                name = var.getName()
                (var_index, _) = self.name_map[name]
                
                var_sf_map['p_opt'][name] = (2*var_sf_count, 2*var_sf_count+1)
                var_sf_count += 1
                var_sf_nbr_vars += 1
        
        self._var_sf_mode     = var_sf_mode
        self._var_sf_count    = var_sf_count
        self._var_sf_map      = var_sf_map
        self._var_sf_nbr_vars = var_sf_nbr_vars
        self._var_sf          = var_sf
            

    def _create_trajectory_scaling_factor_structures(self):
        """
        Define structures for trajectory scaling. Structures that are
        used to scale the level0 functions.
        """
        if self.variable_scaling:
            
            if self.nominal_traj is not None:
                # Create nominal trajectories
                nom_traj = self._create_nominal_trajectories()
            else: #Change mode to nominal if there are no nominal trajectories
                self.nominal_traj_mode["_default_mode"] = "attribute"
                
            if self._normalize_min_time:
                t0_nom = self._denorm_t0_nom
                tf_nom = self._denorm_tf_nom

            # Create storage for scaling factors
            time_points = self.get_time_points()
            is_variant = {}
            n_variant_var = 0
            n_invariant_var = 0
            variant_sf = {}
            invariant_d = []
            invariant_e = []
            variant_timed_var = []
            variant_timed_sf = []
            name_idx_sf_map = {}
            self._is_variant = is_variant
            self._variant_sf = variant_sf
            self._invariant_d = invariant_d
            self._invariant_e = invariant_e
            self._name_idx_sf_map = name_idx_sf_map
            for i in xrange(1, self.n_e + 1):
                variant_sf[i] = {}
                for k in time_points[i]:
                    variant_sf[i][k] = []

            # Evaluate trajectories to generate scaling factors
            for vt in ['x', 'dx', 'unelim_u', 'w']:
                for var in self.mvar_vectors[vt]:
                    name = var.getName()
                    (var_index, _) = self.name_map[name]
                    try:
                        mode = self.nominal_traj_mode[name]
                    except KeyError:
                        mode = self.nominal_traj_mode["_default_mode"]
                    
                    if mode == "time-variant" and self._var_sf_mode[name] != "time-variant":
                        mode = self._var_sf_mode[name]
                        if self.options['verbosity'] >= 3:
                            print("Warning: Could not do time-variant " + 
                                          "scaling for variable %s " % name +
                                          "due to that the original scaling was %s. " %mode + 
                                          "Doing %s scaling instead." %mode)
                    
                    values = {}
                    traj_min = N.inf
                    traj_max = -N.inf
                    if mode not in ["attribute"]: #Compute min/max from nominal trajectories
                        for i in xrange(1, self.n_e + 1):
                            values[i] = {}
                            for k in time_points[i]:
                                tp = time_points[i][k]
                                if self._normalize_min_time:
                                    tp = t0_nom + (tf_nom - t0_nom) * tp
                                val = float(nom_traj[vt][var_index].eval(tp))
                                values[i][k] = val
                                if val < traj_min:
                                    traj_min = val
                                if val > traj_max:
                                    traj_max = val
                    if mode in ["attribute", "linear", "affine"]:
                        variant = False
                    elif mode == "time-variant":
                        variant = True
                        if (traj_min < 0 and traj_max > 0 or
                            traj_min == 0 or traj_max == 0):
                            variant = False
                        if variant:
                            traj_abs = N.abs([traj_min, traj_max])
                            abs_min = traj_abs.min()
                            abs_max = traj_abs.max()
                            if abs_min < 1e-3 and abs_max / abs_min > 1e6:
                                variant = False
                        if not variant:
                            if (self.nominal_traj_mode["_default_mode"] == 
                                "time-variant"):
                                variant = False
                                if self.options['verbosity'] >= 3:
                                    print("Warning: Could not do time-variant " + 
                                          "scaling for variable %s. " % name +
                                          "Doing time-invariant affine scaling " +
                                          "instead.")
                            else:
                                raise CasadiCollocatorException(
                                    "Could not do time-variant scaling for " +
                                    "variable %s." % name)
                    else:
                        raise CasadiCollocatorException(
                            "Unknown scaling mode %s " % mode +
                            "for variable %s." % name)
                    (idx, vt) = self.name_map[name]
                    if variant:
                        is_variant[name] = True
                        name_idx_sf_map[name] = n_variant_var
                        n_variant_var += 1
                        for i in xrange(1, self.n_e + 1):
                            for k in time_points[i]:
                                variant_sf[i][k].append(N.abs(values[i][k]))
                    else:
                        is_variant[name] = False
                        if mode == "attribute":
                            d = N.abs(self.op.get_attr(var, "nominal"))
                            if d == 0.0:
                                raise CasadiCollocatorException(
                                    "Nominal value for " +
                                    "%s is zero." % name)
                            e = 0.
                        elif mode == "linear":
                            d = max([abs(traj_max), abs(traj_min)])
                            if d == 0.0:
                                d = N.abs(self.op.get_attr(var, "nominal"))
                                if self.options['verbosity'] >= 3:
                                    print("Warning: Nominal trajectory for " +
                                          "variable %s is identically " % name + 
                                          "zero. Using nominal attribute instead.")
                                if d == 0.0:
                                    raise CasadiCollocatorException(
                                        "Nominal value for " +
                                        "%s is zero." % name)
                            e = 0.
                        elif mode in ["affine", "time-variant"]:
                            if N.allclose(traj_max, traj_min):
                                if (self.nominal_traj_mode["_default_mode"] in 
                                    ["affine", "time-variant"]):
                                    if self.options['verbosity'] >= 3:
                                        print("Warning: Could not do affine " +
                                              "scaling for variable %s. " % name + 
                                              "Doing linear scaling instead.")
                                else:
                                    raise CasadiCollocatorException(
                                        "Could not do affine scaling " +
                                        "for variable %s." % name)
                                d = max([abs(traj_max), abs(traj_min)])
                                if d == 0.:
                                    if self.options['verbosity'] >= 3:
                                        print("Warning: Nominal trajectory for " +
                                              "variable %s is " % name + 
                                              "identically zero. Using nominal " +
                                              "attribute instead.")
                                    d = N.abs(self.op.get_attr(var, "nominal"))
                                    if d == 0.:
                                        raise CasadiCollocatorException(
                                            "Nominal value for " +
                                            "%s is zero." % name)
                                else:
                                    d = max([abs(traj_max), abs(traj_min)])
                                e = 0.
                            else:
                                d = traj_max - traj_min
                                e = traj_min
                        name_idx_sf_map[name] = n_invariant_var
                        n_invariant_var += 1
                        if self._normalize_min_time and vt == "dx":
                            d *= (tf_nom - t0_nom)
                            e *= (tf_nom - t0_nom)
                        invariant_d.append(d)
                        invariant_e.append(e)

            # Do not scaled eliminated inputs
            for var in self.mvar_vectors['elim_u']:
                name = var.getName()
                (idx, vt) = self.name_map[name]
                is_variant[name] = False
                d = 1.
                e = 0.
                name_idx_sf_map[name] = n_invariant_var
                n_invariant_var += 1
                invariant_d.append(d)
                invariant_e.append(e)

            # Handle free parameters
            for var in self.mvar_vectors['p_opt']:
                name = var.getName()
                (var_index, _) = self.name_map[name]
                is_variant[name] = False
                if name == "startTime":
                    d = N.abs(self._denorm_t0_nom)
                    if d == 0.:
                        d = 1.
                    e = 0.
                elif name == "finalTime":
                    d = N.abs(self._denorm_tf_nom)
                    if d == 0.:
                        d = 1.
                    e = 0.
                else:
                    try:
                        mode = self.nominal_traj_mode[name]
                    except KeyError:
                        mode = self.nominal_traj_mode["_default_mode"]
                    
                    if mode == "attribute":
                        nom_val = self.op.get_attr(var, "nominal")
                        d = N.abs(nom_val)
                        if d == 0.:
                            raise CasadiCollocatorException(
                                "Nominal value for %s is zero." % name)
                    else:
                        try:
                            data = self.nominal_traj.get_variable_data(name)
                            d = N.abs(data.x[0])
                            if N.allclose(d, 0.):
                                if self.options['verbosity'] >= 2:
                                    print("Warning: Nominal value for %s is " % name +
                                          "too small. Setting scaling factor to 1.")
                                d = 1.
                        except VariableNotFoundError:
                            if self.options['verbosity'] >= 2:
                                print("Warning: Could not find nominal trajectory " +
                                      "for variable " + name + ". Using nominal " +
                                      "attribute value instead.")
                            nom_val = self.op.get_attr(var, "nominal")
                            d = N.abs(nom_val)
                            if d == 0.:
                                raise CasadiCollocatorException(
                                    "Nominal value for %s is zero." % name)
                    e = 0.
                name_idx_sf_map[name] = n_invariant_var
                n_invariant_var += 1
                invariant_d.append(d)
                invariant_e.append(e)

            self.n_variant_var = n_variant_var
            self.n_invariant_var = n_invariant_var

    def _sample_external_input_trajectory(self, vk, var_index, name, data):
        """
        Sample the external data for one variable.
        """
        traj_min, traj_max = N.inf, -N.inf

        # Sample collocation points
        for i in xrange(1, self.n_e + 1):
            for k in self.time_points[i].keys():
                value = data.eval(self.time_points[i][k])[0, 0]
                if value < traj_min:
                    traj_min = value
                if value > traj_max:
                    traj_max = value
                
                # Write the sampled data to var_map or _par_vals
                if self.mutable_external_data:
                    self._par_vals[self.var_indices[vk][i][k][var_index]] = value
                else:
                    # consider: Could we have var_map[vk][i][k]['all']
                    # be the same array as self.var_map[vk][i][k]
                    # in this case?
                    self.var_map[vk][i][k]['all'][var_index] = value
                    self.var_map[vk][i][k][var_index] = value

        # Check that constrained and eliminated inputs satisfy their bounds
        if vk in ('elim_u', 'constr_u'):
            var = self.op.getVariable(name)
            var_min = self.op.get_attr(var, "min")
            var_max = self.op.get_attr(var, "max")
            if traj_min < var_min:
                raise CasadiCollocatorException(
                    "The trajectory for the measured input " + name +
                    " does not satisfy the input's lower bound.")
            if traj_max > var_max:
                raise CasadiCollocatorException(
                    "The trajectory for the measured input " + name +
                    " does not satisfy the input's upper bound.")

    def _create_external_input_trajectories(self):
        """
        Computes the external input trajectories 
        """        
        # Create measured input trajectories
        if not self.mutable_external_data:
            for vk in ('elim_u', 'constr_u', 'quad_pen'):
                self.var_map[vk] = dict()
                for i in xrange(1, self.n_e + 1):
                    self.var_map[vk][i]=dict()
                    for k in self.time_points[i].keys():
                        self.var_map[vk][i][k] = dict()
                        self.var_map[vk][i][k]['all'] = N.zeros(self.n_var[vk])

        if self.external_data is not None:
            for (vk, source) in (('elim_u', self.external_data.eliminated), 
                                 ('constr_u', self.external_data.constr_quad_pen),
                                 ('quad_pen', self.external_data.quad_pen)):
                for (j, (name, data)) in enumerate(source.items()):
                    self._sample_external_input_trajectory(vk, j, name, data)

    def set_external_variable_data(self, name, data):
        """
        Set new data for one variable that was supplied using the external_data option.

        The option mutable_external_data must be enabled to use this method.
        """
        if name not in self.name_map:
            raise CasadiCollocatorException("No variable " + name + " in model.");

        if name not in self.external_data_name_map:
            raise CasadiCollocatorException(
                "Cannot change external data for variable " + name
                + " since it has no original external data.");

        if not self.mutable_external_data:
            raise CasadiCollocatorException(
                "Cannot update external data unless the mutable_external_data option is set to True.")

        var_index, vk = self.external_data_name_map[name]
        interpolator = _create_trajectory_function(data)
        self._sample_external_input_trajectory(vk, var_index, name, interpolator)


    def _define_l0_functions(self):
        """
        Defines all functions required for the DOP transcription
        
        Declares the level0 constraints and cost terms as casadi functions.
        path constraints
              self.G_e_l0_fcn
              self.G_i_l0_fcn
        point constraints
              self.g_e_l0_fcn
              selfg_i_l0_fcn
        Collocation equation
              self.coll_l0_eq_fcn -> it has a different signature
        Initial function
              self.initial_l0_fcn
        DAE residual
              self.dae_l0_fcn
        Mayer term
              self.mterm_l0_fcn
        Lagrange Term
              self.lterm_l0_fcn 

        The signature of the functions is 
        f(["time", "x", "dx", "unelim_u", "w", "elim_u", "p_fixed", "p_opt"]+["scaling_factor_list"])
        where the first list corresponds to the order in self.mvar_struct.

        if one of the arguments has dimension zero (n_var[vt]=0) then 
        it is skipped and not passed as an argument. The same applies to
        scaling_factor_list if the time_variant scaling mode is not activated

        First, the expressions are scaled accordingly to the scaling
        mode option and then the casadi functions are created and stored
        as attributes of the class. The scaling is also done for the cost 
        expressions, thus this function must be called before the 
        define_cost_ter

        """
        #defines the symbolic input
        s_sym_input = [self.mvar_struct["time"]]
        s_sym_input_no_der = [self.mvar_struct["time"]]
        var_kinds_ordered =copy.copy(self.mvar_struct.keys())
        del var_kinds_ordered[0]
        for vk in var_kinds_ordered:
            if self.n_var[vk]>0:
                s_sym_input.append(self.mvar_struct[vk])
                if vk!="dx":
                    s_sym_input_no_der.append(self.mvar_struct[vk])

        #collocation symbolics
        dx_i_k = self._collocation['dx_i_k']
        x_i = self._collocation['x_i']
        der_vals_k = self._collocation['der_vals_k']
        h_i = self._collocation['h_i']
        scoll_eq = self._collocation['coll_eq']

        if not self.variable_scaling:
            self._eliminate_der_var()
            initial_fcn = self._FXFunction(s_sym_input, [self.initial])
            
            if self.eliminate_der_var:
                print "TODO define input for no derivative mode daeresidual"
                raise NotImplementedError("eliminate_der_ver not supported yet")
            else:
                coll_eq_fcn = self._FXFunction(
                    x_i + [der_vals_k, h_i] + dx_i_k, [scoll_eq])
                coll_eq_fcn.init()
                self.coll_l0_eq_fcn = coll_eq_fcn
                dae_fcn = self._FXFunction(s_sym_input, [self.dae])
        else:
            # Compose scaling factors for collocation equations
            if self.n_var["x"] > 0:
                x_i_d = self.n_var['x'] * [None]
                x_i_e = self.n_var['x'] * [None]
                
                x_i_sf_d = casadi.MX.sym("x_i_sf_d", self.n_cp + 1, self.n_var["x"])
                x_i_sf_e = casadi.MX.sym("x_i_sf_e", self.n_cp + 1, self.n_var["x"])
                dx_i_k_d = self.n_var['dx'] * [None]
                dx_i_k_e = self.n_var['dx'] * [None]
                dx_i_k_sf_d = casadi.MX.sym("dx_i_sf_d", self.n_var["dx"])
                dx_i_k_sf_e = casadi.MX.sym("dx_i_sf_e", self.n_var["dx"])
                var_x_idx = 0
                var_dx_idx = 0
                
                for var in self.mvar_vectors['x']:
                    # State
                    x_name = var.getName()
                    (ind, _) = self.name_map[x_name]
                    
                    x_i_d[ind] = x_i_sf_d[:, var_x_idx]
                    x_i_e[ind] = x_i_sf_e[:, var_x_idx]
                    var_x_idx += 1
                    

                    # State derivative
                    dx_name = var.getMyDerivativeVariable().getName()
                    (ind, _) = self.name_map[dx_name]
                    
                    dx_i_k_d[ind] = dx_i_k_sf_d[var_dx_idx]
                    dx_i_k_e[ind] = dx_i_k_sf_e[var_dx_idx]
                    var_dx_idx += 1
                    
                # Scale collocation equations
                x_i_d = casadi.horzcat(x_i_d)
                x_i_e = casadi.horzcat(x_i_e)
                s_unscaled_var = list(x_i)
                s_scaled_var = [x_i_d * x_i[0] + x_i_e]

                if self.eliminate_der_var:
                    print "TODO collocation inlining derivative"
                    raise NotImplementedError("eliminate_der_var not supported yet")
                else:
                    s_unscaled_var.append(dx_i_k[0])
                    dx_i_k_d = casadi.vertcat(dx_i_k_d)
                    dx_i_k_e = casadi.vertcat(dx_i_k_e)    
                    s_scaled_var.append(dx_i_k_d * dx_i_k[0] + dx_i_k_e)
                    
                    [scoll_eq] = casadi.substitute([scoll_eq], s_unscaled_var,
                                                   s_scaled_var)

            # Compose scaling factors for other expressions           
            sym_sf = casadi.MX.sym("d_i_k", 2*self._var_sf_nbr_vars)
            sz_d = {}
            sz_e = {}
            sz_d["time"]=1.
            sz_e["time"]=0.
            ind = 0            
            for vk in ["x", "dx", "unelim_u", "w", "elim_u", "p_opt"]:
                if self.n_var[vk]>0:
                    sz_d[vk] = self.n_var[vk]*[1]
                    sz_e[vk] = self.n_var[vk]*[0.]
                    for var in self.mvar_vectors[vk]:
                        name = var.getName()
                        (var_index, _) = self.name_map[name]
                        if vk == "elim_u": #Eliminated u's do not have scaling parameters in the NLP
                            d, e = self._get_affine_scaling(name, -1, -1)
                            sz_d[vk][var_index] = d
                            sz_e[vk][var_index] = e
                        else:
                            sz_d[vk][var_index] = sym_sf[ind]
                            sz_e[vk][var_index] = sym_sf[ind+1]
                            ind = ind + 2 

            # Compose scaling factors for timed variables
            timed_var_d = []
            timed_var_e = []
            for tv in self.op.getTimedVariables():
                base_name = tv.getBaseVariable().getName()
                
                if self._using_variant_variable_scaling(base_name):
                    raise NotImplementedError("Currently not supported.")
                    tp = tv.getTimePoint()
                    if self._normalize_min_time:
                        cp = self._tp2cp(tp)
                    else:
                        cp = self.op.evaluateExpression(tp)
                        
                    (i, k) = collocation_constraint_points[tp]
                
                    d, e = self._get_affine_scaling(base_name, i, k)
                else:
                    d, e = self._get_affine_scaling(base_name, -1, -1)
                    
                timed_var_d.append(d)
                timed_var_e.append(e)

            # Scale variables in expressions
            scaled_timed_var = map(
                operator.add,
                map(operator.mul, timed_var_d, self._timed_variables),
                timed_var_e)

            s_scaled_z   = [sz_d["time"] * self.mvar_struct["time"] + sz_e["time"]]
            s_unscaled_z = [self.mvar_struct["time"]]
            
            for vk in ["x", "dx", "unelim_u", "w", "elim_u", "p_opt"]:
                if self.n_var[vk]>0:
                    s_scaled_z.append(casadi.vertcat(sz_d[vk]) * self.mvar_struct[vk] + casadi.vertcat(sz_e[vk]))
                        
                    s_unscaled_z.append(self.mvar_struct[vk])

            s_scaled_var = s_scaled_z + scaled_timed_var
            s_unscaled_var = s_unscaled_z + self._timed_variables

            s_ocp_expressions = [self.initial, self.dae, 
                                 self.path, self.point,
                                 self.mterm, self.lterm]
            s_scaled_expressions = casadi.substitute(s_ocp_expressions,
                                                     s_unscaled_var,
                                                     s_scaled_var)

            # Scale variables in expressions
            if self.eliminate_der_var:
                print "TODO scaling for the additional constraints elim_der_var"
                raise NotImplementedError("eliminate_der_var not supported yet")                

            else:
                [self.initial, self.dae,
                 self.path, self.point,
                 self.mterm, self.lterm] = s_scaled_expressions

            # Create functions
            input_initial_fcn = s_sym_input + ([sym_sf] if sym_sf.shape[0] > 0 else [])
            initial_fcn = self._FXFunction(input_initial_fcn, [self.initial])
                
            if self.eliminate_der_var:
                print "TODO define input for function with no derivatives"
                raise NotImplementedError("eliminate_der_var not supported yet") 
            else:
                var_inputs = x_i + [der_vals_k, h_i] + dx_i_k
                if self.n_var["x"] > 0:
                    var_inputs += [x_i_sf_d]+[x_i_sf_e]+[dx_i_k_sf_d]+[dx_i_k_sf_e]
                
                coll_eq_fcn = self._FXFunction(var_inputs, [scoll_eq])

                coll_eq_fcn.setOption("name", "coll_l0_eq_fcn")
                coll_eq_fcn.init()
                self.coll_l0_eq_fcn = coll_eq_fcn

                input_dae_fcn = s_sym_input + ([sym_sf] if sym_sf.shape[0] > 0 else [])
                dae_fcn = self._FXFunction(input_dae_fcn, [self.dae])

        # Initialize functions
        initial_fcn.setOption("name", "initial_l0_fcn")
        initial_fcn.init()
        self.initial_l0_fcn =  initial_fcn
        dae_fcn.setOption("name", "dae_l0_fcn")
        dae_fcn.init()
        self.dae_l0_fcn = dae_fcn

        # Manipulate and sort path constraints
        g_e = []
        g_i = []
        self.path_eq_orig = []
        self.path_ineq_orig = []
        for (res, cnstr) in itertools.izip(self.path, self.op.getPathConstraints()):
            if cnstr.getType() == cnstr.EQ:
                g_e.append(res)
                self.path_eq_orig.append(cnstr)
            elif cnstr.getType() == cnstr.LEQ:
                g_i.append(res)
                self.path_ineq_orig.append(cnstr)
            elif cnstr.getType() == cnstr.GEQ:
                g_i.append(-res)
                self.path_ineq_orig.append(cnstr)

        # Create path constraint functions
        s_path_constraint_input = []
        if self.eliminate_der_var:
            print "TODO define input for function with no derivatives"
            raise NotImplementedError("named_vars not supported yet") 
        else:
            s_path_constraint_input += s_sym_input
        s_path_constraint_input += self._timed_variables

        if self.variable_scaling:
            if sym_sf.shape[0] > 0:
                s_path_constraint_input.append(sym_sf)


        g_e_fcn = self._FXFunction(s_path_constraint_input,
                                   [casadi.vertcat(g_e)])
        g_i_fcn = self._FXFunction(s_path_constraint_input,
                                   [casadi.vertcat(g_i)])


        g_e_fcn.setOption("name", "g_e_l0_fcn")
        g_e_fcn.init()
        g_i_fcn.setOption("name", "g_i_l0_fcn")
        g_i_fcn.init()
        self.g_e_l0_fcn = g_e_fcn
        self.g_i_l0_fcn = g_i_fcn

        # Manipulate and sort point constraints
        G_e = []
        G_i = []
        self.point_eq_orig = []
        self.point_ineq_orig = []
        for (res, cnstr) in itertools.izip(self.point,
                                           self.op.getPointConstraints()):
            if cnstr.getType() == cnstr.EQ:
                G_e.append(res)
                self.point_eq_orig.append(cnstr)
            elif cnstr.getType() == cnstr.LEQ:
                G_i.append(res)
                self.point_ineq_orig.append(cnstr)
            elif cnstr.getType() == cnstr.GEQ:
                G_i.append(-res)
                self.point_ineq_orig.append(cnstr)

        # Create point constraint functions
        # Note that sym_input is needed as input since the point constraints
        # may depend on free parameters
        s_point_constraint_input = s_sym_input_no_der + self._timed_variables

        # Add scaling factors for free parameters
        if self.variable_scaling:
            if sym_sf.shape[0] > 0:
                s_point_constraint_input.append(sym_sf)

        G_e_fcn = self._FXFunction(s_point_constraint_input,
                                   [casadi.vertcat(G_e)])
        G_i_fcn = self._FXFunction(s_point_constraint_input,
                                   [casadi.vertcat(G_i)])

        G_e_fcn.setOption("name", "G_e_l0_fcn")
        G_e_fcn.init()
        G_i_fcn.setOption("name", "G_i_l0_fcn")
        G_i_fcn.init()
        self.G_e_l0_fcn = G_e_fcn
        self.G_i_l0_fcn = G_i_fcn
        
        # Solution for eliminated variables NOT SCALED. CALLED AFTER RE-SCALE SOLUTION
        elimination_fcn = self._FXFunction(s_sym_input,[self.elimination])
        elimination_fcn.setOption("name","eliminated_variables_solution_fcn")
        elimination_fcn.init()
        self.elimination_fcn = elimination_fcn

        #Define cost terms
        s_sym_input = [self.mvar_struct["time"]]
        s_sym_input_no_der = [self.mvar_struct["time"]]
        for vk in ["x", "dx", "unelim_u", "w",  "elim_u", "p_fixed", "p_opt"]:
            if self.n_var[vk]>0:
                s_sym_input.append(self.mvar_struct[vk])
                if vk!="dx":
                    s_sym_input_no_der.append(self.mvar_struct[vk])

        # Mayer term
        if not self.mterm.isConstant() or self.mterm.getValue() != 0.:
            # Create function for evaluation of Mayer term
            s_mterm_input = s_sym_input_no_der + self._timed_variables
            if self.variable_scaling:
                if sym_sf.shape[0] > 0:
                    s_mterm_input.append(sym_sf)
            
            mterm_fcn = self._FXFunction(s_mterm_input, [self.mterm])
            mterm_fcn.setOption("name", "mterm_l0_fcn")
            mterm_fcn.init()
            self.mterm_l0_fcn = mterm_fcn

        # Lagrange term
        if not self.lterm.isConstant() or self.lterm.getValue() != 0.:
            # Create function for evaluation of Lagrange integrand
            if self.eliminate_der_var:
                print "TODO lagrange input no derivative mode"
                raise NotImplementedError("eliminate_der_var not supported yet")                
            else:
                s_fcn_input = s_sym_input
                s_fcn_input += self._timed_variables
            if self.variable_scaling:
                if sym_sf.shape[0] > 0:
                    s_fcn_input.append(sym_sf)
            lterm_fcn = self._FXFunction(s_fcn_input, [self.lterm])
            lterm_fcn.setOption("name", "lterm_l0_fcn")
            lterm_fcn.init()
            self.lterm_l0_fcn = lterm_fcn
            
        

    def _define_l1_functions(self):
        """
        Defines checkpointed functions.
        
        Declares the level1 constraints and cost terms as casadi functions.
        Collocation equation
              self.coll_l1_eq_fcn -> it has a different signature
        DAE residual
              self.dae_l1_fcn
        Lagrange Term
              self.lterm_l1_fcn 

        The signature of the functions is 
        f(["time", "x", "dx", "unelim_u", "w", "elim_u", "p_fixed", "p_opt"]+["scaling_factor_list"])

        if one of the arguments has dimension zero (n_var[vt]=0) then 
        it is skipped and not passed as an argument. The same applies to
        scaling_factor_list if the time_variant scaling mode is not activated

        These functions recieve variables that contain all the collocation
        points of a certain element i. The idea is to set up all the collocation
        points of a certain element by calling a single function per element.
        """     
        # Define the symbolic input for level 1 functions
        l1_mvar_struct = OrderedDict()
        l1_mvar_struct["time"] = casadi.MX.sym("timel1", self.n_cp)
        additional_p = 2 if self.is_gauss else 1
        l1_mvar_struct["x"] = casadi.MX.sym("xl1", 
                                          self.n_var['x']*(self.n_cp+additional_p))
        l1_mvar_struct["dx"] = casadi.MX.sym("dxl1", 
                                           self.n_var['dx']*self.n_cp)
        l1_mvar_struct["unelim_u"] = casadi.MX.sym("unelim_u", 
                                                 self.n_var['unelim_u']*self.n_cp)
        l1_mvar_struct["w"] = casadi.MX.sym("wl1", 
                                          self.n_var['w']*self.n_cp)
        l1_mvar_struct["elim_u"] = casadi.MX.sym("elim_ul1", 
                                               self.n_var['elim_u']*self.n_cp)
        l1_mvar_struct["p_fixed"] = casadi.MX.sym("p_fixed_l1", self.n_var['p_fixed'])
        l1_mvar_struct["p_opt"] = casadi.MX.sym("p_opt_l1", self.n_var['p_opt'])
        inputs_order_map=OrderedDict()
        inputs_order_map_no_der=OrderedDict()
        s_sym_input_l1 = [l1_mvar_struct["time"]]
        s_sym_input_l1_no_der = [l1_mvar_struct["time"]]
        inputs_order_map["time"]=0
        inputs_order_map_no_der["time"]=0
        var_kinds_ordered =copy.copy(l1_mvar_struct.keys())
        del var_kinds_ordered[0]
        for vk in var_kinds_ordered:
            if self.n_var[vk]>0:
                inputs_order_map[vk]=len(s_sym_input_l1)
                s_sym_input_l1.append(l1_mvar_struct[vk])

                if vk!="dx":
                    inputs_order_map_no_der[vk]=len(s_sym_input_l1_no_der)
                    s_sym_input_l1_no_der.append(l1_mvar_struct[vk])

        # Build lists of collocation point variables
        empty_list = [[] for i in range(self.n_cp)]
        x_col = casadi.vertsplit(s_sym_input_l1[inputs_order_map["x"]], 
                                 self.n_var['x'])
        dx_col = casadi.vertsplit(s_sym_input_l1[inputs_order_map["dx"]], 
                                  self.n_var['dx'])
        unu_col = casadi.vertsplit(s_sym_input_l1[inputs_order_map["unelim_u"]], 
                                   self.n_var['unelim_u']) \
            if self.n_var['unelim_u']>0 else empty_list
        w_col = casadi.vertsplit(s_sym_input_l1[inputs_order_map["w"]], 
                                 self.n_var['w']) \
            if self.n_var['w']>0 else empty_list 
        elu_col = casadi.vertsplit(s_sym_input_l1[inputs_order_map["elim_u"]], 
                                   self.n_var['elim_u']) \
            if self.n_var['elim_u']>0 else empty_list
        no_boundaries_x_col = list(copy.copy(x_col))
        del no_boundaries_x_col[0]
        if self.is_gauss:
            del no_boundaries_x_col[-1]
        x_col = [[x_col[k]] for k in range(self.n_cp+additional_p)]
        dx_col = [[dx_col[k]] for k in range(self.n_cp)]
        unu_col = [[unu_col[k]] for k in range(self.n_cp)] \
            if self.n_var['unelim_u']>0 else unu_col
        w_col = [[w_col[k]] for k in range(self.n_cp)] \
            if self.n_var['w']>0 else w_col
        elu_col = [[elu_col[k]] for k in range(self.n_cp)] \
            if self.n_var['elim_u']>0 else elu_col        
        no_boundaries_x_col = [[no_boundaries_x_col[k]] for k in range(self.n_cp)]
        time_col = casadi.vertsplit(s_sym_input_l1[inputs_order_map["time"]])
        time_col = [[time_col[k]] for k in range(self.n_cp)]

        # Create gauss quadrature weights symbolic variable
        sym_g_weights = casadi.MX.sym("Gauss_wj", self.n_cp)

        # Create parameters symbolic variable
        p_fixed = [l1_mvar_struct["p_fixed"]] if self.n_var['p_fixed']>0 else []
        p_opt=[l1_mvar_struct["p_opt"]] if self.n_var['p_opt']>0 else []

        # Prepare input for collocation equation (level 0 functions)
        no_rboundary_x = casadi.vertsplit(
            s_sym_input_l1[inputs_order_map["x"]], 
            self.n_var['x']*(self.n_cp+1))
        x_i = [casadi.reshape(no_rboundary_x[0], (self.n_var["x"], self.n_cp + 1)).T]
        element_der_vals = casadi.MX.sym(
            "der_vals_l1", self.n_var["x"]*(self.n_cp + 1)*(self.n_cp))
        der_vals_col = casadi.vertsplit(element_der_vals,
                                        self.n_var["x"]*(self.n_cp + 1))
        der_vals_col = [[casadi.reshape(der_vals_col[k],
                                        (self.n_var["x"], self.n_cp + 1)).T]
                        for k in range(self.n_cp)]
        h_i = casadi.MX.sym("h_i")
        dx_i = casadi.MX.sym("dx_i_k", self.n_var["x"]*(self.n_cp))
        dx_i_col = casadi.vertsplit(dx_i, self.n_var["x"])
        dx_i_col = [[dx_i_col[k]] for k in range(self.n_cp)]

        if not self.variable_scaling:
            if self.eliminate_der_var:
                print "TODO define input for no derivative mode daeresidual with check_point"
                raise NotImplementedError("eliminate_der_ver not supported yet with check_point")
            else:
                # Define functions output
                output_dae_element = list()
                output_coll_element = list()
                lagTerms = list()
                for k in range(self.n_cp):
                    # Call level0 DAEResidual
                    input_l0_fcn = time_col[k]+no_boundaries_x_col[k]\
                        +dx_col[k]+unu_col[k]+w_col[k]+elu_col[k]+p_fixed+p_opt
                    [dae_k] = self.dae_l0_fcn.call(input_l0_fcn)
                    output_dae_element.append(dae_k)
                    # Call level0 Collocations
                    input_l0_coll_fcn = x_i + der_vals_col[k] + \
                        [h_i] + dx_i_col[k]
                    [coll_k] = self.coll_l0_eq_fcn.call(input_l0_coll_fcn)
                    output_coll_element.append(coll_k)
                    if not self.lterm.isConstant() or self.lterm.getValue() != 0.:
                        # Call level0 lagrange
                        input_l0_fcn += self._timed_variables
                        [lag_k] = self.lterm_l0_fcn.call(input_l0_fcn)
                        lagTerms.append(lag_k)

                # Define DAEResideual level1
                input_dae_l1 = s_sym_input_l1
                output_dae_element = casadi.vertcat(output_dae_element)
                dae_l1_fcn = casadi.MXFunction(input_dae_l1,
                                               [output_dae_element])
                dae_l1_fcn.setOption("name", "dae_l1_fcn")
                dae_l1_fcn.init()
                self.dae_l1_fcn = dae_l1_fcn

                # Define Collocation equation level1
                output_coll_element = casadi.vertcat(output_coll_element)
                coll_eq_l1_fcn = casadi.MXFunction([l1_mvar_struct["x"]]\
                                                   +[element_der_vals,h_i]\
                                                   +[dx_i],
                                                   [output_coll_element])
                coll_eq_l1_fcn.setOption("name", "coll_l1_eq_fcn")
                coll_eq_l1_fcn.init()                
                self.coll_eq_l1_fcn = coll_eq_l1_fcn

                if not self.lterm.isConstant() or self.lterm.getValue() != 0.:
                    # Define Lagrange term level1
                    lagTerms= casadi.horzcat(lagTerms)
                    output_lag_element = casadi.mul(lagTerms, sym_g_weights)
                    input_lterm_l1 = [sym_g_weights]
                    input_lterm_l1 += s_sym_input_l1
                    input_lterm_l1 += self._timed_variables
                    lterm_l1 = casadi.MXFunction(input_lterm_l1,
                                                 [output_lag_element])
                    lterm_l1.setOption("name", "lterm_l1_fcn")
                    lterm_l1.init()
                    self.lterm_l1 = lterm_l1
        else:
            # Define symbolic scaling factors for dae
            sym_l1_sf = casadi.MX.sym("d_i_k_sf", 2*self._var_sf_nbr_vars*self.n_cp)
            sym_sf_col = casadi.vertsplit(sym_l1_sf, 2*self._var_sf_nbr_vars) if sym_l1_sf.shape[0]>0 else empty_list
            sym_sf_col = [[sym_sf_col[k]] for k in range(self.n_cp)] if sym_l1_sf.shape[0]>0 else sym_sf_col
            
            # Define scaling factors for collocation equation
            x_i_sf_d = casadi.MX.sym("x_i_sf_d", (self.n_cp + 1)*self.n_var["x"])
            x_i_sf_e = casadi.MX.sym("x_i_sf_e", (self.n_cp + 1)*self.n_var["x"])
            x_i_sf_d_r = [casadi.reshape(x_i_sf_d, (self.n_var["x"], self.n_cp + 1)).T] if x_i_sf_d.shape[0]>0 else []
            x_i_sf_e_r = [casadi.reshape(x_i_sf_e, (self.n_var["x"], self.n_cp + 1)).T] if x_i_sf_e.shape[0]>0 else []

            sdx_sf_d_i = casadi.MX.sym("dx_i_sf_d", self.n_var["dx"]*self.n_cp)
            sdx_sf_e_i = casadi.MX.sym("dx_i_sf_e", self.n_var["dx"]*self.n_cp)
            sdx_sf_d_col = map(list,casadi.vertsplit(sdx_sf_d_i, self.n_var["dx"])) if sdx_sf_d_i.shape[0]>0 else empty_list
            sdx_sf_d_col = [[casadi.vertcat(sdx_sf_d_col[k])] for k in range(self.n_cp)]             if sdx_sf_d_i.shape[0]>0 else sdx_sf_d_col
            sdx_sf_e_col = map(list,casadi.vertsplit(sdx_sf_e_i, self.n_var["dx"])) if sdx_sf_e_i.shape[0]>0 else empty_list
            sdx_sf_e_col = [[casadi.vertcat(sdx_sf_e_col[k])] for k in range(self.n_cp)]             if sdx_sf_e_i.shape[0]>0 else sdx_sf_e_col

            if self.eliminate_der_var:
                print "TODO define input for no derivative mode daeresidual"
                raise NotImplementedError("eliminate_der_ver not supported yet")
            else:
                # Define functions
                output_dae_element = list()
                output_coll_element = list()
                lagTerms = list()
                for k in range(self.n_cp):
                    # Call level1 Collocations
                    input_l0_fcn = time_col[k]+no_boundaries_x_col[k]\
                        +dx_col[k]+unu_col[k]+w_col[k]+elu_col[k]+p_fixed+p_opt\
                        +sym_sf_col[k]
                    [dae_k]=self.dae_l0_fcn.call(input_l0_fcn)
                    output_dae_element.append(dae_k)

                    # Call level0 Collocations
                    input_l0_coll_fcn = x_i + der_vals_col[k] + \
                        [h_i] + dx_i_col[k] + \
                        x_i_sf_d_r+x_i_sf_e_r + sdx_sf_d_col[k]+sdx_sf_e_col[k]
                        
                    [coll_k] = self.coll_l0_eq_fcn.call(input_l0_coll_fcn)
                    output_coll_element.append(coll_k)

                    if not self.lterm.isConstant() or self.lterm.getValue() != 0.:
                        #call level0 lagrange
                        input_l0_fcn = time_col[k]+no_boundaries_x_col[k]\
                            +dx_col[k]+unu_col[k]+w_col[k]+elu_col[k]+p_fixed+p_opt\
                            + self._timed_variables +sym_sf_col[k]
                        [lag_k] = self.lterm_l0_fcn.call(input_l0_fcn)
                        lagTerms.append(lag_k)

                # Define DAEResidual level1    
                output_dae_element = casadi.vertcat(output_dae_element)
                input_dae_l1 = copy.copy(s_sym_input_l1)
                if sym_l1_sf.shape[0]>0:
                    input_dae_l1 += [sym_l1_sf]
                
                dae_l1_fcn = casadi.MXFunction(input_dae_l1,
                                               [output_dae_element])
                dae_l1_fcn.setOption("name", "dae_l1_fcn")
                dae_l1_fcn.init()                    
                self.dae_l1_fcn = dae_l1_fcn

                # Define Collocation equation level1
                output_coll_element = casadi.vertcat(output_coll_element)
                var_inputs = [l1_mvar_struct["x"]]+[element_der_vals,h_i]+[dx_i]
                if x_i_sf_d.shape[0] > 0:
                    var_inputs += [x_i_sf_d] + [x_i_sf_e]
                if sdx_sf_d_i.shape[0] > 0:
                    var_inputs += [sdx_sf_d_i] + [sdx_sf_e_i]
                
                coll_eq_l1_fcn = casadi.MXFunction(var_inputs, [output_coll_element])
                coll_eq_l1_fcn.setOption("name", "coll_l1_eq_fcn")
                coll_eq_l1_fcn.init() 
                self.coll_eq_l1_fcn = coll_eq_l1_fcn 

                if not self.lterm.isConstant() or self.lterm.getValue() != 0.:
                    # Define Lagrange term level1    
                    lagTerms= casadi.horzcat(lagTerms)
                    output_lag_element = casadi.mul(lagTerms, sym_g_weights)
                    input_lterm_l1 = [sym_g_weights]
                    input_lterm_l1 += copy.copy(s_sym_input_l1)
                    input_lterm_l1 += copy.copy(self._timed_variables)
                    if sym_l1_sf.shape[0]>0:
                        input_lterm_l1 += [sym_l1_sf]
                    lterm_l1 = casadi.MXFunction(input_lterm_l1,
                                                 [output_lag_element])
                    lterm_l1.setOption("name", "lterm_l1_fcn")
                    lterm_l1.init()
                    self.lterm_l1 = lterm_l1

    def _add_c(self, kind, eqtype, pos, i, k):
        """
        Record origin of a block of residuals in self.c_e or self.c_i
        """
        n_eq = pos[1] - pos[0]
        if n_eq == 0:
            return # don't record empty residuals
        if eqtype not in self.c_dests:
            dest = self.c_dests[eqtype] = {'kind':kind, 'n_eq':n_eq, 'i':[], 'k':[], 'inds':[]}
        else:
            dest = self.c_dests[eqtype]
        
        assert dest['kind'] == kind, ("Residual type '" + eqtype +
            "' previously recorded as kind '" + dest['kind'] +
            "' cannot record it as kind '" + kind + "'")
        assert dest['n_eq'] == n_eq, ("Residual type '" + eqtype +
            "' previously recorded with " + repr(dest['n_eq']) +
            "equations per point, cannot record it with " + repr(n_eq))

        dest['i'].append(i)
        dest['k'].append(k)
        dest['inds'].append(N.arange(pos[0], pos[1], dtype=N.int))

    def add_c_eq(self, eqtype, constr, i=-1, k=-1):
        """
        Add a block of equality constraints to self.c_e

        The constraint

            constr == 0

        should be instantiated from the given equation type at the given
        i and k (use default value -1 if a value for i or k does not apply).
        """
        j0 = self.c_e.numel()
        self.c_e.append(constr)
        j1 = self.c_e.numel()
        self._add_c('eq', eqtype, (j0, j1), i, k)

    def add_c_ineq(self, eqtype, constr, i=-1, k=-1):
        """
        Add a block of inequality constraints to self.c_i

        The constraint on constr should be instantiated from the given
        equation type at the given i and k (use default value -1 if a value
        for i or k does not apply).
        """
        j0 = self.c_i.numel()
        self.c_i.append(constr)
        j1 = self.c_i.numel()
        self._add_c('ineq', eqtype, (j0, j1), i, k)

    def add_c_eq_l1(self, eqtype, constr, i=-1):
        """
        Add a block of l1 equality constraints to self.c_e

        The constraint

            constr == 0

        should be instantiated from the given equation type at the given i
        and be the concatenation of one constraint for each collocation point
        (use the default value -1 for i if a value does not apply).
        """
        j0 = self.c_e.numel()
        self.c_e.append(constr)
        j1 = self.c_e.numel()
        n = (j1-j0)//self.n_cp
        assert n*self.n_cp == j1-j0
        for k in xrange(1, self.n_cp+1):
            self._add_c('eq', eqtype, (j0+(k-1)*n, j0+k*n), i, k)
            
    def _index_collocation_scale_factors_level_0(self):
        coll_sf = {}
        
        # Index collocation equation scale factors
        if self.variable_scaling:
            
            for i in xrange(1, self.n_e + 1):
                coll_sf[i] = {}
                coll_sf[i]['x_d'] = []
                coll_sf[i]['x_e'] = []
                coll_sf[i]['dx_d'] = {}
                coll_sf[i]['dx_e'] = {}
                for k in xrange(1, self.n_cp + 1):
                    coll_sf[i]['dx_d'][k] = []
                    coll_sf[i]['dx_e'][k] = []
                    
            for var in self.mvar_vectors['x']:
                x_name = var.getName()
                dx_name = var.getMyDerivativeVariable().getName()

                # States
                
                # First element
                i = 1
                coll_sf[i]['x_d'].append([])
                coll_sf[i]['x_e'].append([])
                
                d, e = self._get_affine_scaling_symbols(x_name, i, 0)
                coll_sf[i]['x_d'][-1].append(d)
                coll_sf[i]['x_e'][-1].append(e)
                
                for k in xrange(1, self.n_cp + 1):
                    d, e = self._get_affine_scaling_symbols(x_name, i, k)
                    coll_sf[i]['x_d'][-1].append(d)
                    coll_sf[i]['x_e'][-1].append(e)
                coll_sf[i]['x_d'][-1] = casadi.vertcat(coll_sf[i]['x_d'][-1])
                coll_sf[i]['x_e'][-1] = casadi.vertcat(coll_sf[i]['x_e'][-1])

                # Succeeding elements
                for i in xrange(2, self.n_e + 1):
                    k = self.n_cp + self.is_gauss
                    coll_sf[i]['x_d'].append([])
                    coll_sf[i]['x_e'].append([])
                    
                    d, e = self._get_affine_scaling_symbols(x_name, i-1, k)
                    coll_sf[i]['x_d'][-1].append(d)
                    coll_sf[i]['x_e'][-1].append(e)
                    
                    for k in xrange(1, self.n_cp + 1):
                        d, e = self._get_affine_scaling_symbols(x_name, i, k)
                        coll_sf[i]['x_d'][-1].append(d)
                        coll_sf[i]['x_e'][-1].append(e)
                    coll_sf[i]['x_d'][-1] = casadi.vertcat(coll_sf[i]['x_d'][-1])
                    coll_sf[i]['x_e'][-1] = casadi.vertcat(coll_sf[i]['x_e'][-1])

                # State derivatives
                for i in xrange(1, self.n_e + 1):
                    for k in xrange(1, self.n_cp + 1):
                        d, e = self._get_affine_scaling_symbols(dx_name, i, k)
                        coll_sf[i]['dx_d'][k].append(d)
                        coll_sf[i]['dx_e'][k].append(e)
            
        self.coll_sf = coll_sf
        return coll_sf

    def _index_collocation_scale_factors_level_1(self):
        coll_l1_sf = {}
        
        # Index collocation equation scale factors
        if self.variable_scaling:
            for i in xrange(1, self.n_e + 1):
                coll_l1_sf[i] = {}
                if i==1:
                    coll_l1_sf[i]['x_d'] = []
                    coll_l1_sf[i]['x_e'] = []
                    for var in self.mvar_vectors['x']:
                        x_name = var.getName()
                        dx_name = var.getMyDerivativeVariable().getName()
                        
                        d, e = self._get_affine_scaling_symbols(x_name, i, 0)
                        coll_l1_sf[i]['x_d'].append(d)
                        coll_l1_sf[i]['x_e'].append(e)
                            
                else:
                    k = self.n_cp + self.is_gauss
                    coll_l1_sf[i]['x_d'] = []
                    coll_l1_sf[i]['x_e'] = []
                    for var in self.mvar_vectors['x']:
                        x_name = var.getName()
                        dx_name = var.getMyDerivativeVariable().getName()
                        
                        d, e = self._get_affine_scaling_symbols(x_name, i-1, k)
                        coll_l1_sf[i]['x_d'].append(d)
                        coll_l1_sf[i]['x_e'].append(e)
                            
                coll_l1_sf[i]['dx_d'] = []
                coll_l1_sf[i]['dx_e'] = []

            #level 1 scaling factor lists for Collocation equation
            for k in xrange(1, self.n_cp + 1):
                for var in self.mvar_vectors['x']:
                    x_name = var.getName()
                    dx_name = var.getMyDerivativeVariable().getName()
                    
                    for i in xrange(1, self.n_e + 1):
                        d, e = self._get_affine_scaling_symbols(x_name, i, k)
                        coll_l1_sf[i]['x_d'].append(d)
                        coll_l1_sf[i]['x_e'].append(e)
                        
                    for i in xrange(1, self.n_e + 1):
                        d, e = self._get_affine_scaling_symbols(dx_name, i, k)
                        coll_l1_sf[i]['dx_d'].append(d)
                        coll_l1_sf[i]['dx_e'].append(e)
                                
        self.coll_l1_sf = coll_l1_sf
        return coll_l1_sf
    
    def _call_functions(self):
        """
        Call common functions for level 1 and level 0
        """
        
        # Broadcast self.pol.der_vals
        # Note that der_vals is quite different from self.pol.der_vals
        der_vals = []
        self.der_vals = der_vals

        for k in xrange(self.n_cp + 1):
            #Done like this because of casadi update. This can be improved
            der_vals_k = [self.pol.der_vals[:, k].T.reshape([1, self.n_cp + 1]).T]
            der_vals_k *= self.n_var['x']            
            der_vals.append(casadi.horzcat(der_vals_k))

        # Create list of state matrices
        x_list = [[]]
        self.x_list = x_list        

        for i in xrange(1, self.n_e + 1):
            x_i = [self.var_map['x'][i][k]['all'].T for k in xrange(self.n_cp + 1)]
            x_i = [casadi.vertcat(x_i)]
            x_list.append(x_i)
                            
        # Create constraint storage
        self.c_e = c_e = casadi.MX()
        self.c_i = c_i = casadi.MX()
        # Create storage to track connection between nlp constraints and equations
        # NB: internal format of c_dests is subject to change!
        self.c_dests = {} # map from equation types to nlp constraints

        # Initial conditions
        i = 1
        k = 0
        s_fcn_input = self._get_z_l0(i, k)
        if self.variable_scaling:
            s_fcn_input += self._get_affine_scaling_symbols_communication_point(i, k)

        [initial_constr] = self.initial_l0_fcn.call(s_fcn_input)
        self.add_c_eq('initial', initial_constr, i, k)
        if self.eliminate_der_var:
            print "Call the additional equations for no derivative mode"
            raise NotImplementedError("named_vars not supported yet")
        else:
            [dae_t0_constr] = self.dae_l0_fcn.call(s_fcn_input)
        self.add_c_eq('dae', dae_t0_constr, i, k)

        if self.blocking_factors is None:
            inp_list = [inp.getName() for inp in self.mvar_vectors['unelim_u']]
        else:
            inp_list = [inp.getName() for inp in self.mvar_vectors['unelim_u'] 
                   if not self.blocking_factors.factors.has_key(inp.getName())]

        for name in inp_list:
            # Evaluate u_1_0 based on polynomial u_1
            u_1_0 = 0
            input_index = self.name_map[name][0]

            for k in xrange(1, self.n_cp + 1):
                u_1_0 += (self.pol.eval_basis(k, 0, False) *
                          self.var_map['unelim_u'][1][k][input_index])

            # Add residual for u_1_0 as constraint
            u_1_0_constr = self.var_map['unelim_u'][1][0][input_index] - u_1_0
            self.add_c_eq('u_1_0', u_1_0_constr, i=1, k=0)

        # Continuity constraints for x_{i, n_cp + 1}
        if self.is_gauss:
            if self.quadrature_constraint:
                for i in xrange(1, self.n_e + 1):
                    # Evaluate x_{i, n_cp + 1} based on quadrature
                    x_i_np1  = []
                    x_i_np2  = []
                    dx_i_np1 = []
                    
                    for var in self.mvar_vectors['x']:
                        x_i_np1.append(0.0)
                        x_i_np2.append(0.0)
                        dx_i_np1.append(0.0)
                        
                        # State
                        x_name = var.getName()
                        (ind_x, _) = self.name_map[x_name]
                        
                        # State derivative
                        dx_name = var.getMyDerivativeVariable().getName()
                        (ind_dx, _) = self.name_map[dx_name]
                    
                        for k in xrange(1, self.n_cp + 1):
                            if self.variable_scaling:
                                dx_i_np1[-1] += self.pol.w[k] * self._get_unscaled_expr_symbols(dx_name, i, k)
                            else:
                                dx_i_np1[-1] += self.pol.w[k] * self.var_map['dx'][i][k][ind_dx]
                        
                        if self.variable_scaling:
                            x_i_np1[-1] += self._get_unscaled_expr_symbols(x_name, i, 0)
                            x_i_np2[-1] += self._get_unscaled_expr_symbols(x_name, i, self.n_cp + 1)
                        else:
                            x_i_np1[-1] += self.var_map['x'][i][0][ind_x]
                            x_i_np2[-1] += self.var_map['x'][i][self.n_cp + 1][ind_x]
                    
                        x_i_np1[-1] += self.horizon * self.h[i] * dx_i_np1[-1]

                    # Add residual for x_i_np1 as constraint
                    quad_constr = casadi.vertcat([x_i_np2[jk] - x_i_np1[jk] for jk in range(len(x_i_np1))])
                    self.add_c_eq('continuity', quad_constr, i)
            else:
                for i in xrange(1, self.n_e + 1):
                    # Evaluate x_{i, n_cp + 1} based on polynomial x_i
                    x_i_np1 = 0
                    for k in xrange(self.n_cp + 1):
                        x_i_np1 += self.var_map['x'][i][k]['all'] * self.pol.eval_basis(
                            k, 1, True)

                    # Add residual for x_i_np1 as constraint
                    quad_constr = self.var_map['x'][i][self.n_cp + 1]['all'] - x_i_np1
                    self.add_c_eq('continuity', quad_constr, i)

        # Constraints for terminal values
        if self.is_gauss:
            for var_type in ['unelim_u', 'w']:
                # Evaluate xx_{n_e, n_cp + 1} based on polynomial xx_{n_e}
                xx_ne_np1 = 0
                for k in xrange(1, self.n_cp + 1):
                    xx_ne_np1 += (self.var_map[var_type][self.n_e][k]['all'] *
                                  self.pol.eval_basis(k, 1, False))

                # Add residual for xx_ne_np1 as constraint
                term_constr = (self.var_map[var_type][self.n_e][self.n_cp + 1]['all'] -
                               xx_ne_np1)
                self.add_c_eq('terminal_' + var_type, term_constr, i=self.n_e, k=self.n_cp+1)
            if not self.eliminate_der_var:
                # Evaluate dx_{n_e, n_cp + 1} based on polynomial x_{n_e}
                dx_ne_np1 = 0
                for k in xrange(self.n_cp + 1):
                    x_ne_k = self.var_map['x'][self.n_e][k]['all']
                    dx_ne_np1 += (1. / (self.horizon * self.h[self.n_e]) *
                                  x_ne_k * self.pol.eval_basis_der(k, 1))

                # Add residual for dx_ne_np1 as constraint
                term_constr_dx = (self.var_map['dx'][self.n_e][self.n_cp + 1]['all'] -
                                  dx_ne_np1)
                self.add_c_eq('terminal_dx', term_constr_dx, i=self.n_e, k=self.n_cp+1)

        # Element length constraints
        if self.hs == "free":
            h_constr = casadi.sumRows(self.h[1:]) - 1
            self.add_c_eq('h_sum', h_constr)
            
        # Path constraints
        for i in xrange(1, self.n_e + 1):
            for k in self.time_points[i].keys():
                s_fcn_input = []
                if self.eliminate_der_var:
                    print "TODO path constraints eliminate derivative mode"
                    raise NotImplementedError("eliminate_der_var not supported yet")
                else:
                    s_fcn_input += self._get_z_l0(i, k)
                s_fcn_input += self._nlp_timed_variables
                if self.variable_scaling:
                    s_fcn_input += self._get_affine_scaling_symbols_communication_point(i, k)

                [g_e_constr] = self.g_e_l0_fcn.call(s_fcn_input)
                [g_i_constr] = self.g_i_l0_fcn.call(s_fcn_input)

                self.add_c_eq(  'path_eq',   g_e_constr, i, k)
                self.add_c_ineq('path_ineq', g_i_constr, i, k)
                
        # Point constraints
        s_fcn_input = self._get_z_l0(i, k, with_der=False)
        s_fcn_input += self._nlp_timed_variables
        if self.variable_scaling:
            # Get scaling factors for free parameters.
            scaling_symbols = self._get_affine_scaling_symbols_communication_point(1, 1)
            s_fcn_input += scaling_symbols
        [G_e_constr] = self.G_e_l0_fcn.call(s_fcn_input)
        [G_i_constr] = self.G_i_l0_fcn.call(s_fcn_input)

        self.add_c_eq(  'point_eq',   G_e_constr)
        self.add_c_ineq('point_ineq', G_i_constr)

        # Check that only inputs are constrained or eliminated
        if self.external_data is not None:
            for var_name in (self.external_data.eliminated.keys() +
                             self.external_data.constr_quad_pen.keys()):
                (_, vt) = self.name_map[var_name]
                if vt not in ['elim_u', 'unelim_u']:
                    if var_name in self.external_data.eliminated.keys():
                        msg = ("Eliminated variable " + var_name + " is " +
                               "either not an input or in the model at all.")
                    else:
                        msg = ("Constrained variable " + var_name + " is " +
                               "either not an input or in the model at all.")
                    raise jmiVariableNotFoundError(msg) 

        # Equality constraints for constrained inputs
        if self.external_data is not None:
            for i in xrange(1, self.n_e + 1):
                for k in xrange(1, self.n_cp + 1):
                    for j in xrange(len(self.external_data.constr_quad_pen)):
                        # Retrieve variable and value
                        name = self.external_data.constr_quad_pen.keys()[j]
                        #constr_var = self._get_unscaled_expr(name, i, k)
                        constr_var = self._get_unscaled_expr_symbols(name, i, k)
                        constr_val = self.var_map['constr_u'][i][k]['all'][j]                            

                        # Add constraint
                        input_constr = constr_var - constr_val
                        c_e.append(input_constr)
                        
        # Equality constraints for delayed feedback
        if self.delayed_feedback is not None:

            # Check for unsupported cases
            if self.blocking_factors is not None: raise CasadiCollocatorException(
                "Blocking factors are not supported with delayed feedback.")
            if self._normalize_min_time: raise CasadiCollocatorException(
                "Free time horizon os not supported with delayed feedback.")
            if self.hs is not None: raise CasadiCollocatorException(
                "Non-uniform element lengths are not supported with delayed feedback.")
            
            for (u_name, (y_name, delay_n_e)) in self.delayed_feedback.iteritems():
                u_dae_var = self.op.getVariable(u_name)
                for i in xrange(1, self.n_e + 1):
                    for k in xrange(1, self.n_cp + 1):
                        u_var = self._get_unscaled_expr_symbols(u_name, i, k)
                        if i > delay_n_e:
                            u_value = self._get_unscaled_expr_symbols(y_name, i-delay_n_e, k)
                        else:
                            u_value = self._eval_initial(u_dae_var, i, k)
                                                
                        # Add constraint
                        input_constr = u_var - u_value
                        c_e.append(input_constr)

        # Calculate cost
        self.cost_mayer = 0
        if not self.mterm.isConstant() or self.mterm.getValue() != 0.:
            # Evaluate Mayer term
            s_z = self._get_z_l0(1, 0, with_der=False)
            s_mterm_fcn_input = s_z
            s_mterm_fcn_input += self._nlp_timed_variables
            if self.variable_scaling:
                    s_mterm_fcn_input += self._get_affine_scaling_symbols_communication_point(self.n_e, self.n_cp)
            [self.cost_mayer] = self.mterm_l0_fcn.call(s_mterm_fcn_input)

    
    def _call_l0_functions(self):
        """
        Call functions in a normal fashion without checkpoint.
        
        Build the list of equality and inequality constraints 
        using only level zero functions. This function must 
        be called only after _define_l0_functions 
        has been called. 

        The inequality constraints are stored in  the class 
        attribute c_i, while the equality constraints are 
        stored in the class attribute c_e

        Define the bolza problem based on level zero functions.
        It does not include restricted inputs. Those are added to 
        self.cost later
        """
        # Index collocation equation scale factors
        coll_sf = self._index_collocation_scale_factors_level_0()
        
        # Collocation and DAE constraints
        for i in xrange(1, self.n_e + 1):
            for k in xrange(1, self.n_cp + 1):
                # Create function inputs
                if self.eliminate_der_var:
                    print "TODO set input for no derivative mode collocation equation"
                    raise NotImplementedError("eliminate_der_var not supported yet")
                else:
                    s_fcn_input = self._get_z_l0(i, k)

                    scoll_input = self.x_list[i] + [self.der_vals[k],
                                               self.horizon * self.h[i]]                    
                    scoll_input += [self.var_map['dx'][i][k]['all']]

                if self.variable_scaling:
                    s_fcn_input += self._get_affine_scaling_symbols_communication_point(i, k)
                    
                    if self.eliminate_der_var:
                        print "TODO set input for no derivative mode collocation equation"
                        raise NotImplementedError("eliminate_der_var not supported yet")                        
                    else:
                        if self.n_var["x"] > 0:
                            scoll_input += [casadi.horzcat(coll_sf[i]['x_d'])]
                            scoll_input += [casadi.horzcat(coll_sf[i]['x_e'])]
                            
                            scoll_input += [casadi.vertcat(coll_sf[i]['dx_d'][k])]
                            scoll_input += [casadi.vertcat(coll_sf[i]['dx_e'][k])]

                # Evaluate collocation constraints
                if not self.eliminate_der_var:
                    [scoll_constr] = self.coll_l0_eq_fcn.call(scoll_input)
                    self.add_c_eq('collocation', scoll_constr, i, k)

                # Evaluate DAE constraints
                [dae_constr] = self.dae_l0_fcn.call(s_fcn_input)
                self.add_c_eq('dae', dae_constr, i, k)


        # Continuity constraints for x_{i, 0}
        # CONSIDER: Should these be scaled incase of affine scaling?
        if not self.eliminate_cont_var:
            for i in xrange(1, self.n_e):
                cont_constr = (self.var_map['x'][i][self.n_cp + self.is_gauss]['all'] - 
                               self.var_map['x'][i + 1][0]['all'])
                self.add_c_eq('continuity', cont_constr, i)


        self.cost_lagrange = 0        
        if not self.lterm.isConstant() or self.lterm.getValue() != 0.:
            # Get start and final time
            t0_var = self.op.getVariable('startTime')
            tf_var = self.op.getVariable('finalTime')
            if self.op.get_attr(t0_var, "free"):
                (ind, _) = self.name_map["startTime"]
                t0 = self.var_map['p_opt']['all'][ind]
                (d, e) = self._get_affine_scaling('startTime', -1, -1)
                t0 = d*t0 + e
            else:
                t0 = self.op.get_attr(t0_var, "_value")
            if self.op.get_attr(tf_var, "free"):
                (ind, _) = self.name_map["finalTime"]
                tf = self.var_map['p_opt']['all'][ind]
                (d, e) = self._get_affine_scaling('finalTime', -1, -1)
                tf = d*tf + e
            else:
                tf = self.op.get_attr(tf_var, "_value")

            # Evaluate Lagrange cost
            for i in xrange(1, self.n_e + 1):
                for k in xrange(1, self.n_cp + 1):
                    if self.eliminate_der_var:
                        print "TODO lagrange input no derivative mode"
                        raise NotImplementedError("eliminate_der_var not supported yet")                          
                    else:
                        s_lterm_fcn_input = self._get_z_l0(i,k)
                        s_lterm_fcn_input += self._nlp_timed_variables

                    if self.variable_scaling:
                        s_lterm_fcn_input += self._get_affine_scaling_symbols_communication_point(i, k)

                    [lterm_val] = self.lterm_l0_fcn.call(s_lterm_fcn_input)
                    # This can be improved! See #3355
                    self.cost_lagrange += ((tf - t0) * self.h[i] *
                                           lterm_val * self.pol.w[k])

        # Sum up the two cost terms
        self.cost = self.cost_mayer + self.cost_lagrange

    def _FXFunction(self, *args):
        f = casadi.MXFunction(*args)
        if self.expand_to_sx != 'no':
            f.init()
            f = casadi.SXFunction(f)
        return f

    def _call_l1_functions(self):
        """
        Call checkpointed functions.
        
        Build the list of equality and inequality constraints 
        using level zero and level one functions. This function must 
        be called only after _define_l0_functions and _define_l1_functions 
        have been called. 

        The inequality constraints are stored in  the class 
        attribute c_i, while the equality constraints are 
        stored in the class attribute c_e

        Define the bolza problem based on level zero 
        and level one functions.It does not include restricted inputs. 
        Those are added to self.cost later
        """ 

        # Create der_vals for all collocation points (level1 input)
        der_vals_l1=list()
        for k in xrange(1, self.n_cp + 1):
            der_vals_k = self.pol.der_vals[:, k]
            for j in der_vals_k:
                for x in range(self.n_var['x']):
                    der_vals_l1.append(j)
        der_vals_l1=casadi.MX(der_vals_l1) 

        # Index collocation equation scale factors
        if self.variable_scaling:
            
            coll_l1_sf = self._index_collocation_scale_factors_level_1()

            #Compute level 1 scaling factors lists for DAE
            element_variant_sf=dict()
            for i in range(1, self.n_e+1):
                element_variant_sf[i]=list()
                for k in range(1, self.n_cp+1):
                    element_variant_sf[i] += self._get_affine_scaling_symbols_communication_point(i, k)
        
        if self.n_var['elim_u']>0:
            raise NotImplementedError("Checkpoint not supported with eliminated inputs")
        
        # Collocation and DAE constraints
        # This is benefitial for code generation 
        h_uniform=self.h[1]
        h_no_free=casadi.MX(h_uniform*self.horizon)
        non_uniform_h=False
        for i in xrange(2, self.n_e + 1):
            if self.h[i]!=h_uniform:
                non_uniform_h=True
                break
        for i in xrange(1, self.n_e + 1):
            # Create function inputs
            if self.eliminate_der_var:
                print "TODO set input for no derivative mode collocation equation"
                raise NotImplementedError("eliminate_der_var not supported yet")
            else:
                e_fcn_input = self._get_z_l1(i)
                
                ecoll_input = [self.var_map['x'][i]['all']] + [der_vals_l1]
                if self.hs == "free" or non_uniform_h:
                    ecoll_input += [self.horizon * self.h[i]]
                else:
                    ecoll_input += [h_no_free]
                ecoll_input += [self.var_map['dx'][i]['all']]
                        
                if self.variable_scaling:
                    e_fcn_input += [casadi.vertcat(element_variant_sf[i])]
                    
                    if self.n_var["x"] > 0:
                        ecoll_input += [casadi.vertcat(coll_l1_sf[i]['x_d'])]
                        ecoll_input += [casadi.vertcat(coll_l1_sf[i]['x_e'])]
                    if self.n_var["dx"] > 0:
                        ecoll_input += [casadi.vertcat(coll_l1_sf[i]['dx_d'])]
                        ecoll_input += [casadi.vertcat(coll_l1_sf[i]['dx_e'])]
                        
                [dae_constr_l1] = self.dae_l1_fcn.call(e_fcn_input)
                self.add_c_eq_l1('dae', dae_constr_l1, i)

                if not self.eliminate_der_var:
                    [col_costr_l1]=self.coll_eq_l1_fcn.call(ecoll_input)
                    self.add_c_eq_l1('collocation', col_costr_l1, i)

        # Continuity constraints for x_{i, 0}
        if not self.eliminate_cont_var:
            for i in xrange(1, self.n_e):
                cont_constr = (self.var_map['x'][i][self.n_cp + self.is_gauss]['all'] - 
                               self.var_map['x'][i + 1][0]['all'])
                self.add_c_eq('continuity', cont_constr, i)

        # Lagrange term with check point
        self.cost_lagrange = 0       
        if not self.lterm.isConstant() or self.lterm.getValue() != 0.:
            # Get start and final time
            t0_var = self.op.getVariable('startTime')
            tf_var = self.op.getVariable('finalTime')
            if self.op.get_attr(t0_var, "free"):
                (ind, _) = self.name_map["startTime"]
                t0 = self.var_map['p_opt']['all'][ind]
            else:
                t0 = self.op.get_attr(t0_var, "_value")
            if self.op.get_attr(tf_var, "free"):
                (ind, _) = self.name_map["finalTime"]
                tf = self.var_map['p_opt']['all'][ind]
            else:
                tf = self.op.get_attr(tf_var, "_value")

            # Evaluate Lagrange cost   
            Gauss_w = list()    
            for k in range(1, self.n_cp+1):
                Gauss_w.append(self.pol.w[k])
            Gauss_w=casadi.MX(Gauss_w)
            if self.hs == "free" or non_uniform_h:
                for i in xrange(1, self.n_e + 1):
                    if self.eliminate_der_var:
                        print "TODO lagrange input no derivative mode"
                        raise NotImplementedError("eliminate_der_var not supported yet")                          
                    else:
                        e_fcn_input = [Gauss_w]+self._get_z_l1(i)
                        e_fcn_input += self._nlp_timed_variables
                        if self.variable_scaling:
                            e_fcn_input += [casadi.vertcat(element_variant_sf[i])]

                        [e_lterm_val] = self.lterm_l1.call(e_fcn_input)
                        self.cost_lagrange += ((tf - t0) * self.h[i] *
                                               e_lterm_val)
            else:
                for i in xrange(1, self.n_e + 1):
                    if self.eliminate_der_var:
                        print "TODO lagrange input no derivative mode"
                        raise NotImplementedError("eliminate_der_var not supported yet")                          
                    else:
                        e_fcn_input = [Gauss_w]+self._get_z_l1(i)
                        e_fcn_input += self._nlp_timed_variables
                        if self.variable_scaling:
                            e_fcn_input += [casadi.vertcat(element_variant_sf[i])]

                        [e_lterm_val] = self.lterm_l1.call(e_fcn_input)
                        self.cost_lagrange += e_lterm_val
                
                self.cost_lagrange=(tf - t0)*self.h[1]*self.cost_lagrange

        # Sum up the two cost terms
        self.cost = self.cost_mayer + self.cost_lagrange

    def _eliminate_der_var(self):
        """
        Eliminate derivative variables from OCP expressions.
        """
        if self.eliminate_der_var:
            coll_der = self._collocation['coll_der']
            self.dae_t0 = self.dae
            ocp_expressions = [self.dae,
                               self.path,
                               self.point,
                               self.mterm,
                               self.lterm]
            [self.dae,
             self.path,
             self.point,
             self.mterm,
             self.lterm] = casadi.substitute(ocp_expressions,
                                             self.mvar_struct["dx"],
                                             coll_der)

    def _check_linear_comb(self, expr):
        """
        Checks if expr is a linear combination of startTime and finalTime.
        """
        t0 = self.op.getVariable('startTime').getVar()
        tf = self.op.getVariable('finalTime').getVar()
        [zero] = casadi.substitute([expr], [t0, tf], [0., 0.])
        if zero != 0.:
            return False
        f = self._FXFunction([t0, tf], [expr])
        f.init()
        if not f.grad(0).isConstant() or not f.grad(1).isConstant():
            return False
        return True

    def _tp2cp(self, tp):
        """
        Computes the normalized collocation point given a time point.
        """
        t0_var = self.op.getVariable('startTime').getVar()
        tf_var = self.op.getVariable('finalTime').getVar()
        cp_f = self._FXFunction([t0_var, tf_var], [tp])
        cp_f.init()
        cp_f.setInput(0., 0)
        cp_f.setInput(1., 1)
        cp_f.evaluate()
        return cp_f.output().toScalar()
    
    def _get_affine_scaling_symbols(self, name, i, k):
        
        if not self.variable_scaling_allow_update:
            return self._get_affine_scaling(name, i, k)
            
        (ind, vt) = self.name_map[name]
        if vt == "p_opt" or self._var_sf_mode[name] != "time-variant":
            d, e = self._var_sf_map[vt][name]
        else:
            try:
                d, e = self._var_sf_map[vt][i][k][ind]
            except KeyError:
                if self.is_gauss:
                    if k==0:
                        d, e = self._var_sf_map[vt][i][k+1][ind] #Same scaling for k==0 and k==1
                    elif k==self.n_cp+1:
                        d, e = self._var_sf_map[vt][i][k-1][ind] #Same scaling for k==n_cp+1 and k==n_cp
                    else:
                        raise KeyError
                else:
                    raise KeyError
                    
        offset = self.pp_offset["variable_scale"]
        
        return (self.pp[offset+d], self.pp[offset+e])
        
    def _get_affine_scaling_symbols_communication_point(self, i, k):
        all_sf = []
        
        if self._var_sf_nbr_vars == 0:
            return all_sf
            
        if self.variable_scaling_allow_update and self._var_sf["n_variant"] == 0:
            return [self.pp_split["variable_scale"]]
            
        for vk in ["x", "dx", "unelim_u", "w", "p_opt"]: #Dont check eliminated u!
            for var in self.mvar_vectors[vk]:
                name = var.getName()
                d, e, = self._get_affine_scaling_symbols(name, i, k)
                all_sf.append(d)
                all_sf.append(e)
                
        return [casadi.vertcat(all_sf)] if len(all_sf) > 0 else all_sf
        
    def _update_variable_scaling(self):
        """
        Update the variable scaling based on the stored values from
        _create_trajectory_scaling_factor_structures
        """
        if self.variable_scaling and self.variable_scaling_allow_update:
            par_vals = self._get_par_vals()
            ind = self.pp_offset["variable_scale"]
            
            for vt in ['x', 'dx', 'unelim_u', 'w']:
                for var in self.mvar_vectors[vt]:
                    name = var.getName()
                    if self._var_sf_mode[name] != "time-variant":
                        d, e = self._get_affine_scaling(name, -1, -1)
                        par_vals[ind]   = d
                        par_vals[ind+1] = e
                        ind = ind + 2
                    else:
                        for i in range(1, self.n_e+1):
                            for k in self.time_points[i]:
                                d, e = self._get_affine_scaling(name, i, k)
                                par_vals[ind]   = d
                                par_vals[ind+1] = e
                                ind = ind + 2
                            
            for var in self.mvar_vectors["p_opt"]:
                name = var.getName()
                d, e = self._get_affine_scaling(name, -1, -1)
                
                par_vals[ind]   = d
                par_vals[ind+1] = e
                ind = ind + 2
            
            #Verify that all has been set
            assert ind == self._var_sf_count*2 + self.pp_offset["variable_scale"] 
        
        
    def _get_affine_scaling(self, name, i, k):
        """
        Get the affine scaling (d, e) of variable name at a collocation point.

            unscaled_value = d*scaled_value + e
        """
        if self.variable_scaling:
            sf_index = self._name_idx_sf_map[name]
            if self._using_variant_variable_scaling(name):
                return self._get_affine_variant_scaling(sf_index, i, k)
            else:
                return (self._invariant_d[sf_index], self._invariant_e[sf_index])
        else:
            return (1.0, 0.0)
            
    def _get_affine_variant_scaling(self, index, i, k):
        try:
            d = self._variant_sf[i][k][index]
        except KeyError:
            if self.is_gauss:
                if k==0:
                    d = self._variant_sf[i][k+1][index] #Same scaling for k==0 and k==1
                elif k==self.n_cp+1:
                    d = self._variant_sf[i][k-1][index] #Same scaling for k==n_cp+1 and k==n_cp
            else:
                raise KeyError
        return (d, 0.0)
        
    def _using_variant_variable_scaling(self, name):
        return self._is_variant[name]
    
    def _get_unscaled_expr_symbols(self, name, i, k):
        """
        Get expression for unscaled value of variable at collocation point.
        """
        (ind, vt) = self.name_map[name]
        val = self.var_map[vt][i][k][ind]
        
        if self.variable_scaling:
            d, e = self._get_affine_scaling_symbols(name, i, k)
        else:
            d = 1.0; e = 0.0
            
        return d*val + e
        
    def _get_unscaled_expr(self, name, i, k):
        """
        Get expression for unscaled value of variable at collocation point.
        """
        (ind, vt) = self.name_map[name]
        val = self.var_map[vt][i][k][ind]
        d, e = self._get_affine_scaling(name, i, k)        
        return d*val + e

    def _create_constraints_and_cost(self):
        """
        Create the constraints and cost function.
        """
        # Calculate time points    
        time=self._compute_time_points()
        
        #Create structures for variable scaling (need to be after compute_time_points)
        self._create_variable_scaling_struct()

        #compute and scale timed variables       
        self._store_and_scale_timed_vars(time)
        # Denormalize time for minimum time problems
        self._denormalize_times()

        # must be called after time has been denormalized and self._denorm_t0_init etc have been set
        self._create_initial_trajectories()        

        #create trajectory scaling structures
        self._create_trajectory_scaling_factor_structures()
        
        #Create parameters used in the NLP
        self._create_nlp_parameters()
        
        #Update scaling parameters
        self._update_variable_scaling()

        # Create measured input trajectories
        self._create_external_input_trajectories()

        # At this point, most features stop being supported
        if self.eliminate_der_var:
            raise NotImplementedError("eliminate_der_var not yet supported.")
        if self.eliminate_cont_var:
            raise NotImplementedError("eliminate_cont_var not yet supported.")

        # Make time an attribute
        self.time = N.array(time)

        # Define level0 functions
        self._define_l0_functions() 
        if self.checkpoint:
            self._define_l1_functions()

        # Call functions
        self._call_functions()
        if not self.checkpoint:
            self._call_l0_functions()
        else:         
            self._call_l1_functions()

        # Add quadratic cost for external data
        if (self.external_data is not None and
            (len(self.external_data.quad_pen) +
             len(self.external_data.constr_quad_pen) > 0)):

            # Create nested dictionary for storage of errors and calculate
            # reference values
            err = {}
            for i in range(1, self.n_e + 1):
                err[i] = {}
                for k in range(1, self.n_cp + 1):
                    err[i][k] = []

            # Calculate errors
            for (vk, source) in (('constr_u', self.external_data.constr_quad_pen),
                                 ('quad_pen', self.external_data.quad_pen)):
                for (j, name) in enumerate(source.keys()):
                    for i in range(1, self.n_e + 1):
                        for k in range(1, self.n_cp + 1):
                            unscaled_val = self._get_unscaled_expr_symbols(name, i, k)
                            ref_val = self.var_map[vk][i][k][j]
                            err[i][k].append(unscaled_val - ref_val)

            # Calculate cost contribution from each collocation point
            Q = self.external_data.Q
            for i in range(1, self.n_e + 1):
                h_i = self.horizon * self.h[i]
                for k in range(1, self.n_cp + 1):
                    err_i_k = N.array(err[i][k])
                    integrand = N.dot(N.dot(err_i_k, Q), err_i_k)
                    self.cost += (h_i * integrand * self.pol.w[k])

        # Add cost term for free element lengths
        if self.hs == "free":
            Q = self.free_element_lengths_data.Q
            c = self.free_element_lengths_data.c
            a = self.free_element_lengths_data.a
            length_cost = 0
            for i in range(1, self.n_e + 1):
                h_i = self.horizon * self.h[i]
                for k in range(1, self.n_cp + 1):
                    integrand = casadi.mul(
                        casadi.mul(self.var_map['dx'][i][k]['all'].T, Q),
                        self.var_map['dx'][i][k]['all'])
                    length_cost += (h_i ** (1 + a) * integrand * self.pol.w[k])
            self.cost += c * length_cost

    def _create_blocking_factors_constraints_and_cost(self):
        """
        Add the constraints and penalties from blocking factors.
        """
        # Retrieve meta-data
        c_i = self.c_i

        # Add constraints and penalties
        if self.blocking_factors is not None:
            bf_pen = 0.
            for var in self.mvar_vectors['unelim_u']:
                name = var.getName()
                if name in self.blocking_factors.factors:
                    
                    # Find scale factors
                    if self.variable_scaling and self._using_variant_variable_scaling(name):
                        raise NotImplementedError("Not implemented yet.")
                        d_0, e_0 = self._get_affine_scaling(name, i, 1)
                        d_1, e_1 = self._get_affine_scaling(name, i+1, 1)
                    else:
                        d_0, e_0 = self._get_affine_scaling(name, -1, -1)
                        d_1 = d_0; e_1 = e_0

                    # Get variable info
                    factors = self.blocking_factors.factors[name]
                    if name in self.blocking_factors.du_bounds:
                        bound = self.blocking_factors.du_bounds[name]
                    if name in self.blocking_factors.du_quad_pen:
                        weight = self.blocking_factors.du_quad_pen[name]
                    
                    (idx, _) = self.name_map[name]
                    
                    # Loop over blocking factor boundaries
                    quad_pen = 0.
                    for i in N.cumsum(factors)[:-1]:
                        # Create delta_u
                        du = (d_0*self.var_map['unelim_u'][i][1][idx] + e_0 -
                              d_1*self.var_map['unelim_u'][i+1][1][idx] - e_1)

                        # Add constraints
                        if name in self.blocking_factors.du_bounds:
                            self.add_c_ineq('delta_u_ub',  du - bound, i)
                            self.add_c_ineq('delta_u_lb', -du - bound, i)

                        # Add penalty
                        if name in self.blocking_factors.du_quad_pen:
                            quad_pen += du ** 2

                    # Add penalty for variable
                    if name in self.blocking_factors.du_quad_pen:
                        bf_pen += weight * quad_pen
            self.cost += bf_pen


    def _create_initial_trajectories(self):
        """
        Create interpolated initial trajectories.
        """
        if self.init_traj is not None:
            n = len(self.init_traj.get_data_matrix()[:, 0])
            self.init_traj_interp = traj = {}

            for vt in ["dx", "x", "w", "unelim_u"]:
                for var in self.mvar_vectors[vt]:
                    data_matrix = N.empty([n, len(self.mvar_vectors[vt])])
                    name = var.getName()
                    try:
                        data = self.init_traj.get_variable_data(name)
                    except VariableNotFoundError:
                        if self.options['verbosity'] >= 2:
                            print("Warning: Could not find initial " +
                                  "trajectory for variable " + name +
                                  ". Using initialGuess attribute value " +
                                  "instead.")
                        ordinates = N.array([[
                            self.op.get_attr(var, "initialGuess")]])
                        abscissae = N.array([0])
                    else:
                        abscissae = N.asarray(data.t)
                        ordinates = N.asarray(data.x)
                        nonfinite_ind = N.nonzero(N.isfinite(ordinates) == 0.)[0]
                        if len(nonfinite_ind) > 0:
                            if self.options['verbosity'] >= 1:
                                print("Warning: Initial trajectory for variable " + name +
                                      " contains nonfinite values. Using initialGuess attribute " +
                                      "value for these instead.")
                            ordinates[nonfinite_ind] = self.op.get_attr(var, "initialGuess")
                        ordinates = ordinates.reshape([-1, 1])
                    traj[var] = TrajectoryLinearInterpolation(
                        abscissae, ordinates)

    def _eval_initial(self, var, i, k):
        """
        Evaluate initial value of Variable var at a given collocation point.

        self._create_initial_trajectories() must have been called first.
        """
        if self.init_traj is None:
            return self.op.get_attr(var, "initialGuess")
        else:
            time = self.time_points[i][k]
            if self._normalize_min_time:
                time = (self._denorm_t0_init +
                        (self._denorm_tf_init - self._denorm_t0_init) * time)
            return self.init_traj_interp[var].eval(time)

    def _compute_bounds_and_init(self):
        """
        Compute bounds and intial guesses for NLP variables.
        """
        # Create lower and upper bounds
        xx_lb = self.LOWER * N.ones(self.get_n_xx())
        xx_ub = self.UPPER * N.ones(self.get_n_xx())
        xx_init = N.zeros(self.get_n_xx())

        # Retrieve model data
        op = self.op
        var_types = ['x', 'unelim_u', 'w', 'p_opt']
        name_map = self.name_map
        mvar_vectors = self.mvar_vectors
        time_points = self.time_points

        # Handle free parameters
        p_max = N.empty(self.n_var["p_opt"])
        p_min = copy.deepcopy(p_max)
        p_init = copy.deepcopy(p_max)
        for var in mvar_vectors["p_opt"]:
            name = var.getName()
            (var_index, _) = name_map[name]
            
            (sf, _ ) = self._get_affine_scaling(name, -1, -1)
            
            p_min[var_index] = op.get_attr(var, "min") / sf
            p_max[var_index] = op.get_attr(var, "max") / sf

            # Handle initial guess
            var_init = op.get_attr(var, "initialGuess")
            if self.init_traj is not None:
                name = var.getName()
                if name == "startTime":
                    var_init = self._denorm_t0_init
                elif name == "finalTime":
                    var_init = self._denorm_tf_init
                else:
                    try: 
                        data = self.init_traj.get_variable_data(name) 
                    except VariableNotFoundError: 
                        pass
                    else: 
                        var_init = data.x[0] 
            p_init[var_index] = var_init / sf
        xx_lb[self.var_indices['p_opt']] = p_min
        xx_ub[self.var_indices['p_opt']] = p_max
        xx_init[self.var_indices['p_opt']] = p_init

        # Manipulate initial trajectories
        if self.init_traj is not None:
            n = len(self.init_traj.get_data_matrix()[:, 0])
            traj = {}

            for vt in ["dx", "x", "w", "unelim_u"]:
                traj[vt] = {}
                for var in mvar_vectors[vt]:
                    name = var.getName()
                    (var_index, _) = name_map[name]
                    if name == "startTime":
                        abscissae = N.array([0])
                        ordinates = N.array([[self._denorm_t0_init]])
                    elif name == "finalTime":
                        abscissae = N.array([0])
                        ordinates = N.array([[self._denorm_tf_init]])
                    else:
                        try:
                            data = self.init_traj.get_variable_data(name)
                        except VariableNotFoundError:
                            if self.options['verbosity'] >= 2:
                                print("Warning: Could not find initial " +
                                      "trajectory for variable " + name +
                                      ". Using initialGuess attribute value " +
                                      "instead.")
                            ordinates = N.array([[
                                op.get_attr(var, "initialGuess")]])
                            abscissae = N.array([0])
                        else:
                            abscissae = N.asarray(data.t)
                            ordinates = N.asarray(data.x).reshape([-1, 1])
                        traj[vt][var_index] = TrajectoryLinearInterpolation(
                            abscissae, ordinates)

        # Denormalize time for minimum time problems
        if self._normalize_min_time:
            t0 = self._denorm_t0_init
            tf = self._denorm_tf_init

        # Set bounds and initial guesses
        for vt in ['dx', 'x', 'w', 'unelim_u']:
            for var in mvar_vectors[vt]:
                name = var.getName()
                v_min = op.get_attr(var, "min")
                v_max = op.get_attr(var, "max")
                (var_idx, _) = name_map[name]
                
                for i in xrange(1, self.n_e + 1):
                    for k in self.time_points[i].keys():
                        
                        #Get scaling factors
                        d, e = self._get_affine_scaling(name, i, k)
                        
                        #Scale bounds and init
                        v_init = self._eval_initial(var, i, k)
                        if self._normalize_min_time and vt == "dx":
                            if N.isfinite([v_min, v_max]).any():
                                return NotImplementedError('State derivative bounds are not supported for problems ' +
                                                           'with free time horizons.')
                            v_init *= (tf - t0)
                        xx_lb[self.var_indices[vt][i][k][var_idx]] = (v_min - e) / d
                        xx_ub[self.var_indices[vt][i][k][var_idx]] = (v_max - e) / d
                        xx_init[self.var_indices[vt][i][k][var_idx]] = (v_init - e) / d

        # Set bounds and initial guesses for continuity variables
        if not self.eliminate_cont_var:
            vt = 'x'
            k = self.n_cp + self.is_gauss
            for i in xrange(2, self.n_e + 1):
                xx_lb[self.var_indices[vt][i][0]]   = xx_lb[self.var_indices[vt][i - 1][k]]
                xx_ub[self.var_indices[vt][i][0]]   = xx_ub[self.var_indices[vt][i - 1][k]]
                xx_init[self.var_indices[vt][i][0]] = xx_init[self.var_indices[vt][i - 1][k]]

        # Compute bounds and initial guesses for element lengths
        if self.hs == "free":
            h_0 = 1. / self.n_e
            h_bounds = self.free_element_lengths_data.bounds
            for i in xrange(1, self.n_e + 1):
                xx_lb[self.var_indices['h'][i]] = h_bounds[0] * h_0
                xx_ub[self.var_indices['h'][i]] = h_bounds[1] * h_0
                xx_init[self.var_indices['h'][i]] = h_bounds[1] * h_0

        # Store bounds and initial guesses
        self.xx_lb = xx_lb
        self.xx_ub = xx_ub
        self.xx_init = xx_init

        # Create and store bounds on the constraints
        n_h = self.get_equality_constraint().numel()
        hublb = n_h * [0]
        n_g = self.get_inequality_constraint().numel()
        gub = n_g * [0]
        glb = n_g * [self.LOWER]
        self.glub = N.array(hublb + gub)
        self.gllb = N.array(hublb + glb)

    def _assemble_back_tracking_info(self):
        # Finalize and sort recorded tracking info
        for dests in (self.c_dests, self.xx_dests):
            for dest in dests.itervalues():                
                inds = N.vstack(dest['inds'])
                i = N.array(dest['i'], dtype=N.int)
                k = N.array(dest['k'], dtype=N.int)
                tinds = N.lexsort((k, i))

                inds = inds[tinds, :]
                if dests is self.xx_dests:
                    inds = inds[:, 0]

                dest['inds'] = inds
                dest['i']    = i[tinds]
                dest['k']    = k[tinds]

        # Create mapping from nlp constraints to model equations
        # We need to know the number of equality and inequality constraints at this point
        n_e = self.c_e.numel()
        n_i = self.c_i.numel()
        if (n_e, n_i) != (self.n_c_e, self.n_c_i):
            print "(n_e, self.n_c_e) =", (n_e, self.n_c_e)
            print "(n_i, self.n_c_i) =", (n_i, self.n_c_i)
        assert n_e == self.n_c_e
        assert n_i == self.n_c_i
        n_c = n_e + n_i

        self.c_sources = {}
        self.c_sources['eqtype'] = N.zeros(n_c, dtype=object)
        self.c_sources['eqind'] = N.zeros(n_c, dtype=N.int)
        self.c_sources['i'] = N.zeros(n_c, dtype=N.int)
        self.c_sources['k'] = N.zeros(n_c, dtype=N.int)

        self.c_sources['eqtype'].fill('other')
        self.c_sources['eqind'].fill(-1)
        self.c_sources['i'].fill(-1)
        self.c_sources['k'].fill(-1)

        for eqtype in self.get_nlp_constraint_types():
            c_inds, i, k = self.get_nlp_constraint_indices(eqtype)
            self.c_sources['eqtype'][c_inds] = eqtype
            self.c_sources['eqind'][c_inds] = N.arange(c_inds.shape[1], dtype=N.int)
            
            # work around numpy broadcasted assignment bug
            promoter = N.zeros(c_inds.shape[1], dtype=N.int)

            self.c_sources['i'][c_inds] = (i[:, N.newaxis] + promoter)
            self.c_sources['k'][c_inds] = (k[:, N.newaxis] + promoter)

        # Create mapping from nlp variables xx to model variables
        self.xx_sources = {}
        self.xx_sources['var'] = N.zeros(self.n_xx, dtype=object)
        self.xx_sources['i'] = N.zeros(self.n_xx, dtype=N.int)
        self.xx_sources['k'] = N.zeros(self.n_xx, dtype=N.int)

        self.xx_sources['var'].fill(None)
        self.xx_sources['i'].fill(-1)
        self.xx_sources['k'].fill(-1)

        for (var, dest) in self.xx_dests.iteritems():
            v_inds = dest['inds']
            self.xx_sources['var'][v_inds] = var
            self.xx_sources['i'][v_inds] = dest['i']
            self.xx_sources['k'][v_inds] = dest['k']

    def _create_solver(self):
        # Concatenate constraints
        constraints = casadi.vertcat([self.c_e, self.c_i])

        # Reorder variables and constraints
        if self.order != "default":
            if self.order == "reverse":
                self.eq_ordering = eq_ordering = range(constraints.numel()-1, -1, -1)
                self.var_ordering = var_ordering = range(self.n_xx-1, -1, -1)
            elif self.order == "random":
                self.eq_ordering = eq_ordering = range(constraints.numel())
                self.var_ordering = var_ordering = range(self.n_xx)
                N.random.shuffle(eq_ordering)
                N.random.shuffle(var_ordering)
            else:
                raise ValueError('Invalid order %s' % self.order)
            self.inv_var_ordering = [var_ordering.index(i) for i in range(len(var_ordering))]
            constraints = constraints[eq_ordering]
            (constraints, self.cost) = casadi.substitute([constraints, self.cost], [self.xx], [self.xx[var_ordering]])
            if self.equation_scaling:
                self.pp_split = self.pp_split[eq_ordering]
            self.gllb = self.gllb[eq_ordering]
            self.glub = self.glub[eq_ordering]
            self.xx_lb = self.xx_lb[self.inv_var_ordering]
            self.xx_ub = self.xx_ub[self.inv_var_ordering]
            self.xx_init = self.xx_init[self.inv_var_ordering]

        if self.equation_scaling:
            constraints = self.pp_split['equation_scale'] * constraints

        # Create solver object
        self.constraints = constraints
        nlp = casadi.MXFunction(casadi.nlpIn(x=self.xx, p=self.pp),
                                casadi.nlpOut(f=self.cost, g=constraints))
        if self.solver == "IPOPT":
            self.solver_object = casadi.NlpSolver("ipopt",nlp)
        elif self.solver == "WORHP":
            self.solver_object = casadi.NlpSolver("worhp",nlp)
        else:
            raise CasadiCollocatorException(
                    "Unknown nonlinear programming solver %s." % self.solver)

        # Expand to SX
        self.solver_object.setOption("expand", self.expand_to_sx == "NLP")
        if self.equation_scaling:
            self.solver_object.init() # Probably needed before extracting the nlp function
            nlp = self.solver_object.nlp()
            self.residual_jac_fcn = nlp.jacobian(0,1)
            self.residual_jac_fcn.init()

        # Circumvent CasADi bug, see #4313
        if self.explicit_hessian:
            self._calc_Lagrangian_Hessian()
            self.solver_object.setOption("hess_lag", self.H)        

    def get_equality_constraint(self):
        return self.c_e

    def get_inequality_constraint(self):
        return self.c_i

    def get_cost(self):
        return self.cost_fcn

    def _get_elim_u_result(self, i, k):
        """Return a vector of values of eliminated variables at (i,k)."""
        if self.mutable_external_data:
            elim_u = N.zeros(self.n_var['elim_u'])
            for j in xrange(self.n_var['elim_u']):
                # consider: are those always consecutive indices?
                # If so, would be enough to index into _par_vals with a range
                elim_u[j] = self._par_vals[
                    self.var_indices['elim_u'][i][k][j]]
            return elim_u
        else:
            return self.var_map['elim_u'][i][k]['all']

    def get_result(self):
        # Set model info
        n_var = self.n_var
        cont = {'dx': False, 'x': True, 'unelim_u': False, 'w': False}
        mvar_vectors = self.mvar_vectors
        var_types = ['x', 'unelim_u', 'w']
        if not self.eliminate_der_var:
            var_types = ['dx'] + var_types
        name_map = self.name_map
        var_map = self.var_map
        var_opt = {}
        op = self.op

        # Get copy of solution
        primal_opt = copy.copy(self.primal_opt)

        # Get element lengths
        if self.hs == "free":
            self.h_opt = N.hstack([N.nan, primal_opt[self.var_indices['h'][1:]]])
            h_scaled = self.horizon * self.h_opt
        else:
            h_scaled = self.horizon * N.array(self.h)

        # Create array with discrete times
        if self.result_mode == "collocation_points":
            if self.hs == "free":
                t_start = self.t0
                t_opt = [t_start]
                for h in h_scaled[1:]:
                    for k in xrange(1, self.n_cp + 1):
                        t_opt.append(t_start + self.pol.p[k] * h)
                    t_start += h
                t_opt = N.array(t_opt).reshape([-1, 1])
            else:
                t_opt = self.get_time().reshape([-1, 1])
        elif self.result_mode == "mesh_points":
            t_opt = [self.t0]
            for h in h_scaled[1:]:
                t_opt.append(t_opt[-1] + h)
            t_opt = N.array(t_opt).reshape([-1, 1])
        elif self.result_mode == "element_interpolation":
            t_opt = [self.t0]
            for i in xrange(1, self.n_e + 1):
                t_end = t_opt[-1] + h_scaled[i]
                t_i = N.linspace(t_opt[-1], t_end, self.n_eval_points)
                t_opt.extend(t_i)
            t_opt = N.array(t_opt[1:]).reshape([-1, 1])
        else:
            raise CasadiCollocatorException("Unknown result mode %s." %
                                            self.result_mode)

        # Create arrays for storage of variable trajectories
        for var_type in var_types + ['elim_u']:
            var_opt[var_type] = N.empty([len(t_opt), n_var[var_type]])
        var_opt['merged_u'] = N.empty([len(t_opt),
                                       n_var['unelim_u'] + n_var['elim_u']])
        if self.eliminate_der_var:
            var_opt['dx'] = N.empty([len(t_opt), n_var['x']])
        var_opt['p_opt'] = N.empty(n_var['p_opt'])

        # Get optimal parameter values and rescale
        p_opt = primal_opt[self.var_indices['p_opt']].reshape(-1)
        if self.variable_scaling and not self.write_scaled_result:
            
            #Get scaling factors
            p_opt_sf = N.empty(n_var['p_opt'])
            for var in mvar_vectors['p_opt']:
                name = var.getName()
                (ind, _) = name_map[name]
                (d, _) = self._get_affine_scaling(name, -1, -1)
                p_opt_sf[ind] = d
            
            #Rescale
            p_opt *= p_opt_sf
        var_opt['p_opt'][:] = p_opt

        # Get current values for fixed parameters
        var_opt['p_fixed'] = self._par_vals[0:self.n_var['p_fixed']]

        # Rescale solution
        time_points = self.get_time_points()
        if self.variable_scaling and not self.write_scaled_result:
            for i in xrange(1, self.n_e + 1):
                for k in time_points[i]:
                    for var_type in var_types:
                        for var in mvar_vectors[var_type]:
                            name = var.getName()
                            if (var_type != "unelim_u" or
                                self.blocking_factors is None or
                                name not in self.blocking_factors.factors):
                                
                                (ind, _) = name_map[name]
                                global_ind = self.var_indices[var_type][i][k][ind]
                                xx_i_k = primal_opt[global_ind]
                                
                                #Get the scaling factors
                                d, e = self._get_affine_scaling(name, i, k)
                                
                                #Compute the unscaled value
                                xx_i_k = d * xx_i_k + e
                                
                                primal_opt[global_ind] = xx_i_k

        # Rescale inputs with blocking factors
        if (self.variable_scaling and not self.write_scaled_result and
            self.blocking_factors is not None):
            var_type = "unelim_u"
            k = 1
            for var in mvar_vectors[var_type]:
                name = var.getName()
                if name in self.blocking_factors.factors:
                    (ind, _) = name_map[name]
                    # Rescale once per factor
                    for i in N.cumsum(self.blocking_factors.factors[name]):
                        global_ind = self.var_indices[var_type][i][k][ind]
                        u_i_k = primal_opt[global_ind]
                        
                        #Get the scaling factors
                        d, e = self._get_affine_scaling(name, i, k)
                        
                        #Compute the unscaled value
                        u_i_k = d * u_i_k + e
                        
                        primal_opt[global_ind] = u_i_k

        # Rescale continuity variables
        if (self.variable_scaling and not self.eliminate_cont_var and
            not self.write_scaled_result):
            for i in xrange(1, self.n_e):
                k = self.n_cp + self.is_gauss
                x_i_k = primal_opt[self.var_indices['x'][i][k]]
                primal_opt[self.var_indices['x'][i + 1][0]] = x_i_k
        if (self.is_gauss and self.variable_scaling and 
            not self.eliminate_cont_var and not self.write_scaled_result):
            if self.quadrature_constraint:
                for i in xrange(1, self.n_e + 1):
                    # Evaluate x_{i, n_cp + 1} based on quadrature
                    x_i_np1 = 0
                    for k in xrange(1, self.n_cp + 1):
                        dx_i_k = primal_opt[self.var_indices['dx'][i][k]]
                        x_i_np1 += self.pol.w[k] * dx_i_k
                    x_i_np1 = (primal_opt[self.var_indices['x'][i][0]] + 
                               self.horizon * self.h[i] * x_i_np1)

                    # Rescale x_{i, n_cp + 1}
                    primal_opt[self.var_indices['x'][i][self.n_cp + 1]] = x_i_np1
            else:
                for i in xrange(1, self.n_e + 1):
                    # Evaluate x_{i, n_cp + 1} based on polynomial x_i
                    x_i_np1 = 0
                    for k in xrange(self.n_cp + 1):
                        x_i_k = primal_opt[self.var_indices['x'][i][k]]
                        x_i_np1 += x_i_k * self.pol.eval_basis(k, 1, True)

                    # Rescale x_{i, n_cp + 1}
                    primal_opt[self.var_indices['x'][i][self.n_cp + 1]] = x_i_np1
                    
        
        # Get solution trajectories
        t_index = 0
        if self.result_mode == "collocation_points":
            for i in xrange(1, self.n_e + 1):
                for k in time_points[i]:
                    for var_type in var_types:
                        xx_i_k = primal_opt[self.var_indices[var_type][i][k]]
                        var_opt[var_type][t_index, :] = xx_i_k.reshape(-1)
                    var_opt['elim_u'][t_index, :] = self._get_elim_u_result(i, k)
                    t_index += 1
            if self.eliminate_der_var:
                # dx_1_0
                t_index = 0
                i = 1
                k = 0
                dx_i_k = primal_opt[self.var_indices['dx'][i][k]]
                var_opt['dx'][t_index, :] = dx_i_k.reshape(-1)
                t_index += 1

                # Collocation point derivatives
                for i in xrange(1, self.n_e + 1):
                    for k in xrange(1, self.n_cp + 1):
                        dx_i_k = 0
                        for l in xrange(self.n_cp + 1):
                            x_i_l = primal_opt[self.var_indices['x'][i][l]]
                            dx_i_k += (1. / h_scaled[i] * x_i_l * 
                                       self.pol.eval_basis_der(
                                           l, self.pol.p[k]))
                        var_opt['dx'][t_index, :] = dx_i_k.reshape(-1)
                        t_index += 1
        elif self.result_mode == "element_interpolation":
            tau_arr = N.linspace(0, 1, self.n_eval_points)
            for i in xrange(1, self.n_e + 1):
                for tau in tau_arr:
                    # Non-derivatives and uneliminated inputs
                    for var_type in ['x', 'unelim_u', 'w']:
                        # Evaluate xx_i_tau based on polynomial xx^i
                        xx_i_tau = 0
                        for k in xrange(not cont[var_type], self.n_cp + 1):
                            xx_i_k = primal_opt[self.var_indices[var_type][i][k]]
                            xx_i_tau += xx_i_k * self.pol.eval_basis(
                                k, tau, cont[var_type])
                        var_opt[var_type][t_index, :] = xx_i_tau.reshape(-1)

                    # eliminated inputs
                    xx_i_tau = 0
                    for k in xrange(not cont[var_type], self.n_cp + 1):
                        xx_i_k = self._get_elim_u_result(i, k)
                        xx_i_tau += xx_i_k * self.pol.eval_basis(
                            k, tau, cont[var_type])
                    var_opt['elim_u'][t_index, :] = xx_i_tau.reshape(-1)

                    # Derivatives
                    dx_i_tau = 0
                    for k in xrange(self.n_cp + 1):
                        x_i_k = primal_opt[self.var_indices['x'][i][k]]
                        dx_i_tau += (1. / h_scaled[i] * x_i_k * 
                                     self.pol.eval_basis_der(k, tau))
                    var_opt['dx'][t_index, :] = dx_i_tau.reshape(-1)

                    t_index += 1
        elif self.result_mode == "mesh_points":
            # Start time
            i = 1
            k = 0
            for var_type in var_types:
                xx_i_k = primal_opt[self.var_indices[var_type][i][k]]
                var_opt[var_type][t_index, :] = xx_i_k.reshape(-1)
            var_opt['elim_u'][t_index, :] = self._get_elim_u_result(i, k)
            t_index += 1
            k = self.n_cp + self.is_gauss

            # Mesh points
            var_types.remove('x')
            if self.discr == "LGR":
                for i in xrange(1, self.n_e + 1):
                    for var_type in var_types:
                        xx_i_k = primal_opt[self.var_indices[var_type][i][k]]
                        var_opt[var_type][t_index, :] = xx_i_k.reshape(-1)
                    u_i_k = self._get_elim_u_result(i, k)
                    var_opt['elim_u'][t_index, :] = u_i_k.reshape(-1)
                    t_index += 1
            elif self.discr == "LG":
                for i in xrange(1, self.n_e + 1):
                    for var_type in var_types:
                        # Evaluate xx_{i, n_cp + 1} based on polynomial xx_i
                        xx_i_k = 0
                        for l in xrange(1, self.n_cp + 1):
                            xx_i_l = primal_opt[self.var_indices[var_type][i][l]]
                            xx_i_k += xx_i_l * self.pol.eval_basis(l, 1, False)
                        var_opt[var_type][t_index, :] = xx_i_k.reshape(-1)
                    # Evaluate u_{i, n_cp + 1} based on polynomial u_i
                    u_i_k = 0
                    for l in xrange(1, self.n_cp + 1):
                        u_i_l = self._get_elim_u_result(i, l)
                        u_i_k += u_i_l * self.pol.eval_basis(l, 1, False)
                    var_opt['elim_u'][t_index, :] = u_i_k.reshape(-1)
                    t_index += 1
            var_types.insert(0, 'x')

            # Handle states separately
            t_index = 1
            for i in xrange(1, self.n_e + 1):
                x_i_k = primal_opt[self.var_indices['x'][i][k]]
                var_opt['x'][t_index, :] = x_i_k.reshape(-1)
                t_index += 1

            # Handle state derivatives separately
            if self.eliminate_der_var:
                # dx_1_0
                t_index = 0
                i = 1
                k = 0
                dx_i_k = primal_opt[self.var_indices['dx'][i][k]]
                var_opt['dx'][t_index, :] = dx_i_k.reshape(-1)
                t_index += 1

                # Mesh point state derivatives
                t_index = 1
                for i in xrange(1, self.n_e + 1):
                    dx_i_k = 0
                    for l in xrange(self.n_cp + 1):
                        x_i_l = primal_opt[self.var_indices['x'][i][l]]
                        dx_i_k += (1. / h_scaled[i] * x_i_l * 
                                   self.pol.eval_basis_der(l, 1.))
                    var_opt['dx'][t_index, :] = dx_i_k.reshape(-1)
                    t_index += 1
        else:
            raise CasadiCollocatorException("Unknown result mode %s." %
                                            self.result_mode)

        # Merge uneliminated and eliminated inputs
        if self.n_var['u'] > 0:
            var_opt['merged_u'][:, self._unelim_input_indices] = \
                var_opt['unelim_u']
            var_opt['merged_u'][:, self._elim_input_indices] = \
                var_opt['elim_u']

        # Store optimal inputs for interpolator purposes
        if self.result_mode == "collocation_points":
            u_opt = var_opt['merged_u']
        else:
            t_index = 0
            u_opt = N.empty([self.n_e * self.n_cp + 1 + self.is_gauss,
                             self.n_var['u']])
            for i in xrange(1, self.n_e + 1):
                for k in time_points[i]:
                    unelim_u_i_k = primal_opt[self.var_indices['unelim_u'][i][k]]
                    u_opt[t_index, self._unelim_input_indices] = \
                        unelim_u_i_k.reshape(-1)
                    elim_u_i_k = self._get_elim_u_result(i, k)
                    u_opt[t_index, self._elim_input_indices] = \
                        elim_u_i_k.reshape(-1)
                    t_index += 1
        self._u_opt = u_opt

        # Denormalize minimum time problem
        if self._normalize_min_time:
            t0_var = op.getVariable('startTime')
            tf_var = op.getVariable('finalTime')
            if op.get_attr(t0_var, "free"):
                name = t0_var.getName()
                (ind, _) = name_map[name]
                t0 = var_opt['p_opt'][ind]
            else:
                t0 = op.get_attr(t0_var, "_value")
            if op.get_attr(tf_var, "free"):
                name = tf_var.getName()
                (ind, _) = name_map[name]
                tf = var_opt['p_opt'][ind]
            else:
                tf = op.get_attr(tf_var, "_value")
            t_opt = t0 + (tf - t0) * t_opt
            var_opt['dx'] /= (tf - t0)
        
        # Create array to storage eliminated variables
        n_eliminations = len(op.getEliminatedVariables())
        
        var_opt['elim_vars'] = N.ones([len(t_opt), n_eliminations])
        if n_eliminations>0:
            # Compute eliminated variables
            t_index = 0
            var_kinds_ordered =copy.copy(self.mvar_struct.keys())
            del var_kinds_ordered[0]
            for t in t_opt:
                index_var = 0
                self.elimination_fcn.setInput(t,0)
                j=1
                for vk in var_kinds_ordered:
                    if self.n_var[vk]>0:
                        if vk == 'p_opt':
                            var_input = var_opt[vk]
                        elif vk == 'p_fixed':
                            # todo: better way to access these?
                            var_input = self._par_vals[0:self.n_var['p_fixed']]
                        else:
                            var_input = var_opt[vk][t_index,:]
                        self.elimination_fcn.setInput(var_input,j)
                        j+=1
                self.elimination_fcn.evaluate()
                result = self.elimination_fcn.getOutput()
                for index_v in range(n_eliminations):
                    var_opt['elim_vars'][t_index,index_v] = result[index_v]
                t_index+=1 

        # Return results
        return (t_opt, var_opt['dx'], var_opt['x'], var_opt['merged_u'],
            var_opt['w'], var_opt['p_fixed'], var_opt['p_opt'], var_opt['elim_vars'])

    def get_h_opt(self):
        if self.hs == "free":
            return self.h_opt
        else:
            return None

    def export_result_dymola(self, file_name='', format='txt', 
                             write_scaled_result=False, result=None):
        """
        Export an optimization or simulation result to file in Dymolas result file 
        format. The parameter values are read from the z vector of the model object 
        and the time series are read from the data argument.

        Parameters::

            file_name --
                If no file name is given, the name of the model (as defined by 
                casadiModel.get_name()) concatenated with the string '_result' is used. 
                A file suffix equal to the format argument is then appended to the 
                file name.
                Default: Empty string.

            format --
                A text string equal either to 'txt' for textual format or 'mat' for 
                binary Matlab format.
                Default: 'txt'

            write_scaled_result --
                Set this parameter to True to write the result to file without
                taking scaling into account. If the value of write_sacled_result
                is False, then the variable scaling factors of the model are
                used to reproduced the unscaled variable values.
                Default: False
                
            result --
                If a result is given, that result is the one that gets exported
                to a dymola file. Otherwise this function will call 
                self.get_result() and export the result from the last 
                optimization/sample.
                Default: None 

        Returns::

            used_file_name --
                The actual file name used to write the result file.
                Equals file_name unless file_name is empty.

        Limitations::

            Currently only textual format is supported.
        """
        if result is None:
            (t,dx_opt,x_opt,u_opt,w_opt,p_fixed,p_opt, elim_vars) = self.get_result()
            data = N.hstack((t,dx_opt,x_opt,u_opt,w_opt,elim_vars))
        else:
            (t,dx_opt,x_opt,u_opt,w_opt,p_fixed,p_opt, elim_vars) = result
            data = N.hstack((t,dx_opt,x_opt,u_opt,w_opt,elim_vars))

        if (format=='txt'):
            op = self.op
            name_map = self.name_map
            mvar_vectors = self.mvar_vectors
            variable_list = reduce(list.__add__,
                                   [list(mvar_vectors[vt]) for
                                    vt in ['p_opt', 'p_fixed',
                                           'dx', 'x', 'u', 'w']])
            if result is None:
                for v in op.getEliminatedVariables():
                    variable_list.append(v) 

            # Map variable to aliases
            alias_map = {}
            for var in variable_list:
                alias_map[var.getName()] = []
            for alias_var in op.getAliases():
                alias = alias_var.getModelVariable()
                alias_map[alias.getName()].append(alias_var)

            # Set up sections
            # Put exactly one entry per variable in name_section etc
            # - its length is used to determine num_vars
            name_section = ['time\n']
            description_section = ['Time in [s]\n']
            data_info_section = ['0 1 0 -1 # time\n']

            # Collect meta information
            n_variant = 1
            n_invariant = 1
            max_name_length = len('Time')
            max_desc_length = len('Time in [s]')
            for var in variable_list:
                # Name
                name = var.getName()
                name_section.append('%s\n' % name)
                if len(name) > max_name_length:
                    max_name_length = len(name)

                # Description
                description = op.get_attr(var, "comment")
                description_section.append('%s\n' % description)
                if len(description) > max_desc_length:
                    max_desc_length = len(description)

                # Data info
                variability = var.getVariability()
                if variability in [var.PARAMETER, var.CONSTANT]:
                    n_invariant += 1
                    data_info_section.append('1 %d 0 -1 # %s\n' %
                                             (n_invariant, name))
                else:
                    n_variant += 1
                    data_info_section.append('2 %d 0 -1 # %s\n' %
                                             (n_variant, name))

                # Handle alias variables
                for alias_var in alias_map[var.getName()]:
                    # Name
                    name = alias_var.getName()
                    name_section.append('%s\n' % name)
                    if len(name) > max_name_length:
                        max_name_length = len(name)

                    # Description
                    description = op.get_attr(alias_var, "comment")
                    description_section.append('%s\n' % description)
                    if len(description) > max_desc_length:
                        max_desc_length = len(description)

                    # Data info
                    if alias_var.isNegated():
                        neg = -1
                    else:
                        neg = 1
                    if variability in [alias_var.PARAMETER, alias_var.CONSTANT]:
                        data_info_section.append('1 %d 0 -1 # %s\n' %
                                                 (neg*n_invariant, name))
                    else:
                        data_info_section.append('2 %d 0 -1 # %s\n' %
                                                 (neg*n_variant, name))

            # Collect parameter data (data_1)
            data_1 = []
            for par in mvar_vectors['p_opt']:
                name = par.getName()
                (ind, _) = name_map[name]
                data_1.append(" %.14E" % p_opt[ind])

            for par_val in p_fixed:
                data_1.append(" %.14E" % par_val)

            # Open file
            if file_name == '':
                file_name = self.op.getIdentifier() + '_result.txt'
            f = codecs.open(file_name, 'w', 'utf-8')

            # Write header
            f.write('#1\n')
            f.write('char Aclass(3,11)\n')
            f.write('Atrajectory\n')
            f.write('1.1\n')
            f.write('\n')

            num_vars = len(name_section)

            # Write names
            f.write('char name(%d,%d)\n' % (num_vars, max_name_length))
            for name in name_section:
                f.write(name)
            f.write('\n')

            # Write descriptions
            f.write('char description(%d,%d)\n' % (num_vars, max_desc_length))
            for description in description_section:
                f.write(description)
            f.write('\n')

            # Write dataInfo
            f.write('int dataInfo(%d,%d)\n' % (num_vars, 4))
            for data_info in data_info_section:
                f.write(data_info)
            f.write('\n')

            # Write data_1
            n_parameters = (len(mvar_vectors['p_opt']) +
                            len(mvar_vectors['p_fixed']))
            f.write('float data_1(%d,%d)\n' % (2, n_parameters + 1))
            par_val_str = ''
            for par_val in data_1:
                par_val_str += par_val
            par_val_str += '\n'
            f.write("%.14E" % data[0,0])
            f.write(par_val_str)
            f.write("%.14E" % data[-1,0])
            f.write(par_val_str)
            f.write('\n')

            # Write data_2
            n_vars = len(data[0, :])
            n_points = len(data[:, 0])
            f.write('float data_2(%d,%d)\n' % (n_points, n_vars))
            for i in range(n_points):
                str_text = ''
                for ref in range(n_vars):
                    str_text = str_text + (" %.14E" % data[i, ref])
                f.write(str_text + '\n')

            # Close file
            f.write('\n')
            f.close()

            return file_name
        else:
            raise NotImplementedError('Export on binary Dymola result files ' +
                                      'not yet supported.')

    def get_opt_input(self):
        """
        Get the optimized input variables as a function of time.

        The purpose of this method is to conveniently provide the optimized
        input variables to a simulator.

        Returns::

            input_names --
                Tuple consisting of the names of the input variables.

            input_interpolator --
                Collocation polynomials for input variables as a function of
                time.
        """
        # Consider: do we actually need to save _xi, _ti, and _hi in self?
        if self.hs == "free":
            self._hi = map(lambda h: self.horizon * h, self.h_opt)
        else:
            self._hi = map(lambda h: self.horizon * h, self.h)
        
        xi = self._u_opt[1:self.n_e*self.n_cp+1]
        self._xi = xi.reshape(self.n_e, self.n_cp, self.n_var['u'])
        self._ti = N.cumsum([self.t0] + self._hi[1:])
        input_names = tuple([u.getName() for u in self.mvar_vectors['u']])
        return (input_names, self._create_input_interpolator(self._xi, self._ti, self._hi))

    def get_named_var_expr(self, expr):
        """
        Substitute anonymous variables in an expression for named variables.

        Only works if named_vars == True.
        """
        if self.named_vars:
            f = casadi.MXFunction([self.xx, self.pp], [expr])
            f.init()
            return f.call([self.named_xx, self.named_pp],True)[0]
        else:
            raise CasadiCollocatorException(
                "named_var_expr only works if named_vars is enabled.")

    def get_residual_scales(self):
        """
        Get the scaling factors used for the residuals.

        Call only if using the equation_scaling option.
        """
        offset = self.pp_offset['equation_scale']
        return self._par_vals[offset:offset + self.n_c]

    def _scale_residuals(self, r):
        """
        Return the argument scaled by the current residual scaling.
        """
        if self.equation_scaling:
            return r*self.get_residual_scales()
        else:
            return r

    def _inv_scale_residuals(self, r):
        """
        Return the argument divided by the current residual scaling.
        """
        if self.equation_scaling:
            return r/self.get_residual_scales()
        else:
            return r
            
    def get_par_vals(self, scaled_residuals=False):
        """
        Get the parameter values for the NLP.

        If scaled_residuals is True, return the parameter values needed
        to get the scaled residuals (requires the equation_scaling option).
        """
        if self.equation_scaling:
            if scaled_residuals:
                return self._get_par_vals()
            else:
                # Set the equation scalings to one
                par_vals = self._get_par_vals().copy()
                offset = self.pp_offset['equation_scale']
                par_vals[offset:offset + self.n_c] = 1
                return par_vals
        else:
            if scaled_residuals:
                raise CasadiCollocatorException("Must enable the " +
                    "equation_scaling option to get scaled residuals")
            return self._get_par_vals()
            
    def _get_par_vals(self):
        return self._par_vals

    def get_opt_constraint_duals(self, scaled=False):
        """
        Get the optimal dual variables for the constraints

        If scaled is True then get the duals for the equation scaled NLP.
        """
        if not scaled:
            return self.dual_opt['g']
        else:
            if not self.equation_scaling:
                raise CasadiCollocatorException("Must enable the " +
                    "equation_scaling option to get scaled residuals")
            return self._inv_scale_residuals(self.dual_opt['g'])

    def get_nlp(self, point="fcn", scaled_residuals=False):
        """
        Get the nlp residual function.
        
        Parameters::
            
            point --
                Evaluation point. Possible values: "fcn", "init", "opt",
                "sym"
                
                "fcn": Returns an SXFunction
                
                "init": Numerical evaluation at the initial guess
                
                "opt": Numerical evaluation at the found optimum
                
                "sym": Symbolic evaluation
                
                Type: str
                Default: "fcn"

            scaled_residuals --
                If True, return the residuals for the equation scaled NLP.
        
        Returns::
            
            objective --
                The objective value evaluated in the given point

            residuals --
                The constraint residuals evaluated in the given point
        """
        nlp_fcn = self.solver_object.nlp()
        if point == "fcn":
            return nlp_fcn
        elif point == "init":
            nlp_fcn.setInput(self.xx_init, casadi.NLP_SOLVER_X0)
        elif point == "opt":
            nlp_fcn.setInput(self.primal_opt, casadi.NLP_SOLVER_X)
        elif point == "sym":
            return nlp_fcn.call([self.xx, self.pp],True)
        else:
            raise ValueError("Unkonwn point value: " + repr(point))
        nlp_fcn.setInput(self.get_par_vals(scaled_residuals=scaled_residuals), casadi.NLP_SOLVER_P)
        nlp_fcn.evaluate()
        return (nlp_fcn.output(0).getValue(), nlp_fcn.output(1).toArray().ravel())

    def get_J(self, point="fcn", scaled_residuals=False, dense=True):
        """
        Get the Jacobian of the constraints.
        
        Parameters::
            
            point --
                Evaluation point. Possible values: "fcn", "init", "opt",
                "sym"
                
                "fcn": Returns an SXFunction
                
                "init": Numerical evaluation at the initial guess
                
                "opt": Numerical evaluation at the found optimum
                
                "sym": Symbolic evaluation
                
                Type: str
                Default: "fcn"
        
            scaled_residuals --
                If True, return the Jacobian for the equation scaled NLP.

        Returns::
            
            matrix --
                Matrix value
        """
        J_fcn = self.solver_object.jacG()
        if point == "fcn":
            return J_fcn
        elif point == "init":
            J_fcn.setInput(self.xx_init, casadi.NLP_SOLVER_X0)
        elif point == "opt":
            J_fcn.setInput(self.primal_opt, casadi.NLP_SOLVER_X)
        elif point == "sym":
            return J_fcn.call([self.xx, self.pp],True)[0]
        else:
            raise ValueError("Unkonwn point value: " + repr(point))
        J_fcn.setInput(self.get_par_vals(scaled_residuals=scaled_residuals), casadi.NLP_SOLVER_P)
        J_fcn.evaluate()
        result = J_fcn.output(0)
        if dense: result = result.toArray()
        else: result = result.toCsc_matrix()
        return result
    
    def get_H(self, point="fcn", scaled_residuals=False):
        """
        Get the Hessian of the Lagrangian.
        
        Parameters::
            
            point --
                Evaluation point. Possible values: "fcn", "init", "opt",
                "sym"
                
                "fcn": Returns an SXFunction
                
                "init": Numerical evaluation at the initial guess
                
                "opt": Numerical evaluation at the found optimum
                
                "sym": Symbolic evaluation
                
                Type: str
                Default: "fcn"
        
            scaled_residuals --
                If True, return the Hessian for the equation scaled NLP.

        Returns::
            
            matrix --
                Matrix value

            sigma --
                Symbolic sigma. Only returned if point is "sym".

            dual --
                Symbolic dual variables. Only returned if point is "sym".
        """
        H_fcn = self.solver_object.hessLag()
        if point == "fcn":
            return H_fcn
        elif point == "init":
            x = self.xx_init
            sigma = self._compute_sigma(scaled_residuals=scaled_residuals)
            dual = N.zeros(self.c_e.numel() +
                           self.c_i.numel())
            H_fcn.setInput(x, casadi.NLP_SOLVER_X)
            H_fcn.setInput(self.get_par_vals(scaled_residuals=scaled_residuals), casadi.NLP_SOLVER_P)
            H_fcn.setInput(sigma, 2)
            H_fcn.setInput(dual, 3)
        elif point == "opt":
            x = self.primal_opt
            sigma = self._compute_sigma(scaled_residuals=scaled_residuals)
            dual = self.get_opt_constraint_duals(scaled=scaled_residuals)
            H_fcn.setInput(x, casadi.NLP_SOLVER_X)
            H_fcn.setInput(self.get_par_vals(scaled_residuals=scaled_residuals), casadi.NLP_SOLVER_P)
            H_fcn.setInput(sigma, 2)
            H_fcn.setInput(dual, 3)
        elif point == "sym":
            nu = casadi.MX.sym("nu", self.c_e.numel())
            sigma = casadi.MX.sym("sigma")
            lam = casadi.MX.sym("lambda", self.c_i.numel())
            dual = casadi.vertcat([nu, lam])
            return [H_fcn.call([self.xx, self.pp, sigma, dual],True)[0], sigma,
                    dual]
        else:
            raise ValueError("Unkonwn point value: " + repr(point))
        H_fcn.evaluate()
        return H_fcn.output(0).toArray()

    def get_KKT(self, point="fcn", scaled_residuals=False):
        """
        Get the KKT matrix.

        This only constructs the simple KKT system [H, J^T; J, 0]; not the full
        KKT system used by IPOPT. However, if the problem has no inequality
        constraints (including bounds), they coincide.
        
        Parameters::
            
            point --
                Evaluation point. Possible values: "fcn", "init", "opt",
                "sym"
                
                "fcn": Returns an SXFunction
                
                "init": Numerical evaluation at the initial guess
                
                "opt": Numerical evaluation at the found optimum
                
                "sym": Symbolic evaluation
                
                Type: str
                Default: "fcn"

            scaled_residuals --
                If True, return the KKT matrix for the equation scaled NLP.
        
        Returns::
            
            matrix --
                Matrix value

            sigma --
                Symbolic sigma. Only returned if point is "sym".

            dual --
                Symbolic dual variables. Only returned if point is "sym".
        """
        if point == "fcn" or point == "sym":
            x = self.xx
            J = self.get_J("sym", scaled_residuals=scaled_residuals)
            [H, sigma, dual] = self.get_H("sym", scaled_residuals=scaled_residuals)
            zeros = N.zeros([dual.numel(), dual.numel()])
            KKT = casadi.blockcat([[H, J.T], [J, zeros]])
            if point == "sym":
                return KKT
            else:
                KKT_fcn = casadi.MXFunction([x, [], sigma, dual], [KKT])
                return KKT_fcn
        elif point == "init":
            x = self.xx_init
            dual = N.zeros(self.c_e.numel() +
                           self.c_i.numel())
        elif point == "opt":
            x = self.primal_opt
            dual = self.get_opt_constraint_duals(scaled=scaled_residuals)
        else:
            raise ValueError("Unkonwn point value: " + repr(point))
        sigma = self._compute_sigma(scaled_residuals=scaled_residuals)
        J = self.get_J(point, scaled_residuals=scaled_residuals)
        H = self.get_H(point, scaled_residuals=scaled_residuals)
        zeros = N.zeros([len(dual), len(dual)])
        KKT = N.bmat([[H, J.T], [J, zeros]])
        return KKT

    def _compute_sigma(self, scaled_residuals=False):
        """
        Computes the objective scaling factor sigma.

        Parameters::

            scaled_residuals --
                If True, return sigma for the equation scaled NLP.
        """
        grad_fcn = self.solver_object.gradF()
        grad_fcn.setInput(self.xx_init, casadi.NLP_SOLVER_X0)
        grad_fcn.setInput(self.get_par_vals(scaled_residuals=scaled_residuals), casadi.NLP_SOLVER_P)
        grad_fcn.evaluate()
        grad = grad_fcn.output(0).toArray()
        sigma_inv = N.linalg.norm(grad, N.inf)
        if sigma_inv < 1000.:
            return 1.
        else:
            return 1. / sigma_inv

    def get_nlp_constraint_types(self):
        """
        Get a list of all types of constraints that have mappings to the NLP
        """
        return self.c_dests.keys()

    def get_nlp_constraint_indices(self, eqtype):
        """
        Get a mapping from continuous time equations to NLP constraints

        Parameters::

            eqtype --
                Type of equation, see get_nlp_constraint_kinds() for available
                types in the model.
                Possible values include

                    'initial', 'dae', 'path_eq', 'path_ineq',
                    'point_eq', 'point_ineq'

        Returns::

            indices --
                Array of shape (n_tp, n_eq) of indices into the
                NLP constraints, where n_tp is the number of time points found
                and n_eq the number of equations of the corresponding kind.

            i --
                The element index for each time point. -1 if not applicable.

            k --
                The collocation point index for each time point.
                -1 if not applicable.

        """
        if eqtype not in self.c_dests:
            return (N.zeros((0,0), dtype=N.int),
                N.zeros(0, dtype=N.int), N.zeros(0, dtype=N.int))
        
        dest = self.c_dests[eqtype]
        
        indices = N.array(dest['inds'], dtype=N.int)
        if dest['kind'] == 'ineq':
            # inequalities come after equalities in the constraints
            indices += self.c_e.numel()
        else:
            assert dest['kind'] == 'eq', "Unrecognized equation kind"

        i = N.array(dest['i'], dtype=N.int)
        k = N.array(dest['k'], dtype=N.int)
        
        return (indices, i, k)

    def get_nlp_variable_indices(self, var):
        """
        Get a mapping from continuous time equations to NLP constraints

        Parameters::

            var --
                The model variable to get the NLP variables for

        Returns::

            indices --
                Vector of indices into the NLP variables

            i --
                The element index for each time point. -1 if not applicable.

            k --
                The collocation point index for each time point.
                -1 if not applicable.

        """
        if isinstance(var, basestring):
            var = self.op.getVariable(var)

        dest = self.xx_dests[var]

        inds = N.array(dest['inds'], dtype=N.int)
        i = N.array(dest['i'], dtype=N.int)
        k = N.array(dest['k'], dtype=N.int)
        
        return (inds, i, k)

    def enable_codegen(self, name=None):
        """
        Enables use of generated C code for the collocator. Generates and
        compiles code for the NLP, gradient of f, Jacobian of g, and Hessian
        of the Lagrangian of g Function objects, and then replaces the solver
        object in the collocator with a new one that makes use of the
        compiled functions as ExternalFunction objects.
        
        Parameters::
        
            name --
                A string that if it is not None, tries to load existing files
                nlp_[name].so, grad_f_[name].so, jac_g_[name].so and
                hess_lag_[name].so as ExternalFunction objects to be used
                by the solver rather than generating new code. If any of the
                files don't exist, new files are generated with the above
                names.
                Default: None
        """
        enable_codegen(self, name)


def _add_help_fcns(filename):
    """
    Adds the functions \"sq\" and \"sign\" to a generated .c file if
    they don't already exist, since generateCode doesn't always generate
    them. Help function to _to_external_function.
    
    Parameters:
    
        filename --
            The name of the generated .c file to add the functions to,
            including file extension.
    """
    with open(filename, 'r') as infile:
        contents = infile.read()
        
        add_sq = False
        add_sign = False
    
        if 'd sq(d x)' not in contents:
            add_sq = True
        if 'd sign(d x)' not in contents:
            add_sign = True
    
    if add_sq or add_sign:
        with open(filename, 'w') as outfile:
            for line in contents.splitlines(True):
                outfile.write(line)
                if '#define d double' in line:
                    if add_sq:
                        outfile.write('\nd sq(d x) { return x*x;}\n')
                    if add_sign:
                        outfile.write('\nd sign(d x) { return x<0 ? -1 : x>0 ? 1 : x;}\n')

def _to_external_function(fcn, name, use_existing=False):
    """
    Generates C code for a Function object using its generateCode member
    function, compiles the generated code, and returns it as an
    ExternalFunction object. Help function to enable_codegen.
    
    Parameters::
    
        fcn --
            The Function object for which to generate code.
            
        name --
            A string containing the file name to be used for the
            generated code, without file extension.
            
        use_existing --
            A boolean that if it is set, doesn't generate new code and
            just returns name.so (where name is the function parameter)
            as an ExternalFunction object.
            Default: False
    """
    if os.name == 'nt':
        ext = '.dll'
    else:
        ext = '.so'
    if not use_existing:
        print 'Generating code for', name
        fcn.generateCode(name + '.c')
        _add_help_fcns(name + '.c')
        bitness_flag = '-m32' if struct.calcsize('P') == 4 else '-m64'
        exit_code = system('gcc ' + bitness_flag + ' -fPIC -shared -O3 ' + name + '.c -o ' + name + ext)
        if exit_code != 0:
            return fcn # fall back to uncompiled version
    fcn_e = casadi.ExternalFunction('./' + name + ext)
    return fcn_e
    
def enable_codegen(coll, name=None):
    """
    Enables use of generated C code for a collocator. Generates and compiles
    code for the NLP, gradient of f, Jacobian of g, and Hessian of the
    Lagrangian of g Function objects, and then replaces the solver
    object in the solver's collocator with a new one that makes use of
    the compiled functions as ExternalFunction objects.
    
    Parameters::
    
        coll --
            The LocalDAECollocator for which to enable use of generated code.
            
        name --
            A string that if it is not None, tries to load existing files
            nlp_[name].so, grad_f_[name].so, jac_g_[name].so and
            hess_lag_[name].so as ExternalFunction objects to be used
            by the solver rather than generating new code. If any of the
            files don't exist, new files are generated with the above
            names.
            Default: None
    """
    if os.name == 'nt':
        ext = '.dll'
    else:
        ext = '.so'
    
    old_solver = coll.solver_object
    
    nlp = old_solver.nlp()
    nlp.init()
    grad_f = old_solver.gradF()
    grad_f.init()
    jac_g = old_solver.jacG()
    jac_g.init()
    hess_lag = old_solver.hessLag()
    hess_lag.init()
    
    existing = False
    if name == None:
        enable_codegen.times += 1
        name = str(enable_codegen.times)
    else:
        if (path.isfile('nlp_'+name+ext) and
            path.isfile('grad_f_'+name+ext) and
            path.isfile('jac_g_'+name+ext) and
            path.isfile('hess_lag_'+name+ext)):
            existing = True
    
    nlp = _to_external_function(nlp, 'nlp_' + name, existing)
    grad_f = _to_external_function(grad_f, 'grad_f_' + name, existing)
    jac_g = _to_external_function(jac_g, 'jac_g_' + name, existing)
    hess_lag = _to_external_function(hess_lag, 'hess_lag_' + name, existing)
    
    solver_cg = casadi.NlpSolver('ipopt', nlp)
    
    old_solver_options = old_solver.dictionary()
    old_solver_options['expand'] = False
    solver_cg.setOption(old_solver_options)
    
    solver_cg.setOption('grad_f', grad_f)
    solver_cg.setOption('jac_g', jac_g)
    solver_cg.setOption('hess_lag', hess_lag)
    
    solver_cg.init()
    
    lbx = old_solver.getInput('lbx')
    ubx = old_solver.getInput('ubx')
    lbg = old_solver.getInput('lbg')
    ubg = old_solver.getInput('ubg')
    x0 = old_solver.getInput('x0')
    p = old_solver.getInput('p')
    
    solver_cg.setInput(lbx, 'lbx')
    solver_cg.setInput(ubx, 'ubx')
    solver_cg.setInput(lbg, 'lbg')
    solver_cg.setInput(ubg, 'ubg')
    solver_cg.setInput(x0, 'x0')
    solver_cg.setInput(p, 'p')
    
    coll.solver_object = solver_cg
    
enable_codegen.times = 0


class MeasurementData(object):

    """
    This class is obsolete and replaced by ExternalData.
    """
    
    def __init__(self, eliminated=OrderedDict(), constrained=OrderedDict(),
                 unconstrained=OrderedDict(), Q=None):
        raise DeprecationWarning('MeasurementData is obsolete. ' +
                                 'Use ExternalData instead.')

class LocalDAECollocationAlgResult(JMResultBase):
    
    """
    A JMResultBase object with the additional attributes times and h_opt.
    
    Attributes::
    
        times --
            A dictionary with the keys 'init', 'sol', 'post_processing' and
            'tot', which measure CPU time consumed during different algorithm
            stages.

            times['init'] is the time spent creating the NLP.
            
            times['update'] is the time spent initializing the solver and 
            other things related to pre-processing when using warm start.
            
            times['sol'] is the time spent solving the NLP (total Ipopt
            time).
            
            times['post_processing'] is the time spent processing the NLP
            solution before it is returned.
            
            times['tot'] is the sum of all the other times.
            
            Type: dict
        
        h_opt --
            An array with the normalized optimized element lengths.
            
            The element lengths are only optimized (and stored in a class
            instance) if the algorithm option "hs" == free. Otherwise this
            attribute is None.
            
            Type: ndarray of floats or None
    """
    
    def __init__(self, model=None, result_file_name=None, solver=None, 
                 result_data=None, options=None, times=None, h_opt=None):
        super(LocalDAECollocationAlgResult, self).__init__(
                model, result_file_name, solver, result_data, options)
        self.h_opt = h_opt
        self.times = times
        
        if solver is not None:
            # Save values from the solver since they might change in the solver.
            # Assumes that solver.primal_opt and solver.dual_opt will not be mutated, which seems to be the case.
            self.primal_opt = solver.primal_opt
            self.dual_opt = solver.dual_opt
            self.solver_statistics = solver.get_solver_statistics()
            self.opt_input = solver.get_opt_input()

        if times is not None and self.options['verbosity'] >= 1:
            # Print times
            print("\nInitialization time: %.2f seconds" % times['init'])
            
            print("\nTotal time: %.2f seconds" % times['tot'])
            print("Pre-processing time: %.2f seconds" % times['update'])
            print("Solution time: %.2f seconds" % times['sol'])
            print("Post-processing time: %.2f seconds\n" %
                  times['post_processing'])

        # Print condition numbers
        if options is not None and self.options['print_condition_numbers'] and self.options['verbosity'] >= 1:
            J_init_cond = N.linalg.cond(solver.get_J("init"), scaled_residuals=self.op.equation_scaling)
            J_opt_cond = N.linalg.cond(solver.get_J("opt"), scaled_residuals=self.op.equation_scaling)
            KKT_init_cond = N.linalg.cond(solver.get_KKT("init"), scaled_residuals=self.op.equation_scaling)
            KKT_opt_cond = N.linalg.cond(solver.get_KKT("opt"), scaled_residuals=self.op.equation_scaling)
            print("\nJacobian condition number at the initial guess: %.3g" %
                  J_init_cond)
            print("Jacobian condition number at the optimum: %.3g" %
                  J_opt_cond)
            print("KKT matrix condition number at the initial guess: %.3g" %
                  KKT_init_cond)
            print("KKT matrix condition number at the optimum: %.3g" %
                  KKT_opt_cond)

    def get_opt_input(self):
        """
        Get the optimized input variables as a function of time.

        The purpose of this method is to conveniently provide the optimized
        input variables to a simulator.

        Returns::

            input_names --
                Tuple consisting of the names of the input variables.

            input_interpolator --
                Collocation polynomials for input variables as a function of
                time.
        """
        return self.opt_input

    def get_solver_statistics(self):
        """ 
        Get nonlinear programming solver statistics.

        Returns::

            return_status -- 
                Return status from nonlinear programming solver.

            nbr_iter -- 
                Number of iterations.

            objective -- 
                Final value of objective function.

            total_exec_time -- 
                Nonlinear programming solver execution time.
        """
        return self.solver_statistics

    def get_solver(self):
        """
        Get the solver that was used to create this result.

        Returns an OptimizationSolver wrapping the collocator that was used.
        The solver can be used to query NLP solver progress
        for the optimization, such as residuals and dual variables.
        """
        return self.solver.wrapper


class OptimizationSolver(object):
    """
    Represents an initialized optimization problem that can be reoptimized with different settings.

    Wrapper class around LocalDAECollocator to supply a user interface for warm starting.
    """

    def __init__(self, collocator):
        """
        Create a wrapper around a collocator object to expose reoptimization functionality.

        The collocator should be a LocalDAECollocator.
        """
        self.collocator = collocator
        self.init_traj_set = False
        self.nominal_traj_updated = False
        self.solver_options_changed = False
        self.extra_update = 0

    def set(self, name, value):
        """Set the value of the named parameter from the original OptimizationProblem"""
        return self.collocator.op.set(name, value)

    def get(self, name):
        """Get the value of the named parameter from the original OptimizationProblem"""
        return self.collocator.op.get(name)

    def set_external_variable_data(self, name, data):
        """
        Set new data for one variable that was supplied using the external_data option

        Parameters::

            name --
                Name of a model variable that was given in the external_data
                option when the sovler was created with prepare_optimization.

            data --
                New data to use for the external variable given by name.
                The format is the same as used in external_data.

        The kind of external data used for the variable
        (eliminated/constrained/quadratic penalty) is not changed.
        
        The option mutable_external_data must be enabled to use this method.
        """
        self.collocator.set_external_variable_data(name, data)

    def set_solver_option(self, solver_name, name, value):
        """
        Set an option to the nonlinear programming solver.

        If solver_name does not correspond to the 'solver' option used
        in the optimization, the call is ignored.
        """
        if solver_name not in ['IPOPT', 'WORHP']:
            raise ValueError('Unknown nonlinear programming solver %s.' %
                             solver_name)
        if solver_name == self.collocator.solver:
            self.collocator.set_solver_option(name, value)
            self.solver_options_changed = True
            
    def set_nominal_traj(self, nom_traj, nom_traj_mode = None):
        """
        Define the nominal trajectory to use for scaling in the next
        optimization. Note that scaling by nominal trajectory has to be
        set during the initial creation of the optimization object.
        
        Parameters::
        
            nom_traj --
                The result from which variable scaling is computed.
            
            nom_traj_mode --
                The scaling mode for the nominal trajectories
        """
        t0 = time.clock()
        
        if not self.collocator.variable_scaling:
            raise CasadiCollocatorException("Variable scaling must have been initially used.")
        if not self.collocator.variable_scaling_allow_update:
            raise CasadiCollocatorException("Update of variable scaling must be set to true.")
        
        self.collocator.nominal_traj = nom_traj
        try:
            self.collocator.nominal_traj = self.collocator.nominal_traj.result_data
        except AttributeError:
            pass
            
        if nom_traj_mode is not None:
            self.collocator.nominal_traj_mode = nom_traj_mode
            
        self.collocator._create_trajectory_scaling_factor_structures() #Update the scaling values
        self.collocator._update_variable_scaling() #Update the scaling values in the parameters
        
        self.nominal_traj_updated = True
        
        self.extra_update = time.clock() - t0

    def set_init_traj(self, sim_result): 
        """ 
        Define the initial guess to use for the next optimization
        
        Parameters::
            
            sim_result --
                The result from which the initial guess is to be extracted.
        """
        t0 = time.clock()
        self.collocator.init_traj = sim_result
        try:
            self.collocator.init_traj = self.collocator.init_traj.result_data
        except AttributeError:
            pass

        self.init_traj_set = True
        self.collocator._create_initial_trajectories()        
        self.extra_update = time.clock() - t0
        
    def optimize(self):
        """Solve the optimization problem with the current settings, and return the result."""
        t0 = time.clock()
        
        if self.init_traj_set or self.nominal_traj_updated:
            self.collocator._compute_bounds_and_init() #Update the lower / upper bounds and init
        
        self.collocator._recalculate_model_parameters()

        if self.solver_options_changed:
            self.collocator.solver_object.init()
            self.solver_options_changed = False

        if self.collocator.warm_start:
            
            if not self.init_traj_set:
                self.collocator.xx_init = self.collocator.primal_opt
        
        if self.collocator.warm_start or self.nominal_traj_updated:
            self.nominal_traj_updated = False
            
            self.collocator._init_and_set_solver_inputs()

        self.init_traj_set = False
        # Add extra update times to update and reset
        self.collocator.times['update'] = time.clock() - t0 + self.extra_update # 'update' must be set before call to solve_and_write_result
        self.extra_update = 0
        
        self.collocator.solve_and_write_result()
       
        return self.collocator.get_result_object(include_init=False)

    def set_warm_start(self, warm_start):
        """
        Set whether warm start is enabled for the optimization

        When warm start is enabled, the last solutions for the primal and
        dual variables will be used as the starting point for the next
        optimization.

        If set_init_traj has been called on self since the last call to
        optimize, the supplied initial trajectory will be used for the
        primal variables instead.
        """
        self.collocator.warm_start = warm_start

    def get_nlp_variables(self, point = 'opt'):
        """
        Get the raw vector of (scaled) variable values for the underlying NLP.

        Parameters::
            
            point --
                The point where the variables should be evaluated,
                'opt' for the optimization solution or
                'init' for the initial guess.
                Default: 'opt'
        """
        assert point in ('opt', 'init')
        if point == 'opt':
            return self.collocator.primal_opt
        else:
            return self.collocator.xx_init

    def get_nlp_residuals(self, point = 'opt', raw=False, scaled=False):
        """
        Get the raw vector of residuals for the underlying NLP.

        The vector contains residuals for all equality and inequality
        constraints.

        Parameters::
            
            point --
                The point where the residuals should be evaluated,
                'opt' for the optimization solution or
                'init' for the initial guess.
                Default: 'opt'

            raw --
                If True, return the raw residuals.
                Otherwise, return the constraint violations:
                0 if not violating the bounds, the difference from
                the violated bound otherwise.
                Default: False

            scaled --
                If True, return the residuals for the equation scaled NLP.

        """
        assert point in ('opt', 'init')
        residuals = self.collocator.get_nlp(point, scaled_residuals=scaled)[1]
        if raw:
            return residuals
        lb, ub = self.get_nlp_residual_bounds(scaled=scaled)
        violations = N.zeros_like(residuals)
        violations[residuals < lb] = (residuals - lb)[residuals < lb]
        violations[residuals > ub] = (residuals - ub)[residuals > ub]
        return violations

    def get_nlp_residual_scales(self):
        """
        Get the raw vector of scaling factors used for the NLP residuals.

        The scaled residuals are those exposed to the NLP solver,
        and are formed as the product of the original (unscaled) residuals
        with the residual scale factors.

        Needs the equation_scaling option to be set to true.
        """
        return self.collocator.get_residual_scales()

    def get_nlp_variable_bounds(self):
        """Get the raw vectors (lb, ub) of bounds on variables in the underlying NLP"""
        # Returning copies to be safe
        return (N.array(self.collocator.xx_lb), N.array(self.collocator.xx_ub))

    def get_nlp_residual_bounds(self, scaled=False):
        """
        Get the raw vectors (lb, ub) of bounds on residuals in the underlying NLP

        Parameters::

            scaled --
                If True, return the residual bounds for the equation scaled NLP.        
        """
        if scaled:
            scales = self.collocator.get_residual_scales()
            return (self.collocator.gllb*scales, self.collocator.glub*scales)
        else:
            # Returning copies to be safe
            return (N.array(self.collocator.gllb), N.array(self.collocator.glub))

    def get_nlp_constraint_duals(self, scaled=False):
        """
        Get the raw vector of dual variables for the constraints in the underlying NLP

        Parameters::

            scaled --
                If True, return the constraint duals for the equation scaled NLP.        
        """
        return self.collocator.get_opt_constraint_duals(scaled).copy()

    def get_nlp_bound_duals(self):
        """Get the raw vector of dual variables for variable bounds in the underlying NLP"""
        # Returning a copy to be safe
        return N.array(self.collocator.dual_opt['x'])

    def get_constraint_types(self):
        """
        Get a list of all types of constraints that have mappings to the NLP
        """
        return self.collocator.get_nlp_constraint_types()

    def get_nlp_constraint_indices(self, eqtype):
        """
        Get a mapping from continuous time equations to NLP constraints

        Parameters::

            eqtype --
                Type of equation, see get_constraint_types() for available
                types in the model.
                Possible values include

                    'initial', 'dae', 'path_eq', 'path_ineq',
                    'point_eq', 'point_ineq'

        Returns::

            indices --
                Array of shape (n_tp, n_eq) of indices into the
                NLP constraints, where n_tp is the number of time points found
                and n_eq the number of equations of the corresponding kind.

            time --
                The time for each time point

            i --
                The element index for each time point. -1 if not applicable.

            k --
                The collocation point index for each time point.
                -1 if not applicable.
        """
        inds, i, k = self.collocator.get_nlp_constraint_indices(eqtype)
        time = self.get_point_time(i, k)
        return (inds, time, i, k)

    def get_nlp_variable_indices(self, var):
        """
        Get a mapping from continuous time equations to NLP constraints

        Parameters::

            var --
                The model variable to get the NLP variables for

        Returns::

            indices --
                Vector of indices into the NLP variables

            time --
                The time for each time point

            i --
                The element index for each time point. -1 if not applicable.

            k --
                The collocation point index for each time point.
                -1 if not applicable.

        """
        inds, i, k = self.collocator.get_nlp_variable_indices(var)
        time = self.get_point_time(i, k)
        return (inds, time, i, k)

    def get_constraint_points(self, eqtype):
        """
        Get the time points where a given equation type is instantiated.

        For the given equation type, each equation is instantiated in the time
        points returned, so residuals, residual scale factors, and dual
        variables all refer to the these points.

        Parameters::
            eqtype --
                Type of equation, see get_constraint_types() for available
                types in the model.
                Possible values include

                    'initial', 'dae', 'path_eq', 'path_ineq',
                    'point_eq', 'point_ineq'
        Returns::

            time --
                The time for each time point

            i --
                The element index for each time point. -1 if not applicable.

            k --
                The collocation point index for each time point.
                -1 if not applicable.
        """
        rinds, time, i, k = self.get_nlp_constraint_indices(eqtype)
        return time, i, k

    def get_residuals(self, eqtype, inds=None, point='opt', raw=False, scaled=False, tik=False):
        """
        Get the residuals for a given equation type.

        Parameters::
            eqtype --
                Type of equation, see get_constraint_types() for available
                types in the model.
                Possible values include

                    'initial', 'dae', 'path_eq', 'path_ineq',
                    'point_eq', 'point_ineq'

            inds --
                Iterable of equation indices within eqtype that the residuals
                should be returned for, or None if residuals should be
                returned for all equations.
                Default: None

            point --
                The point where the residuals should be evaluated,
                'opt' for the optimization solution or
                'init' for the initial guess.
                Default: 'opt'

            raw --
                If True, return the raw residuals.
                Otherwise, return the constraint violations:
                0 if not violating the bounds, the difference from
                the violated bound otherwise.
                Default: False

            scaled --
                If True, return the residuals for the equation scaled NLP.        

            tik:
                If True, return (residuals, time, i, k),
                otherwise return just residuals. (Use get_constraint_points
                to get (time, i, k)).

        Returns::

            residuals --
                Array of shape (n_tp, n_eq) of residuals,
                where n_tp is the number of time points found
                and n_eq the number of equations.

            time --
                The time for each time point

            i --
                The element index for each time point. -1 if not applicable.

            k --
                The collocation point index for each time point.
                -1 if not applicable.
        """
        rinds, time, i, k = self.get_nlp_constraint_indices(eqtype)
        residuals = self.get_nlp_residuals(point, raw=raw, scaled=scaled)
        residuals = residuals[rinds]
        if inds is not None:
            residuals = residuals[:, inds]
        if tik:
            return (residuals, time, i, k)
        else:
            return residuals

    def get_constraint_duals(self, eqtype, inds=None, scaled=False, tik=False):
        """
        Get the dual variables at the optimization solution for a given equation type.

        Parameters::
            eqtype --
                Type of equation, see get_constraint_types() for available
                types in the model.
                Possible values include

                    'initial', 'dae', 'path_eq', 'path_ineq',
                    'point_eq', 'point_ineq'

            inds --
                Iterable of equation indices within eqtype that the duals
                should be returned for, or None if duals should be
                returned for all equations.
                Default: None

            scaled --
                If True, return the constraint duals for the equation scaled NLP.        

            tik:
                If True, return (duals, time, i, k),
                otherwise return just duals. (Use get_constraint_points
                to get (time, i, k)).

        Returns::

            duals --
                Array of shape (n_tp, n_eq) of dual variable values,
                where n_tp is the number of time points found
                and n_eq the number of equations.

            time --
                The time for each time point

            i --
                The element index for each time point. -1 if not applicable.

            k --
                The collocation point index for each time point.
                -1 if not applicable.
        """
        rinds, time, i, k = self.get_nlp_constraint_indices(eqtype)
        duals = self.get_nlp_constraint_duals(scaled=scaled)
        duals = duals[rinds]
        if inds is not None:
            duals = duals[:, inds]
        if tik:
            return (duals, time, i, k)
        else:
            return duals

    def get_residual_scales(self, eqtype, inds=None):
        """
        Get the residual scaling factors for a given equation type.

        The scaled residuals are those exposed to the NLP solver,
        and are formed as the product of the original (unscaled) residuals
        with the residual scale factors.

        As a result, the scaled (constraint) dual variables obtained from
        the NLP solver are equal to the constraint duals for the original
        (unscaled) problem divided by the residual scale factors.

        Needs the equation_scaling option to be enabled.

        Parameters::
            eqtype --
                Type of equation, see get_constraint_types() for available
                types in the model.
                Possible values include

                    'initial', 'dae', 'path_eq', 'path_ineq',
                    'point_eq', 'point_ineq'

            inds --
                Iterable of equation indices within eqtype that the scale
                factors should be returned for, or None if scale factors
                should be returned for all equations.
                Default: None

        Returns::

            residual_scales --
                Array of shape (n_tp, n_eq) of scale factors,
                where n_tp is the number of time points found
                and n_eq the number of equations.
                The corresponding time points can be retrieved
                with the get_constraint_points method.
        """
        rinds, time, i, k = self.get_nlp_constraint_indices(eqtype)
        scales = self.get_nlp_residual_scales()
        scales = scales[rinds]
        if inds is not None:
            scales = scales[:, inds]
        return scales

    def get_variable_points(self, var):
        """
        Get the time points where a given equation variable is instantiated.

        These are the time points at which an NLP variable has been created
        from the given variable in the model, and the time points that
        bounds duals for the variable refer to.

        Parameters::
            var --
                The model variable to get the time points for.
                Type: string or Variable

        Returns::

            time --
                The time for each time point

            i --
                The element index for each time point. -1 if not applicable.

            k --
                The collocation point index for each time point.
                -1 if not applicable.
        """
        inds, time, i, k = self.get_nlp_variable_indices(var)
        return time, i, k

    def get_bound_duals(self, var, tik=False):
        """
        Get the dual variables at the optimization solution for the bounds on the given variable.

        Parameters::
            var --
                The model variable to get the bounds dual variables for.
                Type: string or Variable

            tik:
                If True, return (duals, time, i, k),
                otherwise return just duals. (Use get_variable_points
                to get (time, i, k)).

        Returns::

            duals --
                Vector of bounds duals for the given model variable

            time --
                The time for each time point

            i --
                The element index for each time point. -1 if not applicable.

            k --
                The collocation point index for each time point.
                -1 if not applicable.
        """
        inds, time, i, k = self.get_nlp_variable_indices(var)
        duals = self.get_nlp_bound_duals()
        duals = duals[inds]
        if tik:
            return duals, time, i, k
        else:
            return duals

    def get_residual_norms(self, eqtype=None, point='opt', scaled=False, ord=N.inf):
        """
        List the norms of different parts of the residual, in descending order

        For inequality constraints, only the constraint violation contributes
        to the norm.

        Parameters::
            eqtype --
                If None, list all equation types and their residual norms.
                Otherwise, list the residual norm of each equation
                of the given type, along with its index within the type.
                Default: None

            point --
                The point where the residuals should be evaluated,
                'opt' for the optimization solution or
                'init' for the initial guess.
                Default: 'opt'

            scaled --
                If True, consider the residuals for the equation scaled NLP.

            ord --
                Vector norm order used with numpy.linalg.norm
        """
        result = []

        if eqtype is None:
            for eqtype in self.get_constraint_types():
                r = self.get_residuals(eqtype, point=point, scaled=scaled, tik=False)
                rnorm = N.linalg.norm(r.ravel(), ord=ord)
                result.append((rnorm, eqtype))
        else:
            r = self.get_residuals(eqtype, point=point, scaled=scaled, tik=False)
            for j in xrange(r.shape[1]):
                rnorm = N.linalg.norm(r[:,j], ord=ord)
                result.append((rnorm, j))

        result.sort(reverse = True)
        return result

    def get_residual_scale_norms(self, eqtype=None, inv=False, ord=N.inf):
        """
        List the norms of different parts of the residual scales, in descending order.        

        For the inverse scale factors, the equations/equation types
        that have been scaled down the most will appear first.

        Parameters::
            eqtype --
                If None, list all equation types and their scaling norms.
                Otherwise, list the scaling norm of each equation
                of the given type, along with its index within the type.
                Default: None

            inv --
                If True, consider the inverse scale factors instead.

            ord --
                Vector norm order used with numpy.linalg.norm
        """
        result = []

        if eqtype is None:
            for eqtype in self.get_constraint_types():
                r = self.get_residual_scales(eqtype)
                if inv:
                    r = 1/r
                rnorm = N.linalg.norm(r.ravel(), ord=ord)
                result.append((rnorm, eqtype))
        else:
            r = self.get_residual_scales(eqtype)
            if inv:
                r = 1/r
            for j in xrange(r.shape[1]):
                rnorm = N.linalg.norm(r[:,j], ord=ord)
                result.append((rnorm, j))

        result.sort(reverse = True)
        return result

    def get_equations(self, eqtype, eqinds=None):
        """
        Get model equations corresponding to the given equation type

        Parameters::
            eqtype --
                Type of equation. The only values supported are

                    'initial', 'dae',
                    'path_eq', 'path_ineq',
                    'point_eq', 'point_ineq'

            eqinds --
                Indices of the equations to be returned.
                If None, return all equations of the given type in index order.
                Default: None
        """
        if eqinds is not None:
            return self.get_equations(eqtype)[eqinds]

        op = self.collocator.op
        # To be safe, only returning copies
        if eqtype == 'initial':      return op.getInitialEquations()
        elif eqtype == 'dae':        return op.getDaeEquations()
        elif eqtype == 'path_eq':    return N.array(self.collocator.path_eq_orig)
        elif eqtype == 'path_ineq':  return N.array(self.collocator.path_ineq_orig)
        elif eqtype == 'point_eq':   return N.array(self.collocator.point_eq_orig)
        elif eqtype == 'point_ineq': return N.array(self.collocator.point_ineq_orig)
        else: raise KeyError("Unsupported equation type %s" % repr(eqtype))

    def get_nlp_jacobian(self, point='opt', scaled_residuals=False):
        """
        Get the raw Jacobian of the nlp's constraints

        Parameters::
            point --
                The point where the Jacobian should be evaluated,
                'opt' for the optimization solution or
                'init' for the initial guess.
                Default: 'opt'

            scaled_residuals --
                If True, return the Jacobian for the equation scaled NLP.

        Returns::
            J --
                The constraint Jacobian evaluated at the given point.
                Type: scipy.sparse.csc_matrix
        """
        assert point in ('opt', 'init')
        return self.collocator.get_J(point, scaled_residuals=scaled_residuals, dense=False)

    def get_point_time(self, i, k):
        """
        Return a vector of times corresponding to the time points zip(ii,kk)        
        """
        return self.collocator.get_point_time(N.maximum(1, i), N.maximum(0, k))

    def get_model_variables(self, xx_inds):
        """
        Get the model variables corresponding to the given nlp variables

        Parameters::
            xx_inds --
                Array of indices into the nlp variables

        Returns::
            vars --
                Array of model variables

            time --
                The time that each variable was instantiated

            i --
                The element index where each variable was instantiated.
                -1 if not applicable.

            k --
                The collocation point where each variable was instantiated.
                -1 if not applicable.
        """
        xx_sources = self.collocator.xx_sources
        vars = xx_sources['var'][xx_inds]
        i    = xx_sources['i'][xx_inds]
        k    = xx_sources['k'][xx_inds]
        time = self.get_point_time(i, k)
        return (vars, time, i, k)

    def get_model_constraints(self, c_inds):
        """
        Get the model constraints corresponding to the given nlp constraints

        Parameters::
            c_inds --
                Array of indices into the nlp constraints

        Returns::
            eqtypes --
                The constraint type for each constraint

            eqinds --
                The index within constraint type for each constraint

            time --
                The time that each constraint was instantiated

            i --
                The element index where each constraint was instantiated.
                -1 if not applicable.

            k --
                The collocation point where each constraint was instantiated.
                -1 if not applicable.
        """
        c_sources = self.collocator.c_sources
        eqtypes = c_sources['eqtype'][c_inds]
        eqinds  = c_sources['eqind'][c_inds]
        i       = c_sources['i'][c_inds]
        k       = c_sources['k'][c_inds]
        time = self.get_point_time(i, k)
        return (eqtypes, eqinds, time, i, k)

    def get_model_jacobian_entries(self, c_inds, xx_inds):
        """
        List model equations and variables corresponding to constraints and variables in the nlp

        Map zip(c_inds, xx_inds) to model equations and variables and
        return a set of (eqtype, eqind, var) tuples for each unique
        combination.
        """
        c_sources, xx_sources = self.collocator.c_sources, self.collocator.xx_sources
        combos = set(zip(c_sources['eqtype'][c_inds], c_sources['eqind'][c_inds], xx_sources['var'][xx_inds]))

        return combos

    def find_nonfinite_jacobian_entries(self, point='opt'):
        """
        Return combinations of model constraints and variables where the Jacobian is nonfinite

        Return a set of (eqtype, eqind, var) tuples where the equation
        (eqtype, eqind) has a nonfinite derivative with respect to var
        at some time point.

        Parameters::
            point --
                The point where the Jacobian should be evaluated,
                'opt' for the optimization solution or
                'init' for the initial guess.
                Default: 'opt'
        """
        J = self.get_nlp_jacobian(point)
        # J-J != 0 only at entries that are +-inf or nan
        c_inds, xx_inds = N.nonzero(J-J)
        return self.get_model_jacobian_entries(c_inds, xx_inds)

    def print_jacobian_entries(self, entries):
        """
        Print a list of Jacobian entries

        Parameters::
            entries --
                Iterable of entries (eqtype, eqind, var) as returned from
                find_nonfinite_jacobian_entries or get_model_jacobian_entries
        """
        last_eqtype = None
        last_eqind = -1
        for (eqtype, eqind, var) in sorted(entries):
            if eqtype != last_eqtype or eqind != last_eqind:
                # Print new equation
                try:
                    eq = self.get_equations(eqtype)[eqind] # todo: faster lookup?
                    print "\nEquation(%s):" % eqtype, eq
                except (KeyError, IndexError):
                    print "\nEquation: (%s, %i)" % (eqtype, eqind)

                last_eqtype, last_eqind = eqtype, eqind
            print "wrt", var

    def print_nonfinite_jacobian_entries(self, point='opt'):
        """
        List combinations of model equations and variables where the Jacobian is nonfinite

        Parameters::
            point --
                The point where the Jacobian should be evaluated,
                'opt' for the optimization solution or
                'init' for the initial guess.
                Default: 'opt'
        """
        print "Nonfinite Jacobian entries:"
        print "---------------------------"
        self.print_jacobian_entries(self.find_nonfinite_jacobian_entries(point))
    
    def enable_codegen(self, name):
        """
        Enables use of generated C code for the solver's collocator.
        Generates and compiles code for the NLP, gradient of f, Jacobian of g,
        and Hessian of the Lagrangian of g Function objects, and then replaces
        the solver object in the collocator with a new one that makes use of
        the compiled functions as ExternalFunction objects.
        
        Parameters::
        
            name --
                A string that if it is not None, tries to load existing files
                nlp_[name].so, grad_f_[name].so, jac_g_[name].so and
                hess_lag_[name].so as ExternalFunction objects to be used
                by the solver rather than generating new code. If any of the
                files don't exist, new files are generated with the above
                names.
                Default: None
        """
        self.collocator.enable_codegen(name)
