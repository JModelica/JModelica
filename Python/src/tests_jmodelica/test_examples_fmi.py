#!/usr/bin/env python 
# -*- coding: utf-8 -*-

#    Copyright (C) 2012 Modelon AB
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, version 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

""" 
Test module for testing the FMI examples.
"""

from tests_jmodelica import testattr
from pyfmi.examples import *
from pyjmi.examples import (crane,
                            distillation_fmu,
                            distillation1_fmu,
                            distillation2_fmu,
                            distillation4_fmu,
                            furuta_modified,
                            furuta_dfo,
                            extfunctions,
                            extFunctions_arrays,
                            extFunctions_matrix,
                            if_example_1,
                            if_example_2,
                            mechanical_rotational_examples_coupled_clutches,
                            mechanical_rotational_examples_first,
                            planar_pendulum,
                            QR,
                            qt_par_est_dfo,
                            RLC,
                            robertson_fmu,
                            simulation_with_input,
                            simulation_with_input_function,
                            SolAng,
                            vdp_pp,
                            VDP_sim)


@testattr(stddist_base = True)
def test_fmi_bouncing_ball_raw():
    """ Test that the FMI bouncing ball example works """    
    fmi_bouncing_ball_native.run_demo(False)

@testattr(stddist_base = True)
def test_fmi20_bouncing_ball_raw():
    """ Test that the FMI bouncing ball example works """  
    fmi20_bouncing_ball_native.run_demo(False)
    
@testattr(stddist_base = True)
def test_bouncingball_cs_sim():
    """ Test the FMI Bouncing Ball CS example. """    
    fmi_bouncing_ball_cs.run_demo(False, version="1.0")
    fmi_bouncing_ball_cs.run_demo(False, version="2.0")
    
@testattr(stddist_base = True)
def test_crane():
    """ Run the PyMBS example """
    crane.run_demo(False)
    
@testattr(stddist_base = True)
def test_distillation_fmu():
    """ Test of simulation of the distillation column using the FMU export. """
    distillation_fmu.run_demo(False)
    
@testattr(stddist_base = True)
def test_distillation1_fmu():
    """ Test the distillation1_fmu example. """    
    distillation1_fmu.run_demo(False)
    
@testattr(stddist_base = True)
def test_distillation2_fmu():
    """ Test the distillation2_fmu example. """    
    distillation2_fmu.run_demo(False)
    
@testattr(stddist_base = True)
def test_distillation4_fmu():
    """ Test the distillation4_fmu example. """    
    distillation4_fmu.run_demo(False)
    
@testattr(stddist_base = True)
def test_fmi_bouncing_ball():
    """ Test that the FMI bouncing ball using the high-level simulate works. """
    fmi_bouncing_ball.run_demo(False, version="1.0") 
    fmi_bouncing_ball.run_demo(False, version="2.0")
    
@testattr(windows_base = True)
def test_fmu_with_input():
    """ Run FMU with input example. """
    fmu_with_input.run_demo(False)
    
@testattr(windows_base = True)
def test_furuta_modified():
    """ Test the furuta_modified example. """
    furuta_modified.run_demo(False)

@testattr(windows_base = True)
def test_furuta_dfo():
    """ Test the furuta_dfo example. """
    furuta_dfo.run_demo(False)
    
@testattr(stddist_base = True)
def test_extfunctions():
    """ Test of simulation with external functions. """
    extfunctions.run_demo(False)
    
@testattr(windows_base = True)
def test_extfunctions_arrays():
    """ Test of simulation with external functions using array input. """
    extFunctions_arrays.run_demo(False)
    
@testattr(windows_base = True)
def test_extfunctions_matrix():
    """ Test of simulation with external functions using matrix input and output. """
    extFunctions_matrix.run_demo(False)
    
@testattr(stddist_base = True)
def test_if_example_1():
    """ Test the if_example_1 example. """    
    if_example_1.run_demo(False)

@testattr(stddist_base = True)
def test_if_example_2():
    """ Test the if_example_2 example. """    
    if_example_2.run_demo(False)

@testattr(stddist_base = True)
def test_mechanics_rotational_examples_coupled_clutches():
    """ Run mechanics high index example from MSL """
    mechanical_rotational_examples_coupled_clutches.run_demo(False)

@testattr(stddist_base = True)
def test_mechanics_rotational_examples_first():
    """ Run mechanics high index example from MSL """
    mechanical_rotational_examples_first.run_demo(False)

@testattr(stddist_base = True)
def test_planar_pendulum():
    """ Run planar pendulum example """
    planar_pendulum.run_demo(False)
    
@testattr(stddist_base = True)
def test_QR():
    """ Test the QR example. """    
    QR.run_demo(False)

@testattr(stddist_base = True)
def test_qt_par_est_dfo():
    """ Test the qt_par_est_dfo example. """    
    qt_par_est_dfo.run_demo(False)

@testattr(stddist_base = True)
def test_RLC():
    """ Test the RLC example. """    
    RLC.run_demo(False)

@testattr(noncompliantfmi = True)
def test_robertson_sensitivity_fmu():
    """ Test the sensitivty example Robertson as an FMU. """
    robertson_fmu.run_demo(False)
    
@testattr(stddist_base = True)
def test_SEIRS():
    """ Test the sensitivity example by Niklas, SEIRS. """
    pass
    #Needs to be fixed!
    #SEIRS.run_demo(False)
    
@testattr(stddist_base = True)
def test_simulation_with_input():
    """ Test the simulation_with_input example. """    
    simulation_with_input.run_demo(False)

@testattr(stddist_base = True)
def test_simulation_with_input_function():
    """ Test the simulation_with_input_function example. """    
    simulation_with_input_function.run_demo(False)
    
@testattr(stddist_base = True)
def test_SolAng():
    """ Test the SolAng example """
    SolAng.run_demo(False)

@testattr(stddist_base = True)
def test_vdp_pp():
    """ Test the vdp_pp example. """    
    vdp_pp.run_demo(False)
    
@testattr(stddist_base = True)
def test_VDP_sim():
    """ Test the VDP_sim example. """    
    VDP_sim.run_demo(False)
