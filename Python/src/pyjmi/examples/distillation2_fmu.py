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

def run_demo(with_plots=True):
    """
    Distillation2 model
    """

    curr_dir = os.path.dirname(os.path.abspath(__file__));

    fmu_name = compile_fmu("JMExamples.Distillation.Distillation2", 
    curr_dir+"/files/JMExamples.mo")
    dist2 = load_fmu(fmu_name)
    
    res = dist2.simulate(final_time=7200)

    # Extract variable profiles
    x16	= res['x[16]']
    x32	= res['x[32]']
    t	= res['time']
    
    print "t = ", repr(N.array(t))
    print "x16 = ", repr(N.array(x16))
    print "x32 = ", repr(N.array(x32))

    if with_plots:
        # Plot
        plt.figure(1)
        plt.plot(t,x16,t,x32)
        plt.grid()
        plt.ylabel('x')
        
        plt.xlabel('time')
        plt.show()

if __name__ == "__main__":
    run_demo()
