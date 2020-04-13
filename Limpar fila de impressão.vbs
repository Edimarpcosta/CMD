'**************************************************************************************************************************
' Limpar fila de impress�o.vbs
'
' Fun��o: Limpar a fila de impress�o
' Vers�o: 1.0
' Data: 16/01/08
' 
' Por: tm.fernando
' Email: tm.fernando@gmail.com
'**************************************************************************************************************************

Rem Dialogo inicial
Dim WshShell, BtnCode
Set WshShell = WScript.CreateObject("WScript.Shell")

BtnCode = WshShell.Popup("Este Script ira apagar todos os documentos da fila de impress�o." & vbCrLf _
							& " " & vbCrLf _
							& "Para iniciar clique em OK" & vbCrLf _
							& "Para sair clique em CANCELAR", , "Limpar fila de impress�o", 1 + 32)

Select Case BtnCode
   Rem Caso OK seja selecionado
   case 1
		On Error Resume Next

		strComputer = "."

		Rem Parando o Servi�o Spooler
		Set objWMIService = GetObject("winmgmts:" _
		    & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")

		Set colServiceList = objWMIService.ExecQuery("Associators of " _
	    	& "{Win32_Service.Name='Spooler'} Where " _
		        & "AssocClass=Win32_DependentService " & "Role=Antecedent" )

		For Each objService in colServiceList
	    	objService.StopService()
		Next

		WScript.Sleep 200

		Set colServiceList = objWMIService.ExecQuery _
	        	("Select * from Win32_Service where Name='Spooler'")
		For Each objService in colServiceList
		    errReturn = objService.StopService()
		Next

		Rem Apagando os arquivos necessarios
		Set objFSO = CreateObject("Scripting.FileSystemObject")

			objFSO.DeleteFile("C:\WINDOWS\system32\spool\PRINTERS\*.shd")
			objFSO.DeleteFile("C:\WINDOWS\system32\spool\PRINTERS\*.spl")

		Rem Iniciando o Servi�o Spooler
		Set colServiceList = objWMIService.ExecQuery _
	    	("Select * from Win32_Service where Name='Spooler'")

		For Each objService in colServiceList
		    errReturn = objService.StartService()
		Next

		WScript.Sleep 200

		Set colServiceList = objWMIService.ExecQuery("Associators of " _
	   	& "{Win32_Service.Name='Spooler'} Where " _
	        	& "AssocClass=Win32_DependentService " & "Role=Dependent" )
		For Each objService in colServiceList
		    objService.StartService()
		Next

		Rem Mensagem de conclus�o
		WScript.Echo "A fila de impress�o foi limpa com sucesso"   
   
   Rem Caso Cancelar seja selecionado
   case 2      
   
End Select