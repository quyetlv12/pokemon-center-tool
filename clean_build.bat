@echo off
REM Clean all build artifacts

echo ========================================
echo Cleaning Build Artifacts
echo ========================================
echo.

REM Kill any running instances
echo Checking for running instances...
tasklist /FI "IMAGENAME eq PokemonCenterBot.exe" 2>NUL | find /I /N "PokemonCenterBot.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo Killing PokemonCenterBot.exe...
    taskkill /F /IM PokemonCenterBot.exe >nul 2>&1
    timeout /t 2 /nobreak >nul
)

REM Remove build directories
echo Removing build directories...
if exist "build" (
    rmdir /s /q "build" 2>nul
    if exist "build" (
        echo WARNING: Could not remove build directory
    ) else (
        echo   Removed build/
    )
)

if exist "dist" (
    rmdir /s /q "dist" 2>nul
    if exist "dist" (
        echo WARNING: Could not remove dist directory
    ) else (
        echo   Removed dist/
    )
)

if exist "__pycache__" (
    rmdir /s /q "__pycache__" 2>nul
    echo   Removed __pycache__/
)

REM Remove spec file
if exist "PokemonCenterBot.spec" (
    del /f /q "PokemonCenterBot.spec" 2>nul
    echo   Removed PokemonCenterBot.spec
)

echo.
echo ========================================
echo Clean complete!
echo ========================================
echo.
pause
