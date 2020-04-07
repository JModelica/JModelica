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
Utilities to postprocess and analyze JModelica FMU logs
"""

def update_jacs_scalings(jacs, jacs_updated, scalings, scalings_updated, node):
    type = node.type
    if type == 'JacobianUpdated':
        block = node.block
        if 'jacobian' in node:
            jacs[block] = node.jacobian
        jacs_updated[block] = True
    elif type == 'ResidualScalingUpdated':
        block = node.block
        if 'scaling' in node:
            scalings[block] = node.scaling
        scalings_updated[block] = True

def gather_solves(log):
    """Gather information about equation solves from a parsed JMI log.

    Takes a log root node and returns a list of solves, marked up with a block_solves list.
    Each block_solve is marked up with an iterations list and initial_residual_scaling.
    Each iteration is marked up with jacobian and residual_scaling.
    """
    jacs = {}
    jacs_updated = {}
    scalings = {}
    scalings_updated = {}

    solves = log.find('EquationSolve')    
    for solve in solves:
        block_solves = []

        for bl_node in solve.find(('BrentSolve', 'NewtonSolve', 'JacobianUpdated', 'ResidualScalingUpdated')):
            if bl_node.type == 'NewtonSolve' or bl_node.type == 'BrentSolve':
                block_solve = bl_node
                block_solves.append(block_solve)
                block_solve['iterations'] = iterations = []

                block_index = block_solve.block

                if block_index in scalings_updated:
                    if block_index in scalings:
                        block_solve['initial_residual_scaling'] = scalings[block_index]
                    block_solve['initial_residual_scaling_updated'] = scalings_updated[block_index]
                scalings_updated[block_index] = False

                for it_node in block_solve.find(('KinsolInfo', 'JacobianUpdated', 'ResidualScalingUpdated')):
                    if it_node.type == 'KinsolInfo':
                        if 'iteration_index' in it_node:
                            iteration = it_node

                            if block_index in jacs_updated:
                                if block_index in jacs:
                                    iteration['jacobian'] = jacs[block_index]
                                iteration['jacobian_updated'] = jacs_updated[block_index]
                                jacs_updated[block_index] = False
                            if block_index in scalings_updated:
                                if block_index in scalings:
                                    iteration['residual_scaling'] = scalings[block_index]
                                iteration['residual_scaling_updated'] = scalings_updated[block_index]
                            scalings_updated[block_index] = False
                            
                            iterations.append(it_node)
                    else:
                        update_jacs_scalings(jacs, jacs_updated, scalings, scalings_updated, it_node)
            else:
                update_jacs_scalings(jacs, jacs_updated, scalings, scalings_updated, bl_node)            
        solve['block_solves'] = block_solves
        
    return solves
