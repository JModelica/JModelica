# Implementation Plan - JModelica Modernization

## Goal Description
Modernize the JModelica codebase by:
1.  **Python**: Migrating from Python 2.7 to Python 3.
2.  **Java**: Upgrading from Java 1.7 to Java 17 (LTS).
3.  **Build System**: Replacing the legacy Autotools/Ant system with a modern, cross-platform CMake + Gradle setup.

## User Review Required
> [!WARNING]
> **Breaking Changes**:
> - Python 2.7 support will be dropped.
> - Java 1.7 support will be dropped. Requires Java 17+.
> - Build instructions will change completely (from `./configure && make` to `cmake` and `gradle`).

## Proposed Changes

### 1. Python Migration (In Progress)
#### [MODIFY] [Python Source Files](file:///c:/dev/JModelica/20251120/JModelica/Python)
- Continue refactoring `print`, `iteritems`, `xrange`, etc.
- Update `configure.ac` (legacy) was done, but will be superseded by CMake.

### 2. Java Upgrade
#### [MODIFY] [Compiler/build-base.xml](file:///c:/dev/JModelica/20251120/JModelica/Compiler/build-base.xml)
- *Temporary step*: Update `java_version` to `1.7` -> `17` to verify code compatibility before switching build systems.
- Fix any compilation errors arising from stricter type checks or removed APIs in newer Java versions.

### 3. Build System Migration (New)
#### [NEW] [CMakeLists.txt](file:///c:/dev/JModelica/20251120/JModelica/CMakeLists.txt)
- Create a root `CMakeLists.txt` to handle project configuration.
- Detect Python 3, Java, and C/C++ dependencies (Ipopt, Sundials, etc.).
- Replace `configure.ac` functionality.

#### [NEW] [Compiler/build.gradle](file:///c:/dev/JModelica/20251120/JModelica/Compiler/build.gradle)
- Create a Gradle build file to replace `build-base.xml`.
- Define dependencies (JastAdd, Beaver, JUnit).
- Configure Java 17 toolchain.
- Define tasks for JastAdd/JFlex/Beaver code generation.

#### [DELETE] [Legacy Build Files]
- `configure.ac`, `Makefile.am`
- `Compiler/build-base.xml` (after successful Gradle migration)

## Verification Plan

### Automated Tests
- **Java**: Run `gradle test` to execute JUnit tests.
- **Python**: Run `python3 -m pytest` (if setup) or existing test scripts.
- **Integration**: Verify the full build passes with `cmake --build .`.

### Manual Verification
- Compile the project using the new CMake/Gradle system.
- Run a sample Modelica compilation using the updated Python interface.
