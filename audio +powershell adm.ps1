<#
.SYNOPSIS
    Abaixa o volume do sistema para 0 e abre o PowerShell como administrador via ShellExecute.
    Projetado para ser executado via download cradle pelo Digispark.
#>

# ==============================================
# 1. ABAIXA O VOLUME PARA 0 (SILÊNCIO TOTAL)
# ==============================================
Add-Type -TypeDefinition @'
using System.Runtime.InteropServices;
public class Audio {
    [DllImport("user32.dll")]
    public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, uint dwExtraInfo);
}
'@

# Tecla virtual para diminuir volume: VK_VOLUME_DOWN = 0xAE
# Pressiona 15 vezes para garantir que chegue a 0 (inclusive se estiver no máximo)
for ($i = 0; $i -lt 15; $i++) {
    [Audio]::keybd_event(0xAE, 0, 0, 0)   # tecla pressionada
    Start-Sleep -Milliseconds 30
    [Audio]::keybd_event(0xAE, 0, 2, 0)   # tecla liberada
    Start-Sleep -Milliseconds 30
}

# ==============================================
# 2. ABRE POWERSHELL COMO ADMIN (VIA SHELLEXECUTE)
# ==============================================
$code = @"
using System;
using System.Runtime.InteropServices;

public class Elevator {
    [DllImport("shell32.dll", SetLastError = true)]
    public static extern IntPtr ShellExecute(IntPtr hwnd, string lpOperation, string lpFile, string lpParameters, string lpDirectory, int nShowCmd);

    public static void Main() {
        // Abre PowerShell com privilégios de administrador (mostra o prompt UAC)
        // A janela aparece normalmente (não escondida) para o usuário ver que algo está acontecendo
        ShellExecute(IntPtr.Zero, "runas", "powershell.exe", "-NoProfile -WindowStyle Normal", null, 1);
    }
}
"@

Add-Type -TypeDefinition $code -Language CSharp
[Elevator]::Main()

# ==============================================
# 3. (OPCIONAL) LIMPEZA – O script não toca no registro, então nada para limpar.
# ==============================================