from docx import Document
from docx.shared import Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.style import WD_STYLE_TYPE
import datetime

doc = Document()
style = doc.styles['Normal']
style.font.name = 'Calibri'
style.font.size = Pt(11)
style.paragraph_format.space_after = Pt(6)
style.paragraph_format.line_spacing = 1.05

def add_heading(text, level=1, color=None, align=None):
    h = doc.add_heading(level=level)
    run = h.add_run(text)
    run.bold = True
    if color:
        run.font.color.rgb = color
    if level == 1:
        run.font.size = Pt(16)
    elif level == 2:
        run.font.size = Pt(13)
    elif level == 3:
        run.font.size = Pt(11)
    if align:
        h.alignment = align
    h.paragraph_format.space_before = Pt(12)
    h.paragraph_format.space_after = Pt(6)
    return h

def add_para(text, bold=False, italic=False, bullet=False, align=None, size=None, color=None):
    if bullet:
        p = doc.add_paragraph(style='List Bullet')
    else:
        p = doc.add_paragraph()
    run = p.add_run(text)
    run.bold = bold
    run.italic = italic
    if size:
        run.font.size = Pt(size)
    if color:
        run.font.color.rgb = color
    if align:
        p.alignment = align
    return p

def add_para_mixed(parts):
    p = doc.add_paragraph()
    for text, kwargs in parts:
        run = p.add_run(text)
        for k, v in kwargs.items():
            if k == 'bold': run.bold = v
            elif k == 'italic': run.italic = v
            elif k == 'size': run.font.size = Pt(v)
            elif k == 'color': run.font.color.rgb = v
    return p

p = doc.add_paragraph()
p.alignment = WD_ALIGN_PARAGRAPH.CENTER
run = p.add_run("Medición de Equipo Remoto — CRM VoIP")
run.bold = True
run.font.size = Pt(20)
run.font.color.rgb = RGBColor(0x1F, 0x4E, 0x78)
p = doc.add_paragraph()
p.alignment = WD_ALIGN_PARAGRAPH.CENTER
run = p.add_run("Resumen Ejecutivo para Jefatura  |  v1.1.0  |  " + datetime.date.today().strftime("%d/%m/%Y"))
run.font.size = Pt(11)
run.font.color.rgb = RGBColor(0x5A, 0x5A, 0x5A)
p = doc.add_paragraph()
p.alignment = WD_ALIGN_PARAGRAPH.CENTER
run = p.add_run("Repositorio: github.com/lordodnum/medicion_equipo_remoto  —  Link sin login: releases/latest/download/MedicionEquipo.exe")
run.font.size = Pt(9)
run.italic = True
run.font.color.rgb = RGBColor(0x5A, 0x5A, 0x5A)
add_para("Documento solo texto — listo para imprimir o compartir por correo.", italic=True, size=9, color=RGBColor(0x70,0x70,0x70), align=WD_ALIGN_PARAGRAPH.CENTER)

add_heading("1. Resumen Ejecutivo", level=1, color=RGBColor(0x1F,0x4E,0x78))
add_para("La herramienta Medición de Equipo permite evaluar en 15 a 20 segundos si un computador remoto es apto para trabajar con el CRM con llamadas IP (VoIP). Reemplaza la revisión manual del Administrador de tareas y de pruebas web como fast.com, entregando un veredicto objetivo tipo semáforo y un archivo de registro para soporte.")
add_para("Se distribuye como un único archivo ejecutable para Windows (MedicionEquipo.exe) que no requiere instalación. El usuario hace doble clic, espera la medición y lee el veredicto. El proceso es estándar, auditable y reduce el tiempo de diagnóstico de minutos a segundos.")

add_heading("2. Objetivo", level=1, color=RGBColor(0x1F,0x4E,0x78))
add_para("Determinar de forma rápida y objetiva si el equipo remoto cumple los requisitos mínimos de red y de sistema para operar el CRM con telefonía IP, evitando cortes, latencia o mala calidad de audio, y dejando trazabilidad para el área de soporte y la jefatura.")

add_heading("3. Funcionalidad", level=1, color=RGBColor(0x1F,0x4E,0x78))
add_heading("3.1 Qué mide — Red (Ookla Speedtest CLI)", level=2)
add_para("Utiliza el cliente oficial de Ookla (speedtest.exe, ~1 MB) que se descarga automáticamente la primera vez. Mide:")
add_para("Ping (latencia): tiempo de ida y vuelta en milisegundos.", bullet=True)
add_para("Jitter: variación de la latencia.", bullet=True)
add_para("Pérdida de paquetes: porcentaje de paquetes perdidos.", bullet=True)
add_para("Velocidad de bajada y subida en Mbps. Para telefonía IP, la velocidad de subida es la más crítica.", bullet=True)
add_para("Proveedor (ISP) y servidor de prueba utilizado.", bullet=True)

add_heading("3.2 Qué mide — Sistema (PowerShell)", level=2)
add_para("CPU: modelo, cantidad de núcleos y porcentaje de uso.", bullet=True)
add_para("RAM: memoria total, libre y porcentaje de uso.", bullet=True)
add_para("Disco: capacidad total, espacio libre, porcentaje ocupado y tipo (SSD / HDD / no determinado).", bullet=True)
add_para("Uptime: horas desde el último reinicio.", bullet=True)
add_para("Top 5 procesos que más CPU consumen (nombre, tiempo de CPU y memoria).", bullet=True)

add_heading("3.3 Veredicto semáforo", level=2)
add_para("El sistema compara cada métrica contra umbrales configurables y cuenta cuántos umbrales se incumplen. Antes del veredicto muestra una línea de checks del tipo < Ping OK | Jitter ALTO | RAM OK > que explica el motivo.")
add_para("APTO (verde): 0 fallos. El equipo cumple todos los umbrales. Apto para CRM.", bullet=True)
add_para("CON RIESGO (amarillo): 1 fallo. Funciona pero conviene revisar el punto señalado (por ejemplo, RAM en mínimo o jitter al límite).", bullet=True)
add_para("NO APTO (rojo): 2 o más fallos. No se recomienda para CRM hasta corregir.", bullet=True)

add_heading("3.4 Umbrales actuales (editables al inicio de src/medir_red.ps1)", level=2)
add_para("Ping menor a 100 ms (ideal menor a 50 ms).", bullet=True)
add_para("Jitter menor a 30 ms (ideal menor a 20 ms).", bullet=True)
add_para("Pérdida menor a 1 %.", bullet=True)
add_para("Velocidad de subida mayor o igual a 1 Mbps (mínimo para softphone).", bullet=True)
add_para("RAM mayor o igual a 8 GB recomendado, 4 GB mínimo.", bullet=True)
add_para("Los umbrales se pueden ajustar editando las variables $ThrPing, $ThrJitter, $ThrLoss, $ThrUp, $ThrRamMin y $ThrRamOpt al inicio del script.", italic=True, size=9)

add_heading("4. Instrucciones de uso", level=1, color=RGBColor(0x1F,0x4E,0x78))
add_heading("4.1 Para el usuario final (1 clic, sin conocimientos técnicos)", level=2)
add_para("Paso 1 — Descargar: abrir el link sin login https://github.com/lordodnum/medicion_equipo_remoto/releases/latest/download/MedicionEquipo.exe y guardar el archivo en Escritorio o Descargas. Alternativa ZIP: https://github.com/lordodnum/medicion_equipo_remoto/releases/latest/download/MedicionEquipo_v1.3.0.zip", bullet=False)
add_para("Si aparece SmartScreen (Windows protege su PC): hacer clic en Más información y luego en Ejecutar de todas formas. Es normal por ser una aplicación interna sin firma digital.", italic=True, size=9)
add_para("Paso 2 — Ejecutar: doble clic en MedicionEquipo.exe (icono semáforo). No requiere instalación ni permisos de administrador.", bullet=False)
add_para("La primera vez puede tardar 15 a 60 segundos porque descarga speedtest.exe y mide la conexión. Se muestra en pantalla: ISP, ping, jitter, pérdida, bajada, subida, servidor, CPU, RAM, disco, uptime y top 5 procesos.", bullet=False)
add_para("Paso 3 — Leer el veredicto: APTO (verde), CON RIESGO (amarillo) o NO APTO (rojo). Debajo se indica el detalle de cada check. Se genera automáticamente un archivo de registro con nombre EQUIPO_AAAAMMDD_HHMM.txt en la carpeta registros junto al EXE, o en Escritorio/registros_medicion o en la carpeta temporal si no hay permisos. Enviar ese archivo a soporte.", bullet=False)

add_heading("4.2 Para el área técnica / soporte", level=2)
add_para("Estructura del repositorio: src/medir_red.ps1 es el fuente, assets/icon.ico es el icono, build/build.ps1 compila a dist/MedicionEquipo.exe mediante PS2EXE, dist contiene artefactos (no se versiona, solo Release), registros contiene logs por equipo/fecha.", bullet=False)
add_para("Compilación local en Windows: ./build/build.ps1 -Version 1.1.0 y luego ./dist/MedicionEquipo.exe. Requiere Install-Module ps2exe -Scope CurrentUser -Force.", bullet=False)
add_para("Publicación de nueva versión: git tag vX.Y.Z y git push origin vX.Y.Z. GitHub Actions compila el EXE, el ZIP y los checksums SHA256 y publica el Release. También se puede lanzar manual desde Actions con workflow_dispatch.", bullet=False)
add_para("Logs: el registro incluye equipo, usuario, fecha, red completa, CPU, RAM, disco, uptime, checks y veredicto. Es texto plano UTF-8, fácil de adjuntar por correo o ticket.", bullet=False)

add_heading("5. Beneficios", level=1, color=RGBColor(0x1F,0x4E,0x78))
add_para("Reduce el tiempo de diagnóstico de varios minutos (fast.com + Administrador de tareas) a 15-20 segundos con criterio unificado.", bullet=True)
add_para("Estandariza la evaluación: mismos umbrales para todos los equipos, sin interpretación subjetiva.", bullet=True)
add_para("Facilita el soporte: el veredicto y los checks explican el porqué; el log permite trazabilidad y comparación entre equipos.", bullet=True)
add_para("Cero instalación: un solo EXE portable para Windows 10/11 con PowerShell 5.1, sin necesidad de administrador.", bullet=True)
add_para("Distribución simple: link directo sin login, siempre apunta a la última versión, con ZIP alternativo que incluye guía para ejecutivos.", bullet=True)
add_para("Mantenimiento centralizado: cambios de umbrales o mejoras se publican como nuevo Release sin reinstalar nada en los equipos.", bullet=True)

add_heading("6. Requisitos y compatibilidad", level=1, color=RGBColor(0x1F,0x4E,0x78))
add_para("Sistema operativo: Windows 10 u 11 (64 bits).", bullet=True)
add_para("PowerShell: versión 5.1 o superior (incluida por defecto).", bullet=True)
add_para("Permisos: no requiere administrador ni firma digital.", bullet=True)
add_para("Conectividad: acceso a internet para descargar speedtest.exe la primera vez (~1 MB) y para medir. Si hay proxy o antivirus, puede bloquear la descarga; en ese caso descargar manualmente speedtest.exe desde speedtest.net/apps/cli y colocarlo junto al EXE.", bullet=True)
add_para("Antivirus: algunos pueden marcar el EXE por no estar firmado; agregar excepción si es necesario.", bullet=True)

add_heading("7. Distribución y actualización", level=1, color=RGBColor(0x1F,0x4E,0x78))
add_para("El canal oficial es GitHub Releases. Link recomendado para compartir: https://github.com/lordodnum/medicion_equipo_remoto/releases/latest/download/MedicionEquipo.exe (siempre última versión). Link versionado: https://github.com/lordodnum/medicion_equipo_remoto/releases/download/v1.3.0/MedicionEquipo.exe")
add_para("El ZIP MedicionEquipo_v1.3.0.zip incluye el EXE y las guías LEEME_EJECUTIVOS.md y README.md. Los checksums SHA256 se publican como checksums.txt y MedicionEquipo.exe.sha256 para verificación de integridad.")
add_para("El repositorio es público para descarga sin cuenta de GitHub. El código fuente está en src/medir_red.ps1 y el script de compilación en build/build.ps1.")

add_heading("8. Seguridad y soporte", level=1, color=RGBColor(0x1F,0x4E,0x78))
add_para("El EXE no requiere credenciales ni envía datos fuera del equipo, salvo la medición a servidores de Ookla. Los logs quedan locales y solo se comparten si el usuario los envía.", bullet=True)
add_para("SmartScreen mostrará advertencia por falta de firma; está documentado en LEEME_EJECUTIVOS.md (Más información / Ejecutar de todas formas).", bullet=True)
add_para("Solución de problemas: si aparece No se pudo descargar speedtest.exe, verificar internet/proxy y reintentar, o usar ZIP completo. Si speedtest no pudo medir, probar DNS pública 8.8.8.8 / 1.1.1.1 y desactivar VPN.", bullet=True)
add_para("Soporte: solicitar al usuario el archivo EQUIPO_*.txt de la carpeta registros y adjuntarlo al ticket.", bullet=True)

add_heading("9. Conclusión", level=1, color=RGBColor(0x1F,0x4E,0x78))
add_para("La herramienta entrega en segundos un diagnóstico claro y accionable sobre la aptitud de un equipo remoto para operar el CRM con VoIP, con veredicto semáforo, detalle de cada métrica y registro para soporte. Su distribución sin instalación y su link sin login la hacen operativa para usuarios sin conocimientos técnicos, mientras que su código y Release centralizados permiten a la jefatura y al área técnica mantener criterio y trazabilidad.")

add_para("Documento generado automáticamente desde el repositorio medicion_equipo_remoto v1.3.0 — para consultas contactar al área de soporte.", italic=True, size=9, color=RGBColor(0x70,0x70,0x70), align=WD_ALIGN_PARAGRAPH.CENTER)
add_para("Fin del documento.", italic=True, size=9, color=RGBColor(0x70,0x70,0x70), align=WD_ALIGN_PARAGRAPH.CENTER)

out = "dist/Resumen_Jefatura_MedicionEquipo_v1.3.0.docx"
doc.save(out)
print(f"Generado {out}")
