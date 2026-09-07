# Medición Equipo — Guía Ejecutivos (1 clic)

## Paso 1 — Descargar
Entra a **Releases** del repositorio y descarga `MedicionEquipo.exe` (un solo archivo, icono semáforo).

> Si ves advertencia SmartScreen: clic en **Más información** -> **Ejecutar de todas formas**. Es normal por ser app interna sin firma.

## Paso 2 — Doble clic
Guárdalo en Escritorio o Descargas y haz **doble clic** en el icono. No necesita instalar nada.

* La primera vez puede tardar 15-60 segundos midiendo la conexión.
* Verás: Ping, Jitter, Bajada/Subida, CPU, RAM, Disco.

## Paso 3 — Lee el veredicto

* **APTO (verde)** -> Sirve para CRM.
* **CON RIESGO (amarillo)** -> Sirve pero revisar (ej RAM 4GB o jitter alto).
* **NO APTO (rojo)** -> No sirve, 2+ fallos.

Debajo del veredicto sale `< Ping OK | Jitter ALTO | RAM OK >` que dice el porqué.

Se guarda automáticamente un registro en `registros/` junto al EXE (o en Escritorio si no hay permisos) con nombre `EQUIPO_20260907_1530.txt`. **Envía ese archivo a soporte.**

## Solución de problemas

* **"No se pudo descargar speedtest.exe"** -> Sin internet/proxy. Pide a soporte el ZIP completo.
* **"speedtest no pudo medir"** -> Pon DNS 8.8.8.8 / 1.1.1.1, desactiva VPN y reintenta.
* Antivirus bloquea -> Añadir excepción o pedir ZIP firmado.

Soporte: adjunta el `.txt` de `registros/`.
