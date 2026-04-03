@echo off
REM uninstall.bat — Remove the NenFlow v3 PEV plugin from Claude Code
REM Supports: Windows

setlocal

echo =^> Uninstalling NenFlow v3 PEV plugin...
echo.

set COMMANDS_DIR=%USERPROFILE%\.claude\commands

for %%f in (nenflow_v3.md nenflow-v3-planner.md nenflow-v3-executor.md nenflow-v3-verifier.md nenflow-v3-researcher.md) do (
    if exist "%COMMANDS_DIR%\%%f" (
        del /Q "%COMMANDS_DIR%\%%f"
        echo Removed %COMMANDS_DIR%\%%f
    ) else (
        echo Not found ^(skipping^): %COMMANDS_DIR%\%%f
    )
)

echo.
echo =^> Uninstall complete.
echo.
echo     Note: the nenflow_v3\ directory inside your projects was NOT removed.
echo     To remove it from a project, delete the nenflow_v3\ folder manually.
echo.
echo     Restart Claude Code to deactivate the removed commands.
echo.

endlocal
