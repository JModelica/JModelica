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
This script creates a sub-directory to the current one, evaluates a function 
in a certain point in the sub-directory and writes the result to a file.
The script is executed with the os.system() command in the function run() 
in the thread class FevalThread in thread_feval.py which is used for function
evaluations in separate processes. The os.system() command is given four 
input arguments: 
1. 'func_eval.py' - the file to be executed
2. The point x (in string representation) in which to evaluate the function
3. The name of the file (string) in which the function is defined
4. The name of the sub-directory (string) in which to perform the evaluation
"""

import sys
import numpy as N
import os

# Number of dimensions of the point in which to evaluate the function
n = len(sys.argv) - 3

# Get the point as a numpy array instead of a string
x = N.zeros(n)
for i in range(n):
	x[i] = float(sys.argv[i+1])

# Execute the file containing the definition of the function to be evaluated
func_file_name = sys.argv[-2]
execfile(func_file_name)

# Get the actual function
if func_file_name.endswith(".py"):
    func_name = func_file_name[:-3].split('/')[-1].split('\\')[-1]
else:
    func_name = func_file_name.split('/')[-1].split('\\')[-1]
f = eval(func_name)

# Get the name of the sub-directory
dir_name = sys.argv[-1]

# Create the sub-directory
try:
	os.mkdir(dir_name)
except OSError:
	pass
# try-except so that it works even if the sub-directory already exists

# Change to sub-directory
os.chdir(dir_name)

# Evaluate the function
f_value = f(x)

# Write the function value to a file
result_file = open('f_value.txt','w')
result_file.write(repr(f_value))
result_file.close()
