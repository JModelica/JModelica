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
import threading
import os
import sys
import numpy as N

class FevalThread(threading.Thread):
    def __init__(self,x,func_file_name,dir_name,debug):
        self.x = x
        self.func_file_name = func_file_name
        self.dir_name = dir_name
        self.debug = debug
        threading.Thread.__init__(self)

    def run(self):
        curr_dir = os.path.dirname(os.path.abspath(__file__))
        l = list()
        for val in self.x:
            l.append(str(val))
        x_string = ' '.join(l)
        eval_path = os.path.join(curr_dir, 'func_eval.py')
        if not os.path.isfile(eval_path):
            eval_path = os.path.join(curr_dir, 'func_eval.pyc')
        python_path = sys.executable
        cmd = ' '.join([python_path, eval_path, x_string, self.func_file_name, self.dir_name])
        if self.debug:
            outfile = 'out_file_' + self.dir_name + '.txt'
            errfile = 'err_file_' + self.dir_name + '.txt'
            cmd = ' '.join([cmd, '>', outfile, '2>', errfile])
            
        self.retval = os.system(cmd)

def feval(func_file_name,x,debug):
	"""
	Evaluate a function in x in a separate process. If x contains multiple
	points (rows) then the function evaluation in each point is performed 
	in a separate process.
	
	Parameters::
	
		func_file_name --
			string
			The name of a python file containing the function definition.
			The function in the file must have the same name as the file 
			itself (without ".py").
			
		x --
			ndarray (1 or 2 dimensions)
			The point(s) in which to evaluate the function.
			
		debug --
			bool
			Set to True to get separate error and output files for each
			separate process.
		
	Returns::
	
		fval --
			float or ndarray (1 dimension)
			The function value(s) in x.
	"""
	
	# Evaluation in one point only
	if N.ndim(x) == 1:
		dir_name = 'dir'
		th = FevalThread(x,func_file_name,dir_name,debug)
		th.start()
		th.join()
		retval = th.retval
		if retval != 0:
			raise OSError, 'Something went wrong with the function evaluation: os.system did not return 0.'
		f_string = file(dir_name+'/f_value.txt').read()
		fval = eval(f_string)
	
	# Evaluation in several points	
	else:
		m = len(x)
		fval = N.zeros(m)
		# Create and start threads
		threads = []
		for i in range(m):
			dir_name = 'dir_'+str(i+1)
			th = FevalThread(x[i],func_file_name,dir_name,debug)
			th.start()
			threads.append(th)	
		# Wait for all threads to complete
		for t in threads:
		    t.join()    
		# Read from result files
		for i in range(m):
			retval = threads[i].retval
			if retval != 0:
				raise OSError, 'Something went wrong with the function evaluation: os.system did not return 0.'
			dir_name = 'dir_'+str(i+1)
			f_string = file(dir_name+'/f_value.txt').read()
			fval[i] = eval(f_string)
	
	return fval
