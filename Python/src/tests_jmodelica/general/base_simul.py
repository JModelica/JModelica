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

"""JModelica test package.

This file holds base classes for simulation and optimization tests.
"""

import os

from pymodelica.compiler import compile_fmu
from pyfmi.fmi import load_fmu, FMUModelCS1, FMUModelME1, FMUModelCS2, FMUModelME2
from pyjmi.common.io import ResultDymolaTextual, ResultDymolaBinary
from tests_jmodelica import get_files_path

_model_name = ''

class _BaseSimOptTest:
    """
    Base class for simulation and optimization tests.
    Actual test classes should inherit SimulationTest or OptimizationTest.
    All assertion methods consider a value correct if it falls within either tolerance 
    limit, absolute or relative.
    """

    @classmethod
    def setup_class_base(cls, mo_file, class_name, options = {}, target="me", version=None):
        """
        Set up a new test model. Compiles the model. 
        Call this with proper args from setUpClass(). 
          mo_file     - the relative path from the files dir to the .mo file to compile
          class_name  - the qualified name of the class to simulate
          options     - a dict of options to set in the compiler, defaults to no options
        """
        global _model_name
        cls.mo_path = os.path.join(get_files_path(), 'Modelica', mo_file)

        if version==None:
            _model_name = compile_fmu(class_name, cls.mo_path, compiler_options=options,target=target)
        else:
            _model_name = compile_fmu(class_name, cls.mo_path, compiler_options=options,target=target,version=version)


    def setup_base(self, rel_tol, abs_tol):
        """ 
        Set up a new test case. Configures test and creates model.
        Call this with proper args from setUp(). 
          rel_tol -  the relative error tolerance when comparing values
          abs_tol -  the absolute error tolerance when comparing values
        Any other named args are passed to the NLP constructor.
        """
        global _model_name
        self.rel_tol = rel_tol
        self.abs_tol = abs_tol
        self.model_name = _model_name
        parts = _model_name.split('.')
        self.model = load_fmu(self.model_name)

    def run(self,cvode_options=None):
        """
        Run simulation and load result. 
        Call this from setUp() or within a test depending if all tests should run simulation.
        """
        res = self._run_and_write_data(cvode_options)
        self.data = res.result_data#ResultDymolaTextual(self.model_name[:-len('.fmu')] + '_result.txt')


    def load_expected_data(self, name):
        """
        Load the expected data to use for assert_all_paths() and assert_all_end_values().
          name -  the file name of the results file, relative to files dir
        """
        path = os.path.join(get_files_path(), 'Results', name)
        if path.endswith("txt"):
            self.expected = ResultDymolaTextual(path)
        else:
            self.expected = ResultDymolaBinary(path)


    def assert_all_inital_values(self, variables, rel_tol = None, abs_tol = None):
        """
        Assert that all given variables match expected intial values loaded by a call to 
        load_expected_data().
          variables -  list of the names of the variables to test
          rel_tol   -  the relative error tolerance, defaults to the value set with setup_base()
          abs_tol   -  the absolute error tolerance, defaults to the value set with setup_base()
        """
        self._assert_all_spec_values(variables, 0, rel_tol, abs_tol)


    def assert_all_end_values(self, variables, rel_tol = None, abs_tol = None):
        """
        Assert that all given variables match expected end values loaded by a call to 
        load_expected_data().
          variables -  list of the names of the variables to test
          rel_tol   -  the relative error tolerance, defaults to the value set with setup_base()
          abs_tol   -  the absolute error tolerance, defaults to the value set with setup_base()
        """
        self._assert_all_spec_values(variables, -1, rel_tol, abs_tol)


    def assert_all_trajectories(self, variables, same_span = True, rel_tol = None, abs_tol = None):
        """
        Assert that the trajectories of all given variables match expected trajectories 
        loaded by a call to load_expected_data().
          variables -  list of the names of the variables to test
          same_span -  if True, require that the paths span the same time interval
                       if False, only compare overlapping part, default True
          rel_tol   -  the relative error tolerance, defaults to the value set with setup_base()
          abs_tol   -  the absolute error tolerance, defaults to the value set with setup_base()
        """
        for var in variables:
            expected = self.expected.get_variable_data(var)
            expected_t = self.expected.get_variable_data('time')
            self.assert_trajectory(var, expected, expected_t, same_span, rel_tol, abs_tol)


    def assert_initial_value(self, variable, value, rel_tol = None, abs_tol = None):
        """
        Assert that the inital value for a simulation variable matches expected value. 
          variable  -  the name of the variable
          value     -  the expected value
          rel_tol   -  the relative error tolerance, defaults to the value set with setup_base()
          abs_tol   -  the absolute error tolerance, defaults to the value set with setup_base()
        """
        self._assert_value(variable, value, 0, rel_tol, abs_tol)


    def assert_end_value(self, variable, value, rel_tol = None, abs_tol = None):
        """
        Assert that the end result for a simulation variable matches expected value. 
          variable  -  the name of the variable
          value     -  the expected value
          rel_tol   -  the relative error tolerance, defaults to the value set with setup_base()
          abs_tol   -  the absolute error tolerance, defaults to the value set with setup_base()
        """
        self._assert_value(variable, value, -1, rel_tol, abs_tol)

    
    def assert_trajectory(self, variable, expected, expected_t, same_span = True, rel_tol = None, abs_tol = None):
        """
        Assert that the trajectory of a simulation variable matches expected trajectory. 
          variable  -  the name of the variable
          expected  -  the expected trajectory
          same_span -  if True, require that the paths span the same time interval
                       if False, only compare overlapping part, default True
          rel_tol   -  the relative error tolerance, defaults to the value set with setup_base()
          abs_tol   -  the absolute error tolerance, defaults to the value set with setup_base()
        """
        if rel_tol is None:
            rel_tol = self.rel_tol
        if abs_tol is None:
            abs_tol = self.abs_tol
        ans = expected
        ans_t = expected_t
        res = self.data.get_variable_data(variable)
        res_t = self.data.get_variable_data('time')

        if same_span:
            msg = 'paths do not span the same time interval for ' + variable
            assert _check_error(ans.t[0], res.t[0], rel_tol, abs_tol), msg
            assert _check_error(ans.t[-1], res.t[-1], rel_tol, abs_tol), msg

        # Merge the time lists
        time = list(set(ans.t) | set(res.t))

        # Get overlapping span
        (t1, t2) = (max(ans.t[0], res.t[0]), min(ans.t[-1], res.t[-1]))

        # Remove values outside overlap
        #time = filter((lambda t: t >= t1 and t <= t2), time) #This is not a good approach
        time = filter((lambda t: t >= t1 and t <= t2), res.t)

        # Check error for each time point
        for i,t in enumerate(time):
            try:
                if time[i-1]==t or t==time[i+1]: #Necessary in case of jump discontinuities! For instance if there is a result at t_e^- and t_e^+
                    continue
            except IndexError:
                pass
            ans_x = _trajectory_eval(ans, ans_t, t)
            res_x = _trajectory_eval(res, res_t, t)
            (rel, abs) = _error(ans_x, res_x)
            msg = 'error of %s at time %f is too large (rel=%f, abs=%f)' % (variable, t, rel, abs)
            assert (rel <= 100*rel_tol or abs <= 100*abs_tol), msg


    def _assert_all_spec_values(self, variables, index, rel_tol = None, abs_tol = None):
        """
        Assert that all given variables match expected values loaded by a call to 
        load_expected_data(), for a given index in the value arrays.
          variables -  list of the names of the variables to test
          index     -  the index in the array holding the values, 0 is initial, -1 is end
          rel_tol   -  the relative error tolerance, defaults to the value set with setup_base()
          abs_tol   -  the absolute error tolerance, defaults to the value set with setup_base()
        """
        for var in variables:
            value = self.expected.get_variable_data(var)[index]
            self._assert_value(var, value, index, rel_tol, abs_tol)


    def _assert_value(self, variable, value, index, rel_tol = None, abs_tol = None):
        """
        Assert that a specific value for a simulation variable matches expected value. 
          variable  -  the name of the variable
          value     -  the expected value
          index     -  the index in the array holding the values, 0 is initial, -1 is end
          rel_tol   -  the relative error tolerance, defaults to the value set with setup_base()
          abs_tol   -  the absolute error tolerance, defaults to the value set with setup_base()
        """
        res = self.data.get_variable_data(variable)
        msg = 'error of %s at index %i is too large' % (variable, index)
        self.assert_equals(msg, res.x[index], value, rel_tol = None, abs_tol = None)


    def assert_equals(self, message, actual, expected, rel_tol = None, abs_tol = None):
        """
        Assert that a specific value matches expected value. 
          actual    -  the expected value
          expected  -  the expected value
          message   -  the error message to use if values does not match
          rel_tol   -  the relative error tolerance, defaults to the value set with setup_base()
          abs_tol   -  the absolute error tolerance, defaults to the value set with setup_base()
        """
        if rel_tol is None:
            rel_tol = self.rel_tol
        if abs_tol is None:
            abs_tol = self.abs_tol
        (rel, abs) = _error(actual, expected)
        assert (rel <= rel_tol or abs <= abs_tol), '%s (rel=%f, abs=%f)' % (message, rel, abs)


class SimulationTest(_BaseSimOptTest):
    """
    Base class for simulation tests.
    """

    @classmethod
    def setup_class_base(cls, mo_file, class_name, options = {}, target="me", version=None):
        """
        Set up a new test model. Compiles the model. 
        Call this with proper args from setUpClass(). 
          mo_file     - the relative path from the files dir to the .mo file to compile
          class_name  - the qualified name of the class to simulate
          options     - a dict of options to set in the compiler, defaults to no options
        """
        _BaseSimOptTest.setup_class_base(mo_file, class_name, options, target, version)

    def setup_base(self, rel_tol = 1.0e-4, abs_tol = 1.0e-6, 
        start_time=0.0, final_time=10.0, time_step=0.01, input=(),
                   write_scaled_result=False):
        """ 
        Set up a new test case. Creates and configures the simulation.
        Call this with proper args from setUp(). 
          rel_tol -  the relative error tolerance when comparing values, default is 1.0e-4
          abs_tol -  the absolute error tolerance when comparing values, default is 1.0e-6
        Any other named args are passed to sundials.
        """
        _BaseSimOptTest.setup_base(self, rel_tol, abs_tol)

        self.start_time = start_time
        self.final_time = final_time
        self.time_step = time_step
        self.ncp = int((final_time-start_time)/time_step)
        self.input = input
        self.write_scaled_result = write_scaled_result
        
    def _run_and_write_data(self, cvode_options):
        """
        Run optimization and write result to file.
        """
        
        if not cvode_options:
            cvode_options = {'atol':self.abs_tol,'rtol':self.rel_tol}
        
        if isinstance(self.model, FMUModelME1) or isinstance(self.model, FMUModelME2):
            res = self.model.simulate(start_time=self.start_time,
                                final_time=self.final_time,
                                input=self.input,
                                options={'ncp':self.ncp,
                                         'CVode_options':cvode_options})
        else:
            res = self.model.simulate(start_time=self.start_time,
                                final_time=self.final_time,
                                input=self.input,
                                options={'ncp':self.ncp})
        return res
        
class OptimizationTest(_BaseSimOptTest):
    """
    Base class for optimization tests.
    """

    @classmethod
    def setup_class_base(cls, mo_file, class_name, options = {}):
        """
        Set up a new test model. Compiles the model. 
        Call this with proper args from setUpClass(). 
          mo_file     - the relative path from the files dir to the .mo file to compile
          class_name  - the qualified name of the class to simulate
          options     - a dict of options to set in the compiler, defaults to no options
        """
        _BaseSimOptTest.setup_class_base(mo_file, class_name, options)

    def setup_base(self, rel_tol = 1.0e-4, abs_tol = 1.0e-6, opt_options = {}):
        """ 
        Set up a new test case. Creates and configures the optimization.
        Call this with proper args from setUp(). 
          rel_tol -  the relative error tolerance when comparing values, default is 1.0e-4
          abs_tol -  the absolute error tolerance when comparing values, default is 1.0e-6
          opt_options   -  a dict of options to set in the optimizer, defaults to no options (default options will be set)
        """
        _BaseSimOptTest.setup_base(self, rel_tol, abs_tol)
        #self.nlp = ipopt.NLPCollocationLagrangePolynomials(self.model, *nlp_args)
        #self.ipopt = ipopt.CollocationOptimizer(self.nlp)
        self._opt_options = opt_options
        #_set_ipopt_options(self.ipopt, options)


    def _run_and_write_data(self, cvode_options=None):
        """
        Run optimization and write result to file.
        """
        res = self.model.optimize(options=self._opt_options)
        return res


# =========== Helper functions =============

def _set_ipopt_options(nlp, opts):
    """
    Set all options contained in dict opts in Ipopt NLP object nlp.
    Selects method to use from the type of each value.
    """
    for k, v in opts.iteritems():
        if isinstance(v, int):
            nlp.opt_coll_ipopt_set_int_option(k, v)
        elif isinstance(v, float):
            nlp.opt_coll_ipopt_set_num_option(k, v)
        elif isinstance(v, basestring):
            nlp.opt_coll_ipopt_set_string_option(k, v)


def _set_compiler_options(cmp, opts):
    """
    Set all options contained in dict opts in compiler cmp.
    Selects method to use from the type of each value.
    """
    for k, v in opts.iteritems():
        if isinstance(v, bool):
            cmp.set_boolean_option(k, v)
        elif isinstance(v, int):
            cmp.set_integer_option(k, v)
        elif isinstance(v, float):
            cmp.set_real_option(k, v)
        elif isinstance(v, basestring):
            cmp.set_string_option(k, v)


def _error(v1, v2):
    """
    Calculates the relative and absolute error between two values.
    """
    if v1 == v2:
        return (0.0, 0.0)
    abs_err = abs(v1 - v2)
    return (abs_err / max(abs(v1), abs(v2)), abs_err)

def _check_error(ans, res, rel_tol, abs_tol):
    """
    Check that error is within tolerance.
    """
    (rel, abs) = _error(ans, res)
    return rel <= rel_tol or abs <= abs_tol


def _trajectory_eval(var, var_t, t):
    """
    Given the variable var, evaluate the variable for the time t.
    Values in var.t must be in increasing order, and t must be within the span of var.t.
    """
    (pt, px) = (var.t[0], var.x[0])
    for (ct, cx) in zip(var.t, var.x):
        # Since the t values are copies of the ones in the trajectories, we can use equality
        if ct == t:
            return cx
        elif ct > t:
            # pt < t < ct - use linear interpolation
            return ((t - pt) * cx + (ct - t) * px) / (ct - pt)
        (pt, px) = (ct, cx)
