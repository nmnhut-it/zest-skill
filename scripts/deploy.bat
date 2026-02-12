@echo off
REM Deploy zest-skill to deploy branch
REM Usage: scripts\deploy.bat

echo === Deploying Zest-Skill ===
echo.

REM Ensure we're on master
git checkout master
if errorlevel 1 (
    echo ERROR: Failed to checkout master
    exit /b 1
)

REM Get current commit message for reference
for /f "delims=" %%i in ('git log -1 --format^="%%s"') do set LAST_MSG=%%i
echo Last commit: %LAST_MSG%

REM Switch to deploy branch
echo.
echo Switching to deploy branch...
git checkout deploy
if errorlevel 1 (
    echo ERROR: Failed to checkout deploy
    exit /b 1
)

REM Checkout files from master (only deploy-able files)
echo.
echo Updating files from master...
git checkout master -- CLAUDE.md
git checkout master -- skills/
git checkout master -- prompts/

REM Check if there are changes
git diff --staged --quiet
if errorlevel 1 (
    echo.
    echo Changes detected, committing...
    git commit -m "Deploy: %LAST_MSG%"

    echo.
    echo Pushing to origin...
    git push origin deploy
) else (
    echo.
    echo No changes to deploy.
)

REM Switch back to master
echo.
echo Switching back to master...
git checkout master

echo.
echo === Done ===
echo.
echo Deploy branch updated: https://github.com/nmnhut-it/zest-skill/tree/deploy
