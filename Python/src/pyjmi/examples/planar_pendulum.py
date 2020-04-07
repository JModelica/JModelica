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
    Example demonstrating how to use index reduction.
    """

    curr_dir = os.path.dirname(os.path.abspath(__file__));

    # Compile model
    fmu_name = compile_fmu("Pendulum_pack.PlanarPendulum", 
        curr_dir+"/files/Pendulum_pack.mop",compiler='optimica')

    # Load model
    model = load_fmu(fmu_name)
    
    # Options
    opts = model.simulate_options()
    opts["CVode_options"]["rtol"] = 1e-6
    
    # Load result file
    res = model.simulate(final_time=10., options=opts)

    x = res['x']
    st = res['st']
    ct = res['ct']
    err = res['err']
    y = res['y']
    vx = res['vx']
    vy = res['vy']
    t = res['time']
    maxerr = N.max(err)

    if maxerr > 1e-6:
        print "Maximum error: ", maxerr 
        assert maxerr < 1e-4
    
    assert N.abs(res.final('x') - 0.38735171)       < 1e-3
    assert N.abs(res.final('st') - 0.38733358)      < 1e-3
    assert N.abs(res.final('ct') + 0.92193964)      < 1e-3
    assert N.abs(res.final('err') - 1.96716163e-05) < 1e-3
    assert N.abs(res.final('y') + 0.92193202)       < 1e-3
    assert N.abs(res.final('vx') - 6.04839823e-01)  < 1e-3
    assert N.abs(res.final('vy') - 2.54124747e-01)  < 1e-3

    if with_plots:
        plt.figure(1)
        plt.subplot(3,1,1)
        plt.plot(t,x,t,y)
        plt.grid(True)
        plt.legend(['x','y'])
        plt.subplot(3,1,2)
        plt.plot(t,vx,t,vy)
        plt.grid(True)
        plt.legend(['vx','vy'])
        plt.subplot(3,1,3)
        plt.plot(t,err)
        plt.grid(True)
        plt.legend(['err'])
        plt.xlabel('time [s]')
        plt.show()
