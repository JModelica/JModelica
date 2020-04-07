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

# Import library for path manipulations
import os.path

# Import numerical libraries
import numpy as N
import matplotlib.pyplot as plt

# Import the needed JModelica.org Python methods
from pymodelica import compile_fmu
from pyfmi import load_fmu
from pyjmi import transfer_optimization_problem, get_files_path
from pyjmi.common.io import ResultDymolaTextual
from pyjmi.optimization.casadi_collocation import LocalDAECollocationAlgResult

# Import symbolic elimination methods
from pyjmi.symbolic_elimination import BLTOptimizationProblem, EliminationOptions

def run_demo(with_plots=True):
    """
    This example solves the optimization problem from pyjmi.examples.ccpp using the Python-based symbolic elimination.
    """
    # Load initial gues
    init_path = os.path.join(get_files_path(), "ccpp_init.txt")
    init_res = LocalDAECollocationAlgResult(result_data=ResultDymolaTextual(init_path))

    # Compile model
    class_name = "CombinedCycleStartup.Startup6"
    file_paths = (os.path.join(get_files_path(), "CombinedCycle.mo"),
                  os.path.join(get_files_path(), "CombinedCycleStartup.mop"))
    compiler_options = {'equation_sorting': True, 'automatic_tearing': True}
    op = transfer_optimization_problem("CombinedCycleStartup.Startup6", file_paths, compiler_options)

    # Set elimination options
    elim_opts = EliminationOptions()
    elim_opts['ineliminable'] = ['plant.sigma']
    if with_plots:
        elim_opts['draw_blt'] = True

    # Eliminate algebraic variables
    op = BLTOptimizationProblem(op, elim_opts)
    
    # Set collocation options
    opt_opts = op.optimize_options()
    opt_opts['init_traj'] = init_res
    opt_opts['nominal_traj'] = init_res

    # Solve the optimal control problem
    opt_res = op.optimize(options=opt_opts)
    
    # Extract variable profiles
    opt_plant_p = opt_res['plant.p']
    opt_plant_sigma = opt_res['plant.sigma']
    opt_plant_load = opt_res['plant.load']
    opt_time = opt_res['time']
    
    # Plot the optimized trajectories
    if with_plots:
        plt.close(2)
        plt.figure(2)
        plt.subplot(3, 1, 1)
        plt.plot(opt_time, opt_plant_p * 1e-6)
        plt.ylabel('evaporator pressure [MPa]')
        plt.grid(True)
        plt.title('Optimized trajectories')
        
        plt.subplot(3, 1, 2)
        plt.plot(opt_time, opt_plant_sigma * 1e-6)
        plt.grid(True)
        plt.ylabel('turbine thermal stress [MPa]')
        
        plt.subplot(3, 1, 3)
        plt.plot(opt_time, opt_plant_load)
        plt.grid(True)
        plt.ylabel('input load [1]')
        plt.xlabel('time [s]')       
    
    # Verify solution for testing purposes
    try:
        import casadi
    except:
        pass
    else:
        cost = float(opt_res.solver.solver_object.getOutput('f'))
        N.testing.assert_allclose(cost, 17492.465548193624, rtol=1e-5)

if __name__=="__main__":
    run_demo()
