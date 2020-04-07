#!/usr/bin/env python 
# -*- coding: utf-8 -*-

# Copyright (C) 2015 Modelon AB
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

"""Tests back tracking from collocated NLP to original equations and variables."""

import os
import numpy as N
from tests_jmodelica import testattr, get_files_path
try:
    from pyjmi import transfer_optimization_problem
    from pyjmi.optimization.casadi_collocation import BlockingFactors
except (NameError, ImportError):
    pass

def check_roundtrip(solver):
    coll = solver.collocator
    
    xx_dests, xx_sources = coll.xx_dests, coll.xx_sources
    for (var, dest) in xx_dests.iteritems():
        inds = dest['inds']
        assert N.all(xx_sources['var'][inds] == var)
        assert N.all(xx_sources['i'][inds] == dest['i'])
        assert N.all(xx_sources['k'][inds] == dest['k'])
    
    c_dests, c_sources = coll.c_dests, coll.c_sources
    for eqtype in solver.get_constraint_types():
        inds, t, i, k = solver.get_nlp_constraint_indices(eqtype)
        assert N.all(c_sources['eqtype'][inds] == eqtype)
        assert N.all(c_sources['eqind'][inds] == N.arange(inds.shape[1], dtype=N.int))
        assert N.all(c_sources['i'][inds] == i[:, N.newaxis])
        assert N.all(c_sources['k'][inds] == k[:, N.newaxis])

def check_solution(solver):
    violations = solver.get_nlp_residuals()
    assert N.max(N.abs(violations)) < 1e-12

@testattr(casadi_base = True)
def test_nlp_variable_indices():
    file_path = os.path.join(get_files_path(), 'Modelica', 'TestBackTracking.mop')
    op = transfer_optimization_problem("TestVariableTypes", file_path)

    n_e = 10

    opts = op.optimize_options()
    opts['n_e'] = n_e
    opts['variable_scaling'] = False
    opts['blocking_factors'] = BlockingFactors({'u_bf':[1]*n_e})

    res = op.optimize(options = opts)

    t = res['time']
    solver = res.get_solver()
    check_roundtrip(solver)
    check_solution(solver)
    xx = solver.collocator.primal_opt

    var_names = ['x', 'x2', 'w', 'w2', 'u_cont', 'u_bf', 'p']
    for name in var_names:
        inds, tv, i, k = solver.get_nlp_variable_indices(name)
        tinds = N.searchsorted((t[:-1]+t[1:])/2, tv)
        assert N.max(N.abs(t[tinds] - tv)) < 1e-12
        if name == 'u_bf':
            # workaround for the fact that res uses the left value of u_bf
            # at the discontinuity point, and back tracking uses the right
            tinds += 1
        assert N.max(N.abs(res[name][tinds] - xx[inds])) < 1e-12

@testattr(casadi_base = True)
def test_get_residuals():
    file_path = os.path.join(get_files_path(), 'Modelica', 'TestBackTracking.mop')
    op = transfer_optimization_problem("TestResiduals", file_path)

    n_e = 10
    n_cp = 3

    opts = op.optimize_options()
    opts['n_e'] = n_e
    opts['n_cp'] = n_cp
    opts['variable_scaling'] = False
    opts['equation_scaling'] = True

    var_names = ('x', 'der(x)', 'w', 'u')
    eqtypes   = ('initial', 'dae', 'path_eq', 'path_ineq', 'point_eq', 'point_ineq')

    solver = op.prepare_optimization(options=opts)
    check_roundtrip(solver)
    collocator = solver.collocator

    # Set random initial values
    N.random.seed(486151)
    initial = {}
    for var in var_names:
        initial[var] = N.random.rand(n_e+1, n_cp+1)

        inds, t, i, k = solver.get_nlp_variable_indices(var)
        collocator.xx_init[inds] = initial[var][i, k]
    x, derx, w, u = initial['x'], initial['der(x)'], initial['w'], initial['u'] 

    # Check that the residuals match the equations in the model
    for eqtype in eqtypes:
        r1 = solver.get_residuals(eqtype, point='init', raw=True, tik=False)
        t, i, k = solver.get_constraint_points(eqtype)
        i, k = N.maximum(1, i), N.maximum(0, k)
        if eqtype == 'initial':      r2 = 1e3*(x - 1) # x = 1;
        elif eqtype == 'dae':        r2 = 2e4*(derx - u) # der(x) = u;
        elif eqtype == 'path_eq':    r2 = 3e3*(w - x**2) # w = x^2;
        elif eqtype == 'path_ineq':  r2 = 4e3*(x - u**2) # x <= u^2;
        elif eqtype == 'point_eq':
            r2 = 5e3*(x - 2) # x(finalTime) = 2;
            i, k = -1, -1
        elif eqtype == 'point_ineq':
            r2 = 6e3*(-5 - x) # x(startTime) >= -5;
            i, k = 1, 0
        r2 = r2[i, k]
        assert N.max(N.abs(r2 - r1.ravel())) < 1e-12*1e4

        r1 = solver.get_residuals(eqtype, point='init', raw=True, scaled=True, tik=False)
        rs = solver.get_residual_scales(eqtype)
        assert N.max(N.abs(r2*rs - r1.ravel())) < 1e-12

        v1 = solver.get_residuals(eqtype, point='init', raw=False, tik=False)
        if eqtype in ('path_ineq', 'point_ineq'):
            v2 = N.maximum(0, r2)
        else:
            v2 = r2
        assert N.max(N.abs(v2 - v1.ravel())) < 1e-12

        dest = solver.collocator.c_dests[eqtype]
        assert dest['n_eq'] == 1 # for this model
        if eqtype in ('path_ineq', 'point_ineq'):
            assert dest['kind'] == 'ineq'
        else:
            assert dest['kind'] == 'eq'

@testattr(casadi_base = True)
def test_find_nonfinite_jacobian_entry():
    file_path = os.path.join(get_files_path(), 'Modelica', 'TestBackTracking.mop')
    op = transfer_optimization_problem("TestJacInf", file_path)

    solver = op.prepare_optimization()
    check_roundtrip(solver)
    for point in ('init', 'opt'):
        if point == 'opt':
            solver.optimize()

        entries = solver.find_nonfinite_jacobian_entries(point=point)
        assert len(entries) == 1
        (eqtype, eqind, var), = entries # get the only entry and unpack it
        assert eqtype == 'dae'
        assert var == op.getVariable('x2')
        assert 'sqrt' in str(solver.get_equations(eqtype,eqind))

@testattr(casadi_base = True)
def test_duals():
    file_path = os.path.join(get_files_path(), 'Modelica', 'TestBackTracking.mop')
    op = transfer_optimization_problem("TestDuals", file_path)

    n_e = 10
    n_cp = 1

    opts = op.optimize_options()
    opts['n_e'] = n_e
    opts['n_cp'] = n_cp

    solver = op.prepare_optimization(options=opts)
    check_roundtrip(solver)
    solver.optimize()
    check_solution(solver)

    h = 1.0/n_e

    # Strange things seem to happen with the first two entries in the duals;
    # skip them in the comparison.
    # Interaction with initial constraints?
    l = solver.get_constraint_duals('path_ineq', tik=False)
    t, i, k = solver.get_constraint_points('path_ineq')
    l0 = t*h
    assert N.max(N.abs((l.ravel()-l0)[2:])) < 1e-12

    l = solver.get_bound_duals('y', tik=False)
    t, i, k = solver.get_variable_points('y')
    l0 = (t-2)*h
    assert N.max(N.abs((l.ravel()-l0)[2:])) < 1e-12

@testattr(casadi_base = True)
def test_get_equations():
    file_path = os.path.join(get_files_path(), 'Modelica', 'TestBackTracking.mop')
    op = transfer_optimization_problem("TestEquations", file_path)

    eqkeys = {'initial':'sin', 'dae':'der', 'path_eq':'sqrt', 'path_ineq':'cos',
        'point_eq':'tan', 'point_ineq':'exp'}

    solver = op.prepare_optimization()
    check_roundtrip(solver)

    for (eqtype, key) in eqkeys.iteritems():
        eqs = solver.get_equations(eqtype)
        assert len(eqs) == 1
        assert key in repr(eqs[0])
