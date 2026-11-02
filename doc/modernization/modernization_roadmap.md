# JModelica Modernization Roadmap

## Phase 1: Core Modernization (Completed)
*   [x] **Python Migration**: Codebase converted to Python 3. Syntax updated, `print()` fixed, `execfile` replaced.
*   [x] **Java Upgrade**: Compiler updated to Java 17. Build system migrated to Gradle.
*   [x] **Build System**: Replaced Autotools/Ant with CMake + Gradle.
*   [x] **Testing**: Java unit tests passing. Python syntax verification passed.

## Phase 2: C++ Runtime & Dependencies (In Progress)
*   [ ] **Sundials Compatibility**:
    *   [x] Create `jmi_sundials_compat.h/c` layer.
    *   [x] Implement `SUNContext` management.
    *   [ ] **Fix Build Errors**: Resolve `DlsMat` type visibility and `N_Vector` macro issues in `jmi` library.
    *   [ ] Verify compilation of `jmi`, `jmi_brent`, `jmi_kinsol`, `jmi_ode_cvode`.
*   [ ] **Ipopt Integration**:
    *   [ ] Ensure CMake finds Conda-installed Ipopt headers/libs.
    *   [ ] Verify linking against Ipopt 3.14+.

## Phase 3: Python Bindings (Pending)
*   [ ] **SWIG Generation**:
    *   [ ] Configure CMake to run SWIG for `jmi`, `fmi`, etc.
    *   [ ] Generate Python wrappers (`.py`) and C wrapper code (`_wrap.c`).
*   [ ] **Extension Compilation**:
    *   [ ] Compile `_pysundials`, `_pyipopt`, `_jmodelica` extension modules.
    *   [ ] Link against Python 3 libraries.

## Phase 4: Verification & Release (Pending)
*   [ ] **Integration Testing**:
    *   [ ] Run full Modelica simulation examples (e.g., `RLC_Circuit`).
    *   [ ] Verify results against expected baselines.
*   [ ] **Packaging**:
    *   [ ] Create a `setup.py` or `pyproject.toml` for easy installation (`pip install .`).
    *   [ ] Document installation prerequisites (Conda env, compilers).
