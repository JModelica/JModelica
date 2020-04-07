#!/usr/bin/env python
# -*- coding: utf-8 -*-

#    Copyright (C) 2015 Modelon AB
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
import numpy as N
from collections import OrderedDict, Iterable
import casadi
import sys
import modelicacasadi_wrapper as mc


class EKFArrivalCost(object):
    """
    An extended Kalman filter used in an moving horizon estimation to 
    approximate the arrival cost.
    """

    def __init__(self, op, sample_time, state_names, alg_var_names, 
                 process_noise_names, undefined_input_names, 
                 measured_var_names, MHE_opts):
        """
        Initiates the EKFArrivalCost-object by saving the relevant 
        inputs, reconstructing the covariance matrices and calling 
        for the creation of the Jacobian functions.
    
        Parameters::
            op -- 
                The OptimizationProblem object.
        
            sample_time --
                The sample time.
            
            state_names --  
                A list of the names of all the states.
                
            alg_var_names --
                A list of the names of all the algebraic variables.
                
            process_noise_names --
                A list of the names of all the process noise 
                variables.
                
            undefined_input_names --
                A list of the input names not specified by the user 
                and are thus set to zero.
                
            measured_var_names --
                A list of the names of all the measured variables.
            
            MHE_opts --
                A MHEOptions object. See the documentation of the 
                options object for more details.
        """
        self.op = op
        self.sample_time = sample_time
        self._state_names = state_names
        self._alg_var_names = alg_var_names
        self._input_names = MHE_opts['input_names']
        self._process_noise_names = process_noise_names
        self._all_input_names = self._input_names + \
                                [name for name in self._process_noise_names \
                                if name not in self._input_names] + \
                                undefined_input_names
        self._measured_var_names = measured_var_names
        #Create the input list for the process noise
        self._zero_noise_list = [(name, 0.) for name \
                                 in self._process_noise_names \
                                 if name not in self._input_names]
        ##Reconstruct the covariance matrices from the covariance lists
        self._P = self._reconstruct_covariance_matrix(self._state_names,
                                                      MHE_opts['P0_cov'])
        self._Q = \
            self._reconstruct_covariance_matrix(self._process_noise_names,
                                                MHE_opts['process_noise_cov'])
        #Discretize the matrix
        self._Q = self._Q *self.sample_time
        self._R = \
              self._reconstruct_covariance_matrix(self._measured_var_names,
                                                  MHE_opts['measurement_cov'])
        #Discretize the matrix
        self._R = self._R / self.sample_time
        #Get derivative functions
        self._create_jacobian_functions()
      
    def _create_jacobian_functions(self):
        """
        Calculate the Jacobian functions of a DAE represented by an 
        OptimizationProblem object. The DAE is represented by
        
        F(dx,x,u,c,t) = 0
    
        The matrices are computed by evaluating Jacobians with CasADi. 
        (That is, no numerical finite differences are used in the 
        linearization.)
    
        The following functions are created:
    
        dF_dxdot:
            The derivative with respect to the derivative of the 
            state variables.
    
        dF_dx:
            The derivative with respect to the state variables.
    
        dF_dc:
            The derivative function with respect to the algebraic 
            variables.
    
        dF_du:
            The derivative with respect to the control signals.
        """
        #Make sure every parameter has a value
        self.op.calculateValuesForDependentParameters()
        
        self._mvar_vectors = {'dx': N.array([self.op.getVariable('der(' + \
                                            name + ')') for name in self._state_names]), 
                              'x': N.array([self.op.getVariable(name) \
                                           for name in self._state_names]), 
                              'u': N.array([self.op.getVariable(name) \
                                           for name in self._all_input_names]), 
                              'c': N.array([self.op.getVariable(name) \
                                           for name in self._alg_var_names])} 

        self._nvar = {'dx': len(self._mvar_vectors["dx"]),
                      'x': len(self._mvar_vectors["x"]),
                      'u': len(self._mvar_vectors["u"]),
                      'c': len(self._mvar_vectors["c"])}

        # Sort parameters
        par_kinds = [self.op.BOOLEAN_CONSTANT,
                     self.op.BOOLEAN_PARAMETER_DEPENDENT,
                     self.op.BOOLEAN_PARAMETER_INDEPENDENT,
                     self.op.INTEGER_CONSTANT,
                     self.op.INTEGER_PARAMETER_DEPENDENT,
                     self.op.INTEGER_PARAMETER_INDEPENDENT,
                     self.op.REAL_CONSTANT,
                     self.op.REAL_PARAMETER_INDEPENDENT,
                     self.op.REAL_PARAMETER_DEPENDENT]

        pars = reduce(list.__add__, [list(self.op.getVariables(par_kind)) for
                                     par_kind in par_kinds])
        self._mvar_vectors['p_fixed'] = [par for par in pars
                                         if not self.op.get_attr(par, "free")]  

        # Create named symbolic variable structure
        named_mvar_struct = OrderedDict()
        named_mvar_struct["time"] = [self.op.getTimeVariable()]
        named_mvar_struct["dx"] = \
            [mvar.getVar() for mvar in self._mvar_vectors['dx']]    
        named_mvar_struct["x"] = \
            [mvar.getVar() for mvar in self._mvar_vectors['x']]
        named_mvar_struct["c"] = \
            [mvar.getVar() for mvar in self._mvar_vectors['c']]
        named_mvar_struct["u"] = \
            [mvar.getVar() for mvar in self._mvar_vectors['u']]    




        # Substitute named variables with vector variables in expressions
        named_vars = reduce(list.__add__, named_mvar_struct.values()) 
        self._mvar_struct = OrderedDict()
        self._mvar_struct["time"] = casadi.MX.sym("time")
        self._mvar_struct["dx"] = casadi.MX.sym("dx", self._nvar['dx'])
        self._mvar_struct["x"] = casadi.MX.sym("x", self._nvar['x'])
        self._mvar_struct["c"] = casadi.MX.sym("c", self._nvar['c'])
        self._mvar_struct["u"] = casadi.MX.sym("u", self._nvar['u'])
        svector_vars=[self._mvar_struct["time"]]

        # Create map from name to variable index and type
        self._name_map = {}
        for vt in ["dx","x", "c", "u"]:
            i = 0
            for var in self._mvar_vectors[vt]:
                name = var.getName()
                self._name_map[name] = (i, vt)
                svector_vars.append(self._mvar_struct[vt][i])
                i = i + 1


        # DAEResidual in terms of the substituted variables
        self._dae = casadi.substitute([self.op.getDaeResidual()],
                                      named_vars, 
                                      svector_vars)
        # Get parameter values
        par_vars = [par.getVar() for par in self._mvar_vectors['p_fixed']]
        par_vals = [self.op.get_attr(par, "_value")
                    for par in self._mvar_vectors['p_fixed']]

        # Substitute non-free parameters in expressions for their values
        DAE = casadi.substitute(self._dae, par_vars, par_vals)
        # Defines the DAEResidual Function
        self.Fdae = casadi.MXFunction([self._mvar_struct["time"], 
                                       self._mvar_struct["dx"],
                                       self._mvar_struct["x"], 
                                       self._mvar_struct["c"],
                                       self._mvar_struct["u"]], 
                                       DAE)

        self.Fdae.init()
        # Define derivatives
        self.dF_dxdot = self.Fdae.jacobian(1,0)
        self.dF_dxdot.init()
        self.dF_dx = self.Fdae.jacobian(2,0)
        self.dF_dx.init()
        self.dF_dc = self.Fdae.jacobian(3,0)
        self.dF_dc.init()
        self.dF_du = self.Fdae.jacobian(4,0)
        self.dF_du.init()
    
    def recalculate_jacobian_functions(self):
        """
        Recalculates the Jacobian functions after a change of the model
        parameter values.
        """
        par_kinds = [self.op.BOOLEAN_CONSTANT,
                     self.op.BOOLEAN_PARAMETER_DEPENDENT,
                     self.op.BOOLEAN_PARAMETER_INDEPENDENT,
                     self.op.INTEGER_CONSTANT,
                     self.op.INTEGER_PARAMETER_DEPENDENT,
                     self.op.INTEGER_PARAMETER_INDEPENDENT,
                     self.op.REAL_CONSTANT,
                     self.op.REAL_PARAMETER_INDEPENDENT,
                     self.op.REAL_PARAMETER_DEPENDENT]
        pars = reduce(list.__add__, [list(self.op.getVariables(par_kind)) for
                                     par_kind in par_kinds])
        #Get the parameters except for startTime and finalTime since their 
        #value can't be evaluated
        parameter_vars = [par for par in pars
                          if not self.op.get_attr(par, "free") \
                          and not (par.getName() == 'startTime' or \
                          par.getName() == 'finalTime')]
        # Get parameter values
        par_vars = [par.getVar() for par in parameter_vars]
        par_vals = [self.op.get_attr(par, "_value")
                    for par in parameter_vars]
        # Substitute non-free parameters in expressions for their values
        DAE = casadi.substitute(self._dae, par_vars, par_vals)
        # Defines the DAEResidual Function
        self.Fdae = casadi.MXFunction([self._mvar_struct["time"], 
                                       self._mvar_struct["dx"],
                                       self._mvar_struct["x"], 
                                       self._mvar_struct["c"],
                                       self._mvar_struct["u"]], 
                                       DAE)
        self.Fdae.init()
        # Define derivatives
        self.dF_dxdot = self.Fdae.jacobian(1,0)
        self.dF_dxdot.init()
        self.dF_dx = self.Fdae.jacobian(2,0)
        self.dF_dx.init()
        self.dF_dc = self.Fdae.jacobian(3,0)
        self.dF_dc.init()
        self.dF_du = self.Fdae.jacobian(4,0)
        self.dF_du.init()
    
    def update_process_noise_covariance_matrix(self, process_noise_cov):
        """
        Updates the process noise covariance matrix according to a 
        new covariance list describing the process noise covariance 
        matrix in continuous time.
        
        Parameters::
            process_noise_cov --
                A list describing the covariance structure of the 
                process noise. Items are on the form 
                (names, covariance_matrix). Names is a list, tuple or 
                string of the variable names which have a covariance 
                matrix given by covariance_matrix. If names is a list 
                or tuple of length 1 or a string the covariance_matrix 
                can be given as a float or a 1D or 2D numpy array. For 
                lists or tuple of length greater than 1 covariance_matrix 
                is given as a 2D numpy array. 
        """
        #Reconstruct the matrix from the list
        self._Q = \
                self._reconstruct_covariance_matrix(self._process_noise_names,
                                                    process_noise_cov)
        #Discretize the matrix
        self._Q = self._Q * self.sample_time
        
    def update_measurement_noise_covariance_matrix(self, measurement_cov):
        """
        Updates the measurement noise covariance matrix according 
        to a new covariance list describing the measurement noise 
        covariance matrix in continuous time.
        
        Parameters::
            measurement_cov --
                A list describing the covariance structure of the 
                measurement noise. Items are on the form 
                (names, covariance_matrix). Names is a list, tuple or 
                string of the variable names which have a covariance 
                matrix given by covariance_matrix. If names is a list 
                or tuple of length 1 or a string the covariance_matrix 
                can be given as a float or a 1D or 2D numpy array. For 
                lists or tuple of length greater than 1 covariance_matrix 
                is given as a 2D numpy array.
        """
        #Reconstruct the matrix from the list
        self._R = self._reconstruct_covariance_matrix(self._measured_var_names,
                                                      measurement_cov)
        #Discretize the matrix
        self._R = self._R / self.sample_time
        
    def _evaluate_jacobian_functions(self, z0, t0):
        """
        Evaluates the function created in _create_jacobian_functions 
        for a certain point.
    
        Parameters::
    
            z0 -- 
                Dictionary with the reference point around which 
                the linearization is done. 
                z0['variable_type']= [("variable_name",value),
                                      ("name",z_r)]
                z0['x']= [("x1",v1),("x2",v2)...]
                z0['dx']= [("der(x1)",dv1),("der(x2)",dv2)...]
                z0['u']= [("u1",uv1),("u2",uv2)...]
                z0['c']= [("c1",cv1),("c2",cv2)...]
            
            t0 -- 
                Time for which the linearization is done.

        Returns::
    
            E -- 
                n_eq_F x n_dx matrix corresponding to dF/ddx.
                
            A -- 
                n_eq_F x n_x matrix corresponding to -dF/dx.
                
            B -- 
                n_eq_F x n_u matrix corresponding to -dF/du.
                
            C -- 
                n_eq_F x n_w matrix corresponding to -dF/dc.
        """
        # Compute reference point for the linearization 
        #[t0, dotx0, x0, c0, u0]
        RefPoint=dict()
        var_kinds = ["dx","x", "c", "u"]            

        RefPoint["time"] = t0 

        #Sort Values for reference point
        stop=False
        for vt in z0.keys():
            RefPoint[vt] = N.zeros(self._nvar[vt])
            passed_indices = list()
            for var_tuple in z0[vt]:
                index = self._name_map[var_tuple[0]][0]
                value = var_tuple[1]
                RefPoint[vt][index] = value
                passed_indices.append(index)
            missing_indices = [i for i in range(self._nvar[vt]) \
                               if i not in passed_indices]
        if len(missing_indices)!=0:
            if not stop:
                error_message = "Error: Please provide the value " +\
                                "for the following variables in z0:\n"
            for j in missing_indices:
                v = self._mvar_vectors[vt][j]
                name = v.getName()
                error_message = error_message + name + "\n"
            stop=True

        if stop:
            raise RuntimeError(error_message)
     
        missing_types = [vt for vt in var_kinds \
                         if vt not in z0.keys() and self._nvar[vt]!=0]
        if len(missing_types) !=0:
            error_message = "Error: Please provide the " +\
                            "following types in z0:\n"
            for j in missing_types:
                error_message = error_message + j + "\n"
            raise RuntimeError(error_message) 

        for vk in var_kinds:
            if self._nvar[vk]==0:
                RefPoint[vk] = N.zeros(self._nvar[vk])

        # Set inputs
        var_kinds = ["time"] + var_kinds
        for i,varType in enumerate(var_kinds):
            self.dF_dxdot.setInput(RefPoint[varType],i)
            self.dF_dx.setInput(RefPoint[varType],i)
            self.dF_dc.setInput(RefPoint[varType],i)
            self.dF_du.setInput(RefPoint[varType],i)

        # Evaluate derivatives
        self.dF_dxdot.evaluate()
        self.dF_dx.evaluate()
        self.dF_dc.evaluate()
        self.dF_du.evaluate()

        # Store result in Matrices
        E = self.dF_dxdot.getOutput()
        A = -self.dF_dx.getOutput()
        B = -self.dF_du.getOutput()
        C = -self.dF_dc.getOutput()
        
        return E, A, B, C
    
    def _update_P(self, A, C, G):
        """
        Updates the error covariance matrix using the matrices from 
        the discrete, linearised model on the form
        
        x_k+1 = Ax_k + Bu_k + Gw_k
        y_k = Cx_k + v_k
        
        Parameters::
            A --
                The A-matrix found in the system above. 2D numpy array
            
            C --
                The C-matrix found in the system above. 2D numpy array
            
            G --
                The G-matrix found in the system above. 2D numpy array   
        """
        GQGT = N.dot(N.dot(G, self._Q), N.transpose(G))
        APAT = N.dot(N.dot(A, self._P), N.transpose(A))
        APCT = N.dot(N.dot(A, self._P), N.transpose(C))
        R_CPCT = self._R + N.dot(N.dot(C, self._P),N.transpose(C))
        CPAT = N.dot(N.dot(C, self._P),N.transpose(A))
        self._P = GQGT + APAT - N.dot(APCT, N.linalg.solve(R_CPCT, CPAT))
    
    def _calculate_A_B_C_and_G(self, A, B, C, E):
        """
        Calculates the A, B, C and G matrix for the linearised system 
        from the matrices obtained from the 
        _evaluate_jacobian_functions function. This is done by 
        solving a linear system on the form 
        
        [E - C][xdot c]^T = Ax
        
        to get an expression for xdot in terms of x.
        
        Two help functions are called, 
        _calculate_C and _calculate__B_and_G, to 
        generate the C, B and G matrices of the linearised system.
        
        The linearised system is represented by
        
        xdot = Ax + Bu + Gw
        y = Cx + v
        
        Parameters::
            A --  
                The jacobian matrix of the systems DAE with respect to 
                the state variables. 2D numpy array.
          
            B --  
                The jacobian matrix of the systems DAE with respect to 
                the control signals.2D numpy array.
            
            C --  
                The jacobian matrix of the systems DAE with respect to 
                the algebraic variables.2D numpy array.
            
            E --  
                The jacobian matrix of the systems DAE with respect to the 
                derivatives of the state variables. 2D numpy array
        
        Returns::
            A_dx --
                The A matrix of the linearised system. 2D numpy array
            
            B --
                The B matrix of the linearised system. 2D numpy array
            
            C --
                The C matrix of the linearised system. 2D numpy array
            
            G --
                The G matrix of the linearised system. 2D numpy array
        """
        xN = self._nvar['x']
        E_C = N.concatenate((E,-C),1)
        E_C_A = N.linalg.solve(E_C, A)
    
        C = self._calculate_C(E_C_A)
    
        A_dx = A[0:xN,:]
    
        (B, G) = self._calculate_B_and_G(E_C, B)
    
        return A_dx, B, C, G
  
    def _calculate_C(self, E_C_A):
        """
        Calculates the C matrix of the linearised system. Does so by 
        adding a 1 at the appropriate place if the measured variable 
        is a state or takes the correct row from the solved linear 
        system
        
        [xdot c]^T = [E - C]^(-1)Ax
        
        if the measured variable is an algebraic variable
        
        Parameters::
            E_C_A --
                The matrix [E - C]^(-1)A from the solved linear system 
                described above. 2D numpy array
         
        Returns::
            C --
                The C matrix of the linearised system. 2D numpy array
        """
        xN = self._nvar['x']
        C = N.zeros((len(self._measured_var_names),xN))
        for i, name in enumerate(self._measured_var_names):
            (index, type) = self._name_map[name]
            if type == 'x':
                C[i, index] = 1.
            else:
                C[i,:] = E_C_A[xN+index,:]
    
        return C
  
    def _calculate_B_and_G(self, E_C, B):
        """
        Calculates the B and G matrices of the linearised system. 
        This is done by solving the linear system
        
        [E - C][xdot c]^T = Bu
        
        to get the equations corresponding to the derivatives of the 
        state vector. The rows corresponding to control signal are 
        then used to create the B matrix of the linearised system and 
        the rows corresponding to process noise variables are used to 
        create the G matrix.
        
        Parameters::
            E_C --  
                The [E - C] matrix in the linear system of equations 
                above. 2D numpy array
            
            B --  
                The jacobian matrix of the systems DAE with respect 
                to the control signals. 2D numpy array
        Returns::
            B --
                The B matrix of the linearised system. 2D numpy array
            
            G --
                The G matrix of the linearised system. 2D numpy array
        """
        B_du = N.linalg.solve(E_C, B)
        B_du = B_du[0:self._nvar['x'],:]
        noise_cols = []
        input_cols = []
        for input in self._input_names:
            input_cols.append(self._name_map[input][0])

        for name in self._process_noise_names:
            noise_cols.append(self._name_map[name][0])
    
        G = B_du[:,noise_cols]
        B = B_du[:,input_cols]
        return B, G
  
    def _backward_euler_discretize(self, Ac, Bc, Gc):
        """
        Discretizes the linearised system using the backward euler 
        method.
        
        Parameters::
            Ac --
                The A matrix of the continuous, linearised system. 
                2D numpy array
            
            Bc --
                The B matrix of the continuous, linearised system. 
                2D numpy array
            
            Gc --
                The G matrix of the continuous, linearised system. 
                2D numpy array
            
        Returns::
            Ad --
                The A matrix of the discrete, linearised system. 
                2D numpy array
            
            Bd --
                The B matrix of the discrete, linearised system. 
                2D numpy array
            
            Gd --
                The G matrix of the discrete, linearised system. 
                2D numpy array
        """
        I = N.eye(self._nvar['x'])
        Ad = N.linalg.solve((I - self.sample_time*Ac),I)
        Bd = self.sample_time*N.dot(Ad,Bc)
        Gd = self.sample_time*N.dot(Ad,Gc)
        return Ad, Bd, Gd
  
    def get_next_P(self, t, x, dx, u, c):
        """
        Calculate the error covariance matrix at the next time step. 
        This is achieved by evaluating the Jacobian function at the 
        work point, solving a linear system to get the system matrices 
        of the linearised system on the form:
         
        xdot = Ax + Bu + Gw
        y = Cx + v
        
        and then discretizing the system using backward Euler to get
        the system matrices of the system on the form.
        
        x_k+1 = Ax_k + Bu_k+1 + Gw_k+1
        y_k = Cx_k + v_k
        
        The error covariance is then updated using these matrices.
        
        Parameters::
            t --
                The time of the work point. Given as a float.
          
            x --
                A list of tuples on the form (varName, value) of the 
                state variables.
            
            dx --
                A list of tuples on the form (varName, value) of the 
                derivatives of the state variables.
          
            u --
                A list of tuples on the form (varName, value) of the 
                control signals.
            
            c --
                A list of tuples on the form (varName, value) of the 
                algebraic variables.
            
        Returns::
            P --
                The updated error covariance matrix. 2D numpy array.
        """
        z0 = {'x':x,
              'dx':dx,
              'u':u + self._zero_noise_list,
              'c':c}
        
        E, A, B, C = self._evaluate_jacobian_functions(z0, t)
        A, B, C, G = self._calculate_A_B_C_and_G(A, B, C, E)
        
        Ad, Bd, Gd = self._backward_euler_discretize(A, B, G)
        
        self._update_P(Ad, C, Gd)
    
        return self._P
    
    def _reconstruct_covariance_matrix(self, name_list, cov_list):
        """
        Reconstructs a covariance matrix from a list of variable 
        names, specifying the order of the variables, and a list with 
        items on the form (name_list, covariance_matrix). Where 
        'name_list' is a list with the names of N variables having a 
        covariance matrix of 'covariance_matrix' which is a N*N numpy 
        array.
        
        Parameters::
            name_list --
                A list of the names of the variables.
             
            cov_list --
                A list with items on the form (name_list, covariance). 
                Where 'name_list' is a list or a tuple with the names of 
                variables having a covariance_matrix of 
                'covariance_matrix'. In the case of a one dimensional 
                the list may be a single string and the matrix itself 
                can be given as a float.
        
        Returns::
            matrix --
                The reconstructed covariance matrix.
        """
        dim = len(name_list)
        matrix = N.zeros((dim,dim))
        for (list, cov_matrix) in cov_list:
            #Check if the expected iterable object is instead a string
            if isinstance(list, basestring):
                i = name_list.index(list)
                matrix[i, i] = cov_matrix
            else:
                #If the length of the list is one the cov_matrix could be a float
                if len(list) == 1:
                    name = list[0]
                    i = name_list.index(name)
                    matrix[i, i] = cov_matrix
                else:
                    for (k, n1) in enumerate(list):
                        i = name_list.index(n1)
                        for (l, n2) in enumerate(list):
                            j = name_list.index(n2)
                            matrix[i,j] = cov_matrix[k, l]
        return matrix