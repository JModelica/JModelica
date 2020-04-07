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

import numpy as N
import matplotlib.pyplot as plt

from pymodelica import compile_fmu
from pyfmi import load_fmu

def run_demo(with_plots=True):
    """
    This is the crystallizer example from Bieglers book in section 10.3.
    """
    curr_dir = os.path.dirname(os.path.abspath(__file__));
        
    # Compile and load model
    fmu_name = compile_fmu("Crystallizer.SimulateCrystallizer", os.path.join(curr_dir, "files", "Crystallizer.mop"), 
                           compiler_options={"enable_variable_scaling":True})
    crys = load_fmu(fmu_name)
    
    # Simulate
    res = crys.simulate(final_time=25)

    time = res['time']
    Ls = res['c.Ls']
    Nc = res['c.Nc']
    L = res['c.L']
    Ac = res['c.Ac']
    Vc = res['c.Vc']
    Mc = res['c.Mc']
    Cc = res['c.Cc']
    Tc = res['c.Tc']
    
    Ta = res['Ta']
    Teq = res['c.Teq']
    deltaT = res['c.deltaT']
    Cbar = res['c.Cbar']
    
    Tj = res['c.Tj']

    if with_plots:
        plt.figure(1)
        plt.clf()
        plt.subplot(2,1,1)
        plt.plot(time,Ls)
        plt.grid()
        plt.subplot(2,1,2)
        plt.plot(time,Tj)
        plt.grid()
        plt.show()
        
        plt.figure(2)
        plt.clf()
        plt.subplot(4,1,1)
        plt.plot(time,Nc)
        plt.title('Nc')
        plt.grid()
        plt.subplot(4,1,2)
        plt.plot(time,L)
        plt.title('L')
        plt.grid()
        plt.subplot(4,1,3)
        plt.plot(time,Ac)
        plt.title('Ac')
        plt.grid()
        plt.subplot(4,1,4)
        plt.plot(time,Vc)
        plt.title('Vc')
        plt.grid()
        
        plt.figure(3)
        plt.clf()
        plt.subplot(4,1,1)
        plt.plot(time,Mc)
        plt.title('Mc')
        plt.grid()
        plt.subplot(4,1,2)
        plt.plot(time,Cc)
        plt.title('Cc')
        plt.grid()
        plt.subplot(4,1,3)
        plt.plot(time,Tc)
        plt.title('Tc')
        plt.grid()
        plt.subplot(4,1,4)
        plt.plot(time,Teq)
        plt.title('Teq')
        plt.grid()
        plt.show()

        plt.figure(4)
        plt.clf()
        plt.subplot(4,1,1)
        plt.plot(time,deltaT)
        plt.title('deltaT')
        plt.grid()
        plt.subplot(4,1,2)
        plt.plot(time,Cbar)
        plt.title('Cbar')
        plt.grid()
        plt.subplot(4,1,3)
        plt.plot(time,Teq-Tc)
        plt.title('Teq-Tc')
        plt.grid()
        plt.subplot(4,1,4)
        plt.plot(time,Ta)
        plt.title('Ta')
        plt.grid()
        plt.show()
        
    
            
if __name__ == "__main__":
    run_demo()

