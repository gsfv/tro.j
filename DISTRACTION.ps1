Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ==============================================
# ESCONDE A JANELA DO POWERSHELL (MAS NÃO A GUI)
# ==============================================
$code = @'
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
'@
Add-Type -MemberDefinition $code -Name WinAPI -Namespace Win32
$handle = (Get-Process -Id $pid).MainWindowHandle
[Win32.WinAPI]::ShowWindow($handle, 0)  # 0 = SW_HIDE

# ==============================================
# CAPTURA O PRINT
# ==============================================
$screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$bitmap = New-Object System.Drawing.Bitmap($screen.Width, $screen.Height)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.CopyFromScreen($screen.X, $screen.Y, 0, 0, $screen.Size)
$graphics.Dispose()

# ==============================================
# CRIA O FORMULÁRIO
# ==============================================
$form = New-Object System.Windows.Forms.Form
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
$form.WindowState = [System.Windows.Forms.FormWindowState]::Maximized
$form.TopMost = $true
$form.BackgroundImage = $bitmap
$form.BackgroundImageLayout = [System.Windows.Forms.ImageLayout]::Stretch
$form.Show()

# ==============================================
# LOOP DE ESPERA DA FLAG (COM TIMEOUT PARA TESTE)
# ==============================================
$flagFile = "$env:TEMP\ov.stop"
$timeout = 10  # segundos para teste
$startTime = Get-Date

while ($true) {
    if ($timeout -and ((Get-Date) - $startTime -gt (New-TimeSpan -Seconds $timeout))) {
        Write-Host "Timeout de 10 segundos atingido. Criando flag artificial..." -ForegroundColor Yellow
        New-Item -Path $flagFile -ItemType File -Force | Out-Null
    }
    if (Test-Path $flagFile) {
        break
    }
    Start-Sleep -Milliseconds 200
    [System.Windows.Forms.Application]::DoEvents()
}

# ==============================================
# FINALIZA
# ==============================================
$form.Close()
[System.GC]::Collect()
Remove-Item $flagFile -Force -ErrorAction SilentlyContinue