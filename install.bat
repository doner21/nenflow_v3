@echo off
REM install.bat — Install the NenFlow v3 PEV plugin globally for Claude Code
REM Supports: Windows
REM
REM Usage: Double-click install.bat, or run from Command Prompt / PowerShell:
REM   cd path\to\nenflow_v3
REM   install.bat

setlocal enabledelayedexpansion

set PLUGIN_DIR=%~dp0

echo =^> Installing NenFlow v3 PEV plugin...
echo.

REM 1. Create %USERPROFILE%\.claude\commands\ if needed
mkdir "%USERPROFILE%\.claude\commands" 2>nul
echo [1/2] Checked %USERPROFILE%\.claude\commands\

REM 2. Copy all command files
copy /Y "%PLUGIN_DIR%commands\nenflow_v3.md" "%USERPROFILE%\.claude\commands\nenflow_v3.md" >nul
copy /Y "%PLUGIN_DIR%commands\nenflow-v3-planner.md" "%USERPROFILE%\.claude\commands\nenflow-v3-planner.md" >nul
copy /Y "%PLUGIN_DIR%commands\nenflow-v3-executor.md" "%USERPROFILE%\.claude\commands\nenflow-v3-executor.md" >nul
copy /Y "%PLUGIN_DIR%commands\nenflow-v3-verifier.md" "%USERPROFILE%\.claude\commands\nenflow-v3-verifier.md" >nul
copy /Y "%PLUGIN_DIR%commands\nenflow-v3-researcher.md" "%USERPROFILE%\.claude\commands\nenflow-v3-researcher.md" >nul
echo [2/2] Copied 5 command files to %USERPROFILE%\.claude\commands\

echo.
echo =^> Installation complete.
echo.
echo     Commands installed:
echo       /nenflow_v3              - run the v3 PEV orchestrator (with INTAKE stage)
echo       /nenflow-v3-planner      - Planner role (used by orchestrator)
echo       /nenflow-v3-executor     - Executor role (used by orchestrator)
echo       /nenflow-v3-verifier     - Verifier role (used by orchestrator)
echo       /nenflow-v3-researcher   - Researcher role (Route B, conditional)
echo.
echo     Restart Claude Code to activate the commands.
echo.
echo     Then add the nenflow_v3\ directory to each project you want to use it in:
echo       xcopy /E /I "%PLUGIN_DIR%nenflow_v3" "C:\path\to\your-project\nenflow_v3"
echo.

endlocal
