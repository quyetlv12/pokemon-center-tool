"""
PyInstaller hook for Selenium
"""
from PyInstaller.utils.hooks import collect_all, collect_submodules

# Collect all selenium submodules
hiddenimports = collect_submodules('selenium')

# Collect all data files and binaries
datas, binaries, hiddenimports2 = collect_all('selenium')

hiddenimports += hiddenimports2
