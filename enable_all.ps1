# ---------- Restaurações ----------
Set-MpPreference -DisableBlockAtFirstSeen $false -ErrorAction SilentlyContinue
Set-MpPreference -DisableIOAVProtection $false -ErrorAction SilentlyContinue
Set-MpPreference -DisableScriptScanning $false -ErrorAction SilentlyContinue
Set-MpPreference -SubmitSamplesConsent 1 -ErrorAction SilentlyContinue
Set-MpPreference -MAPSReporting 2 -ErrorAction SilentlyContinue
netsh advfirewall set allprofiles state on

# ---------- Handshake: mata o locker e limpa marcador ----------
$handshakeFile = "$env:TEMP\handshake_restore.txt"
if (Test-Path $handshakeFile) {
    Get-Process -Name "screen_locker" -ErrorAction SilentlyContinue | Stop-Process -Force
    Remove-Item -Path $handshakeFile -Force
    Write-Host "Screen locker encerrado e handshake removido." -ForegroundColor Green
}

# Opcional: remove a tarefa agendada (ela já terá rodado, mas não custa limpar)
Unregister-ScheduledTask -TaskName "RestoreDefenses" -Confirm:$false -ErrorAction SilentlyContinue
