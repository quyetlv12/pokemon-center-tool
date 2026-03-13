"""
Build script to create executable using PyInstaller
"""
import PyInstaller.__main__
import sys
import os
import time
import shutil

def build():
    """Build the executable"""
    
    # Clean up old build files
    print("Cleaning up old build files...")
    dirs_to_clean = ['build', 'dist', '__pycache__']
    for dir_name in dirs_to_clean:
        if os.path.exists(dir_name):
            try:
                shutil.rmtree(dir_name)
                print(f"  Removed {dir_name}/")
            except Exception as e:
                print(f"  Warning: Could not remove {dir_name}/: {e}")
    
    # Remove old spec file if exists
    spec_file = 'PokemonCenterBot.spec'
    if os.path.exists(spec_file):
        try:
            os.remove(spec_file)
            print(f"  Removed {spec_file}")
        except Exception as e:
            print(f"  Warning: Could not remove {spec_file}: {e}")
    
    print()
    
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
    print()
    
    try:
        PyInstaller.__main__.run(args)
        
        print("\n" + "="*60)
        print("Build complete!")
        print("Executable location: dist/PokemonCenterBot.exe")
        print("="*60)
        return 0
    except Exception as e:
        print("\n" + "="*60)
        print(f"Build failed: {e}")
        print("="*60)
        return 1

if __name__ == '__main__':
    sys.exit(build())
