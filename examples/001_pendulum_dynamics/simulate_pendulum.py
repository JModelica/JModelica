"""
Pendulum Dynamics Example

This example demonstrates:
- Nonlinear system simulation
- Energy analysis
- Phase portrait plotting
"""

from pymodelica import compile_fmu
from pyjmi import load_fmu
import matplotlib.pyplot as plt
import numpy as np

# Compile the Modelica model
print("Compiling pendulum model...")
fmu_path = compile_fmu("PendulumModel", "pendulum.mo")

# Load the FMU
print("Loading FMU...")
model = load_fmu(fmu_path)

# Set parameters
model.set('L', 1.0)   # Length in meters
model.set('m', 1.0)   # Mass in kg
model.set('g', 9.81)  # Gravity
model.set('b', 0.1)   # Friction coefficient

# Simulate
print("Running simulation...")
res = model.simulate(final_time=20.0)

# Extract results
time = res['time']
theta = res['theta']
omega = res['omega']
energy = res['E']

# Create plots
fig = plt.figure(figsize=(12, 10))

# Time series
ax1 = plt.subplot(3, 1, 1)
ax1.plot(time, np.degrees(theta))
ax1.set_xlabel('Time (s)')
ax1.set_ylabel('Angle (degrees)')
ax1.set_title('Pendulum Angle vs Time')
ax1.grid(True)

# Energy dissipation
ax2 = plt.subplot(3, 1, 2)
ax2.plot(time, energy)
ax2.set_xlabel('Time (s)')
ax2.set_ylabel('Energy (J)')
ax2.set_title('Total Energy vs Time')
ax2.grid(True)

# Phase portrait
ax3 = plt.subplot(3, 1, 3)
ax3.plot(np.degrees(theta), omega)
ax3.set_xlabel('Angle (degrees)')
ax3.set_ylabel('Angular Velocity (rad/s)')
ax3.set_title('Phase Portrait')
ax3.grid(True)

plt.tight_layout()
plt.savefig('pendulum_results.png')
print("Results saved to pendulum_results.png")
plt.show()
