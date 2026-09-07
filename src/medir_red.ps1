# ============================================================
#  MEDICION RED + SISTEMA - equipos remotos (CRM VoIP)
#  Version: 1.1.0  |  Build: 2026-09-07
#  Uso EXE: doble clic en MedicionEquipo.exe
#  Uso PS1: powershell -NoProfile -ExecutionPolicy Bypass -File medir_red.ps1
# ============================================================
$ErrorActionPreference = 'Continue'
$Version = '1.1.0'
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

$ThrPing   = 100
$ThrJitter = 30
$ThrLoss   = 1
$ThrUp     = 1
$ThrRamMin = 4
$ThrRamOpt = 8

function Get-ScriptDir {
    if ($PSScriptRoot -and (Test-Path $PSScriptRoot)) { return $PSScriptRoot }
    try {
        $p = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
        if ($p) { $d = Split-Path $p -Parent; if ($d -and (Test-Path $d)) { return $d } }
    } catch {}
    try {
        if ($MyInvocation.MyCommand.Path) { $d = Split-Path $MyInvocation.MyCommand.Path -Parent; if ($d) { return $d } }
    } catch {}
    return (Get-Location).Path
}

function Get-LogDir($baseDir) {
    $candidates = @(
        (Join-Path $baseDir 'registros')
        (Join-Path $env:USERPROFILE 'Desktop\registros_medicion')
        (Join-Path $env:TEMP 'registros_medicion')
    )
    foreach ($c in $candidates) {
        try {
            if (-not (Test-Path $c)) { New-Item -ItemType Directory -Path $c -Force | Out-Null }
            $test = Join-Path $c '.writetest'
            Set-Content -Path $test -Value 'ok' -Force -ErrorAction Stop
            Remove-Item $test -Force -ErrorAction SilentlyContinue
            return $c
        } catch {}
    }
    return $candidates[0]
}

function Pause-Exit($code = 0) {
    Write-Host ''
    Write-Host 'Pulsa una tecla para cerrar...' -ForegroundColor DarkGray
    try { $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown') } catch { Start-Sleep -Seconds 3 }
    exit $code
}

$scriptDir = Get-ScriptDir
$st = Join-Path $scriptDir 'speedtest.exe'
if (-not (Test-Path $st)) {
    $fallback = Join-Path $env:TEMP 'speedtest.exe'
    if (Test-Path $fallback) { $st = $fallback }
}

if (-not (Test-Path $st)) {
    Write-Host "[+] Descargando speedtest.exe (primera vez, ~1 MB)..." -NoNewline
    try {
        $zip = Join-Path $env:TEMP 'ookla-speedtest.zip'
        $dst = Join-Path $env:TEMP 'ookla-cli'
        Invoke-WebRequest -Uri 'https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-win64.zip' -OutFile $zip -UseBasicParsing -TimeoutSec 30 -ErrorAction Stop
        if (Test-Path $dst) { Remove-Item $dst -Recurse -Force -ErrorAction SilentlyContinue }
        Expand-Archive -Path $zip -DestinationPath $dst -Force -ErrorAction Stop
        $found = Get-ChildItem $dst -Recurse -Filter 'speedtest.exe' | Select-Object -First 1
        if (-not $found) { throw 'No se encontro speedtest.exe en el zip' }
        $targetDir = Split-Path $st -Parent
        if (-not (Test-Path $targetDir)) { New-Item -ItemType Directory -Path $targetDir -Force | Out-Null }
        try { Copy-Item $found.FullName $st -Force -ErrorAction Stop }
        catch { Copy-Item $found.FullName $fallback -Force; $st = $fallback }
        Remove-Item $zip -Force -ErrorAction SilentlyContinue
        Remove-Item $dst -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host ' listo.'
    } catch {
        Write-Host ''
        Write-Host "ERROR: No se pudo descargar speedtest.exe" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Yellow
        Write-Host ''
        Write-Host 'Posibles causas: sin internet, proxy corporativo, antivirus bloqueando.'
        Write-Host 'Solucion: descarga manualmente speedtest.exe de https://www.speedtest.net/apps/cli y ponlo junto a MedicionEquipo.exe'
        Pause-Exit 1
    }
}

if (-not (Test-Path $st)) {
    Write-Host "ERROR: No se encuentra speedtest.exe en $st" -ForegroundColor Red
    Pause-Exit 1
}

function Run-Speedtest {
    $outF = Join-Path $env:TEMP 'st_out.json'
    $errF = Join-Path $env:TEMP 'st_err.txt'
    for ($i = 1; $i -le 3; $i++) {
        Remove-Item $outF, $errF -ErrorAction SilentlyContinue
        try {
            $p = Start-Process -FilePath $st -ArgumentList '--accept-license','--accept-gdpr','--format','json','--progress=no' -NoNewWindow -Wait -PassThru -RedirectStandardOutput $outF -RedirectStandardError $errF -ErrorAction Stop
        } catch {
            Write-Host "  Intento $i : no se pudo lanzar speedtest.exe ($($_.Exception.Message))" -ForegroundColor Yellow
            Start-Sleep -Seconds 2
            continue
        }
        $raw = ''
        if (Test-Path $outF) { $raw = Get-Content $outF -Raw -ErrorAction SilentlyContinue }
        if ($raw -and $raw.Trim().StartsWith('{')) { return $raw }
        Write-Host "  Intento $i : speedtest no devolvio datos." -ForegroundColor Yellow
        if (Test-Path $errF) {
            $e = (Get-Content $errF -Raw -ErrorAction SilentlyContinue)
            if ($e) { Write-Host "  Detalle: $e" -ForegroundColor DarkGray }
        }
        if ($i -lt 3) { Start-Sleep -Seconds 2 }
    }
    return $null
}

Write-Host ''
Write-Host "  Medicion Equipo v$Version  |  CRM VoIP" -ForegroundColor Cyan
Write-Host '[+] Midiendo velocidad (puede tardar 15s a 1 min segun conexion)...' -ForegroundColor Gray
$raw = Run-Speedtest
if (-not $raw) {
    Write-Host ''
    Write-Host 'ERROR: speedtest no pudo medir (fallo DNS/conexion).' -ForegroundColor Red
    Write-Host 'Tip: pon DNS publica 8.8.8.8 y 1.1.1.1 en el adaptador, desactiva VPN/proxy y reintenta.' -ForegroundColor Yellow
    Pause-Exit 1
}

try { $r = $raw | ConvertFrom-Json -ErrorAction Stop }
catch {
    Write-Host "ERROR: respuesta JSON invalida de speedtest" -ForegroundColor Red
    Write-Host $raw -ForegroundColor DarkGray
    Pause-Exit 1
}

$ping   = $r.ping.latency
$jitter = $r.ping.jitter
$downM  = [math]::Round(($r.download.bandwidth * 8 / 1000000), 1)
$upM    = [math]::Round(($r.upload.bandwidth * 8 / 1000000), 1)
$loss   = $r.packetLoss
if ($null -eq $loss) { $loss = 0 }
$isp    = $r.isp
$serverTxt = "$($r.server.name) - $($r.server.location), $($r.server.country)"

$os   = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
$cpu  = Get-CimInstance Win32_Processor | Select-Object -First 1
$cores = $cpu.NumberOfCores
if (-not $cores) { $cores = $cpu.NumberOfLogicalProcessors }
$cpuLoad = (Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average
if ($null -eq $cpuLoad) { $cpuLoad = 0 }
$cpuLoad = [math]::Round($cpuLoad, 0)
$ramTotal = [math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
$ramFree  = [math]::Round($os.FreePhysicalMemory / 1MB, 1)
$ramPct   = if ($ramTotal -gt 0) { [math]::Round(($ramTotal - $ramFree) / $ramTotal * 100, 0) } else { 0 }
$upHours  = [math]::Round(((Get-Date) - $os.LastBootUpTime).TotalHours, 0)

$disk = Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' | Sort-Object Size -Descending | Select-Object -First 1
$diskSizeGB = if ($disk.Size) { [math]::Round($disk.Size / 1GB, 0) } else { 0 }
$diskFreeGB = if ($disk.FreeSpace) { [math]::Round($disk.FreeSpace / 1GB, 0) } else { 0 }
$diskPct    = if ($disk.Size -and $disk.Size -gt 0) { [math]::Round(($disk.Size - $disk.FreeSpace) / $disk.Size * 100, 0) } else { 0 }

$mediaType = 'N/A'
try { $pd = Get-PhysicalDisk | Select-Object -First 1 -ErrorAction Stop; if ($pd.MediaType) { $mediaType = $pd.MediaType } } catch { $mediaType = 'No determin.' }

$top = (Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 | ForEach-Object { $_.ProcessName + '  CPU=' + [math]::Round($_.CPU,0) + 's  Mem=' + [math]::Round($_.WS/1MB) + ' MB' })

$checks = @()
if ($ping   -lt $ThrPing)   { $checks += 'Ping OK' } else { $checks += 'Ping ALTO' }
if ($jitter -lt $ThrJitter) { $checks += 'Jitter OK' } else { $checks += 'Jitter ALTO' }
if ($loss   -lt $ThrLoss)   { $checks += 'Perdida OK' } else { $checks += 'Perdida ALTA' }
if ($upM    -ge $ThrUp)     { $checks += 'Subida OK' } else { $checks += 'Subida BAJA' }
if ($ramTotal -ge $ThrRamOpt) { $checks += 'RAM OK' }
elseif ($ramTotal -ge $ThrRamMin) { $checks += 'RAM MINIMO' }
else { $checks += 'RAM BAJA' }
$warn = ($checks | Where-Object { $_ -match 'ALTO|ALTA|BAJA|MINIMO' }).Count
if ($warn -eq 0) { $verdict = 'APTO'; $color = 'Green' }
elseif ($warn -eq 1) { $verdict = 'CON RIESGO'; $color = 'Yellow' }
else { $verdict = 'NO APTO'; $color = 'Red' }

try { $userName = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name } catch { $userName = "$env:USERDOMAIN\$env:USERNAME" }
$line = '=' * 78
Write-Host $line
Write-Host ('  MEDICION RED/SISTEMA v' + $Version + ' - Equipo: ' + $env:COMPUTERNAME + '   Usuario: ' + $userName + '   Fecha: ' + (Get-Date -Format 'yyyy-MM-dd HH:mm'))
Write-Host $line
Write-Host (' :: RED        ISP: ' + $isp)
Write-Host ('   Ping    : ' + $ping + ' ms')
Write-Host ('   Jitter  : ' + $jitter + ' ms')
Write-Host ('   Perdida : ' + $loss + ' %')
Write-Host ('   Bajada  : ' + $downM + ' Mbps')
Write-Host ('   Subida  : ' + $upM + ' Mbps')
Write-Host ('   Servidor: ' + $serverTxt)
Write-Host ''
Write-Host ' :: SISTEMA'
Write-Host ('   CPU     : ' + $cpu.Name + '  (' + $cores + ' nucleos, uso ' + $cpuLoad + '%)')
Write-Host ('   RAM     : ' + $ramTotal + ' GB total - libre ' + $ramFree + ' GB (uso ' + $ramPct + '%)')
Write-Host ('   Disco   : ' + $diskSizeGB + ' GB, libre ' + $diskFreeGB + ' GB (' + $diskPct + '% usado) [' + $mediaType + ']')
Write-Host ('   Uptime  : ' + $upHours + ' horas')
Write-Host ''
Write-Host ' :: PROCESOS TOP (CPU)'
$top | ForEach-Object { Write-Host ('   ' + $_) }
Write-Host ''
Write-Host ('< ' + ($checks -join ' | ') + ' >')
Write-Host ''
Write-Host ('  >>>  VEREDICTO: ' + $verdict + '  <<<') -ForegroundColor $color
Write-Host $line
Write-Host ''
Write-Host '  Semaforo:  APTO (verde)  |  CON RIESGO (amarillo)  |  NO APTO (rojo)' -ForegroundColor Gray

$logDir = Get-LogDir $scriptDir
$logFile = Join-Path $logDir ($env:COMPUTERNAME + '_' + (Get-Date -Format 'yyyyMMdd_HHmm') + '.txt')
$log = 'MEDICION EQUIPO: ' + $env:COMPUTERNAME + '   Usuario: ' + $userName + "`n" + 'Version: ' + $Version + "`n" + 'Fecha: ' + (Get-Date -Format 'yyyy-MM-dd HH:mm') + "`n" + 'RED    ping=' + $ping + ' ms  jitter=' + $jitter + ' ms  perdida=' + $loss + '%  bajada=' + $downM + ' Mbps  subida=' + $upM + ' Mbps  ISP=' + $isp + "`n" + 'SERVIDOR ' + $serverTxt + "`n" + 'CPU    ' + $cpu.Name + ' | ' + $cores + ' nucleos | uso ' + $cpuLoad + '%' + "`n" + 'RAM    ' + $ramTotal + ' GB total | libre ' + $ramFree + ' GB | uso ' + $ramPct + '%' + "`n" + 'DISCO  ' + $diskSizeGB + ' GB | libre ' + $diskFreeGB + ' GB | ' + $diskPct + '% | ' + $mediaType + "`n" + 'UPTIME ' + $upHours + ' horas' + "`n" + 'CHECKS ' + ($checks -join ' | ') + "`n" + 'VEREDICTO ' + $verdict + "`n"
try {
    Set-Content -Path $logFile -Value $log -Encoding UTF8 -ErrorAction Stop
    Write-Host ''
    Write-Host ('[+] Registro guardado: ' + $logFile) -ForegroundColor Green
} catch {
    Write-Host ('[!] No se pudo guardar log en ' + $logFile + ' : ' + $_.Exception.Message) -ForegroundColor Yellow
}

Write-Host ''
Pause-Exit 0
