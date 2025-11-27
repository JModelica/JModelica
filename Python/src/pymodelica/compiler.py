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

# Try to import pyfmi (installed via conda)
try:
    from pyfmi import load_fmu as pyfmi_load_fmu
    PYFMI_AVAILABLE = True
except ImportError:
    PYFMI_AVAILABLE = False
    print("Warning: PyFMI not available. Install with: conda install -c conda-forge pyfmi")



def compile_fmu(class_name, file_names, target='me', compile_to='fmu', compiler_log_level='warning'):
    """
    Compile a Modelica model to FMU using JModelica Java compiler.
    
    Parameters:
    -----------
    class_name : str
        Name of the Modelica class to compile
    file_names : str or list
        Modelica file(s) containing the model
    target : str
        Target type ('me' for Model Exchange, 'cs' for Co-Simulation)
    compile_to : str
        Compilation target ('fmu')
    compiler_log_level : str
        Logging level
        
    Returns:
    --------
    str : Path to the generated FMU file
    """
    if not PYFMI_AVAILABLE:
        raise ImportError("PyFMI not available. Cannot compile FMU.")
    
    # Ensure file_names is a list
    if isinstance(file_names, str):
        file_names = [file_names]
    
    # For now, return a message that FMU compilation requires full JModelica compiler
    # In a complete implementation, this would call the Java compiler
    raise NotImplementedError(
        f"FMU compilation from Modelica not yet implemented in compatibility layer.\n"
        f"The Java compiler can parse Modelica but FMU generation requires additional integration.\n"
        f"To use this example:\n"
        f"1. Use OpenModelica to compile {file_names[0]} to FMU\n"
        f"2. Or wait for full JModelica C++ runtime build\n"
        f"3. Or modify example to use a pre-compiled FMU"
    )


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


# Module-level initialization
JMODELICA_HOME = os.environ.get('JMODELICA_HOME')
if not JMODELICA_HOME:
    # Try to set it automatically
    current_file = Path(__file__).resolve()
    jmodelica_root = current_file.parent.parent.parent
    if (jmodelica_root / 'Compiler').exists():
        JMODELICA_HOME = str(jmodelica_root)
        os.environ['JMODELICA_HOME'] = JMODELICA_HOME
        print(f"Auto-detected JMODELICA_HOME: {JMODELICA_HOME}")


__all__ = ['compile_fmu', 'load_fmu', 'JMODELICA_HOME']
