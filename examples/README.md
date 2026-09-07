# JModelica Examples

This directory contains example projects demonstrating JModelica capabilities with Modelica models and Python simulation scripts.

## 📁 Example Structure

Each example is in a numbered folder (`000_name`, `001_name`, etc.) and contains:
- **`.mo` files** - Modelica models (separate from Python code)
- **`.py` files** - Python simulation scripts
- **`README.md`** - Example-specific documentation

## 📚 Available Examples

### 000_simple_rc_circuit
**Difficulty**: Beginner  
**Topics**: Basic electrical circuit, first-order dynamics

Simple RC circuit demonstrating:
- Modelica model compilation to FMU
- Parameter modification from Python
- Result extraction and plotting
- Exponential charging behavior

### 001_pendulum_dynamics
**Difficulty**: Intermediate  
**Topics**: Nonlinear dynamics, energy analysis

Pendulum with friction demonstrating:
- Nonlinear differential equations
- Energy dissipation
- Phase portrait analysis
- Oscillatory behavior

### 002_van_der_pol
**Difficulty**: Intermediate  
**Topics**: Limit cycles, parameter sweeps

Van der Pol oscillator demonstrating:
- Self-sustained oscillations
- Nonlinear damping
- Parameter sensitivity
- Multiple simulations

### 003_predator_prey
**Difficulty**: Intermediate  
**Topics**: Ecological modeling, population dynamics

Lotka-Volterra model demonstrating:
- Coupled differential equations
- Cyclic population dynamics
- Ecological interactions
- Statistical analysis

## ⚠️ Important: C++ Dependencies Required

**These examples require C++ runtime extensions to be built.**

### Current Status
- ✅ **Java Compiler**: Fully functional
- ✅ **Python Code**: Migrated to Python 3
- ✅ **Modelica Models**: Ready to use
- ❌ **C++ Extensions**: Not yet built

### Why Examples Won't Run Yet

The Python scripts use `pymodelica` and `pyjmi` modules which depend on C++ extensions that require:
1. **Ipopt** - Interior Point Optimizer
2. **Sundials** - ODE/DAE solvers

Without these, you'll see:
```
ImportError: No module named 'jmi'
```

### How to Enable Examples

#### Step 1: Install C++ Dependencies

Using vcpkg (recommended):
```bash
# Set VCPKG_ROOT if not already set
set VCPKG_ROOT=C:\vcpkg

# Install dependencies
vcpkg install ipopt:x64-windows sundials:x64-windows
```

#### Step 2: Build C++ Extensions

```bash
# Configure with vcpkg
cmake -B build -S . -DCMAKE_TOOLCHAIN_FILE=%VCPKG_ROOT%/scripts/buildsystems/vcpkg.cmake

# Build C++ extensions
cmake --build build
```

#### Step 3: Set Environment Variable

```bash
set JMODELICA_HOME=C:\dev\JModelica\20251120\JModelica
```

#### Step 4: Run Examples

```bash
cd examples/000_simple_rc_circuit
python simulate_rc.py
```

## 🎓 Learning Path

**Recommended order for beginners**:
1. `000_simple_rc_circuit` - Learn basics
2. `001_pendulum_dynamics` - Understand nonlinear systems
3. `002_van_der_pol` - Explore parameter effects
4. `003_predator_prey` - Apply to real-world problems

## 📖 Example Code Structure

### Typical Modelica Model (`.mo`)
```modelica
model ExampleModel
  "Model description"
  
  // Parameters
  parameter Real param1 = 1.0 "Description";
  
  // Variables
  Real var1(start=0) "Description";
  
equation
  der(var1) = -param1 * var1;
  
end ExampleModel;
```

### Typical Python Script (`.py`)
```python
from pymodelica import compile_fmu
from pyjmi import load_fmu
import matplotlib.pyplot as plt

# Compile Modelica to FMU
fmu = compile_fmu("ExampleModel", "model.mo")

# Load and configure
model = load_fmu(fmu)
model.set('param1', 2.0)

# Simulate
res = model.simulate(final_time=10.0)

# Plot results
plt.plot(res['time'], res['var1'])
plt.show()
```

## 🔧 Troubleshooting

### "No module named 'pymodelica'"
**Cause**: C++ extensions not built  
**Solution**: Follow installation steps above

### "No module named 'jmi'"
**Cause**: C++ extensions not built  
**Solution**: Install Ipopt and Sundials, then build extensions

### "JMODELICA_HOME not set"
**Cause**: Environment variable missing  
**Solution**: `set JMODELICA_HOME=C:\path\to\JModelica`

### "FMU compilation failed"
**Cause**: Java compiler not in PATH  
**Solution**: Ensure Java 17 is installed and in PATH

## 📝 Creating Your Own Examples

1. Create a new numbered folder: `004_your_example`
2. Write Modelica model: `your_model.mo`
3. Write Python script: `simulate_model.py`
4. Add README.md with description
5. Test after C++ extensions are built

## 🔗 Additional Resources

- [Modelica Language Specification](https://modelica.org/documents/ModelicaSpec34.pdf)
- [JModelica Documentation](http://www.jmodelica.org/page/10)
- [FMI Standard](https://fmi-standard.org/)

## ✅ What Works Now (Without C++ Extensions)

While you can't run the Python simulations yet, you can:
- ✅ View and study the Modelica models
- ✅ Understand the Python simulation workflow
- ✅ Learn JModelica API usage
- ✅ Prepare for when C++ extensions are built

The examples are **ready to run** once C++ dependencies are installed!
