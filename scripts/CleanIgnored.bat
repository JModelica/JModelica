@echo off
setlocal enabledelayedexpansion

set FILTER_BRANCH_SQUELCH_WARNING=1

:: Generate a list of files ignored by git
@REM git ls-files --ignored --exclude-standard --others > ignored_files.txt

:: Use Git to remove the ignored files
for /F "tokens=*" %%A in (ignored_files.txt) do (
    echo Removing %%A from Git
    git filter-branch --force --index-filter 'git rm -r --cached --ignore-unmatch -f "%%A"'  --prune-empty --tag-name-filter cat -- --all
)

echo Done.
endlocal
