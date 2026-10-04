# Sobe todos os servicos do projeto, cada um em uma janela propria,
# e por ultimo roda o tunnel (subir.ps1) nesta janela.
# Coloque este arquivo na RAIZ do projeto (onde esta o Caddyfile).

$raiz = $PSScriptRoot

function Abrir($titulo, $pasta, $comando) {
    if (-not (Test-Path $pasta)) {
        Write-Host ">> PULANDO $titulo (pasta nao existe: $pasta)" -ForegroundColor Yellow
        return
    }
    $cmd = "`$Host.UI.RawUI.WindowTitle = '$titulo'; Set-Location '$pasta'; $comando"
    Start-Process powershell -ArgumentList "-NoExit", "-Command", $cmd
    Write-Host ">> $titulo iniciado" -ForegroundColor Green
}

Write-Host "Projeto em: $raiz" -ForegroundColor Cyan

# Garante que nao ha um Caddy antigo ocupando as portas
caddy stop 2>$null | Out-Null
Start-Sleep -Seconds 1

Abrir "Banco (5000)"    "$raiz\banco_de_dados"      "python app.py"
Abrir "Clima (5001)"    "$raiz\backend_clima"       "npm start"
Abrir "Indices (8001)"  "$raiz\backend_indices"     "python -m uvicorn backend_server:app --host 0.0.0.0 --port 8001"
Abrir "IA (8000)"       "$raiz\IA\API"              "python -m uvicorn classificar:app --port 8000"
Abrir "Frontend (5173)" "$raiz\frontend_projete"    "npm run dev"
Abrir "Caddy (8080)"    $raiz                       "caddy run"

Write-Host ""
Write-Host "Aguardando os servicos subirem (8 segundos)..." -ForegroundColor Cyan
Start-Sleep -Seconds 8

Write-Host "Iniciando o tunnel e atualizando o Worker..." -ForegroundColor Cyan
Write-Host "(Deixe esta janela aberta. Ctrl+C para derrubar o tunnel.)" -ForegroundColor Cyan
Write-Host ""

& "$raiz\subir.ps1"