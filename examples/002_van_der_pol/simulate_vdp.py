"""
Van der Pol Oscillator Example

This example demonstrates:
- Limit cycle behavior
- Parameter sweeps
- Multiple simulations
"""

from pymodelica import compile_fmu
from pyjmi import load_fmu
import matplotlib.pyplot as plt
import numpy as np

# Compile the model
print("Compiling Van der Pol oscillator...")
fmu_path = compile_fmu("VanDerPolOscillator", "van_der_pol.mo")

# Parameter sweep
mu_values = [0.1, 0.5, 1.0, 2.0, 5.0]
colors = ['blue', 'green', 'orange', 'red', 'purple']

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

for mu, color in zip(mu_values, colors):
    print(f"Simulating with mu = {mu}...")
    
    # Load FMU
    model = load_fmu(fmu_path)
    model.set('mu', mu)
    
    # Simulate
    res = model.simulate(final_time=30.0)
    
    # Extract results
    time = res['time']
    x = res['x']
    y = res['y']
    
    # Plot time series
    ax1.plot(time, x, color=color, label=f'μ = {mu}', linewidth=1.5)
    
    # Plot phase portrait
    ax2.plot(x, y, color=color, label=f'μ = {mu}', linewidth=1.5)

# Configure time series plot
ax1.set_xlabel('Time (s)')
ax1.set_ylabel('Position x')
ax1.set_title('Van der Pol Oscillator - Time Series')
ax1.legend()
ax1.grid(True)

# Configure phase portrait
ax2.set_xlabel('Position x')
ax2.set_ylabel('Velocity y')
ax2.set_title('Van der Pol Oscillator - Phase Portrait')
ax2.legend()
ax2.grid(True)
ax2.axis('equal')

plt.tight_layout()
plt.savefig('van_der_pol_results.png')
print("Results saved to van_der_pol_results.png")
plt.show()
