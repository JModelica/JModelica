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
This file contains code for preforming multiple shooting using the
simulation package Assimulo.
"""


import numpy as N
import pylab as P
from scipy.optimize import slsqp

try:
    from openopt import NLP
except ImportError:
    print "Could not load OpenOpt."
    

class Multiple_Shooting_Exception(Exception):
    """
    A mutiple shooting exception.
    """
    pass

class Multiple_Shooting(object):
    
    def __init__(self, simulator, gridsize, initial_u):
        """
        Initiates the shooting algorithm.
        """
        #Set default parameters
        self.set_default_param()
        
        
        self.simulator = simulator
        self.model = simulator._problem._model
        self.gridsize = gridsize
        
        self.nbr_us = len(self.model.real_u)
        self.nbr_ys = len(self.model.real_x)
        
        self.start_time = self.model.opt_interval_get_start_time()
        self.final_time = self.model.opt_interval_get_final_time()
    
        self.initial_u = initial_u
        self.initial_y = self.model.real_x.copy()
        
        #Sets the verbosity, default=NORMAL
        self.verbosity = Multiple_Shooting.NORMAL
    
    def set_default_param(self):
        """
        Sets the default parameters for the optimizer.
        """
        self.maxFeval = 1e5
        self.maxIter = 400
        self.optMethod = 'scipy_slsqp'
        self.ftol = 1e-6
        self.maxTime = 700
    
    def check_initial_u(self):
        """
        Helper function to determine the initial guess of the inputs.
        """
        #TODO
        #HANDLE NUMPY ARRAYS
        u = N.array([])
        
        if self.nbr_us == 1:
            if type(self.initial_u) == 'list' or type(self.initial_u[0]) == 'numpy.ndarray':
                if len(self.initial_u) == self.gridsize:
                    u = N.array(self.initial_u)
                else:
                    raise Multiple_Shooting_Exception('Undefined initial guess of inputs.')
            else:
                u = N.array(self.initial_u*self.gridsize)
        else:
            try:
                len(self.initial_u)
            except TypeError:
                raise Multiple_Shooting_Exception('Undefined initial guess of inputs.')
                
            if len(self.initial_u) == self.nbr_us:
                if type(self.initial_u[0]) == 'list' or type(self.initial_u[0]) == 'numpy.ndarray':
                    if len(self.initial_u) == self.gridsize:
                        u = N.array(self.initial_u)
                    else:
                        raise Multiple_Shooting_Exception('Undefined initial guess of inputs.')
                else:
                    u = N.array(self.initial_u*self.gridsize)
                
            if len(self.initial_u) == self.gridsize:
                if type(self.initial_u[0]) != 'list' and type(self.initial_u[0]) != 'numpy.ndarray':
                    if len(self.initial_u) == self.nbr_us:
                        u = N.array(self.initial_u*self.gridsize)
                    else:
                        raise Multiple_Shooting_Exception('Undefined initial guess of inputs.')
                else:
                    u = N.array(self.initial_u)
        
        if len(u) == 0:
            raise Multiple_Shooting_Exception('Undefined initial guess of inputs.')
        
        return u
    
    def get_p0(self):
        """
        Creates a grid of the problem and returns the parameters to
        be optimized over.
        """
        y = N.array([])
        u = self.check_initial_u();
        

        self.simulator.reset() #Reset the simulator before creating the initial guess for the ys
        
        self.model.real_u = u[0:self.nbr_us]
        
        for i in range(self.gridsize-1):
            #Make a simulation across the interval to get an initial guess for the ys
            final_time = (self.final_time-self.start_time)/self.gridsize*(i+1)
            
            [ts, ys] = self.simulator(final_time)
            self.model.real_u = u[self.nbr_us*(i+1):self.nbr_us*(i+2)]
            self.simulator.re_init(final_time,ys[-1]) #Re initiates the solver to the new values

            y = N.append(y,ys[-1].flatten())

        return N.append(u,y)

    
    def split_p(self, p):
        """
        Splits the parameter vector into its input and y.
        """
        u = p[0:self.nbr_us*self.gridsize]
        y = p[self.nbr_us*self.gridsize:]

        u = u.reshape(self.gridsize,self.nbr_us)
        y = N.append(self.initial_y,y)
        y = y.reshape(self.gridsize,self.nbr_ys)
        
        return [u, y]
    
    def f(self, p):
        """
        This is our cost function to be optimized over.
        """
        
        [u, y] = self.split_p(p)
        
        if self.verbosity >= Multiple_Shooting.SCREAM:
            print 'Calculating cost...'
            print 'Input u:', u[-1]
            print 'Input y: ', y[-1,:-1]
        
        start_time = (self.final_time-self.start_time)/self.gridsize*(self.gridsize-1)

        try:
            self.model.real_u = u[-1]
            self.simulator.re_init(start_time,y[-1]) #Re initiates the solver to the new values
            [ts, ys] = self.simulator(self.final_time,1) #Run the simulation to final time
            
            self.model.real_u = u[-1]
            self.model.real_x = ys[-1]
            
            #Set values for calculation of the cost function
            self.model.set_real_x_p(ys[-1], 0)
            self.model.set_real_dx_p(self.model.real_dx, 0)
            self.model.set_real_u_p(u[-1], 0)
            
            cost = self.model.opt_eval_J() #Evaluate the cost function
        except:
            cost = N.array(N.nan)
        
        if  self.verbosity >= Multiple_Shooting.WHISPER:
            print 'Evaluating cost:', cost
        #if  self.verbosity >= Multiple_Shooting.SCREAM:
        #    print 'Evaluating cost: (u, y) = ', u[-1], ys[-1]

        return cost
    
    def h(self, p):
        """
        These are the equility constraints that arises from optimizing
        over intervals. 
        """
        u, y = self.split_p(p)
        
        if self.verbosity >= Multiple_Shooting.SCREAM:
            print 'Calculating constraints...'
            print 'Input u:', u
            print 'Input y: ', y
        
        y_calc = N.array([])

        for i in range(self.gridsize-1):
            
            start_time = (self.final_time-self.start_time)/self.gridsize*i
            final_time = (self.final_time-self.start_time)/self.gridsize*(i+1)
            
            self.model.real_u = u[i]
            self.simulator.re_init(start_time, y[i])
            try:
                [t, y_sol] = self.simulator(final_time, 1)
            except:
                y_sol = [N.array([N.nan]*self.nbr_ys)]
                
            y_calc = N.append(y_calc,y_sol[-1].flatten())
            
        y_calc = y_calc.reshape(self.gridsize-1,self.nbr_ys)
            
        cons = y[1:,:]-y_calc[:,:]
        cons = cons.flatten()
            
        if self.verbosity >= Multiple_Shooting.SCREAM:
            print 'Equility constraints: ', cons.sum()

        return cons
        
    def run(self, plot=True):
        """
        Solves the optimization problem.
        """        
        # Initial try
        p0 = self.get_p0()
        
        #Lower bounds and Upper bounds (HARDCODED FOR QUADTANK)
        lbound = N.array([0.0001]*len(p0))
        if self.gridsize == 1:
            ubound = [10.0]*(self.gridsize*self.nbr_us)
        else:
            ubound = [10.0]*(self.gridsize*self.nbr_us) + [0.20,0.20,0.20,0.20,N.inf]*((self.gridsize-1))

        
        #UPPER BOUND FOR VDP
        #ubound = [0.75]*(self.gridsize*self.nbr_us)+[N.inf]*((self.gridsize-1)*self.nbr_ys)
        
        if self.verbosity >= Multiple_Shooting.NORMAL:
            print 'Initial parameter vector: '
            print p0
            print 'Lower bound:', len(lbound)
            print 'Upper bound:', len(ubound)

        # Get OpenOPT handler
        p_solve = NLP(self.f,p0,lb = lbound, ub=ubound,maxFunEvals = self.maxFeval, maxIter = self.maxIter, ftol=self.ftol, maxTime=self.maxTime)
        
        #If multiple shooting is preformed or single shooting
        if self.gridsize > 1:
            p_solve.h  = self.h
        
        if plot:
            p_solve.plot = 1

        self.opt = p_solve.solve(self.optMethod)        
        
        return self.opt
        
    def _set_opt_method(self, method):
        """
        Sets the optimization method to use.
        """
        self.__optMethod = method
        
    def _get_opt_method(self):
        """
        Returns the optimization method.
        """
        return self.__optMethod
    
    optMethoddocstring = 'Optimization method to use.'
    optMethod = property(_get_opt_method, _set_opt_method, doc=optMethoddocstring)
    
    def _set_max_Iter(self, iter):
        """
        Sets the maximum number of iterations tolerated by the optimizer.
        
            Default = 400
        """
        self.__maxIter = iter
        
    def _get_max_Iter(self):
        """
        Gets the maximum number of iterations tolerated by the optimizer.
        """
        return self.__maxIter
        
    maxIterdocstring = 'Get/Sets the maximum numer of iterations tolerated.'
    maxIter = property(_get_max_Iter, _set_max_Iter, doc=maxIterdocstring)
    
    def _set_max_Feval(self, feval):
        """
        Sets the maximum number of function evaluations tolerated by
        the optimizer.
        
            Default=1e5
        """
        self.__maxFeval = feval
        
    def _get_max_Feval(self):
        """
        Gets the maximum number of function evaluations tolerated by
        the optimizer.
        """
        return self.__maxFeval
        
    maxFevaldocstring = 'Get/Sets the maximum number of function evaluations tolerated.'
    maxFeval = property(_get_max_Feval, _set_max_Feval, doc=maxFevaldocstring)
    
    def plot(self):
        """
        Plots the solution.
        """
        [u, y] = self.split_p(self.opt.xf)

        ts = N.array([])
        ys = N.array([])
        
        for i in range(self.gridsize):
            
            start_time = (self.final_time-self.start_time)/self.gridsize*i
            final_time = (self.final_time-self.start_time)/self.gridsize*(i+1)
            
            self.model.u = u[i]
            if i == 0:
                self.simulator.re_init(start_time, y[i])
            
            [tl, yl] = self.simulator(final_time, 500)
            
            if i == self.gridsize-1:
                ts = N.append(ts, tl)
                ys = N.append(ys, yl)
        
        ys = ys.reshape(len(ts), self.nbr_ys) #Dont plot the cost function
        ys = ys[:,:-1]
        
        legend_y = []
        for i in range(self.nbr_ys-1):
            legend_y = legend_y + ['State y%s'%(i+1)]
        
        P.figure(1)
        P.plot(ts, ys)
        P.grid(True)
        P.title('Solution (states)')
        P.legend(legend_y)
        P.figure(2)
        
        u_plot = N.zeros([len(self.model.u)+1, self.gridsize*2])
        
        for i in range(self.gridsize):
            start_time = (self.final_time-self.start_time)/self.gridsize*i
            final_time = (self.final_time-self.start_time)/self.gridsize*(i+1)
            u_plot[0,i*2:i*2+2] = [start_time, final_time]
            
            for j in range(len(self.model.u)):
                u_plot[j+1,i*2:i*2+2] = [u[i][j], u[i][j]]
        
        for j in range(len(self.model.u)):
            P.subplot(len(self.model.u), 1, j+1)
            P.plot(u_plot[0,:], u_plot[j+1,:])#, label='Input u%s'%(j+1))
            P.legend(['Input u%s'%(j+1)])
            P.grid(True)
            
        P.suptitle('Control/Input Signals')
        P.show()
        
    #Verbosity levels
    QUIET = 0
    WHISPER = 1
    NORMAL = 2
    LOUD = 3
    SCREAM = 4
    VERBOSE_VALUES = [QUIET, WHISPER, NORMAL, LOUD, SCREAM]
    def _get_verbosity(self):
        """Return the verbosity of the optimization."""
        return self.__verbosity
        
    def _set_verbosity(self, verbosity):
        """
        Sets the verbosity of the optimization. The verbosity levels are used to
        determine the amount of output from the optimization the user wishes to receive.
        
        These are the options:
            QUIET = 0
            WHISPER = 1
            NORMAL = 2
            LOUD = 3
            SCREAM = 4
        """
        if verbosity not in self.VERBOSE_VALUES:
            raise ODE_Exception('Verbosity values must be within %s - %s'%(self.QUIET, self.SCREAM))
        self.__verbosity = verbosity
        
    verbositydocstring = 'Determine the output level from the optimization.'
    verbosity = property(_get_verbosity, _set_verbosity,doc=verbositydocstring)
