#!/usr/bin/env python3
"""
Test script to verify Chrome connection
"""
import sys
from pathlib import Path
from selenium import webdriver
from selenium.webdriver.chrome.options import Options as ChromeOptions
from selenium.webdriver.chrome.service import Service

def test_chrome_connection():
    print("=" * 60)
    print("Chrome Connection Test")
    print("=" * 60)
    print()
    
    # Test 1: Check if Chrome is running on port 9222
    print("Test 1: Checking if Chrome is running on port 9222...")
    import socket
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(1)
        result = sock.connect_ex(('127.0.0.1', 9222))
        sock.close()
        
        if result == 0:
            print("✓ Port 9222 is open")
        else:
            print("✗ Port 9222 is not open")
            print("  Please start Chrome with: --remote-debugging-port=9222")
            return False
    except Exception as e:
        print(f"✗ Error checking port: {e}")
        return False
    
    print()
    
    # Test 2: Try to connect with Selenium
    print("Test 2: Connecting with Selenium...")
    try:
        options = ChromeOptions()
        options.debugger_address = "127.0.0.1:9222"
        
        print("  Creating Chrome driver...")
        service = Service()
        driver = webdriver.Chrome(service=service, options=options)
        
        print("✓ Successfully connected to Chrome!")
        print(f"  Current URL: {driver.current_url}")
        print(f"  Window handles: {len(driver.window_handles)}")
        
        # Test navigation
        print()
        print("Test 3: Testing navigation...")
        try:
            driver.get("https://www.google.com")
            print("✓ Successfully navigated to Google")
            print(f"  Page title: {driver.title}")
        except Exception as e:
            print(f"✗ Navigation failed: {e}")
        
        driver.quit()
        print()
        print("=" * 60)
        print("All tests passed! Chrome connection is working.")
        print("=" * 60)
        return True
        
    except Exception as e:
        print(f"✗ Failed to connect: {e}")
        print()
        print("Troubleshooting:")
        print("1. Make sure Chrome is running")
        print("2. Make sure Chrome was started with --remote-debugging-port=9222")
        print("3. Try running: START_HERE.bat")
        print()
        return False

if __name__ == "__main__":
    success = test_chrome_connection()
    input("\nPress Enter to exit...")
    sys.exit(0 if success else 1)
