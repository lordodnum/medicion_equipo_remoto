# Medición Red + Sistema — CRM VoIP

Script/exe que en ~15-20s reporta red y sistema con veredicto binario (APTO / NO APTO) para CRM con llamadas IP.

## Para ejecutivos — 1 clic

Descarga `MedicionEquipo.exe` de **Releases** -> doble clic -> lee veredicto. Ver `LEEME_EJECUTIVOS.md`.

No requiere instalación. Windows 10/11 PowerShell 5.1.

## Para técnicos

### Estructura
```
src/medir_red.ps1      # fuente
assets/icon.ico        # icono semáforo
build/build.ps1        # compila a dist/MedicionEquipo.exe via PS2EXE
dist/                  # artefactos (no trackeado, solo Release)
registros/             # logs por equipo/fecha (gitignore)
```

### Build local (Windows)
```powershell
./build/build.ps1 -Version 1.3.1
./dist/MedicionEquipo.exe
```

Requiere `Install-Module ps2exe -Scope CurrentUser -Force`.

### Release
```bash
git tag v1.3.1 && git push origin v1.3.1
# GitHub Actions compila EXE + ZIP + checksums y publica Release
```

Manual dispatch: Actions -> release -> Run workflow.

### Qué reporta
**RED (Ookla CLI):** Ping <100ms, Jitter <30ms, Pérdida <1%, Subida ≥1 Mbps
**SISTEMA:** CPU, RAM (instalada/visible/libre), Disco SSD/HDD, Uptime, Top5 procesos
**Veredicto:** binario — APTO (cumple todo) / NO APTO (falla uno o más umbrales)

El umbral de RAM se evalúa contra la memoria **instalada** (`Win32_PhysicalMemory`), no contra la visible del SO: un equipo de 8 GB reales reporta ~7.8 GB visibles y si no, fallaría por redondeo.

Umbrales editables al inicio de `src/medir_red.ps1` (`$Thr*`).

### Notas EXE
* `$PSScriptRoot` fallback a `Process.MainModule.FileName` para ser portable.
* `speedtest.exe` se busca junto al EXE; si no está lo descarga a `%TEMP%` (TLS1.2).
* Log fallback: `registros/` -> `Desktop\registros_medicion` -> `%TEMP%`.
* Nombre del log: `EQUIPO_yyyyMMdd_HHmmss.txt` (con segundos, para no sobrescribir si se corre dos veces seguidas).
* Sin `requireAdmin`, sin firma (SmartScreen bypass documentado).

### Legacy
`medir.bat` aún funciona: si existe `MedicionEquipo.exe` lo lanza, si no cae a `src/medir_red.ps1` (y a `medir_red.ps1` en la raíz).
