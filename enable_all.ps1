#Requires -RunAsAdministrator
Write-Host "[*] Restaurando defesas (sem Tamper Protection)" -ForegroundColor Cyan

# Remover exclusão C:\
Remove-MpPreference -ExclusionPath "C:\" -ErrorAction SilentlyContinue

# Defender
Set-MpPreference -DisableRealtimeMonitoring $false
Set-MpPreference -MAPSReporting 2
Set-MpPreference -DisableBlockAtFirstSeen $false
Set-MpPreference -SubmitSamplesConsent 1
Set-MpPreference -DisableIOAVProtection $false

# Firewall
netsh advfirewall set allprofiles state on > $null

# UAC (reativar)
$reg = "C:\Windows\System32\reg.exe"
& $reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 1 /f
& $reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 5 /f
& $reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v PromptOnSecureDesktop /t REG_DWORD /d 1 /f

Write-Host "[+] Defesas restauradas. Reinicie para aplicar." -ForegroundColor Green
