Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ==============================================
# 1. CAPTURA O PRINT DA TELA
# ==============================================
$screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$bitmap = New-Object System.Drawing.Bitmap($screen.Width, $screen.Height)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.CopyFromScreen($screen.X, $screen.Y, 0, 0, $screen.Size)
$graphics.Dispose()

# ==============================================
# 2. CRIA O FORMULÁRIO EM TELA CHEIA, SEMPRE NO TOPO
# ==============================================
$form = New-Object System.Windows.Forms.Form
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
$form.WindowState = [System.Windows.Forms.FormWindowState]::Maximized
$form.TopMost = $true
$form.BackgroundImage = $bitmap
$form.BackgroundImageLayout = [System.Windows.Forms.ImageLayout]::Stretch
$form.Show()

# ==============================================
# 3. DEFINE O CÓDIGO C# DO HOOK DE TECLADO (BLOQUEIO PESADO)
# ==============================================
$csharpCode = @"
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Threading;

public class KeyBlocker
{
    private delegate IntPtr LowLevelKeyboardProc(int nCode, IntPtr wParam, IntPtr lParam);
    private static LowLevelKeyboardProc _proc = HookCallback;
    private static IntPtr _hookID = IntPtr.Zero;

    [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    private static extern IntPtr SetWindowsHookEx(int idHook, LowLevelKeyboardProc lpfn, IntPtr hMod, uint dwThreadId);

    [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool UnhookWindowsHookEx(IntPtr hhk);

    [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    private static extern IntPtr CallNextHookEx(IntPtr hhk, int nCode, IntPtr wParam, IntPtr lParam);

    [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    private static extern IntPtr GetModuleHandle(string lpModuleName);

    [StructLayout(LayoutKind.Sequential)]
    private struct KBDLLHOOKSTRUCT
    {
        public uint vkCode;
        public uint scanCode;
        public uint flags;
        public uint time;
        public IntPtr dwExtraInfo;
    }

    private const int WH_KEYBOARD_LL = 13;
    private const int VK_LWIN = 0x5B;
    private const int VK_RWIN = 0x5C;
    private const int VK_TAB = 0x09;
    private const int VK_F4 = 0x73;
    private const int VK_LMENU = 0xA4;  // Alt esquerdo
    private const int VK_RMENU = 0xA5;  // Alt direito

    private static bool _isActive = true;

    public static void StartBlocking()
    {
        _hookID = SetHook(_proc);
        if (_hookID == IntPtr.Zero)
        {
            return;
        }

        // Loop de verificação da flag
        string flagFile = Environment.GetEnvironmentVariable("TEMP") + "\\ov.stop";
        while (_isActive)
        {
            if (System.IO.File.Exists(flagFile))
            {
                _isActive = false;
            }
            Thread.Sleep(200);
        }

        UnhookWindowsHookEx(_hookID);
    }

    private static IntPtr SetHook(LowLevelKeyboardProc proc)
    {
        using (Process curProcess = Process.GetCurrentProcess())
        using (ProcessModule curModule = curProcess.MainModule)
        {
            return SetWindowsHookEx(WH_KEYBOARD_LL, proc,
                GetModuleHandle(curModule.ModuleName), 0);
        }
    }

    private static IntPtr HookCallback(int nCode, IntPtr wParam, IntPtr lParam)
    {
        if (nCode >= 0)
        {
            KBDLLHOOKSTRUCT hookStruct = (KBDLLHOOKSTRUCT)Marshal.PtrToStructure(lParam, typeof(KBDLLHOOKSTRUCT));
            uint vkCode = hookStruct.vkCode;

            bool isBlocked = false;

            // Bloqueia teclas isoladas: Win, Tab, F4, Alt
            if (vkCode == VK_LWIN || vkCode == VK_RWIN || vkCode == VK_TAB || vkCode == VK_F4 ||
                vkCode == VK_LMENU || vkCode == VK_RMENU)
            {
                isBlocked = true;
            }

            // Bloqueia Alt+F4 especificamente (se Alt estiver pressionado E F4 for acionado)
            if (vkCode == VK_F4 && (GetKeyState(VK_LMENU) < 0 || GetKeyState(VK_RMENU) < 0))
            {
                isBlocked = true;
            }

            if (isBlocked)
            {
                return (IntPtr)1; // Bloqueia a tecla (não passa adiante)
            }
        }
        return CallNextHookEx(_hookID, nCode, wParam, lParam);
    }

    [DllImport("user32.dll")]
    private static extern short GetKeyState(int nVirtKey);
}
"@

# ==============================================
# 4. COMPILA O C# E INICIA O BLOQUEIO EM UMA THREAD SEPARADA
# ==============================================
Add-Type -TypeDefinition $csharpCode -Language CSharp

$blockThread = [System.Threading.Thread]::new({ [KeyBlocker]::StartBlocking() })
$blockThread.Start()

# ==============================================
# 5. LOOP DE ESPERA DA FLAG
# ==============================================
$flagFile = "$env:TEMP\ov.stop"
while (-not (Test-Path $flagFile)) {
    Start-Sleep -Milliseconds 200
    [System.Windows.Forms.Application]::DoEvents()
}

# ==============================================
# 6. FINALIZA
# ==============================================
$form.Close()
[System.GC]::Collect()
Remove-Item $flagFile -Force -ErrorAction SilentlyContinue