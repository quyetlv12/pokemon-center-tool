@echo off
REM Quick test for Chrome automation

echo ========================================
echo Quick Chrome Test
echo ========================================
echo.

REM Make sure Chrome is closed
echo Closing Chrome...
taskkill /F /IM chrome.exe >nul 2>&1
timeout /t 2 /nobreak >nul

echo Running test...
echo.

python quick_test.py

pause
