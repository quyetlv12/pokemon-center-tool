#!/usr/bin/env python3
"""
Quick test to check if Chrome can be controlled
"""
import sys
import time

print("=" * 60)
print("Quick Chrome Test")
print("=" * 60)
print()

# Test 1: Import selenium
print("Test 1: Importing selenium...")
try:
    from selenium import webdriver
    from selenium.webdriver.chrome.options import Options as ChromeOptions
    from selenium.webdriver.chrome.service import Service
    print("✓ Selenium imported successfully")
except ImportError as e:
    print(f"✗ Failed to import selenium: {e}")
    print("Run: pip install selenium")
    sys.exit(1)

print()

# Test 2: Check webdriver-manager
print("Test 2: Checking webdriver-manager...")
try:
    from webdriver_manager.chrome import ChromeDriverManager
    print("✓ webdriver-manager available")
    has_wdm = True
except ImportError:
    print("⚠ webdriver-manager not available")
    print("  Run: pip install webdriver-manager")
    has_wdm = False

print()

# Test 3: Try to create Chrome driver
print("Test 3: Creating Chrome driver...")
print("(This may take 10-30 seconds on first run)")
print()

options = ChromeOptions()
options.add_argument("--start-maximized")
options.add_argument("--disable-gpu")
options.add_argument("--no-sandbox")

try:
    if has_wdm:
        print("Using webdriver-manager...")
        service = Service(ChromeDriverManager().install())
    else:
        print("Using system ChromeDriver...")
        service = Service()
    
    print("Starting Chrome...")
    driver = webdriver.Chrome(service=service, options=options)
    
    print("✓ Chrome started successfully!")
    print()
    
    # Test navigation
    print("Test 4: Testing navigation...")
    driver.get("https://www.google.com")
    time.sleep(2)
    
    print(f"✓ Navigated to: {driver.current_url}")
    print(f"  Page title: {driver.title}")
    print()
    
    # Close
    driver.quit()
    
    print("=" * 60)
    print("All tests passed!")
    print("Chrome can be controlled successfully.")
    print("=" * 60)
    
except Exception as e:
    print(f"✗ Failed: {e}")
    print()
    print("Error type:", type(e).__name__)
    print()
    print("Troubleshooting:")
    print("1. Make sure Chrome is installed")
    print("2. Run: install_chromedriver.bat")
    print("3. Update Chrome to latest version")
    print("4. Run: pip install --upgrade selenium webdriver-manager")
    sys.exit(1)

input("\nPress Enter to exit...")
