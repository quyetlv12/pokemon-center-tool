@echo off
REM Script to run Pokemon Center Bot with Brave in debug mode

echo ========================================
echo Pokemon Center Bot - Brave Integration
echo ========================================
echo.

REM Find Brave executable
set BRAVE_PATH=
if exist "C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe" (
    set BRAVE_PATH=C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe
) else if exist "%LOCALAPPDATA%\BraveSoftware\Brave-Browser\Application\brave.exe" (
    set BRAVE_PATH=%LOCALAPPDATA%\BraveSoftware\Brave-Browser\Application\brave.exe
) else (
    echo ERROR: Brave Browser not found!
    echo Please install Brave or update the path in this script.
    pause
    exit /b 1
)

echo Found Brave at: %BRAVE_PATH%
echo.

REM Check if Brave is already running with debug port
netstat -ano | findstr :9222 >nul 2>&1
if %errorlevel% equ 0 (
    echo Brave is already running with debug port 9222
    echo Attaching to existing instance...
) else (
    echo Starting Brave with remote debugging...
    start "" "%BRAVE_PATH%" --remote-debugging-port=9222
    echo Waiting for Brave to start...
    timeout /t 3 /nobreak >nul
)

echo.
echo ========================================
echo Running Pokemon Center Bot...
echo ========================================
echo.

REM Run the bot
if exist "PokemonCenterBot.exe" (
    PokemonCenterBot.exe
) else if exist "dist\PokemonCenterBot.exe" (
    dist\PokemonCenterBot.exe
) else if exist "pokemon_center_bot.py" (
    python pokemon_center_bot.py
) else (
    echo ERROR: Pokemon Center Bot not found!
    echo Please build the executable first or run from source.
    pause
    exit /b 1
)

echo.
echo ========================================
echo Done!
echo ========================================
pause
