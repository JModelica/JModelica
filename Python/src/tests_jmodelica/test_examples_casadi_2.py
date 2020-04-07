#!/usr/bin/env python 
# -*- coding: utf-8 -*-

#    Copyright (C) 2014 Modelon AB
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, version 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
""" 
Test module for testing the CASADI examples. 
"""
import platform

from tests_jmodelica import testattr
# Will catch import errors in the examples.
try:
    from pyjmi.examples import (cart_pendulum, ccpp, ccpp_elimination, ccpp_sym_elim,
                                vdp_casadi, vdp_minimum_time_casadi, elimination_example,
                                cstr_casadi, qt_par_est_casadi, vehicle_turn, fed_batch_oed,
                                distillation4_opt, cstr_mpc_casadi, ccpp_elimination, double_pendulum, fourbar1, greybox_identification)
except (NameError, ImportError):
    pass

@testattr(casadi_base = True)
def test_ccpp():
    ccpp.run_demo(False)

@testattr(ma57 = True)
def test_fourbar1():
    """Run the fourbar1 optimization example."""
    fourbar1.run_demo(False)

@testattr(casadi_base = True)
def test_elimination_example():
    """Run the elimination example."""
    elimination_example.run_demo(False)
