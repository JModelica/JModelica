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

""" 
Test module for testing the core module. 
"""

import os, os.path
import sys

import nose
import nose.tools

from tests_jmodelica import testattr, get_files_path
from pyfmi.common.core import *


class Test_TrajectoryConstantInterpolationExtrapolation:
    
    @testattr(stddist_full = True)
    def test_one_dimensional(self):
        t = N.array([1,2,3,4,5])
        x = N.array([[2,2.5,4,5,9]]).transpose()
        
        interp = TrajectoryConstantInterpolationExtrapolation(t,x)
        
        assert interp.eval(0)[:,0] == 2.0
        assert interp.eval(6)[:,0] == 9.0
        assert interp.eval(1.5)[:,0] == 2.0
        assert interp.eval(2.6)[:,0] == 2.5
        
        assert interp.eval([0, 1.5, 2.6, 6])[0,0] == 2.0
        assert interp.eval([0, 1.5, 2.6, 6])[1,0] == 2.0
        assert interp.eval([0, 1.5, 2.6, 6])[2,0] == 2.5
        assert interp.eval([0, 1.5, 2.6, 6])[3,0] == 9.0
        
        #Change mode
        interp.set_mode("Backward")
        
        assert interp.eval(0)[:,0] == 2.0
        assert interp.eval(6)[:,0] == 9.0
        assert interp.eval(1.5)[:,0] == 2.5
        assert interp.eval(2.6)[:,0] == 4.0
        
        assert interp.eval([0, 1.5, 2.6, 6])[0,0] == 2.0
        assert interp.eval([0, 1.5, 2.6, 6])[1,0] == 2.5
        assert interp.eval([0, 1.5, 2.6, 6])[2,0] == 4.0
        assert interp.eval([0, 1.5, 2.6, 6])[3,0] == 9.0
        
    @testattr(stddist_full = True)
    def test_two_dimensional(self):
        t = N.array([1,2,3,4,5])
        x = N.array([[2,2.5,4,5,9], [1,1.5,3,4,8]]).transpose()
        
        interp = TrajectoryConstantInterpolationExtrapolation(t,x)
        
        assert interp.eval(0)[0,0] == 2.0
        assert interp.eval(6)[0,0] == 9.0
        assert interp.eval(1.5)[0,0] == 2.0
        assert interp.eval(2.6)[0,0] == 2.5
        assert interp.eval(0)[0,1] == 1.0
        assert interp.eval(6)[0,1] == 8.0
        assert interp.eval(1.5)[0,1] == 1.0
        assert interp.eval(2.6)[0,1] == 1.5
        
        assert interp.eval([0, 1.5, 2.6, 6])[0,0] == 2.0
        assert interp.eval([0, 1.5, 2.6, 6])[1,0] == 2.0
        assert interp.eval([0, 1.5, 2.6, 6])[2,0] == 2.5
        assert interp.eval([0, 1.5, 2.6, 6])[3,0] == 9.0
        assert interp.eval([0, 1.5, 2.6, 6])[0,1] == 1.0
        assert interp.eval([0, 1.5, 2.6, 6])[1,1] == 1.0
        assert interp.eval([0, 1.5, 2.6, 6])[2,1] == 1.5
        assert interp.eval([0, 1.5, 2.6, 6])[3,1] == 8.0
        
        #Change mode
        interp.set_mode("Backward")
        
        assert interp.eval(0)[0,0] == 2.0
        assert interp.eval(6)[0,0] == 9.0
        assert interp.eval(1.5)[0,0] == 2.5
        assert interp.eval(2.6)[0,0] == 4.0
        assert interp.eval(0)[0,1] == 1.0
        assert interp.eval(6)[0,1] == 8.0
        assert interp.eval(1.5)[0,1] == 1.5
        assert interp.eval(2.6)[0,1] == 3.0
        
        assert interp.eval([0, 1.5, 2.6, 6])[0,0] == 2.0
        assert interp.eval([0, 1.5, 2.6, 6])[1,0] == 2.5
        assert interp.eval([0, 1.5, 2.6, 6])[2,0] == 4.0
        assert interp.eval([0, 1.5, 2.6, 6])[3,0] == 9.0
        assert interp.eval([0, 1.5, 2.6, 6])[0,1] == 1.0
        assert interp.eval([0, 1.5, 2.6, 6])[1,1] == 1.5
        assert interp.eval([0, 1.5, 2.6, 6])[2,1] == 3.0
        assert interp.eval([0, 1.5, 2.6, 6])[3,1] == 8.0


class Test_TrajectoryLinearInterpolationExtrapolation:
    
    @testattr(stddist_full = True)
    def test_one_dimensional(self):
        t = N.array([1,2,3,4,5])
        x = N.array([[2,2.5,4,5,9]]).transpose()
        
        interp = TrajectoryLinearInterpolationExtrapolation(t,x)
        
        assert interp.eval(0)[:,0] == 1.5
        assert interp.eval(6)[:,0] == 13.0
        assert interp.eval(1.5)[:,0] == 2.25
        nose.tools.assert_almost_equal(interp.eval(2.6)[:,0],3.4)
        
        assert interp.eval([0, 1.5, 2.6, 6])[0,0] == 1.5
        assert interp.eval([0, 1.5, 2.6, 6])[1,0] == 2.25
        nose.tools.assert_almost_equal(interp.eval([0, 1.5, 2.6, 6])[2,0],3.4)
        nose.tools.assert_almost_equal(interp.eval([0, 1.5, 2.6, 6])[3,0],13.0)
        
    @testattr(stddist_full = True)
    def test_two_dimensional(self):
        t = N.array([1,2,3,4,5])
        x = N.array([[2,2.5,4,5,9], [1,1.5,3,4,8]]).transpose()
        
        interp = TrajectoryLinearInterpolationExtrapolation(t,x)
        
        assert interp.eval(0)[:,0] == 1.5
        assert interp.eval(6)[:,0] == 13.0
        assert interp.eval(1.5)[:,0] == 2.25
        nose.tools.assert_almost_equal(interp.eval(2.6)[:,0],3.4)
        assert interp.eval(0)[:,1] == 0.5
        assert interp.eval(6)[:,1] == 12.0
        assert interp.eval(1.5)[:,1] == 1.25
        nose.tools.assert_almost_equal(interp.eval(2.6)[:,1],2.4)
        
        assert interp.eval([0, 1.5, 2.6, 6])[0,0] == 1.5
        assert interp.eval([0, 1.5, 2.6, 6])[1,0] == 2.25
        nose.tools.assert_almost_equal(interp.eval([0, 1.5, 2.6, 6])[2,0],3.4)
        nose.tools.assert_almost_equal(interp.eval([0, 1.5, 2.6, 6])[3,0],13.0)
        assert interp.eval([0, 1.5, 2.6, 6])[0,1] == 0.5
        assert interp.eval([0, 1.5, 2.6, 6])[1,1] == 1.25
        nose.tools.assert_almost_equal(interp.eval([0, 1.5, 2.6, 6])[2,1],2.4)
        nose.tools.assert_almost_equal(interp.eval([0, 1.5, 2.6, 6])[3,1],12.0)
