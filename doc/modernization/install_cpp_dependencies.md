# Installing C++ Dependencies for JModelica - Complete Guide

## Current Status

✅ **Java Compiler**: Fully functional  
✅ **Python Code**: Migrated to Python 3  
✅ **Modelica Examples**: Created and ready  
❌ **C++ Extensions**: Require manual installation

## Why C++ Dependencies Are Needed

The JModelica Python runtime (`pyjmi` module) requires C++ extensions that depend on:
1. **Ipopt** - Interior Point Optimizer (for optimization problems)
2. **Sundials** - ODE/DAE solvers (for simulation)

Without these, you'll see: `ImportError: No module named 'jmi'`

## Installation Steps

### Option 1: Official Microsoft vcpkg (Recommended)

The scoop-installed vcpkg doesn't include Ipopt/Sundials ports. You need the official Microsoft vcpkg.

#### Step 1: Install Official vcpkg

```powershell
# Clone vcpkg repository
cd C:\
git clone https://github.com/Microsoft/vcpkg.git
cd vcpkg

# Bootstrap vcpkg
.\bootstrap-vcpkg.bat

# Add to PATH (optional but recommended)
$env:Path += ";C:\vcpkg"
[Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::User)

# Set VCPKG_ROOT
[Environment]::SetEnvironmentVariable("VCPKG_ROOT", "C:\vcpkg", [System.EnvironmentVariableTarget]::User)
```

#### Step 2: Install Dependencies

```powershell
# Install Ipopt (this will take 30-60 minutes)
C:\vcpkg\vcpkg install ipopt:x64-windows

# Install Sundials (this will take 15-30 minutes)
C:\vcpkg\vcpkg install sundials:x64-windows

# Verify installation
C:\vcpkg\vcpkg list
```

#### Step 3: Configure JModelica with CMake

```powershell
cd C:\dev\JModelica\20251120\JModelica

# Configure with vcpkg toolchain
cmake -B build -S . -DCMAKE_TOOLCHAIN_FILE=C:\vcpkg\scripts\buildsystems\vcpkg.cmake

# Build C++ extensions
cmake --build build

# Or build specific targets
cmake --build build --target compiler_build
```

#### Step 4: Set Environment Variables

```powershell
# Set JMODELICA_HOME
$env:JMODELICA_HOME = "C:\dev\JModelica\20251120\JModelica"
[Environment]::SetEnvironmentVariable("JMODELICA_HOME", $env:JMODELICA_HOME, [System.EnvironmentVariableTarget]::User)

# Add to PYTHONPATH
$pythonPath = "$env:JMODELICA_HOME\Python\src"
[Environment]::SetEnvironmentVariable("PYTHONPATH", $pythonPath, [System.EnvironmentVariableTarget]::User)
```

#### Step 5: Test Installation

```powershell
# Test Python imports
C:\Users\FoadS\AppData\Local\miniconda3\python.exe -c "import pymodelica; print('pymodelica OK')"
C:\Users\FoadS\AppData\Local\miniconda3\python.exe -c "import pyjmi; print('pyjmi OK')"

# Run an example
cd examples\000_simple_rc_circuit
C:\Users\FoadS\AppData\Local\miniconda3\python.exe simulate_rc.py
```

---

### Option 2: Pre-built Binaries (Faster)

If available, download pre-built Ipopt and Sundials binaries:

#### Ipopt
- Download from: https://github.com/coin-or/Ipopt/releases
- Extract to: `C:\Program Files\Ipopt`
- Add to PATH: `C:\Program Files\Ipopt\bin`

#### Sundials
- Download from: https://computing.llnl.gov/projects/sundials
- Extract to: `C:\Program Files\Sundials`
- Add to PATH: `C:\Program Files\Sundials\bin`

Then configure CMake to find them:
```powershell
cmake -B build -S . `
  -DIpopt_DIR="C:\Program Files\Ipopt\lib\cmake\Ipopt" `
  -DSUNDIALS_DIR="C:\Program Files\Sundials\lib\cmake\sundials"
```

---

### Option 3: Conda (Alternative)

If you're using conda/miniconda:

```powershell
# Activate base environment
conda activate base

# Install dependencies via conda-forge
conda install -c conda-forge ipopt sundials

# Configure CMake to use conda libraries
cmake -B build -S . `
  -DCMAKE_PREFIX_PATH="C:\Users\FoadS\AppData\Local\miniconda3"
```

---

## Troubleshooting

### "ipopt does not exist" in vcpkg
**Cause**: Using scoop-installed vcpkg which has limited ports  
**Solution**: Install official Microsoft vcpkg (see Option 1)

### "CMake not found"
**Cause**: CMake not in PATH  
**Solution**: `scoop install cmake` or download from cmake.org

### "Cannot find Ipopt" during CMake configure
**Cause**: vcpkg toolchain not specified  
**Solution**: Add `-DCMAKE_TOOLCHAIN_FILE=C:\vcpkg\scripts\buildsystems\vcpkg.cmake`

### "No module named 'jmi'" after installation
**Cause**: C++ extensions not built or not in PYTHONPATH  
**Solution**: 
1. Verify build completed: `ls build\lib`
2. Check JMODELICA_HOME: `echo $env:JMODELICA_HOME`
3. Check PYTHONPATH: `echo $env:PYTHONPATH`

### Build takes too long
**Cause**: Ipopt builds many dependencies from source  
**Solution**: This is normal. Ipopt can take 30-60 minutes on first build.

---

## What You Can Do Right Now (Without C++ Extensions)

While waiting for dependencies to install:

1. ✅ **Study the Examples** - Review Modelica models and Python scripts
2. ✅ **Modify Models** - Edit `.mo` files to learn Modelica syntax
3. ✅ **Use Java Compiler** - The Java compiler works independently
4. ✅ **Compile Modelica** - Use the Java compiler to check model syntax

```powershell
# Compile a Modelica model (Java only, no simulation)
cd Compiler
.\gradlew.bat build

# This works without C++ dependencies!
```

---

## Estimated Installation Time

| Step | Time |
|------|------|
| Install official vcpkg | 5 minutes |
| Install Ipopt | 30-60 minutes |
| Install Sundials | 15-30 minutes |
| Build C++ extensions | 10-20 minutes |
| **Total** | **1-2 hours** |

Most of this is automated compilation time. You can do other work while it builds.

---

## Next Steps After Installation

Once C++ dependencies are installed:

1. ✅ Run all examples in `examples/` directory
2. ✅ Verify simulation results
3. ✅ Create your own Modelica models
4. ✅ Use JModelica for optimization and simulation

---

## Quick Reference Commands

```powershell
# Install official vcpkg
git clone https://github.com/Microsoft/vcpkg.git C:\vcpkg
C:\vcpkg\bootstrap-vcpkg.bat

# Install dependencies
C:\vcpkg\vcpkg install ipopt:x64-windows sundials:x64-windows

# Build JModelica
cd C:\dev\JModelica\20251120\JModelica
cmake -B build -S . -DCMAKE_TOOLCHAIN_FILE=C:\vcpkg\scripts\buildsystems\vcpkg.cmake
cmake --build build

# Set environment
$env:JMODELICA_HOME = "C:\dev\JModelica\20251120\JModelica"

# Test
cd examples\000_simple_rc_circuit
python simulate_rc.py
```

---

## Support

If you encounter issues:
1. Check the error message carefully
2. Verify all environment variables are set
3. Ensure vcpkg installation completed successfully
4. Check CMake configuration output for missing dependencies

The JModelica Java compiler and Python code are fully modernized and ready. The C++ dependencies are the final step to enable full simulation capabilities.
