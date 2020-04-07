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

# Import library for path manipulations
import os.path

# Import numerical libraries
import numpy as N
import matplotlib.pyplot as plt

def run_demo(with_plots=True):
    """
    Demonstrate how to optimize a VDP oscillator using CasADiInterface.
    """
    # Compile and load optimization problem
    from pyjmi import get_files_path, transfer_to_casadi_interface
    file_path = os.path.join(get_files_path(), "VDP.mop")
    op = transfer_to_casadi_interface("VDP_pack.VDP_Opt2", file_path)
    
    # Set algorithm options
    opts = op.optimize_options()
    opts['n_e'] = 30
    
    # Optimize
    res = op.optimize(options=opts)
    
    # Extract variable profiles
    x1 = res['x1']
    x2 = res['x2']
    u = res['u']
    time = res['time']
    
    assert N.abs(res.final('x1')) < 1e-3
    assert N.abs(res.final('x2')) < 1e-3
    
    # Plot
    if with_plots:
        plt.figure(1)
        plt.clf()
        plt.subplot(3, 1, 1)
        plt.plot(time, x1)
        plt.grid()
        plt.ylabel('x1')
        
        plt.subplot(3, 1, 2)
        plt.plot(time, x2)
        plt.grid()
        plt.ylabel('x2')
        
        plt.subplot(3, 1, 3)
        plt.plot(time, u)
        plt.grid()
        plt.ylabel('u')
        plt.xlabel('time')
        plt.show()

if __name__ == "__main__":
    run_demo()
