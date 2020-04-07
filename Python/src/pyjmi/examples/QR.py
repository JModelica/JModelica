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
    An example on how to simulate a model which computes QR-factorization of a
    square matrix using Modelica.Math.Matrices.LAPACK.dgeqpf.
    """
    curr_dir = os.path.dirname(os.path.abspath(__file__));

    class_name = 'QR_pack.QR1'
    mofile = curr_dir+'/files/QR_pack.mo'
    
    fmu_name = compile_fmu(class_name, mofile)
    qr = load_fmu(fmu_name)
    
    res = qr.simulate(final_time=10)
    
    qr_1_1 = res['QR[1,1]']
    qr_1_2 = res['QR[1,2]']
    qr_2_1 = res['QR[2,1]']
    qr_2_2 = res['QR[2,2]']
    tau_1  = res['tau[1]']
    tau_2  = res['tau[2]']
    p_1    = res['p[1]']
    p_2    = res['p[2]']
    t = res['time']

    assert N.abs(res.final('QR[1,1]') + 4.47214)  < 1e-3
    assert N.abs(res.final('QR[1,2]') + 3.13049)  < 1e-3
    assert N.abs(res.final('QR[2,1]') - 0.618034) < 1e-3
    assert N.abs(res.final('QR[2,2]') - 0.447214) < 1e-3
    assert N.abs(res.final('tau[1]') - 1.44721)   < 1e-3
    assert N.abs(res.final('tau[2]') - 0)         < 1e-3
    assert N.abs(res.final('p[1]') - 2)           < 1e-3
    assert N.abs(res.final('p[2]') - 1)           < 1e-3
    
    if with_plots:
        fig = p.figure()
        p.plot(t, qr_1_1, t, qr_1_2, t, qr_2_1, t, qr_2_2)
        p.legend(('QR[1,1]','QR[1,2]','QR[2,1]','QR[2,2]'))
        p.grid()
        p.show()

if __name__=="__main__":
    run_demo()
