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
    Distillation4 model
    """

    curr_dir = os.path.dirname(os.path.abspath(__file__));

    fmu_name = compile_fmu("JMExamples.Distillation.Distillation4", 
                           curr_dir+"/files/JMExamples.mo")
    dist4 = load_fmu(fmu_name)

    # Set constant inputs and simulate
    [L_vol_ref] = dist4.get('Vdot_L1_ref')
    [Q_ref] = dist4.get('Q_elec_ref')
    res = dist4.simulate(final_time=6000,
                         input=(['Q_elec', 'Vdot_L1'],
                                lambda t: [Q_ref, L_vol_ref]))

    # Extract variable profiles
    x20	= res['xA[20]']
    x40	= res['xA[40]']
    T20	= res['Temp[20]']
    T40	= res['Temp[40]']
    V20	= res['V[20]']
    V40	= res['V[40]']
    t	= res['time']
    
    print "t = ", repr(N.array(t))
    print "x20 = ", repr(N.array(x20))
    print "x40 = ", repr(N.array(x40))
	
    print "T20 = ", repr(N.array(T20))
    print "T40 = ", repr(N.array(T40))

    print "V20 = ", repr(N.array(V20))
    print "V40 = ", repr(N.array(V40))
	
    if with_plots:
        # Plot
        plt.figure(1)
        plt.subplot(321)
        plt.plot(t,x20)
        plt.grid()
        plt.ylabel('x[20]')
        plt.subplot(322)
        plt.plot(t,x40)
        plt.grid()
        plt.ylabel('x[40]')
        
        plt.subplot(323)
        plt.plot(t,T20)
        plt.grid()
        plt.ylabel('T[20]')
        plt.subplot(324)
        plt.plot(t,T40)
        plt.grid()
        plt.ylabel('T[40]')
        
        plt.subplot(325)
        plt.plot(t,V20)
        plt.grid()
        plt.ylabel('V[20]')
        plt.subplot(326)
        plt.plot(t,V40)
        plt.grid()
        plt.ylabel('V[40]')
        
        plt.xlabel('time')
        plt.show()

if __name__ == "__main__":
    run_demo()
