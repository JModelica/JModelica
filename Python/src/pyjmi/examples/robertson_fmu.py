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

import os.path

import numpy as N
import matplotlib.pyplot as plt
import nose

from pymodelica import compile_fmu
from pyfmi import load_fmu

def run_demo(with_plots=True):
    """
    Demonstrates how to use an JMODELICA generated FMU for sensitivity
    calculations.
    """
    curr_dir = os.path.dirname(os.path.abspath(__file__));

    fmu_name = compile_fmu("Robertson", curr_dir+"/files/Robertson.mo")
        
    model = load_fmu(fmu_name)
        
    # Get and set the options
    opts = model.simulate_options()
    opts['sensitivities'] = ["p1","p2","p3"]
    opts['ncp'] = 400

    #Simulate
    res = model.simulate(final_time=4, options=opts)

    dy1dp1 = res['dy1/dp1']
    dy2dp1 = res['dy2/dp1']
    time = res['time']
        
    nose.tools.assert_almost_equal(dy1dp1[40], -0.35590, 3)
    nose.tools.assert_almost_equal(dy2dp1[40],  3.9026e-04, 6)
    
    if with_plots:
        plt.plot(time, dy1dp1, time, dy2dp1)
        plt.legend(('dy1/dp1', 'dy2/dp1'))
        plt.show()
    

if __name__=="__main__":
    run_demo()
