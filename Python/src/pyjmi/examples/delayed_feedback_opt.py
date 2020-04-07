#!/usr/bin/env python 
# -*- coding: utf-8 -*-

# Copyright (C) 2014 Modelon AB
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

import numpy as np
import matplotlib.pyplot as plt

from pyjmi import get_files_path, transfer_optimization_problem

def run_demo(with_plots = True):
    n_e = 20
    delay_n_e = 5
    horizon = 1.0
    delay = horizon*delay_n_e/n_e

    # Compile and load optimization problem
    file_path = os.path.join(get_files_path(), "DelayedFeedbackOpt.mop")
    opt = transfer_optimization_problem("DelayTest", file_path)

    # Set value for u2(t) when t < delay
    opt.getVariable('u2').setAttribute('initialGuess', 0.25)

    # Set algorithm options
    opts = opt.optimize_options()
    opts['n_e'] = n_e
    # Set delayed feedback from u1 to u2
    opts['delayed_feedback'] = {'u2': ('u1', delay_n_e)}

    # Optimize
    res = opt.optimize(options=opts)

    # Extract variable profiles
    x_res = res['x']
    u1_res = res['u1']
    u2_res = res['u2']
    time_res = res['time']

    # Plot results
    if with_plots:
        plt.plot(time_res, x_res, time_res, u1_res, time_res, u2_res)
        plt.hold(True)
        plt.plot(time_res+delay, u1_res, '--')
        plt.hold(False)
        plt.legend(('x', 'u1', 'u2', 'delay(u1)'))

        plt.show()

if __name__ == "__main__":
    run_demo()
