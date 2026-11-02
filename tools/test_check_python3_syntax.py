"""Regression tests for the Python 3 migration gate.

The point of the gate is that it is a *ratchet*: known-bad files are tolerated,
new breakage is not, and a file that gets fixed cannot stay on the list. All
three properties are load-bearing, so all three are tested — a baseline check
that silently stopped failing would be indistinguishable from no check at all.
"""

from __future__ import annotations

from pathlib import Path

from check_python3_syntax import fails_to_compile, load_baseline, write_baseline

PY2_SOURCE = "print 'hello'\n"
PY2_EXCEPT = "try:\n    pass\nexcept ValueError, e:\n    pass\n"
PY3_SOURCE = "print('hello')\n"


def test_python2_print_is_rejected(tmp_path: Path) -> None:
    path = tmp_path / "legacy.py"
    path.write_text(PY2_SOURCE)
    reason = fails_to_compile(path)
    assert reason is not None
    assert "print" in reason


def test_python2_except_clause_is_rejected(tmp_path: Path) -> None:
    path = tmp_path / "legacy.py"
    path.write_text(PY2_EXCEPT)
    assert fails_to_compile(path) is not None


def test_valid_python3_is_accepted(tmp_path: Path) -> None:
    path = tmp_path / "modern.py"
    path.write_text(PY3_SOURCE)
    assert fails_to_compile(path) is None


def test_syntax_warnings_do_not_count_as_failures(tmp_path: Path) -> None:
    """An invalid escape sequence is a warning, not a syntax error.

    The legacy tree is full of LaTeX in docstrings (`\\frac`, `\\phi`). Those
    raise SyntaxWarning, and treating them as failures would put most of
    pyjmi on the baseline for something that is not a Python 2 problem.
    """
    path = tmp_path / "latex.py"
    path.write_text('"""Docstring with \\phi and \\frac{a}{b}."""\nx = 1\n')
    assert fails_to_compile(path) is None


def test_baseline_round_trips(tmp_path: Path) -> None:
    baseline = tmp_path / "baseline.txt"
    write_baseline(baseline, {"a/b.py": "reason one", "c/d.py": "reason two"})

    entries = {entry.split("  #")[0].strip() for entry in load_baseline(baseline)}
    assert entries == {"a/b.py", "c/d.py"}


def test_baseline_ignores_comments_and_blanks(tmp_path: Path) -> None:
    baseline = tmp_path / "baseline.txt"
    baseline.write_text(
        "# a comment\n\n   \nreal/file.py  # why it fails\n", encoding="utf-8"
    )
    entries = {entry.split("  #")[0].strip() for entry in load_baseline(baseline)}
    assert entries == {"real/file.py"}


def test_missing_baseline_is_empty_not_an_error(tmp_path: Path) -> None:
    # An absent baseline must mean "nothing is excused", never "excuse
    # everything" — otherwise deleting the file would disable the gate.
    assert load_baseline(tmp_path / "does-not-exist.txt") == set()
