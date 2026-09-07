# Link de Descarga — Medición Equipo

## Para usuarios finales (1 clic, sin login)

> **Requisito:** el repo debe estar público. Si acabás de hacerlo público, esperá a que se publique el Release `v1.1.0` (~3 min).

**Link directo (siempre última versión):**
```
https://github.com/lordodnum/medicion_equipo_remoto/releases/latest/download/MedicionEquipo.exe
```

**Link versionado:**
```
https://github.com/lordodnum/medicion_equipo_remoto/releases/download/v1.1.0/MedicionEquipo.exe
```

**ZIP alternativo (incluye guía):**
```
https://github.com/lordodnum/medicion_equipo_remoto/releases/latest/download/MedicionEquipo_v1.1.0.zip
```

## Instrucciones para compartir

1. Copiá el link `latest` y pegalo en mail/WhatsApp/Teams
2. Adjuntá `LEEME_EJECUTIVOS.md` o deciles: doble clic → si sale SmartScreen: **Más información** → **Ejecutar de todas formas**
3. El usuario guarda en Escritorio, doble clic, lee veredicto y te envía el `.txt` de `registros/`

## Verificación (para admin)

- Repo público: `https://github.com/lordodnum/medicion_equipo_remoto` debe abrir sin login en incógnito
- Release publicado: `https://github.com/lordodnum/medicion_equipo_remoto/releases` debe mostrar `v1.1.0` con 3 archivos (exe, zip, checksums)
- Si no ves el Release: ejecutá en Windows `git push && git push origin v1.1.0` y revisá Actions

## Comandos admin (Windows)

```powershell
gh repo edit lordodnum/medicion_equipo_remoto --visibility public --accept-visibility-change-consequences
git push
git push origin v1.1.0
```
