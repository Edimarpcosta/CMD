# Solicita elevação para administrador, se ainda não estiver executando como tal
if (-Not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Este script precisa de privilégios de administrador."
    Write-Warning "Tentando reiniciar como Administrador..."
    Start-Process PowerShell -Verb RunAs -ArgumentList ("-File `"{0}`"" -f $MyInvocation.MyCommand.Path)
    exit
}

# --- Configuração do Logging ---
# Define o nome do arquivo de log no mesmo diretório do script
$LogFileName = "LimparFilaImpressao_Log_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
$LogFile = Join-Path -Path $PSScriptRoot -ChildPath $LogFileName

try {
    # Inicia a gravação de tudo que aparece no console para o arquivo de log
    # -Force: Sobrescreve o arquivo de log se ele já existir (o timestamp já torna único)
    Start-Transcript -Path $LogFile -Force
}
catch {
    Write-Warning "FALHA AO INICIAR O TRANSCRIPT (LOG): $($_.Exception.Message)"
    Write-Warning "O script continuará, mas o log completo pode não estar disponível."
}

Write-Host "=================================================================="
Write-Host "INÍCIO DA EXECUÇÃO DO SCRIPT DE LIMPEZA DE FILA DE IMPRESSÃO"
Write-Host "Data e Hora: $(Get-Date)"
Write-Host "Log sendo gravado em: $LogFile"
Write-Host "=================================================================="
Write-Host ""

# --- Lógica Principal do Script com Tratamento de Erros ---
try {
    Write-Host "[INFO] Tentando parar o serviço de Spooler de Impressão (Spooler)..."
    Stop-Service -Name Spooler -Force -ErrorAction Stop # -ErrorAction Stop para pular para o bloco Catch em caso de erro
    Write-Host "[SUCESSO] Serviço de Spooler de Impressão parado."

    $SpoolFolder = "$env:SystemRoot\System32\spool\PRINTERS"
    Write-Host "[INFO] Caminho da pasta de spool da impressora: $SpoolFolder"

    if (Test-Path $SpoolFolder) {
        Write-Host "[INFO] Limpando arquivos .SHD e .SPL da pasta $SpoolFolder..."
        # Pega os itens e, se houver, tenta remover.
        $PrintFiles = Get-ChildItem -Path $SpoolFolder -Include *.SHD, *.SPL -Recurse -ErrorAction SilentlyContinue
        if ($PrintFiles) {
            $PrintFiles | Remove-Item -Force -ErrorAction Stop
            Write-Host "[SUCESSO] Arquivos da fila de impressão (.SHD, .SPL) removidos."
        } else {
            Write-Host "[INFO] Nenhum arquivo .SHD ou .SPL encontrado para remover."
        }
    } else {
        Write-Warning "[AVISO] A pasta de spool $SpoolFolder não foi encontrada."
    }

    Write-Host "[INFO] Tentando iniciar o serviço de Spooler de Impressão (Spooler)..."
    Start-Service -Name Spooler -ErrorAction Stop
    Write-Host "[SUCESSO] Serviço de Spooler de Impressão iniciado."

    # Verifica se o serviço realmente iniciou
    $SpoolerService = Get-Service -Name Spooler -ErrorAction SilentlyContinue # Não queremos que essa verificação pare o script
    if ($SpoolerService.Status -eq "Running") {
        Write-Host "[VERIFICAÇÃO] Serviço de Spooler de Impressão está em execução (Status: $($SpoolerService.Status))."
    } else {
        Write-Warning "[VERIFICAÇÃO - AVISO] O serviço de Spooler de Impressão NÃO está em execução. Status atual: $($SpoolerService.Status)"
    }

    Write-Host ""
    Write-Host "[INFO] Script concluído com sucesso (aparentemente)."

}
catch {
    # Este bloco será executado se qualquer comando com -ErrorAction Stop falhar
    Write-Error "[ERRO FATAL] Ocorreu um erro durante a execução do script:"
    Write-Error "Mensagem: $($_.Exception.Message)"
    Write-Error "Comando que falhou: $($_.InvocationInfo.MyCommand)"
    Write-Error "Linha: $($_.InvocationInfo.ScriptLineNumber)"
    Write-Error "Detalhes Completos do Erro: $_"
    # $_ contém o objeto de erro completo, que será logado pelo Transcript
}
finally {
    Write-Host ""
    Write-Host "=================================================================="
    Write-Host "FIM DA EXECUÇÃO DO SCRIPT"
    Write-Host "Data e Hora: $(Get-Date)"
    Write-Host "Verifique o arquivo de log para detalhes completos: $LogFile"
    Write-Host "=================================================================="

    # Pausa para o usuário ver as mensagens no console antes de fechar
    Read-Host "Pressione Enter para sair."

    # Para a gravação do transcript
    if (Get-Transcript) { # Verifica se um transcript está ativo antes de tentar parar
        Stop-Transcript
    }
}
