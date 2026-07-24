# QA responsive e interacción — Fase 1

Fecha: 2026-07-23 (`America/Costa_Rica`)  
Navegador: navegador integrado de Codex  
URL local: `http://localhost:41731/`  
Datos: exclusivamente ficticios

## Matriz de reflujo

| Viewport | Estado                         | Columnas observadas   |        Contexto vivo | Resultado                                        |
| -------: | ------------------------------ | --------------------- | -------------------: | ------------------------------------------------ |
| 1440×900 | sidebar 244 px, IA cerrada     | `633 / 420`           |               420 px | overflow horizontal 0                            |
| 1440×900 | sidebar slim 64 px, IA abierta | `447 / 420 / 350`     | 420 px, mayor que IA | orden sección → contexto → IA; overflow 0        |
| 1024×900 | sidebar slim, IA abierta       | una columna de 863 px |               863 px | IA después del contexto, sin overlay; overflow 0 |
|  768×900 | navegación móvil, IA cerrada   | una columna de 705 px |               705 px | 3 trabajos de 218 px; overflow 0                 |
|  360×800 | navegación móvil, IA cerrada   | una columna de 313 px |               313 px | trabajos de 278 px; overflow 0                   |

En 360 px, ambas tarjetas APT/SIRI midieron `scrollWidth = clientWidth = 313`; los badges permanecieron dentro de su tarjeta. Los viewports 768 y 360 cubren también el reflujo equivalente a un escritorio ampliado; la ejecución manual del control de zoom del navegador a 200 % queda como comprobación visual complementaria.

## Casos de interacción

| Caso                       | Evidencia observada                                                                                           | Resultado |
| -------------------------- | ------------------------------------------------------------------------------------------------------------- | --------- |
| Proyecto como contratación | PC-2026-0042 muestra 3 trabajos y un trabajo activo                                                           | PASS      |
| Independencia por trabajo  | cambiar a TR-0042-02 actualiza URL, estado `En elaboración` y contrato APT `2026-01843`                       | PASS      |
| Once ámbitos               | Trabajos, Datos, Gestiones, Tareas, Agenda, Trámites, Archivos, Aprobaciones, Actividad, Reportes e Historial | PASS      |
| Inspección sin navegación  | `Tareas` abre inspector en Contexto vivo                                                                      | PASS      |
| Tarea como objeto real     | `Corregir minuta APT` navega a `tab=tareas&record=TAR-1042` y muestra vista operativa/Editar tarea            | PASS      |
| Archivo como objeto real   | `Croquis_rev03.pdf` navega a `tab=archivos&record=FILE-CROQUIS-REV03` y muestra `Abrir archivo en OneDrive`   | PASS      |
| Anotación predeterminada   | texto sin `/` + `Publicar` crea `Anotación de Laura Mora`                                                     | PASS      |
| Creación con `/`           | `/tarea Validar plano B` + `Publicar` crea evento `Creación de tarea confirmada`                              | PASS      |
| Adjunto integrado          | selector dentro del compositor detecta `fixture-croquis-rev04.txt`; no aparece dropzone separada              | PASS      |
| Confirmación única         | propuesta de archivo no muestra `Confirmar destino`; el único `Publicar` registra carga OneDrive simulada     | PASS      |
| Límites de archivo         | antes de publicar se informa que nada salió del dispositivo; no hubo transferencia real                       | PASS      |
| IA reordenada              | rectángulo del compositor termina antes de iniciar mensajes                                                   | PASS      |
| IA no superpuesta          | 1440: tercera columna; 1024/768/360: apilada después de Contexto vivo                                         | PASS      |
| Sidebar slim               | 244 → 64 px; nombre accesible cambia a `Expandir menú principal`; overflow 0                                  | PASS      |
| Temas                      | claro: fondo `rgb(244,245,246)` y contexto blanco; oscuro: fondo `rgb(17,19,21)` y contexto `rgb(27,30,33)`   | PASS      |
| Fuentes renderizadas       | UI `Inter, "Segoe UI", sans-serif`; datos `"Roboto Mono", Consolas, monospace`                                | PASS      |

Recorrido móvil adicional: **13/13 rutas** (`inicio`, `proyectos`, `crear`, `proyecto`, `trabajo`, `agenda`, `archivos`, `aprobaciones`, `notificaciones`, `reportes`, `administracion`, `estados`, `buscar`) renderizaron `main` y `h1` propios con overflow horizontal 0 a 360×800.

Navegación inmersiva: **12/12 secciones** del Trabajo catastro conservaron Contexto vivo con 11 alcances, marcaron correctamente la sección activa y mantuvieron overflow 0 a 360 px. En el Trabajo de Delimitación se observaron 0 tarjetas de integración activa, mensaje explícito `APT/SIRI no aplica` y overflow 0.

El flujo de selector usa el mismo manejador que el arrastre sobre `data-composer-drop-target`. La selección de archivo sí se ejecutó; el gesto físico de arrastre se conserva para una prueba manual de puntero.

## Capturas del corte vigente

- `proyecto-1440-trabajos-contexto-ia.png`
- `proyecto-1024-trabajos.png`
- `proyecto-768-trabajos.png`
- `proyecto-360-trabajos.png`
- `proyecto-360-trabajos-claro.png`

## Límites

- El prototipo no persiste ni contacta OneDrive, Supabase, APT, SIRI u OpenAI.
- La “apertura” del archivo termina en una vista operativa ficticia con acción simulada; la integración real corresponde a Fase 7.
- No se ejecutaron axe-core ni Lighthouse en este artefacto estático; sus gates siguen asignados a fases técnicas.
