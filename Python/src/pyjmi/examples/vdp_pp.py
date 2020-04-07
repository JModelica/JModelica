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

import os

import numpy as N
import pylab as p

from pymodelica import compile_fmu
from pyfmi import load_fmu

def run_demo(with_plots=True):
    """
    Demonstrate how to do batch simulations
    """

    curr_dir = os.path.dirname(os.path.abspath(__file__));

    # Define model file name and class name
    model_name = 'VDP_pack.VDP'
    mofile = curr_dir+'/files/VDP.mop'

    # Compile model
    fmu_name = compile_fmu(model_name,mofile)

    # Define initial conditions
    N_points = 11
    x1_0 = N.linspace(-3.,3.,N_points)
    x2_0 = N.zeros(N_points)

    # Open phase plane plot
    if with_plots:
        fig = p.figure()
        p.clf()
        p.hold(True)
        p.xlabel('x1')
        p.ylabel('x2')

    # Loop over initial conditions    
    for i in range(N_points):
    
        # Load model
        model = load_fmu(fmu_name)
    
        # Set initial conditions in model
        model.set('x1_0',x1_0[i])
        model.set('x2_0',x2_0[i])
        
        # Simulate 
        res = model.simulate(final_time=20)
        
        # Get simulation result
        x1=res['x1']
        x2=res['x2']
        
        # Plot simulation result in phase plane plot
        if with_plots:
            p.plot(x1, x2,'b')
    
    assert N.abs(res.final('x1') - 1.75293937)     < 1e-3
    assert N.abs(res.final('x2') + 3.98830742e-01) < 1e-3

    if with_plots:
        p.grid()
        p.show()

if __name__=="__main__":
    run_demo()
