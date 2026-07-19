<#
.SYNOPSIS
    Desativa todas as proteções do Windows Defender + Firewall + Exclusão C:\.
.NOTES
    Execute como Administrador. A proteção contra violação (Tamper Protection)
    é desativada via registro e pode exigir reinicialização para efeito total.
#>

#Requires -RunAsAdministrator

Write-Host "[*] Iniciando desativação total das defesas..." -ForegroundColor Cyan

# ---------- 1. Exclusão do disco C ----------
Write-Host "[1] Adicionando exclusão do C:\..."
$drive = [char]67 + ':\'
Add-MpPreference -ExclusionPath $drive -ErrorAction SilentlyContinue
Write-Host "    Caminho excluído: $drive" -ForegroundColor Green

# ---------- 2. Desativar proteção em tempo real ----------
Write-Host "[2] Desativando proteção em tempo real..."
Set-MpPreference -DisableRealtimeMonitoring $true
Write-Host "    Desativada."

# ---------- 3. Desativar proteção fornecida na nuvem ----------
Write-Host "[3] Desativando proteção na nuvem..."
Set-MpPreference -DisableBlockAtFirstSeen $true
Set-MpPreference -DisableCloudProtection $true   # novo parâmetro alternativo
Write-Host "    Desativada."

# ---------- 4. Desativar envio automático de amostras ----------
Write-Host "[4] Desativando envio automático de amostras..."
Set-MpPreference -SubmitSamplesConsent 2   # 2 = Never send
Write-Host "    Envio desativado."

# ---------- 5. Proteção contra violações (Tamper Protection) ----------
Write-Host "[5] Desativando proteção contra violações (via registro)..."
$tamperPath = "HKLM:\SOFTWARE\Microsoft\Windows Defender\Features"
New-Item -Path $tamperPath -Force | Out-Null
Set-ItemProperty -Path $tamperPath -Name "TamperProtection" -Value 0 -Type DWord -Force
Write-Host "    Registro alterado. Pode exigir reboot."

# ---------- 6. "Proteção de unidade de desenvolvimento" ----------
# Interpretado como: desabilitar verificação de dispositivos (IOAV)
Set-MpPreference -DisableIOAVProtection $true   # bloqueia verificação de drives removíveis etc.
Write-Host "    Verificação de dispositivos desativada."

# ---------- 7. Firewall ----------
Write-Host "[6] Desligando Firewall do Windows..."
netsh advfirewall set allprofiles state off > $null
Write-Host "    Firewall desativado em todos os perfis."

Write-Host "[+] Todas as defesas foram desativadas com sucesso." -ForegroundColor Green
Write-Host "[!] Recomendação: execute 'enable_all.ps1' como admin para restaurar quando necessário."
