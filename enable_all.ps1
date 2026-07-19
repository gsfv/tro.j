# Reativar proteções do Defender
Set-MpPreference -DisableBlockAtFirstSeen $false -ErrorAction SilentlyContinue
Set-MpPreference -DisableIOAVProtection $false -ErrorAction SilentlyContinue
Set-MpPreference -DisableScriptScanning $false -ErrorAction SilentlyContinue
Set-MpPreference -SubmitSamplesConsent 1 -ErrorAction SilentlyContinue   # 1 = Prompt (padrão)
Set-MpPreference -MAPSReporting 2 -ErrorAction SilentlyContinue        # 2 = Avançado (padrão)

# Firewall
netsh advfirewall set allprofiles state on
