#!/usr/bin/env python 
# -*- coding: utf-8 -*-

# Copyright (C) 2010 Modelon AB
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

""" Test module for testing the compiler module.
 
"""

import os, os.path
import sys
import shutil
import zipfile

import nose
import nose.tools

from tests_jmodelica import testattr, get_files_path
from pymodelica.compiler_wrappers import ModelicaCompiler
from pymodelica.compiler_wrappers import OptimicaCompiler
from pymodelica import compile_fmu
import pymodelica as pym
from pyfmi import load_fmu


class Test_Compiler:
    """ This class tests the compiler class. """
    
    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        cls.mc = ModelicaCompiler()
        cls.oc = OptimicaCompiler()
        cls.jm_home = pym.environ['JMODELICA_HOME']        
        cls.fpath_mc = os.path.join(get_files_path(), 'Modelica', 
            'Pendulum_pack_no_opt.mo')
        cls.cpath_mc = "Pendulum_pack.Pendulum"
        cls.fpath_oc = os.path.join(get_files_path(), 'Modelica', 
            'Pendulum_pack.mop')
        cls.cpath_oc = "Pendulum_pack.Pendulum_Opt"
    
    @testattr(stddist_base = True)
    def test_compile_FMUME10(self):
        """
        Test that it is possible to compile an FMU ME version 1.0 from a .mo 
        file with ModelicaCompiler.
        """ 
        Test_Compiler.mc.compile_Unit(Test_Compiler.cpath_mc, [Test_Compiler.fpath_mc], 'me', '1.0', '.')
        fname = Test_Compiler.cpath_mc.replace('.','_',1)
        assert os.access(fname+'.fmu',os.F_OK) == True, \
               fname+'.fmu'+" was not created."
        os.remove(fname+'.fmu')

    @testattr(stddist_base = True)
    def test_compile_FMUCS10(self):
        """
        Test that it is possible to compile an FMU CS version 1.0 from a .mo 
        file with ModelicaCompiler.
        """ 
        Test_Compiler.mc.compile_Unit(Test_Compiler.cpath_mc, [Test_Compiler.fpath_mc], 'cs', '1.0', '.')
        fname = Test_Compiler.cpath_mc.replace('.','_',1)
        assert os.access(fname+'.fmu',os.F_OK) == True, \
               fname+'.fmu'+" was not created."
        os.remove(fname+'.fmu')
        
    @testattr(stddist_base = True)
    def test_compile_FMUME20(self):
        """
        Test that it is possible to compile an FMU ME version 2.0 from a .mo 
        file with ModelicaCompiler.
        """ 
        Test_Compiler.mc.compile_Unit(Test_Compiler.cpath_mc, [Test_Compiler.fpath_mc], 'me', '2.0', '.')
        fname = Test_Compiler.cpath_mc.replace('.','_',1)
        assert os.access(fname+'.fmu',os.F_OK) == True, \
               fname+'.fmu'+" was not created."
        os.remove(fname+'.fmu')
        
    @testattr(stddist_base = True)
    def test_compile_FMUCS20(self):
        """
        Test that it is possible to compile an FMU CS version 2.0 from a .mo 
        file with ModelicaCompiler.
        """ 
        Test_Compiler.mc.compile_Unit(Test_Compiler.cpath_mc, [Test_Compiler.fpath_mc], 'cs', '2.0', '.')
        fname = Test_Compiler.cpath_mc.replace('.','_',1)
        assert os.access(fname+'.fmu',os.F_OK) == True, \
               fname+'.fmu'+" was not created."
        os.remove(fname+'.fmu')
        
    @testattr(stddist_base = True)
    def test_compile_FMUMECS20(self):
        """
        Test that it is possible to compile an FMU MECS version 2.0 from a .mo 
        file with ModelicaCompiler.
        """ 
        Test_Compiler.mc.compile_Unit(Test_Compiler.cpath_mc, [Test_Compiler.fpath_mc], 'me+cs', '2.0', '.')
        fname = Test_Compiler.cpath_mc.replace('.','_',1)
        assert os.access(fname+'.fmu',os.F_OK) == True, \
               fname+'.fmu'+" was not created."
        os.remove(fname+'.fmu')

    @testattr(stddist_full = True)
    def test_stepbystep(self):
        """ Test that it is possible to compile step-by-step with ModelicaCompiler. """
        target = Test_Compiler.mc.create_target_object("me", "1.0")
        sourceroot = Test_Compiler.mc.parse_model(Test_Compiler.fpath_mc)
        icd = Test_Compiler.mc.instantiate_model(sourceroot, Test_Compiler.cpath_mc, target)
        fclass = Test_Compiler.mc.flatten_model(icd, target)
        Test_Compiler.mc.generate_code(fclass, target)

    @testattr(stddist_full = True)
    def test_optimica_stepbystep(self):
        """ Test that it is possible to compile step-by-step with OptimicaCompiler. """
        target = Test_Compiler.oc.create_target_object("me", "1.0")
        sourceroot = Test_Compiler.oc.parse_model(Test_Compiler.fpath_oc)
        icd = Test_Compiler.oc.instantiate_model(sourceroot, Test_Compiler.cpath_oc, target)
        fclass = Test_Compiler.oc.flatten_model(icd, target)
        Test_Compiler.oc.generate_code(fclass, target)

    '''
    @testattr(stddist_base = True)
    def test_class_not_found_error(self):
        """ Test that a ModelicaClassNotFoundError is raised if model class is not found. """
        errorcl = 'NonExisting.Class'
        nose.tools.assert_raises(pym.compiler_exceptions.ModelicaClassNotFoundError, pym.compile_fmu, errorcl, self.fpath_mc, separate_process=True)

    @testattr(stddist_base = True)
    def test_IO_error(self):
        """ Test that an IOError is raised if the model file is not found. """
        errorpath = os.path.join(get_files_path(), 'Modelica','NonExistingModel.mo')
        nose.tools.assert_raises(IOError, pym.compile_fmu, Test_Compiler.cpath_mc, errorpath, separate_process=True)
    '''
    @testattr(stddist_full = True)
    def test_setget_modelicapath(self):
        """ Test modelicapath setter and getter. """
        newpath = os.path.join(Test_Compiler.jm_home,'ThirdParty','MSL')
        Test_Compiler.mc.set_modelicapath(newpath)
        nose.tools.assert_equal(Test_Compiler.mc.get_modelicapath(),newpath)
        nose.tools.assert_equal(Test_Compiler.oc.get_modelicapath(),newpath)
    
    @testattr(stddist_full = True)
    def test_parse_multiple(self):
        """ Test that it is possible to parse two model files. """
        lib = os.path.join(get_files_path(), 'Modelica','CSTRLib.mo')
        opt = os.path.join(get_files_path(), 'Modelica','CSTR2_Opt.mo')
        Test_Compiler.oc.parse_model([lib, opt])

    @testattr(stddist_full = True)
    def test_setget_boolean_option(self):
        """ Test boolean option setter and getter. """
        option = 'halt_on_warning'
        value = Test_Compiler.mc.get_boolean_option(option)
        # change value of option
        Test_Compiler.mc.set_boolean_option(option, not value)
        nose.tools.assert_equal(Test_Compiler.mc.get_boolean_option(option), not value)
        # option should be of type bool
        assert isinstance(Test_Compiler.mc.get_boolean_option(option), bool)
        # reset to original value
        Test_Compiler.mc.set_boolean_option(option, value)
    
    @testattr(stddist_full = True)
    def test_setget_boolean_option_error(self):
        """ Test that boolean option getter raises the proper error. """
        option = 'nonexist_boolean'
        #try to get an unknown option
        nose.tools.assert_raises(pym.compiler_exceptions.UnknownOptionError, Test_Compiler.mc.get_boolean_option, option)

    @testattr(stddist_full = True)
    def test_setget_integer_option(self):
        """ Test integer option setter and getter. """
        option = 'log_level'
        default_value = Test_Compiler.mc.get_integer_option(option)
        new_value = 1
        # change value of option
        Test_Compiler.mc.set_integer_option(option, new_value)
        nose.tools.assert_equal(Test_Compiler.mc.get_integer_option(option), new_value)
        # option should be of type int
        assert isinstance(Test_Compiler.mc.get_integer_option(option),int)
        # reset to original value
        Test_Compiler.mc.set_integer_option(option, default_value)
    
    @testattr(stddist_full = True)
    def test_setget_integer_option_error(self):
        """ Test that integer option getter raises the proper error. """
        option = 'nonexist_integer'
        #try to get an unknown option
        nose.tools.assert_raises(pym.compiler_exceptions.UnknownOptionError, Test_Compiler.mc.get_integer_option, option) 

    @testattr(stddist_full = True)
    def test_setget_integer_option_value_error(self):
        """ Test that integer option setter raises the proper error. """
        #try to set to an invalid value
        option = 'log_level'
        invalid_value = 30
        nose.tools.assert_raises(pym.compiler_exceptions.InvalidOptionValueError, Test_Compiler.mc.set_integer_option, option, invalid_value)


    @testattr(stddist_full = True)
    def test_setget_real_option(self):
        """ Test real option setter and getter. """
        option = 'events_tol_factor'
        default_value = Test_Compiler.mc.get_real_option(option)
        new_value = 1.0e-5
        # change value of option
        Test_Compiler.mc.set_real_option(option, new_value)
        nose.tools.assert_equal(Test_Compiler.mc.get_real_option(option), new_value)
        # option should be of type int
        assert isinstance(Test_Compiler.mc.get_real_option(option),float)
        # reset to original value
        Test_Compiler.mc.set_real_option(option, default_value)
    
    @testattr(stddist_full = True)
    def test_setget_real_option_error(self):
        """ Test that real option getter raises the proper error. """
        option = 'nonexist_real'
        #try to get an unknown option
        nose.tools.assert_raises(pym.compiler_exceptions.UnknownOptionError, Test_Compiler.mc.get_real_option, option)

    @testattr(stddist_full = True)
    def test_setget_string_option(self):
        """ Test string option setter and getter. """
        option = 'inline_functions'
        default_value = Test_Compiler.mc.get_string_option(option)
        setvalue = 'none'
        # change value of option
        Test_Compiler.mc.set_string_option(option, setvalue)
        nose.tools.assert_equal(Test_Compiler.mc.get_string_option(option), setvalue)
        # option should be of type str
        assert isinstance(Test_Compiler.mc.get_string_option(option),basestring)
        # reset to original value
        Test_Compiler.mc.set_string_option(option, default_value)
    
    @testattr(stddist_full = True)
    def test_setget_string_option_error(self):
        """ Test that string option getter raises the proper error. """
        option = 'nonexist_real'
        #try to get an unknown option
        nose.tools.assert_raises(pym.compiler_exceptions.UnknownOptionError, Test_Compiler.mc.get_string_option, option)

    @testattr(stddist_base = True)
    def TO_ADDtest_MODELICAPATH(self):
        """ Test that the MODELICAPATH is loaded correctly.
    
        This test does currently not pass since changes of global
        environment variable MODELICAPATH does not take effect
        after OptimicaCompiler has been used a first time."""
    
        curr_dir = os.path.dirname(os.path.abspath(__file__));
        self.jm_home = os.environ['JMODELICA_HOME']
        model = os.path.join('files','Test_MODELICAPATH.mo')
        fpath = os.path.join(curr_dir,model)
        cpath = "Test_MODELICAPATH"
        fname = cpath.replace('.','_',1)
            
        pathElSep = ''
        if sys.platform == 'win32':
            pathElSep = ';'
        else:
            pathElSep = ':'
    
        modelica_path = os.environ['MODELICAPATH']
        os.environ['MODELICAPATH'] = os.environ['MODELICAPATH'] + pathElSep + \
                                     os.path.join(curr_dir,'files','MODELICAPATH_test','LibLoc1') + pathElSep + \
                                     os.path.join(curr_dir,'files','MODELICAPATH_test','LibLoc2')
    
        comp_res = 1
        try:
            oc.compile_model(cpath, fpath)
        except:
            comp_res = 0
    
        assert comp_res==1, "Compilation failed in test_MODELICAPATH"

class Test_Compile_Load:
    
    @testattr(windows_base = True)
    def test_load_FMU_VS2017(self):
        """
        Test that a gcc compiled FMU can be loaded into a VS2017 compiled program.
        """
        cwd = os.getcwd()
        try:
            import subprocess
            os.chdir(os.path.join(get_files_path(), "Programs", "Load_and_initialize"))
            name = compile_fmu("Modelica.Mechanics.Rotational.Examples.CoupledClutches", compile_to="CC.fmu", compiler_options={"c_compiler":"gcc"}, platform="win64")
            
            #Basically just verify that the process terminates
            return_code = subprocess.call("LoadAndInitialize.exe CC.fmu .", shell=True)
            assert return_code == 0
        except pym.compiler_exceptions.CcodeCompilationError:
            pass #64bit not supported
        os.chdir(cwd)

class Test_Compiler_functions:
    """ This class tests the compiler functions. """

    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        cls.fpath_mc = os.path.join(get_files_path(), 'Modelica', 
            'Pendulum_pack_no_opt.mo')
        cls.cpath_mc = "Pendulum_pack.Pendulum"
        cls.fpath_oc = os.path.join(get_files_path(), 'Modelica', 
            'Pendulum_pack.mop')
        cls.cpath_oc = "Pendulum_pack.Pendulum_Opt"
    
    @testattr(stddist_full = True)
    def test_compile_to_argument(self):
        
        name = pym.compile_fmu("Modelica.Mechanics.Rotational.Examples.CoupledClutches", compile_to="Coupled.fmu")
        
        assert name.endswith("Coupled.fmu")
        
        model = load_fmu(name)
        
        assert model.get_name() == "Coupled"
        assert model.get_identifier() == "Coupled"
   
    @testattr(stddist_full = True)
    def test_compile_fmu_illegal_target_error(self):
        """Test that an exception is raised when an incorrect target is given to compile_fmu"""
        cl = Test_Compiler_functions.cpath_mc 
        path = Test_Compiler_functions.fpath_mc
        #Incorrect target.
        nose.tools.assert_raises(pym.compiler_exceptions.IllegalCompilerArgumentError, pym.compile_fmu, cl, path, target="notValidTarget")
        #Incorrect target that contains the valid target 'me'.
        nose.tools.assert_raises(pym.compiler_exceptions.IllegalCompilerArgumentError, pym.compile_fmu, cl, path, target="men") 
        #Incorrect version, correct target 'me'.
        nose.tools.assert_raises(pym.compiler_exceptions.IllegalCompilerArgumentError, pym.compile_fmu, cl, path, target="me", version="notValidVersion") 
               
    @testattr(stddist_base = True)
    def test_compile_fmu_mop(self):
        """
        Test that it is possible to compile an FMU from a .mop file with 
        pymodelica.compile_fmu.
        """
        fmuname = compile_fmu(Test_Compiler_functions.cpath_mc, Test_Compiler_functions.fpath_oc, 
            separate_process=False)

        assert os.access(fmuname, os.F_OK) == True, \
               fmuname+" was not created."
        os.remove(fmuname)

    @testattr(stddist_base = True)
    def test_compile_fmu_mop_separate_process(self):
        """
        Test that it is possible to compile an FMU from a .mop file with 
        pymodelica.compile_fmu using separate process.
        """
        fmuname = compile_fmu(Test_Compiler_functions.cpath_mc, Test_Compiler_functions.fpath_oc)

        assert os.access(fmuname, os.F_OK) == True, \
               fmuname+" was not created."
        os.remove(fmuname)

    @testattr(stddist_full = True)
    def test_compiler_error(self):
        """ Test that a CompilerError is raised if compilation errors are found in the model."""
        path = os.path.join(get_files_path(), 'Modelica','CorruptCodeGenTests.mo')
        cl = 'CorruptCodeGenTests.CorruptTest1'
        nose.tools.assert_raises(pym.compiler_exceptions.CompilerError, pym.compile_fmu, cl, path)
    
    @testattr(stddist_full = True)
    def test_compiler_modification_error(self):
        """ Test that a CompilerError is raised if compilation errors are found in the modification on the classname."""
        path = os.path.join(get_files_path(), 'Modelica','Diode.mo')
        err = pym.compiler_exceptions.CompilerError
        nose.tools.assert_raises(err, pym.compile_fmu, 'Diode(wrong_name=2)', path)
        nose.tools.assert_raises(err, pym.compile_fmu, 'Diode(===)', path)

    @testattr(stddist_base = True)
    def test_compile_fmu_separate_process_options(self):
        """
        Test that it is possible to call separate process compilation with compiler options
        """
        fmuname = compile_fmu(Test_Compiler_functions.cpath_mc, Test_Compiler_functions.fpath_mc, compiler_options={'generate_html_diagnostics':True})
        (diag_name, _) = os.path.splitext(fmuname)
        diag_name += '_html_diagnostics'

        assert os.access(fmuname, os.F_OK) == True, \
               fmuname+" was not created."
        assert os.access(diag_name, os.F_OK) == True, \
               diag_name+" was not created."
        os.remove(fmuname)
        shutil.rmtree(diag_name)
    

    @testattr(stddist_base = True)
    def test_compile_fmu_separate_process_jvm_args(self):
        """
        Test that it is possible to call separate process compilation with multiple jvm args
        """
        fmuname = compile_fmu(Test_Compiler_functions.cpath_mc, Test_Compiler_functions.fpath_mc, jvm_args='-Xmx100m -Xss2m')

        assert os.access(fmuname, os.F_OK) == True, \
               fmuname+" was not created."
        os.remove(fmuname)

    @testattr(stddist_base = True)
    def test_separate_process_control_characters(self):
        """
        Test that the separate process pipe can handle control characters
        """
        fmuname = compile_fmu("ExtFunctionTests.PrintsControlCharacters", [os.path.join(get_files_path(), 'Modelica', 'ExtFunctionTests.mo')])

        assert os.access(fmuname, os.F_OK) == True, \
               fmuname+" was not created."
        os.remove(fmuname)

    @testattr(stddist_full = True)
    def test_no_source_files_in_fmu(self):
        """
        Test that no c source files are added to the fmu when copy_source_files_to_fmu is false.
        """

        try :
            fmuname = compile_fmu("BouncingBall", [os.path.join(get_files_path(), 'Modelica', 'BouncingBall.mo')], \
                    compiler_options={'copy_source_files_to_fmu':False})

        except pym.compiler_exceptions.UnknownOptionError as e :
            self.assert_compiler_option_missing("copy_source_files_to_fmu", e)
            return

        zf = zipfile.ZipFile(fmuname, 'r')
        includedFiles = zf.namelist()
        for f in includedFiles:
            assert f != 'sources/', 'Source files should not be present when copy_source_files_to_fmu is set to false'
            assert '.c' not in f, f + ' should not be present when copy_source_files_to_fmu is set to false'
            
    @testattr(stddist_full = True)
    def test_source_files_in_fmu(self):
        """
        Test that c source files are added to the fmu when copy_source_files_to_fmu is true
        """

        try :
            fmuname = compile_fmu("BouncingBall", [os.path.join(get_files_path(), 'Modelica', 'BouncingBall.mo')], \
                    compiler_options={'copy_source_files_to_fmu':True})

        except pym.compiler_exceptions.UnknownOptionError as e :
            self.assert_compiler_option_missing("copy_source_files_to_fmu", e)
            return

        zf = zipfile.ZipFile(fmuname, 'r')
        includedFiles = zf.namelist()
        assert 'sources/' in includedFiles, 'Source files should be present when copy_source_files_to_fmu is set to true'
        assert 'sources/BouncingBall.c' in includedFiles, 'Source files should be present when copy_source_files_to_fmu is set to true'

    def assert_compiler_option_missing(self, option_name, exception) :
        """
            Tests that an option is missing, deducing it from an exception message.

            @param option_name  the name of the option asserted to be missing.
            @param exception    the exception that was raised trying to use a compiler option.
        """

        assert str(exception).startswith("Unknown option \"%s\"" % option_name), "Option %s was expected to be " \
                "missing, but was not." % option_name

# 64-bit FMUs no longer supported by SDK
#    @testattr(windows_base = True)
#    def test_compile_fmu_me_1_64bit(self):
#        """Test that it is possible to compile an FMU-ME 1.0 64bit FMU on Windows"""
#        cl = Test_Compiler_functions.cpath_mc 
#        path = Test_Compiler_functions.fpath_mc
#        pym.compile_fmu(cl, path, platform='win64')
#
#    @testattr(windows_base = True)
#    def test_compile_fmu_me_2_64bit(self):
#        """Test that it is possible to compile an FMU-ME 2.0 64bit FMU on Windows"""
#        cl = Test_Compiler_functions.cpath_mc 
#        path = Test_Compiler_functions.fpath_mc
#        pym.compile_fmu(cl, path, version='2.0', platform='win64')
#
#    @testattr(windows_base = True)
#    def test_compile_fmu_cs_1_64bit(self):
#        """Test that it is possible to compile an FMU-CS 1.0 64bit FMU on Windows"""
#        cl = Test_Compiler_functions.cpath_mc 
#        path = Test_Compiler_functions.fpath_mc
#        pym.compile_fmu(cl, path, target='cs', platform='win64')
#
#    @testattr(windows_base = True)
#    def test_compile_fmu_cs_2_64bit(self):
#        """Test that it is possible to compile an FMU-CS 2.0 64bit FMU on Windows"""
#        cl = Test_Compiler_functions.cpath_mc 
#        path = Test_Compiler_functions.fpath_mc
#        pym.compile_fmu(cl, path, target='cs', version='2.0', platform='win64')

