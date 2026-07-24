# QA manual de accesibilidad — pendientes físicos de Fase 1

**Fecha:** 2026-07-23 (`America/Costa_Rica`)  
**Responsable:** subagente `f1_manual_accessibility`  
**Alcance:** prototipo local de Fase 1 con datos ficticios; sin integraciones, persistencia ni transmisión de archivos  
**Entorno:** Windows, Google Chrome controlado mediante extensión, servidor HTTP local temporal en `127.0.0.1:41736`  
**Ruta preparada:** `#proyecto?id=JBC-2026-0042&work=TR-0042-01&tab=resumen`  
**Archivo de prueba previsto:** `docs/testing/evidence/F01/fixture-croquis-rev04.txt`

## Dictamen

**Resultado global: NO EJECUTADO.** Ninguna de las cuatro comprobaciones físicas pendientes alcanzó una ejecución completa y auditable. Esta corrida no aporta evidencia suficiente para cerrar `F1-REV-P1-03`.

La página local sí cargó correctamente y quedó preparada en Chrome. Sin embargo, los atajos enviados a la pestaña controlada no modificaron el zoom nativo, y la activación de la ventana física de Chrome no respondió dentro del tiempo disponible. La interacción se detuvo sin enviar entradas adicionales. No se sustituyeron las pruebas físicas con cambios de viewport, eventos DOM sintéticos ni inferencias.

## Resultados

| Caso obligatorio                                                     | Pasos ejecutados                                                                                                                                                                                                                                               | Resultado        | Observación verificable                                                                                                                                                                                                                                                                             |
| -------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Zoom nativo del navegador al 200 %, claro/oscuro                     | Se cargó el Proyecto/Trabajo catastral en tema resuelto oscuro. Se midió el estado inicial (`innerWidth=1206`, `devicePixelRatio=1.5625`, `scrollWidth=1194`). Se enviaron `Ctrl+0` y un incremento `Ctrl++` a la pestaña controlada y se repitió la medición. | **NO EJECUTADO** | Ambos atajos dejaron exactamente `innerWidth=1206` y `devicePixelRatio=1.5625`; no se demostró cambio de zoom. El intento posterior de activar la ventana física de Chrome no respondió y fue abortado antes de aplicar entrada. No se evaluó 200 %, tema claro ni pérdida/overflow bajo zoom real. |
| Selector nativo `Adjuntar`: cancelación, selección y retorno de foco | Se comprobó que existe el fixture y se localizó en el prototipo el `input[type=file]` con nombre accesible `Seleccionar archivos para clasificar en OneDrive`.                                                                                                 | **NO EJECUTADO** | No se abrió el diálogo nativo ni se realizó cancelación o selección. El fixture no se cargó ni transmitió. No hay evidencia nueva de retorno de foco.                                                                                                                                               |
| Arrastre físico desde Explorador al compositor                       | Se identificaron ventanas existentes del Explorador y la zona de composición en el prototipo.                                                                                                                                                                  | **NO EJECUTADO** | No se inició ningún arrastre y no se añadió el archivo al compositor. No se generó una propuesta previa.                                                                                                                                                                                            |
| Lector de pantalla real de Windows, claro/oscuro                     | Se confirmó la disponibilidad de control de Windows y se dejó preparada la ruta representativa.                                                                                                                                                                | **NO EJECUTADO** | Narrador no se inició. No se auditaron nombres, orden, estado activo, anuncios ni restauración de foco mediante salida real de lector de pantalla. Al terminar se confirmó `Narrator: No activo`.                                                                                                   |

## Preparación y límites observados

- El primer intento de servidor con el alias `python` falló por el entorno de ejecución; se reemplazó por el runtime local autorizado y el servidor quedó accesible antes de abrir la ruta.
- El corte local cargó con título `Detalle de proyecto · JBC Proyectos` y la URL/Trabajo esperados.
- El intento de control directo de la ventana física de Chrome excedió el tiempo acotado de interacción y fue interrumpido. No se repitió para evitar dejar superficies esperando indefinidamente.
- No se realizaron correcciones en `prototypes/fase1/**`, porque no se obtuvo un defecto reproducible mediante estas pruebas.
- `DEC-0115`, `DEC-0116` y `DEC-0117` permanecen sin cambios.

## Higiene al finalizar

- La pestaña temporal de QA fue finalizada.
- El servidor HTTP temporal de `41736` fue detenido y el puerto quedó sin escucha.
- Narrador no quedó activo.
- No se seleccionó, cargó, copió ni transmitió el archivo ficticio.

## Consecuencia para el cierre

Las cuatro pendientes **no permiten cerrar `F1-REV-P1-03`** con esta corrida. Siguen siendo obligatorias una ejecución física verificable de zoom 200 %, selector nativo, arrastre desde Explorador y lector de pantalla en ambos temas. La evidencia estructural y automatizada de `F01-ACCESSIBILITY-QA-R2-2026-07-23.md` continúa siendo complementaria, no sustituta.
