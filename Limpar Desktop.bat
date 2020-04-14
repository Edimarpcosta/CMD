@echo off
color c
ECHO Limpar Area de trabalho Movendo Arquivos para Backup_Desktop.
ECHO Deseja continuar?
pause
md C:\Users\%username%\Desktop\Backup_Desktop

move C:\Users\%username%\Desktop\*.* C:\Users\%username%\Desktop\Backup_Desktop
pause
