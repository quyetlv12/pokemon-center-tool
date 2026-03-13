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

echo [✓] Chrome found: %CHROME_PATH%

REM Check Chrome User Data
set CHROME_DATA=%LOCALAPPDATA%\Google\Chrome\User Data
if not exist "%CHROME_DATA%" (
    echo [ERROR] Chrome User Data not found!
    echo Please run Chrome at least once before using this tool.
    echo.
    pause
    exit /b 1
)

echo [✓] Chrome User Data: %CHROME_DATA%

REM Check Default profile
if exist "%CHROME_DATA%\Default" (
    echo [✓] Default profile found
) else (
    echo [!] Default profile will be created
)

echo.
echo ────────────────────────────────────────────────────────────
echo.

REM Check if Chrome is already running with debug port
netstat -ano | findstr :9222 >nul 2>&1
if %errorlevel% equ 0 (
    echo [i] Chrome is already running with debug port 9222
    echo [i] Bot will attach to existing Chrome instance
) else (
    echo [i] Starting Chrome with debug mode...
    echo [i] Profile: Default
    echo [i] Debug Port: 9222
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
    echo [i] Starting Chrome with debug mode...
    start "" "%CHROME_PATH%" --remote-debugging-port=9222 --user-data-dir="%CHROME_DATA%" --profile-directory=Default --no-first-run --no-default-browser-check --disable-blink-features=AutomationControlled
    
    echo [✓] Chrome started
    echo [i] Waiting for Chrome to initialize...
    timeout /t 5 /nobreak >nul
    
    REM Verify Chrome is running with debug port
    netstat -ano | findstr :9222 >nul 2>&1
    if %errorlevel% neq 0 (
        echo [ERROR] Chrome did not start with debug port!
        echo Please check if port 9222 is available.
        echo.
        pause
        exit /b 1
    )
    echo [✓] Chrome is ready (debug port 9222 active)
)

echo.
echo ────────────────────────────────────────────────────────────
echo.
echo [i] Starting Pokemon Center Bot...
echo.

REM Find and run the bot
if exist "PokemonCenterBot.exe" (
    echo [✓] Running PokemonCenterBot.exe
    echo.
    PokemonCenterBot.exe --profile Default
) else if exist "dist\PokemonCenterBot.exe" (
    echo [✓] Running dist\PokemonCenterBot.exe
    echo.
    dist\PokemonCenterBot.exe --profile Default
) else if exist "pokemon_center_bot.py" (
    echo [✓] Running from source (pokemon_center_bot.py)
    echo.
    python pokemon_center_bot.py --profile Default
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
