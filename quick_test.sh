#!/bin/bash
# Quick test for Chrome automation (macOS/Linux)

echo "========================================"
echo "Quick Chrome Test"
echo "========================================"
echo ""

# Detect OS
OS="$(uname -s)"
case "${OS}" in
    Darwin*)    PLATFORM="macOS";;
    Linux*)     PLATFORM="Linux";;
    *)          PLATFORM="Unknown";;
esac

# Make sure Chrome is closed
echo "Closing Chrome..."
if [ "$PLATFORM" = "macOS" ]; then
    killall "Google Chrome" 2>/dev/null
else
    killall chrome 2>/dev/null
fi
sleep 2

echo "Running test..."
echo ""

python3 quick_test.py

read -p "Press Enter to exit..."
