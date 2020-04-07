#!/usr/bin/env python 
# -*- coding: utf-8 -*-

# Copyright (C) 2013 Modelon AB
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

import os.path
from pyfmi import load_fmu
from pymodelica import compile_fmu
import numpy
from pylab import *
from pyjmi.log import parse_jmi_log, gather_solves

def run_demo(with_plots=True):
    """
    This example demonstrates how to initialize with and without active
    boundaries. The iterations are displaied graphically together with
    the boundaries.
    """
    curr_dir = os.path.dirname(os.path.abspath(__file__));
    fpath = os.path.join(curr_dir, 'files', 'BoundsDemo.mo')
    print(fpath)
    compile_fmu('BoundsDemo', fpath)
    
    log_file_name='files/bounds_kinsol.txt'
    m = load_fmu('BoundsDemo.fmu', log_file_name=log_file_name)
    
    m.set_debug_logging(True)
    m.set_fmil_log_level(5)
    m.set('_log_level',5)
    m.set('_nle_solver_log_level',3)
    
    m.set('_enforce_bounds',False)
    
    try:
        m.initialize()
        print 'Initialized OK'
    except:
        print 'Error in initialize'
    
    # Parse the entire XML log
    log = parse_jmi_log(log_file_name)
    
    # Gather information pertaining to equation solves
    solves = gather_solves(log)
    
    print 'Number of iterations in solver without bounds:',\
            len(solves[0].block_solves[0].iterations), '+', len(solves[0].block_solves[1].iterations)
    
    print 'Solution: x_1=', m.get('x_1'),' x_2=', m.get('x_2') 
    
    nbr_iterations = len(solves[0].block_solves[0].iterations)
    iteration_points = numpy.zeros(shape=(nbr_iterations,2))
    
    for i in xrange(nbr_iterations):
        iteration_points[i] = solves[0].block_solves[0].iterations[i].ivs
    
    if with_plots:
        #Plot the iterations
        iteration_points_dx = diff(iteration_points[:, 0])
        iteration_points_dy = diff(iteration_points[:, 1])
        Q = quiver(iteration_points[0:-1,0], iteration_points[0:-1,1], 
               iteration_points_dx, iteration_points_dy,scale_units='xy', 
               angles='xy', scale=1, width=0.005, color='k')
        
        quiverkey(Q,4,8,1,"Iteration without active bounds",coordinates='data',color='k')
    
    m = load_fmu('BoundsDemo.fmu', log_file_name=log_file_name)
    m.set_debug_logging(True)
    m.set_fmil_log_level(5)
    m.set('_log_level',5)
    m.set('_nle_solver_log_level',3)
    
    m.set('_enforce_bounds',True)
    
    try:
        m.initialize()
        print 'Initialized OK'
    except:
        print 'Error in initialize'
    
    # Parse the entire XML log
    log = parse_jmi_log(log_file_name)
    
    # Gather information pertaining to equation solves
    solves = gather_solves(log)
    
    print 'Number of iterations in solver with bounds:',\
            len(solves[0].block_solves[0].iterations), '+', len(solves[0].block_solves[1].iterations)
    
    print 'Solution: x_1=', m.get('x_1'),' x_2=', m.get('x_2') 
    
    nbr_iterations = len(solves[0].block_solves[0].iterations)
    iteration_points = numpy.zeros(shape=(nbr_iterations,2))
    
    for i in xrange(nbr_iterations):
        iteration_points[i] = solves[0].block_solves[0].iterations[i].ivs
    
    if with_plots:
        #Plot the iterations
        iteration_points_dx = diff(iteration_points[:, 0])
        iteration_points_dy = diff(iteration_points[:, 1])
        Q = quiver(iteration_points[0:-1,0], iteration_points[0:-1,1], 
               iteration_points_dx, iteration_points_dy,scale_units='xy', 
               angles='xy', scale=1, width=0.005, color='red', label='test')
        quiverkey(Q,4,7,1,"Iteration with active bounds",coordinates='data',color='r')
        
        #Plot the boundaries
        plot([-4, 4, 4, -4, -4], [-6, -6, 6, 6, -6], color='k')
        xlim([-5,7])
        ylim([-7,9])
        
        #Plot the contours
        x = arange(-5,7,0.1)
        y = arange(-7,9,0.1)
        X,Y = meshgrid(x, y)
        Z = (X**2 + Y**2 - 25)**2 + ((X - 5)**2 + (Y - 2)**2 - 4)**2
        contour_levels = [4**n for n in xrange(1,6)] 
        contour(X,Y,Z, contour_levels, colors='b')
        show() 
    
if __name__=="__main__":
    run_demo()
