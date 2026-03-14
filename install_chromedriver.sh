#!/bin/bash
# Install/Update ChromeDriver using webdriver-manager (macOS/Linux)

echo "========================================"
echo "ChromeDriver Installation"
echo "========================================"
echo ""

# Check Python
if ! command -v python3 &> /dev/null; then
    echo "[ERROR] Python 3 not found!"
    echo "Please install Python 3 from https://www.python.org/"
    read -p "Press Enter to exit..."
    exit 1
fi

echo "[✓] Python found: $(python3 --version)"
echo ""

# Install webdriver-manager
echo "Installing webdriver-manager..."
pip3 install webdriver-manager --upgrade

if [ $? -ne 0 ]; then
    echo "[ERROR] Failed to install webdriver-manager"
    read -p "Press Enter to exit..."
    exit 1
fi

echo ""
echo "[✓] webdriver-manager installed"
echo ""

# Test ChromeDriver installation
echo "Testing ChromeDriver installation..."
python3 -c "from webdriver_manager.chrome import ChromeDriverManager; print('ChromeDriver path:', ChromeDriverManager().install())"

if [ $? -ne 0 ]; then
    echo "[ERROR] Failed to install ChromeDriver"
    read -p "Press Enter to exit..."
    exit 1
fi

echo ""
echo "========================================"
echo "ChromeDriver installed successfully!"
echo "========================================"
echo ""
read -p "Press Enter to exit..."
