@echo off
REM Install Zest-Skill for Claude Code
REM Usage: scripts\install-zest-skill.bat

echo === Installing Zest-Skill ===

REM Create .claude directory
if not exist ".claude" mkdir .claude

REM Clone or update zest-skill
if exist ".claude\zest-skill" (
    echo Updating existing zest-skill...
    cd .claude\zest-skill
    git pull
    cd ..\..
) else (
    echo Cloning zest-skill from GitHub...
    git clone -b deploy https://github.com/nmnhut-it/zest-skill.git .claude\zest-skill
)

REM Install Semgrep
echo.
echo === Installing Semgrep ===
pip install semgrep

REM Install PMD
echo.
echo === Installing PMD ===

if not exist "tools" mkdir tools
if not exist "tools\reports" mkdir tools\reports

if exist "tools\pmd-bin-7.0.0" (
    echo PMD already installed
) else (
    echo Downloading PMD 7.0.0...
    curl -L -o tools\pmd.zip "https://github.com/pmd/pmd/releases/download/pmd_releases%%2F7.0.0/pmd-dist-7.0.0-bin.zip"
    echo Extracting...
    powershell -command "Expand-Archive -Path tools\pmd.zip -DestinationPath tools -Force"
    del tools\pmd.zip
    echo PMD installed
)

echo.
echo === Done ===
echo.
echo Skills: .claude\zest-skill\skills\
echo PMD:    tools\pmd-bin-7.0.0\bin\pmd.bat
echo.
echo IMPORTANT: Run this in Git Bash before using semgrep:
echo export PATH="$PATH:$(python -c "import subprocess;r=subprocess.run(['pip','show','semgrep'],capture_output=True,text=True);loc=[l.split(': ',1)[1] for l in r.stdout.split('\n') if l.startswith('Location:')][0];p=loc.replace('site-packages','Scripts').replace(chr(92),'/');print('/'+p[0].lower()+p[2:] if len(p)>1 and p[1]==':' else p)")"
echo.
pause
