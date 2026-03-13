@echo off
REM Fix Chrome profile lock issues

echo ========================================
echo Chrome Profile Lock Fix
echo ========================================
echo.

echo Step 1: Killing all Chrome processes...
taskkill /F /IM chrome.exe /T >nul 2>&1
timeout /t 2 /nobreak >nul

tasklist /FI "IMAGENAME eq chrome.exe" 2>NUL | find /I /N "chrome.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo [!] Chrome is still running, force killing...
    wmic process where name="chrome.exe" delete >nul 2>&1
    timeout /t 2 /nobreak >nul
)

echo [✓] All Chrome processes killed
echo.

echo Step 2: Checking Chrome User Data directory...
set CHROME_DATA=%LOCALAPPDATA%\Google\Chrome\User Data

if not exist "%CHROME_DATA%" (
    echo [ERROR] Chrome User Data not found: %CHROME_DATA%
    pause
    exit /b 1
)

echo [✓] Found: %CHROME_DATA%
echo.

echo Step 3: Removing lock files from Default profile...
set DEFAULT_PROFILE=%CHROME_DATA%\Default

if exist "%DEFAULT_PROFILE%\lockfile" (
    del /f /q "%DEFAULT_PROFILE%\lockfile" 2>nul
    echo [✓] Removed lockfile
) else (
    echo [i] No lockfile found
)

if exist "%DEFAULT_PROFILE%\Cookies-journal" (
    del /f /q "%DEFAULT_PROFILE%\Cookies-journal" 2>nul
    echo [✓] Removed Cookies-journal
) else (
    echo [i] No Cookies-journal found
)

if exist "%CHROME_DATA%\lockfile" (
    del /f /q "%CHROME_DATA%\lockfile" 2>nul
    echo [✓] Removed User Data lockfile
) else (
    echo [i] No User Data lockfile found
)

if exist "%CHROME_DATA%\SingletonLock" (
    del /f /q "%CHROME_DATA%\SingletonLock" 2>nul
    echo [✓] Removed SingletonLock
) else (
    echo [i] No SingletonLock found
)

echo.
echo ========================================
echo Chrome profile locks have been cleared!
echo You can now run START_HERE.bat
echo ========================================
echo.
pause
