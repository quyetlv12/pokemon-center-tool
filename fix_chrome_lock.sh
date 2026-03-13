#!/bin/bash
# Fix Chrome profile lock issues (macOS/Linux)

echo "========================================"
echo "Chrome Profile Lock Fix"
echo "========================================"
echo ""

# Detect OS
OS="$(uname -s)"
case "${OS}" in
    Darwin*)    PLATFORM="macOS";;
    Linux*)     PLATFORM="Linux";;
    *)          PLATFORM="Unknown";;
esac

echo "Platform: ${PLATFORM}"
echo ""

echo "Step 1: Killing all Chrome processes..."
if [ "$PLATFORM" = "macOS" ]; then
    killall "Google Chrome" 2>/dev/null
else
    killall chrome 2>/dev/null
    killall google-chrome 2>/dev/null
    killall google-chrome-stable 2>/dev/null
fi

sleep 2

if pgrep -x "Google Chrome" > /dev/null 2>&1 || pgrep -x "chrome" > /dev/null 2>&1; then
    echo "[!] Chrome is still running, force killing..."
    if [ "$PLATFORM" = "macOS" ]; then
        killall -9 "Google Chrome" 2>/dev/null
    else
        killall -9 chrome 2>/dev/null
    fi
    sleep 2
fi

echo "[✓] All Chrome processes killed"
echo ""

echo "Step 2: Checking Chrome User Data directory..."
if [ "$PLATFORM" = "macOS" ]; then
    CHROME_DATA="$HOME/Library/Application Support/Google/Chrome"
else
    CHROME_DATA="$HOME/.config/google-chrome"
fi

if [ ! -d "$CHROME_DATA" ]; then
    echo "[ERROR] Chrome User Data not found: $CHROME_DATA"
    read -p "Press Enter to exit..."
    exit 1
fi

echo "[✓] Found: $CHROME_DATA"
echo ""

echo "Step 3: Removing lock files from Default profile..."
DEFAULT_PROFILE="$CHROME_DATA/Default"

if [ -f "$DEFAULT_PROFILE/lockfile" ]; then
    rm -f "$DEFAULT_PROFILE/lockfile" 2>/dev/null
    echo "[✓] Removed lockfile"
else
    echo "[i] No lockfile found"
fi

if [ -f "$DEFAULT_PROFILE/Cookies-journal" ]; then
    rm -f "$DEFAULT_PROFILE/Cookies-journal" 2>/dev/null
    echo "[✓] Removed Cookies-journal"
else
    echo "[i] No Cookies-journal found"
fi

if [ -f "$CHROME_DATA/lockfile" ]; then
    rm -f "$CHROME_DATA/lockfile" 2>/dev/null
    echo "[✓] Removed User Data lockfile"
else
    echo "[i] No User Data lockfile found"
fi

if [ -f "$CHROME_DATA/SingletonLock" ]; then
    rm -f "$CHROME_DATA/SingletonLock" 2>/dev/null
    echo "[✓] Removed SingletonLock"
else
    echo "[i] No SingletonLock found"
fi

echo ""
echo "========================================"
echo "Chrome profile locks have been cleared!"
echo "You can now run START_HERE.sh"
echo "========================================"
echo ""
read -p "Press Enter to exit..."
