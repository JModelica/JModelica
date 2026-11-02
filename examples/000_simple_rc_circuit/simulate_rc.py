"""
Simple RC Circuit Example

This example demonstrates:
- Basic Modelica model compilation
- Parameter modification
- Simulation
- Result plotting
"""

import sys
import os

# Hack to fix pyfmi import issue where it expects 'fmi' module but it is 'pyfmi.fmi'
try:
    import pyfmi.fmi
    sys.modules['fmi'] = pyfmi.fmi
except ImportError:
    pass

from pymodelica import compile_fmu
from pyjmi import load_fmu
import matplotlib.pyplot as plt
import numpy as np

# Resolve path to rc_circuit.mo
current_dir = os.path.dirname(os.path.abspath(__file__))
mo_file = os.path.join(current_dir, "rc_circuit.mo")

# Compile the Modelica model to FMU
print("Compiling RC circuit model...")
fmu_path = compile_fmu("RCCircuit", mo_file)

# Load the compiled FMU
print("Loading FMU...")
model = load_fmu(fmu_path)

# Set parameters
model.set('R', 100.0)  # Resistance in Ohms
model.set('C', 1e-6)   # Capacitance in Farads

# Simulate
print("Running simulation...")
res = model.simulate(final_time=0.001)

# Extract results
time = res['time']
voltage = res['v']
current = res['i']

# Plot results
fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 8))

ax1.plot(time * 1000, voltage)
ax1.set_xlabel('Time (ms)')
ax1.set_ylabel('Voltage (V)')
ax1.set_title('RC Circuit - Capacitor Voltage')
ax1.grid(True)

ax2.plot(time * 1000, current * 1000)
ax2.set_xlabel('Time (ms)')
ax2.set_ylabel('Current (mA)')
ax2.set_title('RC Circuit - Current')
ax2.grid(True)

output_file = os.path.join(current_dir, 'rc_circuit_results.png')
plt.tight_layout()
plt.savefig(output_file)
print(f"Results saved to {output_file}")
# plt.show() # Disable show for headless environment
