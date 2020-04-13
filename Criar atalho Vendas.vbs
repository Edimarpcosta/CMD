'Script para criar o atalho de vendas caso for excluido ou outro motivo.


On error Resume Next
Err.clear 0

'============================================================================

'
set WshShell = WScript.CreateObject("WScript.Shell")
strDesktop = WshShell.SpecialFolders("Desktop")

set oUrlLink = WshShell.CreateShortcut(strDesktop & "\Vendas.lnk")
oUrlLink.TargetPath = "D:\Vendas\Vendas.exe"
oUrlLink.Save

Wscript.Quit
