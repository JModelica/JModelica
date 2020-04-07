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

"""Tests optimization with delayed feedback."""

from __future__ import division

import os
import nose

import numpy as np

from tests_jmodelica import testattr, get_files_path
try:
    from pyjmi import transfer_optimization_problem
except (NameError, ImportError):
    pass

path_to_mos = os.path.join(get_files_path(), 'Modelica')

@testattr(casadi_base = True)
def test_delayed_feedback_optimization(with_plots = False):
    if with_plots:
        import matplotlib.pyplot as plt
    
    n_e = 20
    delay_n_e = 5

    n_cp = 3

    horizon = 1.0
    delay = horizon*delay_n_e/n_e

    opt = transfer_optimization_problem("Test", [os.path.join(path_to_mos, "DelayedFeedbackOptTest.mop")])

    u2 = opt.getVariable('u2')
    u2.setAttribute('initialGuess',0.25)

    stepresults = []
    for step in xrange(2):    
        opts = opt.optimize_options()
        #    opts['variable_scaling'] = False
        #    opts['discr'] = "LG"
        opts['n_e'] = n_e
        opts['n_cp'] = n_cp

        if step==1:
            opts['delayed_feedback'] = {'u2': ('u1', delay_n_e)}
            opts['init_traj'] = res.result_data
    
        res = opt.optimize(options=opts)
        stepresults.append(res)
    
        x_res = res['x']
        u1_res = res['u1']
        u2_res = res['u2']
        time_res = res['time']

        if with_plots:
            plt.figure(step+1)
            plt.plot(time_res, x_res, time_res, u1_res, time_res, u2_res)
            if step==1:
                plt.hold(True)
                plt.plot(time_res+delay, u1_res, '--')
                plt.hold(False)
                plt.legend(('x', 'u1', 'u2', 'delay(u1)'))
            else:    
                plt.legend(('x', 'u1', 'u2'))

    u2_res0 = stepresults[0]['u2']
    delay_len = delay_n_e*n_cp
    initial_len = delay_len + 1
    # test initial (fixed) part of delayed var u2
    assert np.allclose(u2_res[0:initial_len], u2_res0[0:initial_len], rtol=1e-5)
    # test that delayed part of u2 matches undelayed u1
    assert np.allclose(u1_res[1:-delay_len],u2_res[initial_len:], rtol=1e-5)

    return_status, niter, objective, solve_time = res.solver.get_solver_statistics()
    assert abs(objective/1.6652 - 1) < 2e4
    assert niter <= 10 # At the time of this writing, 1

    final_vals = [x_res[-1], u1_res[-1], u2_res[-1]]
    final_ref  = [0, -0.746557345650112, 0.292267925751724]
    assert np.allclose(final_vals, final_ref, rtol = 1e4)

    if with_plots:
        plt.show()
