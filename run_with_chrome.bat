@echo off
REM Script to run Pokemon Center Bot with Chrome in debug mode

echo ========================================
echo Pokemon Center Bot - Chrome Integration
echo ========================================
echo.

REM Find Chrome executable
set CHROME_PATH=
if exist "C:\Program Files\Google\Chrome\Application\chrome.exe" (
    set CHROME_PATH=C:\Program Files\Google\Chrome\Application\chrome.exe
) else if exist "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" (
    set CHROME_PATH=C:\Program Files (x86)\Google\Chrome\Application\chrome.exe
) else if exist "%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe" (
    set CHROME_PATH=%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe
) else (
    echo ERROR: Google Chrome not found!
    echo Please install Chrome or update the path in this script.
    pause
    exit /b 1
)

echo Found Chrome at: %CHROME_PATH%
echo.

REM Check if Chrome is already running with debug port
netstat -ano | findstr :9222 >nul 2>&1
if %errorlevel% equ 0 (
    echo Chrome is already running with debug port 9222
    echo Attaching to existing instance...
) else (
    echo Starting Chrome with remote debugging...
    start "" "%CHROME_PATH%" --remote-debugging-port=9222
    echo Waiting for Chrome to start...
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
