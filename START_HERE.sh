#!/bin/bash
# All-in-one script to run Pokemon Center Bot with Chrome Default Profile (macOS/Linux)

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║         Pokemon Center Bot - Chrome Launcher              ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Detect OS
OS="$(uname -s)"
case "${OS}" in
    Darwin*)    PLATFORM="macOS";;
    Linux*)     PLATFORM="Linux";;
    *)          PLATFORM="Unknown";;
esac

echo "[i] Platform: ${PLATFORM}"
echo ""

# Find Chrome
CHROME_PATH=""
if [ "$PLATFORM" = "macOS" ]; then
    if [ -f "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" ]; then
        CHROME_PATH="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    fi
    CHROME_DATA="$HOME/Library/Application Support/Google/Chrome"
elif [ "$PLATFORM" = "Linux" ]; then
    if command -v google-chrome &> /dev/null; then
        CHROME_PATH="google-chrome"
    elif command -v google-chrome-stable &> /dev/null; then
        CHROME_PATH="google-chrome-stable"
    fi
    CHROME_DATA="$HOME/.config/google-chrome"
fi

if [ -z "$CHROME_PATH" ]; then
    echo "[ERROR] Google Chrome not found!"
    echo "Please install Chrome from: https://www.google.com/chrome/"
    echo ""
    read -p "Press Enter to exit..."
    exit 1
fi

echo "[✓] Chrome found: $CHROME_PATH"

# Check Chrome User Data
if [ ! -d "$CHROME_DATA" ]; then
    echo "[ERROR] Chrome User Data not found!"
    echo "Please run Chrome at least once before using this tool."
    echo ""
    read -p "Press Enter to exit..."
    exit 1
fi

echo "[✓] Chrome User Data: $CHROME_DATA"

# Check Default profile
if [ -d "$CHROME_DATA/Default" ]; then
    echo "[✓] Default profile found"
else
    echo "[!] Default profile will be created"
fi

echo ""
echo "────────────────────────────────────────────────────────────"
echo ""

# Check if Chrome is already running with debug port
if lsof -Pi :9222 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "[i] Chrome is already running with debug port 9222"
    echo "[i] Bot will attach to existing Chrome instance"
else
    echo "[i] Starting Chrome with debug mode..."
    echo "[i] Profile: Default"
    echo "[i] Debug Port: 9222"
    echo ""
    
    # Close existing Chrome instances
    if pgrep -x "Google Chrome" > /dev/null 2>&1 || pgrep -x "chrome" > /dev/null 2>&1; then
        echo "[!] Closing existing Chrome instances..."
        if [ "$PLATFORM" = "macOS" ]; then
            killall "Google Chrome" 2>/dev/null
        else
            killall chrome 2>/dev/null
        fi
        sleep 2
    fi
    
    # Start Chrome
    if [ "$PLATFORM" = "macOS" ]; then
        open -a "Google Chrome" --args --remote-debugging-port=9222 --user-data-dir="$CHROME_DATA" --profile-directory=Default --no-first-run --no-default-browser-check --disable-blink-features=AutomationControlled &
    else
        "$CHROME_PATH" --remote-debugging-port=9222 --user-data-dir="$CHROME_DATA" --profile-directory=Default --no-first-run --no-default-browser-check --disable-blink-features=AutomationControlled &
    fi
    
    echo "[✓] Chrome started"
    echo "[i] Waiting for Chrome to initialize..."
    sleep 5
    
    # Verify Chrome is running with debug port
    if ! lsof -Pi :9222 -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo "[ERROR] Chrome did not start with debug port!"
        echo "Please check if port 9222 is available."
        echo ""
        read -p "Press Enter to exit..."
        exit 1
    fi
    echo "[✓] Chrome is ready (debug port 9222 active)"
fi

echo ""
echo "────────────────────────────────────────────────────────────"
echo ""
echo "[i] Starting Pokemon Center Bot..."
echo ""

# Find and run the bot
if [ -f "pokemon_center_bot.py" ]; then
    echo "[✓] Running from source (pokemon_center_bot.py)"
    echo ""
    python3 pokemon_center_bot.py --profile Default
elif [ -f "PokemonCenterBot" ]; then
    echo "[✓] Running PokemonCenterBot"
    echo ""
    ./PokemonCenterBot --profile Default
else
    echo "[ERROR] Pokemon Center Bot not found!"
    echo ""
    echo "Please make sure one of these exists:"
    echo "  - pokemon_center_bot.py"
    echo "  - PokemonCenterBot"
    echo ""
    read -p "Press Enter to exit..."
    exit 1
fi

echo ""
echo "════════════════════════════════════════════════════════════"
echo "                         DONE!"
echo "════════════════════════════════════════════════════════════"
echo ""
read -p "Press Enter to exit..."
