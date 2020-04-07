#!/usr/bin/env python
# -*- coding: utf-8 -*-

#    Copyright (C) 2014 Modelon AB
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, version 3 of the License.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
import pyjmi.optimization.shooting as shooting
import matplotlib.pyplot as plt
import numpy as N

opt_vals = [  5.45715979e-02,   8.44173747e-02,   1.15601416e-02,   9.90864172e-03,
   3.68902469e+02,   6.07856270e-02,   9.24801740e-02,   1.30464076e-02,
   1.09292429e-02,   4.59797257e+02,   6.34750709e-02,   9.63951163e-02,
   1.25434657e-02,   1.07050575e-02,   4.97359649e+02,   6.45436819e-02,
   9.85201410e-02,   1.14961203e-02,   1.01064361e-02,   5.18724066e+02,
   6.48900330e-02,   9.97979905e-02,   1.04232941e-02,   9.49007358e-03,
   5.31925683e+02,   6.49289569e-02,   1.00622620e-01,   9.49102589e-03,
   8.98262615e-03,   5.40113500e+02,   6.48557116e-02,   1.01171070e-01,
   8.73115089e-03,   8.61370025e-03,   5.45150297e+02,   6.47706707e-02,
   1.01529803e-01,   8.12697009e-03,   8.37708244e-03,   5.48234827e+02,
   6.47513047e-02,   1.01745837e-01,   7.64747589e-03,   8.26298103e-03,
   5.50131534e+02,   5.31132775e+00,   7.13686371e+00,   3.43109227e+00,
   4.38151572e+00,   2.63481428e+00,   3.31732657e+00,   2.32601013e+00,
   2.89558042e+00,   2.23280255e+00,   2.72303474e+00,   2.22980786e+00,
   2.64676189e+00,   2.26240670e+00,   2.60697637e+00,   2.30898809e+00,
   2.57973467e+00,   2.36692183e+00,   2.55532528e+00,   2.44549622e+00,
   2.52259836e+00]

x_0 = [0.04102638,  0.06607553,  0.00393984,  0.00556818, 0]

x_r = [ 0.06410371,  0.10324302,  0.006156  ,  0.00870028]
u_r = [2.5,2.5]
model = shooting.JmiOptModel('QuadTank_Pack_QuadTank_Opt','./')

gridsize = 10
grid = shooting.construct_grid(gridsize)
initial_u = [[2.5] * len(model.getInputs())] * gridsize
shooter = shooting.MultipleShooter(model,initial_u,grid)
#shooter.set_time_step(5.)
shooter.h(N.array(opt_vals))
print('z')
print(model._m.getZ())

interval = [0., 5.]

N_xvars = 5*9;

us = opt_vals[N_xvars:N_xvars+2]

plt.figure(1)
plt.clf()
plt.figure(2)
plt.clf()

for i in range(0,10):
    us = opt_vals[N_xvars+i*2:N_xvars+(i+1)*2]
    interval = [i*5,(i+1)*5]
    shooting._plot_control_solution(model, interval, x_0, us)
    x_0 = opt_vals[5*i:5*i+5]

plt.figure(1)
plt.subplot(211)
plt.plot([0,50.],[x_r[0],x_r[0]],'r-.',linewidth=2)
plt.plot([0,50.],[x_r[1],x_r[1]],'r-.',linewidth=2)
plt.ylabel('x1, x2')
plt.grid(True)
plt.subplot(212)
plt.plot([0,50.],[x_r[2],x_r[2]],'r-.',linewidth=2)
plt.plot([0,50.],[x_r[3],x_r[3]],'r-.',linewidth=2)
plt.ylabel('x3, x4')
plt.xlabel('t')
plt.grid(True)

plt.figure(2)
plt.clf()
us = opt_vals[N_xvars:N_xvars+2]
plt.subplot(211)
plt.plot([0.,5],[us[0],us[0]],'b',linewidth=2)
plt.subplot(212)
plt.plot([0.,5],[us[1],us[1]],'b',linewidth=2)
us_old = us[:]
for i in range(1,10):
    us = opt_vals[N_xvars+i*2:N_xvars+(i+1)*2]
    plt.subplot(211)
    plt.plot([i*5,i*5,(i+1)*5],[us_old[0],us[0],us[0]],'b',linewidth=2)
    plt.subplot(212)
    plt.plot([i*5,i*5,(i+1)*5],[us_old[1],us[1],us[1]],'b',linewidth=2)
    us_old = us[:]

plt.subplot(211)
plt.plot([0,50.],[u_r[0],u_r[0]],'r-.',linewidth=2)
plt.subplot(212)
plt.plot([0,50.],[u_r[1],u_r[1]],'r-.',linewidth=2)

plt.subplot(211)
plt.grid(True)
plt.ylabel('u1')
plt.subplot(212)
plt.ylabel('u2')
plt.xlabel('t')
plt.grid(True)
plt.show()

