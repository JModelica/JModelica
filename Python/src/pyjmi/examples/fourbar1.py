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
from pyjmi.optimization.casadi_collocation import LocalDAECollocationAlgResult
from pymodelica.common.io import ResultDymolaTextual
from pymodelica import compile_fmu
from pyfmi import load_fmu

# Import other stuff
import matplotlib.pyplot as plt
import numpy as N
import os

def run_demo(with_plots=True):
    """
    This example is based on the multibody mechanics fourbar1 example from the Modelica Standard Library (MSL).

    The MSL example has been modified by adding a torque on the first revolute joint of the pendulum as a top-level
    input. The considered optimization problem is to control the translation along the prismatic joint at the other end
    of the closed kinematic loop.

    This example needs the linear solver MA57 to work.
    """
    # Compile simulation model
    file_paths = (os.path.join(get_files_path(), "Fourbar1.mo"),
                  os.path.join(get_files_path(), "Fourbar1.mop"))
    comp_opts = {'inline_functions': 'all', 'dynamic_states': False, 'expose_temp_vars_in_fmu': True}
    model = load_fmu(compile_fmu('Fourbar1.Fourbar1Sim', file_paths, compiler_options=comp_opts))
    
    # Load trajectories that are optimal subject to a smaller torque constraint and use to generate initial guess
    init_path = os.path.join(get_files_path(), "fourbar1_init.txt")
    init_res = LocalDAECollocationAlgResult(result_data=ResultDymolaTextual(init_path))
    t = init_res['time']
    u = init_res['u']
    u_traj = ('u', N.transpose(N.vstack((t, u))))
    sim_res = model.simulate(final_time=1.0, input=u_traj)
    
    # Set up optimization
    op = transfer_optimization_problem('Opt', file_paths, compiler_options=comp_opts)
    opts = op.optimize_options()
    opts['IPOPT_options']['linear_solver'] = "ma57"
    opts['IPOPT_options']['ma57_pivtol'] = 1e-3
    opts['IPOPT_options']['ma57_automatic_scaling'] = "yes"
    opts['IPOPT_options']['mu_strategy'] = "adaptive"
    opts['n_e'] = 20
    opts['init_traj'] = sim_res
    opts['nominal_traj'] = sim_res

    # Solve optimization problem
    res = op.optimize(options=opts)

    # Extract solution
    time = res['time']
    s = res['fourbar1.j2.s']
    phi = res['fourbar1.j1.phi']
    u = res['u']

    # Verify solution for testing purposes
    try:
        import casadi
    except:
        pass
    else:
        cost = float(res.solver.solver_object.output(casadi.NLP_SOLVER_F))
        N.testing.assert_allclose(cost, 1.0455646e-03, rtol=5e-3)

    # Plot solution
    if with_plots:
        plt.close(1)
        plt.figure(1)
        plt.subplot(3, 1, 1)
        plt.plot(time, s)
        plt.ylabel('$s$')
        plt.xlabel('$t$')
        plt.grid()
        
        plt.subplot(3, 1, 2)
        plt.plot(time, s)
        plt.ylabel('$\phi$')
        plt.xlabel('$t$')
        plt.grid()
        
        plt.subplot(3, 1, 3)
        plt.plot(time, u)
        plt.ylabel('$u$')
        plt.xlabel('$t$')
        plt.grid()
        
        plt.show()

if __name__=="__main__":
    run_demo()
