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
Utility functions for extracting and filtering FMU logs
"""

def get_structured_fmu_log(log_file):
    
    f = open(log_file)

    l = f.readline()

    d = []

    jacs = {}
    jacs_updated = {}
    jac_parsing_in_progress = False

    scalings = {}
    scalings_updated = {}

    while l != '':
        #print l

        if l.find('[NLE_JAC]')>=0:
            ll = l.split(';')
            if not jac_parsing_in_progress:
                jacs[int(ll[1])] = []
                jacs_updated[int(ll[1])] = True
                jac_parsing_in_progress = True
            jacs[int(ll[1])].append([])
            for v in ll[5:-1]:
                jacs[int(ll[1])][-1].append(float(v))

        if l.find('[NLE_JAC]')==-1:
            jac_parsing_in_progress = False

        if l.find('[NLE_SCALING]')>=0 and l.find('Updating')>=0:
            ll = l.split(';')
            scalings[int(ll[1])] = []
            scalings_updated[int(ll[1])] = True
            for v in ll[5:-1]:
                scalings[int(ll[1])].append(float(v))

        if l.find('[NLE_ITERS]')>=0:
            # Detect a solve has started
            if l.find('Model equations evaluation invoked at time:')>=0:
                s = {}
                ll = l.split(';')
                s['time'] = float(ll[-1])
                s['block_solves'] = [] 

            if l.find('Newton solver invoked')>=0:
                bl = {}
                bl['names'] = []
                bl['iterations'] = []
                ll = l.split(';')
                for i in range(5,len(ll)-1):
                    bl['names'].append(ll[i])
                bl['block_index'] = int(ll[1])
                bl['initial_residual_scaling'] = scalings[int(ll[1])]
                bl['initial_residual_scaling_updated'] = scalings_updated[int(ll[1])]
                if scalings_updated[int(ll[1])]:
                    scalings_updated[int(ll[1])] = False
				
            if l.find('Iteration')>=0:
                iteration = {}
                bl['iterations'].append(iteration)
                iteration['iteration_variables'] = []
                ll = l.split(';')
                for i in range(5,len(ll)-1):
                    iteration['iteration_variables'].append(float(ll[i]))

                if len(jacs)>0:
                    iteration['jacobian'] = jacs[int(ll[1])]
                    iteration['jacobian_updated'] = jacs_updated[int(ll[1])]
                    if jacs_updated[int(ll[1])]:
                        jacs_updated[int(ll[1])] = False

                iteration['residual_scaling'] = scalings[int(ll[1])]
                iteration['residual_scaling_updated'] = scalings_updated[int(ll[1])]
                if scalings_updated[int(ll[1])]:
                    scalings_updated[int(ll[1])] = False
                    
            if l.find('Residuals')>=0:
                iteration['residuals'] = []
                ll = l.split(';')
                for i in range(5,len(ll)-1):
                    iteration['residuals'].append(float(ll[i]))
                iteration['scaled_residual_norm'] = float(ll[3])
                
            if l.find('Limitation')>=0:
                iteration['at_bound'] = []
                l2 = l.split(';')
                for i in range(5,len(l2)-1):
                    iteration['at_bound'].append(tuple(l2[i].split()))
                
            if l.find('Max')>=0:
                bl['max'] = []
                ll = l.split(';')
                for i in range(5,len(ll)-1):
                    bl['max'].append(float(ll[i]))

            if l.find('Initial guess')>=0:
                bl['initial_guess'] = []
                ll = l.split(';')
                for i in range(5,len(ll)-1):
                    bl['initial_guess'].append(float(ll[i]))

            if l.find('Variable nominal')>=0:
                bl['variable_nominal'] = []
                ll = l.split(';')
                for i in range(5,len(ll)-1):
                    bl['variable_nominal'].append(float(ll[i]))

            if l.find('Min')>=0:
                bl['min'] = []
                ll = l.split(';')
                for i in range(5,len(ll)-1):
                    bl['min'].append(float(ll[i]))

            if l.find('Newton solver finished with exit flag')>=0:
                ll = l.split(';')
                bl['kinsol_exit_flag'] = ll[3]


            if l.find('Newton solver finished')>=0:
                s['block_solves'].append(bl)

            # Detect a solve has ended
            if l.find('Model equations evaluation finished')>=0:
                d.append(s)

        l = f.readline()

    return d
       
def FMU_write_log_to_file(log_file, tags=[], file_name='fmu_log.txt'):
    
    fi = open(log_file)
    fo = open(file_name,'w')

    if len(tags)==0:
    	l = fi.readline()
    	while l != '':
            fo.write(l)
            l = fi.readline()
			    
    else:
    	l = fi.readline()
    	while l != '':
            for tag in tags:
            	if l.find(tag)>=0:
                    fo.write(l.split(tag)[1])
            l = fi.readline()

    fo.close()       
       
