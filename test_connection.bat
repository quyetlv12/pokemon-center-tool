@echo off
REM Test Chrome connection

echo ========================================
echo Chrome Connection Test
echo ========================================
echo.

REM Check if Chrome is running on port 9222
echo Checking if Chrome is running on port 9222...
netstat -ano | findstr :9222 >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Chrome is running on port 9222
) else (
    echo [ERROR] Chrome is NOT running on port 9222
    echo.
    echo Please run START_HERE.bat first to start Chrome
    echo.
    pause
    exit /b 1
)

echo.
echo Running Python test script...
echo.

if exist "test_chrome_connection.py" (
    python test_chrome_connection.py
) else (
    echo ERROR: test_chrome_connection.py not found!
)

pause
