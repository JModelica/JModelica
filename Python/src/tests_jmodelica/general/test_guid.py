#!/usr/bin/env python 
# -*- coding: utf-8 -*-

# Copyright (C) 2018 Modelon AB
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
Module for testing GUID generation.
"""
import os

import nose

from tests_jmodelica import testattr, get_files_path

class TestGuid:
    
    @testattr(stddist_full = True)
    def test_guid(self):
        from pymodelica import compile_fmu
        from pyfmi import load_fmu
        mo_file = os.path.join(get_files_path(), 'Modelica', "BouncingBall.mo")
        fmu = load_fmu(compile_fmu("BouncingBall", [mo_file]))
        guid = fmu.get_guid()
        assert guid == "e3b48aa15b4f281c119e2208b06a2582", "GUID was " + fmu.get_guid()
       