# JModelica.org - Modernized

This is a modernized fork of the JModelica.org platform.

## Key Changes
*   **Python 3**: The codebase has been migrated from Python 2.7 to Python 3.
*   **Java 17**: The compiler now requires Java 17 (LTS).
*   **Build System**: The legacy Autotools/Ant system has been replaced with **CMake** (C++ runtime) and **Gradle** (Java compiler).

## Prerequisites
*   **Python 3.8+** (via Conda recommended)
*   **Java JDK 17+**
*   **CMake 3.15+**
*   **Ninja Build System**
*   **C++ Compiler** (MSVC on Windows, GCC/Clang on Linux)
*   **Sundials 7.x** & **Ipopt 3.14+** (install via Conda: `conda install sundials ipopt`)

## Build Instructions

### 1. Java Compiler
```bash
cd Compiler
./gradlew build
```
This will generate the `Compiler.jar` in `Compiler/bin`.

### 2. C++ Runtime (JMI)
```bash
mkdir build
cd build
cmake .. -G "Ninja" -DCMAKE_PREFIX_PATH=$CONDA_PREFIX
cmake --build . --target jmi
```

### 3. Python Packages
(Instructions pending completion of Python bindings)
