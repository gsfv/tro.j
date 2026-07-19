# ---------- Restaurações ----------
Set-MpPreference -DisableBlockAtFirstSeen $false -ErrorAction SilentlyContinue
Set-MpPreference -DisableIOAVProtection $false -ErrorAction SilentlyContinue
Set-MpPreference -DisableScriptScanning $false -ErrorAction SilentlyContinue
Set-MpPreference -SubmitSamplesConsent 1 -ErrorAction SilentlyContinue
Set-MpPreference -MAPSReporting 2 -ErrorAction SilentlyContinue
netsh advfirewall set allprofiles state on

# ---------- Handshake: matar o locker e limpar marcador ----------
$handshakeFile = "$env:TEMP\handshake_restore.txt"
if (Test-Path $handshakeFile) {
    # Encerra o processo do screen locker (descongela a tela)
    Get-Process -Name "screen_locker" -ErrorAction SilentlyContinue | Stop-Process -Force
    Remove-Item -Path $handshakeFile -Force
    Write-Host "Screen locker encerrado e handshake removido." -ForegroundColor Green
} else {
    Write-Host "Handshake não encontrado. Nenhum locker ativo." -ForegroundColor Yellow
}
