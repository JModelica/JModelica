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
    An example on how to simulate a model using a DAE simulator with Assimulo. 
    The model used is made by Maja Djačić.
    """

    curr_dir = os.path.dirname(os.path.abspath(__file__));

    m_name = 'SolAngles'
    mofile = curr_dir+'/files/SolAngles.mo'
    
    fmu_name = compile_fmu(m_name, mofile)
    model = load_fmu(fmu_name)
    
    res = model.simulate(final_time=86400.0, options={'ncp':86400})

    theta = res['theta']
    azim = res['azim']
    N_day = res['N_day']
    time = res['time']
    
    assert N.abs(res.final('theta') - 90.28737353) < 1e-3
    
    # Plot results
    if with_plots:
        p.figure(1)
        p.plot(time, theta)
        p.xlabel('time [s]')
        p.ylabel('theta [deg]')
        p.title('Angle of Incidence on Surface')
        p.grid()
        p.show()

if __name__=="__main__":
    run_demo()
