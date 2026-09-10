# Link de Descarga — Medición Equipo

## Para usuarios finales (1 clic, sin login)

> **Requisito:** el repo debe estar público. Si acabás de hacerlo público, esperá a que se publique el Release `v1.2.0` (~3 min).

**Link directo (siempre última versión):**
```
https://github.com/lordodnum/medicion_equipo_remoto/releases/latest/download/MedicionEquipo.exe
```

**Link versionado:**
```
https://github.com/lordodnum/medicion_equipo_remoto/releases/download/v1.2.0/MedicionEquipo.exe
```

**ZIP alternativo (incluye guía):**
```
https://github.com/lordodnum/medicion_equipo_remoto/releases/latest/download/MedicionEquipo_v1.2.0.zip
```

## Instrucciones para compartir

1. Copiá el link `latest` y pegalo en mail/WhatsApp/Teams
2. Adjuntá `LEEME_EJECUTIVOS.md` o deciles: doble clic → si sale SmartScreen: **Más información** → **Ejecutar de todas formas**
3. El usuario guarda en Escritorio, doble clic, lee veredicto y te envía el `.txt` de `registros/`

## Qué cambió en v1.2.0

- El veredicto ahora es **binario: APTO o NO APTO**. Ya no existe "CON RIESGO": si falla un solo requisito, el equipo es NO APTO.
- **RAM mínima para APTO: 8 GB**, medida sobre la memoria instalada. Un equipo de 8 GB sirve (antes se veía como ~7.8 GB y quedaba al límite).
- El resto de requisitos sigue igual: ping < 100 ms, jitter < 30 ms, pérdida < 1 %, subida ≥ 1 Mbps.
- El archivo de registro ahora lleva segundos en el nombre, así dos mediciones seguidas no se sobrescriben.

## Verificación (para admin)

- Repo público: `https://github.com/lordodnum/medicion_equipo_remoto` debe abrir sin login en incógnito
- Release publicado: `https://github.com/lordodnum/medicion_equipo_remoto/releases` debe mostrar `v1.2.0` con 4 archivos (exe, zip, checksums.txt, exe.sha256)
- Checksums: el SHA256 del `MedicionEquipo.exe` descargado debe coincidir con el del `checksums.txt`
- Si no ves el Release: revisá Actions y, si el tag no está, corré `git tag v1.2.0 && git push origin v1.2.0`

## Comandos admin (Windows)

```powershell
gh repo edit lordodnum/medicion_equipo_remoto --visibility public --accept-visibility-change-consequences
git push
git push origin v1.2.0
```
