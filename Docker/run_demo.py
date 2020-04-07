# 
#    Copyright (C) 2018 Modelon AB
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the Common Public License as published by
#    IBM, version 1.0 of the License.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY. See the Common Public License for more details.
#
#    You should have received a copy of the Common Public License
#    along with this program.  If not, see
#     <http://www.ibm.com/developerworks/library/os-cpl.html/>.

import matplotlib
matplotlib.use('Agg')

from pyfmi.examples import fmi_bouncing_ball
fmi_bouncing_ball.run_demo()

#from pyjmi.examples import cstr_casadi
#cstr_casadi.run_demo() 

# Compilation example 
from pymodelica import compile_fmu
name = compile_fmu("Modelica.Mechanics.Rotational.Examples.CoupledClutches") 

from pyfmi import load_fmu
model = load_fmu(name)
model.simulate()





