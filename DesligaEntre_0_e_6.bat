set hora_atual=%time:~0,2%
IF %hora_atual% GEQ 0 (
   IF %hora_atual% LEQ 6 (
     start notepad "Fora de Hora"
   )
)
