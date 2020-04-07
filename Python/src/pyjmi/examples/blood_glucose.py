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
    Simulation of a model that predicts the blood glucose levels of a type-I 
    diabetic. The objective is to predict the relationship between insulin 
    injection and blood glucose levels.
    
    Reference:
     S. M. Lynch and B. W. Bequette, Estimation based Model Predictive Control of Blood Glucose in 
     Type I Diabetes: A Simulation Study, Proc. 27th IEEE Northeast Bioengineering Conference, IEEE, 2001.
     
     S. M. Lynch and B. W. Bequette, Model Predictive Control of Blood Glucose in type I Diabetics 
     using Subcutaneous Glucose Measurements, Proc. ACC, Anchorage, AK, 2002. 
    """
    
    curr_dir = os.path.dirname(os.path.abspath(__file__));

    fmu_name1 = compile_fmu("JMExamples.BloodGlucose.BloodGlucose1", 
        os.path.join(curr_dir, 'files', 'JMExamples.mo'))
    bg = load_fmu(fmu_name1)
    
    opts = bg.simulate_options()
    opts["CVode_options"]["rtol"] = 1e-6
    
    res = bg.simulate(final_time=400, options=opts)

    # Extract variable profiles
    G = res['G']
    X = res['X']
    I = res['I']
    t = res['time']
    
    assert N.abs(res.final('G') - 19.77650) < 1e-3
    assert N.abs(res.final('X') - 14.97815) < 1e-3
    assert N.abs(res.final('I') - 2.7)      < 1e-3

    if with_plots:
        plt.figure(1)
        
        plt.subplot(2,2,1)
        plt.plot(t, G)
        plt.title('Plasma Glucose Conc')
        plt.grid(True)
        plt.ylabel('Plasma Glucose Conc. (mmol/L)')
        plt.xlabel('time')
        
        plt.subplot(2,2,2)
        plt.plot(t, X)
        plt.title('Plasma Insulin Conc.')
        plt.grid(True)
        plt.ylabel('Plasma Insulin Conc. (mu/L)')
        plt.xlabel('time')
        
        plt.subplot(2,2,3)
        plt.plot(t, I)
        plt.title('Plasma Insulin Conc.')
        plt.grid(True)
        plt.ylabel('Plasma Insulin Conc. (mu/L)')
        plt.xlabel('time')
        
        plt.show()

if __name__ == "__main__":
    run_demo()
