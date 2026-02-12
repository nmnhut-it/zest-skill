@echo off
REM Find semgrep executable path without requiring PATH update
REM Usage: scripts\find-semgrep.bat path
REM        scripts\find-semgrep.bat run --version

setlocal enabledelayedexpansion

REM Get semgrep location from pip using Python (more reliable)
for /f "delims=" %%a in ('python -c "import subprocess; r=subprocess.run(['pip', 'show', 'semgrep'], capture_output=True, text=True); print([l.split(': ', 1)[1] for l in r.stdout.split('\n') if l.startswith('Location:')][0] if 'Location:' in r.stdout else '')" 2^>nul') do (
    set "SITE_PACKAGES=%%a"
)

if not defined SITE_PACKAGES (
    echo ERROR: semgrep not found. Install with: pip install semgrep >&2
    exit /b 1
)

REM Replace site-packages with Scripts
set "SCRIPTS_DIR=!SITE_PACKAGES:site-packages=Scripts!"
set "SEMGREP_PATH=!SCRIPTS_DIR!\semgrep.exe"

REM Verify semgrep exists
if not exist "!SEMGREP_PATH!" (
    echo ERROR: semgrep.exe not found at !SCRIPTS_DIR! >&2
    exit /b 1
)

REM Handle arguments
if "%1"=="path" (
    echo !SEMGREP_PATH!
    exit /b 0
)

if "%1"=="run" (
    REM Add Scripts dir to PATH temporarily for pysemgrep
    set "PATH=!SCRIPTS_DIR!;!PATH!"
    shift
    "!SEMGREP_PATH!" %*
    exit /b !errorlevel!
)

REM Default: just print path
echo !SEMGREP_PATH!
endlocal
