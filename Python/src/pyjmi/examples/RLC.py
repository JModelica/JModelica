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

import numpy as N
import pylab as p

from pymodelica import compile_fmu
from pyfmi import load_fmu

def run_demo(with_plots=True):
    """
    An example on how to simulate a model using the DAE simulator. The result 
    can be compared with that of sim_rlc.py which has solved the same problem 
    using dymola. Also writes information to a file.
    """

    curr_dir = os.path.dirname(os.path.abspath(__file__));

    class_name = 'RLC_Circuit'
    mofile = curr_dir+'/files/RLC_Circuit.mo'
    
    fmu_name = compile_fmu(class_name, mofile)
    rlc = load_fmu(fmu_name)
    
    res = rlc.simulate(final_time=30)
    
    sine_y = res['sine.y']
    resistor_v = res['resistor.v']
    inductor1_i = res['inductor1.i']
    t = res['time']

    assert N.abs(res.final('resistor.v') - 0.159255008028) < 1e-3
    
    if with_plots:
        fig = p.figure()
        p.plot(t, sine_y, t, resistor_v, t, inductor1_i)
        p.legend(('sine.y','resistor.v','inductor1.i'))
        p.show()

if __name__=="__main__":
    run_demo()
