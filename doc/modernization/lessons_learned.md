# Lessons Learned: JModelica Modernization

## 1. Sundials Compatibility (v2.x to v7.x)
The leap from Sundials 2.x (circa 2014) to 7.x (2024) involves major breaking changes that cannot be ignored.

*   **`DlsMat` Removal**: The `DlsMat` type (Dense Linear Solver Matrix) was removed. It was a struct pointer. Modern Sundials uses `SUNMatrix` (an opaque object).
    *   *Lesson*: Attempting to mix legacy code that accesses `DlsMat` internals (`J->data`) with modern headers is dangerous.
    *   *Solution*: We had to manually define `DlsMat` in `jmi_sundials_compat.h` to match the old struct layout so legacy code could compile.
*   **`N_Vector` Accessors**: Direct access to `N_Vector` fields (like `v->data`) is forbidden.
    *   *Lesson*: Macros like `N_VGetArrayPointer` must be used. However, legacy code often used older macro names or direct access.
    *   *Gotcha*: `N_VGetArrayPointer` is sometimes implemented as a function in newer versions, but legacy code might expect a macro or a different signature. We had to force-define macros using `NV_DATA_S`.
*   **Context Objects**: Sundials 7 requires a `SUNContext` object for almost all calls.
    *   *Lesson*: Legacy code has no concept of this. We implemented a global `SUNContext` in `jmi_sundials_compat.c` and wrapped creation functions (e.g., `CVodeCreate`) to inject it.

## 2. C/C++ Build System Migration
Migrating from Autotools to CMake reveals hidden dependencies.

*   **Implicit Includes**: Legacy code often relied on headers including other headers (e.g., `jmi_block_solver.h` implicitly getting `sundials_types.h`).
    *   *Lesson*: Modern headers are cleaner and don't include as much. We had to explicitly add includes like `<stdint.h>` and `<sundials/sundials_nvector.h>` in multiple files.
*   **Type Visibility**: The error `invalid type argument of '->' (have 'int')` is a classic C compiler confusing a missing type definition for an implicit `int`.
    *   *Lesson*: When seeing "have 'int'" for a struct pointer, 99% of the time the struct definition is not visible to the compiler at that line. Check include order carefully.

## 3. CMake & Conda on Windows
*   **Path Issues**: Conda environments on Windows can be tricky with CMake.
    *   *Lesson*: Explicitly setting `CMAKE_PREFIX_PATH` to the Conda environment root is crucial for `find_package` to work.
    *   *Lesson*: Ninja is strictly required for fast builds, but MSVC is the underlying compiler. Ensure the environment variables for MSVC (`cl.exe`) are set up correctly (using `vcvarsall.bat` or similar if not in a VS command prompt).

## 4. General Modernization Strategy
*   **Iterative vs. Big Bang**: We successfully migrated Python and Java first. This was the right call.
*   **The "Compat Layer" Pattern**: Instead of rewriting 50+ C files to use new Sundials APIs, creating a single `jmi_sundials_compat.h/c` shim was the correct strategic decision, even though getting the types right was hard. It isolates the "ugly" adaptation logic.
