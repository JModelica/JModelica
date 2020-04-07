#!/usr/bin/env python 
# -*- coding: utf-8 -*-

# Copyright (C) 2014 Modelon AB
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

import os.path

import numpy as N
import matplotlib.pyplot as plt

from pymodelica import compile_fmu
from pyfmi import load_fmu
from pyjmi import get_files_path, transfer_optimization_problem

def run_demo(with_plots=True, use_ma57=True, latex_plots=False):
    """
    This example is based on a binary distillation column. The model has 42
    states, 1083 algebraic variables and 2 control variables. The task is to
    get back to the desired steady-state after a short reflux breakdown.
    
    The example consists of the following steps:
    
    1.  Find the desired steady state by simulating ad infinitum with constant
        inputs.
    
    2.  Simulate the short reflux breakdown.

    3.  Simulate post-breakdown with constant inputs to generate an initial
        guess.

    4.  Solve the optimal control problem to get back to the desired steady
        state after the breakdown.
       
    5.  Verify the optimal trajectories by simulation.
    
    The model was developed in Moritz Diehl's PhD thesis:
    
    @PHDTHESIS{diehl2002phd,
      author = {Diehl, Moritz},
      title = {Real-Time Optimization for Large Scale Nonlinear Processes},
      school = {Heidelberg University},
      year = {2002},
      type = {Ph.{D}. thesis}
    }

    The Modelica implementation was based on the MATLAB implementation from
    John Hedengren's nonlinear model library available at:

    http://www.hedengren.net/research/models.htm

    This example needs one of the linear solvers MA27 or MA57 to work.
    The precense of MA27 or MA57 is not detected in the example, so if only 
    MA57 is present, then True must be passed in the use_ma57 argument.
    """
    ### 1. Find the desired steady state by simulating with constant inputs
    # Compile model
    file_name = (os.path.join(get_files_path(), "JMExamples.mo"),
                 os.path.join(get_files_path(), "JMExamples_opt.mop"))
    ss_fmu = compile_fmu("JMExamples.Distillation.Distillation4",
                         file_name)
    ss_model = load_fmu(ss_fmu)

    # Set constant input and simulate
    [L_vol_ref] = ss_model.get('Vdot_L1_ref')
    [Q_ref] = ss_model.get('Q_elec_ref')
    ss_res = ss_model.simulate(final_time=500000.,
                               input=(['Q_elec', 'Vdot_L1'],
                                      lambda t: [Q_ref, L_vol_ref]))

    # Extract results
    ss_T_14 = ss_res['Temp[28]']
    T_14_ref = ss_T_14[-1]
    ss_T_28 = ss_res['Temp[14]']
    T_28_ref = ss_T_28[-1]
    ss_L_vol = ss_res['Vdot_L1']
    ss_Q = ss_res['Q_elec']
    ss_t = ss_res['time']
    abs_zero = ss_model.get('absolute_zero')
    L_fac = 1e3 * 3.6e3
    Q_fac = 1e-3

    print('T_14_ref: %.6f' % T_14_ref)
    print('T_28_ref: %.6f' % T_28_ref)

    # Plot simulation
    if with_plots:
        # Plotting options
        plt.rcParams.update(
            {'font.serif': ['Times New Roman'],
             'text.usetex': latex_plots,
             'font.family': 'serif',
             'axes.labelsize': 20,
             'legend.fontsize': 16,
             'xtick.labelsize': 12,
             'font.size': 20,
             'ytick.labelsize': 14})
        pad = 2
        padplus = plt.rcParams['axes.labelsize'] / 2

        # Define function for custom axis scaling in plots
        def scale_axis(figure=plt, xfac=0.01, yfac=0.05):
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

        # Define function for plotting the important quantities
        def plot_solution(t, T_28, T_14, Q, L_vol, fig_index, title):
            plt.close(fig_index)
            fig = plt.figure(fig_index)
            fig.subplots_adjust(wspace=0.35)

            ax = fig.add_subplot(2, 2, 1)
            bx = fig.add_subplot(2, 2, 2)
            cx = fig.add_subplot(2, 2, 3, sharex=ax)
            dx = fig.add_subplot(2, 2, 4, sharex=bx)
            width = 3

            ax.plot(t, T_28 + abs_zero, lw=width)
            ax.hold(True)
            ax.plot(t[[0, -1]], 2 * [T_28_ref + abs_zero], 'g--')
            ax.hold(False)
            ax.grid()
            if latex_plots:
                label = '$T_{28}$ [$^\circ$C]'
            else:
                label = 'T28'
            ax.set_ylabel(label, labelpad=pad)
            plt.setp(ax.get_xticklabels(), visible=False)
            scale_axis(ax)

            bx.plot(t, T_14 + abs_zero, lw=width)
            bx.hold(True)
            bx.plot(t[[0, -1]], 2 * [T_14_ref + abs_zero], 'g--')
            bx.hold(False)
            bx.grid()
            if latex_plots:
                label = '$T_{14}$ [$^\circ$C]'
            else:
                label = 'T14'
            ax.set_ylabel(label, labelpad=pad)
            plt.setp(bx.get_xticklabels(), visible=False)
            scale_axis(bx)

            cx.plot(t, Q * Q_fac, lw=width)
            cx.hold(True)
            cx.plot(t[[0, -1]], 2 * [Q_ref * Q_fac], 'g--')
            cx.hold(False)
            cx.grid()
            if latex_plots:
                ylabel = '$Q$ [kW]'
                xlabel = '$t$ [s]'
            else:
                ylabel = 'Q'
                xlabel = 't'
            cx.set_ylabel(ylabel, labelpad=pad)
            cx.set_xlabel(xlabel)
            scale_axis(cx)

            dx.plot(t, L_vol * L_fac, lw=width)
            dx.hold(True)
            dx.plot(t[[0, -1]], 2 * [L_vol_ref * L_fac], 'g--')
            dx.hold(False)
            dx.grid()
            if latex_plots:
                ylabel = '$L_{\Large \mbox{vol}}$ [l/h]'
                xlabel = '$t$ [s]'
            else:
                ylabel = 'L'
                xlabel = 't'
            dx.set_ylabel(ylabel, labelpad=pad)
            dx.set_xlabel(xlabel)
            scale_axis(dx)

            fig.suptitle(title)
            plt.show()

        # Call plot function
        plot_solution(ss_t, ss_T_28, ss_T_14, ss_Q, ss_L_vol, 1,
                      'Simulated trajectories to find steady state')

        # Plot steady state temperatures
        plt.close(2)
        plt.figure(2)
        plt.hold(True)
        for i in xrange(1, 43):
            temperature = (ss_res.final('Temp[' + `i` + ']') +
                           ss_res.initial('absolute_zero'))
            plt.plot(temperature, 43 - i, 'ko')
        plt.title('Steady state temperatures')
        if latex_plots:
            label = '$T$ [$^\circ$C]'
        else:
            label = 'T'
        plt.xlabel(label)
        plt.ylabel('Tray index [1]')

    ### 2. Simulate the short reflux breakdown
    # Compile model
    model_fmu = compile_fmu("JMExamples.Distillation.Distillation4", file_name)
    break_model = load_fmu(model_fmu)

    # Set initial values
    break_model.set('Q_elec_ref', Q_ref)
    break_model.set('Vdot_L1_ref', L_vol_ref)
    for i in xrange(1, 43):
        break_model.set('xA_init[%d]' % i, ss_res.final('xA[%d]' % i))

    # Define input function for broken reflux
    def input_function(time):
        if time < 700.:
            return [Q_ref, L_vol_ref]
        else:
            return [Q_ref, 0.5 / 1000. / 3600.]

    # Simulate and extract results
    break_res = break_model.simulate(
        final_time=1000., input=(['Q_elec', 'Vdot_L1'], input_function))
    break_T_14 = break_res['Temp[28]']
    break_T_28 = break_res['Temp[14]']
    break_L_vol = break_res['Vdot_L1']
    break_Q = break_res['Q_elec']
    break_t = break_res['time']

    # Plot simulation
    if with_plots:
        plot_solution(break_t, break_T_28, break_T_14, break_Q, break_L_vol, 3,
                      'Simulated short reflux breakdown')

    ### 3. Simulate post-breakdown with constant inputs to find initial guess
    # Compile the model
    ref_model = load_fmu(model_fmu)

    # Set initial conditions for post breakdown
    ref_model.set('Q_elec_ref', Q_ref)
    ref_model.set('Vdot_L1_ref', L_vol_ref)
    for i in xrange(1, 43):
        ref_model.set('xA_init[' + `i` + ']',
                      break_res.final('xA[' + `i` + ']'))

    # Simulate
    ref_res = ref_model.simulate(final_time=5000.,
                                 input=(['Q_elec', 'Vdot_L1'],
                                        lambda t: [Q_ref, L_vol_ref]))

    # Extract results
    ref_T_14 = ref_res['Temp[28]']
    ref_T_28 = ref_res['Temp[14]']
    ref_L_vol = ref_res['Vdot_L1']
    ref_Q = ref_res['Q_elec']
    ref_t = ref_res['time']

    # Plot initial guess
    if with_plots:
        plot_solution(ref_t, ref_T_28, ref_T_14, ref_Q, ref_L_vol, 4,
                      'Initial guess')

    ### 4. Solve optimal control problem
    # Compile optimization problem
    compiler_options={"common_subexp_elim":False}
    op = transfer_optimization_problem("JMExamples_opt.Distillation4_Opt",
                                       file_name, compiler_options)

    # Set initial conditions for post breakdown
    op.set('Q_elec_ref', Q_ref)
    op.set('Vdot_L1_ref', L_vol_ref)
    for i in xrange(1, 43):
        op.set('xA_init[' + `i` + ']', break_res.final('xA[' + `i` + ']'))

    # Set optimization options and solve
    opts = op.optimize_options()
    opts['init_traj'] = ref_res
    opts['nominal_traj'] = ref_res
    opts['n_e'] = 15
    opts['IPOPT_options']['linear_solver'] = "ma57" if use_ma57 else "ma27"
    opts['IPOPT_options']['mu_init'] = 1e-3
    opt_res = op.optimize(options=opts)

    # Extract results
    opt_T_14 = opt_res['Temp[28]']
    opt_T_28 = opt_res['Temp[14]']
    opt_L_vol = opt_res['Vdot_L1']
    opt_Q = opt_res['Q_elec']
    opt_t = opt_res['time']

    # Plot
    if with_plots:
        plot_solution(opt_t, opt_T_28, opt_T_14, opt_Q, opt_L_vol, 5,
                      'Optimal control')

    # Verify cost for testing purposes
    try:
        import casadi
    except:
        pass
    else:
        cost = float(opt_res.solver.solver_object.output(casadi.NLP_SOLVER_F))
        N.testing.assert_allclose(cost, 4.611038777467e-02, rtol=1e-2)

    ### 5. Verify optimization discretization by simulation
    verif_model = load_fmu(model_fmu)

    # Set initial conditions for post breakdown
    verif_model.set('Q_elec_ref', Q_ref)
    verif_model.set('Vdot_L1_ref', L_vol_ref)
    for i in xrange(1, 43):
        verif_model.set('xA_init[' + `i` + ']',
                        break_res.final('xA[' + `i` + ']'))

    # Simulate with optimal input
    verif_res = verif_model.simulate(final_time=5000.,
                                     input=opt_res.get_opt_input())

    # Extract results
    verif_T_14 = verif_res['Temp[28]']
    verif_T_28 = verif_res['Temp[14]']
    verif_L_vol = verif_res['Vdot_L1']
    verif_Q = verif_res['Q_elec']
    verif_t = verif_res['time']

    # Plot verifying simulation
    if with_plots:
        plot_solution(verif_t, verif_T_28, verif_T_14, verif_Q, verif_L_vol, 6,
                      'Simulation with optimal input')

if __name__ == "__main__":
    run_demo(True)
