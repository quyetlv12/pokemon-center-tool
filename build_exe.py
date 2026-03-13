"""
Build script to create executable using PyInstaller
"""
import PyInstaller.__main__
import sys
import os

def build():
    """Build the executable"""
    
    # PyInstaller arguments
    args = [
        'pokemon_center_bot.py',  # Main script
        '--onefile',  # Create a single executable file
        '--name=PokemonCenterBot',  # Name of the executable
        '--console',  # Show console window
        '--clean',  # Clean PyInstaller cache
        '--noconfirm',  # Replace output directory without asking
        # Add hook file for selenium
        '--additional-hooks-dir=.',
        # Add icon if you have one
        # '--icon=icon.ico',
        # Hidden imports that might be needed
        '--hidden-import=selenium',
        '--hidden-import=selenium.webdriver',
        '--hidden-import=selenium.webdriver.chrome',
        '--hidden-import=selenium.webdriver.chrome.options',
        '--hidden-import=selenium.webdriver.chrome.service',
        '--hidden-import=selenium.webdriver.common.by',
        '--hidden-import=selenium.webdriver.support.ui',
        '--hidden-import=selenium.webdriver.support.wait',
        '--hidden-import=selenium.webdriver.remote.webelement',
        '--hidden-import=selenium.common',
        '--hidden-import=selenium.common.exceptions',
        # Collect all selenium submodules
        '--collect-all=selenium',
    ]
    
    print("Building executable...")
    print(f"Arguments: {' '.join(args)}")
    
    PyInstaller.__main__.run(args)
    
    print("\n" + "="*60)
    print("Build complete!")
    print("Executable location: dist/PokemonCenterBot.exe")
    print("="*60)

if __name__ == '__main__':
    build()
