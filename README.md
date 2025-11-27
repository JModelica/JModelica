# JModelica - Modern Build System

This project has been modernized to use:
- **Python 3** (latest)
- **Java 17** (LTS)
- **Gradle** (Java build)
- **CMake** (root build orchestration)
- **vcpkg** (C++ dependency management)

## Quick Start

### Prerequisites
- Python 3.x
- Java 17 or later
- CMake 3.20+
- vcpkg (optional, for C++ dependencies)

### Building

#### Java Compiler Only
```bash
cd Compiler
.\gradlew.bat build
```

#### Full Build with CMake
```bash
# Configure
cmake -B build -S .

# Build Java compiler
cmake --build build --target compiler_build

# Or build everything
cmake --build build
```

### Installing C++ Dependencies (Optional)

Using vcpkg:
```bash
# Set VCPKG_ROOT environment variable
set VCPKG_ROOT=C:\path\to\vcpkg

# Dependencies will be automatically installed via vcpkg.json
cmake -B build -S . -DCMAKE_TOOLCHAIN_FILE=%VCPKG_ROOT%/scripts/buildsystems/vcpkg.cmake
```

Or install manually:
```bash
vcpkg install ipopt sundials
```

### Testing

```bash
cd Compiler
.\gradlew.bat test
```

### Python Verification

```bash
python verify_python.py
```

## Build Outputs

- **Java Compiler**: `Compiler/build/libs/Compiler.jar` (5.3 MB)
- **Generated Code**: `Compiler/build/generated/java/`

## Migration Status

✅ Python 3 migration complete (200+ files)  
✅ Java 17 upgrade complete  
✅ Gradle build system functional  
✅ CMake integration complete  
✅ All tests passing

See `walkthrough.md` in the artifacts directory for complete details.

## Original README

For the original JModelica documentation, see `README_ORIGINAL.md`.
