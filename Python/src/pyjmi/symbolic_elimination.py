#!/usr/bin/env python 
# -*- coding: utf-8 -*-

# Copyright (C) 2016 Modelon AB
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

import matplotlib.pyplot as plt
import numpy as np
import copy
import scipy
import casadi
import modelicacasadi_wrapper as ci
import itertools
from collections import OrderedDict
from modelicacasadi_wrapper import Model
from pyjmi.common.core import ModelBase
from pyjmi.common.algorithm_drivers import OptionBase

class EliminationOptions(OptionBase):

    """
    dict-like options class for the elimination.

    Standard options::

        draw_blt --
            Whether to plot the BLT form.

            Default: False

        draw_blt_strings --
            Whether to annotate plot of the BLT form with strings for variables and equations.

            Default: False

        tearing --
            Whether to tear algebraic loops.

            Type: bool
            Default: True

        ineliminable --
            List of names of variables that should not be eliminated. Particularly useful for variables with bounds.

            Default: []

        dense_measure --
            Density measure for controlling density in causalized system. Possible values: ['lmfi', 'Markowitz']

            Markowitz uses the Markowitz criterion and lmfi uses local minimum fill-in to estimate density.

            Default: 'lmfi'

        dense_tol --
            Tolerance for controlling density in causalized system. Possible values: [-inf, inf]

            Default: 15

    Experimental/debug options::

        plots --
            Whether to plot intermediate results for matching and component computation.

            Default: False

        solve_blocks --
            Whether to factorize coefficient matrices in non-scalar, linear blocks.

            Default: False

        solve_torn_linear_blocks --
            Whether to solve causalized equations in torn blocks, rather than doing forward substitution as for
            nonlinear blocks.

            Default: False

        inline --
            Whether to inline function calls (such as creation of linear systems).

            Default: True

        linear_solver --
            Which linear solver to use.
            See http://casadi.sourceforge.net/api/html/d8/d6a/classcasadi_1_1LinearSolver.html for possibilities

            Default: "symbolicqr"

        closed_form --
            Whether to create a closed form expression for residuals and solutions. Disables computations.

            Default: False

        inline_solved --
            Whether to inline solved expressions in the closed form expressions (only applicable
            if closed_form == True).

            Default: False
    """
    
    def __init__(self, *args, **kw):
        _defaults = {
                'plots': False,
                'draw_blt': False,
                'draw_blt_strings': False,
                'solve_blocks': False,
                'solve_torn_linear_blocks': False,
                'tearing': True,
                'inline': True,
                'closed_form': False,
                'inline_solved': False,
                'ineliminable': [],
                'linear_solver': "symbolicqr",
                'dense_tol': 15,
                'dense_measure': 'lmfi'}
        
        super(EliminationOptions, self).__init__(_defaults)
        self._update_keep_dict_defaults(*args, **kw)

def scale_axis(figure=plt, xfac=0.08, yfac=0.08):
    """
    Adjust the axis.

    The size of the axis is first changed to plt.axis('tight') and then
    scaled by (1 + xfac) horizontally and (1 + yfac) vertically.
    """
    (xmin, xmax, ymin, ymax) = figure.axis('tight')
    if figure == plt:
        figure.xlim(xmin - xfac * (xmax - xmin), xmax + xfac * (xmax - xmin))
        figure.ylim(ymin - yfac * (ymax - ymin), ymax + yfac * (ymax - ymin))
    else:
        figure.set_xlim(xmin - xfac * (xmax - xmin), xmax + xfac * (xmax - xmin))
        figure.set_ylim(ymin - yfac * (ymax - ymin), ymax + yfac * (ymax - ymin))

class Equation(object):

    def __init__(self, string, global_index, local_index, tearing, expression=None):
        self.string = string
        self.global_index = global_index
        self.local_index = local_index
        self.expression = expression
        self.tearing = tearing
        self.global_blt_index = None
        self.local_blt_index = None
        self.dig_vertex = None
        self.visited = False

    def __repr__(self):
        return self.string

    def __str__(self):
        return self.string

class NonBool(object):

    """
    Class used to indicate non-existing bool value.
    """

    def __init__(self):
        pass

    def __nonzero__(self):
        raise RuntimeError("BUG: Undefined Boolean value")

class Variable(object):

    def __init__(self, name, global_index, local_index, is_der, tearing, mvar=None, mx_var=None):
        self.name = name
        self.global_index = global_index
        self.local_index = local_index
        self.is_der = is_der
        self.mvar = mvar
        self.mx_var = mx_var
        self.tearing = tearing
        self.global_blt_index = None
        self.local_blt_index = None
        self.dig_vertex = None
        self.visited = False
        self.mx_ind = None
        self.sx_var = None

    def __repr__(self):
        return self.name

    def __str__(self):
        return self.name

class Edge(object):

    def __init__(self, equation, variable):
        self.eq = equation
        self.var = variable
        self.linear = True

class DigraphVertex(object):

    def __init__(self, index, equation, variable):
        self.index = index
        self.equation = equation
        self.variable = variable
        equation.dig_vertex = self
        variable.dig_vertex = self
        self.number = None
        self.lowlink = None

def find_deps(expr, mx_vars, deps=None):
    """
    Recursively finds which mx_vars expr depends on.
    """
    if deps is None:
        deps = len(mx_vars) * [False]
    for i in xrange(expr.getNdeps()):
        dep = expr.getDep(i)
        deps = map(any, zip(deps, [casadi.isEqual(dep, var) for var in mx_vars]))
        deps = find_deps(dep, mx_vars, deps)
    return deps

class Component(object):

    def __init__(self, vertices, causalization_options, edges):
        # Define data structures
        self.options = causalization_options
        self.vertices = vertices
        self.n = len(vertices) # Block size
        self.variables = variables = []
        self.equations = equations = []
        self.mvars = mvars = []
        self.mx_vars = mx_vars = []
        self.eq_expr = eq_expr = []
        if self.options['closed_form']:
            self.sx_vars = sx_vars = []
        
        # Find algebraic and differential variables in component
        for vertex in vertices:
            variables.append(vertex.variable)
            vertex.variable.component = self
            mvars.append(vertex.variable.mvar)
            mx_vars.append(vertex.variable.mx_var)
            equations.append(vertex.equation)
            vertex.equation.component = self
            eq_expr.append(vertex.equation.expression)
            if self.options['closed_form']:
                vertex.variable.sx_var = casadi.SX.sym(vertex.variable.name)
                sx_vars.append(vertex.variable.sx_var)

        # Check equation properties
        self.torn = self._is_torn()
        self.solvable = self._is_solvable()
        self.linear = self._is_linear(edges)
        self.sparsity_preserving = NonBool()

    def _is_torn(self):
        """
        Find tearing variables and residuals of block, and check if there are any.
        """
        if self.options['tearing']:
            self.block_tear_vars = []
            self.block_tear_res = []
            self.block_causal_vars = []
            self.block_causal_equations = []
            for var in self.variables:
                if var.tearing:
                    self.block_tear_vars.append(var)
                else:
                    self.block_causal_vars.append(var)
            for eq in self.equations:
                if eq.tearing:
                    self.block_tear_res.append(eq)
                else:
                    self.block_causal_equations.append(eq)
            if len(self.block_tear_vars) != len(self.block_tear_res):
                self.debug_tearing()
                raise RuntimeError("Number of tearing variables does not match number of residuals for block. " +
                                   "See above printouts for block variables and equations.")
            if 0 < len(self.block_tear_vars) < self.n:
                return True
            else:
                return False
        else:
            return False

    def _is_solvable(self):
        """
        Check solvability.
        """
        # Torn blocks are always solvable
        if self.torn:
            return True

        # Check if scalar
        if not self.options['solve_blocks'] and self.n > 1:
            return False

        # Blocks containing derivatives or ineliminable variables are not solvable
        for var in self.variables:
            if var.is_der or var.name in self.options['ineliminable']:
                return False

        return True

    def _is_linear(self, edges):
        """
        Check if unknowns can be solved for linearly in component.

        Solvability in this method is considered to be equivalent to linear dependence of
        all unknowns.
        """
        # Check if block is linear
        res_f = casadi.MXFunction(self.mx_vars, self.eq_expr)
        res_f.setOption("name", "block_residual_for_solvability")
        res_f.init()
        is_linear = True
        for i in xrange(self.n):
            for j in xrange(self.n):
                # Check if jac[i, j] depends on block unknowns
                if casadi.dependsOn(res_f.jac(i, j), self.mx_vars):
                    is_linear = False
                    found_edges = 0
                    for edge in edges:
                        if (casadi.isEqual(self.eq_expr[j], edge.eq.expression) and
                            casadi.isEqual(self.mx_vars[i], edge.var.mx_var)):
                            edge.linear = False
                            found_edges += 1
                    if found_edges != 1:
                        dh()
        if not self.options['solve_torn_linear_blocks'] and self.torn:
            return False
        return is_linear

    def debug_tearing(self):
        """
        Print block equations and variables and choice of tearing variables and residuals.
        """
        print("Chosen causal variables: \n")
        for var in self.block_causal_vars:
            print("\t%s" % var.name)
        print("\nChosen tearing variables: \n")
        for var in self.block_tear_vars:
            print("\t%s" % var.name)
        print("\nChosen causal equations (ID: expression): \n")
        for eq in self.block_causal_equations:
            print("\t%d: %s" % (eq.global_index, eq.string))
        print("\nChosen tearing residuals: \n")
        for eq in self.block_tear_res:
            print("\t%d: %s" % (eq.global_index, eq.string))

    def create_lin_eq(self, known_vars, solved_vars, tear_vars):
        """
        Create linear equation system for block.

        Defines A_fcn and b_fcn as data attributes.
        """
        if not self.solvable:
            raise RuntimeError("Can only create linear equation system for solvable blocks.")
        res = casadi.vertcat(self.eq_expr)
        all_vars = self.mx_vars + known_vars + solved_vars
        res_f = casadi.MXFunction(all_vars , [res])
        res_f.setOption("name", "block_residual_for_creating_linear_eq")
        res_f.init()

        # Create coefficient function
        A = []
        for i in xrange(self.n):
            jac_f = res_f.jacobian(i)
            jac_f.setOption("name", "block_jacobian")
            jac_f.init()
            A.append(jac_f.call(all_vars, self.options['inline'])[0])
        self.A_fcn = casadi.MXFunction(all_vars, [casadi.horzcat(A)])
        self.A_fcn.setOption("name", "A")
        self.A_fcn.init()
        if self.options['closed_form']:
            self.A_fcn = casadi.SXFunction(self.A_fcn)
            self.A_fcn.init()

        # Create right-hand side function
        rhs = casadi.mul(self.A_fcn.call(all_vars, self.options['inline'])[0], casadi.vertcat(self.mx_vars)) - res
        self.b_fcn = casadi.MXFunction(all_vars + tear_vars, [rhs])
        self.b_fcn.setOption("name", "b")
        self.b_fcn.init()
        if self.options['closed_form']:
            self.b_fcn = casadi.SXFunction(self.b_fcn)
            self.b_fcn.init()

        # TODO: Remove this
        self.A_sym = A
        self.b_sym = rhs

    def create_torn_lin_eq(self, known_vars, solved_vars, global_index):
        """
        Create linear equation system for block using tearing and Schur complement.

        |A B| |x|   |a|
        |   | | | = | |
        |C D| |y|   |b|,

        where x are causalized block variables (since A is lower triangular) and y are tearing variables.

        Defines fcn["alpha"], for all alpha in {A, B, C, D, a, b} as data attributes.
        """
        if not self.solvable or not self.linear or not self.torn:
            raise RuntimeError("Can only create torn linear equation system for solvable, linear, torn blocks.")
        res = casadi.vertcat(self.eq_expr)
        all_vars = self.mx_vars + known_vars + solved_vars

        # Sort causal and tearing equations
        tearing_variables = self.block_tear_vars
        tearing_equations = self.block_tear_res
        causal_variables = [var for var in self.variables if not var in tearing_variables]
        causal_equations = [eq for eq in self.equations if not eq in tearing_equations]
        tearing_index = self.n - len(tearing_variables)
        for var in tearing_variables:
            var.global_blt_index = global_index + tearing_index
            var.local_blt_index = tearing_index
            tearing_index += 1
        tearing_index = self.n - len(tearing_equations)
        for eq in tearing_equations:
            eq.global_blt_index = global_index + tearing_index
            eq.local_blt_index = tearing_index
            tearing_index += 1

        # Update component indices
        i = 0
        for (eq, var) in itertools.izip(causal_equations, causal_variables):
            eq.local_index = i
            var.local_index = i
            eq.local_blt_index = None
            var.local_blt_index = None
            eq.global_blt_index = None
            var.global_blt_index = None
            i += 1

        # Create new bipartite graph for block
        causal_edges = create_edges(causal_equations, causal_variables)
        causal_graph = BipartiteGraph(causal_equations, causal_variables, causal_edges, EliminationOptions())

        # Compute components and verify scalarity
        causal_graph.maximum_match()
        causal_graph.scc(global_index)
        if causal_graph.n != len(causal_graph.components):
            raise RuntimeError("Causalized equations in block involving tearing variables " +
                               str(self.tear_vars) + " are not causal. " +
                               "Additional tearing variables needed.")

        # Compose component equations and variables
        causal_eq_expr = casadi.vertcat([comp.eq_expr[0] for comp in causal_graph.components])
        tearing_eq_expr = casadi.vertcat([tearing_eq.expression for tearing_eq in tearing_equations])
        self.causalized_vars = causalized_vars = [comp.variables[0] for comp in causal_graph.components]
        causal_mx_vars = [comp.mx_vars[0] for comp in causal_graph.components]
        tearing_mx_vars = [var.mx_var for var in tearing_variables]

        # Compose component block matrices and right-hand sides
        eq_sys = {}
        eq_sys["A"] = casadi.horzcat([casadi.jacobian(causal_eq_expr, var) for var in causal_mx_vars])
        eq_sys["B"] = casadi.horzcat([casadi.jacobian(causal_eq_expr, var) for var in tearing_mx_vars])
        eq_sys["C"] = casadi.horzcat([casadi.jacobian(tearing_eq_expr, var) for var in causal_mx_vars])
        eq_sys["D"] = casadi.horzcat([casadi.jacobian(tearing_eq_expr, var) for var in tearing_mx_vars])
        eq_sys["a"] = (casadi.mul(eq_sys["A"], casadi.vertcat(causal_mx_vars)) +
                       casadi.mul(eq_sys["B"], casadi.vertcat(tearing_mx_vars)) - causal_eq_expr)
        eq_sys["b"] = (casadi.mul(eq_sys["C"], casadi.vertcat(causal_mx_vars)) +
                       casadi.mul(eq_sys["D"], casadi.vertcat(tearing_mx_vars)) - tearing_eq_expr)

        # Create functions for evaluating equation system components
        self.fcn = {}
        for alpha in ["A", "B", "C", "D", "a", "b"]:
            fcn = casadi.MXFunction(all_vars, [eq_sys[alpha]])
            fcn.setOption("name", alpha)
            fcn.init()
            if self.options['closed_form']:
                fcn = casadi.SXFunction(fcn)
                fcn.init()
            self.fcn[alpha] = fcn

    def tear_nonlin_eq(self, known_vars, solved_vars, matches, global_index):
        """
        Tear nonlinear equation block.

        Original equations:
        
        L(x) + F(y) = 0
        G(x, y) = 0,

        where L has a lower triangular structure with constant diagonal

        Torn equations:

        G(-\F(y), y) = 0
        x := - L^{-1}F(y) =: H(y)

        where x are causalized block variables (since A is lower triangular) and y are tearing variables.

        Defines fcn_F as data attribute for post-computation of solved variables.
        """
        if not self.block_tear_vars:
            raise RuntimeError("Torn block has no tearing variables (bug?)")
        res = casadi.vertcat(self.eq_expr)
        all_vars = self.mx_vars + known_vars + solved_vars

        # Sort causal and tearing equations
        tearing_variables = self.block_tear_vars
        tearing_equations = self.block_tear_res
        causal_variables = [var for var in self.variables if not var in tearing_variables]
        causal_equations = [eq for eq in self.equations if not eq in tearing_equations]
        tearing_index = self.n - len(tearing_variables)
        for var in tearing_variables:
            var.global_blt_index = global_index + tearing_index
            var.local_blt_index = tearing_index
            tearing_index += 1
        tearing_index = self.n - len(tearing_equations)
        for eq in tearing_equations:
            eq.global_blt_index = global_index + tearing_index
            eq.local_blt_index = tearing_index
            tearing_index += 1

        # Update component indices
        i = 0
        for (eq, var) in itertools.izip(causal_equations, causal_variables):
            eq.local_index = i
            var.local_index = i
            eq.local_blt_index = None
            var.local_blt_index = None
            eq.global_blt_index = None
            var.global_blt_index = None
            i += 1

        # Create new bipartite graph for block
        causal_edges = create_edges(causal_equations, causal_variables)
        causal_graph = BipartiteGraph(causal_equations, causal_variables, causal_edges, EliminationOptions())

        # Compute components and verify scalarity
        try:
            causal_graph.maximum_match()
        except RuntimeError:
            self.debug_tearing()
            raise RuntimeError("Causalized equations in torn block are structurally singular. " +
                               "See above printouts for block variables and equations.")
        causal_graph.scc(global_index)
        if causal_graph.n != len(causal_graph.components):
            for component in causal_graph.components:
                component.sparsity_preserving = True
            self.debug_tearing()
            if self.options['draw_blt']:
                causal_graph.draw_blt("Failed torn block", True)
            raise RuntimeError("Causalized equations in torn block are not lower triangular. " +
                               "See above printouts for block variables and equations.")
        for co in causal_graph.components:
            if not co.linear or (not co.solvable and not co.variables[0].is_der):
                for component in causal_graph.components:
                    component.sparsity_preserving = True
                self.debug_tearing()
                if self.options['draw_blt']:
                    causal_graph.draw_blt("Failed torn block", True)
                raise RuntimeError("Causalized equations in torn block are not solvable and linear. " +
                                   "See above printouts for block variables and equations.")

        return causal_graph

class BipartiteGraph(object):

    def __init__(self, equations, variables, edges, causalization_options):
        self.equations = equations
        self.variables = variables
        self.options = causalization_options
        self.n = len(equations)
        if self.n != len(variables):
            raise ValueError("Equation system is structurally singular.")
        self.edges = edges
        self.matches = None
        self.components = []

        # Create incidence matrix
        row = []
        col = []
        for edge in edges:
            row.append(edge.eq.local_index)
            col.append(edge.var.local_index)
        self.incidences = scipy.sparse.coo_matrix((np.ones(len(row)), (row, col)), shape=(self.n, self.n))

    def _reset(self):
        """
        Resets visited attribute for equations and variables.
        """
        for eq in self.equations:
            eq.visited = False
        for vari in self.variables:
            vari.visited = False

    def draw(self, idx=1):
        # Draw bipartite graph
        plt.close(idx)
        plt.figure(idx)
        plt.hold(True)
        for equation in self.equations:
            plt.plot(0, -equation.local_index, 'go', ms=12)
        for variable in self.variables:
            plt.plot(1, -variable.local_index, 'ro', ms=12)
        for edge in self.edges:
            if self.matches is None:
                style = 'b'
            elif (edge.eq, edge.var) in self.matches: # or (edge.var, edge.eq) in self.matches:
                style = 'b'
            else:
                style = 'b--'
            plt.plot([0, 1], [-equation.global_index, -variable.global_index], style, lw=1.5)
        eq_offset = np.array([-0.7, -0.24])
        var_offset = np.array([0.07, -0.24])
        for equation in self.equations:
            plt.annotate(equation.string, np.array([0, -equation.global_index]) + eq_offset, color='k')
        for variable in self.variables:
            plt.annotate(variable.name, np.array([1, -variable.global_index]) + var_offset, color='k')
        scale_axis(xfac=0.88)

        # Draw corresponding incidence matrix
        idx += 1
        plt.close(idx)
        plt.figure(idx)
        plt.tick_params(
            axis='both',       # changes apply to both axes
            which='both',      # both major and minor ticks are affected
            bottom='off',      # ticks along the bottom edge are off
            top='off',         # ticks along the top edge are off
            left='off',
            right='off',
            labelbottom='off',
            labelleft='off')
        for edge in self.edges:
            if self.matches:
                if (edge.eq, edge.var) in self.matches:
                    style = 'ro'
                    ms = 10
                else:
                    style = 'bo'
                    ms = 8
            else:
                style = 'bo'
                ms = 8
            plt.plot(vari.global_index, -eq.global_index, style, ms=ms)
        eq_offset = np.array([-0.2, -0.17])
        var_offset = np.array([-0.21, 0.22])
        for equation in self.equations:
            plt.annotate(equation.string, np.array([0, -equation.global_index]) + eq_offset, color='k',
                         horizontalalignment='right')
        for variable in self.variables:
            plt.annotate(variable.name, np.array([variable.global_index, 0]) + var_offset, color='k',
                         rotation='vertical', verticalalignment='bottom')
        scale_axis(xfac=0.65, yfac=0.4)

    def draw_blt(self, idx=99, strings=False):
        # Draw BLT incidence matrix
        if self.components:
            plt.close(idx)
            fig = plt.figure(idx, frameon=False)
            if strings:
                plt.tick_params(
                    axis='both',       # changes apply to both axes
                    which='both',        # ticks along the top edge are off
                    left='off',
                    labelleft='off')
            else:
                fig.gca().set_frame_on(False)
                plt.tick_params(
                    axis='both',       # changes apply to both axes
                    which='both',      # both major and minor ticks are affected
                    bottom='off',      # ticks along the bottom edge are off
                    top='off',         # ticks along the top edge are off
                    left='off',
                    right='off',
                    labelbottom='off',
                    labelleft='off')
            i = 0
            torn_linear_clr = 'SpringGreen'
            linear_clr = 'ForestGreen'
            dense_clr = 'Gold'
            nonlinear_clr = 'Red'
            ineliminable_clr = 'DarkOrange'
            derivative_clr = 'Blue'
            unknown_clr = 'Black'
            for component in self.components:
                i_new = i + component.n - 1
                offset = 0.5
                i -= offset
                i_new += offset
                lw = 3./(self.n**0.17)
                # Colors: https://css-tricks.com/snippets/css/named-colors-and-hex-equivalents/
                if component.solvable:
                    if component.linear:
                        if component.sparsity_preserving:
                            if component.torn:
                                color = torn_linear_clr
                                if hasattr(component, 'fcn'):
                                    ls = '--'
                                    n_torn = len(component.block_tear_vars)
                                    plt.plot([i, i_new], [-i_new + n_torn, -i_new + n_torn], color, ls=ls, lw=lw)
                                    plt.plot([i_new - n_torn, i_new - n_torn], [-i, -i_new], color, ls=ls, lw=lw)
                            else:
                                color = linear_clr
                        else:
                            color = dense_clr
                    else:
                        if component.torn:
                            color = nonlinear_clr
                            for (j, causal_co) in enumerate(component.causal_graph.components):
                                if causal_co.variables[0].name in self.options['ineliminable']:
                                    causal_color = ineliminable_clr
                                elif causal_co.variables[0].is_der:
                                    causal_color = derivative_clr
                                elif causal_co.sparsity_preserving:
                                    causal_color = linear_clr
                                else:
                                    causal_color = dense_clr
                                plt.plot([i+j, i+j+1], [-i-j, -i-j], causal_color, lw=lw)
                                plt.plot([i+j, i+j], [-i-j, -i-j-1], causal_color, lw=lw)
                                plt.plot([i+j, i+j+1], [-i-j-1, -i-j-1], causal_color, lw=lw)
                                plt.plot([i+j+1, i+j+1], [-i-j, -i-j-1], causal_color, lw=lw)
                            if hasattr(component, 'tear_mx_vars'):
                                ls = '--'
                                n_torn = len(component.block_tear_vars)
                                plt.plot([i, i_new], [-i_new + n_torn, -i_new + n_torn], color, ls=ls, lw=0.5*lw)
                                plt.plot([i_new - n_torn, i_new - n_torn], [-i, -i_new], color, ls=ls, lw=0.5*lw)
                            else:
                                RuntimeError("BUG?")
                        else:
                            color = nonlinear_clr
                elif component.n == 1 and component.variables[0].name in self.options['ineliminable']:
                    color = ineliminable_clr
                else:
                    color = derivative_clr
                plt.plot([i, i_new], [-i, -i], color, lw=lw)
                plt.plot([i, i], [-i, -i_new], color, lw=lw)
                plt.plot([i, i_new], [-i_new, -i_new], color, lw=lw)
                plt.plot([i_new, i_new], [-i, -i_new], color, lw=lw)
                i = i_new - offset + 1
            for edge in self.edges:
                ms = 100.0 / self.n ** 0.73
                if edge.var.is_der:
                    marker = 'o'
                    mew = 1
                    #~ marker = 'd'
                    #~ mew = 2
                else:
                    marker = 'o'
                    mew = 1
                if edge.linear == "unknown":
                    markerfacecolor = unknown_clr
                    markeredgecolor = unknown_clr
                elif edge.linear == True:
                    markerfacecolor = linear_clr
                    markeredgecolor = linear_clr
                else:
                    markerfacecolor = nonlinear_clr
                    markeredgecolor = nonlinear_clr
                plt.plot(edge.var.global_blt_index, -edge.eq.global_blt_index, mew=mew,
                         marker=marker, markerfacecolor=markerfacecolor, markeredgecolor=markeredgecolor, ms=ms)
            eq_offset = np.array([-0.2, -0.17])
            var_offset = np.array([-0.21, 0.22])
            if strings:
                for equation in self.equations:
                    plt.annotate(equation.string, np.array([0, -equation.global_blt_index]) + eq_offset, color='k',
                                 horizontalalignment='right')
                for variable in self.variables:
                    plt.annotate(variable.name, np.array([variable.global_blt_index, 0]) + var_offset, color='k',
                                 rotation='vertical', verticalalignment='bottom')
            scale_axis()
            plt.show()

    def maximum_match(self):
        """
        Computes a new perfect matching.
        """
        self.matches = [] # Step 0
        i = 0
        while True:
            i += 1
            paths = self._find_shortest_aug_paths(i) # Step 1
            if paths == []:
                return
            for path in paths:
                for edge in path:
                    try:
                        idx = self.matches.index(edge)
                    except ValueError:
                        self.matches.append(edge)
                    else:
                        del self.matches[idx]

    def _remove_duplicates(self, l):
        """
        Remove duplicate elements in iterable.
        """
        seen = set()
        seen_add = seen.add
        return [x for x in l if not (x in seen or seen_add(x))]

    def _find_shortest_aug_paths(self, idx=2):
        """
        Step 1 of Hopcroft-Karp.
        
        Finds a maximal vertex-disjoint set of shortest augmenting paths
        relative to self.matches.

        Equations are boys and variables are girls.
        """
        options = self.options
        
        # Find unmatched equations and variables
        matched_eqs = []
        matched_varis = []
        for (eq, vari) in self.matches:
            matched_eqs.append(eq)
            matched_varis.append(vari)
        unmatched_eqs = [eq for eq in self.equations if eq not in matched_eqs]
        unmatched_varis = [vari for vari in self.variables if vari not in matched_varis]
        if unmatched_eqs == []:
            return []

        # Construct layers
        L = [unmatched_eqs]
        L_union = copy.copy(L[0])
        E = []
        i = 0
        while set(L[-1]) & set(unmatched_varis) == set():
            if i % 2 == 0:
                E_i = [(edge.var, edge.eq) for edge in self.edges if ((edge.eq in L[i]) and (edge.var not in L_union) and ((edge.eq, edge.var) not in self.matches))]
                if i == 0 and len(E_i) == 0:
                    raise RuntimeError("The following equations contain no variables: %s" % L[0])
                E.append(E_i)
                L_i = self._remove_duplicates([vari for (vari, eq) in E_i])
            else:
                E_i = [(edge.eq, edge.var) for edge in self.edges if ((edge.var in L[i]) and (edge.eq not in L_union) and ((edge.eq, edge.var) in self.matches))]
                E.append(E_i)
                L_i = self._remove_duplicates([eq for (eq, vari) in E_i])
            if len(E_i) == 0:
                raise RuntimeError("Unable to find perfect matching")
            i += 1
            L_union += L_i
            L_union = self._remove_duplicates(L_union)
            L.append(L_i)
        i_star = len(L) - 1 # = len(E)

        # Only consider unmatched variables in final layer
        E[i_star-1] = [(vari, eq) for (vari, eq) in E[i_star-1] if vari in unmatched_varis]
        L[i_star] = [vari for vari in L[i_star] if vari in unmatched_varis]

        # Add source and sink
        source = Equation('source', -1, -1, False, False)
        sink = Variable('sink', -1, -1, False, False)

        # Draw layers
        if options['plots']:
            plt.close(idx)
            plt.figure(idx)

            # Plot vertices
            for i in xrange(i_star + 1):
                if i % 2 == 0:
                    for eq in L[i]:
                        plt.plot(i, -eq.local_index, 'go', ms=12)
                else:
                    for vari in L[i]:
                        plt.plot(i, -vari.local_index, 'ro', ms=12)

            # Plot source
            plt.plot(-1, -(self.n - 1) / 2., 'ko', ms=12)
            for eq in L[0]:
                plt.plot([-1, 0], [-(self.n - 1) / 2., -eq.local_index], 'k', ms=12)

            # Plot sink
            plt.plot(i_star + 1, -(self.n - 1) / 2., 'ko', ms=12)
            for vari in L[i_star]:
                plt.plot([i_star + 1, i_star], [-(self.n - 1) / 2., -vari.local_index], 'k', ms=12)

            # Plot edges
            for i in xrange(i_star):
                for (u, v) in E[i]:
                    if i % 2 == 0:
                        color = 'r'
                    else:
                        color = 'g'
                    plt.plot([i, i+1], [-v.local_index, -u.local_index], color=color, lw=1.5)
            scale_axis()
            plt.show()

        # Compute vertex successors
        successors = {}
        for i in xrange(i_star):
            for v in L[i+1]:
                successors[v] = []
            for (u, v) in E[i]:
                successors[u].append(v)
        successors[source] = L[i_star]
        successors[sink] = []
        for eq in L[0]:
            successors[eq] = [sink]

        # Find maximal set of paths from source to sink
        stack = []
        stack.append(source)
        paths = []
        self._reset()
        while len(stack) > 0:
            while len(successors[stack[-1]]) > 0:
                first = successors[stack[-1]].pop()
                if not first.visited:
                    stack.append(first)
                    if stack[-1] != sink:
                        stack[-1].visited = True
                    else:
                        path = []
                        del stack[0] # Remove source
                        del stack[-1] # Remove sink
                        for i in xrange(len(stack)-1):
                            if i % 2 == 0:
                                path.append((stack[i+1], stack[i]))
                            else:
                                path.append((stack[i], stack[i+1]))
                        paths.append(path)
                        stack = [source]
            stack.pop()
        return paths

    def inherit_matching(self, matching):
        """
        Inherits the applicable subset of the provided matchings.
        """
        block_names = [var.name for var in self.variables]
        self.matches = [match for match in matching if match[1].name in block_names]

    def scc(self, global_index=0):
        """
        Computes strongly connected components using Tarjan's algorithm.
        """
        vertices = [DigraphVertex(i, eq, vari) for (i, (eq, vari)) in enumerate(self.matches)]

        # Create edges (without self-loops)
        dig_edgs = []
        for edge in self.edges:
            if (edge.eq, edge.var) not in self.matches:
            #~ if (edge.var, edge.eq) not in self.matches:
                dig_edgs.append((edge.eq.dig_vertex, edge.var.dig_vertex))
        self.dig_edgs = dig_edgs

        # Strong connect
        self.i = 0
        self.stack = []
        self.components = []
        for v in vertices:
            if v.number is None:
                self._strong_connect(v)

        # Create new equation and variable indices
        i = 0
        for component in self.components:
            for vertex in component.vertices:
                vertex.equation.local_blt_index = i
                vertex.variable.local_blt_index = i
                vertex.equation.global_blt_index = global_index + i
                vertex.variable.global_blt_index = global_index + i
                i += 1

    def _strong_connect(self, v):
        """
        Finds a strong connection for v.
        """
        self.i += 1
        v.number = self.i
        v.lowlink = self.i
        self.stack.append(v)

        for (v1, w) in self.dig_edgs:
            if v1 == v:
                if w.number is None: # (v, w) is a tree arc
                    self._strong_connect(w)
                    v.lowlink = min(v.lowlink, w.lowlink)
                elif w.number < v.number: # (v, w) is a frond or cross-link
                    if w in self.stack:
                        v.lowlink = min(v.lowlink, w.number)

        if v.lowlink == v.number: # v is the root of a component
            # Start new strongly connected component
            vertices = []
            while self.stack and self.stack[-1].number >= v.number:
                vertices.append(self.stack.pop())
            self.components.append(Component(vertices, self.options, self.edges))

def create_edges(equations, variables):
        """
        Create edges between Equations and Variables.
        """
        # This can probably be made more efficient by analyzing Jacobian sparsity of a SISO function with latest CasADi
        edges = []
        mx_vars = [var.mx_var for var in variables]
        for equation in equations:
            expr = equation.expression
            deps_incidence = np.array(find_deps(expr, mx_vars))
            deps_equal = np.array(map(lambda mx_var: casadi.isEqual(expr, mx_var), mx_vars))
            deps = deps_incidence + deps_equal
            for (i, var) in enumerate(variables):
                if deps[i]:
                    edges.append(Edge(equation, var))
        return edges

class BLTModel(object):
    
    """
    Emulates CasADi Interface's Model class using BLT.

    Parameters::

        model --
            CasADi Interface Model.

        elimination_options --
            EliminationOptions object.
    """

    def __init__(self, model, elimination_options=EliminationOptions()):
        """
        Creates a BLTModel from a Model.
        """
        self.original_options = elimination_options
        self.options = copy.deepcopy(self.original_options)

        # Identify tearing variables
        if self.options['tearing']:
            self.tear_vars = [var.getName() for var in model.getVariables(model.REAL_ALGEBRAIC)
                              if not var.isAlias() and var.getTearing()]
        else:
            self.tear_vars = []

        # Check validity of options
        if self.options['closed_form'] and not self.options['inline']:
            raise ValueError("inline has to be true when closed_form is")

        # Get to work
        self._model = model
        self._process_ineliminables()
        self._create_bipgraph()
        self._setup_dependencies()
        self._compute_blt()
        self._create_residuals()
        self._print_statistics()

    def __getattr__(self, name):
        """
        Emulate Model by default (particularly useful for enums).
        """
        return self._model.__getattribute__(name)

    def _process_ineliminables(self):
        # Check that ineliminables exist and replace with aliases.
        for (i, name) in enumerate(self.options['ineliminable']):
            var = self._model.getVariable(name)
            if var is None:
                raise ValueError('Ineliminable variable %s does not exist.' % name)
            self.options['ineliminable'][i] = var.getModelVariable().getName()

    def _create_bipgraph(self):
        # Initialize structures
        self._equations = equations = []
        self._variables = variables = []
        self._mx_var_struct = mx_var_struct = OrderedDict()
        
        # Get model variable vectors
        model = self._model
        var_kinds = {'dx': model.DERIVATIVE,
                     'x': model.DIFFERENTIATED,
                     'u': model.REAL_INPUT,
                     'w': model.REAL_ALGEBRAIC}
        mvar_vectors = {'dx': np.array([var for var in
                                        model.getVariables(var_kinds['dx'])
                                        if not var.isAlias()]),
                        'x': np.array([var for var in
                                       model.getVariables(var_kinds['x'])
                                       if not var.isAlias()]),
                        'u': np.array([var for var in
                                       model.getVariables(var_kinds['u'])
                                       if not var.isAlias()]),
                        'w': np.array([var for var in
                                       model.getVariables(var_kinds['w'])
                                       if not var.isAlias()])}

        # Count variables
        n_var = {'dx': len(mvar_vectors["dx"]),
                 'x': len(mvar_vectors["x"]),
                 'u': len(mvar_vectors["u"]),
                 'w': len(mvar_vectors["w"])}

        # Sort parameters
        par_kinds = [model.BOOLEAN_CONSTANT,
                     model.BOOLEAN_PARAMETER_DEPENDENT,
                     model.BOOLEAN_PARAMETER_INDEPENDENT,
                     model.INTEGER_CONSTANT,
                     model.INTEGER_PARAMETER_DEPENDENT,
                     model.INTEGER_PARAMETER_INDEPENDENT,
                     model.REAL_CONSTANT,
                     model.REAL_PARAMETER_INDEPENDENT,
                     model.REAL_PARAMETER_DEPENDENT]
        pars = reduce(list.__add__, [list(model.getVariables(par_kind)) for
                                     par_kind in par_kinds])

        # Sort free/fixed parameters
        fixed_pars = filter(lambda par: not model.get_attr(par, "free"), pars)
        free_pars = filter(lambda par: model.get_attr(par, "free"), pars)
        mvar_vectors['p_fixed'] = fixed_pars
        n_var['p_fixed'] = len(mvar_vectors['p_fixed'])
        mvar_vectors['p_opt'] = free_pars
        n_var['p_opt'] = len(mvar_vectors['p_opt'])

        # Get parameter values
        model.calculateValuesForDependentParameters()
        par_vars = [par.getVar() for par in mvar_vectors['p_fixed']]
        par_vals = [model.get_attr(par, "_value") for par in mvar_vectors['p_fixed']]

        # Get optimization and model expressions
        named_initial = model.getInitialResidual()
        named_dae = model.getDaeResidual()
        named_dae_equations = model.getDaeEquations()

        # Eliminate parameters
        [named_initial, named_dae] = casadi.substitute([named_initial, named_dae], par_vars, par_vals)

        # Create named symbolic variable structure
        mx_var_struct["time"] = [model.getTimeVariable()]
        for vk in ["dx", "x", "u", "w", "p_opt"]:
            mx_var_struct[vk] = [mvar.getVar() for mvar in mvar_vectors[vk]]

        # Create variables
        i = 0
        for vk in ["dx", "w"]:
            for (mvar, mx_var) in itertools.izip(mvar_vectors[vk], mx_var_struct[vk]):
                if self.options['tearing'] and mvar.getTearing():
                    tearing = True
                else:
                    tearing = False
                variables.append(Variable(mvar.getName(), i, i, vk=="dx", tearing, mvar, mx_var))
                i += 1

        # Create equations
        i = 0
        for (named_res, named_eq) in itertools.izip(named_dae, named_dae_equations):
            if self.options['tearing'] and named_eq.getTearing():
                tearing = True
            else:
                tearing = False
            equations.append(Equation(named_eq.__str__(), i, i, tearing, named_res))
            i += 1

        # Create edges
        self._edges = create_edges(equations, variables)

        # Create graph
        self._graph = BipartiteGraph(equations, variables, self._edges, self.options)
        if self.options['plots']:
            self._graph.draw(11)

    def _setup_dependencies(self):
        """
        Setup structure for computing variable dependencies for preserving sparsity.
        """
        self._dependencies = dependencies = {}
        for vk in ['x', 'u', 'p_opt']:
            for var in self._mx_var_struct[vk]:
                dependencies[var.getName()] = [var.getName()]

        for var_name in self.options['ineliminable']:
            dependencies[var_name] = [var_name]

        for var in self.tear_vars:
            self._dependencies[var] = [var]

    def _compute_blt(self):
        # Match equations and variables
        self._graph.maximum_match()

        # Compute strongly connected components
        self._graph.scc()
        if self.options['plots']:
            self._graph.draw(13)
            self._graph.draw_blt(98, True)

        # Identify linear edges
        cumidx = 0
        for component in self._graph.components:
            component.cumidx = cumidx
            cumidx += component.n
        for edge in self._edges:
            eq = edge.eq
            var = edge.var
            #~ if eq.global_blt_index > eq.component.cumidx+eq.component.n or var.global_blt_index < var.component.cumidx:
            if eq.global_blt_index >= var.component.cumidx+var.component.n:
                edge.linear = "unknown"

    def _create_residuals(self):
        # Create list of named MX variables
        mx_var_struct = self._mx_var_struct
        mx_vars = list(itertools.chain.from_iterable(mx_var_struct.values()))
        time = mx_var_struct['time']
        dx = mx_var_struct['dx']
        x = mx_var_struct['x']
        u = mx_var_struct['u']
        w = mx_var_struct['w']
        p = mx_var_struct['p_opt']
        self._known_vars = known_vars = time + x + u + p
        options = self.options
        if options['closed_form']:
            sx_time = [casadi.SX.sym("time")]
            sx_x = [casadi.SX.sym(name) for name in [var.__repr__()[3:-1] for var in x]]
            sx_u = [casadi.SX.sym(name) for name in [var.__repr__()[3:-1] for var in u]]
            self._sx_known_vars = sx_known_vars = sx_time + sx_x + sx_u
            self._sx_solved_vars = sx_solved_vars = []

        # Create expression
        residuals = []
        self._solved_vars = solved_vars = []
        self._explicit_solved_vars = explicit_solved_vars = []
        self._explicit_unsolved_vars = explicit_unsolved_vars = []
        if options['closed_form']:
            self._explicit_unsolved_sx_vars = explicit_unsolved_sx_vars = []
        self._solved_expr = solved_expr = []
        self._explicit_solved_algebraics = explicit_solved_algebraics = []
        self._explicit_unsolved_algebraics = explicit_unsolved_algebraics = []
        alg_sols = []
        n_solvable = 0
        n_unsolvable = 0
        if options['inline']:
            inlined_solutions = []
        global_index = 0
        for co in self._graph.components:
            if co.solvable and co.linear and self._sparsity_preserving(co):
                n_solvable += co.n
                if co.torn:
                    co.create_torn_lin_eq(known_vars, solved_vars, global_index)

                    # Compute equation system components
                    # Block variables need a (any) real value in order to find right-hand sides
                    eq_sys = {}
                    if options['closed_form']:
                        if options['inline_solved']:
                            inputs = co.n * [0.] + sx_known_vars + solved_expr
                        else:
                            inputs = co.n * [0.] + sx_known_vars + sx_solved_vars
                    else:
                        inputs = co.n * [0.] + known_vars + solved_expr
                    for alpha in ["A", "B", "C", "D", "a", "b"]:
                        eq_sys[alpha] = co.fcn[alpha].call(inputs, self.options['inline'])[0]

                    # Extract equation system components
                    A = eq_sys["A"]
                    B = eq_sys["B"]
                    C = eq_sys["C"]
                    D = eq_sys["D"]
                    a = eq_sys["a"]
                    b = eq_sys["b"]

                    # Solve component equations using Schur complement
                    I = np.eye(A.shape[0])
                    if options['closed_form']:
                        Ainv = casadi.solve(A, I) # TODO: Is it better to solve twice instead?
                    else:
                        Ainv = casadi.solve(A, I, options['linear_solver']) # TODO: Is it better to solve twice instead?
                    CAinv = casadi.mul(C, Ainv)
                    if options['closed_form']:
                        torn_sol = casadi.solve(D - casadi.mul(CAinv, B),
                                                b - casadi.mul(CAinv, a))
                    else:
                        torn_sol = casadi.solve(D - casadi.mul(CAinv, B),
                                                b - casadi.mul(CAinv, a), options['linear_solver'])
                    causal_sol = casadi.mul(Ainv, a - casadi.mul(B, torn_sol))
                    sol = casadi.vertcat([causal_sol, torn_sol])

                    # Store causal solution
                    for (i, var) in enumerate(co.causalized_vars + co.block_tear_vars):
                        if var.is_der:
                            if options['closed_form']:
                                residuals.append(var.sx_var - sol[i])
                            else:
                                residuals.append(var.mx_var - sol[i])
                        else:
                            explicit_solved_algebraics.append((len(solved_vars) + i, var))
                    mx_vars = [var.mx_var for var in co.causalized_vars + co.block_tear_vars]
                    solved_vars.extend(mx_vars)
                    explicit_solved_vars.extend(mx_vars)
                    if options['closed_form'] and not options['inline_solved']:
                        sx_solved_vars += [casadi.SX.sym(name) for name in [var.__repr__()[3:-1] for var in mx_vars]]
                    solved_expr.extend([sol[i] for i in range(sol.numel())])
                else:
                    co.create_lin_eq(known_vars, solved_vars, [])

                    # Compute A
                    if options['closed_form']:
                        if options['inline_solved']:
                            A_input = co.n * [np.nan] + sx_known_vars + solved_expr
                        else:
                            A_input = co.n * [np.nan] + sx_known_vars + sx_solved_vars
                    else:
                        A_input = co.n * [np.nan] + known_vars + solved_expr
                    A = co.A_fcn.call(A_input, self.options['inline'])[0]

                    # Compute b
                    # Block variables need a (any) real value in order to find b
                    if options['closed_form']:
                        if options['inline_solved']:
                            b_input = co.n * [0.] + sx_known_vars + solved_expr
                        else:
                            b_input = co.n * [0.] + sx_known_vars + sx_solved_vars
                    else:
                        b_input = co.n * [0.] + known_vars + solved_expr
                    b = co.b_fcn.call(b_input, self.options['inline'])[0]
                        
                    # Solve
                    if options['closed_form']:
                        sol = casadi.mul(casadi.inv(A), b)
                        casadi.simplify(sol)
                    else:
                        sol = casadi.solve(A, b, options['linear_solver'])

                    # Create residuals
                    for (i, var) in enumerate(co.variables):
                        if var.is_der or var.name in self.options['ineliminable']:
                            if options['closed_form']:
                                residuals.append(var.sx_var - sol[i])
                            else:
                                residuals.append(var.mx_var - sol[i])
                        else:
                            explicit_solved_algebraics.append((len(solved_vars) + i, var))

                    # Store solution
                    solved_vars.extend(co.mx_vars)
                    explicit_solved_vars.extend(co.mx_vars)
                    if options['closed_form'] and not options['inline_solved']:
                        sx_solved_vars += [casadi.SX.sym(name) for name in [var.__repr__()[3:-1] for var in co.mx_vars]]
                    solved_expr.extend([sol[i] for i in range(sol.numel())])
            else:
                if co.torn:
                    co.causal_graph = co.tear_nonlin_eq(known_vars, solved_vars, self._graph.matches, global_index)
                    tear_mx_vars = [var.mx_var for var in co.block_tear_vars]

                    for causal_co in co.causal_graph.components:
                        if causal_co.n > 1:
                            raise NotImplementedError('Causalized equations must be lower triangular')
                        # Eliminate causal variable
                        if (self._sparsity_preserving(causal_co) and
                            causal_co.variables[0].name not in self.options['ineliminable'] and
                            not causal_co.variables[0].is_der):
                            causal_co.create_lin_eq(known_vars, solved_vars, tear_mx_vars)
                            
                            # Compute A
                            if options['closed_form']:
                                if options['inline_solved']:
                                    A_input = causal_co.n * [np.nan] + sx_known_vars + solved_expr
                                else:
                                    A_input = causal_co.n * [np.nan] + sx_known_vars + sx_solved_vars
                            else:
                                A_input = causal_co.n * [np.nan] + known_vars + solved_expr
                            A = causal_co.A_fcn.call(A_input, self.options['inline'])[0]

                            # Compute b
                            # Block variables need a (any) real value in order to find b
                            if options['closed_form']:
                                if options['inline_solved']:
                                    something = [] # tear_sx_vars
                                    # TODO: something
                                    b_input = causal_co.n * [0.] + sx_known_vars + solved_expr + something
                                    raise NotImplementedError('Closed form is not supported for tearing')
                                else:
                                    something = [] # tear_sx_vars
                                    # TODO: something
                                    b_input = causal_co.n * [0.] + sx_known_vars + sx_solved_vars + something
                                    raise NotImplementedError('Closed form is not supported for tearing')
                            else:
                                b_input = causal_co.n * [0.] + known_vars + solved_expr + tear_mx_vars
                            b = causal_co.b_fcn.call(b_input, self.options['inline'])[0]
                                
                            # Solve
                            if options['closed_form']:
                                sol = casadi.mul(casadi.inv(A), b)
                                casadi.simplify(sol)
                            else:
                                sol = casadi.solve(A, b, options['linear_solver'])

                            # Create residuals
                            for (i, var) in enumerate(causal_co.variables):
                                if var.is_der:
                                    if options['closed_form']:
                                        residuals.append(var.sx_var - sol[i])
                                    else:
                                        residuals.append(var.mx_var - sol[i])
                                else:
                                    explicit_solved_algebraics.append((len(solved_vars) + i, var))

                            # Store solution
                            solved_vars.extend(causal_co.mx_vars)
                            explicit_solved_vars.extend(causal_co.mx_vars)
                            if options['closed_form'] and not options['inline_solved']:
                                sx_solved_vars += [casadi.SX.sym(name) for name in [var.__repr__()[3:-1]
                                                   for var in causal_co.mx_vars]]
                            solved_expr.extend([sol[i] for i in range(sol.numel())])
                        else:
                            n_unsolvable += causal_co.n
                            explicit_unsolved_algebraics.extend([var.mvar for var in causal_co.variables
                                                                 if not var.is_der])
                            explicit_unsolved_vars.extend(causal_co.mx_vars)
                            res = casadi.vertcat(causal_co.eq_expr)
                            all_vars = causal_co.mx_vars + known_vars + solved_vars + tear_mx_vars
                            res_f = casadi.MXFunction(all_vars , [res])
                            res_f.init()
                            if options['closed_form']:
                                explicit_unsolved_sx_vars.extend(causal_co.sx_vars)
                                sx_res = casadi.SXFunction(res_f)
                                sx_res.init()
                                residuals.extend(sx_res.call(causal_co.sx_vars + sx_known_vars + solved_expr, True))
                                solved_expr.extend(causal_co.sx_vars)
                            else:
                                residuals.extend(res_f.call(causal_co.mx_vars + known_vars +
                                                            solved_expr + tear_mx_vars))
                                solved_expr.extend(causal_co.mx_vars)
                            solved_vars.extend(causal_co.mx_vars)

                    n_unsolvable += len(co.block_tear_vars)
                    explicit_unsolved_algebraics.extend([var.mvar for var in co.block_tear_vars if not var.is_der])
                    explicit_unsolved_vars.extend([var.mx_var for var in co.block_tear_vars])
                    if options['closed_form']:
                        # Create SX residual
                        explicit_unsolved_sx_vars.extend([var.sx_var for var in co.block_tear_vars])
                        res = casadi.vertcat([eq.expression for eq in co.block_tear_res])
                        co.tear_mx_vars = tear_mx_vars = [var.mx_var for var in co.block_tear_vars]
                        all_vars = tear_mx_vars + known_vars + solved_vars
                        res_f = casadi.MXFunction(all_vars , [res])
                        res_f.init()
                        sx_res = casadi.SXFunction(res_f)
                        sx_res.init()
                        residuals.extend(sx_res.call(tear_mx_vars + known_vars + solved_expr, True))

                        raise NotImplementedError
                        #~ solved_expr.extend(co.sx_vars) # Need to figure out what do here
                    else:
                        res = casadi.vertcat([eq.expression for eq in co.block_tear_res])
                        co.tear_mx_vars = tear_mx_vars = [var.mx_var for var in co.block_tear_vars]
                        all_vars = tear_mx_vars + known_vars + solved_vars
                        res_f = casadi.MXFunction(all_vars , [res])
                        res_f.init()
                        residuals.extend(res_f.call(tear_mx_vars + known_vars + solved_expr))
                        solved_expr.extend(tear_mx_vars)
                    solved_vars.extend(tear_mx_vars)
                else:
                    for var in co.variables:
                        self._dependencies[var.name] = [var.name]
                    
                    n_unsolvable += co.n
                    explicit_unsolved_algebraics.extend([var.mvar for var in co.variables if not var.is_der])
                    explicit_unsolved_vars.extend(co.mx_vars)
                    res = casadi.vertcat(co.eq_expr)
                    all_vars = co.mx_vars + known_vars + solved_vars 
                    res_f = casadi.MXFunction(all_vars , [res])
                    res_f.init()
                    if options['closed_form']:
                        explicit_unsolved_sx_vars.extend(co.sx_vars)
                        sx_res = casadi.SXFunction(res_f)
                        sx_res.init()
                        residuals.extend(sx_res.call(co.sx_vars + sx_known_vars + solved_expr, True))
                        solved_expr.extend(co.sx_vars)
                    else:
                        residuals.extend(res_f.call(co.mx_vars + known_vars + solved_expr))
                        solved_expr.extend(co.mx_vars)
                    solved_vars.extend(co.mx_vars)
            global_index += co.n

        # Save results
        self._dae_residual = casadi.vertcat(residuals)
        self._explicit_unsolved_algebraics = [var for var in self._model.getVariables(self.REAL_ALGEBRAIC) if
                                              var in explicit_unsolved_algebraics] # Preserve order
        self._solved_algebraics_mvar = [var[1].mvar for var in explicit_solved_algebraics]
        self.n_solvable = n_solvable
        self.n_unsolvable = n_unsolvable

        # Draw BLT
        if options['plots'] or options['draw_blt']:
            self._graph.draw_blt(strings=options['draw_blt_strings'])

    def _sparsity_preserving(self, co):
        """
        Check whether system sparsity is sufficiently preserved if block is solved.
        """
        # We never solve non-scalar blocks, so mark as sparsity preserving for plotting reasons
        if len(co.variables) > 1:
            for var in co.variables:
                self._dependencies[var.name] = [var.name]
            co.sparsity_preserving = True
            return True
        var = co.variables[0]

        # Find untorn dependencies, excluding block variable
        deps = []
        for i in xrange(co.n):
            for vk in ['dx', 'x', 'u', 'w', 'p_opt']:
                for dae_var in self._mx_var_struct[vk]:
                    if casadi.dependsOn(co.eq_expr[i], [dae_var]) and dae_var.getName() != var.name:
                        deps.append(dae_var)
        deps = list(set(deps))

        # Find torn dependencies
        torn_dep_names = []
        for dep in deps:
            torn_dep_names += self._dependencies[dep.getName()]
        torn_dep_names = list(set(torn_dep_names))

        # Compute density measure
        if self.options['dense_measure'] == 'Markowitz':
            # Count dependencies
            n_dependencies = len(torn_dep_names)

            # Count incidences
            n_incidences = self._graph.incidences.getcol(var.global_index).getnnz()

            # Compute measure
            measure = (n_dependencies - 1) * (n_incidences - 1)
        elif self.options['dense_measure'] == 'lmfi':
            # Compute measure
            measure = 0
            incidences = list(self._graph.incidences.getcol(var.global_index).nonzero()[0])
            incidences.remove(co.equations[0].global_index) # Skip block equation
            if len(incidences) > 1:
                # Find torn dependencies that cause fill-in
                for inc in incidences:
                    inc_torn_dep_names = []
                    for dep in deps:
                        # If dependency causes fill-in
                        if not casadi.dependsOn(self._graph.equations[inc].expression, [dep]):
                            inc_torn_dep_names += self._dependencies[dep.getName()]
                    n_dependencies = len(set(inc_torn_dep_names))
                    measure += n_dependencies - 1
        else:
            raise ValueError('Unknown density measure %s.' % self.options['dense_measure'])

        # Compare measure with tolerance
        if measure >= self.options['dense_tol']:
            self._dependencies[var.name] = [var.name]
            co.sparsity_preserving = False
            return False
        else:
            self._dependencies[var.name] = torn_dep_names
            co.sparsity_preserving = True
            return True

    def _print_statistics(self):
        """
        Print BLT statistics.
        """
        block_sizes = np.sort([co.n for co in self._graph.components])
        n_alg_before = len([var for var in self._model.getVariables(self._model.REAL_ALGEBRAIC) if not var.isAlias()])
        n_alg_after = len([var for var in self.getVariables(self.REAL_ALGEBRAIC) if not var.isAlias()])
        print('\nSystem has %d algebraic variables before elimination and %d after.' % (n_alg_before, n_alg_after))
        n_blocks = len(self._graph.components)
        if n_blocks > 3:
            print('The three largest BLT blocks have sizes %d, %d, and %d.\n' % tuple(block_sizes[-1:-4:-1]))
        else:
            print('The system has %d BLT blocks of sizes: %s' % (n_blocks, block_sizes[::-1]))

    def getVariables(self, vk):
        if vk == self.REAL_ALGEBRAIC:
            return np.array(self._explicit_unsolved_algebraics)
        else:
            return self._model.getVariables(vk)

    def set(self, *args):
        self._model.set(*args)

    def get(self, *args):
        return self._model.get(*args)

    def getAliases(self):
        return np.array([var for var in self._model.getAliases() if var.getModelVariable() not in self._solved_algebraics_mvar])

    def getAllVariables(self):
        # Include aliases of unsolved algebraics
        unsolved_algebraics_aliases = [var for var in self._model.getVariables(self._model.REAL_ALGEBRAIC) if not var.getModelVariable() in self._solved_algebraics_mvar]
        return np.array([var for var in self._model.getAllVariables() if
                         (var not in self._model.getVariables(self.REAL_ALGEBRAIC) or var in unsolved_algebraics_aliases)])

    def getDaeResidual(self):
        return self._dae_residual
    
    def get_solved_variables(self):
        """
        Returns list of names of explicitly solved BLT variables.
        """
        return [var.getName() for var in self._explicit_solved_vars]

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

class BLTOptimizationProblem(BLTModel, ModelBase):

    """
    Emulates CasADi Interface's OptimizationProblem class using BLT.
    """

    def __init__(self, op, elimination_options=EliminationOptions()):
        """
        Creates a BLTModel from a Model.
        """
        self._op = op
        super(BLTOptimizationProblem, self).__init__(op, elimination_options)
        self._substitute_objective_and_constraint()

    def _process_ineliminables(self):
        # Mark variables with timed variables as ineliminable
        for var in self._model.getTimedVariables():
            self.options['ineliminable'] += [var.getBaseVariable().getName()]
        self.options['ineliminable'] = list(set(self.options['ineliminable']))
        super(BLTOptimizationProblem, self)._process_ineliminables()

    def _substitute_objective_and_constraint(self):
        """
        Substitute eliminated variables in objectiveIntegrand and path constraints.
        """
        # Find solved variables and their solutions
        solved_vars = []
        solved_expr = []
        for (i, var) in self._explicit_solved_algebraics:
            if self.options['closed_form']:
                solved_vars.append(var.sx_var)
            else:
                solved_vars.append(var.mx_var)
            solved_expr.append(self._solved_expr[i])

        # Copy original path constraints
        path_constraints = [ci.Constraint(constraint) for constraint in self._op.getPathConstraints()]
        n_path = len(path_constraints)
        if n_path > 0:
            [path_lhs, path_rhs] = \
                    map(list, zip(*[(constraint.getLhs(), constraint.getRhs()) for constraint in path_constraints]))
        else:
            path_lhs = []
            path_rhs = []

        # Substitute
        objective_integrand = [self._op.getObjectiveIntegrand()]
        if self.options['closed_form']:
            all_vars = self._explicit_unsolved_vars + self._known_vars + self._explicit_solved_vars
            mx_f = casadi.MXFunction(all_vars, path_lhs + path_rhs + objective_integrand)
            mx_f.init()
            sx_f = casadi.SXFunction(mx_f)
            sx_f.init()
            new_expr = sx_f.call(self._explicit_unsolved_sx_vars + self._sx_known_vars + solved_expr,
                                 self.options['inline'])
        else:
            new_expr = casadi.substitute(path_lhs + path_rhs + objective_integrand, solved_vars, solved_expr)

        # Unpack new expressions
        path_lhs = new_expr[:n_path]
        path_rhs = new_expr[n_path:-1]
        objective_integrand = new_expr[-1]

        # Update objective and path constraints
        if self.options['closed_form']:
            self._path_constraints = np.array(path_lhs) - np.array(path_rhs)
            self._objective_integrand = objective_integrand
        else:
            for (path, lhs, rhs) in itertools.izip(path_constraints, path_lhs, path_rhs):
                path.setLhs(lhs)
                path.setRhs(rhs)
            self._path_constraints = np.array(path_constraints)
            self._objective_integrand = objective_integrand

    def getObjectiveIntegrand(self):
        return self._objective_integrand

    def getPathConstraints(self):
        return self._path_constraints

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
            raise ValueError("LocalDAECollocationAlg is the only supported algorithm.")
        op_res = self._exec_algorithm('pyjmi.jmi_algorithm_drivers', algorithm, options)

        # Create result
        class BLTResult(dict):
            def __init__(self, op_res):
                self._op_res = op_res
            def get_data_matrix(self):
                return self._op_res.result_data.get_data_matrix()
            def get_variable_data(self, name):
                return self._op_res.result_data.get_variable_data(name)
            def get_opt_input(self):
                return self._op_res.get_opt_input()
            def get_solver_statistics(self):
                return self._op_res.get_solver_statistics()
        res = BLTResult(op_res)
        for key in op_res.keys():
            res[key] = op_res[key]

        # Add result for solved algebraics
        if len(self._explicit_solved_algebraics) > 0:
            # Create function for computing solved algebraics
            explicit_solved_expr = []
            for (i, sol_alg) in self._explicit_solved_algebraics:
                res[sol_alg.name] = []
                explicit_solved_expr.append(self._solved_expr[i])
            alg_sol_f = casadi.MXFunction(self._known_vars + self._explicit_unsolved_vars, explicit_solved_expr)
            alg_sol_f.init()
            if op_res.solver.expand_to_sx != "no":
                alg_sol_f = casadi.SXFunction(alg_sol_f)
                alg_sol_f.init()

            # Compute solved algebraics
            for k in xrange(len(res['time'])):
                for (i, var) in enumerate(self._known_vars + self._explicit_unsolved_vars):
                    alg_sol_f.setInput(res[var.getName()][k], i)
                alg_sol_f.evaluate()
                for (i, sol_alg) in enumerate(self._explicit_solved_algebraics):
                    res[sol_alg[1].name].append(alg_sol_f.getOutput(i).toArray().reshape(-1))

        # Add results for all alias variables (only needed for solved algebraics) and convert to array
        for var in self._model.getAllVariables():
            res[var.getName()] = np.array(res[var.getModelVariable().getName()])

        # Return result
        res.solver = op_res.solver
        return res

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
