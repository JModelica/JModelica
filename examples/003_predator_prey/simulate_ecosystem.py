"""
Predator-Prey Dynamics Example

This example demonstrates:
- Ecological modeling
- Cyclic population dynamics
- Sensitivity analysis
"""

from pymodelica import compile_fmu
from pyjmi import load_fmu
import matplotlib.pyplot as plt
import numpy as np

# Compile the model
print("Compiling Lotka-Volterra model...")
fmu_path = compile_fmu("LotkaVolterra", "lotka_volterra.mo")

# Load and simulate
print("Loading FMU...")
model = load_fmu(fmu_path)

# Set parameters (classic Lotka-Volterra values)
model.set('alpha', 1.5)  # Prey growth
model.set('beta', 1.0)   # Predation rate
model.set('gamma', 3.0)  # Predator death
model.set('delta', 1.0)  # Predator growth from predation

# Simulate
print("Running simulation...")
res = model.simulate(final_time=20.0)

# Extract results
time = res['time']
prey = res['prey']
predator = res['predator']

# Create plots
fig = plt.figure(figsize=(12, 10))

# Population vs time
ax1 = plt.subplot(2, 2, 1)
ax1.plot(time, prey, 'b-', label='Prey', linewidth=2)
ax1.plot(time, predator, 'r-', label='Predator', linewidth=2)
ax1.set_xlabel('Time')
ax1.set_ylabel('Population')
ax1.set_title('Population Dynamics')
ax1.legend()
ax1.grid(True)

# Phase portrait
ax2 = plt.subplot(2, 2, 2)
ax2.plot(prey, predator, 'g-', linewidth=2)
ax2.set_xlabel('Prey Population')
ax2.set_ylabel('Predator Population')
ax2.set_title('Phase Portrait')
ax2.grid(True)

# Prey population detail
ax3 = plt.subplot(2, 2, 3)
ax3.plot(time, prey, 'b-', linewidth=2)
ax3.set_xlabel('Time')
ax3.set_ylabel('Prey Population')
ax3.set_title('Prey Dynamics')
ax3.grid(True)

# Predator population detail
ax4 = plt.subplot(2, 2, 4)
ax4.plot(time, predator, 'r-', linewidth=2)
ax4.set_xlabel('Time')
ax4.set_ylabel('Predator Population')
ax4.set_title('Predator Dynamics')
ax4.grid(True)

plt.tight_layout()
plt.savefig('predator_prey_results.png')
print("Results saved to predator_prey_results.png")
plt.show()

# Print statistics
print(f"\nSimulation Statistics:")
print(f"Prey - Min: {np.min(prey):.2f}, Max: {np.max(prey):.2f}, Mean: {np.mean(prey):.2f}")
print(f"Predator - Min: {np.min(predator):.2f}, Max: {np.max(predator):.2f}, Mean: {np.mean(predator):.2f}")
