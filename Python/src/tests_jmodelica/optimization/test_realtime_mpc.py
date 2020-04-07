#!/usr/bin/env python 
# -*- coding: utf-8 -*-

# Copyright (C) 2015 Modelon AB
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

"""
Tests the real time MPC base class.
"""

import os
import math

import numpy as N
from tests_jmodelica import testattr, get_files_path

try:
    from pyjmi.optimization.realtimecontrol import ParameterChanges, MPCSimBase
    from pyjmi.optimization.casadi_collocation import BlockingFactors
except (NameError, ImportError):
    pass


def check_result(results, ref):
    for key in ref:
        assert abs(ref[key] - results[key][-1]) < 1e-5
        

@testattr(casadi_base = True)
def test_realtime_mpc():
    start_values = {'_start_phi': 0, '_start_v': 0, '_start_z': 0}
    par_changes = ParameterChanges({1: {'z_ref': 5}})
    ref = {'phi': 0.936978004043,
           'z': 4.25919322427,
           'v': 3.40523065632,
           'u': -0.0597209819244,
           'time': 2.0}

    path = os.path.join(get_files_path(), 'Modelica', 'bnb.mop')
    mpc = MPCSimBase(path, 'Ball_Beam.Ball_Beam_MPC',
                     'Ball_Beam.Ball_Beam_MPC_Model', 0.05, 1, 2,
                     start_values, {}, ['phi', 'v', 'z'], ['u'], None,
                     par_changes)
    results, _ = mpc.run()
    check_result(results, ref)

@testattr(casadi_base = True)
def test_realtime_mpc_ia():
    start_values = {'_start_h1': 0, '_start_h2': 0,
                    '_start_h3': 0, '_start_h4': 0}
    ref = {'h1': 5.41158639648,
           'h2': 5.14179296558,
           'h3': 7.6831333579,
           'h4': 8.66958129138,
           'u1': 10.0,
           'u2': 10.0,
           'time': 5.0}
    mpc_opts = {'blocking_factors': BlockingFactors(
        {'u1': [1]*30, 'u2': [1]*30}, du_quad_pen = {'u1': 0.1, 'u2': 0.1})}
    
    path = os.path.join(get_files_path(), 'Modelica', 'quadtank.mop')
    mpc = MPCSimBase(path, 'QuadTank.QuadTank_MPC',
                     'QuadTank.QuadTank_MPC_Model', 1, 30, 5, 
                     start_values, {}, ['h1', 'h2', 'h3', 'h4'],
                     ['u1', 'u2'], mpc_options=mpc_opts)
    T = 1
    dt = 1
    mu = math.exp(-float(dt)/T)
    k = mpc.solver.op.get('k')
    A = mpc.solver.op.get('A')
    gamma = mpc.solver.op.get('gamma')
    B = k/A*dt*N.array([[gamma  , 0      ],
                        [0      , gamma  ],
                        [0      , 1-gamma],
                        [1-gamma, 0      ]])
    M = N.linalg.inv(B.T.dot(B)).dot(B.T)
    mpc.enable_integral_action(mu, M, u_e = [1.0, -1.0])
    results, _ = mpc.run()
    check_result(results, ref)

@testattr(casadi_base = True)
def test_realtime_mpc_cg():
    start_values = {'_start_px': 0, '_start_py': 0, '_start_l': 1,
                    '_start_vx': 0, '_start_vy': 0, '_start_der_l': 0,
                    '_start_tx': 0, '_start_ty': 0,
                    '_start_wx': 0, '_start_wy': 0}
    par_changes = ParameterChanges({1: {'lx_ref': 0.5,
                                        'ly_ref': 1.0,
                                        'lz_ref': -0.5}})
    ref = {'px': 0.346932431817,
           'py': 0.694178183248,
           'ul': 0.11764811976,
           'vx': 0.263449683258,
           'vy': 0.520923008414,
           'der_l': 0.237609752809,
           'tx': 0.153826374643,
           'ty': 0.29862921556,
           'wx': 1.20408324142,
           'wy': 2.20145775869,
           'ux': -0.0554289031676,
           'uy': -0.11787736265,
           'ul': 0.117369869311,
           'time': 2.0}
    
    path = os.path.join(get_files_path(), 'Modelica', 'crane.mop')
    mpc = MPCSimBase(path, 'Crane.Crane_MPC', 'Crane.Crane_MPC_Model',
                     0.2, 2, 2, start_values, {},
                     ['px', 'py', 'vx', 'vy', 'l', 'der_l', 'tx', 'ty', 'wx', 'wy'],
                     ['ux', 'uy', 'ul'], None,  par_changes)
    mpc.enable_codegen()
    results, _ = mpc.run()
    check_result(results, ref)
    
