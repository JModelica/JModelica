#!/usr/bin/env python 
# -*- coding: utf-8 -*-

# Copyright (C) 2014 Modelon AB
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

# Import library for path manipulations
import os.path

# Import the JModelica.org Python packages
from pymodelica import compile_fmu
from pyfmi import load_fmu
from pyjmi.log import extract_jmi_log, parse_jmi_log, gather_solves

def run_demo():
    """
    Demonstrate how to parse a log file from a JModelica FMU.
    """

    curr_dir = os.path.dirname(os.path.abspath(__file__));
    file_name = os.path.join(curr_dir, 'files', 'LoggerTest.mo')
    
    fmu_name = compile_fmu('LoggerTest', file_name, compiler_log_level='i',
        compiler_options={'generate_only_initial_system':True})
    log_file_name='LoggerTest_log.txt'
    m = load_fmu(fmu_name, log_file_name=log_file_name)

    m.set_debug_logging(True)
    m.set('_log_level', 6)
    m.set_fmil_log_level(5)

    # Play around with the model
    
    m.set('u1',3)

    print 'u1' + str(m.get('u1'))
    print 'x1' + str(m.get('x1'))
    print 'y1' + str(m.get('y1'))
    print 'z1' + str(m.get('z1'))

    m.set('y1',0.)

    m.initialize()

    print "model initialized"

    print 'u1' + str(m.get('u1'))
    print 'x1' + str(m.get('x1'))
    print 'y1' + str(m.get('y1'))
    print 'z1' + str(m.get('z1'))

    m.set('u1',4)

    print "Input set"

    print 'u1' + str(m.get('u1'))
    print 'x1' + str(m.get('x1'))
    print 'y1' + str(m.get('y1'))
    print 'z1' + str(m.get('z1'))

    m.get_derivatives()

    m.set('y1',0.5)

    print "Set initial value of y1"

    print 'x1' + str(m.get('x1'))
    print 'y1' + str(m.get('y1'))
    print 'z1' + str(m.get('z1'))

    m.set('p',0.5)

    print "Set initial value of p"

    print 'x1' + str(m.get('x1'))
    print 'y1' + str(m.get('y1'))
    print 'z1' + str(m.get('z1'))

    # Parse the log file and print some of its contents

    # Extract the log file XML contents into a pure XML file
    dest_xml_file_name = 'LoggerTest_log.xml'
    extract_jmi_log(dest_xml_file_name, log_file_name)

    # Parse the entire XML log
    log = parse_jmi_log(log_file_name)

    print
    print 'Top log node:        log =', log
    print 'Unnamed sub nodes:   log.nodes = ['
    for node in log.nodes:
        print '   ', node, ','
    print ']'

    # Gather information pertaining to equation solves
    solves = gather_solves(log)

    print
    print 'Number of solver invocations:',                      len(solves)
    print 'Time of first solve:',                               solves[0].t
    print 'Number of block solves in first solver invocation:', len(solves[0].block_solves)
    print 'Names of iteration variables in first block solve:', solves[0].block_solves[0].variables
    print 'Min bounds in first block solve:',                   solves[0].block_solves[0].min
    print 'Max bounds in first block solve:',                   solves[0].block_solves[0].max
    print 'Initial residual scaling in first block solve:',     solves[0].block_solves[0].initial_residual_scaling
    print 'Number of iterations in first block solve:',         len(solves[0].block_solves[0].iterations)
    print
    print 'First iteration in first block solve: '
    print '  Iteration variables:',              solves[0].block_solves[0].iterations[0].ivs
    print '  Scaled residuals:',                 solves[0].block_solves[0].iterations[0].scaled_residuals
    print '  Jacobian:\n',                       solves[0].block_solves[0].iterations[0].jacobian
    print '  Jacobian updated in iteration:',    solves[0].block_solves[0].iterations[0].jacobian_updated
    print '  Residual scaling factors:',         solves[0].block_solves[0].iterations[0].residual_scaling
    print '  Residual scaling factors_updated:', solves[0].block_solves[0].iterations[0].residual_scaling_updated
    print '  Scaled residual norm:',             solves[0].block_solves[0].iterations[0].scaled_residual_norm

if __name__ == "__main__":
    run_demo()
