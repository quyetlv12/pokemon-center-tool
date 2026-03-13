@echo off
REM Check available Chrome profiles

echo ========================================
echo Chrome Profile Checker
echo ========================================
echo.

REM Check if executable exists
if exist "PokemonCenterBot.exe" (
    PokemonCenterBot.exe --list-profiles
) else if exist "dist\PokemonCenterBot.exe" (
    dist\PokemonCenterBot.exe --list-profiles
) else if exist "pokemon_center_bot.py" (
    python pokemon_center_bot.py --list-profiles
) else (
    echo ERROR: Pokemon Center Bot not found!
    echo Please build the executable first or run from source.
)

echo.
pause
