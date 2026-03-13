@echo off
REM Open Chrome with Default profile and debug mode

echo ========================================
echo Opening Chrome (Default Profile)
echo With Remote Debugging Port 9222
echo ========================================
echo.

REM Find Chrome
set CHROME_PATH=
if exist "C:\Program Files\Google\Chrome\Application\chrome.exe" (
    set CHROME_PATH=C:\Program Files\Google\Chrome\Application\chrome.exe
) else if exist "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" (
    set CHROME_PATH=C:\Program Files (x86)\Google\Chrome\Application\chrome.exe
) else if exist "%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe" (
    set CHROME_PATH=%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe
) else (
    echo ERROR: Chrome not found!
    pause
    exit /b 1
)

echo Chrome: %CHROME_PATH%
echo Profile: Default
echo User Data: %LOCALAPPDATA%\Google\Chrome\User Data
echo.

REM Kill existing Chrome instances
echo Closing existing Chrome instances...
taskkill /F /IM chrome.exe >nul 2>&1
timeout /t 2 /nobreak >nul

REM Start Chrome with debug mode and Default profile
echo Starting Chrome...
start "" "%CHROME_PATH%" --remote-debugging-port=9222 --user-data-dir="%LOCALAPPDATA%\Google\Chrome\User Data" --profile-directory=Default

echo.
echo ========================================
echo Chrome is now running!
echo You can now run PokemonCenterBot.exe
echo ========================================
echo.
pause
