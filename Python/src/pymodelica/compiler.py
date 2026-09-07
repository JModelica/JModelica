"""
JModelica Python Compatibility Layer

This module provides a compatibility layer for JModelica examples using PyFMI backend.
Since the legacy C++ JModelica runtime requires extensive build system modernization,
this wrapper uses modern PyFMI to enable simulation of Modelica models.
"""

import os
import sys
import subprocess
import tempfile
import shutil
from pathlib import Path
import jpype
import jpype.imports
from jpype.types import *

# Try to import pyfmi (installed via conda)
try:
    from pyfmi import load_fmu as pyfmi_load_fmu
    PYFMI_AVAILABLE = True
except ImportError as e:
    PYFMI_AVAILABLE = False
    print(f"Warning: PyFMI not available. Error: {e}")

# Module-level initialization
JMODELICA_HOME = os.environ.get('JMODELICA_HOME')
if not JMODELICA_HOME:
    # Try to set it automatically
    current_file = Path(__file__).resolve()
    # Go up: pymodelica -> src -> Python -> Root
    jmodelica_root = current_file.parent.parent.parent.parent
    if (jmodelica_root / 'Compiler').exists():
        JMODELICA_HOME = str(jmodelica_root)
        os.environ['JMODELICA_HOME'] = JMODELICA_HOME
        print(f"Auto-detected JMODELICA_HOME: {repr(JMODELICA_HOME)}")
    else:
        # Fallback for when installed?
        pass

if JMODELICA_HOME is None:
    raise RuntimeError("JMODELICA_HOME environment variable not set and could not be auto-detected.")

COMPILER_JAR = os.path.join(JMODELICA_HOME, 'Compiler', 'build', 'libs', 'Compiler.jar')
BEAVER_JAR = os.path.join(JMODELICA_HOME, 'Compiler', 'ModelicaFrontEnd', 'ThirdParty', 'Beaver', 'lib', 'beaver-rt.jar')

print(f"JVM Classpath: {COMPILER_JAR}:{BEAVER_JAR}")

if not os.path.exists(COMPILER_JAR):
    print(f"Error: Compiler jar not found at {COMPILER_JAR}")

if not jpype.isJVMStarted():
    # Use convertStrings=True for convenience, though defaults in newer JPype might vary
    jpype.startJVM(classpath=[COMPILER_JAR, BEAVER_JAR], convertStrings=True)

import org.jmodelica.modelica.compiler.ModelicaCompiler as ModelicaCompiler
import org.jmodelica.modelica.compiler.generated.OptionRegistry as OptionRegistry
import java.io.File as File
import java.nio.file.Paths as Paths
import java.nio.file.Path as JPath

def compile_fmu(class_name, file_names, target='me', compile_to='fmu', compiler_log_level='warning', compiler_options=None):
    """
    Compile a Modelica model to FMU using JModelica Java compiler.
    """
    if isinstance(file_names, str):
        file_names = [file_names]

    file_paths = [File(f) for f in file_names]

    # Initialize OptionRegistry
    options = OptionRegistry.buildOptions()
    # TODO: Populate options if compiler_options is provided

    compiler = ModelicaCompiler(options)

    print(f"Compiling {class_name} to FMU...")
    try:
        j_paths = jpype.JArray(JPath)([Paths.get(f) for f in file_names])
        j_output = Paths.get(f"{class_name}.fmu")

        # Call:
        # public CompiledUnit compileFMU(String className, Path[] paths, String target, Path compileTo)
        compiled_unit = compiler.compileFMU(class_name, j_paths, target, j_output)

        if compiled_unit is None:
             raise Exception("Compilation failed (returned null).")

        # If CompiledUnit has a method to get the file, use it.
        # Otherwise, assume it wrote to j_output

        # Let's return the path to the FMU
        return str(j_output.toAbsolutePath())

    except Exception as e:
        print(f"Java Compilation Error: {e}")
        # Print stack trace if possible
        if hasattr(e, 'stacktrace'):
             print(e.stacktrace())
        raise

def compile_fmux(class_name, file_names, target='me', compile_to='fmu', compiler_log_level='warning'):
    """
    Compile a Modelica model to FMU using JModelica Java compiler (extended version).
    """
    return compile_fmu(class_name, file_names, target, compile_to, compiler_log_level)


def load_fmu(fmu_name, kind='auto', log_level=7):
    """
    Load an FMU for simulation using PyFMI.

    Parameters:
    -----------
    fmu_name : str
        Path to the FMU file
    kind : str
        FMU kind ('me', 'cs', or 'auto')
    log_level : int
        Logging level

    Returns:
    --------
    FMUModel : Loaded FMU model
    """
    if not PYFMI_AVAILABLE:
        raise ImportError("PyFMI not available. Install with: conda install -c conda-forge pyfmi")

    # Use PyFMI to load the FMU
    return pyfmi_load_fmu(fmu_name, kind=kind, log_level=log_level)


__all__ = ['compile_fmu', 'compile_fmux', 'load_fmu', 'JMODELICA_HOME']
