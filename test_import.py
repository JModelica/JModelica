
try:
    import pyfmi
    print("pyfmi imported successfully")
    from pyfmi.fmi import FMUModel
    print("pyfmi.fmi imported successfully")
    from pyfmi.master import Master
    print("pyfmi.master imported successfully")
except ImportError as e:
    print(f"ImportError: {e}")
except Exception as e:
    print(f"An error occurred: {e}")
