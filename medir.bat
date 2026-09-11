@echo off
title Medicion Red/Sistema v1.3.0
if exist "%~dp0MedicionEquipo.exe" (
  start "" "%~dp0MedicionEquipo.exe"
  exit /b
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0src\medir_red.ps1"
if not exist "%~dp0src\medir_red.ps1" powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0medir_red.ps1"
echo.
echo ============================================================
echo   Pulsa una tecla para cerrar...
echo ============================================================
pause >nul
