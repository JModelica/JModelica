#!/usr/bin/env python3
"""Reject build artifacts, generated sources and unportable symlinks.

This exists because pull request #21 added 348,869 lines, of which 347,828 were
Cython output, an installed FMILibrary tree, copied headers, whitespace churn,
and six symlinks pointing at absolute paths inside the build VM
(``sundials/include -> /usr/include``). None of it was reviewable, and none of
it belonged in a commit.

Run over a diff in CI::

    git diff --name-only --diff-filter=AM origin/master...HEAD | \
        python tools/check_no_artifacts.py --stdin

Or over the whole working tree::

    python tools/check_no_artifacts.py --all

Exits non-zero and prints a GitHub Actions error annotation for each offending
path. ``--warn-only`` downgrades the exit code for advisory runs.
"""

from __future__ import annotations

import argparse
import fnmatch
import os
import posixpath
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path, PurePosixPath, PureWindowsPath

# Paths matching a rule are rejected unless they also match an allowance in
# ALLOWED. Patterns are matched against POSIX-style repository-relative paths.
#
# Each rule carries the reason a human needs in order to act on it; a bare
# "file not allowed" wastes the reader's time.


@dataclass(frozen=True)
class Rule:
    patterns: tuple[str, ...]
    reason: str


RULES: tuple[Rule, ...] = (
    Rule(
        patterns=("**/*.pyx.c",),
        reason=(
            "Cython-generated C. Regenerate it at build time from the .pyx "
            "source instead of committing it"
        ),
    ),
    Rule(
        patterns=(
            "external/*/install/**",
            "include/RuntimeLibrary/**",
            "**/CMakeFiles/**",
            "**/CMakeCache.txt",
            "**/*.egg-info/**",
        ),
        reason=(
            "installed or staged build output. Let the build produce it; "
            "point at it with CMAKE_PREFIX_PATH if something needs to find it"
        ),
    ),
    Rule(
        patterns=(
            "**/*.o",
            "**/*.obj",
            "**/*.a",
            "**/*.lib",
            "**/*.so",
            "**/*.so.*",
            "**/*.dylib",
            "**/*.dll",
            "**/*.exe",
            "**/*.class",
            "**/*.jar",
            "**/*.pyc",
            "**/*.pyd",
            "**/*.fmu",
            "**/*.fmux",
        ),
        reason="compiled output",
    ),
    Rule(
        patterns=(
            "**/_revision.py",
            "**/generated/**/*.java",
        ),
        reason="generated at build time",
    ),
    Rule(
        patterns=(
            "test_import.py",
            "verify_path.py",
            "verify_python.py",
            "**/*_snippet.txt",
            "**/scratch_*",
            "**/tmp_*",
        ),
        reason="looks like a scratch or debug file left behind by a build session",
    ),
)

# Deliberate exceptions.
#
# Test and example *fixtures* are the interesting case: the FMUs under
# `.../tests/files/FMUs/` are pre-built inputs that the test suite reads, not
# output that the build produces. Blocking them would make the rule unusable for
# anyone touching the test corpus. The allowance is scoped to `files/`
# directories under a test or example tree so that it cannot be used to smuggle
# a compiled library into `src/`.
ALLOWED: tuple[str, ...] = (
    "**/gradle/wrapper/gradle-wrapper.jar",
    # Vendored upstream sources this project is built around. Matched at any
    # depth: there is a ThirdParty tree at the repository root and another under
    # Compiler/ModelicaFrontEnd/.
    "ThirdParty/**",
    "**/ThirdParty/**",
    "**/thirdparty/**",
    # Test and example fixtures.
    "**/test/files/**",
    "**/tests/files/**",
    "**/tests_*/files/**",
    "**/examples/files/**",
)

# Binary sizes above this in a single added file are reported even when no rule
# matches, because a large opaque blob is almost never a deliberate source
# addition.
LARGE_FILE_BYTES = 2 * 1024 * 1024


def matches(path: str, patterns: tuple[str, ...]) -> bool:
    """True if *path* matches any glob in *patterns*.

    ``fnmatch`` has no notion of path separators, so ``**/`` is handled by also
    testing the pattern with a leading ``**/`` stripped. That makes ``**/*.o``
    match both ``a/b.o`` and ``b.o``.
    """
    for pattern in patterns:
        if fnmatch.fnmatch(path, pattern):
            return True
        if pattern.startswith("**/") and fnmatch.fnmatch(path, pattern[3:]):
            return True
    return False


def annotate(path: str, message: str, *, level: str = "error") -> None:
    """Print a GitHub Actions annotation, or a plain line when run locally."""
    if os.environ.get("GITHUB_ACTIONS") == "true":
        print(f"::{level} file={path}::{message}")
    else:
        print(f"{level.upper()}: {path}: {message}")


def check_cython_output(root: Path, path: str) -> str | None:
    """Reject a ``.c`` file that sits next to a ``.pyx`` of the same name.

    Keying on the sibling source rather than on a directory glob matters here:
    ``external/Assimulo/thirdparty/kvaernoe/SDIRK-DAE.c`` is hand-written C that
    a path-based rule would wrongly condemn, while
    ``external/PyFMI/src/pyfmi/fmi.c`` — 134,361 lines of it in PR #21 — is
    output from ``fmi.pyx`` sitting right beside it.
    """
    if not path.endswith(".c"):
        return None

    stem = (root / path).with_suffix(".pyx")
    if stem.exists():
        return (
            f"Cython output generated from {stem.name}. Regenerate it at build "
            f"time instead of committing it"
        )
    return None


def check_symlink(root: Path, path: str) -> str | None:
    """Reject a symlink whose target escapes the repository.

    An absolute target, or a relative one that climbs out of the tree, refers to
    the machine that created it and to nothing else.
    """
    full = root / path
    if not full.is_symlink():
        return None

    target = os.readlink(full)

    # Both conventions are tested deliberately. A symlink committed on Linux is
    # read back on Windows and vice versa, so "absolute" has to mean absolute
    # under either set of rules. os.path.isabs alone is not enough: since Python
    # 3.13, ntpath.isabs("/usr/include") returns False, because on Windows a
    # leading slash is drive-relative rather than absolute. Relying on it would
    # make this check silently blind on Windows to precisely the POSIX symlinks
    # it exists to catch.
    if PurePosixPath(target).is_absolute() or PureWindowsPath(target).is_absolute():
        return (
            f"symlink to the absolute path {target!r}. That path exists only on "
            f"the machine that created it. Express the dependency through CMake "
            f"(find_package / find_library / CMAKE_PREFIX_PATH) instead"
        )

    # git always reports POSIX-separated paths, so normalise as POSIX rather
    # than with os.path, whose behaviour would differ per platform.
    resolved = posixpath.normpath(
        posixpath.join(posixpath.dirname(path), target.replace("\\", "/"))
    )
    if resolved == ".." or resolved.startswith("../"):
        return f"symlink to {target!r}, which points outside the repository"
    return None


def tracked_files(root: Path) -> list[str]:
    result = subprocess.run(
        ["git", "-C", str(root), "ls-files"],
        capture_output=True,
        text=True,
        check=True,
    )
    return [line for line in result.stdout.splitlines() if line]


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    source = parser.add_mutually_exclusive_group(required=True)
    source.add_argument(
        "--stdin",
        action="store_true",
        help="read newline-separated paths from stdin (e.g. git diff --name-only)",
    )
    source.add_argument(
        "--all", action="store_true", help="check every tracked file"
    )
    parser.add_argument(
        "--root", default=".", help="repository root (default: current directory)"
    )
    parser.add_argument(
        "--warn-only",
        action="store_true",
        help="report findings but exit 0",
    )
    args = parser.parse_args()

    root = Path(args.root).resolve()

    if args.stdin:
        paths = [line.strip() for line in sys.stdin if line.strip()]
    else:
        paths = tracked_files(root)

    findings = 0
    for raw in paths:
        path = raw.replace("\\", "/")

        if matches(path, ALLOWED):
            continue

        symlink_problem = check_symlink(root, path)
        if symlink_problem is not None:
            annotate(path, symlink_problem)
            findings += 1
            continue

        cython_problem = check_cython_output(root, path)
        if cython_problem is not None:
            annotate(path, f"{cython_problem}. See AGENTS.md section 5.")
            findings += 1
            continue

        matched = False
        for rule in RULES:
            if matches(path, rule.patterns):
                annotate(path, f"{rule.reason}. See AGENTS.md section 5.")
                findings += 1
                matched = True
                break
        if matched:
            continue

        full = root / path
        # A symlink was handled above; is_file() follows links, so guard on it.
        if full.is_file() and not full.is_symlink():
            size = full.stat().st_size
            if size > LARGE_FILE_BYTES:
                annotate(
                    path,
                    f"{size // 1024} KiB added in one file. If this is build "
                    f"output or vendored binary content it does not belong in "
                    f"git; if it is legitimate, add it to ALLOWED in "
                    f"tools/check_no_artifacts.py with a reason",
                    level="warning",
                )

    if findings:
        print(
            f"\n{findings} disallowed path(s). AGENTS.md section 5 explains "
            f"what belongs in a commit and what does not.",
            file=sys.stderr,
        )
        return 0 if args.warn_only else 1

    print(f"No build artifacts or unportable symlinks in {len(paths)} path(s).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
