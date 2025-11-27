import sys
import os

# Add source directories to path
sys.path.append(os.path.abspath("Python/src"))

print("Verifying Python 3 compatibility...")

try:
    import pymodelica
    import pymodelica.compiler
    import pymodelica.compiler_interface
    import pymodelica.compiler_logging
    print("pymodelica modules imported successfully.")
except ImportError as e:
    print(f"ImportError in pymodelica: {e}")
except SyntaxError as e:
    print(f"SyntaxError in pymodelica: {e}")
except Exception as e:
    print(f"Error in pymodelica: {e}")

try:
    import pyjmi
    import pyjmi.jmi_io
    # import pyjmi.examples.bounds_kinsol # This might fail due to missing FMUs/DLLs, but we check syntax
    print("pyjmi modules imported successfully.")
except ImportError as e:
    print(f"ImportError in pyjmi: {e}")
except SyntaxError as e:
    print(f"SyntaxError in pyjmi: {e}")
except Exception as e:
    print(f"Error in pyjmi: {e}")

print("Verification complete.")
