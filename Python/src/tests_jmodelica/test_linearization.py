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

""" Test module for testing the linearize module
"""

import os
import os.path

import numpy as N
import nose

from tests_jmodelica import testattr, get_files_path
from pymodelica.compiler import compile_fmu
from pyfmi import load_fmu
from pyjmi.optimization import ipopt
from pyjmi.linearization import *
from pyjmi.initialization.ipopt import InitializationOptimizer

path_to_mofiles = os.path.join(get_files_path(), 'Modelica')
fpath = os.path.join(get_files_path(), 'Modelica', 'CSTR.mop')
cpath = "CSTR.CSTR_Opt"
fname = cpath.replace('.','_',1)



class TestOptLinearization:
    
    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        cls.vdp_sim = compile_fmu("VDP_pack.VDP",os.path.join(path_to_mofiles,"VDP_pack.mo"))

    
    @testattr(casadi_base = True)
    def test_linearize_dae_with_simresult(self):
        
        from pyjmi.casadi_interface import linearize_dae_with_simresult
        from pyjmi import transfer_optimization_problem
        
        sim_model = load_fmu(self.vdp_sim)

        res = sim_model.simulate()

        model = transfer_optimization_problem("VDP_pack.VDP_Opt_Simple",os.path.join(path_to_mofiles,"VDP.mop"))
        
        [E, A , B ,C ,D , G, h, RefPoint] = linearize_dae_with_simresult(model, 0.0, res)
        
        nose.tools.assert_almost_equal(A[0,0],0.0)
        nose.tools.assert_almost_equal(A[0,1],-1.0)
        nose.tools.assert_almost_equal(A[1,0],1.0)
        nose.tools.assert_almost_equal(A[1,1],0.0)
        
        nose.tools.assert_almost_equal(B[0,0],1.0)
        nose.tools.assert_almost_equal(B[1,0],0.0)
        
        

        
