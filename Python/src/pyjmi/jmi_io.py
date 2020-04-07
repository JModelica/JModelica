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
Module for writing optimization and simulation results to file.
"""
from operator import itemgetter
import array
import codecs

import numpy as N
import scipy.io

import jmi
from pyjmi.common.io import ResultWriter
from pyjmi.common import xmlparser

def export_result_dymola(model, data, file_name='', format='txt', scaled=False):
    """
    Export an optimization or simulation result to file in Dymolas result file 
    format. The parameter values are read from the z vector of the model object 
    and the time series are read from the data argument.

    Parameters::
    
        model --
            A Model object.
            
        data --
            A two dimensional array of variable trajectory data. The first 
            column represents the time vector. The following colums contain, in 
            order, the derivatives, the states, the inputs and the algebraic 
            variables. The ordering is according to increasing value references.
            
        file_name --
            If no file name is given, the name of the model (as defined by 
            FMUModel.get_identifier()) concatenated with the string '_result' is used. 
            A file suffix equal to the format argument is then appended to the 
            file name.
            Default: Empty string.
            
        format --
            A text string equal either to 'txt' for textual format or 'mat' for 
            binary Matlab format.
            Default: 'txt'
            
        scaled --
            Set this parameter to True to write the result to file without
            taking scaling into account. If the value of scaled is False, then 
            the variable scaling factors of the model are used to reproduced the 
            unscaled variable values.
            Default: False

    Limitations::
    
        Currently only textual format is supported.
    """

    if (format=='txt'):

        if file_name=='':
            file_name=model.get_identifier() + '_result.txt'

        # Open file
        f = codecs.open(file_name,'w','utf-8')

        # Write header
        f.write('#1\n')
        f.write('char Aclass(3,11)\n')
        f.write('Atrajectory\n')
        f.write('1.1\n')
        f.write('\n')
        
        md = model._get_XMLDoc()
        
        # NOTE: it is essential that the lists 'names', 'aliases', 'descriptions' 
        # and 'variabilities' are sorted in the same order and that this order 
        # is: value reference order AND within the same value reference the 
        # non-alias variable must be before its corresponding aliases. Otherwise 
        # the header-writing algorithm further down will fail.
        # Therefore the following code is needed...
        
        # all lists that we need for later
        vrefs_alias = []
        vrefs = []
        names_alias = []
        names = []
        aliases_alias = []
        aliases = []
        descriptions_alias = []
        descriptions = []
        variabilities_alias = []
        variabilities = []
        
        # go through all variables and split in non-alias/only-alias lists
        for var in md.get_model_variables():
            if var.get_alias() == xmlparser.NO_ALIAS:
                vrefs.append(var.get_value_reference())
                names.append(var.get_name())
                aliases.append(var.get_alias())
                descriptions.append(var.get_description())
                variabilities.append(var.get_variability())
            else:
                vrefs_alias.append(var.get_value_reference())
                names_alias.append(var.get_name())
                aliases_alias.append(var.get_alias())
                descriptions_alias.append(var.get_description())
                variabilities_alias.append(var.get_variability())
        
        # extend non-alias lists with only-alias-lists
        vrefs.extend(vrefs_alias)
        names.extend(names_alias)
        aliases.extend(aliases_alias)
        descriptions.extend(descriptions_alias)
        variabilities.extend(variabilities_alias)
        
        # zip to list of tuples and sort - non alias variables are now
        # guaranteed to be first in list and all variables are in value reference 
        # order
        names = sorted(zip(
            tuple(vrefs), 
            tuple(names)), 
            key=itemgetter(0))
        aliases = sorted(zip(
            tuple(vrefs), 
            tuple(aliases)), 
            key=itemgetter(0))
        descriptions = sorted(zip(
            tuple(vrefs), 
            tuple(descriptions)), 
            key=itemgetter(0))
        variabilities = sorted(zip(
            tuple(vrefs), 
            tuple(variabilities)), 
            key=itemgetter(0))
        
        num_vars = len(names)
        
        # Find the maximum name and description length
        max_name_length = len('Time')
        max_desc_length = len('Time in [s]')
        
        for i in range(len(names)):
            name = names[i][1]
            desc = descriptions[i][1]
            
            if (len(name)>max_name_length):
                max_name_length = len(name)
                
            if (len(desc)>max_desc_length):
                max_desc_length = len(desc)

        f.write('char name(%d,%d)\n' % (num_vars + 1, max_name_length))
        f.write('time\n')
    
        # write names
        for name in names:
            f.write(name[1] +'\n')

        f.write('\n')

        f.write('char description(%d,%d)\n' % (num_vars + 1, max_desc_length))
        f.write('Time in [s]\n')

        # write descriptions
        for desc in descriptions:
            f.write(desc[1]+'\n')
            
        f.write('\n')

        # Write data meta information
        offs = model.get_offsets()
        n_parameters = offs[12] # offs[12] = offs_dx
        f.write('int dataInfo(%d,%d)\n' % (num_vars + 1, 4))
        f.write('0 1 0 -1 # time\n')

        cnt_1 = 1
        cnt_2 = 1
        
        for i, name in enumerate(names):
            (ref, type) = jmi._translate_value_ref(name[0])
            
            if int(ref) < n_parameters: # Put parameters in data set
                if aliases[i][1] == 0: # no alias
                    cnt_1 = cnt_1 + 1
                    f.write('1 %d 0 -1 # ' % cnt_1 + name[1]+'\n')
                elif aliases[i][1] == 1: # alias
                    f.write('1 %d 0 -1 # ' % cnt_1 + name[1]+'\n')
                else: # negated alias
                    f.write('1 -%d 0 -1 # ' % cnt_1 + name[1] +'\n')
                
                
            else:
                if aliases[i][1] == 0: # noalias
                    cnt_2 = cnt_2 + 1   
                    f.write('2 %d 0 -1 # ' % cnt_2 + name[1] +'\n')
                elif aliases[i][1] == 1: # alias
                    f.write('2 %d 0 -1 # ' % cnt_2 + name[1] +'\n')
                else: #neg alias
                    f.write('2 -%d 0 -1 # ' % cnt_2 + name[1] +'\n')
            
                
        f.write('\n')

        sc = model.jmimodel.get_variable_scaling_factors()
        z = model.z

        rescale = (model.get_scaling_method() == 
            jmi.JMI_SCALING_VARIABLES) and (not scaled)

        # Write data
        # Write data set 1
        f.write('float data_1(%d,%d)\n' % (2, n_parameters + 1))
        f.write("%.14E" % data[0,0])
        str_text = ''
        for ref in range(n_parameters):
            #print ref
            if rescale:
                #print z[ref]*sc[ref]
                #print "hej"
                str_text += " %.14E" % (z[ref]*sc[ref])
            else:
                #print z[ref]
                #print "hopp"
                str_text += " %.14E" % (z[ref])
                
        f.write(str_text)
        f.write('\n')
        f.write("%.14E" % data[-1,0])
        f.write(str_text)

        f.write('\n\n')

        # Write data set 2
        n_vars = len(data[0,:])
        n_points = len(data[:,0])
        f.write('float data_2(%d,%d)\n' % (n_points, n_vars))
        for i in range(n_points):
            str = ''
            for ref in range(n_vars):
                if ref==0: # Don't scale time
                    str = str + (" %.14E" % data[i,ref])
                else:
                    if rescale:
                        str = str + (" %.14E" % (data[i,ref]*sc[ref-1+n_parameters]))
                    else:
                        str = str + (" %.14E" % data[i,ref])
            f.write(str+'\n')

        f.write('\n')

        f.close()

    else:
        raise Error('Export on binary Dymola result files not yet supported.')

class ResultWriterDymolaSensitivity(ResultWriter):
    """
    Export an simulation result With calculated sensitivities in Dymola's
    result file format.
    """
    def __init__(self, model, format='txt'):
        """
        Export an simulation result With calculated sensitivities in Dymola's
        result file format.
        
        Parameters::
        
            model   --
                A FMUModel object.
            format  --
                A text string equal either to 'txt for textual format
                or 'mat' for binary Matlab format.
                Defaults: txt
                
        Limitations::
        
            Currently only textual format is supported.
        """
        self.model = model
        
        if format!='txt':
            raise JIOError('The format is currently not supported.')
        
        #Internal values
        self._file_open = False
        self._npoints = 0
        
    def write_header(self, file_name='', scaled=False):
        """
        Opens the file and writes the header. This includes the 
        information about the variables and a table determining the link 
        between variables and data.
        
        Parameters::
        
            file_name --
                If no file name is given, the name of the model (as 
                defined by FMUModel.get_identifier()) concatenated with the 
                string '_result' is used. A file suffix equal to the 
                format argument is then appended to the file name.
                Default: Empty string.
        """
        model = self.model
        if file_name=='':
            file_name=model.get_identifier() + '_result.txt'

        # Open file
        f = codecs.open(file_name,'w','utf-8')
        self._file_open = True

        # Write header
        f.write('#1\n')
        f.write('char Aclass(3,11)\n')
        f.write('Atrajectory\n')
        f.write('1.1\n')
        f.write('\n')
        
        # Retrieve the xml-file
        md = model._get_XMLDoc()
        
        # all lists that we need for later
        vrefs_alias = []
        vrefs = []
        names_alias = []
        names = []
        aliases_alias = []
        aliases = []
        descriptions_alias = []
        descriptions = []
        variabilities_alias = []
        variabilities = []
        
        # go through all variables and split in non-alias/only-alias lists
        for var in md.get_model_variables():
            if var.get_alias() == xmlparser.NO_ALIAS:
                vrefs.append(var.get_value_reference())
                names.append(var.get_name())
                aliases.append(var.get_alias())
                descriptions.append(var.get_description())
                variabilities.append(var.get_variability())
            else:
                vrefs_alias.append(var.get_value_reference())
                names_alias.append(var.get_name())
                aliases_alias.append(var.get_alias())
                descriptions_alias.append(var.get_description())
                variabilities_alias.append(var.get_variability())
        
        # Parameters for sensitivity calculations
        sens_p = model.get_p_opt_variable_names()
        sens_x = model.get_x_variable_names()
        sens_w = model.get_w_variable_names()
        
        # sort in value reference order (must match order in data)
        sens_xw = sens_x+sens_w
        sens_xw = sorted(sens_xw, key=itemgetter(0))
        
        sens_names = []
        sens_desc = []
        
        for j in range(len(sens_p)):
            #(ref_param, type) = pyjmi.jmi._translate_value_ref(sens_p[j][0])
            for i in range(len(sens_xw)):
                sens_names += ['d'+sens_xw[i][1]+'/d'+sens_p[j][1]]
                sens_desc  += ['Sensitivity of '+sens_xw[i][1]+' with respect to '+sens_p[j][1]+'.']
        
        
        # extend non-alias lists with only-alias-lists
        vrefs.extend(vrefs_alias)
        names.extend(names_alias)
        aliases.extend(aliases_alias)
        descriptions.extend(descriptions_alias)
        variabilities.extend(variabilities_alias)
        
        # zip to list of tuples and sort - non alias variables are now
        # guaranteed to be first in list and all variables are in value reference 
        # order
        names = sorted(zip(
            tuple(vrefs), 
            tuple(names)), 
            key=itemgetter(0))
        aliases = sorted(zip(
            tuple(vrefs), 
            tuple(aliases)), 
            key=itemgetter(0))
        descriptions = sorted(zip(
            tuple(vrefs), 
            tuple(descriptions)), 
            key=itemgetter(0))
        variabilities = sorted(zip(
            tuple(vrefs), 
            tuple(variabilities)), 
            key=itemgetter(0))
        
        # sort in value reference order (must match order in data)
        #names = sorted(md.get_variable_names(), key=itemgetter(0))
        #aliases = sorted(md.get_variable_aliases(), key=itemgetter(0))
        #descriptions = sorted(md.get_variable_descriptions(), key=itemgetter(0))
        #variabilities = sorted(md.get_variable_variabilities(), key=itemgetter(0))
        
        num_vars = len(names)+len(sens_names)
        
        # Find the maximum name and description length
        max_name_length = len('Time')
        max_desc_length = len('Time in [s]')
        
        for i in range(len(names)):
            name = names[i][1]
            desc = descriptions[i][1]
            
            if (len(name)>max_name_length):
                max_name_length = len(name)
                
            if (len(desc)>max_desc_length):
                max_desc_length = len(desc)
        
        for i in range(len(sens_names)):
            
            if (len(sens_names[i])>max_name_length):
                max_name_length = len(sens_names[i])
                
            if (len(sens_desc[i])>max_desc_length):
                max_desc_length = len(sens_desc[i])
        
        f.write('char name(%d,%d)\n' % (num_vars + 1, max_name_length))
        f.write('time\n')
        
        self._rescale = (model.get_scaling_method() == jmi.JMI_SCALING_VARIABLES) and (not scaled)

        for name in names:
            f.write(name[1] +'\n')
        for name in sens_names:
            f.write(name+'\n')

        f.write('\n')

        # Write descriptions       
        f.write('char description(%d,%d)\n' % (num_vars + 1, max_desc_length))
        f.write('Time in [s]\n')

        # write descriptions
        for desc in descriptions:
            f.write(desc[1]+'\n')
            
        # Write sensitivity descriptions
        for desc in sens_desc:
            f.write(desc+'\n')
            
        f.write('\n')

        # Write data meta information
        offs = model.get_offsets()
        n_parameters = offs[12] # offs[12] = offs_dx
        self._n_parameters = n_parameters
        f.write('int dataInfo(%d,%d)\n' % (num_vars + 1, 4))
        f.write('0 1 0 -1 # time\n')

        cnt_1 = 1
        cnt_2 = 1
        
        for i, name in enumerate(names):
            (ref, type) = jmi._translate_value_ref(name[0])
            
            if int(ref) < n_parameters: # Put parameters in data set
                if aliases[i][1] == 0: # no alias
                    cnt_1 = cnt_1 + 1
                    f.write('1 %d 0 -1 # ' % cnt_1 + name[1]+'\n')
                elif aliases[i][1] == 1: # alias
                    f.write('1 %d 0 -1 # ' % cnt_1 + name[1]+'\n')
                else: # negated alias
                    f.write('1 -%d 0 -1 # ' % cnt_1 + name[1] +'\n')
            else:
                if aliases[i][1] == 0: # noalias
                    cnt_2 = cnt_2 + 1   
                    f.write('2 %d 0 -1 # ' % cnt_2 + name[1] +'\n')
                elif aliases[i][1] == 1: # alias
                    f.write('2 %d 0 -1 # ' % cnt_2 + name[1] +'\n')
                else: #neg alias
                    f.write('2 -%d 0 -1 # ' % cnt_2 + name[1] +'\n')
        
        self._nvariables_without_sens = cnt_2
        
        
        sc = model.jmimodel.get_variable_scaling_factors()
        self._sc = sc
        z = model.z
        
        sens_param_res = []
        self._sens_sc = [] #Sensitivity scaling factors
        
        #Write sensitivity variables into the table (No alias, no parameters)
        for i,name in enumerate(sens_names):
            name_split = name.split('/')
            param = name_split[1][1:]
            var   = name_split[0][1:]
            (ref_param, type) = jmi._translate_value_ref(model.get_value_reference(param))
            (ref_var  , type) = jmi._translate_value_ref(model.get_value_reference(var))
            
            if int(ref_var) < n_parameters: # Put parameters in data set
                cnt_1 = cnt_1 + 1
                f.write('1 %d 0 -1 # ' % cnt_1 + name +'\n')
                
                if ref_param == ref_var:
                    if model.is_negated_alias(var):
                        sens_param_res += [-1.0]
                    else:
                        sens_param_res += [1.0]
                else:
                    sens_param_res += [0.0]
            else:
                if not md.is_alias(var):
                    cnt_2 = cnt_2+1
                    self._sens_sc += [self._sc[ref_var]/self._sc[ref_param]]
                    f.write('2 %d 0 -1 # ' % cnt_2 + name + '\n')
                elif md.is_negated_alias(var):
                    f.write('2 -%d 0 -1 # ' % cnt_2 + name + '\n')
                else:
                    f.write('2 %d 0 -1 # ' % cnt_2 + name + '\n')

        self._nvariables_total = cnt_2 #Store the number of variables
        f.write('\n')


        # Write data
        # Write data set 1
        f.write('float data_1(%d,%d)\n' % (2, cnt_1))
        
        str_text = ''
        for ref in range(n_parameters):
            if self._rescale:
                str_text += " %.14E" % (z[ref]*sc[ref])
            else:
                str_text += " %.14E" % (z[ref])
        
        # Write sensitivity data set 1
        for i in range(cnt_1-1-n_parameters):
            str_text += " %.14E " % sens_param_res[i]
        
        #f.write("%.14E" % data[0,0])
        self._point_first_t = f.tell()
        f.write("%s" % ' '*28)
        f.write(str_text)
        f.write('\n')
        self._point_last_t = f.tell()
        f.write("%s" % ' '*28)
        f.write(str_text)

        f.write('\n\n')
        
        f.write('float data_2(')
        self._point_npoints = f.tell()
        f.write(' '*(14+4+14))
        f.write('\n')
        
        self._file = f
        
        
    def write_point(self, data=None):
        """ Writes the current status of the model to file. If the header
        has not been written previously it is written now. If data is 
        specified it is written instead of the current status.
        
        Parameters::
            
                data --
                    A one dimensional array of variable trajectory data.
                    data should consist of information about the status.
                    Default: None
        """
        f = self._file
        rescale = self._rescale
        sc = self._sc
        sens_sc = self._sens_sc
        n_parameters = self._n_parameters

        if self._npoints == 0:
            self._tstart = data[0]
        
        #Write the point
        str_text = (" %.14E" % data[0])
        for j in xrange(self._nvariables_without_sens-1):
            if rescale:
                str_text = str_text + (" %.14E" %(data[1+j]*sc[j+n_parameters]))
            else:
                str_text = str_text + (" %.14E" % data[1+j])

        for j in xrange(self._nvariables_total-self._nvariables_without_sens):
            if rescale:
                str_text = str_text + (" %.14E" %(data[j+self._nvariables_without_sens]*sens_sc[j]))
            else:
                str_text = str_text + (" %.14E" % data[j+self._nvariables_without_sens])
        f.write(str_text+'\n')
        
        #Update number of points
        self._npoints+=1

        
    def write_finalize(self):
        """ Finalize the writing by filling in the blanks in the created 
        file. The blanks consists of the number of points and the final 
        time (in data set 1). Also closes the file.
        """
        #If open, finalize and close
        if self._file_open:
            
            f = self._file
            
            f.seek(self._point_first_t)
            
            f.write('%.14E'%self._tstart)
            
            f.seek(self._point_last_t)
            
            f.write('%.14E'%self.model.t)
            
            f.seek(self._point_npoints)
            f.write('%d,%d)' % (self._npoints, self._nvariables_total))

            f.seek(-1,2)
            #Close the file
            f.write('\n')
            f.close()
            self._file_open = False
