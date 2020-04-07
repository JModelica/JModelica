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

import pylab as p
import numpy as N

from pymodelica import compile_fmu
from pyfmi import load_fmu

def run_demo(with_plots=True):
    
    curr_dir = os.path.dirname(os.path.abspath(__file__));
    class_name = 'ExtFunctions.sumArray'
    mofile = os.path.join(curr_dir, 'files', 'ExtFunctions.mo')
    
    # Compile and load model
    fmu_name = compile_fmu(class_name, mofile)
    model = load_fmu(fmu_name)

    # Simulate
    res = model.simulate(final_time=10.0)
    
    res_sum = res['sum']
    t = res['time']

    assert N.abs(res.final('sum') - 55) < 1e-6 

    if with_plots:
        fig = p.figure()
        p.clf()
        p.plot(t, res_sum)
        p.grid()
        p.show()

if __name__=="__main__":
    run_demo()
