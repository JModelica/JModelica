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
    Example demonstrating simulation of a mechanical system with friction
    from the Modelica standard library.
    """

    # Compile model
    fmu_name = compile_fmu("Modelica.Mechanics.Rotational.Examples.CoupledClutches",())

    # Load model
    model = load_fmu(fmu_name)

    # Get options
    opts = model.simulate_options()

    # Set tolerances
    opts['CVode_options']['atol'] = 1e-6
    opts['CVode_options']['rtol'] = 1e-6

    # Load result file
    res = model.simulate(final_time=3., options=opts)

    w1 = res['J1.w']
    w2 = res['J2.w']
    w3 = res['J3.w']
    w4 = res['J4.w']
    tau_c1 = res['clutch1.tau']
    tau_c2 = res['clutch2.tau']
    tau_c3 = res['clutch3.tau']
    t = res['time']

    assert N.abs(res.final('J3.w') - (2.46382546506)) < 1e-3

    if with_plots:
        plt.figure(1)
        plt.subplot(2,1,1)
        plt.plot(t,w1,t,w2,t,w3,t,w4)
        plt.grid(True)
        plt.legend(['J1.w','J2.w','J3.w','J4.w'])
        plt.subplot(2,1,2)
        plt.plot(t,tau_c1,t,tau_c3,t,tau_c3)
        plt.grid(True)
        plt.legend(['clutch1.tau','clutch2.tau','clutch3.tau'])
        plt.xlabel('time [s]')
        plt.show()

if __name__=="__main__":
    run_demo()
