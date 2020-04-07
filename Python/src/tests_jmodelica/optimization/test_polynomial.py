#!/usr/bin/env python 
# -*- coding: utf-8 -*-

# Copyright (C) 2011 Modelon AB
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

""" Tests the casadi_polynomial module. """

import os
import nose

import numpy as N

from tests_jmodelica import testattr
from pyjmi.optimization.polynomial import *

class TestPolynomialMethods:
    """ This tests the evaluation of various polynomial methods. """

    @testattr(stddist_base = True)
    def test_legendre_pn(self):
        """Compare the Legendre_Pn evaluation against explicit expressions. """
        
        x = 0.5 #Point
        
        #Explicit Legendre expressions 
        #(http://mathworld.wolfram.com/LegendrePolynomial.html)
        P_0	= 1.0
        P_1 = x
        P_2 = 1.0/2.0*(3.0*x**2-1.0)
        P_3 = 1.0/2.0*(5.0*x**3.0-3.0*x)
        P_4 = 1.0/8.0*(35.0*x**4-30.0*x**2+3.0)
        P_5=  1.0/8.0*(63*x**5-70.0*x**3+15.0*x)
        P_6=  1.0/16.0*(231.0*x**6-315.0*x**4+105.0*x**2-5.0)
        
        nose.tools.assert_almost_equal(P_0, legendre_Pn(0, x), places=13)
        nose.tools.assert_almost_equal(P_1, legendre_Pn(1, x), places=13)
        nose.tools.assert_almost_equal(P_2, legendre_Pn(2, x), places=13)
        nose.tools.assert_almost_equal(P_3, legendre_Pn(3, x), places=13)
        nose.tools.assert_almost_equal(P_4, legendre_Pn(4, x), places=13)
        nose.tools.assert_almost_equal(P_5, legendre_Pn(5, x), places=13)
        nose.tools.assert_almost_equal(P_6, legendre_Pn(6, x), places=13)
        
    @testattr(stddist_base = True)
    def test_legendre_dpn(self):
        """Compare the Legendre_dPn evaluation against explicit expressions. """
        
        x = 0.5 #Point
        
        #Explicit Legendre expressions
        P_1 = 1.0
        P_2 = 1.0/2.0*(3.0*2.0*x)
        P_3 = 1.0/2.0*(5.0*3.0*x**2.0-3.0)
        P_4 = 1.0/8.0*(35.0*4.0*x**3-30.0*2.0*x)
        P_5=  1.0/8.0*(63.0*5.0*x**4-70.0*3.0*x**2+15.0)
        P_6=  1.0/16.0*(231.0*6.0*x**5-315.0*4.0*x**3+105.0*2.0*x)
        
        nose.tools.assert_almost_equal(P_1, legendre_dPn(1, x), places=13)
        nose.tools.assert_almost_equal(P_2, legendre_dPn(2, x), places=13)
        nose.tools.assert_almost_equal(P_3, legendre_dPn(3, x), places=13)
        nose.tools.assert_almost_equal(P_4, legendre_dPn(4, x), places=13)
        nose.tools.assert_almost_equal(P_5, legendre_dPn(5, x), places=13)
        nose.tools.assert_almost_equal(P_6, legendre_dPn(6, x), places=13)
    
    @testattr(stddist_base = True)
    def test_legendre_ddpn(self):
        """
            Compare the Legendre_ddPn evaluation against explicit expressions. 
        """
        
        x = 0.5 #Point
        
        #Explicit Legendre expressions
        P_1 = 0.0
        P_2 = 1.0/2.0*(3.0*2.0)
        P_3 = 1.0/2.0*(5.0*6.0*x)
        P_4 = 1.0/8.0*(35.0*12.0*x**2-30.0*2.0)
        P_5=  1.0/8.0*(63.0*20.0*x**3-70.0*6.0*x)
        P_6=  1.0/16.0*(231.0*30.0*x**4-315.0*12.0*x**2+105.0*2.0)
        
        nose.tools.assert_almost_equal(P_1, legendre_ddPn(1, x), places=13)
        nose.tools.assert_almost_equal(P_2, legendre_ddPn(2, x), places=13)
        nose.tools.assert_almost_equal(P_3, legendre_ddPn(3, x), places=13)
        nose.tools.assert_almost_equal(P_4, legendre_ddPn(4, x), places=13)
        nose.tools.assert_almost_equal(P_5, legendre_ddPn(5, x), places=13)
        nose.tools.assert_almost_equal(P_6, legendre_ddPn(6, x), places=13)
        
    
    @testattr(stddist_base = True)
    def test_jacobi_a1_b0_roots(self):
        """ Compare the roots of the Jacobi (a=1,b=0) polynonmial against 
            explicit expressions. 
        """
        roots1 = N.array([-1.0/3.0])
        roots2 = N.array([-1.0/5.0*(1.0+N.sqrt(6.0)), -1.0/5.0*(1.0-N.sqrt(6.0))])
        
        pn_r = jacobi_a1_b0_roots(1)
        nose.tools.assert_almost_equal(pn_r[0], roots1[0], places=13)
        
        pn_r = jacobi_a1_b0_roots(2)
        nose.tools.assert_almost_equal(pn_r[0], roots2[0], places=13)
        nose.tools.assert_almost_equal(pn_r[1], roots2[1], places=13)
    
    @testattr(stddist_base = True)
    def test_differentiation_matrix(self):
        """
            Tests the generation of the differentiation matrix for the different
            points.
        """
        #Tests LG matrix
        #TODO: FIX!
        
        #Tests the LGL matrix
        W = gauss_quadrature_weights("LGL", 10)
        D = differentiation_matrix("Legendre", 10)
        WTD = N.dot(W,D)
        nose.tools.assert_almost_equal(WTD[0], -1.0, places=11)
        nose.tools.assert_almost_equal(WTD[-1], 1.0, places=11)
        for i in range(1,9):
            nose.tools.assert_almost_equal(WTD[i], 0.0, places=11)
            
        #Tests the LGR matrix
        W = gauss_quadrature_weights("LGR", 10)
        D = differentiation_matrix("Radau", 10)
        WTD = N.dot(W,D)
        nose.tools.assert_almost_equal(WTD[0], -1.0, places=11)
        nose.tools.assert_almost_equal(WTD[-1], 1.0, places=11)
        for i in range(1,10):
            nose.tools.assert_almost_equal(WTD[i], 0.0, places=11)
    
    @testattr(stddist_base = True)
    def test_legendre_pn_roots(self):
        """ 
            Compare the roots of the Legendre_Pn polynomial against explicit 
            expressions. 
        """
        
        roots2 = N.array([-1.0/3.0*N.sqrt(3.0), 1.0/3.0*N.sqrt(3.0)])
        roots3 = N.array([-1.0/5.0*N.sqrt(15.0), 0.0, 1.0/5.0*N.sqrt(15.0)])
        roots4 = N.array([-1.0/35.0*N.sqrt(525.0+70.0*N.sqrt(30.0)),
                          -1.0/35.0*N.sqrt(525.0-70.0*N.sqrt(30.0)),
                           1.0/35.0*N.sqrt(525.0-70.0*N.sqrt(30.0)), 
                           1.0/35.0*N.sqrt(525.0+70.0*N.sqrt(30.0))])
        roots5 = N.array([-1.0/21.0*N.sqrt(245.0+14.0*N.sqrt(70.0)),
                          -1.0/21.0*N.sqrt(245.0-14.0*N.sqrt(70.0)),
                           0.0,
                          1.0/21.0*N.sqrt(245.0-14.0*N.sqrt(70.0)),
                          1.0/21.0*N.sqrt(245.0+14.0*N.sqrt(70.0))])

        pn_r = legendre_Pn_roots(2)
        nose.tools.assert_almost_equal(pn_r[0], roots2[0], places=13)
        nose.tools.assert_almost_equal(pn_r[1], roots2[1], places=13)
        
        pn_r = legendre_Pn_roots(3)
        nose.tools.assert_almost_equal(pn_r[0], roots3[0], places=13)
        nose.tools.assert_almost_equal(pn_r[1], roots3[1], places=13)
        nose.tools.assert_almost_equal(pn_r[2], roots3[2], places=13)
        
        pn_r = legendre_Pn_roots(4)
        nose.tools.assert_almost_equal(pn_r[0], roots4[0], places=13)
        nose.tools.assert_almost_equal(pn_r[1], roots4[1], places=13)
        nose.tools.assert_almost_equal(pn_r[2], roots4[2], places=13)
        nose.tools.assert_almost_equal(pn_r[3], roots4[3], places=13)
        
        pn_r = legendre_Pn_roots(5)
        nose.tools.assert_almost_equal(pn_r[0], roots5[0], places=13)
        nose.tools.assert_almost_equal(pn_r[1], roots5[1], places=13)
        nose.tools.assert_almost_equal(pn_r[2], roots5[2], places=13)
        nose.tools.assert_almost_equal(pn_r[3], roots5[3], places=13)
        nose.tools.assert_almost_equal(pn_r[4], roots5[4], places=13)
    
    @testattr(stddist_base = True)
    def test_gauss_legendre_radau_weights(self):
        """ Compare the weights of the Legendre-Gauss-Radau points against
            explicit values. """
        w2 = N.array([3/2.0,1.0/2.0])
        w3 = N.array([1.0/18.0*(16.0-N.sqrt(6)), 1.0/18.0*(16.0+N.sqrt(6)), 2.0/9.0])
        
        pn_w = gauss_quadrature_weights("LGR", 2)
        nose.tools.assert_almost_equal(pn_w[0], w2[0], places=13)
        nose.tools.assert_almost_equal(pn_w[1], w2[1], places=13)
        
        pn_w = gauss_quadrature_weights("LGR", 3)
        nose.tools.assert_almost_equal(pn_w[0], w3[0], places=13)
        nose.tools.assert_almost_equal(pn_w[1], w3[1], places=13)
        nose.tools.assert_almost_equal(pn_w[2], w3[2], places=13)
        
        # Test that the sum of all the weights are equal to two
        pn_w = gauss_quadrature_weights("LGR", 20)
        nose.tools.assert_almost_equal(N.sum(pn_w), 2.0, places=10)
        
        pn_w = gauss_quadrature_weights("LGR", 40)
        nose.tools.assert_almost_equal(N.sum(pn_w), 2.0, places=10)
        
        pn_w = gauss_quadrature_weights("LGR", 61)
        nose.tools.assert_almost_equal(N.sum(pn_w), 2.0, places=10)
    
    @testattr(stddist_base = True)
    def test_gauss_legendre_lobatto_weights(self):
        """ Compare the weights of the Legendre-Gauss-Lobatto points against
            explicit values. """

        #TODO ADD EXPLICIT VALUES
        
        # Test that the sum of all the weights are equal to two
        pn_w = gauss_quadrature_weights("LGL", 20)
        nose.tools.assert_almost_equal(N.sum(pn_w), 2.0, places=13)
        
        pn_w = gauss_quadrature_weights("LGL", 40)
        nose.tools.assert_almost_equal(N.sum(pn_w), 2.0, places=11)
        
        pn_w = gauss_quadrature_weights("LGL", 61)
        nose.tools.assert_almost_equal(N.sum(pn_w), 2.0, places=11)
        
    @testattr(stddist_base = True)
    def test_gauss_legendre_weights(self):
        """ 
            Compare the weights of Legendre-Gauss points against explicit 
            values. 
        """
        
        w2 = N.array([1.0,1.0])
        w3 = N.array([5.0/9.0, 8.0/9.0, 5.0/9.0])
        w4 = N.array([1.0/36.0*(18.0-N.sqrt(30.0)),
                      1.0/36.0*(18.0+N.sqrt(30.0)),
                      1.0/36.0*(18.0+N.sqrt(30.0)),
                      1.0/36.0*(18.0-N.sqrt(30.0))])
        w5 = N.array([1.0/900.0*(322.0-13.0*N.sqrt(70.0)),
                      1.0/900.0*(322.0+13.0*N.sqrt(70.0)),
                      128.0/225.0,
                      1.0/900.0*(322.0+13.0*N.sqrt(70.0)),
                      1.0/900.0*(322.0-13.0*N.sqrt(70.0))])

        pn_w = gauss_quadrature_weights("LG", 2)
        nose.tools.assert_almost_equal(pn_w[0], w2[0], places=13)
        nose.tools.assert_almost_equal(pn_w[1], w2[1], places=13)
        
        pn_w = gauss_quadrature_weights("LG", 3)
        nose.tools.assert_almost_equal(pn_w[0], w3[0], places=13)
        nose.tools.assert_almost_equal(pn_w[1], w3[1], places=13)
        nose.tools.assert_almost_equal(pn_w[2], w3[2], places=13)
        
        pn_w = gauss_quadrature_weights("LG", 4)
        nose.tools.assert_almost_equal(pn_w[0], w4[0], places=13)
        nose.tools.assert_almost_equal(pn_w[1], w4[1], places=13)
        nose.tools.assert_almost_equal(pn_w[2], w4[2], places=13)
        nose.tools.assert_almost_equal(pn_w[3], w4[3], places=13)
        
        pn_w = gauss_quadrature_weights("LG", 5)
        nose.tools.assert_almost_equal(pn_w[0], w5[0], places=13)
        nose.tools.assert_almost_equal(pn_w[1], w5[1], places=13)
        nose.tools.assert_almost_equal(pn_w[2], w5[2], places=13)
        nose.tools.assert_almost_equal(pn_w[3], w5[3], places=13)
        nose.tools.assert_almost_equal(pn_w[4], w5[4], places=13)
        
        # Test that the sum of all the weights are equal to two
        pn_w = gauss_quadrature_weights("LG", 20)
        nose.tools.assert_almost_equal(N.sum(pn_w), 2.0, places=13)
        
        pn_w = gauss_quadrature_weights("LG", 40)
        nose.tools.assert_almost_equal(N.sum(pn_w), 2.0, places=11)
        
        pn_w = gauss_quadrature_weights("LG", 61)
        nose.tools.assert_almost_equal(N.sum(pn_w), 2.0, places=11)
