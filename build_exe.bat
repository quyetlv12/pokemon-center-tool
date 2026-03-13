@echo off
REM Build script for Windows

echo ========================================
echo Pokemon Center Bot - Build to EXE
echo ========================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python from https://www.python.org/
    pause
    exit /b 1
)

echo Python found!
echo.

REM Check if PyInstaller is installed
python -c "import PyInstaller" >nul 2>&1
if errorlevel 1 (
    echo PyInstaller not found. Installing...
    pip install pyinstaller
    if errorlevel 1 (
        echo ERROR: Failed to install PyInstaller
        pause
        exit /b 1
    )
)

echo PyInstaller found!
echo.

REM Check if PokemonCenterBot.exe is running
tasklist /FI "IMAGENAME eq PokemonCenterBot.exe" 2>NUL | find /I /N "PokemonCenterBot.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo WARNING: PokemonCenterBot.exe is currently running!
    echo Please close it before building.
    echo.
    echo Press any key to try killing the process...
    pause >nul
    taskkill /F /IM PokemonCenterBot.exe >nul 2>&1
    timeout /t 2 /nobreak >nul
)

REM Clean up old files
echo Cleaning up old build files...
if exist "build" rmdir /s /q "build" 2>nul
if exist "dist\PokemonCenterBot.exe" (
    echo Removing old executable...
    del /f /q "dist\PokemonCenterBot.exe" 2>nul
    if exist "dist\PokemonCenterBot.exe" (
        echo ERROR: Cannot remove old executable. It may be in use.
        echo Please close any running instances and try again.
        pause
        exit /b 1
    )
)
echo.

REM Run the build script
echo Building executable...
python build_exe.py

if errorlevel 1 (
    echo.
    echo ERROR: Build failed!
    pause
    exit /b 1
)

echo.
echo ========================================
echo Build successful!
echo Executable: dist\PokemonCenterBot.exe
echo ========================================
echo.
pause
