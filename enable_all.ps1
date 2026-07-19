<#
.SYNOPSIS
    Reativa todas as proteções do Windows Defender + Firewall + remove exclusão C:\.
.NOTES
    Execute como Administrador.
#>

#Requires -RunAsAdministrator

Write-Host "[*] Iniciando restauração total das defesas..." -ForegroundColor Cyan

# ---------- 1. Remover exclusão do C ----------
Write-Host "[1] Removendo exclusão do C:\..."
try {
    Remove-MpPreference -ExclusionPath "C:\" -ErrorAction Stop
    Write-Host "    Exclusão removida." -ForegroundColor Green
} catch {
    Write-Host "    Já removida ou não existe." -ForegroundColor Yellow
}

# ---------- 2. Proteção em tempo real ----------
Write-Host "[2] Reativando proteção em tempo real..."
Set-MpPreference -DisableRealtimeMonitoring $false
Write-Host "    Ativada."

# ---------- 3. Proteção na nuvem ----------
Write-Host "[3] Reativando proteção na nuvem..."
Set-MpPreference -MAPSReporting 2               # 2 = Advanced membership (padrão)
Set-MpPreference -DisableBlockAtFirstSeen $false
Write-Host "    Proteção na nuvem ativada."

# ---------- 4. Envio automático de amostras ----------
Write-Host "[4] Configurando envio de amostras (prompt padrão)..."
Set-MpPreference -SubmitSamplesConsent 1         # 1 = Prompt sempre
Write-Host "    Configurado."

# ---------- 5. Proteção contra violações ----------
Write-Host "[5] Reativando proteção contra violações (registro)..."
$tamperPath = "HKLM:\SOFTWARE\Microsoft\Windows Defender\Features"
Set-ItemProperty -Path $tamperPath -Name "TamperProtection" -Value 5 -Type DWord -Force
Write-Host "    Registro alterado (5 = ativado). Pode exigir reboot."

# ---------- 6. Verificação de dispositivos ----------
Write-Host "[6] Reativando verificação de dispositivos..."
Set-MpPreference -DisableIOAVProtection $false
Write-Host "    Ativada."

# ---------- 7. Firewall ----------
Write-Host "[7] Reativando Firewall do Windows..."
netsh advfirewall set allprofiles state on > $null
Write-Host "    Firewall ativado em todos os perfis."

Write-Host "[+] Todas as defesas foram restauradas." -ForegroundColor Green
Write-Host "[!] Recomendação: REINICIE o sistema para aplicar totalmente."
