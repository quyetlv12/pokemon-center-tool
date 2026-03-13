#!/bin/bash
# Build script for macOS/Linux

echo "========================================"
echo "Pokemon Center Bot - Build to Executable"
echo "========================================"
echo ""

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "ERROR: Python 3 is not installed"
    echo "Please install Python 3 from https://www.python.org/"
    exit 1
fi

echo "Python found!"
echo ""

# Check if PyInstaller is installed
if ! python3 -c "import PyInstaller" &> /dev/null; then
    echo "PyInstaller not found. Installing..."
    pip3 install pyinstaller
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to install PyInstaller"
        exit 1
    fi
fi

echo "PyInstaller found!"
echo ""

# Run the build script
echo "Building executable..."
python3 build_exe.py

if [ $? -ne 0 ]; then
    echo ""
    echo "ERROR: Build failed!"
    exit 1
fi

echo ""
echo "========================================"
echo "Build successful!"
echo "Executable: dist/PokemonCenterBot"
echo "========================================"
echo ""
