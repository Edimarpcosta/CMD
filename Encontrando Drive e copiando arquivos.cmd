@echo off
echo Inicio %time%
Title Copia do .NET Framework 3.5 para o Desktop
for %%I in (D E F G H I J K L M N O P Q R S T U V W X Y Z) do if exist "%%I:\\sources\install.wim" set setupdrv=%%I
if defined setupdrv (
echo Encontrado drive %setupdrv%:\
echo Copiando .NET Framework 3.5...
copy %setupdrv%:\sources\sxs\*.cab C:\Users\%username%\Desktop\Net35\
copy %setupdrv%:\sources\sxs\*.zip C:\Users\%username%\Desktop\Net35\
echo.
echo Fim %time%
echo .NET Framework 3.5 copiado.
echo.
) else (
echo Midia de instalacao nao encontrada!
echo.
echo Insira um DVD, USB ou ISO e tente novamente. 
echo.
)
pause