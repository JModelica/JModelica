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

# Import JModelica functions
from pyjmi import transfer_optimization_problem, get_files_path
from pymodelica.common.io import ResultDymolaTextual
from pymodelica import compile_fmu
from pyfmi import load_fmu
from pyjmi.symbolic_elimination import BLTOptimizationProblem

# Import other stuff
import matplotlib.pyplot as plt
import numpy as N
import os

def run_demo(with_plots=True):
    """
    This example is based on the multibody mechanics double pendulum example from the Modelica Standard Library (MSL).

    The MSL example has been modified by adding a torque on the first revolute joint of the pendulum as a top-level
    input. The considered optimization problem is to invert both pendulum bodies with bounded torque.

    This example needs linear solver MA27 to work.
    """
    # Simulate system with linear state feedback to generate initial guess
    file_paths = (os.path.join(get_files_path(), "DoublePendulum.mo"),
                  os.path.join(get_files_path(), "DoublePendulum.mop"))
    comp_opts = {'inline_functions': 'all', 'dynamic_states': False,
            'expose_temp_vars_in_fmu': True, 'equation_sorting': True, 'automatic_tearing': True}
    init_fmu = load_fmu(compile_fmu("DoublePendulum.Feedback", file_paths, compiler_options=comp_opts))
    init_res = init_fmu.simulate(final_time=3., options={'CVode_options': {'rtol': 1e-10}})
    
    # Set up optimization
    op = transfer_optimization_problem('Opt', file_paths, compiler_options=comp_opts)
    opts = op.optimize_options()
    opts['IPOPT_options']['linear_solver'] = "ma27"
    opts['n_e'] = 100
    opts['init_traj'] = init_res
    opts['nominal_traj'] = init_res

    # Symbolic elimination
    op = BLTOptimizationProblem(op)

    # Solve optimization problem
    res = op.optimize(options=opts)

    # Extract solution
    time = res['time']
    phi1 = res['pendulum.revolute1.phi']
    phi2 = res['pendulum.revolute2.phi']
    u = res['u']

    # Verify solution for testing purposes
    try:
        import casadi
    except:
        pass
    else:
        cost = float(res.solver.solver_object.output(casadi.NLP_SOLVER_F))
        N.testing.assert_allclose(cost, 9.632883808252522, rtol=5e-3)

    # Plot solution
    if with_plots:
        plt.close(1)
        plt.figure(1)
        plt.subplot(2, 1, 1)
        plt.plot(time, phi1, 'b')
        plt.plot(time, phi2, 'r')
        plt.legend(['$\phi_1$', '$\phi_2$'])
        plt.ylabel('$\phi$')
        plt.xlabel('$t$')
        plt.grid()
        
        plt.subplot(2, 1, 2)
        plt.plot(time, u)
        plt.ylabel('$u$')
        plt.xlabel('$t$')
        plt.grid()
        
        plt.show()

if __name__=="__main__":
    run_demo()
