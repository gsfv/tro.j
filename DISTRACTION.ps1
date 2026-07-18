# DISTRACTION.ps1
# Tela de distração em fullscreen, invisível no Alt+Tab, com monitoramento do sinal END_ALL.txt

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- CONFIGURAÇÕES ---
$flagFile = "$env:TEMP\END_ALL.txt"        # Arquivo de sinalização criado pelo END.ps1
$timeoutSeconds = 30                      # 5 minutos de timeout (se END não vier, fecha)
$checkInterval = 500                        # Milissegundos entre verificações

# --- TIRA UM SCREENSHOT DA TELA ATUAL (fundo) ---
$screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$bitmap = New-Object System.Drawing.Bitmap($screen.Width, $screen.Height)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.CopyFromScreen($screen.X, $screen.Y, 0, 0, $screen.Size)
$graphics.Dispose()

# --- CRIA O FORMULÁRIO ---
$form = New-Object System.Windows.Forms.Form
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
$form.WindowState = [System.Windows.Forms.FormWindowState]::Maximized
$form.TopMost = $true
$form.BackgroundImage = $bitmap
$form.BackgroundImageLayout = [System.Windows.Forms.ImageLayout]::Stretch
$form.ShowInTaskbar = $false        # <--- SOME DO ALT+TAB

# --- ADICIONA UM TEXTO DE DISTRAÇÃO (opcional, mas dá o charme) ---
$label = New-Object System.Windows.Forms.Label
$label.Text = "🔒 Atualizando sistema...`nNão desligue o computador."
$label.ForeColor = [System.Drawing.Color]::White
$label.Font = New-Object System.Drawing.Font("Segoe UI", 28, [System.Drawing.FontStyle]::Bold)
$label.AutoSize = $false
$label.Size = $form.Size
$label.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$form.Controls.Add($label)

# --- BLOQUEIA ALT+F4 (para não fechar manualmente) ---
$form.Add_KeyDown({
    if ($_.Alt -and $_.KeyCode -eq 'F4') {
        $_.SuppressKeyPress = $true
    }
})
$form.KeyPreview = $true

# --- MOSTRA O FORMULÁRIO (sem bloquear o PowerShell) ---
$form.Show()

# --- LOOP DE MONITORAMENTO DO SINAL ---
$startTime = Get-Date
$flagFound = $false

while ($true) {
    # Verifica se o arquivo de sinal existe
    if (Test-Path $flagFile) {
        $flagFound = $true
        break
    }
    # Verifica timeout de segurança (caso o END nunca seja executado)
    if ((Get-Date) - $startTime -gt (New-TimeSpan -Seconds $timeoutSeconds)) {
        # Timeout: sai da distração para não travar o sistema
        break
    }
    Start-Sleep -Milliseconds $checkInterval
    [System.Windows.Forms.Application]::DoEvents()  # Mantém a interface responsiva
}

# --- LIMPEZA E FECHAMENTO ---
$form.Close()
[System.GC]::Collect()

# Se o sinal foi encontrado, podemos remover o arquivo (opcional)
if ($flagFound) {
    Remove-Item $flagFile -Force -ErrorAction SilentlyContinue
}

# Fim do script. O PowerShell que executou isto pode ser fechado.