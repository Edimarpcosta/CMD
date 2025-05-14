# Solicita elevação para administrador, se ainda não estiver executando como tal
if (-Not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process PowerShell -Verb RunAs -ArgumentList ("-File `"{0}`"" -f $MyInvocation.MyCommand.Path)
    exit
}

Write-Host "Parando o serviço de Spooler de Impressão..."
Stop-Service -Name Spooler -Force -ErrorAction SilentlyContinue

$SpoolFolder = "$env:SystemRoot\System32\spool\PRINTERS"
Write-Host "Limpando arquivos da fila de impressão em $SpoolFolder..."

if (Test-Path $SpoolFolder) {
    Get-ChildItem -Path $SpoolFolder -Include *.SHD, *.SPL -Recurse | Remove-Item -Force -ErrorAction SilentlyContinue
    Write-Host "Arquivos da fila de impressão (.SHD, .SPL) foram removidos."
} else {
    Write-Warning "A pasta $SpoolFolder não foi encontrada."
}

Write-Host "Iniciando o serviço de Spooler de Impressão..."
Start-Service -Name Spooler -ErrorAction SilentlyContinue

# Verifica se o serviço iniciou
$SpoolerService = Get-Service -Name Spooler
if ($SpoolerService.Status -eq "Running") {
    Write-Host "Serviço de Spooler de Impressão iniciado com sucesso."
} else {
    Write-Warning "Falha ao iniciar o serviço de Spooler de Impressão. Status atual: $($SpoolerService.Status)"
}

Write-Host "Processo concluído. Pressione Enter para sair."
Read-Host
