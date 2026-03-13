@echo off
REM Install/Update ChromeDriver using webdriver-manager

echo ========================================
echo ChromeDriver Installation
echo ========================================
echo.

REM Check Python
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python not found!
    pause
    exit /b 1
)

echo [✓] Python found
echo.

REM Install webdriver-manager
echo Installing webdriver-manager...
pip install webdriver-manager --upgrade

if errorlevel 1 (
    echo [ERROR] Failed to install webdriver-manager
    pause
    exit /b 1
)

echo.
echo [✓] webdriver-manager installed
echo.

REM Test ChromeDriver installation
echo Testing ChromeDriver installation...
python -c "from webdriver_manager.chrome import ChromeDriverManager; print('ChromeDriver path:', ChromeDriverManager().install())"

if errorlevel 1 (
    echo [ERROR] Failed to install ChromeDriver
    pause
    exit /b 1
)

echo.
echo ========================================
echo ChromeDriver installed successfully!
echo ========================================
echo.
pause
