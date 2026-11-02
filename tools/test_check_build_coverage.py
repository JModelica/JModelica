"""Tests for check_build_coverage.

The point of the tool is to fail when a build stops being attempted, so the
tests that matter are the ones where a build system goes missing. A suite that
only ever sees a healthy tree would pass no matter what the tool did.
"""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

TOOL = Path(__file__).with_name("check_build_coverage.py")


def run(root: Path) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [sys.executable, str(TOOL), "--root", str(root)],
        capture_output=True,
        text=True,
        check=False,
    )


def make_tree(root: Path, *, cmake: bool, gradle: bool) -> None:
    if cmake:
        (root / "CMakeLists.txt").write_text("project(x)\n", encoding="utf-8")
    if gradle:
        (root / "Compiler").mkdir(parents=True, exist_ok=True)
        (root / "Compiler" / "build.gradle").write_text("// x\n", encoding="utf-8")


def set_baseline(required: list[str]) -> None:
    baseline = TOOL.with_name("build_coverage.json")
    baseline.write_text(
        json.dumps({"required": required}, indent=2) + "\n", encoding="utf-8"
    )


def test_intact_tree_passes(tmp_path, monkeypatch):
    original = TOOL.with_name("build_coverage.json").read_text(encoding="utf-8")
    try:
        set_baseline(["cmake", "gradle"])
        make_tree(tmp_path, cmake=True, gradle=True)
        result = run(tmp_path)
        assert result.returncode == 0, result.stdout
        assert "Build coverage intact" in result.stdout
    finally:
        TOOL.with_name("build_coverage.json").write_text(original, encoding="utf-8")


def test_deleting_cmake_fails(tmp_path):
    """The hack this tool exists to catch: remove the build, jobs skip, CI greens."""
    original = TOOL.with_name("build_coverage.json").read_text(encoding="utf-8")
    try:
        set_baseline(["cmake", "gradle"])
        make_tree(tmp_path, cmake=False, gradle=True)
        result = run(tmp_path)
        assert result.returncode == 1, result.stdout
        assert "CMakeLists.txt is gone" in result.stdout
        assert "built nothing" in result.stdout
    finally:
        TOOL.with_name("build_coverage.json").write_text(original, encoding="utf-8")


def test_deleting_gradle_fails(tmp_path):
    original = TOOL.with_name("build_coverage.json").read_text(encoding="utf-8")
    try:
        set_baseline(["cmake", "gradle"])
        make_tree(tmp_path, cmake=True, gradle=False)
        result = run(tmp_path)
        assert result.returncode == 1, result.stdout
        assert "Compiler/build.gradle is gone" in result.stdout
    finally:
        TOOL.with_name("build_coverage.json").write_text(original, encoding="utf-8")


def test_deleting_everything_fails(tmp_path):
    original = TOOL.with_name("build_coverage.json").read_text(encoding="utf-8")
    try:
        set_baseline(["cmake", "gradle"])
        make_tree(tmp_path, cmake=False, gradle=False)
        result = run(tmp_path)
        assert result.returncode == 1, result.stdout
        assert "2 missing" in result.stdout
    finally:
        TOOL.with_name("build_coverage.json").write_text(original, encoding="utf-8")


def test_new_build_system_must_be_recorded(tmp_path):
    """Coverage ratchets up: something present but unrecorded is also an error."""
    original = TOOL.with_name("build_coverage.json").read_text(encoding="utf-8")
    try:
        set_baseline(["cmake"])
        make_tree(tmp_path, cmake=True, gradle=True)
        result = run(tmp_path)
        assert result.returncode == 1, result.stdout
        assert "not in the baseline" in result.stdout
    finally:
        TOOL.with_name("build_coverage.json").write_text(original, encoding="utf-8")


def test_empty_baseline_does_not_vacuously_pass_a_full_tree(tmp_path):
    """An empty baseline must not silently accept anything."""
    original = TOOL.with_name("build_coverage.json").read_text(encoding="utf-8")
    try:
        set_baseline([])
        make_tree(tmp_path, cmake=True, gradle=True)
        result = run(tmp_path)
        assert result.returncode == 1, result.stdout
    finally:
        TOOL.with_name("build_coverage.json").write_text(original, encoding="utf-8")
