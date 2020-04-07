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
Module containing polynomial evaluations, weight calculations etc. .
"""

import logging
import abc
import numpy as N
import numpy.linalg
import scipy.special as SP
try:
    import casadi
except ImportError:
    logging.warning(
        'Could not find CasADi package, aborting.')

class LocalPol(object):
    
    """
    Abstract base class for Lagrange polynomials used for local collocation.
    """
    
    __metaclass__ = abc.ABCMeta
    
    def __init__(self, n):
        """
        Parameters::
        
            n --
                Number of collocation points per element.
                Type: int
        """
        self.n = n
        self._calc_p()
        self._calc_w()
        self._calc_der_vals()
    
    @abc.abstractmethod
    def _calc_p(self):
        pass
    
    @abc.abstractmethod
    def _calc_w(self):
        pass
    
    def _calc_der_vals(self):
        # Derivatives of all basis polynomials at all interpolation points
        der_vals = casadi.DMatrix.ones(self.n + 1, self.n + 1)
        for j in xrange(self.n + 1):
            for k in xrange(self.n + 1):
                der_vals[j, k] = lagrange_derivative_eval(self.p, j,
                                                          self.p[k])
        
        # Store derivative values as data attribute
        self.der_vals = der_vals
    
    @abc.abstractmethod
    def eval_basis(self, i, tau, beg_interp):
        pass
    
    @abc.abstractmethod
    def eval_basis_der(self, i, tau):
        pass

class RadauPol(LocalPol):
    
    """
    Handles Lagrange polynomials used for Radau collocation.
    
    Data attributes::
    
        n --
            Number of collocation points per element.
            Type: int
    
        p --
            Interpolation points, including \tau_0 = 0.
            Type: rank 1 ndarray
            
        w --
            Quadrature weights.
            Type: rank 1 ndarray
            
        der_vals --
            Derivative values for each basis polynomial at the interpolation
            points. der_vals[j, k] contains the derivative of basis polynomial
            j evaluated at interpolation point k.
            Type: rank 2 ndarray
    """
        
    def _calc_p(self):
        # Calculate the roots for the non-shifted Gauss-Radau polynomial
        r = jacobi_a1_b0_roots(self.n - 1)
        
        # Shift the roots
        p = (r + 1) / 2
        
        # Add interpolation point for tau = 0 and tau = 1
        p = N.hstack([0., p, 1.])
        
        # Store interpolation points as data attribute
        self.p = p
        
    def _calc_w(self):
        # Calculate the weights for the non-shifted Gauss-Radau polynomial
        w = gauss_quadrature_weights("LGR", self.n)
        
        # Shift the weights
        w = N.hstack([N.nan, w / 2])
        
        # Store weights as data attribute
        self.w = w
    
    def eval_basis(self, i, tau, beg_interp):
        """
        Evaluate Lagrange basis polynomial.
        
        Parameters::
        
            i --
                Polynomial index, corresponds to interpolation point i.
                
                Type: int
                
            tau --
                Normalized time point to evaluate polynomial at.
                
                Type: float
                
            beg_interp --
                Whether or not to include an interpolation point at tau = 0.
                
                Type: bool
        """
        nbi = not beg_interp
        return lagrange_eval(self.p[nbi:], i - nbi, tau)
    
    def eval_basis_der(self, i, tau):
        """
        Evaluate derivative of Lagrange basis polynomial. Assumes an
        interpolation point at \tau = 0.
        
        Parameters::
        
            i --
                Polynomial index, corresponds to interpolation point i.
                
                Type: int
                
            tau --
                Normalized time point to evaluate polynomial at.
                
                Type: float
        """
        return lagrange_derivative_eval(self.p, i, tau)

class GaussPol(LocalPol):
    
    """
    Handles Lagrange polynomials used for Gauss collocation.
    
    Data attributes::
    
        n --
            Number of collocation points per element.
            Type: int
    
        p --
            Interpolation points, including \tau_0 = 0.
            Type: rank 1 ndarray
            
        w --
            Quadrature weights.
            Type: rank 1 ndarray
            
        der_vals --
            Derivative values for each basis polynomial at the interpolation
            points. der_vals[j, k] contains the derivative of basis polynomial
            j evaluated at interpolation point k.
            Type: rank 2 ndarray
    """
    
    def _calc_p(self):
        # Calculate the roots for the non-shifted Gauss-Legendre polynomial
        r = legendre_Pn_roots(self.n)
        
        # Shift the roots
        p = (r + 1) / 2
        
        # Add interpolation points for tau = 0
        p = N.hstack([0., p])
        
        # Store interpolation points as data attribute
        self.p = p
    
    def _calc_w(self):
        # Calculate the weights for the non-shifted Gauss-Radau polynomial
        w = gauss_quadrature_weights("LG", self.n)
        
        # Shift the weights
        w = N.hstack([N.nan, w / 2])
        
        # Store weights as data attribute
        self.w = w
    
    # Inherit evaluation methods from RadauPol
    eval_basis = RadauPol.__dict__["eval_basis"]
    eval_basis_der = RadauPol.__dict__["eval_basis_der"]

class LobattoPol(LocalPol):
    
    """
    Handles Lagrange polynomials used for Lobatto collocation.
    
    Data attributes::
    
        n --
            Number of collocation points per element.
            Type: int
    
        p --
            Interpolation (and collocation) points.
            Type: rank 1 ndarray
            
        w --
            Quadrature weights.
            Type: rank 1 ndarray
            
        der_vals --
            Derivative values for each basis polynomial at the interpolation
            points. der_vals[j, k] contains the derivative of basis polynomial
            j evaluated at interpolation point k.
            Type: rank 2 ndarray
    """
    
    def _calc_p(self):
        # Calculate the roots for the non-shifted Gauss-Legendre polynomial
        r = legendre_dPn_roots(self.n - 1)
        
        # Shift the roots
        p = (r + 1) / 2
        
        # Add interpolation points for tau = 0 and tau = 1
        p = N.hstack([N.nan, 0., p, 1.])
        
        # Store interpolation points as data attribute
        self.p = p
        
    def _calc_w(self):
        # Calculate the weights for the non-shifted Gauss-Legendre polynomial
        w = gauss_quadrature_weights("LGL", self.n)
        
        # Shift the weights
        w = N.hstack([N.nan, w / 2])
        
        # Store weights as data attribute
        self.w = w
    
    def eval_basis(self, i, tau):
        """
        Evaluate Lagrange basis polynomial.
        
        Parameters::
        
            i --
                Polynomial index, corresponds to interpolation point i.
                
                Type: int
                
            tau --
                Normalized time point to evaluate polynomial at.
                
                Type: float
        """
        return lagrange_eval(self.p[1:], i - 1, tau)
    
    def eval_basis_der(self, i, tau):
        """
        Evaluate derivative of Lagrange basis polynomial.
        
        Parameters::
        
            i --
                Polynomial index, corresponds to interpolation point i.
                
                Type: int
                
            tau --
                Normalized time point to evaluate polynomial at.
                
                Type: float
        """
        return lagrange_derivative_eval(self.p[1:], i - 1, tau)
        
def lagrange(R):
    """
    Creates K Lagrange Polynomials given R roots. Returns a vector of Poly1D 
    polynomials.
    
    .. math::
    
        L_i(t) = \prod_{j=0,j \\neq i}^N \\frac{t-t_j}{t_i - t_j}
        
    Parameters::
    
        R   --
            The roots for which lagrange polynomials should be created. Array.
    
    .. warning::
    
        Numerically highly unstable. Consider using "lagrange_eval"
    
    """
    K = len(R)
    L = []
    
    for i in range(K):
        p = 1.0
        for j in range(K):
            if i==j:
                continue
            else:
                p = p*SP.poly1d([1.0, -R[j]])/(R[i]-R[j])
        L += [p]
    return L

def lagrange_eval(R, i, t):
    """
    Evaluates the i:th Lagrange polynomial based on the roots, R at point t.
    
    .. math::
    
        L_i(t) = \prod_{j=0,j \\neq i}^N \\frac{t-t_j}{t_i - t_j}
        
    Parameters::
    
        R   --
            The roots for which lagrange polynomials should be created. Array.
            
        i   --
            The index of the lagrange polynomial. Integer.
            
        t   --
            The point at which the polynomial should be evaluated. Double.
    
    """
    val = 1.0
    x   = N.array(t)
    R   = N.array(R)
    
    K = len(R)
    
    for j in range(K):
        if j==i:
            continue
        else:
            val *= (x-R[j])/(R[i]-R[j])
    return val

def lagrange_derivative_eval(R, i, t):
    """
    Evaluates the derivative of the i:th Lagrange polynomial based on the roots,
    R at point t.
    
    .. math::
    
        \\frac{dL_i(t)}{dt} = \\frac{d}{dt} \prod_{j=0,j \\neq i}^N \\frac{t-t_j}{t_i - t_j}
        
    Parameters::
    
        R   --
            The roots for which lagrange polynomials should be created. Array.
            
        i   --
            The index of the lagrange polynomial. Integer.
            
        t   --
            The point at which the polynomial should be evaluated. Double.
    
    """
    val = N.array(0.0)
    x   = N.array(t)
    R   = N.array(R)
    
    K = len(R)
    
    for l in range(K):
        if l==i:
            continue
        lval = N.array(1.0)
        for j in range(K):
            if j==i:
                continue
            elif j==l:
                lval *= N.array(1.0)/(R[i]-R[j])
            else:
                lval *= (x-R[j])/(R[i]-R[j])
        val += lval
    return val

def legendre_Pn(K, x):
    """
    Calculates the Legendre polynomial of degree K at point x, :math:`P_n(x)` using
    the recurrence relation:
    
    .. math::
    
        P_l(x) = \\frac{2l-1}{l} \cdot x \cdot P_{l-1}(x)- \\frac{l-1}{l} \cdot P_{l-2}(x), \quad l=2,...,K
        
        P_0(x) = 1.0
        
        P_1(x) = x
    
    Parameters::
    
        K   --
            The degree of the polynomial. Integer.
            
        x   --
            The point at which the polynomial should be evaluated. Double.
    
    .. note::
        
        A reference can be found at, http://mathworld.wolfram.com/LegendrePolynomial.html (eq:43)
    """
    p0 = N.array(1.0)
    p1 = N.array(x)
    
    if K==0:
        return p0
    elif K==1:
        return p1
    else:
        for n in range(2,K+1):
            pn = (2*n-1)*x*p1/n-(n-1)*p0/n
            p0 = p1
            p1 = pn
        return pn

def legendre_dPn(K, x):
    """
    Calculates the derivative of the Legendre polynomial of degree K
    at point x, :math:`P_K'(x)` using the relation:
    
    .. math::
    
        P_K'(x) = \\frac{K \cdot P_{K-1}(x)-K \cdot x \cdot P_K(x)}{1-x^2} 
    
    the end points :math:`P_K'(-1)` and :math:`P_K'(1)` are given by:
    
    .. math::
    
        P_K'(x) = \\frac{x^{K+1} \cdot K \cdot (K+1)}{2.0}

    where :math:`P_{K-1}` and :math:`P_K` are the Legendre polynomials of degree K-1 and
    K.
    
    Parameters::
    
        K   --
            The degree of the Legendre polynomial. Integer.
            
        x   --
            The point at which the derived polynomial should be evaluated. Double.
    
    .. note::
    
        A reference can be found at, http://mathworld.wolfram.com/LegendrePolynomial.html (eq:44)
    
    """
    p0 = legendre_Pn(K-1, x)
    p1 = legendre_Pn(K, x)
    
    if N.abs(x)==1.0:
        pn = x**(K+1)*K*(K+1)/2.0
    else:
        pn = (K*p0-K*x*p1)/(1.0-x**2)
    
    return pn
    
def legendre_ddPn(K, x):
    """
    Calculates the second derivative of the Legendre polynomial of degree K
    at point x, :math:`P_K''(x)` using the relation:
    
    .. math::
    
        P_l''(x) = \\frac{1}{4} \cdot (l+1) \cdot (l+2) \cdot P_{l-2}^{2,2}(x), \quad l=2,...,K
        
        P_0''(x) = 0
        
        P_1''(x) = 0
        
    where :math:`P_{l-2}^{2,2}(x)` is the l-2 degree Jacobi polynomial with a=2 and
    b=2. The Jacobi polynomial is solved using the recurrence relation:
    
    .. math::
    
        2l \cdot (l+4) \cdot (2l+2) \cdot P_l^{2,2}(x) = (2l+2)_3 \cdot x \cdot P_{l-1}^{2,2}(x)-2(l+1)^2 \cdot (2l+4) \cdot P_{l-2}^{2,2}(x), \quad l=2,...,K
    
        P_0^{2,2}(x) = 1
        
        P_1^{2,2}(x) = 3x
        
    Parameters::
    
        K   --
            The degree of the Legendre polynomial. Integer.
            
        x   --
            The point at which the derived polynomial should be evaluated. Double.
    
    .. note::
    
        A reference can be found at, http://mathworld.wolfram.com/JacobiPolynomial.html (eq:12, eq:14)
    
    """
    p0 = N.array(0.0)
    p1 = N.array(0.0)
    
    if K==0:
        return p0
    elif K==1:
        return p1
    else:
        p0 = N.array(1.0)
        p1 = N.array(3.0*x)
        if K==2:
            pn=p0
        elif K==3:
            pn=p1
        else:
            for n in range(2, K-1):
                pn = 1.0/(2.0*n*(n+4.0)*(2.0*n+2.0))*((2.0*n+2.0)*(2.0*n+3.0)*(2.0*n+4.0)*x*p1-2.0*(n+1.0)**2.0*(2.0*n+4.0)*p0)
                p0 = p1
                p1 = pn
                
    return pn*1.0/4.0*(K+1.0)*(K+2.0)
    
def legendre_Pn_roots(K):
    """
    Calculates the K roots of the K degree Legendre polynomial by first
    generating the Jacobi matrix. The Jacobi matrix is a :math:`K \\times K` 
    where the only non-zero elements are on the superdiagonal and subdiagonal 
    as,
    
    .. math::
    
        A(l+1, l) = \\frac{l}{\sqrt{4l^2-1}} , \quad l=1,...,K-1
        
        A(l, l+1) = \\frac{l}{\sqrt{4l^2-1}} , \quad l=1,...,K-1
    
    For a degree 4 Legendre polynomial, the Jacobi matrix is:  
    
    .. math::

        \\begin{pmatrix}
            0          &   \\frac{1}{\sqrt{3}}   &   0           &    0    \\\\
            \\frac{1}{\sqrt{3}}  &   0           &   \\frac{2}{\sqrt{15}} &    0   \\\\
            0          &   \\frac{2}{\sqrt{15}}  &   0           &    \\frac{3}{\sqrt{35}} \\\\
            0          &   0           &   \\frac{3}{\sqrt{35}}  &    0    
        \end{pmatrix}

    Parameters::
    
        K   --
            Specifies the order of the Legendre polynomial for which roots are 
            to be calculated. Integer.
           
    """
    supdiag = [i/N.sqrt(4.0*i*i-1) for i in range(1,K)]

    A = N.diag(supdiag, 1)+N.diag(supdiag, -1)
    r = N.linalg.eig(A)[0]
    r.sort()
    return r
    
def legendre_dPn_roots(K):
    """
    Calculates K-1 roots of the derivative of the K degree Legendre Polynomial.
    The calculations are performed via generation of a Jacobi Matrix. The Jacobi 
    matrix is a :math:`(K-1) \\times (K-1)` where the only non-zero elements are on the 
    superdiagonal and subdiagonal as,
    
    .. math::
    
        A(l+1, l) = \sqrt{ \\frac{l \cdot (l+2)}{(2l+1) \cdot (2l+3)}} , \quad l=1,...,K-2
        
        A(l, l+1) = \sqrt{ \\frac{l \cdot (l+2)}{(2l+1) \cdot (2l+3)}} , \quad l=1,...,K-2
    
    Parameters::
    
        K   --
            Specifies the order of the underlying Legendre polynomial for which 
            roots of the derivative are to be calculated. Integer.
    
    
    .. note::
    
        A reference can be found at, 
        http://mathworld.wolfram.com/JacobiPolynomial.html (eq:11, 12)
    """
    if K < 2:
        return N.array([])
    K = K-1
    supdiag = [N.sqrt(i*(i+2.0)/((2.0*i+1.0)*(2.0*i+3.0))) for i in range(1,K)]
    
    A = N.diag(supdiag, 1)+N.diag(supdiag, -1)
    r = N.linalg.eig(A)[0]
    r.sort()
    return r

def jacobi_a1_b0_roots(K):
    """
    Calculates the K roots of the K degree Jacobi (a=1,b=0) Polynomial. The
    calculations are performed via generation of a Jacobi Matrix. The Jacobi 
    matrix is a :math:`K \\times K` where the only non-zero elements are on the 
    diagonal, superdiagonal and subdiagonal as,
    
    .. math::
    
            A(l+1,l) = \sqrt{\\frac{n \cdot (n+1)}{2n+1} } , \quad l=1,...,K-1
            
            A(l,l+1) = \sqrt{\\frac{n \cdot (n+1)}{2n+1} } , \quad l=1,...,K-1
            
            B(l,l)   = \\frac{-1}{(2n+1) \cdot (2n+3) }, \quad l=0,...,K-1
    
    Parameters::
    
        K   --
            Specifies the order of the Jacobi (a=1,b=0) polynomial for which 
            roots are to be calculated. Integer.
    
    .. note::
    
        A reference can be found at, 
        http://mathworld.wolfram.com/JacobiPolynomial.html (eq:11, 12) 
    
    """
    if K == 0:
        return N.array([])
    A = [1.0/(2.0*i+1.0)*N.sqrt(i*(i+1.0)) for i in range(1,K)]
    B = [-1.0/((2.0*i+1.0)*(2.0*i+3.0)) for i in range(0,K)]
     
    M = N.diag(A, 1)+N.diag(A, -1)+N.diag(B)
    r = N.linalg.eig(M)[0]
    r.sort()
    return r

def differentiation_matrix(type, K):
    """
    Calculates the differentiation matrix for the given type of collocation
    points. 
    
    .. math::
    
        D_{ki} = \\frac{dL_i(t_k)}{dt}, \quad k=1,..,K , \quad i=1,...,M
        
    where K are the collocation points and M are the number of points used
    in the approximation of the states. M is determined by the choice of points.
    L are lagrange polynomials.
    
    Parameters::
    
        type    --
                Determines the pseudospectral type for which the differentiation
                matrix should be calculated. Allowed options, "Gauss", 
                "Legendre", "Radau".
    
    type = "Gauss", generates the differentiation matrix for the 
    Gauss-Pseudospectral method. M = K + 1.
    
    .. math::
        
            D_{ki} = \\frac{(1+t_k) \cdot P_K'(t_k) + P_K(t_k)}{(t_k-t_i) \cdot ( (1+t_i) \cdot P_K'(t_i) + P_K(t_i) )} , \quad \\text{if} \quad i \\neq k

            \\frac{(1+t_i) \cdot P_K''(t_i) + 2 \cdot P_K'(t_i)}{ 2 \cdot ( (1+t_i) \cdot P_K'(t_i) + P_K(t_i) )} , \quad \\text{if} \quad i=k
                            
    type="Legendre", generates the differentiation matrix for the 
    Legendre-Pseudospectral method. M = K.
    
    .. math::
    
            D_{ki} =  \\frac{P_{K-1}(t_k)}{P_{K-1}(t_i)} \cdot \\frac{1}{t_k - t_i} , \quad \\text{if} \quad i \\neq k
    
            \\frac{- (K-1) \cdot K}{4} , \quad \\text{if} \quad i=k=1
    
            \\frac{(K-1) \cdot K}{4} , \quad \\text{if} \quad i=k=K
    
            0.0 , \quad \\text{otherwise}
                   
    type = "Radau", generates the differentiation matrix for the 
    Radau-Pseudospectral method (flipped LGR points). M = K+1.
    
    .. math::
    
            D_{ki} =  \\frac{ (1+t_k) \cdot ( P_K'(t_k) - P_{K-1}'(t_k) ) + P_K(t_k) - P_{K-1}(t_k) }{ (t_k-t_i) \cdot ( (1+t_i) \cdot ( P_K'(t_i) - P_{K-1}'(t_i) ) + P_K(t_i) - P_{K-1}(t_k) ) } , \quad \\text{if} \quad i \\neq k
    
            \\frac{ (1+t_i) \cdot ( P_K''(t_i) - P_{K-1}''(t_i) ) + 2 \cdot P_K'(t_i) - 2 \cdot P_{K-1}'(t_i) }{ 2 \cdot ( (1+t_i) \cdot ( P_K'(t_i) - P_{K-1}'(t_i) ) + P_K(t_i) - P_{K-1}(t_k) ) } , \quad \\text{if} \quad i=k
    """
    if type == "Gauss":
        M = K+1
        D = N.zeros((K,M))
        
        kk = legendre_Pn_roots(K)
        ii = N.append(-1.0, kk)
        
        Pn_k   = [legendre_Pn(K, x) for x in ii]
        dPn_k  = [legendre_dPn(K, x) for x in ii]
        ddPn_k = [legendre_ddPn(K, x) for x in ii]
        
        for k in range(K):
            tk = kk[k]
            for i in range(M):
                ti = ii[i]
                if i != k+1:
                    D[k,i] = ( (1.0+tk)*dPn_k[k+1] + Pn_k[k+1] ) / ( (tk-ti)*( (1.0+ti)*dPn_k[i] + Pn_k[i] ) )
                else:
                    D[k,i] = ( (1.0+ti)*ddPn_k[i] + 2.0*dPn_k[i] ) / ( 2.0*( (1.0+ti)*dPn_k[i] + Pn_k[i] )  )
    
    elif type == "Legendre":
        M = K
        D = N.zeros((K,M))
        
        kk = N.append(N.append(-1.0, legendre_dPn_roots(K-1)), 1.0)
        ii = kk
        
        Pn_k   = [legendre_Pn(K-1, x) for x in ii]
        
        for k in range(K):
            tk = kk[k]
            for i in range(M):
                ti = ii[i]
                if i != k:
                    D[k,i] = Pn_k[k]/Pn_k[i] * 1.0 / (tk-ti)
                elif k==0 and i==0:
                    D[k,i] = -(K-1)*K / 4.0
                elif k+1==K and i+1 ==K:
                    D[k,i] =  (K-1)*K / 4.0
                else:
                    D[k,i] = 0.0
    
    elif type == "Radau":
        M = K+1
        D = N.zeros((K,M))
        
        kk = N.append(jacobi_a1_b0_roots(K-1), 1.0)
        ii = N.append(-1.0, kk)
        
        Pn_k   = [legendre_Pn(K, x)-legendre_Pn(K-1, x) for x in ii]
        dPn_k  = [legendre_dPn(K, x)-legendre_dPn(K-1, x) for x in ii]
        ddPn_k = [legendre_ddPn(K, x)-legendre_ddPn(K-1, x) for x in ii]
        
        for k in range(K):
            tk = kk[k]
            for i in range(M):
                ti = ii[i]
                if i != k+1:
                    D[k,i] = ( (1.0+tk)*dPn_k[k+1] + Pn_k[k+1] ) / ( (tk-ti)*( (1.0+ti)*dPn_k[i] + Pn_k[i] ) )
                else:
                    D[k,i] = ( (1.0+ti)*ddPn_k[i] + 2.0*dPn_k[i] ) / ( 2.0*( (1.0+ti)*dPn_k[i] + Pn_k[i] )  )
    
    else:
        raise Exception("Unknown option to differentiation_matrix.")
        
    return D
    
def gauss_quadrature_weights(type, K):
    """
    Calculates the K Gauss quadrature weights for a given type of points.
    
    Parameters::
    
        type    --
                Determines the type of points which the weights should be 
                calculated for. Allowed options, "LG", "LGR", "LGL".
    
    "LG" , corresponding to Legendre-Gauss points. Weights are calculated for 
    the K Legendre-Gauss points as:
    
    .. math::
                
        w_i = \\frac{2}{(1-t_i^2) \cdot P_n'(t_i)^2}, \quad i=1,...,K
                
    "LGL", corresponding to Legendre-Gauss-Lobatto points. Weights are 
    calculated for the K Legendre-Gauss-Lobatto points as:
    
    .. math::
    
        w_i = \\frac{2}{ K \cdot (K-1) } \cdot \\frac{1}{P_{n-1}(t_i)^2}, \quad i=2,...,K-1
    
    .. math::
        
        w_1 = w_K = \\frac{2}{K \cdot (K-1)}
    
    "LGR", corresponding to (flipped) Legendre-Gauss-Radau points, i.e the end 
    point 1 is included instead of -1. Weights are calculated for the K 
    Legendre-Gauss-Radau points as:
    
    .. math::
    
        w_i = \\frac{1}{(1-t_i) \cdot P_n'(t_i)^2}, \quad i=1,..,K-1
        
    .. math::
    
        w_K = \\frac{2}{K^2}
        
    """
    w = N.zeros(K)
    
    if type == "LG":
        ti = legendre_Pn_roots(K)
        dPn_ti = [legendre_dPn(K,x) for x in ti]
        w = [2.0/((1.0-ti[i]**2)*x**2) for i,x in enumerate(dPn_ti)]
        
    elif type == "LGL":
        ti = N.append(N.append(-1.0, legendre_dPn_roots(K-1)), 1.0)
        Pn_ti = [legendre_Pn(K-1, x) for x in ti]
        w = [2.0/(K*(K-1))*1.0/x**2 for x in Pn_ti]
        
    elif type == "LGR":
        ti = jacobi_a1_b0_roots(K-1)
        dPn_ti = [legendre_dPn(K-1, x) for x in ti]
        w = [1.0/((1.0+ti[i])*x**2) for i,x in enumerate(dPn_ti)]
        w += [N.array(2.0/K**2)]
        
    else:
        raise Exception("Unknown option to Gauss Quadrature.")
                        
    return N.array(w)
