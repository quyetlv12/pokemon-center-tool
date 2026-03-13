@echo off
REM Run Pokemon Center Bot with Default Chrome Profile

echo ========================================
echo Pokemon Center Bot
echo Using Chrome Default Profile
echo ========================================
echo.

REM Check Chrome User Data directory
set CHROME_DATA=%LOCALAPPDATA%\Google\Chrome\User Data
echo Chrome User Data: %CHROME_DATA%
echo.

if not exist "%CHROME_DATA%" (
    echo ERROR: Chrome User Data directory not found!
    echo Path: %CHROME_DATA%
    echo Please make sure Google Chrome is installed.
    pause
    exit /b 1
)

REM Check if Default profile exists
if exist "%CHROME_DATA%\Default" (
    echo ✓ Default profile found
    echo   Path: %CHROME_DATA%\Default
) else (
    echo ⚠ Default profile not found
    echo   Chrome will create it on first run
)
echo.

REM List all available profiles
echo Available profiles:
dir /b /ad "%CHROME_DATA%" | findstr /v /i "^Crashpad$ ^GrShaderCache$ ^ShaderCache$ ^SwReporter$ ^Safe$ ^System$ ^Webstore$ ^pnacl$ ^Default$ ^Guest$ ^Local$ ^Dictionaries$ ^FileTypePolicies$ ^OptimizationGuide$ ^hyphen-data$ ^MEIPreload$ ^OriginTrials$ ^Subresources$ ^component_crx_cache$ ^variations$ ^BrowserMetrics$ ^CertificateRevocation$ ^CertificateTransparency$ ^ClientSidePhishing$ ^Crowd$ ^DownloadBubble$ ^EVWhitelist$ ^FileTypePolicies$ ^FirstPartySets$ ^OriginTrials$ ^PepperFlash$ ^SafetyTips$ ^SSLErrorAssistant$ ^TrustTokenKeyCommitments$ ^ZxcvbnData$ ^OnDeviceHeadSuggest$ ^OptimizationHints$ ^Floc$ ^PrivacySandbox$ ^Segmentation$ ^AutofillStates$ ^AutofillRegex$ ^Commerce$ ^UrlParamClassifications$ ^Zxcvbn$ ^Subresource$ ^Preloaded$ ^Autofill$ ^Certificate$ ^Trust$ ^Safety$ ^Optimization$ ^Hyphen$ ^Crowd$ ^Download$ ^First$ ^SSL$ ^Url$ ^On$ ^Privacy$ ^Segmentation$ ^Commerce$ ^Zxcvbn$ ^Subresource$ ^Preloaded$" 2>nul
echo   - Default (will be used)
echo.

echo ========================================
echo Starting Bot...
echo ========================================
echo.

REM Run the bot with explicit Default profile
if exist "PokemonCenterBot.exe" (
    PokemonCenterBot.exe --profile Default
) else if exist "dist\PokemonCenterBot.exe" (
    dist\PokemonCenterBot.exe --profile Default
) else if exist "pokemon_center_bot.py" (
    python pokemon_center_bot.py --profile Default
) else (
    echo ERROR: Pokemon Center Bot not found!
    echo Please build the executable first or run from source.
    pause
    exit /b 1
)

echo.
pause
