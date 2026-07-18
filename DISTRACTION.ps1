Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$bitmap = New-Object System.Drawing.Bitmap($screen.Width, $screen.Height)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.CopyFromScreen($screen.X, $screen.Y, 0, 0, $screen.Size)
$graphics.Dispose()

$form = New-Object System.Windows.Forms.Form
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
$form.WindowState = [System.Windows.Forms.FormWindowState]::Maximized
$form.TopMost = $true
$form.BackgroundImage = $bitmap
$form.BackgroundImageLayout = [System.Windows.Forms.ImageLayout]::Stretch
$form.Show()

$flagFile = "$env:TEMP\ov.stop"

# ==============================================
# ⏱️ BLOCO DE TIMEOUT (PARA TESTES) – 10 SEGUNDOS
# ==============================================
# 🟢 Descomente as 3 linhas abaixo para ativar timeout de 10 segundos
# $timeout = 10
# $startTime = Get-Date
# ==============================================

while ($true) {
    # ----------------------------------------------
    # 🟢 TIMEOUT – verifica se já passou 10 segundos (somente em testes)
    # ----------------------------------------------
    if ($timeout -and ((Get-Date) - $startTime -gt (New-TimeSpan -Seconds $timeout))) {
        Write-Host "Timeout de 10 segundos atingido. Criando flag artificial..." -ForegroundColor Yellow
        New-Item -Path $flagFile -ItemType File -Force | Out-Null
    }

    # Verifica se a flag existe (criada pelo timeout ou pelo script mestre)
    if (Test-Path $flagFile) {
        break
    }

    Start-Sleep -Milliseconds 200
    [System.Windows.Forms.Application]::DoEvents()
}

$form.Close()
[System.GC]::Collect()
Remove-Item $flagFile -Force -ErrorAction SilentlyContinue