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
import os.path

# Import numerical libraries
import numpy as N
import matplotlib.pyplot as plt

# Import the JModelica.org Python packages
from pymodelica import compile_fmu
from pyfmi import load_fmu
from pyjmi import transfer_optimization_problem, get_files_path

def run_demo(with_plots=True):
    """
    Demonstrate how to solve a minimum time dynamic optimization problem based 
    on a Van der Pol oscillator system.
    """

    file_paths = (os.path.join(get_files_path(), "JMExamples_opt.mop"),
                  os.path.join(get_files_path(), "JMExamples.mo"))
    vdp = transfer_optimization_problem("JMExamples_opt.VDP_Opt_Min_Time", file_paths)
    res = vdp.optimize()
    
    # Extract variable profiles
    x1=res['x1']
    x2=res['x2']
    u=res['u']
    t=res['time']

    assert N.abs(res.final('finalTime') - 2.2811587) < 1e-3

    if with_plots:
        # Plot
        plt.figure(1)
        plt.clf()
        plt.subplot(311)
        plt.plot(t,x1)
        plt.grid()
        plt.ylabel('x1')
        
        plt.subplot(312)
        plt.plot(t,x2)
        plt.grid()
        plt.ylabel('x2')
        
        plt.subplot(313)
        plt.plot(t,u,'x-')
        plt.grid()
        plt.ylabel('u')
        plt.xlabel('time')
        plt.show()

if __name__ == "__main__":
    run_demo()
