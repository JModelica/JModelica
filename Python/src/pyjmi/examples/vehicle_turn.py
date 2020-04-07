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

# Import JModelica functions
from pyjmi import transfer_optimization_problem, get_files_path
from pyjmi.optimization.casadi_collocation import BlockingFactors
from pymodelica.common.io import ResultDymolaTextual
from pyjmi.symbolic_elimination import BLTOptimizationProblem

# Import other stuff
import matplotlib.pyplot as plt
import numpy as N
import os

def run_demo(with_plots=True, use_ma57=True):
    """
    This example is based on a single-track model of a car with tire dynamics.
    The optimization problem is to minimize the duration of a 90-degree turn
    with actuators on the steer angle and front and rear wheel torques.

    This example also demonstrates the usage of blocking factors, to enforce
    piecewise constant inputs.

    This example needs one of the linear solvers MA27 or MA57 to work.
    The precense of MA27 or MA57 is not detected in the example, so if only 
    MA57 is present, then True must be passed in the use_ma57 argument.
    """
    # Set up optimization
    mop_path = os.path.join(get_files_path(), "vehicle_turn.mop")
    op = transfer_optimization_problem('Turn', mop_path)
    opts = op.optimize_options()
    opts['IPOPT_options']['linear_solver'] = "ma57" if use_ma57 else "ma27"
    opts['IPOPT_options']['tol'] = 1e-9
    opts['n_e'] = 60

    # Set blocking factors
    factors = {'delta_u': opts['n_e'] / 2 * [2],
               'Twf_u': opts['n_e'] / 4 * [4],
               'Twr_u': opts['n_e'] / 4 * [4]}
    rad2deg = 180. / (2*N.pi)
    du_bounds = {'delta_u': 2. / rad2deg}
    bf = BlockingFactors(factors, du_bounds=du_bounds)
    opts['blocking_factors'] = bf

    # Use Dymola simulation result as initial guess
    init_path = os.path.join(get_files_path(), "vehicle_turn_dymola.txt")
    init_guess = ResultDymolaTextual(init_path)
    opts['init_traj'] = init_guess

    # Symbolic elimination
    op = BLTOptimizationProblem(op)

    # Solve optimization problem
    res = op.optimize(options=opts)

    # Extract solution
    time = res['time']
    X = res['car.X']
    Y = res['car.Y']
    delta = res['delta_u']
    Twf = res['Twf_u']
    Twr = res['Twr_u']
    Ri = op.get('Ri')
    Ro = op.get('Ro')

    # Verify result
    N.testing.assert_allclose(time[-1], 4.0118, rtol=5e-3)

    # Plot solution
    if with_plots:
        # Plot road
        plt.close(1)
        plt.figure(1)
        plt.plot(X, Y, 'b')
        xi = N.linspace(0., Ri, 100)
        xo = N.linspace(0., Ro, 100)
        yi = (Ri**8 - xi**8) ** (1./8.)
        yo = (Ro**8 - xo**8) ** (1./8.)
        plt.plot(xi, yi, 'r--')
        plt.plot(xo, yo, 'r--')
        plt.xlabel('X [m]')
        plt.ylabel('Y [m]')
        plt.legend(['position', 'road'], loc=3)

        # Plot inputs
        plt.close(2)
        plt.figure(2)
        plt.plot(time, delta * rad2deg, drawstyle='steps-post')
        plt.plot(time, Twf * 1e-3, drawstyle='steps-post')
        plt.plot(time, Twr * 1e-3, drawstyle='steps-post')
        plt.xlabel('time [s]')
        plt.legend(['delta [deg]', 'Twf [kN]', 'Twr [kN]'], loc=4)
        plt.show()

if __name__=="__main__":
    run_demo()
