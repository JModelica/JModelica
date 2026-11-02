# Simple RC Circuit Example

This example demonstrates basic JModelica usage with a simple RC circuit.

## Files
- `rc_circuit.mo` - Modelica model of an RC circuit
- `simulate_rc.py` - Python script to compile, simulate, and plot results

## Model Description
The RC circuit consists of:
- Voltage source (V_source = 5V)
- Resistor (R = 100Ω)
- Capacitor (C = 1μF)

The model demonstrates first-order system dynamics with exponential charging behavior.

## Running the Example

**Prerequisites**: C++ extensions must be built (requires Ipopt and Sundials)

```bash
# Install dependencies first (if not done)
vcpkg install ipopt sundials

# Run the example
cd examples/000_simple_rc_circuit
python simulate_rc.py
```

## Expected Results
- Capacitor voltage rises exponentially to 5V
- Current decreases exponentially to 0A
- Time constant τ = R×C = 100μs
- Results saved to `rc_circuit_results.png`

## Learning Objectives
1. Basic Modelica model structure
2. Compiling Modelica to FMU
3. Loading and simulating FMUs from Python
4. Extracting and plotting simulation results
