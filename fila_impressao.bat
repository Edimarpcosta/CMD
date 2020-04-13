
net stop spooler
cd %systemroot%\system32\spool\PRINTERS
del /f /s *.shd
del /f /s *.spl
net start spooler
pause
echo Pressione uma tecla pra sair
exit