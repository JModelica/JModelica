"""Regression tests for the artifact guard.

Run with ``python -m pytest tools/test_check_no_artifacts.py``.

The symlink cases are exercised through monkeypatching rather than real
symlinks, because creating a symlink on Windows requires Developer Mode or
elevation and these tests must run on every platform in the CI matrix.

Every case here is drawn from a path that actually appeared in pull request
#21, so a change that stops catching them is a real regression.
"""

from __future__ import annotations

import os
from pathlib import Path

import pytest

# No sys.path manipulation: pytest's default "prepend" import mode already puts
# this file's directory first, because tools/ has no __init__.py.
from check_no_artifacts import (
    ALLOWED,
    RULES,
    check_cython_output,
    check_symlink,
    matches,
)

# --- Paths that must be rejected -------------------------------------------

REJECTED = [
    # Installed / staged trees copied into the source tree by PR #21.
    "include/RuntimeLibrary/jmi.h",
    "include/RuntimeLibrary/zlib/zlib.h",
    "external/FMILibrary/install/include/FMI2/fmi2_import.h",
    # Compiled output.
    "RuntimeLibrary/libjmi.so",
    "Compiler/build/classes/Foo.class",
    "RCCircuit.fmu",
    "build/libjmi.a",
    "Python/src/pymodelica/compiler.pyc",
    # Generated at build time.
    "Python/src/pyjmi/_revision.py",
    "Python/src/pymodelica/_revision.py",
    # Scratch files.
    "test_import.py",
    "verify_path.py",
    "Python/setup_snippet.txt",
]


@pytest.mark.parametrize("path", REJECTED)
def test_rejected_paths_match_a_rule(path: str) -> None:
    assert not matches(path, ALLOWED), f"{path} should not be allow-listed"
    assert any(
        matches(path, rule.patterns) for rule in RULES
    ), f"{path} matched no rule; PR #21 would slip through again"


# --- Paths that must be accepted -------------------------------------------

ACCEPTED = [
    # Real source.
    "RuntimeLibrary/src/jmi/jmi_sundials_compat.c",
    "RuntimeLibrary/src/jmi/jmi_sundials_compat.h",
    "Compiler/ModelicaMiddleEnd/src/jastadd/structural/BLT.jrag",
    "Python/src/pymodelica/compiler.py",
    "tools/check_no_artifacts.py",
    ".github/workflows/ci.yml",
    # Hand-written C that a directory-glob rule would wrongly condemn.
    "external/Assimulo/thirdparty/kvaernoe/SDIRK-DAE.c",
    # Vendored upstream trees, at both depths they occur in this repository.
    "ThirdParty/Minpack/cminpack-1.3.2/minpack.c",
    "Compiler/ModelicaFrontEnd/ThirdParty/Beaver/lib/beaver-rt.jar",
    # Test and example fixtures: pre-built inputs the suites read.
    "external/PyFMI/src/pyfmi/tests/files/FMUs/XML/ME2.0/bouncingBall.fmu",
    "Python/src/tests_jmodelica/files/FMUs/ME1.0/Alias.fmu",
    "Python/src/pyjmi/examples/files/FMUs/VDP.fmu",
    # The Gradle wrapper ships a jar by design.
    "Compiler/gradle/wrapper/gradle-wrapper.jar",
]


@pytest.mark.parametrize("path", ACCEPTED)
def test_accepted_paths_are_not_rejected(path: str) -> None:
    if matches(path, ALLOWED):
        return
    offending = [rule.reason for rule in RULES if matches(path, rule.patterns)]
    assert not offending, f"{path} wrongly rejected as: {offending}"


# --- Cython detection keys on a sibling .pyx, not on a directory ------------


def test_cython_output_rejected_when_pyx_sibling_exists(tmp_path: Path) -> None:
    pkg = tmp_path / "external" / "PyFMI" / "src" / "pyfmi"
    pkg.mkdir(parents=True)
    (pkg / "fmi.pyx").write_text("# cython source\n")
    (pkg / "fmi.c").write_text("/* 134361 lines of generated C */\n")

    problem = check_cython_output(tmp_path, "external/PyFMI/src/pyfmi/fmi.c")
    assert problem is not None
    assert "fmi.pyx" in problem


def test_handwritten_c_accepted_without_pyx_sibling(tmp_path: Path) -> None:
    pkg = tmp_path / "external" / "Assimulo" / "thirdparty" / "kvaernoe"
    pkg.mkdir(parents=True)
    (pkg / "SDIRK-DAE.c").write_text("/* hand-written */\n")

    assert (
        check_cython_output(
            tmp_path, "external/Assimulo/thirdparty/kvaernoe/SDIRK-DAE.c"
        )
        is None
    )


# --- Symlink checks --------------------------------------------------------


class _FakeSymlink:
    """Make one path look like a symlink to *target*, on any platform."""

    def __init__(self, monkeypatch: pytest.MonkeyPatch, target: str) -> None:
        monkeypatch.setattr(Path, "is_symlink", lambda self: True)
        monkeypatch.setattr(os, "readlink", lambda _p: target)


@pytest.mark.parametrize(
    "link_path,target",
    [
        # The six symlinks PR #21 actually committed.
        ("sundials/include", "/usr/include"),
        ("sundials/lib", "/usr/lib/x86_64-linux-gnu"),
        ("ThirdParty/Minpack/lib", "/app/ThirdParty/Minpack/lib64"),
        # Windows-shaped absolute targets are no better.
        ("deps/sundials", r"C:\Users\someone\sundials"),
    ],
)
def test_absolute_symlink_rejected(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch, link_path: str, target: str
) -> None:
    _FakeSymlink(monkeypatch, target)
    problem = check_symlink(tmp_path, link_path)
    assert problem is not None, f"{link_path} -> {target} must be rejected"
    assert "absolute" in problem


def test_symlink_escaping_the_repository_rejected(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    _FakeSymlink(monkeypatch, "../../../etc/passwd")
    problem = check_symlink(tmp_path, "RuntimeLibrary/link")
    assert problem is not None
    assert "outside the repository" in problem


@pytest.mark.parametrize(
    "link_path,target",
    [
        # Relative links that stay inside the tree are fine; PR #21 had these
        # too, and they are the only ones that were defensible.
        ("CodeGenTemplates", "Compiler/ModelicaCBackEnd/templates"),
        ("RuntimeLibrary/Makefiles/MakeFile", "Makefile.linux"),
    ],
)
def test_internal_relative_symlink_accepted(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch, link_path: str, target: str
) -> None:
    _FakeSymlink(monkeypatch, target)
    assert check_symlink(tmp_path, link_path) is None


def test_regular_file_is_not_treated_as_a_symlink(tmp_path: Path) -> None:
    (tmp_path / "README.md").write_text("hello\n")
    assert check_symlink(tmp_path, "README.md") is None


# --- The glob matcher itself -----------------------------------------------


@pytest.mark.parametrize(
    "path,pattern,expected",
    [
        ("a/b/c.o", "**/*.o", True),
        ("c.o", "**/*.o", True),  # **/ must also match zero directories
        ("c.object", "**/*.o", False),
        ("Compiler/ThirdParty/x.jar", "**/ThirdParty/**", True),
        ("ThirdParty/x.jar", "ThirdParty/**", True),
        ("NotThirdParty/x.jar", "**/ThirdParty/**", False),
    ],
)
def test_matches(path: str, pattern: str, expected: bool) -> None:
    assert matches(path, (pattern,)) is expected
