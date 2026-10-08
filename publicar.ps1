# ---------------------------------------------------------------
# Compila el libro (MyST) y lo publica en GitHub Pages.
#
#   Uso:   .\publicar.ps1            (solo compila y publica)
#          .\publicar.ps1 -Ejecutar  (ademas re-ejecuta los notebooks)
#
# No hace commits en la rama main: esos se hacen a mano.
# ---------------------------------------------------------------
param([switch]$Ejecutar)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

$ENV_DIR = "$env:USERPROFILE\miniconda3\envs\ml_venv"
$SCRIPTS = "$ENV_DIR\Scripts"
$env:PATH = "$ENV_DIR;$SCRIPTS;$env:PATH"
$env:BASE_URL = "/Informe_Dashboard_Magdalena_ML"

if ($Ejecutar) {
    foreach ($nb in "01_contexto", "02_eda", "03_modelos") {
        & "$SCRIPTS\jupyter.exe" nbconvert --to notebook --execute --inplace `
            --ExecutePreprocessor.kernel_name=ml_venv `
            --ExecutePreprocessor.timeout=1800 "$nb.ipynb"
    }
}

if (Test-Path "_build") { Remove-Item -LiteralPath "_build" -Recurse -Force }
& "$SCRIPTS\myst.exe" build --html

if (-not (Test-Path "_build\html\index.html")) {
    Write-Host "ERROR: la compilacion no genero el libro." -ForegroundColor Red; exit 1
}

& "$SCRIPTS\ghp-import.exe" -n -p -f _build/html
Write-Host "`nListo: https://qclemente.github.io/Informe_Dashboard_Magdalena_ML/" -ForegroundColor Green
