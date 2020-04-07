#!/usr/bin/env python 
# -*- coding: utf-8 -*-

# Copyright (C) 2010 Modelon AB
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
import os

# Import numerical libraries
import numpy as N
import matplotlib.pyplot as plt

# Import the JModelica.org Python packages
from pymodelica import compile_fmu
from pyfmi import load_fmu

def run_demo(with_plots=True,with_blocking_factors = False):
    """ 
    FMU simulation of a distillation column. The distillation column model is 
    documented in the paper:

    @Article{hahn+02,
    title={An improved method for nonlinear model reduction using balancing of 
        empirical gramians},
    author={Hahn, J. and Edgar, T.F.},
    journal={Computers and Chemical Engineering},
    volume={26},
    number={10},
    pages={1379-1397},
    year={2002}
    }
    """
    
    curr_dir = os.path.dirname(os.path.abspath(__file__));

    # Compile the stationary initialization model into a FMU
    fmu_name = compile_fmu('DISTLib.Examples.Simulation', 
        os.path.join(curr_dir, 'files', 'DISTLib.mo'))

    # Load a model instance into Python
    model = load_fmu(fmu_name)
    
    # Simulate
    res = model.simulate(final_time=200)

    x_16 = res['binary_dist_initial.x[16]']
    y_16 = res['binary_dist_initial.y[16]']
    x_32 = res['binary_dist_initial.x[32]']
    y_32 = res['binary_dist_initial.y[32]']
    t = res['time']

    assert N.abs(res.final('binary_dist_initial.x[16]') - 0.49931368) < 1e-3
    assert N.abs(res.final('binary_dist_initial.y[16]') - 0.61473464) < 1e-3
    assert N.abs(res.final('binary_dist_initial.x[32]') - 0.18984724) < 1e-3
    assert N.abs(res.final('binary_dist_initial.y[32]') - 0.27269352) < 1e-3

    # Plot the results
    if with_plots:
        plt.figure(1)
        plt.clf()
        plt.subplot(2,1,1)
        plt.plot(t,x_16,'b')
        plt.hold(True)
        plt.plot(t,x_32,'b')
        plt.title('Liquid composition')
        plt.grid(True)
        plt.subplot(2,1,2)
        plt.plot(t,y_16,'b')
        plt.hold(True)
        plt.plot(t,y_32,'b')
        plt.title('Vapor composition')
        plt.grid(True)
        plt.show()

if __name__ == "__main__":
    run_demo()

