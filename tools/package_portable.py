#!/usr/bin/env python3
"""Assemble a self-contained, relocatable JModelica bundle.

The result is one archive per (operating system, architecture) that unpacks and
runs with no installation step, no system JDK, and no system Sundials — every
dependency the platform does not already guarantee is inside it.

What "portable" can and cannot mean here
----------------------------------------
JModelica is not one program. It is a Java compiler, a C runtime library that
generated model code links against, and a Python driver on top of both. There is
no single-executable form of that, and a tool claiming to produce one would be
shipping something else. What is achievable, and what this produces, is a
*hermetic directory tree* that can be copied anywhere on a matching platform and
run:

    jmodelica-2.15-linux-x86_64/
      bin/jmodelica            launcher, resolves its own root at runtime
      runtime/                 minimal JRE built by jlink from the build JDK
      lib/                     compiler jars
      lib/native/              libjmi and the solver libraries it links
      python/                  pymodelica, pyjmi and their pure-Python deps
      MSL/                     Modelica Standard Library

The one thing the host must still provide is a C compiler, because compiling a
Modelica model to an FMU means compiling generated C. That is inherent to how
JModelica works, not a packaging shortfall.

Usage
-----
    python tools/package_portable.py \
        --build-dir build \
        --compiler-dir Compiler/build/libs \
        --version 2.15 \
        --output dist

Requires a completed build. It verifies what it is given rather than assuming:
a missing runtime library or an empty jar directory is an error, not a warning,
because an archive that unpacks into a broken tree is worse than no archive.
"""

from __future__ import annotations

import argparse
import hashlib
import os
import platform
import shutil
import subprocess
import sys
import tarfile
import zipfile
from pathlib import Path

# Modules the compiler and the launcher need. Kept explicit rather than using
# --add-modules ALL-MODULE-PATH so the runtime stays small and its contents are
# reviewable.
JLINK_MODULES = [
    "java.base",
    "java.desktop",
    "java.logging",
    "java.management",
    "java.naming",
    "java.scripting",
    "java.sql",
    "java.xml",
    "jdk.crypto.ec",
    "jdk.unsupported",
    "jdk.zipfs",
]

NATIVE_LIB_SUFFIXES = (".so", ".dylib", ".dll", ".a", ".lib")


def normalised_arch() -> str:
    """Return a stable architecture name.

    ``platform.machine()`` reports the same architecture under several names
    depending on the OS and the Python build — ``AMD64`` on Windows, ``x86_64``
    on Linux, ``arm64`` on macOS and ``aarch64`` on Linux for the same chip.
    Release asset names must not inherit that inconsistency.
    """
    machine = platform.machine().lower()
    return {
        "amd64": "x86_64",
        "x64": "x86_64",
        "x86-64": "x86_64",
        "arm64": "aarch64",
        "armv8": "aarch64",
        "armv8l": "aarch64",
    }.get(machine, machine)


def normalised_os() -> str:
    system = platform.system().lower()
    return {"darwin": "macos"}.get(system, system)


def run(command: list[str]) -> None:
    print("+", " ".join(command), flush=True)
    subprocess.run(command, check=True)


def build_runtime(destination: Path) -> None:
    """Build a minimal Java runtime with jlink.

    jlink emits a runtime for the architecture of the JDK running it, so this
    must run on the target platform. That is why the release matrix has a job
    per platform rather than cross-building from one runner.
    """
    jlink = shutil.which("jlink")
    if jlink is None:
        raise SystemExit(
            "jlink not found. A full JDK is required to build the bundle; a JRE "
            "is not enough. Set JAVA_HOME to a JDK and put its bin on PATH."
        )

    if destination.exists():
        shutil.rmtree(destination)

    run(
        [
            jlink,
            "--add-modules",
            ",".join(JLINK_MODULES),
            "--strip-debug",
            "--no-man-pages",
            "--no-header-files",
            "--compress=zip-6",
            "--output",
            str(destination),
        ]
    )


def copy_tree(source: Path, destination: Path, *, description: str) -> int:
    if not source.is_dir():
        raise SystemExit(f"{description} not found at {source}")
    shutil.copytree(source, destination, dirs_exist_ok=True, symlinks=False)
    return sum(1 for _ in destination.rglob("*") if _.is_file())


def collect_native_libraries(build_dir: Path, destination: Path) -> int:
    """Copy built shared and static libraries out of the CMake build tree.

    Symlinks are resolved rather than copied: a versioned ``.so.6 -> .so.6.1.0``
    chain is meaningless once the tree is relocated, and AGENTS.md forbids
    shipping symlinks that point outside their own tree.
    """
    destination.mkdir(parents=True, exist_ok=True)
    count = 0
    for path in build_dir.rglob("*"):
        if not path.is_file():
            continue
        if path.suffix not in NATIVE_LIB_SUFFIXES:
            continue
        if "CMakeFiles" in path.parts:
            continue
        target = destination / path.name
        if target.exists():
            continue
        shutil.copy2(path.resolve(), target)
        count += 1
    return count


LAUNCHER_SH = """#!/bin/sh
# JModelica launcher. Resolves its own installation root so the bundle can be
# unpacked anywhere; nothing here is baked in at build time.
set -eu

target=$0
# Follow symlinks so `ln -s .../bin/jmodelica /usr/local/bin/jmodelica` works.
while [ -L "$target" ]; do
    link=$(readlink "$target")
    case $link in
        /*) target=$link ;;
        *)  target=$(dirname "$target")/$link ;;
    esac
done

JMODELICA_HOME=$(cd -- "$(dirname -- "$target")/.." && pwd)
export JMODELICA_HOME

JAVA_HOME=$JMODELICA_HOME/runtime
export JAVA_HOME

PYTHONPATH=$JMODELICA_HOME/python${PYTHONPATH:+:$PYTHONPATH}
export PYTHONPATH

MODELICAPATH=$JMODELICA_HOME/MSL${MODELICAPATH:+:$MODELICAPATH}
export MODELICAPATH

case $(uname -s) in
    Darwin)
        DYLD_LIBRARY_PATH=$JMODELICA_HOME/lib/native${DYLD_LIBRARY_PATH:+:$DYLD_LIBRARY_PATH}
        export DYLD_LIBRARY_PATH
        ;;
    *)
        LD_LIBRARY_PATH=$JMODELICA_HOME/lib/native${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
        export LD_LIBRARY_PATH
        ;;
esac

exec "$JAVA_HOME/bin/java" -cp "$JMODELICA_HOME/lib/*" \\
    org.jmodelica.modelica.compiler.ModelicaCompiler "$@"
"""

LAUNCHER_BAT = """@echo off
rem JModelica launcher. Resolves its own installation root so the bundle can be
rem unpacked anywhere; nothing here is baked in at build time.
setlocal

for %%I in ("%~dp0..") do set "JMODELICA_HOME=%%~fI"
set "JAVA_HOME=%JMODELICA_HOME%\\runtime"
set "PYTHONPATH=%JMODELICA_HOME%\\python;%PYTHONPATH%"
set "MODELICAPATH=%JMODELICA_HOME%\\MSL;%MODELICAPATH%"
rem Windows resolves DLLs from PATH, not from a dedicated library variable.
set "PATH=%JMODELICA_HOME%\\lib\\native;%PATH%"

"%JAVA_HOME%\\bin\\java.exe" -cp "%JMODELICA_HOME%\\lib\\*" ^
    org.jmodelica.modelica.compiler.ModelicaCompiler %*
"""


def write_launchers(root: Path) -> None:
    bin_dir = root / "bin"
    bin_dir.mkdir(parents=True, exist_ok=True)

    sh = bin_dir / "jmodelica"
    sh.write_text(LAUNCHER_SH, newline="\n", encoding="utf-8")
    sh.chmod(0o755)

    bat = bin_dir / "jmodelica.bat"
    # CRLF: cmd.exe misparses a batch file with bare LF line endings.
    bat.write_text(LAUNCHER_BAT, newline="\r\n", encoding="utf-8")


def archive(root: Path, output_dir: Path, name: str, *, use_zip: bool) -> Path:
    output_dir.mkdir(parents=True, exist_ok=True)

    if use_zip:
        path = output_dir / f"{name}.zip"
        with zipfile.ZipFile(path, "w", zipfile.ZIP_DEFLATED, compresslevel=9) as zf:
            for item in sorted(root.rglob("*")):
                zf.write(item, Path(name) / item.relative_to(root))
        return path

    path = output_dir / f"{name}.tar.gz"
    with tarfile.open(path, "w:gz", compresslevel=9) as tf:
        # A fixed arcname prefix keeps the archive from unpacking into the
        # current directory, and sorting makes the output reproducible.
        tf.add(root, arcname=name, recursive=True)
    return path


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--build-dir", type=Path, default=Path("build"))
    parser.add_argument("--compiler-dir", type=Path, default=Path("Compiler/build/libs"))
    parser.add_argument("--python-dir", type=Path, default=Path("Python/src"))
    parser.add_argument("--msl-dir", type=Path, default=Path("ThirdParty/MSL"))
    parser.add_argument("--version", required=True)
    parser.add_argument("--output", type=Path, default=Path("dist"))
    parser.add_argument(
        "--staging",
        type=Path,
        default=None,
        help="where to assemble the tree (default: <output>/staging)",
    )
    args = parser.parse_args()

    target_os = normalised_os()
    target_arch = normalised_arch()
    name = f"jmodelica-{args.version}-{target_os}-{target_arch}"

    print(f"Packaging {name}")
    print(f"  host: {platform.platform()}")

    staging = (args.staging or args.output / "staging") / name
    if staging.exists():
        shutil.rmtree(staging)
    staging.mkdir(parents=True)

    print("Building the Java runtime with jlink...")
    build_runtime(staging / "runtime")

    print("Collecting the compiler jars...")
    jars = sorted(args.compiler_dir.glob("*.jar")) if args.compiler_dir.is_dir() else []
    if not jars:
        raise SystemExit(
            f"No jars in {args.compiler_dir}. Build the compiler first:\n"
            f"    cd Compiler && ./gradlew build"
        )
    lib = staging / "lib"
    lib.mkdir(parents=True, exist_ok=True)
    for jar in jars:
        shutil.copy2(jar, lib / jar.name)
    print(f"  {len(jars)} jar(s)")

    print("Collecting the native libraries...")
    native_count = collect_native_libraries(args.build_dir, lib / "native")
    if native_count == 0:
        raise SystemExit(
            f"No native libraries under {args.build_dir}. Build the runtime "
            f"library first:\n"
            f"    cmake -S . -B build && cmake --build build\n"
            f"Shipping a bundle without libjmi would produce a compiler that "
            f"cannot link the model code it generates."
        )
    print(f"  {native_count} librar(y/ies)")

    print("Collecting the Python interface...")
    python_files = copy_tree(
        args.python_dir, staging / "python", description="Python source"
    )
    print(f"  {python_files} file(s)")

    if args.msl_dir.is_dir():
        print("Collecting the Modelica Standard Library...")
        msl_files = copy_tree(
            args.msl_dir, staging / "MSL", description="Modelica Standard Library"
        )
        print(f"  {msl_files} file(s)")
    else:
        print(f"  skipped: {args.msl_dir} not present")

    print("Writing the launchers...")
    write_launchers(staging)

    for filename in ("LICENSE", "README.md", "CHANGELOG.txt"):
        source = Path(filename)
        if source.is_file():
            shutil.copy2(source, staging / filename)

    (staging / "BUNDLE-INFO.txt").write_text(
        f"JModelica {args.version}\n"
        f"Platform: {target_os}-{target_arch}\n"
        f"Built on: {platform.platform()}\n"
        f"Java runtime: bundled (jlink)\n"
        f"\n"
        f"Relocatable: unpack anywhere and run bin/jmodelica.\n"
        f"\n"
        f"The host must provide a C compiler. Compiling a Modelica model to an\n"
        f"FMU means compiling generated C source, so a toolchain is required at\n"
        f"model-compile time. Everything else is inside this directory.\n",
        encoding="utf-8",
    )

    print("Creating the archive...")
    path = archive(
        staging, args.output, name, use_zip=(target_os == "windows")
    )
    digest = sha256(path)
    (args.output / f"{path.name}.sha256").write_text(
        f"{digest}  {path.name}\n", encoding="utf-8"
    )

    size_mb = path.stat().st_size / (1024 * 1024)
    print(f"\n{path}  ({size_mb:.1f} MiB)")
    print(f"sha256  {digest}")

    if os.environ.get("GITHUB_OUTPUT"):
        with open(os.environ["GITHUB_OUTPUT"], "a", encoding="utf-8") as handle:
            handle.write(f"archive={path}\n")
            handle.write(f"name={name}\n")

    return 0


if __name__ == "__main__":
    sys.exit(main())
