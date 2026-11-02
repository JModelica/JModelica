# Installing C++ Dependencies for JModelica

JModelica requires the following C++ libraries for full functionality:
- **Ipopt** - Interior Point Optimizer
- **Sundials** - Suite of Nonlinear and Differential/Algebraic equation Solvers

## Option 1: Using vcpkg (Recommended for Windows)

### Setup vcpkg

If you don't have vcpkg installed:
```bash
# Clone vcpkg
git clone https://github.com/Microsoft/vcpkg.git C:\vcpkg
cd C:\vcpkg

# Bootstrap vcpkg
.\bootstrap-vcpkg.bat

# Set environment variable (add to System Environment Variables for persistence)
setx VCPKG_ROOT C:\vcpkg
```

### Install Dependencies

#### Automatic Installation (via vcpkg.json manifest)
The project includes a `vcpkg.json` manifest file. Dependencies will be automatically installed when you configure with CMake:

```bash
cmake -B build -S . -DCMAKE_TOOLCHAIN_FILE=%VCPKG_ROOT%/scripts/buildsystems/vcpkg.cmake
```

#### Manual Installation
```bash
# Install Ipopt
vcpkg install ipopt:x64-windows

# Install Sundials
vcpkg install sundials:x64-windows

# Or install both at once
vcpkg install ipopt sundials --triplet x64-windows
```

### Build with vcpkg

```bash
# Configure
cmake -B build -S . -DCMAKE_TOOLCHAIN_FILE=%VCPKG_ROOT%/scripts/buildsystems/vcpkg.cmake

# Build
cmake --build build

# Build Java compiler only
cmake --build build --target compiler_build
```

---

## Option 2: Using Conan

### Setup Conan

```bash
# Install Conan (if not already installed)
pip install conan

# Create default profile
conan profile detect
```

### Create conanfile.txt

Create a `conanfile.txt` in the project root:
```ini
[requires]
ipopt/3.14.14
sundials/6.6.2

[generators]
CMakeDeps
CMakeToolchain

[options]
ipopt/*:shared=True
sundials/*:shared=True
```

### Install Dependencies

```bash
# Install dependencies
conan install . --output-folder=build --build=missing

# Configure CMake with Conan toolchain
cmake -B build -S . -DCMAKE_TOOLCHAIN_FILE=build/conan_toolchain.cmake

# Build
cmake --build build
```

---

## Verifying Installation

After installing dependencies, CMake will report their status:

```
-- Ipopt: Found
-- Sundials: Found
```

If not found, you'll see:
```
-- Ipopt not found. Install with: vcpkg install ipopt
-- Sundials not found. Install with: vcpkg install sundials
```

---

## Current Build Status

✅ **Java Compiler**: Fully functional without C++ dependencies
- Build: `cd Compiler && .\gradlew.bat build`
- Test: `cd Compiler && .\gradlew.bat test`
- Output: `Compiler/build/libs/Compiler.jar` (5.3 MB)

⚠️ **C++ Extensions**: Require Ipopt and Sundials
- Used by Python `pyjmi` module
- Not required for Java compiler functionality

✅ **Python Code**: Migrated to Python 3, syntax verified
- Verification: `python verify_python.py`
- Runtime testing requires C++ extensions

---

## Troubleshooting

### vcpkg not found
```bash
# Make sure VCPKG_ROOT is set
echo %VCPKG_ROOT%

# If not set, set it:
setx VCPKG_ROOT C:\path\to\vcpkg
```

### CMake not found
Install CMake from https://cmake.org/download/ or use:
```bash
# Via scoop
scoop install cmake

# Via chocolatey
choco install cmake
```

### Dependency conflicts
```bash
# Clean vcpkg cache
vcpkg remove ipopt sundials
vcpkg install ipopt sundials --triplet x64-windows
```

---

## Next Steps

1. **Install dependencies** using vcpkg or conan (see above)
2. **Configure CMake** with the appropriate toolchain file
3. **Build C++ extensions** (will be added to CMakeLists.txt)
4. **Test Python runtime** with `import pyjmi`

For now, the Java compiler is fully functional and can be used independently of the C++ dependencies.
