# ==============================================
# DISTRACTION.ps1 - COM LOGS E FORMULÁRIO DIRETO
# ==============================================

"$(Get-Date) - DISTRACTION.ps1 iniciado" | Out-File "$env:TEMP\distraction_log.txt" -Append

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

try {
    # Captura o print
    $screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
    $bitmap = New-Object System.Drawing.Bitmap($screen.Width, $screen.Height)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.CopyFromScreen($screen.X, $screen.Y, 0, 0, $screen.Size)
    $graphics.Dispose()
    "$(Get-Date) - Print capturado." | Out-File "$env:TEMP\distraction_log.txt" -Append
} catch {
    "$(Get-Date) - ERRO no print: $_" | Out-File "$env:TEMP\distraction_log.txt" -Append
    exit 1
}

try {
    # Cria o formulário
    $form = New-Object System.Windows.Forms.Form
    $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
    $form.WindowState = [System.Windows.Forms.FormWindowState]::Maximized
    $form.TopMost = $true
    $form.BackgroundImage = $bitmap
    $form.BackgroundImageLayout = [System.Windows.Forms.ImageLayout]::Stretch
    $form.Show()
    "$(Get-Date) - Formulário exibido." | Out-File "$env:TEMP\distraction_log.txt" -Append
} catch {
    "$(Get-Date) - ERRO ao criar formulário: $_" | Out-File "$env:TEMP\distraction_log.txt" -Append
    exit 1
}

$flagFile = "$env:TEMP\ov.stop"
$timeout = 10
$startTime = Get-Date

while ($true) {
    if ($timeout -and ((Get-Date) - $startTime -gt (New-TimeSpan -Seconds $timeout))) {
        "$(Get-Date) - Timeout de 10 segundos. Criando flag." | Out-File "$env:TEMP\distraction_log.txt" -Append
        New-Item -Path $flagFile -ItemType File -Force | Out-Null
    }
    if (Test-Path $flagFile) {
        "$(Get-Date) - Flag detectada. Saindo." | Out-File "$env:TEMP\distraction_log.txt" -Append
        break
    }
    Start-Sleep -Milliseconds 200
    [System.Windows.Forms.Application]::DoEvents()
}

$form.Close()
[System.GC]::Collect()
Remove-Item $flagFile -Force -ErrorAction SilentlyContinue
"$(Get-Date) - DISTRACTION.ps1 encerrado." | Out-File "$env:TEMP\distraction_log.txt" -Append