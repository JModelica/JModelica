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
import logging

import numpy as N
import pylab as p
import matplotlib.pyplot as plt

from pymodelica import compile_fmu
from pyfmi import load_fmu

def run_demo(with_plots=True):
    """
    An example on how to simulate a model using the DAE simulator. Also writes 
    information to a file.

    NOTICE: The script does not run since the compiler does not support all 
    constructs needed.
    """

    curr_dir = os.path.dirname(os.path.abspath(__file__));

    # Compile model
    fmu_name = compile_fmu("PyMBSModels.CraneCrab_recursive_der_state_Test", 
        os.path.join(curr_dir, "files", "PyMBSModels.mo"))

    # Load model
    model = load_fmu(fmu_name)

    # Load result file
    res = model.simulate(final_time=10.)

    q1 = res['crane.q[1]']
    q2 = res['crane.q[2]']
    qd1 = res['crane.qd[1]']
    qd2 = res['crane.qd[2]']
    t = res['time']

    assert N.abs(res.final('crane.q[1]') - 0.99373831) < 1e-1  

    if with_plots:
        plt.figure(1)
        plt.subplot(2,1,1)
        plt.plot(t,q1,t,q2)
        plt.grid(True)
        plt.legend(['q[1]','q[2]'])
        plt.subplot(2,1,2)
        plt.plot(t,qd1,t,qd2)
        plt.grid(True)
        plt.legend(['qd[1]','qd[2]'])
        plt.xlabel('time [s]')
        plt.show()

if __name__=="__main__":
    run_demo()
