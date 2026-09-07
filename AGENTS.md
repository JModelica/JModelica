# AGENTS.md

Instructions for automated coding agents (Google Jules, and any other agent that
reads `AGENTS.md`) working on this repository. Human contributors should read it
too — everything here applies to both.

---

## 1. What this project is

JModelica is a compiler and simulation platform for the [Modelica](https://modelica.org)
modelling language. It was developed by Modelon AB, open-sourced under a
CPL/GPL dual licence, and abandoned upstream in 2019 at version 2.14. This
repository is the community continuation.

The system has four layers, and a change in one usually implies a change in another:

| Layer | Path | Language | Built with |
|---|---|---|---|
| Compiler (Modelica → C) | `Compiler/` | Java + [JastAdd](https://jastadd.cs.lth.se/) aspects (`.jrag`, `.ast`, `.flex`, `.parser`) | Gradle (modern) / Ant (legacy) |
| Runtime library | `RuntimeLibrary/` | C | CMake (modern) / Autotools (legacy) |
| Python interface | `Python/src/pymodelica`, `Python/src/pyjmi` | Python + Cython | setuptools |
| Third-party solvers | `ThirdParty/`, `external/` | C, C++, Fortran | vendored |

The compiler emits C code from a `.mo` model; the runtime library is linked
against that generated C to produce an FMU (Functional Mock-up Unit); the Python
layer drives compilation and simulation.

## 2. Branches — read this before starting any task

| Branch | State |
|---|---|
| `master` | **Historical.** The 2.14 tree as salvaged from Modelon, plus small fixes. Autotools + Ant + Python 2 + Java 8. It does not build on any currently supported toolchain. Do not try to "fix" master's autotools build unless an issue explicitly asks for it. |
| `feature/modernization-checkpoint` | **Active development.** CMake + Gradle + Python 3 + Java 17/21. This is where build work belongs. |

**Unless an issue says otherwise, start from `feature/modernization-checkpoint`.**
The repository variable `JULES_STARTING_BRANCH` controls what the automation
passes as the starting branch; workflows read it rather than hard-coding a name.

## 3. Building

On the modernization branch:

```bash
# Runtime library (C)
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel

# Compiler (Java)
cd Compiler && ./gradlew build      # gradlew.bat on Windows
```

System dependencies (Ubuntu names; `vcpkg.json` covers the same set for Windows):

```
build-essential gfortran cmake ninja-build swig
openjdk-21-jdk
libsundials-dev libopenblas-dev liblapack-dev coinor-libipopt-dev zlib1g-dev
python3-dev python3-numpy python3-scipy cython3
```

Ipopt and CasADi are **optional** — they gate the optimisation features only.
A build without them is a valid build. Do not add them as hard requirements.

### Known build blockers

These are the real, current obstacles. `doc/modernization/` on the modernization
branch has the long-form notes.

1. **Sundials 7.x removed `DlsMat`, `realtype`, and the implicit `SUNContext`.**
   JModelica's C runtime uses all three throughout. The shim lives in
   `RuntimeLibrary/src/jmi/jmi_sundials_compat.{c,h}` and is gated on
   `SUNDIALS_VERSION_MAJOR`. Extend the shim; do not sprinkle `#ifdef`s across
   call sites.
2. **JastAdd + Java 17/21.** The generated compiler sources trip on stricter
   generics and static-initialisation ordering.
3. **Python 2 → 3.** Implicit relative imports, `print` statements, and
   `dict.iteritems()` remain in parts of `Python/src/`.
4. **Cython/NumPy 2.x.** `external/PyFMI` and `external/Assimulo` predate the
   NumPy 2 C API.

## 4. Testing

```bash
ctest --test-dir build --output-on-failure   # C runtime
cd Compiler && ./gradlew test                # compiler unit + JUnit tests
python -m pytest Python/tests                # Python layer
```

End-to-end check — this is the one that matters, because it exercises all four
layers at once:

```bash
python examples/000_simple_rc_circuit/simulate_rc.py
```

If you fix a build error, say so plainly and show the command output. If you
could not run the build, say that instead. **Never report a fix as verified on
the strength of the code looking right.**

## 5. Rules for commits and pull requests

### Never commit build artifacts

This is the single most important rule in this file, and it has already cost
this project one unmergeable 348,869-line pull request (#21). Nothing generated
by a build belongs in a commit:

- Cython output — `external/PyFMI/src/pyfmi/*.c`, `external/Assimulo/**/*.c`
- Installed/staged trees — `external/FMILibrary/install/**`, `include/RuntimeLibrary/**`
- Compiled output — `*.o`, `*.so`, `*.dll`, `*.dylib`, `*.a`, `*.class`, `*.jar`, `*.fmu`
- Generated Java from JastAdd/JFlex/Beaver
- `_revision.py` files, `build/`, `install/`, `dist/`, `*.egg-info/`

### Never commit a symlink to an absolute path

PR #21 committed `sundials/include -> /usr/include` and
`ThirdParty/Minpack/lib -> /app/ThirdParty/Minpack/lib64`. Those are paths
inside the build VM; in any other checkout they are meaningless, and actively
breaking. If a build needs to find a library, express that through CMake
(`find_package`, `find_library`, `CMAKE_PREFIX_PATH`) or an environment
variable. Never through a symlink in the source tree.

### Keep diffs reviewable

- **One issue, one pull request.** Do not bundle unrelated fixes.
- **No whitespace-only changes.** Do not reformat, strip trailing whitespace, or
  convert line endings in a file you are otherwise not changing. PR #21 rewrote
  all 5,864 lines of `InstanceTree.jrag` to change nothing.
- **No scratch files.** `test_import.py`, `verify_path.py`, `*_snippet.txt`,
  debug scripts — delete them before committing.
- Preserve existing line endings and indentation style in files you touch.

### Licensing

JModelica is dual-licensed CPL 1.0 / GPL 3.0 (see `LICENSE`). Do not add
dependencies under incompatible licences, and do not paste code from
incompatibly-licensed projects.

### Commit messages

Explain *why*, not just what. Reference the issue: `Fixes #NN`. If a change is
unverified, say so in the commit body — an honest "not compiled" is worth more
than a confident claim that turns out to be wrong.

## 6. Portability requirements

JModelica must be hardware-agnostic and cross-platform. Every change is held to this:

- **No hard-coded absolute paths.** Not `/usr/lib/x86_64-linux-gnu`, not
  `/usr/lib/jvm/java-8-openjdk-amd64`, not `C:\JModelica.org-SDK-1.13`.
- **No architecture assumptions.** Do not assume x86_64. arm64 (Apple Silicon,
  AWS Graviton, Raspberry Pi) is a first-class target. Do not assume
  little-endian, 64-bit pointers, or a specific `long` width.
- **No compiler-specific extensions** without a portable fallback. The C target
  is C11, the C++ target is C++17.
- **Path handling** goes through `os.path` / `pathlib` in Python and
  `std::filesystem` or CMake in C/C++. Emit forward slashes in generated XML —
  see issue #19, where backslashes in `modelDescription.xml` break FMI
  compliance validation.
- Prefer `find_package`/`pkg-config` over hard-coded library names.

## 7. What the CI will run against your pull request

`.github/workflows/ci.yml` runs on every PR:

- `meta` — actionlint on the workflows, `ruff` on Python, artifact/symlink
  guard. **This job is expected to pass and it is the one you must not break.**
- `compiler`, `runtime`, `python` — real builds on Linux, macOS and Windows.
  These currently fail; that is a known state, not something your PR caused.
  Improving them is the point.

The artifact guard in the `meta` job will fail a PR that adds any of the files
listed in §5. That check exists because of PR #21.

### A green CI run does not mean JModelica builds

Read the run summary, not the tick. On `master` there is no CMake and no
Gradle, so the compiler and runtime jobs do not run at all and the workflow can
pass having compiled nothing. Every such run carries a warning annotation
saying so, and the summary states how much was actually built.

Two checks are deliberately tolerant of the existing backlog, and it matters
that you understand the difference between tolerant and absent:

- **The Python 3 job** (`tools/check_python3_syntax.py`) compiles all of
  `Python/src/pymodelica` and `pyjmi` on every run, but excuses the files
  listed in `tools/python3_baseline.txt`. It fails on a *new* Python 2 file, and
  it also fails when a listed file starts compiling and its line is not removed
  — so the list can only shrink, and the debt cannot quietly grow back.
- **Container images** are not built on a ref with no CMake, because the build
  would fail at `cmake -S .` before compiling anything. That failure carried no
  information; it is not evidence that the image builds.

If you are fixing CI, do not extend either mechanism to cover a *new* failure.
Adding a file to the Python baseline to make your pull request pass is
prohibited: the baseline records pre-existing debt, not yours.
