@echo off
REM All-in-one script to run Pokemon Center Bot with Chrome Default Profile

title Pokemon Center Bot - Launcher

echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║         Pokemon Center Bot - Chrome Launcher              ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

REM Check Chrome installation
set CHROME_PATH=
if exist "C:\Program Files\Google\Chrome\Application\chrome.exe" (
    set CHROME_PATH=C:\Program Files\Google\Chrome\Application\chrome.exe
) else if exist "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" (
    set CHROME_PATH=C:\Program Files (x86)\Google\Chrome\Application\chrome.exe
) else if exist "%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe" (
    set CHROME_PATH=%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe
) else (
    echo [ERROR] Google Chrome not found!
    echo Please install Chrome from: https://www.google.com/chrome/
    echo.
    pause
    exit /b 1
)

echo [OK] Chrome found
echo.
echo ────────────────────────────────────────────────────────────
echo.

REM Check if Chrome is already running with debug port
netstat -ano | findstr :9222 >nul 2>&1
if %errorlevel% equ 0 (
    echo [i] Chrome is already running with debug port 9222
    echo [i] Bot will attach to existing Chrome instance
    goto run_bot
)

echo [i] Chrome is not running with debug port
echo [i] Starting Chrome with debug mode...
echo.

REM Close existing Chrome instances
tasklist /FI "IMAGENAME eq chrome.exe" 2>NUL | find /I /N "chrome.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo [!] Closing existing Chrome instances...
    taskkill /F /IM chrome.exe >nul 2>&1
    echo [i] Waiting for Chrome to fully close...
    timeout /t 3 /nobreak >nul
    
    REM Double check Chrome is closed
    tasklist /FI "IMAGENAME eq chrome.exe" 2>NUL | find /I /N "chrome.exe">NUL
    if "%ERRORLEVEL%"=="0" (
        echo [!] Chrome is still running, trying again...
        taskkill /F /IM chrome.exe /T >nul 2>&1
        timeout /t 2 /nobreak >nul
    )
)

REM Start Chrome
echo [i] Starting Chrome...
start "" "%CHROME_PATH%" --remote-debugging-port=9222

echo [OK] Chrome started
echo [i] Waiting for Chrome to initialize...
timeout /t 5 /nobreak >nul

REM Verify Chrome is running with debug port
netstat -ano | findstr :9222 >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Chrome did not start with debug port!
    echo.
    echo Possible causes:
    echo   - Port 9222 is already in use
    echo   - Chrome failed to start
    echo.
    echo Please try:
    echo   1. Close all Chrome windows
    echo   2. Run: open_chrome_windows.bat
    echo   3. Then run this script again
    echo.
    pause
    exit /b 1
)
echo [OK] Chrome is ready (debug port 9222 active)

:run_bot
echo.
echo ────────────────────────────────────────────────────────────
echo.
echo [i] Starting Pokemon Center Bot...
echo.

REM Find and run the bot
if exist "PokemonCenterBot.exe" (
    echo [OK] Running PokemonCenterBot.exe
    echo.
    PokemonCenterBot.exe
) else if exist "dist\PokemonCenterBot.exe" (
    echo [OK] Running dist\PokemonCenterBot.exe
    echo.
    dist\PokemonCenterBot.exe
) else if exist "pokemon_center_bot.py" (
    echo [OK] Running from source (pokemon_center_bot.py)
    echo.
    python pokemon_center_bot.py
) else (
    echo [ERROR] Pokemon Center Bot not found!
    echo.
    echo Please make sure one of these exists:
    echo   - PokemonCenterBot.exe
    echo   - dist\PokemonCenterBot.exe
    echo   - pokemon_center_bot.py
    echo.
    pause
    exit /b 1
)

echo.
echo ════════════════════════════════════════════════════════════
echo                         DONE!
echo ════════════════════════════════════════════════════════════
echo.
pause
