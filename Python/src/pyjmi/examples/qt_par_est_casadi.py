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

import os
from collections import OrderedDict

from scipy.io.matlab.mio import loadmat
import matplotlib.pyplot as plt
import numpy as N

from pymodelica import compile_fmu
from pyfmi import load_fmu
from pyjmi import transfer_optimization_problem, get_files_path
from pyjmi.optimization.casadi_collocation import ExternalData

def run_demo(with_plots=True):
    """
    This example demonstrates how to solve parameter estimation problmes.

    The system is tanks with connected inlets and outlets. The objective is to
    estimate the outlet area of two of the tanks based on measurement data.
    """
    # Compile and load FMU, which is used for simulation
    file_path = os.path.join(get_files_path(), "QuadTankPack.mop")
    model = load_fmu(compile_fmu('QuadTankPack.QuadTank', file_path))

    # Transfer problem to CasADi Interface, which is used for estimation
    op = transfer_optimization_problem("QuadTankPack.QuadTank_ParEstCasADi",
                                       file_path)

    # Set initial states in model, which are stored in the optimization problem
    x_0_names = ['x1_0', 'x2_0', 'x3_0', 'x4_0']
    x_0_values = op.get(x_0_names)
    model.set(x_0_names, x_0_values)
    
    # Load measurement data from file
    data_path = os.path.join(get_files_path(), "qt_par_est_data.mat")
    data = loadmat(data_path, appendmat=False)

    # Extract data series
    t_meas = data['t'][6000::100, 0] - 60
    y1_meas = data['y1_f'][6000::100, 0] / 100
    y2_meas = data['y2_f'][6000::100, 0] / 100
    y3_meas = data['y3_d'][6000::100, 0] / 100
    y4_meas = data['y4_d'][6000::100, 0] / 100
    u1 = data['u1_d'][6000::100, 0]
    u2 = data['u2_d'][6000::100, 0]
    
    # Plot measurements and inputs
    if with_plots:
        plt.close(1)
        plt.figure(1)
        plt.subplot(2, 2, 1)
        plt.plot(t_meas, y3_meas)
        plt.title('x3')
        plt.grid()
        plt.subplot(2, 2, 2)
        plt.plot(t_meas, y4_meas)
        plt.title('x4')
        plt.grid()
        plt.subplot(2, 2, 3)
        plt.plot(t_meas, y1_meas)
        plt.title('x1')
        plt.xlabel('t[s]')
        plt.grid()
        plt.subplot(2, 2, 4)
        plt.plot(t_meas, y2_meas)
        plt.title('x2')
        plt.xlabel('t[s]')
        plt.grid()

        plt.close(2)
        plt.figure(2)
        plt.subplot(2, 1, 1)
        plt.plot(t_meas, u1)
        plt.hold(True)
        plt.title('u1')
        plt.grid()
        plt.subplot(2, 1, 2)
        plt.plot(t_meas, u2)
        plt.title('u2')
        plt.xlabel('t[s]')
        plt.hold(True)
        plt.grid()

    # Build input trajectory matrix for use in simulation
    u = N.transpose(N.vstack([t_meas, u1, u2]))
    
    # Simulate model response with nominal parameter values
    res_sim = model.simulate(input=(['u1', 'u2'], u),
                             start_time=0., final_time=60.)

    # Load simulation result
    x1_sim = res_sim['x1']
    x2_sim = res_sim['x2']
    x3_sim = res_sim['x3']
    x4_sim = res_sim['x4']
    t_sim  = res_sim['time']
    u1_sim = res_sim['u1']
    u2_sim = res_sim['u2']

    # Check simulation results for testing purposes
    assert N.abs(res_sim.final('x1') - 0.05642485) < 1e-3
    assert N.abs(res_sim.final('x2') - 0.05510478) < 1e-3
    assert N.abs(res_sim.final('x3') - 0.02736532) < 1e-3
    assert N.abs(res_sim.final('x4') - 0.02789808) < 1e-3
    assert N.abs(res_sim.final('u1') - 6.0) < 1e-3
    assert N.abs(res_sim.final('u2') - 5.0) < 1e-3

    # Plot simulation result
    if with_plots:
        plt.figure(1)
        plt.subplot(2, 2, 1)
        plt.plot(t_sim, x3_sim)
        plt.subplot(2, 2, 2)
        plt.plot(t_sim, x4_sim)
        plt.subplot(2, 2, 3)
        plt.plot(t_sim, x1_sim)
        plt.subplot(2, 2, 4)
        plt.plot(t_sim, x2_sim)

        plt.figure(2)
        plt.subplot(2, 1, 1)
        plt.plot(t_sim, u1_sim, 'r')
        plt.subplot(2, 1, 2)
        plt.plot(t_sim, u2_sim, 'r')

    # Create external data object for optimization
    Q = N.diag([1., 1., 10., 10.])
    data_x1 = N.vstack([t_meas, y1_meas])
    data_x2 = N.vstack([t_meas, y2_meas])
    data_u1 = N.vstack([t_meas, u1])
    data_u2 = N.vstack([t_meas, u2])
    quad_pen = OrderedDict()
    quad_pen['x1'] = data_x1
    quad_pen['x2'] = data_x2
    quad_pen['u1'] = data_u1
    quad_pen['u2'] = data_u2
    external_data = ExternalData(Q=Q, quad_pen=quad_pen)

    # Set optimization options and optimize
    opts = op.optimize_options()
    opts['n_e'] = 60 # Number of collocation elements
    opts['external_data'] = external_data
    opts['init_traj'] = res_sim
    opts['nominal_traj'] = res_sim
    res = op.optimize(options=opts) # Solve estimation problem

    # Extract estimated values of parameters
    a1_opt = res.initial("a1")
    a2_opt = res.initial("a2")

    # Print and assert estimated parameter values
    print('a1: ' + str(a1_opt*1e4) + 'cm^2')
    print('a2: ' + str(a2_opt*1e4) + 'cm^2')
    a_ref = [0.02656702, 0.02713898]
    N.testing.assert_allclose(1e4 * N.array([a1_opt, a2_opt]),
                              a_ref, rtol=1e-4)

    # Load state profiles
    x1_opt = res["x1"]
    x2_opt = res["x2"]
    x3_opt = res["x3"]
    x4_opt = res["x4"]
    u1_opt = res["u1"]
    u2_opt = res["u2"]
    t_opt  = res["time"]

    # Plot estimated trajectories
    if with_plots:
        plt.figure(1)
        plt.subplot(2, 2, 1)
        plt.plot(t_opt, x3_opt, 'k')
        plt.subplot(2, 2, 2)
        plt.plot(t_opt, x4_opt, 'k')
        plt.subplot(2, 2, 3)
        plt.plot(t_opt, x1_opt, 'k')
        plt.subplot(2, 2, 4)
        plt.plot(t_opt, x2_opt, 'k')

        plt.figure(2)
        plt.subplot(2, 1, 1)
        plt.plot(t_opt, u1_opt, 'k')
        plt.subplot(2, 1, 2)
        plt.plot(t_opt, u2_opt, 'k')
        plt.show()

if __name__ == "__main__":
    run_demo()
