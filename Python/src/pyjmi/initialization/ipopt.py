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
The IPOPT solver module. 
"""
import ctypes as ct
from ctypes import byref
import numpy as N
import numpy.ctypeslib as Nct

from pyjmi.jmi import JMIException, IpoptException, _translate_value_ref, _returns_ndarray
from pyjmi.jmi_io import export_result_dymola as jmi_io_export_result_dymola

int = N.int32
N.int = N.int32

c_jmi_real_t = ct.c_double

class InitializationOptimizer(object):
    """ 
    An interface to the NLP solver Ipopt. 
    """
    
    def __init__(self, nlp_init):
        """ 
        Class for solving a DAE initialization problem my means of optimization 
        using IPOPT.
        
        Parameters::
        
            nlp_init -- 
                The NLPInitialization object.
        """
        
        self._nlp_init = nlp_init
        self._ipopt_init = ct.c_voidp()
        
        self._set_initOpt_typedefs()
        
        try:
            assert self._nlp_init._jmi_model._dll.jmi_init_opt_ipopt_new(
                byref(self._ipopt_init), self._nlp_init._jmi_init_opt) == 0, \
                   "jmi_init_opt_ipopt_new returned non-zero"
        except AttributeError as e:
            raise JMIException(
                "Can not create InitializationOptimizer object. \ "
                "Please recompile model with target='ipopt")
        
        assert self._ipopt_init.value is not None, \
               "jmi struct not returned correctly"
               
    def _set_initOpt_typedefs(self):
        try:
            self._nlp_init._jmi_model._dll.jmi_init_opt_ipopt_new.argtypes = [
                ct.c_void_p,
                ct.c_void_p]
            self._nlp_init._jmi_model._dll.jmi_init_opt_ipopt_solve.argtypes = [
                ct.c_void_p]
            self._nlp_init._jmi_model._dll.jmi_init_opt_ipopt_set_string_option.argtypes = [
                ct.c_void_p,
                ct.c_char_p,
                ct.c_char_p]
            self._nlp_init._jmi_model._dll.jmi_init_opt_ipopt_set_int_option.argtypes = [
                ct.c_void_p,
                ct.c_char_p,
                ct.c_int]
            self._nlp_init._jmi_model._dll.jmi_init_opt_ipopt_set_num_option.argtypes = [
                ct.c_void_p,
                ct.c_char_p,
                c_jmi_real_t]
            self._nlp_init._jmi_model._dll.jmi_init_opt_ipopt_get_statistics.argtypes = [
                ct.c_void_p,
                ct.POINTER(ct.c_int),
                ct.POINTER(ct.c_int),
                ct.POINTER(c_jmi_real_t),
                ct.POINTER(c_jmi_real_t)]

        except AttributeError as e:
            pass
               
    def init_opt_ipopt_solve(self):
        """ 
        Solve the NLP problem.
        """
        if self._nlp_init._jmi_model._dll.jmi_init_opt_ipopt_solve(self._ipopt_init) > 1:
            raise JMIException("Solving IPOPT failed.")
        
        # Check return status from Ipopt and raise exception if not ok
        (return_status, nbr_iters, obj_final, tot_exec_time) = self.init_opt_ipopt_get_statistics()
        # Return code should be one of (taken from IpReturnCodes.inc):
        # 0: IP_SOLVE_SUCCEEDED
        # 1: IP_ACCEPTABLE_LEVEL
        # 6: IP_FEASIBLE_POINT_FOUND
        if return_status not in (0, 1, 6):
            raise IpoptException("Ipopt failed with return code: " + str(return_status) + \
                                 " Please see Ipopt documentation for more information.")
    
    def init_opt_ipopt_set_string_option(self, key, val):
        """ 
        Set an Ipopt string option.
        
        Parameters::
        
            key -- 
                The name of the option.
            val -- 
                The value of the option.
        """
        if self._nlp_init._jmi_model._dll.jmi_init_opt_ipopt_set_string_option(
            self._ipopt_init, key, val) is not 0:
            raise JMIException(
                "The Ipopt string option " + key + " is unknown")
        
    def init_opt_ipopt_set_int_option(self, key, val):
        """ 
        Set an Ipopt integer option.
        
        Parameters::
        
            key -- 
                The name of the option.
            val -- 
                The value of the option.
        """        
        if self._nlp_init._jmi_model._dll.jmi_init_opt_ipopt_set_int_option(
            self._ipopt_init, key, val) is not 0:
            raise JMIException(
                "The Ipopt integer option " + key + " is unknown")

    def init_opt_ipopt_set_num_option(self, key, val):
        """ 
        Set an Ipopt double option.
        
        Parameters::
        
            key -- 
                The name of the option.
            val -- 
                The value of the option.
        """
        if self._nlp_init._jmi_model._dll.jmi_init_opt_ipopt_set_num_option(
            self._ipopt_init, key, val) is not 0:
            raise JMIException(
                "The Ipopt real option " + key + " is unknown")

    def init_opt_ipopt_get_statistics(self):
        """ 
        Get statistics from the last optimization run.

        Returns::
        
            return_status -- 
                The return status from IPOPT.
                
            nbr_iter -- 
                The number of iterations. 
                
            objective -- 
                The final value of the objective function.
                
            total_exec_time -- 
                The execution time.
        """
        return_code = ct.c_int()
        iters = ct.c_int()
        objective = c_jmi_real_t()
        exec_time = c_jmi_real_t()
        if self._nlp_init._jmi_model._dll.jmi_init_opt_ipopt_get_statistics(
            self._ipopt_init,
            byref(return_code),
            byref(iters),
            byref(objective),
            byref(exec_time)) is not 0:
            raise JMIException(
                "Error when retrieve statistics - optimization problem may not be solved.")
        return (return_code.value,iters.value,objective.value,exec_time.value)

