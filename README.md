# Medición Red + Sistema — CRM VoIP

Script/exe que en ~15-20s reporta red y sistema con veredicto semáforo para CRM con llamadas IP.

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
./build/build.ps1 -Version 1.1.0
./dist/MedicionEquipo.exe
```

Requiere `Install-Module ps2exe -Scope CurrentUser -Force`.

### Release
```bash
git tag v1.1.0 && git push origin v1.1.0
# GitHub Actions compila EXE + ZIP + checksums y publica Release
```

Manual dispatch: Actions -> release -> Run workflow.

### Qué reporta
**RED (Ookla CLI):** Ping <100ms, Jitter <30ms, Pérdida <1%, Subida ≥1 Mbps
**SISTEMA:** CPU, RAM, Disco SSD/HDD, Uptime, Top5 procesos
**Veredicto:** APTO (0 fallos) / CON RIESGO (1) / NO APTO (2+)

Umbrales editables al inicio de `src/medir_red.ps1` (`$Thr*`).

### Notas EXE
* `$PSScriptRoot` fallback a `Process.MainModule.FileName` para ser portable.
* `speedtest.exe` se busca junto al EXE; si no está lo descarga a `%TEMP%` (TLS1.2).
* Log fallback: `registros/` -> `Desktop\registros_medicion` -> `%TEMP%`.
* Sin `requireAdmin`, sin firma (SmartScreen bypass documentado).

### Legacy
`medir.bat` aún funciona: si existe `MedicionEquipo.exe` lo lanza, si no cae a `src/medir_red.ps1`.
