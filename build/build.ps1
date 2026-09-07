#Requires -Version 5.1
param(
    [string]$Version = '1.1.0',
    [string]$Src = "$PSScriptRoot/../src/medir_red.ps1",
    [string]$OutDir = "$PSScriptRoot/../dist",
    [string]$Icon = "$PSScriptRoot/../assets/icon.ico"
)
$ErrorActionPreference = 'Stop'
Write-Host "== Build MedicionEquipo v$Version ==" -ForegroundColor Cyan

if (-not (Test-Path $Src)) { throw "No se encuentra $Src" }
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir -Force | Out-Null }

if (-not (Get-Module -ListAvailable -Name ps2exe)) {
    Write-Host '[+] Instalando ps2exe...' -ForegroundColor Yellow
    Install-Module ps2exe -Scope CurrentUser -Force -ErrorAction Stop
}
Import-Module ps2exe -Force

$outExe = Join-Path $OutDir 'MedicionEquipo.exe'
if (Test-Path $outExe) { Remove-Item $outExe -Force }

$params = @{
    inputFile   = (Resolve-Path $Src).Path
    outputFile  = $outExe
    title       = 'Medicion Equipo Remoto'
    description = 'Medicion Red/Sistema CRM VoIP - Semaforo aptitud'
    company     = 'MedicionEquipo'
    product     = 'MedicionEquipo'
    copyright   = "Copyright $(Get-Date -Format yyyy)"
    version     = $Version
    iconFile    = (Resolve-Path $Icon).Path
    noConsole   = $false
    noOutput    = $false
    noError     = $false
    requireAdmin = $false
    STA         = $true
    supportOS   = $true
    credentialGUI = $false
}

Write-Host "[+] Compilando $Src -> $outExe" -ForegroundColor Gray
Invoke-PS2EXE @params

if (-not (Test-Path $outExe)) { throw "Build fallo: no se genero $outExe" }
$size = [math]::Round((Get-Item $outExe).Length / 1MB, 2)
Write-Host "[OK] EXE generado: $outExe ($size MB)" -ForegroundColor Green

$hash = (Get-FileHash $outExe -Algorithm SHA256).Hash
$hash | Out-File (Join-Path $OutDir 'MedicionEquipo.exe.sha256') -Encoding ascii
Write-Host "SHA256: $hash" -ForegroundColor DarkGray

Write-Host ''
Write-Host 'Para probar:' -ForegroundColor Cyan
Write-Host "  $outExe"
Write-Host ''
Write-Host 'Para release ZIP manual:' -ForegroundColor Cyan
Write-Host "  Compress-Archive -Path $outExe, ./assets/icon.png, ./LEEME_EJECUTIVOS.md -DestinationPath ./dist/MedicionEquipo_v$Version.zip -Force"
