#!/usr/bin/env python
# -*- coding: utf-8 -*-

#    Copyright (C) 2016 Modelon AB
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
Tests for pyjmi.symbolic_elimination.
"""

import sys
from tests_jmodelica import testattr, get_files_path
import numpy as N
import os
from pyfmi import load_fmu
from collections import OrderedDict
from pymodelica import compile_fmu

try: 
    from pyjmi.symbolic_elimination import BLTOptimizationProblem, EliminationOptions
    from pyjmi import transfer_optimization_problem
    import casadi
    from pyjmi.optimization.casadi_collocation import ExternalData
except (NameError, ImportError):
    pass

def assert_results(res, cost_ref, u_norm_ref,
                   cost_rtol=1e-3, u_norm_rtol=1e-4, input_name="u"):
    """Helper function for asserting optimization results."""
    cost = float(res.solver.solver_object.output(casadi.NLP_SOLVER_F))
    u = res[input_name]
    u_norm = N.linalg.norm(u) / N.sqrt(len(u))
    N.testing.assert_allclose(cost, cost_ref, cost_rtol)
    N.testing.assert_allclose(u_norm, u_norm_ref, u_norm_rtol)

class TestSymbolicElimination(object):
    
    """
    Tests pyjmi.BLTOptimizationProblem.
    """
    
    @classmethod
    def setUpClass(self):
        """Compile the test models."""
        self.compiler_opts_automatic = {'equation_sorting': True, 'automatic_tearing': True}
        self.compiler_opts_manual = {}
        
        class_path = "IllustExample"
        file_path = os.path.join(get_files_path(), 'Modelica', 'SymbolicElimination.mop')
        self.model_illust = load_fmu(compile_fmu(class_path, file_path))
        
        class_path = "IllustExampleLagrange"
        file_path = os.path.join(get_files_path(), 'Modelica', 'SymbolicElimination.mop')
        self.op_illust_automatic = transfer_optimization_problem(class_path, file_path, self.compiler_opts_automatic)
        self.op_illust_manual = transfer_optimization_problem(class_path, file_path, self.compiler_opts_manual)
        
        class_path = "IllustExampleLagrangeBound"
        file_path = os.path.join(get_files_path(), 'Modelica', 'SymbolicElimination.mop')
        self.op_illust_automatic_bound = transfer_optimization_problem(
                class_path, file_path, self.compiler_opts_automatic)
        self.op_illust_manual_bound = transfer_optimization_problem(
                class_path, file_path, self.compiler_opts_manual)
        
        class_path = "IllustExampleLagrangeConstraintAndObjective"
        file_path = os.path.join(get_files_path(), 'Modelica', 'SymbolicElimination.mop')
        self.op_illust_automatic_constraint = transfer_optimization_problem(
                class_path, file_path, self.compiler_opts_automatic)
        self.op_illust_manual_constraint = transfer_optimization_problem(
                class_path, file_path, self.compiler_opts_manual)
        
        class_path = "IllustExampleEst"
        file_path = os.path.join(get_files_path(), 'Modelica', 'SymbolicElimination.mop')
        self.op_illust_est_automatic = transfer_optimization_problem(class_path, file_path, self.compiler_opts_automatic)
        self.op_illust_est_manual = transfer_optimization_problem(class_path, file_path, self.compiler_opts_manual)
        
        class_path = "LinearLoopLagrangeConstraint"
        file_path = os.path.join(get_files_path(), 'Modelica', 'SymbolicElimination.mop')
        self.op_loop_automatic = transfer_optimization_problem(
                class_path, file_path, self.compiler_opts_automatic)
        self.op_loop_manual = transfer_optimization_problem(
                class_path, file_path, self.compiler_opts_manual)
        
        class_path = "DerivativeLoop"
        file_path = os.path.join(get_files_path(), 'Modelica', 'SymbolicElimination.mop')
        self.op_der_loop_automatic = transfer_optimization_problem(
                class_path, file_path, self.compiler_opts_automatic)
        self.op_der_loop_manual = transfer_optimization_problem(
                class_path, file_path, self.compiler_opts_manual)
        
    @testattr(casadi_base = True)
    def test_automatic_tearing(self):
        """
        Test consistency between with and without automatic tearing.
        """
        cost_ref = 1.06183273
        u_norm_ref = 0.398219663

        # Perform elimination
        blt_op_automatic = BLTOptimizationProblem(self.op_illust_automatic)
        blt_op_manual = BLTOptimizationProblem(self.op_illust_manual)

        # Check remaining variables
        var_automatic = sorted([var.getName() for var in blt_op_automatic.getVariables(blt_op_automatic.REAL_ALGEBRAIC)
                                if not var.isAlias()])
        var_manual = sorted([var.getName() for var in blt_op_manual.getVariables(blt_op_manual.REAL_ALGEBRAIC)
                             if not var.isAlias()])
        assert len(var_automatic) == 3
        assert len(var_manual) == 4

        # Optimize and check result
        res_automatic = blt_op_automatic.optimize()
        res_manual = blt_op_manual.optimize()
        assert_results(res_automatic, cost_ref, u_norm_ref, u_norm_rtol=1e-2)
        assert_results(res_manual, cost_ref, u_norm_ref, u_norm_rtol=1e-2)
        
    @testattr(casadi_base = True)
    def test_hybrid_tearing(self):
        """
        Test consistency between manual and automatic tearing as well as the combination of both.
        """
        cost_ref = 1.06183273
        u_norm_ref = 0.398219663

        # Automatic tearing
        blt_op_automatic = BLTOptimizationProblem(self.op_illust_automatic)

        # Manual tearing
        op_manual = self.op_illust_manual
        op_manual.getVariable('y3').setTearing(True)
        for eq in op_manual.getDaeEquations():
            if 'y1)*y2)*y4)' in eq.getResidual().getRepresentation():
                eq.setTearing(True)
        blt_op_manual = BLTOptimizationProblem(op_manual)

        # Automatic and manual tearing
        op_hybrid = self.op_illust_automatic
        op_hybrid.getVariable('y1').setTearing(False)
        for eq in op_hybrid.getDaeEquations():
            if '(y1*y4)+sqrt(y3)' in eq.getResidual().getRepresentation():
                eq.setTearing(False)
        blt_op_hybrid = BLTOptimizationProblem(op_hybrid)

        # Check remaining variables
        var_automatic = sorted([var.getName() for var in blt_op_automatic.getVariables(blt_op_automatic.REAL_ALGEBRAIC)
                                if not var.isAlias()])
        var_manual = sorted([var.getName() for var in blt_op_manual.getVariables(blt_op_manual.REAL_ALGEBRAIC)
                             if not var.isAlias()])
        var_hybrid = sorted([var.getName() for var in blt_op_hybrid.getVariables(blt_op_hybrid.REAL_ALGEBRAIC)
                             if not var.isAlias()])
        assert len(var_automatic) == 3
        assert len(var_manual) == 2
        assert len(var_hybrid) == 2

        # Optimize and check result
        res_automatic = blt_op_automatic.optimize()
        res_manual = blt_op_manual.optimize()
        res_hybrid = blt_op_hybrid.optimize()
        assert_results(res_automatic, cost_ref, u_norm_ref, u_norm_rtol=1e-2)
        assert_results(res_manual, cost_ref, u_norm_ref, u_norm_rtol=1e-2)
        assert_results(res_hybrid, cost_ref, u_norm_ref, u_norm_rtol=1e-2)

        # Reset tearing choices
        op_manual.getVariable('y3').setTearing(False)
        for eq in op_manual.getDaeEquations():
            if 'y1)*y2)*y4)' in eq.getResidual().getRepresentation():
                eq.setTearing(False)
        op_hybrid.getVariable('y1').setTearing(True)
        for eq in op_hybrid.getDaeEquations():
            if '(y1*y4)+sqrt(y3)' in eq.getResidual().getRepresentation():
                eq.setTearing(True)
        
    @testattr(casadi_base = True)
    def test_ineliminable(self):
        """
        Test ineliminable variables for both manual and automatic tearing.
        """
        cost_ref = 1.08181340
        u_norm_ref = 0.399868319

        # Mark bounded varible as ineliminable
        elim_opts = EliminationOptions()
        elim_opts['ineliminable'] = ['y1']

        # Manual tearing
        op_manual = self.op_illust_manual_bound
        op_manual.getVariable('y3').setTearing(True)
        for eq in op_manual.getDaeEquations():
            if 'y1)*y2)*y4)' in eq.getResidual().getRepresentation():
                eq.setTearing(True)
        blt_op_manual = BLTOptimizationProblem(op_manual, elim_opts)

        # Automatic and manual tearing
        op_hybrid = self.op_illust_automatic_bound
        op_hybrid.getVariable('y1').setTearing(False)
        for eq in op_hybrid.getDaeEquations():
            if '(y1*y4)+sqrt(y3)' in eq.getResidual().getRepresentation():
                eq.setTearing(False)
        blt_op_hybrid = BLTOptimizationProblem(op_hybrid, elim_opts)

        # Check remaining variables
        var_manual = sorted([var.getName() for var in blt_op_manual.getVariables(blt_op_manual.REAL_ALGEBRAIC)
                             if not var.isAlias()])
        var_hybrid = sorted([var.getName() for var in blt_op_hybrid.getVariables(blt_op_hybrid.REAL_ALGEBRAIC)
                             if not var.isAlias()])
        assert len(var_manual) == 3
        assert len(var_hybrid) == 3

        # Optimize and check result
        res_manual = blt_op_manual.optimize()
        res_hybrid = blt_op_hybrid.optimize()
        assert_results(res_manual, cost_ref, u_norm_ref, u_norm_rtol=1e-2)
        assert_results(res_hybrid, cost_ref, u_norm_ref, u_norm_rtol=1e-2)

        # Reset tearing choices
        op_manual.getVariable('y3').setTearing(False)
        for eq in op_manual.getDaeEquations():
            if 'y1)*y2)*y4)' in eq.getResidual().getRepresentation():
                eq.setTearing(False)
        op_hybrid.getVariable('y1').setTearing(True)
        for eq in op_hybrid.getDaeEquations():
            if '(y1*y4)+sqrt(y3)' in eq.getResidual().getRepresentation():
                eq.setTearing(True)
        
    @testattr(casadi_base = True)
    def test_sparsity_preservation(self):
        """
        Test sparsity preservation for both LMFI and Markowitz.
        """
        cost_ref = 1.06183273
        u_norm_ref = 0.398219663

        # Specify sparsity preservation
        elim_opts_lmfi = EliminationOptions()
        elim_opts_lmfi['dense_tol'] = 2
        elim_opts_lmfi['dense_measure'] = "lmfi"
        elim_opts_mrkwtz = EliminationOptions()
        elim_opts_mrkwtz['dense_tol'] = 4
        elim_opts_mrkwtz['dense_measure'] = "Markowitz"
        elim_opts_mrkwtz2 = EliminationOptions()
        elim_opts_mrkwtz2['dense_tol'] = 2
        elim_opts_mrkwtz2['dense_measure'] = "Markowitz"

        # Manual tearing
        op = self.op_illust_manual
        op.getVariable('y3').setTearing(True)
        for eq in op.getDaeEquations():
            if 'y1)*y2)*y4)' in eq.getResidual().getRepresentation():
                eq.setTearing(True)
        blt_op_lmfi = BLTOptimizationProblem(op, elim_opts_lmfi)
        blt_op_mrkwtz = BLTOptimizationProblem(op, elim_opts_mrkwtz)
        blt_op_mrkwtz2 = BLTOptimizationProblem(op, elim_opts_mrkwtz2)

        # Check remaining variables
        var_lmfi = sorted([var.getName() for var in blt_op_lmfi.getVariables(blt_op_lmfi.REAL_ALGEBRAIC)
                           if not var.isAlias()])
        var_mrkwtz = sorted([var.getName() for var in blt_op_mrkwtz.getVariables(blt_op_mrkwtz.REAL_ALGEBRAIC)
                             if not var.isAlias()])
        var_mrkwtz2 = sorted([var.getName() for var in blt_op_mrkwtz2.getVariables(blt_op_mrkwtz.REAL_ALGEBRAIC)
                              if not var.isAlias()])
        assert len(var_lmfi) == 3
        assert len(var_mrkwtz) == 3
        assert len(var_mrkwtz2) == 4

        # Optimize and check result
        res_lmfi = blt_op_lmfi.optimize()
        res_mrkwtz = blt_op_mrkwtz.optimize()
        res_mrkwtz2 = blt_op_mrkwtz2.optimize()
        assert_results(res_lmfi, cost_ref, u_norm_ref, u_norm_rtol=1e-2)
        assert_results(res_mrkwtz, cost_ref, u_norm_ref, u_norm_rtol=1e-2)
        assert_results(res_mrkwtz2, cost_ref, u_norm_ref, u_norm_rtol=1e-2)

        # Reset tearing choices
        op.getVariable('y3').setTearing(False)
        for eq in op.getDaeEquations():
            if 'y1)*y2)*y4)' in eq.getResidual().getRepresentation():
                eq.setTearing(False)
        
    @testattr(casadi_base = True)
    def test_closed_form(self):
        """
        Test creation of closed form expressions when not using tearing.
        """
        # Perform elimination
        elim_opts = EliminationOptions()
        elim_opts['inline_solved'] = True
        elim_opts['closed_form'] = True
        blt_op = BLTOptimizationProblem(self.op_illust_manual, elim_opts)
        for res in blt_op.getDaeResidual():
            if 'y1)*y2)*' in res.getRepresentation():
                residual = res.getRepresentation()
        N.testing.assert_string_equal(residual, "SX(((((2*y1)*y2)*sqrt(y5))-sqrt(x1)))")

    @testattr(casadi_base = True)
    def test_constraint_and_objective(self):
        """
        Test eliminating variables occurring in constraints and objective.
        """
        cost_ref = 1.08181340
        u_norm_ref = 0.399868319

        # Mark bounded varible as ineliminable for reference
        inelim_opts = EliminationOptions()
        inelim_opts['ineliminable'] = ['y1']
        elim_opts = EliminationOptions()

        # Manual tearing
        op = self.op_illust_manual_constraint
        op.getVariable('y3').setTearing(True)
        for eq in op.getDaeEquations():
            if 'y1)*y2)*y4)' in eq.getResidual().getRepresentation():
                eq.setTearing(True)
        blt_op_inelim = BLTOptimizationProblem(op, inelim_opts)
        blt_op_elim = BLTOptimizationProblem(op, elim_opts)

        # Check remaining variables
        var_inelim = sorted([var.getName() for var in blt_op_inelim.getVariables(blt_op_inelim.REAL_ALGEBRAIC)
                             if not var.isAlias()])
        var_elim = sorted([var.getName() for var in blt_op_elim.getVariables(blt_op_elim.REAL_ALGEBRAIC)
                           if not var.isAlias()])
        assert len(var_inelim) == 3
        assert len(var_elim) == 2

        # Optimize and check result
        res_inelim = blt_op_inelim.optimize()
        res_elim = blt_op_elim.optimize()
        assert_results(res_inelim, cost_ref, u_norm_ref, u_norm_rtol=1e-2)
        assert_results(res_elim, cost_ref, u_norm_ref, u_norm_rtol=1e-2)

        # Reset tearing choices
        op.getVariable('y3').setTearing(False)
        for eq in op.getDaeEquations():
            if 'y1)*y2)*y4)' in eq.getResidual().getRepresentation():
                eq.setTearing(False)

    @testattr(casadi_base = True)
    def test_block_solve(self):
        """
        Test solution of linear blocks both symbolically with SX and numerically with MX.

        Numerical part of the test has been disabled, see #5208.
        """
        cost_ref = 2.5843277
        u_norm_ref = 0.647282415

        # Select linear solver
        dae_opts = EliminationOptions()
        dae_opts['solve_blocks'] = False
        symbolic_opts = EliminationOptions()
        symbolic_opts['solve_blocks'] = True
        symbolic_opts['linear_solver'] = "symbolicqr"
        numeric_opts = EliminationOptions()
        numeric_opts['solve_blocks'] = True
        numeric_opts['linear_solver'] = "lapackqr"
        numeric_op_opts = {'expand_to_sx': 'no'}

        # Eliminate
        op = self.op_loop_manual
        blt_op_dae = BLTOptimizationProblem(op, dae_opts)
        blt_op_symbolic = BLTOptimizationProblem(op, symbolic_opts)
        #~ blt_op_numeric = BLTOptimizationProblem(op, numeric_opts)

        # Check remaining variables
        var_dae = sorted([var.getName() for var in blt_op_dae.getVariables(blt_op_dae.REAL_ALGEBRAIC)
                          if not var.isAlias()])
        var_symbolic = sorted([var.getName() for var in blt_op_symbolic.getVariables(blt_op_symbolic.REAL_ALGEBRAIC)
                               if not var.isAlias()])
        #~ var_numeric = sorted([var.getName() for var in blt_op_numeric.getVariables(blt_op_numeric.REAL_ALGEBRAIC)
                              #~ if not var.isAlias()])
        assert len(var_dae) == 2
        assert len(var_symbolic) == 0
        #~ assert len(var_numeric) == 0

        # Optimize and check result
        res_dae = blt_op_dae.optimize()
        res_symbolic = blt_op_symbolic.optimize()
        #~ res_numeric = blt_op_numeric.optimize(options=numeric_op_opts)
        assert_results(res_dae, cost_ref, u_norm_ref, u_norm_rtol=1e-2)
        assert_results(res_symbolic, cost_ref, u_norm_ref, u_norm_rtol=1e-2)
        #~ assert_results(res_numeric, cost_ref, u_norm_ref, u_norm_rtol=1e-2)

    @testattr(casadi_base = True)
    def test_linear_tearing(self):
        """
        Test solution of torn linear blocks both symbolically with SX and numerically with MX.

        Numerical part of the test has been disabled, see #5208.
        """
        cost_ref = 2.5843277
        u_norm_ref = 0.647282415

        # Select linear solver
        nonlinear_opts = EliminationOptions()
        nonlinear_opts['solve_blocks'] = False
        symbolic_opts = EliminationOptions()
        symbolic_opts['solve_blocks'] = True
        symbolic_opts['solve_torn_linear_blocks'] = True
        symbolic_opts['linear_solver'] = "symbolicqr"
        numeric_opts = EliminationOptions()
        numeric_opts['solve_blocks'] = True
        numeric_opts['solve_torn_linear_blocks'] = True
        numeric_opts['linear_solver'] = "lapackqr"
        numeric_op_opts = {'expand_to_sx': 'no'}

        # Eliminate
        op = self.op_loop_automatic
        blt_op_nonlinear = BLTOptimizationProblem(op, nonlinear_opts)
        blt_op_symbolic = BLTOptimizationProblem(op, symbolic_opts)
        #~ blt_op_numeric = BLTOptimizationProblem(op, numeric_opts)

        # Check remaining variables
        var_nonlinear = sorted([var.getName() for var in blt_op_nonlinear.getVariables(blt_op_nonlinear.REAL_ALGEBRAIC)
                                if not var.isAlias()])
        var_symbolic = sorted([var.getName() for var in blt_op_symbolic.getVariables(blt_op_symbolic.REAL_ALGEBRAIC)
                               if not var.isAlias()])
        #~ var_numeric = sorted([var.getName() for var in blt_op_numeric.getVariables(blt_op_numeric.REAL_ALGEBRAIC)
                              #~ if not var.isAlias()])
        assert len(var_nonlinear) == 1
        assert len(var_symbolic) == 0
        #~ assert len(var_numeric) == 0

        # Optimize and check result
        res_nonlinear = blt_op_nonlinear.optimize()
        res_symbolic = blt_op_symbolic.optimize()
        #~ res_numeric = blt_op_numeric.optimize(options=numeric_op_opts)
        assert_results(res_nonlinear, cost_ref, u_norm_ref, u_norm_rtol=1e-2)
        assert_results(res_symbolic, cost_ref, u_norm_ref, u_norm_rtol=1e-2)
        #~ assert_results(res_numeric, cost_ref, u_norm_ref, u_norm_rtol=1e-2)

    @testattr(casadi_base = True)
    def test_derivative_elimination(self):
        """
        Test that state derivatives are not eliminated even if causalized in torn blocks.
        """
        cost_ref = 88.740458
        u_norm_ref = 4.242559212
        
        op_manual = self.op_der_loop_manual
        op_automatic = self.op_der_loop_automatic

        # Eliminate
        blt_op_manual = BLTOptimizationProblem(op_manual)
        blt_op_automatic = BLTOptimizationProblem(op_automatic)

        # Check remaining variables
        var_manual = sorted([var.getName() for var in blt_op_manual.getVariables(blt_op_manual.REAL_ALGEBRAIC)
                             if not var.isAlias()])
        var_automatic = sorted([var.getName() for var in blt_op_automatic.getVariables(blt_op_automatic.REAL_ALGEBRAIC)
                                if not var.isAlias()])
        assert len(var_manual) == 2
        assert len(var_automatic) == 1

        # Optimize and check result
        res_manual = blt_op_manual.optimize()
        res_automatic = blt_op_automatic.optimize()
        assert_results(res_manual, cost_ref, u_norm_ref, u_norm_rtol=1e-2)
        assert_results(res_automatic, cost_ref, u_norm_ref, u_norm_rtol=1e-2)

    @testattr(casadi_base = True)
    def test_par_est(self):
        """
        Test parameter estimation.
        """
        cost_ref = 1.1109779e-2
        u_norm_ref = 0.556018602

        model = self.model_illust
        op = self.op_illust_est_automatic

        # Simulate with nominal parameters
        n_meas = 16
        sim_res = model.simulate(input=('u', lambda t: -0.2 + N.sin(t)), final_time=4.,
                                 options={'ncp': n_meas, 'CVode_options': {'rtol': 1e-10}})

        # Assemble external data by adding noise to simulation
        Q = N.diag([1., 1.])
        N.random.seed(1)
        t_meas = sim_res['time']
        sigma = 0.05
        x1_meas = sim_res['x1'] + sigma*N.random.randn(n_meas+1)
        x2_meas = sim_res['x2'] + sigma*N.random.randn(n_meas+1)
        u_meas = sim_res['u']
        data_x1 = N.vstack([t_meas, x1_meas])
        data_x2 = N.vstack([t_meas, x2_meas])
        data_u1 = N.vstack([t_meas, u_meas])
        quad_pen = OrderedDict()
        quad_pen['x1'] = data_x1
        quad_pen['x2'] = data_x2
        eliminated = OrderedDict()
        eliminated['u'] = data_u1
        external_data = ExternalData(Q=Q, quad_pen=quad_pen, eliminated=eliminated)

        # Eliminate
        blt_op = BLTOptimizationProblem(op)

        # Check remaining variables
        alg_vars = sorted([var.getName() for var in blt_op.getVariables(blt_op.REAL_ALGEBRAIC) if not var.isAlias()])
        assert len(alg_vars) == 3

        # Set up options
        dae_opts = op.optimize_options()
        dae_opts['init_traj'] = sim_res
        dae_opts['nominal_traj'] = sim_res
        dae_opts['external_data'] = external_data
        blt_opts = blt_op.optimize_options()
        blt_opts['init_traj'] = sim_res
        blt_opts['nominal_traj'] = sim_res
        blt_opts['external_data'] = external_data

        # Optimize and check result
        res_dae = op.optimize(options=dae_opts)
        res_blt = blt_op.optimize(options=blt_opts)
        assert_results(res_dae, cost_ref, u_norm_ref, u_norm_rtol=1e-2)
        assert_results(res_blt, cost_ref, u_norm_ref, u_norm_rtol=1e-2)
        N.testing.assert_allclose([res_dae['p1'][0], res_dae['p3'][0]], [2.022765, 0.992965], rtol=2e-3)
        N.testing.assert_allclose([res_blt['p1'][0], res_blt['p3'][0]], [2.022765, 0.992965], rtol=2e-3)
