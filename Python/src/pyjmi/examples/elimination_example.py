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

# Import JModelica.org functionality
from pyjmi import transfer_optimization_problem, get_files_path

# Import elimination functionality
from pyjmi.symbolic_elimination import BLTOptimizationProblem, EliminationOptions

# Import other stuff
import matplotlib.pyplot as plt
import numpy as N
import os

def run_demo(with_plots=True):
    """
    Demonstrate symbolic elimination.
    """
    # Compile and load optimization problem
    file_path = os.path.join(get_files_path(), "JMExamples_opt.mop")
    compiler_options = {'equation_sorting': True, 'automatic_tearing': True}
    op = transfer_optimization_problem("JMExamples_opt.EliminationExample", file_path, compiler_options)

    # Set up and perform elimination
    elim_opts = EliminationOptions()
    elim_opts['ineliminable'] = ['y1'] # Provide list of variable names to not eliminate
    # Variables with any of the following properties are recommended to mark as ineliminable:
        # Potentially active bounds
        # Occurring in the objective or constraints
        # Numerically unstable pivots (difficult to predict)
    if with_plots:
        elim_opts['draw_blt'] = True
        elim_opts['draw_blt_strings'] = True
    op = BLTOptimizationProblem(op, elim_opts)
    
    # Optimize and extract solution
    res = op.optimize()
    x1 = res['x1']
    x2 = res['x2']
    y1 = res['y1']
    u = res['u']
    time = res['time']
    
    # Plot
    if with_plots:
        plt.figure(1)
        plt.clf()
        plt.subplot(4, 1, 1)
        plt.plot(time, x1)
        plt.grid()
        plt.ylabel('x1')
        
        plt.subplot(4, 1, 2)
        plt.plot(time, x2)
        plt.grid()
        plt.ylabel('x2')
        
        plt.subplot(4, 1, 3)
        plt.plot(time, y1)
        plt.grid()
        plt.ylabel('y1')
        
        plt.subplot(4, 1, 4)
        plt.plot(time, u)
        plt.grid()
        plt.ylabel('u')
        plt.xlabel('time')
        plt.show()

    # Verify solution for testing purposes
    try:
        import casadi
    except:
        pass
    else:
        cost = float(res.solver.solver_object.getOutput('f'))
        N.testing.assert_allclose(cost, 1.0818134, rtol=1e-4)

if __name__ == "__main__":
    run_demo()
