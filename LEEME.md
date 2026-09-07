# Medición Red + Sistema para equipos remotos (CRM con llamadas IP)

Script que se ejecuta en el equipo remoto y en ~15-20 s muestra el estado de
la red y del sistema, con un veredicto (semáforo) para saber si el equipo es
apto para el CRM. Reemplaza la espera del Administrador de tareas y de
fast.com.

## Qué reporta

RED (Ookla Speedtest CLI)
    Ping      latencia   -> ideal <50 ms, aceptable <100 ms
    Jitter    variación  -> ideal <20 ms, aceptable <30 ms
    Pérdida   % paquetes -> <1 %
    Bajada /  en Mbps
    Subida    (para softphone la SUBIDA es lo que manda)

SISTEMA (PowerShell)
    CPU       modelo, núcleos, uso %
    RAM       total, libre, uso %
    Disco     tamaño, usado %, y tipo (SSD/HDD)
    Uptime    horas encendido
    Top 5     procesos que consumen más CPU

## Veredicto (semáforo)

  APTO         (verde)    -> el equipo cumple TODOS los umbrales. Sirve.
  CON RIESGO   (amarillo) -> 1 umbral al límite (ej. RAM 4 GB o jitter alto).
                             Sirve, pero conviene revisarlo.
  NO APTO      (rojo)     -> 2 o más umbrales superados. No es apto.

Antes del veredicto sale una línea tipo: < Ping OK | Jitter ALTO | RAM OK >
que indica exactamente qué pasó y qué no, para que sepas el motivo.

## Cómo usar

1. Copia la carpeta completa (medir_red.ps1 + medir.bat) al equipo remoto.
2. Doble clic en `medir.bat`, o desde una consola:
       powershell -NoProfile -ExecutionPolicy Bypass -File medir_red.ps1
3. La primera vez descarga `speedtest.exe` (~974 KB) y lo deja junto al script.
4. Lee el reporte en pantalla. Se guarda además un log por equipo/fecha en
   la subcarpeta `registros\`.

## Umbrales usados por el veredicto (editables al inicio del .ps1)

    Ping < 100 ms          (VoIP: <50 ideal)
    Jitter < 30 ms         (VoIP: <20 ideal)
    Pérdida < 1 %
    Subida >= 1 Mbps       (mínimo para softphone)
    RAM >= 4 GB (>=8 recomendado)

Ajusta estos valores en las variables $Thr* de medir_red.ps1 si tu plan/CRM
exige más.
