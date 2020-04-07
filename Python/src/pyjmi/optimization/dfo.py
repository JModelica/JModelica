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

"""
This file contains code for performing derivative-free optimization of
a function.
"""

import numpy as N
import scipy as S
import scipy.linalg
import matplotlib.pyplot as plt
import time
import multiprocessing
import logging
import os

import thread_feval as tf

try:
    from openopt import NLP
except ImportError:
    pass
    #print "Could not load OpenOpt package."

def cost_evaluater_test(func, x, process="thread_0"):
    logging.basicConfig(level=logging.ERROR)
    try:
        os.mkdir(process)
    except OSError:
        pass
    os.chdir(process)
    ret = func(x)
    os.chdir("..")
    return ret

def nelme_modified(func,xstart,lb=None,ub=None,h=0.3,x_tol=1e-3,f_tol=1e-6,
          max_iters=500,max_fevals=5000, disp=True,nbr_cores=None, debug=False):
    """
    Minimize a function of one or more variables using the 
    Nelder-Mead simplex method. Handles box bound constraints rather well 
    but it cannot be guaranteed that it works well for all situations.
    
    If desired, all function evaluations in the algorithm can be performed 
    in separate processes (multiprocessing) to save memory. For example, 
    when the function evaluation involves the loading of an FMU, there is 
    a risk of running out of memory after a number of function evaluations.
    In that case, this feature is quite useful. The feature is applied if the
    user provides the objective function (func) as a file name (of a file 
    containing the definition of the function) instead of a function.
    
    NB: If the function is provided this way and an FMU is loaded inside the
        function, then the FMU file name must be preceded by "../" when
        using FMUModel(), like this: 
        
            model = FMUModel('../fmu_name.fmu')
        
        The reason for this is that the function evaluations are performed
        in sub-directories to the working directory when multiprocessing 
        is used.
    
    Parameters::
    
        func -- 
            callable func(x) or string
            The objective function OR the name of a python file 
            containing the definition of the objective function. In case 
            of a file name, the objective function in the file must 
            have the same name as the file itself (without '.py').  
            
        xstart -- 
            ndarray or scalar
            The initial guess for x. 
            
        lb -- 
            ndarray or scalar
            The lower bound on x.
            Default: None
        
        ub --
            ndarray or scalar
            The upper bound on x.
            Default: None
        
        h -- 
            float
            The side length of the initial simplex.
            NB: 0 < h < 1 should be fulfilled.
            Default: 0.3    
        
        x_tol --
            float
            The tolerance for the termination criteria for x. 
            Termination when at least one side length in the simplex have 
            reached this value.
            NB: x_tol < h must be fulfilled.
            Default: 1e-3
        
        f_tol --
            float
            The tolerance for the termination criteria for the objective 
            function. Termination when at least two vertix function values 
            in the simplex are this close to each other.
            Default: 1e-6
        
        max_iters --
            int
            The maximum number of iterations allowed.
            Default: 500
            
        max_fevals --
            int
            The maximum number of function evaluations allowed. 
            Default: 5000
            
        disp --
            bool
            Set to True to print convergence messages.
            Default: True
            
        nbr_cores --
            int
            The number of processor cores used.
            Default: Maximum Number of cores
            
        debug --
            bool
            Set to True to get separate error and output files for each
            separate process when using multiprocessing.
            Default: False
            
    Returns::
    
        x_opt --
            ndarray or scalar
            The optimal point which minimizes the objective function.
            
        f_opt --
            float
            The minimal value of the objective function.
        
        nbr_iters --
            int
            The number of iterations performed.
        
        nbr_fevals --
            int
            The number of function evaluations made. Evaluations due to 
            generation of contour plot are not included.    
        
        solve_time --
            float
            The execution time for the solver in seconds.
    """
    t0 = time.clock()
    
    # Check that lb < ub
    if ub is not None:  # "None" < everything
        if N.any(lb >= ub):
            raise ValueError, 'Lower bound must be smaller than upper bound.'
    
    # Check that lb < xstart < ub 
    if N.any(xstart <= lb):
        raise ValueError, 'xstart must be larger than lb.'
    if ub is not None:  # "None" < everything
        if N.any(xstart >= ub):
            raise ValueError, 'xstart must be smaller than ub.'
    
    if nbr_cores is None:
        nbr_cores = multiprocessing.cpu_count()
    
    # Convert xstart to float type array and flatten it so that 
    # len(xstart) can be used even if xstart is a scalar
    xstart = N.asfarray(xstart).flatten()   
    
    # Do the same with lb and ub
    if lb is not None:
        lb = N.asfarray(lb).flatten()
    if ub is not None:
        ub = N.asfarray(ub).flatten()
    
    # Number of dimensions
    n = len(xstart)
    
    # Scale h such that it has the appropriate size compared to xstart
    scale = S.linalg.norm(xstart)
    if scale > 1:
        h = h*scale
    
    # Initial simplex
    X = N.zeros((n+1,n))
    X[0] = xstart
    for i in range(1,n+1):
        X[i] = xstart
        X[i,i-1] = xstart[i-1] + h
        
    # If the initial simplex has vertices outside the feasible region it 
    # must be shrunk s.t all vertices are inside this region
    if ub is not None:
        for i in range(1,n+1):
            v = X[i]
            if N.any(v >= ub):
                ind = v >= ub
                v[ind] = ub[ind] - 1e-6
                X[i] = v
    
    # Number of function evaluations
    nbr_fevals = 0
    
    # Start iterations
    k = 1
    F_val = []
    Shiftfv = []
    Ssize = []
    
    print ' '
    print 'Running solver Nelder-Mead...'
    print ' Initial parameters: ', xstart
    print ' '
    
    if debug:    
        multiprocessing.log_to_stderr()
        logger = multiprocessing.get_logger()
        logger.setLevel(logging.INFO)
        
    
    while k < max_iters and nbr_fevals < max_fevals:
        
        
        f_val = N.zeros(n+1)
        
        vertice_calculations = []
        pool = multiprocessing.Pool(nbr_cores if nbr_cores < n+1 else n+1) #Not needed more cores than parameters + 1 
        for i in range(n+1):
            vertice_calculations.append(pool.apply_async(cost_evaluater_test, args=(func,X[i],"thread_"+str(i))))
            nbr_fevals += 1
        pool.close()
        pool.join()
        for j in range(n+1):
            #if not vertice_calculations[j].successful():
            #    raise Exception("An error occurred...")
            f_val[j] = vertice_calculations[j].get()
        
        # Order all vertices s.t f(x0) <= f(x1) <= ... <= f(xn)
        ind = N.argsort(f_val)
        X = X[ind]
        f_val = f_val[ind]
        
        # Save vertex function values for each iteration
        F_val.append(f_val)
        
        t_temp = time.clock()
        t_now = t_temp - t0
        
        # CONVERGENCE TESTS
        
        # Domain convergence test
        #lengths = N.zeros(n)
        #for i in range(n):
        #    lengths[i] = S.linalg.norm(X[0]-X[i+1])
        #ssize = N.max(lengths)
        #Ssize.append(ssize)
        #term_x = ssize < x_tol
        
        wi = 1.0/(x_tol*X[0]+x_tol) #1/(ATOL+RTOL*y_i)
        lengths = N.zeros(n)
        for i in range(n):
            lengths[i] = S.linalg.norm(wi*(X[0]-X[i+1]))
        ssize = N.max(lengths)
        Ssize.append(ssize)
        term_x = ssize < 1.0
        
        # Function value convergence test
        shiftfv = N.abs(f_val[0]-f_val[-1]) #n or n+1 ?
        Shiftfv.append(shiftfv)
        term_f = shiftfv < f_tol
        
        if k%10 == 1:
            print '  %s  %s        %s            %s          %s'%("iter", "fevals", "obj", "term_x", "term_f")
        print ' {:>5d} {:>7d} {:>15e} {:>15e} {:>15e}'.format(k, nbr_fevals, f_val[0], ssize, shiftfv)
        
        if term_x or term_f:
            break
        
        # Centroid of the side opposite the worst vertex
        c = 1.0/n*N.sum(X[0:n],0)
        
        # Transformation parameters
        alfa = 1    # 0 < alfa
        beta = 0.5  # 0 < beta < 1
        gamma = 2   # 1 < gamma
        delta = 0.5 # 0 < delta < 1
        
        # Reflection-, Expansion- and Contraction points
        xr = c + alfa*(c-X[n])
        xe = c + gamma*(xr-c)
        xc1 = c + beta*(xr-c)
        xc2 = c - beta*(xr-c)
        
        # If any point ends up outside the feasible region we must move 
        # it inside of the region (xc2 cannot end up outside)
        if ub is not None:
            if N.any(xr >= ub):
                ind = xr >= ub
                xr[ind] = ub[ind] - 1e-6
            if N.any(xe >= ub):
                ind = xe >= ub
                xe[ind] = ub[ind] - 1e-6
            if N.any(xc1 >= ub):
                ind = xc1 >= ub
                xc1[ind] = ub[ind] - 1e-6
        if lb is not None:
            if N.any(xr <= lb):
                ind = xr <= lb
                xr[ind] = lb[ind] + 1e-6
            if N.any(xe <= lb):
                ind = xe <= lb
                xe[ind] = lb[ind] + 1e-6
            if N.any(xc1 <= lb):
                ind = xc1 <= lb
                xc1[ind] = lb[ind] + 1e-6
        
        # Evaluate function in the four points
        vertice_calculations = []
        pool = multiprocessing.Pool(nbr_cores if nbr_cores < 4 else 4) #Not needed more than 4 cores
        for i,f in enumerate([xr,xe,xc1,xc2]):
            vertice_calculations.append(pool.apply_async(cost_evaluater_test, args=(func,f,"thread_"+str(i))))
        pool.close()
        pool.join()

        fr = vertice_calculations[0].get()
        fe = vertice_calculations[1].get()
        fc1 = vertice_calculations[2].get()
        fc2 = vertice_calculations[3].get()
        nbr_fevals += 4
        
        # Reflection
        if f_val[0] <= fr and fr < f_val[n-1]:
            X[n] = xr
            # Go to next iteration
            k += 1
            continue
        
        # Expansion 
        elif fr < f_val[0]:
            if fe < fr:
                X[n] = xe
                # Go to next iteration
                k += 1
                continue
            else:
                X[n] = xr
                # Go to next iteration
                k += 1
                continue
                
        # Contraction       
        elif f_val[n-1] <= fr:
            # Outside contraction
            if fr < f_val[n]:
                if fc1 <= fr:
                    X[n] = xc1
                    # Go to next iteration
                    k += 1
                    continue
            # Inside contraction
            else:
                if fc2 < f_val[n]:
                    X[n] = xc2
                    # Go to next iteration
                    k += 1
                    continue
            # Shrink simplex toward x0
            for i in range(1,n+1):
                X[i] = X[0] + delta*(X[i]-X[0])
            k += 1
            
    # Optimal point and objective function value        
    x_opt = X[0]
    f_opt = f_val[0]
    
    # Number of iterations
    nbr_iters = k

    t1 = time.clock()
    solve_time = t1 - t0
    
    # Print convergence results
    if disp:
        print " "
        if nbr_iters >= max_iters:
            print 'Warning: Maximum number of iterations has been exceeded.'
        elif nbr_fevals >= max_fevals:
            print 'Warning: Maximum number of function evaluations has been exceeded.'
        else:
            print 'Optimization terminated successfully.'
            if term_x:
                print 'Terminated due to sufficiently small simplex.'
            else:
                print 'Terminated due to sufficiently close function values at the vertices of the simplex.'
            print 'Found parameters: ', x_opt
        print ' '
        print 'Total number of iterations: ' + str(nbr_iters)
        print 'Total number of function evaluations: ' + str(nbr_fevals)
        print 'Total execution time: ' + str(solve_time) + ' s'
        print ' '

    # Return results
    return x_opt, f_opt, nbr_iters, nbr_fevals, solve_time


def nelme(func,xstart,lb=None,ub=None,h=0.3,plot_con=False,plot_sim=False,
          plot_conv=False,x_tol=1e-3,f_tol=1e-6,max_iters=500,max_fevals=5000,
          disp=True,nbr_cores=None,debug=False):
    """
    Minimize a function of one or more variables using the 
    Nelder-Mead simplex method. Handles box bound constraints rather well 
    but it cannot be guaranteed that it works well for all situations.
    
    If desired, all function evaluations in the algorithm can be performed 
    in separate processes (multiprocessing) to save memory. For example, 
    when the function evaluation involves the loading of an FMU, there is 
    a risk of running out of memory after a number of function evaluations.
    In that case, this feature is quite useful. The feature is applied if the
    user provides the objective function (func) as a file name (of a file 
    containing the definition of the function) instead of a function.
    
    NB: If the function is provided this way and an FMU is loaded inside the
        function, then the FMU file name must be preceded by "../" when
        using FMUModel(), like this: 
        
            model = FMUModel('../fmu_name.fmu')
        
        The reason for this is that the function evaluations are performed
        in sub-directories to the working directory when multiprocessing 
        is used.
    
    Parameters::
    
        func -- 
            callable func(x) or string
            The objective function OR the name of a python file 
            containing the definition of the objective function. In case 
            of a file name, the objective function in the file must 
            have the same name as the file itself (without '.py').  
            
        xstart -- 
            ndarray or scalar
            The initial guess for x. 
            
        lb -- 
            ndarray or scalar
            The lower bound on x.
            Default: None
        
        ub --
            ndarray or scalar
            The upper bound on x.
            Default: None
        
        h -- 
            float
            The side length of the initial simplex.
            NB: 0 < h < 1 should be fulfilled.
            Default: 0.3    
            
        plot_con --
            bool
            Set to True if a contour plot of the objective function and
            plots of the bounds (if any) are desired. 
            NB: Only works for two dimensions.
            Default: False
        
        plot_sim --
            bool
            Set to True if a plot of the simplex in each iteration is 
            desired. 
            NB: Only works for two dimensions.
            Default: False
        
        plot_conv --
            bool
            Set to True to get two plots with the convergence criteria for 
            x and the objective function vs the iterations.
            Default: False
        
        x_tol --
            float
            The tolerance for the termination criteria for x. 
            Termination when at least one side length in the simplex have 
            reached this value.
            NB: x_tol < h must be fulfilled.
            Default: 1e-3
        
        f_tol --
            float
            The tolerance for the termination criteria for the objective 
            function. Termination when at least two vertix function values 
            in the simplex are this close to each other.
            Default: 1e-6
        
        max_iters --
            int
            The maximum number of iterations allowed.
            Default: 500
            
        max_fevals --
            int
            The maximum number of function evaluations allowed. 
            Default: 5000
            
        disp --
            bool
            Set to True to print convergence messages.
            Default: True
            
        nbr_cores --
            int
            The number of processor cores used. This is only needed if the 
            function evaluations should be performed in separate processes.
            Default: None
            
        debug --
            bool
            Set to True to get separate error and output files for each
            separate process when using multiprocessing.
            Default: False
            
    Returns::
    
        x_opt --
            ndarray or scalar
            The optimal point which minimizes the objective function.
            
        f_opt --
            float
            The minimal value of the objective function.
        
        nbr_iters --
            int
            The number of iterations performed.
        
        nbr_fevals --
            int
            The number of function evaluations made. Evaluations due to 
            generation of contour plot are not included.    
        
        solve_time --
            float
            The execution time for the solver in seconds.
    """
    
    t0 = time.clock()
    
    # Check that lb < ub
    if ub is not None:  # "None" < everything
        if N.any(lb >= ub):
            raise ValueError, 'Lower bound must be smaller than upper bound.'
    
    # Check that lb < xstart < ub 
    if N.any(xstart <= lb):
        raise ValueError, 'xstart must be larger than lb.'
    if ub is not None:  # "None" < everything
        if N.any(xstart >= ub):
            raise ValueError, 'xstart must be smaller than ub.'
    
    # Check that nbr of cores is provided if multithreading is to be used
    if type(func).__name__ != 'function':
        if nbr_cores is None:
            raise ValueError, 'The number of processor cores used must be provided.'
    
    # Convert xstart to float type array and flatten it so that 
    # len(xstart) can be used even if xstart is a scalar
    xstart = N.asfarray(xstart).flatten()   
    
    # Do the same with lb and ub
    if lb is not None:
        lb = N.asfarray(lb).flatten()
    if ub is not None:
        ub = N.asfarray(ub).flatten()
    
    # Number of dimensions
    n = len(xstart)
    
    # If not two dimensions nothing should be plotted
    if n != 2:
        plot_con = False
        plot_sim = False
    
    if plot_con:
        
        # Create meshgrid
        if lb is None:
            x_min = xstart[0]-3*N.absolute(xstart[0])
            y_min = xstart[1]-3*N.absolute(xstart[1])
        else:
            x_min = lb[0]
            y_min = lb[1]
        if ub is None:
            x_max = xstart[0]+3*N.absolute(xstart[0])
            y_max = xstart[1]+3*N.absolute(xstart[1])
        else:
            x_max = ub[0]
            y_max = ub[1]
        x_vec = N.linspace(x_min,x_max,10)
        y_vec = N.linspace(y_min,y_max,10)
        x_grid,y_grid = N.meshgrid(x_vec,y_vec)
        
        # Compute the contour lines for the objective function
        l = len(x_vec)
        z = N.zeros((l,l))
        if type(func).__name__ == 'function':
            for i in range(l):
                for j in range(l):
                    point = N.array([x_grid[i,j],y_grid[i,j]])
                    z[i,j] = func(point)
        else:
            # Generate points in which to evaluate the function
            points = []
            for i in range(l):
                for j in range(l):
                    points.append(N.array([x_grid[i,j],y_grid[i,j]]))
            # Evaluate function in these points     
            f_values = tf.feval(func,points,debug)
            for i in range(l):
                z[i] = f_values[i*l:(i+1)*l]
    
        # Plot the contour lines for the function
        plt.figure()
        plt.grid()
        plt.axis('equal')
        plt.contour(x_grid,y_grid,z) 
        plt.title('Contour lines for the objective function')
        plt.show()
        
        # Plot lower bounds
        if lb is not None:
            plt.plot(lb[0]*N.ones(len(y_vec)),y_vec)
            plt.plot(x_vec,lb[1]*N.ones(len(x_vec)))
        
        # Plot upper bounds
        if ub is not None:
            plt.plot(ub[0]*N.ones(len(y_vec)),y_vec)
            plt.plot(x_vec,ub[1]*N.ones(len(x_vec)))
    
    # Scale h such that it has the appropriate size compared to xstart
    scale = S.linalg.norm(xstart)
    if scale > 1:
        h = h*scale
    
    # Initial simplex
    X = N.zeros((n+1,n))
    X[0] = xstart
    for i in range(1,n+1):
        X[i] = xstart
        X[i,i-1] = xstart[i-1] + h
    
    if plot_sim:
        # Plot the initial simplex
        plt.plot(N.hstack((X[:,0],X[0,0])),N.hstack((X[:,1],X[0,1])))
        plt.show()
        
    # If the initial simplex has vertices outside the feasible region it 
    # must be shrunk s.t all vertices are inside this region
    if ub is not None:
        for i in range(1,n+1):
            v = X[i]
            if N.any(v >= ub):
                ind = v >= ub
                v[ind] = ub[ind] - 1e-6
                X[i] = v
        if plot_sim:
            # Plot the new initial simplex
            plt.plot(N.hstack((X[:,0],X[0,0])),N.hstack((X[:,1],X[0,1])))
    
    # Number of function evaluations
    nbr_fevals = 0
    
    # Start iterations
    k = 0
    F_val = []
    Shiftfv = []
    Ssize = []
    while k < max_iters and nbr_fevals < max_fevals:
        
        # Function values at the vertices of the current simplex
        if type(func).__name__ == 'function':
            f_val = N.zeros(n+1)
            for i in range(n+1):
                f_val[i] = func(X[i])
                nbr_fevals += 1
        else:
            f_val = tf.feval(func,X,debug)
            nbr_fevals += (n+1)
        
        # Order all vertices s.t f(x0) <= f(x1) <= ... <= f(xn)
        ind = N.argsort(f_val)
        X = X[ind]
        f_val = f_val[ind]
        
        # Save vertex function values for each iteration
        F_val.append(f_val)
        
        t_temp = time.clock()
        t_now = t_temp - t0
        print ' '
        print 'Number of iterations: ' + str(k)
        print 'Number of function evaluations: ' + str(nbr_fevals)
        print 'Current time: ' + str(t_now) + ' s'
        print ' '
        print 'Current x value: ' + str(X[0])
        print 'Current function value: ' + str(f_val[0])
        print ' '
            
        if plot_sim:
            # Plot the current simplex
            plt.plot(N.hstack((X[:,0],X[0,0])),N.hstack((X[:,1],X[0,1])))
            plt.draw()
        
        # CONVERGENCE TESTS
        
        # Domain convergence test
        lengths = N.zeros(n)
        for i in range(n):
            lengths[i] = S.linalg.norm(X[0]-X[i+1])
        ssize = N.max(lengths)
        Ssize.append(ssize)
        term_x = ssize < x_tol
        
        # Function value convergence test
        shiftfv = N.abs(f_val[0]-f_val[n])
        Shiftfv.append(shiftfv)
        term_f = shiftfv < f_tol
        
        print 'Termination criterion for x: ' + str(ssize)
        print 'Termination criterion for the objective function: ' + str(shiftfv)
        print ' '
        
        if term_x or term_f:
            break
        
        # Centroid of the side opposite the worst vertex
        c = 1.0/n*N.sum(X[0:n],0)
        
        # Transformation parameters
        alfa = 1    # 0 < alfa
        beta = 0.5  # 0 < beta < 1
        gamma = 2   # 1 < gamma
        delta = 0.5 # 0 < delta < 1
        
        # Reflection-, Expansion- and Contraction points
        xr = c + alfa*(c-X[n])
        xe = c + gamma*(xr-c)
        xc1 = c + beta*(xr-c)
        xc2 = c - beta*(xr-c)
        
        # If any point ends up outside the feasible region we must move 
        # it inside of the region (xc2 cannot end up outside)
        if ub is not None:
            if N.any(xr >= ub):
                ind = xr >= ub
                xr[ind] = ub[ind] - 1e-6
            if N.any(xe >= ub):
                ind = xe >= ub
                xe[ind] = ub[ind] - 1e-6
            if N.any(xc1 >= ub):
                ind = xc1 >= ub
                xc1[ind] = ub[ind] - 1e-6
        if lb is not None:
            if N.any(xr <= lb):
                ind = xr <= lb
                xr[ind] = lb[ind] + 1e-6
            if N.any(xe <= lb):
                ind = xe <= lb
                xe[ind] = lb[ind] + 1e-6
            if N.any(xc1 <= lb):
                ind = xc1 <= lb
                xc1[ind] = lb[ind] + 1e-6
        
        # Evaluate function in the four ponits      
        if type(func).__name__ == 'function':
            fr = func(xr)
            fe = func(xe)
            fc1 = func(xc1)
            fc2 = func(xc2)
            nbr_fevals += 4
        else:
            if nbr_cores >= 4:
                x_values = N.vstack([xr,xe,xc1,xc2])
                f_values = tf.feval(func,x_values,debug)
                fr = f_values[0]
                fe = f_values[1]
                fc1 = f_values[2]
                fc2 = f_values[3]
                nbr_fevals += 4
            elif nbr_cores == 3:
                x_values = N.vstack([xr,xe,xc1])
                f_values = tf.feval(func,x_values,debug)
                fr = f_values[0]
                fe = f_values[1]
                fc1 = f_values[2]
                nbr_fevals += 3
            elif nbr_cores == 2:
                x_values = N.vstack([xr,xe])
                f_values = tf.feval(func,x_values,debug)
                fr = f_values[0]
                fe = f_values[1]
                nbr_fevals += 2
            elif nbr_cores == 1:
                # This is completely unnecessary but we must compute the
                # function value in a separate process to avoid memory problems
                fr = tf.feval(func,xr,debug)
                nbr_fevals += 1
        
        # Reflection
        if f_val[0] <= fr and fr < f_val[n-1]:
            X[n] = xr
            # Go to next iteration
            k += 1
            continue
        
        # Expansion 
        elif fr < f_val[0]:
            if type(func).__name__ != 'function':
                if nbr_cores == 1:
                    fe = tf.feval(func,xe,debug)
                    nbr_fevals += 1
            if fe < fr:
                X[n] = xe
                # Go to next iteration
                k += 1
                continue
            else:
                X[n] = xr
                # Go to next iteration
                k += 1
                continue
                
        # Contraction       
        elif f_val[n-1] <= fr:
            # Outside contraction
            if fr < f_val[n]:
                if type(func).__name__ != 'function':
                    if nbr_cores == 1 or nbr_cores == 2:
                        fc1 = tf.feval(func,xc1,debug)
                        nbr_fevals += 1
                if fc1 <= fr:
                    X[n] = xc1
                    # Go to next iteration
                    k += 1
                    continue
            # Inside contraction
            else:
                if type(func).__name__ != 'function':
                    if nbr_cores == 1 or nbr_cores == 2 or nbr_cores == 3:
                        fc2 = tf.feval(func,xc2,debug)
                        nbr_fevals += 1
                if fc2 < f_val[n]:
                    X[n] = xc2
                    # Go to next iteration
                    k += 1
                    continue
            # Shrink simplex toward x0
            for i in range(1,n+1):
                X[i] = X[0] + delta*(X[i]-X[0])
            k += 1
            
    # Optimal point and objective function value        
    x_opt = X[0]
    if type(func).__name__ == 'function':
            f_opt = func(x_opt)
    else:
        f_opt = tf.feval(func,x_opt,debug)
    nbr_fevals += 1
    
    # Number of iterations
    nbr_iters = k

    t1 = time.clock()
    solve_time = t1 - t0
    
    # Plot convergence criteria
    if plot_conv:
        iters = range(len(F_val))
        # Plot shiftfv vs iterations
        plt.figure()
        plt.grid()
        plt.plot(iters,Shiftfv,label='shiftfv')
        plt.plot(iters,f_tol*N.ones(len(iters)),label='f_tol = '+str(f_tol))
        plt.legend()
        plt.xlabel('iteration')
        plt.title('shiftfv vs iterations')
        plt.show()
        # Plot ssize vs iterations
        plt.figure()
        plt.grid()
        plt.plot(iters,Ssize,label='ssize')
        plt.plot(iters,x_tol*N.ones(len(iters)),label='x_tol = '+str(x_tol))
        plt.legend()
        plt.xlabel('iteration')
        plt.title('ssize vs iterations')
        plt.show()
    
    # Print convergence results
    if disp:
        print ' '
        print 'Solver: Nelder-Mead'
        print ' '
        if nbr_iters >= max_iters:
            print 'Warning: Maximum number of iterations has been exceeded.'
        elif nbr_fevals >= max_fevals:
            print 'Warning: Maximum number of function evaluations has been exceeded.'
        else:
            print 'Optimization terminated successfully.'
            if term_x:
                print 'Terminated due to sufficiently small simplex.'
            else:
                print 'Terminated due to sufficiently close function values at the vertices of the simplex.'
        print ' '
        print 'Total number of iterations: ' + str(nbr_iters)
        print 'Total number of function evaluations: ' + str(nbr_fevals)
        print 'Total execution time: ' + str(solve_time) + ' s'
        print ' '

    # Return results
    return x_opt, f_opt, nbr_iters, nbr_fevals, solve_time


def seqbar(f,xstart,lb=None,ub=None,mu=0.1,plot=False,x_tol=1e-3,
           q_tol=1e-3,max_iters=1000,max_fevals=5000,disp=True):
    """
    Bounded minimization of a function of one or more variables using 
    a sequential barrier function method which uses the Nelder-Mead 
    simplex method. Handles box bound constraints. Can only be used if 
    some bound (lb or ub or both) is provided.
    
    Parameters::
    
        f --
            callable f(x)
            The objective function to be minimized.
        
        xstart --
            ndarray or scalar
            The initial guess for x. 
            NB: lb < xstart < ub must be fulfilled 
            Default: None
            
        lb -- 
            ndarray or scalar
            The lower bound on x.
            Default: None
        
        ub --
            ndarray or scalar
            The upper bound on x.
            Default: None
        
        mu --
            float
            The initial value of the barrier parameter.
            Default: 0.1
        
        plot --
            bool
            Set to True if contour plots for the objective function and 
            the auxiliary function and plots of the simplex in each 
            Nelder-Mead iteration are desired. The bounds are also 
            plotted.
            NB: Only works for two dimensions.
            
        x_tol --
            float
            The tolerance for the termination criteria for x.
            Default: 1e-3
        
        q_tol --
            float
            The tolerance for the termination criteria for the auxiliary 
            function.
            Default: 1e-3
        
        max_iters --
            int
            The maximum number of iterations allowed.
            Default: 1000
            
        max_fevals --
            int
            The maximum number of function evaluations allowed.
            Default: 5000
        
        disp --
            bool
            Set to True to print convergence messages.
            Default: True
    
    Returns::
    
        x_opt --
            ndarray or scalar
            The optimal point which minimizes the objective function.
        
        f_opt --
            float
            The optimal value of the objective function.
            
        nbr_iters --
            int
            The number of iterations performed.
        
        nbr_fevals --
            int
            The number of function evaluations made.
        
        solve_time --
            float
            The execution time for the solver in seconds.
    """
    
    t0 = time.clock()
    
    # If no bounds are given this function should not be used
    if lb is None and ub is None:
        raise ValueError, 'No bounds given, use function nelme instead.'
    
    # Check that lb < ub
    if ub is not None:  # "None" < everything
        if N.any(lb >= ub):
            raise ValueError, 'Lower bound must be smaller than upper bound.'
    
    # Check that lb < xstart < ub 
    if N.any(xstart <= lb):
        raise ValueError, 'xstart must be larger than lb.'
    if ub is not None:  # "None" < everything
        if N.any(xstart >= ub):
            raise ValueError, 'xstart must be smaller than ub.'
    
    # Convert xstart to float type array and flatten it so that 
    # len(xstart) can be used even if xstart is a scalar
    xstart = N.asfarray(xstart).flatten()   
    
    # Do the same with lb and ub
    if lb is not None:
        lb = N.asfarray(lb).flatten()
    if ub is not None:
        ub = N.asfarray(ub).flatten()
    
    # Auxiliary function
    def q(x):
    
        if lb is None and ub is None:
            out = f(x)
        else:
            if lb is None:
                b = - N.sum(N.log(ub-x))
            elif ub is None:
                b = - N.sum(N.log(x-lb))
            else:
                b = - N.sum(N.log(ub-x)) - N.sum(N.log(x-lb))
            out = f(x) + mu*b

        return out

    # Number of dimensions
    n = len(xstart)
    
    # If not two dimensions nothing should be plotted
    if n != 2:
        plot = False
    
    # Number of iterations and function evaluations
    nbr_iters = 0
    nbr_fevals = 0
    
    if plot:
        
        # Create meshgrid
        if lb is None:
            x_min = xstart[0]-3*N.absolute(xstart[0])
            y_min = xstart[1]-3*N.absolute(xstart[1])
        else:
            x_min = lb[0]+1e-6
            y_min = lb[1]+1e-6
        if ub is None:
            x_max = xstart[0]+3*N.absolute(xstart[0])
            y_max = xstart[1]+3*N.absolute(xstart[1])
        else:
            x_max = ub[0]-1e-6
            y_max = ub[1]-1e-6
        x_vec = N.linspace(x_min,x_max,10)
        y_vec = N.linspace(y_min,y_max,10)
        x_grid,y_grid = N.meshgrid(x_vec,y_vec)
        
        # Compute the contour lines for f
        l = len(x_vec)
        z = N.zeros((l,l))
        for i in range(l):
            for j in range(l):
                point = N.array([x_grid[i,j],y_grid[i,j]])
                z[i,j] = f(point)
                nbr_fevals += 1
        
        # Plot the contour lines for f
        plt.figure()
        plt.grid()
        plt.axis('equal')
        plt.contour(x_grid,y_grid,z) 
        plt.title('Contour lines for the objective function f')
        plt.show()
        
        # Plot lower bounds
        if lb is not None:
            plt.plot(lb[0]*N.ones(len(y_vec)),y_vec)
            plt.plot(x_vec,lb[1]*N.ones(len(x_vec)))
        
        # Plot upper bounds
        if ub is not None:
            plt.plot(ub[0]*N.ones(len(y_vec)),y_vec)
            plt.plot(x_vec,ub[1]*N.ones(len(x_vec)))
    
    # The side length for the initial simplex 
    h = 0.3
    
    # Start iterations
    x_pre = xstart
    k = 0
    while nbr_iters < max_iters and nbr_fevals < max_fevals:
        
        # Only plot the five first steps in order to save time
        if k > 4:
            plot = False
        
        if plot:
            # Plot the countour lines of the auxiliary function q for the 
            # current mu
            if lb is None:
                b = - N.log(ub[0]-x_grid) - N.log(ub[1]-y_grid)
            elif ub is None:
                b = - N.log(x_grid-lb[0]) - N.log(y_grid-lb[1])
            else:
                b = - N.log(ub[0]-x_grid) - N.log(ub[1]-y_grid)\
                    - N.log(x_grid-lb[0]) - N.log(y_grid-lb[1])
            Z = z + mu*b 
            print 'Z: ' + str(Z)
            plt.figure()
            plt.grid()
            plt.axis('equal')
            plt.contour(x_grid,y_grid,Z)
            plt.title('Contour lines for the auxiliary function q with mu = ' + str(mu))
            plt.show()              
            
        # Previous q value
        q_pre = q(x_pre)
        nbr_fevals += 1
        
        # Minimize q with Nelder-Mead
        x_new,q_new,iters,func_evals,solve_time = nelme(q,x_pre,lb=lb,ub=ub,h=h,
                                                        plot_sim=plot,disp=False)
        
        # Increase number of iterations and function evaluations
        nbr_iters += iters
        nbr_fevals += func_evals
        
        # Increase k
        k += 1
        
        # CONVERGENCE TESTS
        
        # Termination criteria for x
        x_pre_norm = S.linalg.norm(x_pre)
        if x_pre_norm == 0:
            term_x = S.linalg.norm(x_new - x_pre) < x_tol
        else:   
            term_x = S.linalg.norm(x_new - x_pre)/x_pre_norm < x_tol
            
        # Termination criteria for q
        q_pre_norm = S.linalg.norm(q_pre)
        if q_pre_norm == 0:
            term_q = S.linalg.norm(q_new - q_pre) < q_tol
        else:
            term_q = S.linalg.norm(q_new - q_pre)/q_pre_norm < q_tol
        
        if term_x or term_q:
            break
        
        # Reduce the barrier parameter for next iteration
        mu = 0.5*mu
        
        # Reduce the side length for the initial simplex in Nelder-Mead
        h = 0.5*h
        
        # Update x
        x_pre = x_new
    
    # Optimal point and function value
    x_opt = x_new
    f_opt = f(x_opt)
    nbr_fevals += 1
        
    t1 = time.clock()
    solve_time = t1 - t0
    
    # Print convergence results
    if disp:
        print ' '
        print 'Solver: Sequential barrier method with Nelder-Mead'
        print ' '
        if nbr_iters >= max_iters:
            print 'Warning: Maximum number of iterations has been exceeded.'
        elif nbr_fevals >= max_fevals:
            print 'Warning: Maximum number of function evaluations has been exceeded.'
        else:
            print 'Optimization terminated successfully.'
            if term_x:
                print 'Termination criteria for x was fulfilled.'
            else:
                print 'Termination criteria for auxiliary function was fulfilled.'
        print ' '
        print 'Number of iterations: ' + str(nbr_iters)
        print 'Number of function evaluations: ' + str(nbr_fevals)
        print ' '
        print 'Execution time: ' + str(solve_time) + ' s'
        print ' '
    
    # Return results
    return x_opt, f_opt, nbr_iters, nbr_fevals, solve_time


def de(f,lb,ub,plot=False,x_tol=1e-6,f_tol=1e-6,max_iters=1000,
       max_fevals=10000,disp=True):
    """
    Minimize a function of one or more variables using the OpenOpt 
    solver 'de' which is a GLP solver based on the Differential 
    Evolution method. Handles box bound constraints. Can only be used if 
    bounds (both lb and ub) are provided. Requires the OpenOpt package 
    installed.
    
    Parameters::
    
        f -- 
            callable f(x)
            The objective function to be minimized.
        
        lb -- 
            ndarray or scalar
            The lower bound on x.
    
        ub --
            ndarray or scalar
            The upper bound on x.
    
        plot --
            bool
            Set to True if a graph of the objective function value over 
            time is desired.
            Default: False
    
        x_tol --
            float
            The tolerance for the termination criteria for x.
            Default: 1e-6
            
        f_tol --
            float
            The tolerance for the termination criteria for the objective 
            function.
            Default: 1e-6
        
        max_iters --
            int
            The maximum number of iterations allowed.
            Default: 1000
            
        max_fevals --
            int
            The maximum number of function evaluations allowed.
            Default: 10000
        
        disp --
            bool
            Set to True to print convergence messages.
            Default: True
        
    Returns::
        
        x_opt --
            ndarray or scalar
            The optimal point which minimizes the objective function.
                
        f_opt --
            float
            The minimal value of the objective function.
        
        nbr_iters --
                int
                The number of iterations performed.
            
        nbr_fevals --
            int
            The number of function evaluations made.
            
        solve_time --
            float
            The execution time for the solver in seconds.
    """
    
    # Check that lb < ub
    if N.any(lb >= ub):
        raise ValueError, 'Lower bound must be smaller than upper bound.'
    
    if plot:
        plt.figure()
    
    if disp:
        iprint = 0
    else:
        iprint = -1
    
    # Construct the problem
    p = GLP(f,lb=lb,ub=ub,maxIter=max_iters,maxFunEvals=max_fevals)
    
    # Solve the problem
    solver = 'de'
    r = p.solve(solver,plot=plot,xtol=x_tol,ftol=f_tol,iprint=iprint)
    
    # Get results   
    x_opt, f_opt = r.xf, r.ff
    d1 = r.evals
    d2 = r.elapsed
    nbr_iters = d1['iter']
    nbr_fevals = d1['f']
    solve_time = d2['solver_time']
    
    if disp:
        print ' '
        print 'Solver: OpenOpt solver ' + solver
        print ' '
        print 'Number of iterations: ' + str(nbr_iters)
        print 'Number of function evaluations: ' + str(nbr_fevals)
        print ' '
        print 'Execution time: ' + str(solve_time)
        print ' '
    
    # Return results
    return x_opt, f_opt, nbr_iters, nbr_fevals, solve_time


def galileo(f,lb,ub,plot=False,x_tol=1e-6,f_tol=1e-6,max_iters=1000,
            max_fevals=10000,disp=True):
    """
    Minimize a function of one or more variables using the OpenOpt 
    solver 'galileo' which is a GLP solver based on a Genetic Algorithm. 
    Handles box bound constraints. Can only be used if bounds (both lb 
    and ub) are provided. Requires the OpenOpt package installed.
    
    Parameters::
    
        f -- 
            callable f(x)
            The objective function to be minimized.
        
        lb -- 
            ndarray or scalar
            The lower bound on x.
    
        ub --
            ndarray or scalar
            The upper bound on x.
    
        plot --
            bool
            Set to True if a graph of the objective function value over 
            time is desired.
            Default: False
    
        x_tol --
            float
            The tolerance for the termination criteria for x.
            Default: 1e-6
            
        f_tol --
            float
            The tolerance for the termination criteria for the objective 
            function.
            Default: 1e-6
        
        max_iters --
            int
            The maximum number of iterations allowed.
            Default: 1000
            
        max_fevals --
            int
            The maximum number of function evaluations allowed.
            Default: 10000
        
        disp --
            bool
            Set to True to print convergence messages.
            Default: True
        
    Returns::
        
        x_opt --
            ndarray or scalar
            The optimal point which minimizes the objective function.
                
        f_opt --
            float
            The minimal value of the objective function.
        
        nbr_iters --
                int
                The number of iterations performed.
            
        nbr_fevals --
            int
            The number of function evaluations made.
            
        solve_time --
            float
            The execution time for the solver in seconds.
    """
    
    # Check that lb < ub
    if N.any(lb >= ub):
        raise ValueError, 'Lower bound must be smaller than upper bound.'
    
    if plot:
        plt.figure()
    
    if disp:
        iprint = 0
    else:
        iprint = -1
    
    # Construct the problem
    p = GLP(f,lb=lb,ub=ub,maxIter=max_iters,maxFunEvals=max_fevals)
    
    # Solve the problem
    solver = 'galileo'
    r = p.solve(solver,plot=plot,xtol=x_tol,ftol=f_tol,iprint=iprint)
    
    # Get results   
    x_opt, f_opt = r.xf, r.ff
    d1 = r.evals
    d2 = r.elapsed
    nbr_iters = d1['iter']
    nbr_fevals = d1['f']
    solve_time = d2['solver_time']
    
    if disp:
        print ' '
        print 'Solver: OpenOpt solver ' + solver
        print ' '
        print 'Number of iterations: ' + str(nbr_iters)
        print 'Number of function evaluations: ' + str(nbr_fevals)
        print ' '
        print 'Execution time: ' + str(solve_time)
        print ' '
    
    # Return results
    return x_opt, f_opt, nbr_iters, nbr_fevals, solve_time


def fmin(func,xstart=None,lb=None,ub=None,alg=None,plot=False,plot_conv=False,
         x_tol=1e-6,f_tol=1e-6,max_iters=1000,max_fevals=10000,disp=True,
         nbr_cores=None,debug=False):
    """
    Minimize a function of one or more variables using a derivative-free 
    method which can be chosen from the following alternatives: 
        1. The Nelder-Mead simplex method. Handles box bound constraints 
           but it cannot be guaranteed that it works well for all situations.
        2. A sequential barrier function method which uses the 
           Nelder-Mead simplex method. Handles box bound constraints. 
           Can only be chosen if some bound (lb or ub or both) is 
           provided.
        3. The OpenOpt solver 'de' which is a GLP solver based on the
           Differential Evolution method. Handles box bound constraints. 
           Can only be chosen if bounds (both lb and ub) are provided.
        4. The OpenOpt solver 'galileo' which is a GLP solver based on a
           Genetic Algorithm. Handles box bound constraints. Can only be 
           chosen if bounds (both lb and ub) are provided.
           
    If the Nelder-Mead method is chosen, then all function evaluations in 
    the algorithm can be performed in separate processes (multiprocessing)
    to save memory. For example, when the function evaluation involves the 
    loading of an FMU, there is a risk of running out of memory after a 
    number of function evaluations. In that case, this feature is quite 
    useful. The feature is applied if the user provides the objective 
    function (func) as a file name (of a file containing the definition 
    of the function) instead of a function.
    
    NB: If the function is provided this way and an FMU is loaded inside the
        function, then the FMU file name must be preceded by "../" when
        using FMUModel(), like this: 
        
            model = FMUModel('../fmu_name.fmu')
        
        The reason for this is that the function evaluations are performed
        in sub-directories to the working directory when multiprocessing 
        is used.
    
    Parameters::
    
        func --
            callable func(x) or string
            The objective function OR the name of a python file 
            containing the definition of the objective function. In case 
            of a file name, the objective function in the file must 
            have the same name as the file itself (without ".py") and this
            feature is only available when using the Nelder-Mead method.
        
        xstart --
            ndarray or scalar
            The initial guess for x. 
            NB: Must be provided if alg = 1 or alg = 2 is chosen.
                lb < xstart < ub must be fulfilled.
            Default: None
            
        lb -- 
            ndarray or scalar
            The lower bound on x.
            Default: None
        
        ub --
            ndarray or scalar
            The upper bound on x.
            Default: None
            
        alg --
            int
            The number of the desired optimization method to be used:
                1 = The Nelder-Mead simplex method. 
                2 = A sequential barrier function method which uses 
                    the Nelder-Mead simplex method. 
                3 = The OpenOpt solver 'de' which is a GLP solver based 
                    on the Differential Evolution method.
                4 = The OpenOpt solver 'galileo' which is a GLP solver based 
                    on a Genetic Algorithm.
            Default: None
        
        plot --
            bool
            Set to True if graphic output is desired: 
                If alg = 1: The contour lines for the objective function 
                            are plotted once and the simplex is plotted 
                            in each iteration. The bounds (if any) are 
                            also plotted.
                If alg = 2: The contour lines for the objective function 
                            are plotted once, the contour lines for the 
                            auxiliary function are plotted in each step
                            (for each mu-value) and the simplex is 
                            plotted in each Nelder-Mead iteration. The 
                            bounds are also plotted.
                If alg = 3: A graphic output from OpenOpt is given where
                            the objective function value is plotted over
                            time. It also shows the name of the OpenOpt
                            solver: "de".
                If alg = 4: A graphic output from OpenOpt is given where
                            the objective function value is plotted over
                            time. It also shows the name of the OpenOpt
                            solver: "galileo".
            NB: Only works for two dimensions.
            Default: False
        
        plot_conv --
            bool
            Set to True to get two plots with the convergence criteria for 
            x and the objective function vs the iterations.
            NB: Only works for the Nelder-Mead method (alg = 1).
            Default: False
            
        x_tol --
            float
            The tolerance for the termination criteria for x.
            Default: 1e-6
        
        f_tol --
            float
            The tolerance for the termination criteria for the objective 
            function.
            Default: 1e-6
        
        max_iters --
            int
            The maximum number of iterations allowed.
            Default: 1000
            
        max_fevals --
            int
            The maximum number of function evaluations allowed.
            Default: 10000
        
        disp --
            bool
            Set to True to print convergence messages.
            Default: True
        
        nbr_cores --
            int
            The number of processor cores used. This is only needed if the
            Nelder-Mead algorithm is to be used and the function evaluations 
            should be performed in separate processes.
            Default: None
            
        debug --
            bool
            Set to True to get separate error and output files for each
            separate process when using Nelder-Mead with multiprocessing.
            Default: False
    
    Returns::
    
        x_opt --
            ndarray or scalar
            The optimal point which minimizes the objective function.
        
        f_opt --
            float
            The optimal value of the objective function.
            
        nbr_iters --
            int
            The number of iterations performed.
        
        nbr_fevals --
            int
            The number of function evaluations made.
        
        solve_time --
            float
            The execution time for the solver in seconds.
    """
    
    # If no algorithm is chosen then alg = 1 is used.
    if alg is None:
        alg = 1
    
    # Check that the choice of alg is allowed concerning lb and ub
    if lb is None and ub is None:
        if alg == 2:
            raise ValueError, 'Method 2 can only be chosen if bounds are provided.'
        if alg == 3:
            raise ValueError, 'Method 3 can only be chosen if bounds are provided.'
        if alg == 4:
            raise ValueError, 'Method 4 can only be chosen if bounds are provided.'
    elif lb is None or ub is None:
        if alg == 3:
            raise ValueError, 'Method 3 can only be chosen if both upper and lower bounds are provided.'
        if alg == 4:
            raise ValueError, 'Method 4 can only be chosen if both upper and lower bounds are provided.'
                              
    # Check that xstart is given if alg = 1 or 2                          
    if alg == 1 or alg == 2:
        if xstart is None:
            raise ValueError, 'Methods 1 and 2 require a starting point.'
    
    if type(func).__name__ != 'function':
        if alg != 1:
            raise ValueError, 'If other than the Nelder-Mead method is chosen, func must be of function type.'
    
    # Solve the problem
    if alg == 1:
        x_opt,f_opt,nbr_iters,nbr_fevals,solve_time = nelme(func,xstart,lb=lb,ub=ub,
                                                               plot_con=plot,plot_sim=plot,
                                                               plot_conv=plot_conv,
                                                               x_tol=x_tol,f_tol=f_tol,
                                                               max_iters=max_iters,
                                                               max_fevals=max_fevals,
                                                               disp=disp,nbr_cores=nbr_cores,
                                                               debug=debug)
    elif alg == 2:
        x_opt,f_opt,nbr_iters,nbr_fevals,solve_time = seqbar(func,xstart,lb=lb,ub=ub,
                                                                plot=plot,x_tol=x_tol,
                                                                q_tol=f_tol,
                                                                max_iters=max_iters,
                                                                max_fevals=max_fevals,
                                                                disp=disp)
    
    elif alg == 3:
        x_opt,f_opt,nbr_iters,nbr_fevals,solve_time = de(func,lb,ub,plot=plot,x_tol=x_tol,
                                                            f_tol=f_tol,max_iters=max_iters,
                                                            max_fevals=max_fevals,disp=disp)
    
    else:
        x_opt,f_opt,nbr_iters,nbr_fevals,solve_time = galileo(func,lb,ub,plot=plot,x_tol=x_tol,
                                                            f_tol=f_tol,max_iters=max_iters,
                                                            max_fevals=max_fevals,disp=disp)
    
    # Return results
    return x_opt, f_opt, nbr_iters, nbr_fevals, solve_time

def quad_err_simple(t_meas,y_meas,t_sim,y_sim, w=None):
    # The number of dimensions of y_meas
    dim1 = N.ndim(y_meas)
    
    # The number of rows and columns in y_meas
    if dim1 == 1:
        m1 = 1
        n1 = len(y_meas)
    else:
        m1 = N.size(y_meas,0)
        n1 = N.size(y_meas,1)
    
    if w is None:
        if dim1 == 1:
            w = 1
        else:
            w = N.ones(m1)
    
    # The number of measurement points
    n = n1
    
    # The number of rows in y_meas and y_sim
    m = m1
    
    # Interpolate to get the simulated values in the measurement points
    if m == 1:
        Y_sim = N.interp(t_meas,t_sim,y_sim)
    else:
        Y_sim = N.zeros([m,n])
        for i in range(m):
            Y_sim[i] = N.interp(t_meas,t_sim,y_sim[i])

    # Evaluate the error
    X = Y_sim - y_meas
    if m == 1:
        err = N.sum(X**2,0)
    else:
        qX2 = N.dot(w,X**2)
        err = sum(qX2)
    return err

def quad_err(t_meas,y_meas,t_sim,y_sim,w=None):
    """
    Compute the quadratic error sum for the difference between 
    measurements and simulation results. The measurements and the 
    simulation results do not have to be given at the same time points.
    
    Parameters::
        
        t_meas --
            ndarray (of 1 dimension)
            The measurement time points.
            
        y_meas --
            ndarray (of 1 or 2 dimensions)
            The measurement values. The number of rows in the 
            array corresponds to the number of physical quantities
            measured.
            NB: Must have same length as t_meas and same number of 
                rows as y_sim.
        
        t_sim --
            ndarray (of 1 dimension)
            The simulation time points. 
            NB: Must be increasing.
            
        y_sim --
            ndarray (of 1 or 2 dimensions)
            The simulation values. The number of rows in the array 
            corresponds to the number of physical quantities simulated.
            NB: Must have same length as t_sim and same number of 
                rows as y_meas.
                
        w --
            scalar or ndarray (of 1 dimension)
            Scaling factor(s). If y_meas and y_sim are 1-dimensional, then
            w must be a scalar. Otherwise, w must be a 1-dimensional array
            with the same number of elements as the number of rows in y_meas 
            and y_sim.          
            Example: If w = [w1 w2 w2], then the first row in y_meas and 
            y_sim is multiplied with w1, the second with w2 and the third 
            with w3.
            If w is not supplied, then it is set to 1 or a 1-dimensional 
            array of ones.
            Default: None 
            
    Returns::
    
        err --
            float
            The quadratic error.
    """
    
    # The number of dimensions of y_meas
    dim1 = N.ndim(y_meas)
    
    # The number of rows and columns in y_meas
    if dim1 == 1:
        m1 = 1
        n1 = len(y_meas)
    else:
        m1 = N.size(y_meas,0)
        n1 = N.size(y_meas,1)
    
    # The number of dimensions of y_sim
    dim2 = N.ndim(y_sim)
    
    # The number of rows and columns in y_sim
    if dim2 == 1:
        m2 = 1
        n2 = len(y_sim)
    else:
        m2 = N.size(y_sim,0)
        n2 = N.size(y_sim,1)
    
    if len(t_meas) != n1:
        raise ValueError, 't_meas and y_meas must have the same length.'
    
    if len(t_sim) != n2:
        raise ValueError, 't_sim and y_sim must have the same length.'
    
    if m1 != m2:
        raise ValueError, 'y_meas and y_sim must have the same number of rows.'
    
    if not N.all(N.diff(t_sim) >= 0):
        raise ValueError, 't_sim must be increasing.'
    
    if w is None:
        if dim1 == 1:
            w = 1
        else:
            w = N.ones(m1)
    else:
        if dim1 == 1:
            if N.ndim(w) != 0:
                raise ValueError, 'w must be a scalar since y_meas and y_sim only have one dimension.'
        else:
            if N.ndim(w) != 1:
                raise ValueError, 'w must be a 1-dimensional array since y_meas and y_sim are 2-dimensional.'
            if (len(w) != m1):
                raise ValueError, 'w must have the same length as the number of rows in y_meas and y_sim.'
            
    # The number of measurement points
    n = n1
    
    # The number of rows in y_meas and y_sim
    m = m1
    
    # Interpolate to get the simulated values in the measurement points
    Y_sim = N.zeros([m,n])
    if m == 1:
        Y_sim = N.interp(t_meas,t_sim,y_sim)
    else:
        for i in range(m):
            Y_sim[i] = N.interp(t_meas,t_sim,y_sim[i])
    
    # Check if the same time point occurs more than once in t_sim and 
    # then fix the problem
    for i in range(len(t_sim)):
        val = t_sim[i]
        rest = t_sim[i+1:]
        if val in rest and val in t_meas:
            ind1 = t_sim == val
            y_sim_val = y_sim[:,ind1]
            ind2 = t_meas == val
            if m == 1:
                Y_sim[:,ind2] = sum(y_sim_val)*1.0/len(y_sim_val)
            else:
                vec = N.sum(y_sim_val,1)*1.0/N.size(y_sim_val,1)
                for j in range(m):
                    Y_sim[j,ind2] = vec[j]
    
    # Evaluate the error
    X = Y_sim - y_meas
    if m == 1:
        err = w*sum(X**2,0)
    else:
        qX2 = N.dot(w,X**2)
        err = sum(qX2)
    return err
