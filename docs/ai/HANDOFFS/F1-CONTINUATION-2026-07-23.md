# Handoff de continuación — Fase 1

> **Sustituido:** este documento conserva el estado anterior a accesibilidad/R2. El corte vigente está en `F1-CP-UX-READY-2026-07-23.md`.

**Fecha:** 2026-07-23 (`America/Costa_Rica`)  
**Estado:** Fase 1 activa, **no cerrada**  
**Checkpoint:** CP-UX pendiente  
**Próximo alcance autorizado:** terminar y validar Fase 1; **no iniciar Fase 2**

## 1. Punto exacto de reanudación

El prototipo y la documentación funcional de Fase 1 están ampliamente construidos. La lógica `Proyecto/Contratación 1:N Trabajos` fue auditada por un subagente, corregida y regresada por el orquestador. También quedaron corregidos localmente el condicionamiento APT/SIRI por Trabajo y la carga general paralela.

La fase **no está lista para confirmación** porque la revisión independiente R1 mantiene como bloqueo la evidencia accesible obligatoria. Después de completarla todavía hace falta ordenar/regenerar el paquete visual y solicitar una revisión independiente R2 con cero P0/P1.

Fuente de estado: [CURRENT_STATUS.md](../CURRENT_STATUS.md). Borrador de reporte: [PHASE_1_REPORT.md](../PHASE_1_REPORT.md).

## 2. Fuentes que el siguiente chat debe leer primero

1. Objetivo original, antes de cualquier acción:
   `C:\Users\JBCTopografía\.codex\attachments\a1a4d6f8-557a-4172-baf6-f04014eceb90\goal-objective.md`
2. Este handoff completo.
3. [Registro de decisiones](../DECISIONS_LOG.md).
4. [Plan de Fase 1](../PHASE_1_PLAN.md).
5. [Revisión independiente R1](../../architecture/reviews/F1/F1-INDEPENDENT-REVIEW-2026-07-23.md).
6. [Auditoría Proyecto→Trabajos](../../testing/evidence/F01/PROJECT-WORKS-AUDIT-2026-07-23.md).
7. [QA de accesibilidad vigente](../../testing/evidence/F01/F01-ACCESSIBILITY-QA-2026-07-23.md).
8. [Matriz de trazabilidad](../../product/TRACEABILITY_MATRIX.md).
9. [Estándar obligatorio de desarrollo UI/UX](../../development/UI_UX_IMPLEMENTATION_GUIDELINES.md).
10. [QA de densidad visual de Proyecto](../../testing/evidence/F01/F01-PROJECT-VISUAL-DENSITY-QA-2026-07-23.md).
11. [QA del encabezado adaptable del sidebar](../../testing/evidence/F01/F01-SIDEBAR-BRAND-TOGGLE-QA-2026-07-23.md).
12. [QA de Configuración al pie del sidebar](../../testing/evidence/F01/F01-SIDEBAR-SETTINGS-FOOTER-QA-2026-07-23.md).

Raíz del workspace:
`C:\Users\JBCTopografía\OneDrive - JBC Topografia\Documentos\AppGestionProyectos`

No hay repositorio Git en esta carpeta. Antes de editar, revisar los archivos actuales y preservar todo cambio del usuario.

## 3. Aprobaciones y reglas ya fijadas

- G0 aprobado el 2026-07-23.
- `DEC-0101`: al cambiar el tipo queda historial inmutable con usuario, marca UTC, tipo/estado anterior, tipo nuevo y correlación/aprobación; APT/SIRI deja de estar activo si el Trabajo ya no es catastral.
- `DEC-0102`: entrega 07:00 inclusive–20:00 exclusiva y silencio 20:00–07:00, hora Costa Rica.
- `DEC-0105`: coexisten navegación general e inmersiva por Proyecto.
- `DEC-0106`: fondos grises neutros y temas automático, claro y oscuro.
- `DEC-0107`: IA transversal con comandos `/`, borrador y confirmación humana.
- `DEC-0108`: secciones preservadas, historial contextual tipo Odoo, archivos OneDrive y fuentes obligatorias.
- `DEC-0109`: relaciones inspeccionables en sitio; IA a la derecha del Contexto vivo.
- `DEC-0110`: Contexto vivo accionable y compositor único; sin dropzone separada, `Crear documento` ni selector Mensaje/Nota/Actividad.
- `DEC-0111`: Proyecto es la Contratación y contiene `1..N` Trabajos independientes.
- `DEC-0112`: sidebar slim, Contexto vivo ancho, compositor IA arriba y propuesta IA compacta antes de estados.
- `DEC-0113`: los once alcances de Contexto vivo viven en un desplegable `Filtrar por tipo`; no restaurar la cuadrícula grande anterior.
- `DEC-0114`: usar patrones UI convencionales; cierres `×` con nombre accesible, acciones de negocio con texto y `Actualización`/`Al día` en APT en vez de `Frescura` visible. Su detalle original `☰`/`×` del sidebar fue sustituido por `DEC-0116`.
- `DEC-0115`: conservar el contenido y aligerar la jerarquía; no acumular contornos en panel, hijos y filas. Priorizar espacio, tipografía y superficies neutras, con bordes reservados para controles, foco, selección y estado.
- `DEC-0116`: sidebar slim con una única `J` que expande; abierto alinea `J`, `JBC Proyectos` y `×` en una sola fila. No restaurar el `☰` separado.
- `DEC-0117`: ocultar el grupo `Sistema` del sidebar y sustituir el pie técnico por un único `⚙ Configuración`; en slim queda solo el engranaje. Las rutas técnicas siguen disponibles dentro de Configuración o por URL autorizada.

Siguen pendientes `DEC-0103` antes de G2, `DEC-0104` antes de G4 y `DEC-0202` antes de Fase 5. No deben inventarse respuestas ni usarse para ampliar Fase 1.

## 4. Implementación y evidencia ya terminadas

### Prototipo

- Entrada: `prototypes/fase1/index.html`.
- Lógica principal: `prototypes/fase1/app.js`.
- Estilos: `prototypes/fase1/styles.css`.
- Datos exclusivamente ficticios; sin persistencia, SDK, secretos, red ni escritura real a OneDrive, Supabase, APT, SIRI u OpenAI.

### Proyecto → Trabajos

- 4 Proyectos/Contrataciones y 8 Trabajos; ninguna Contratación vacía.
- Proyecto conserva solo atributos contractuales; tipo, estado, responsable y relaciones pertenecen al Trabajo.
- Todos los Trabajos tienen relaciones independientes mediante `workRelations`.
- `JBC-2026-0018` demuestra una Contratación heterogénea con Delimitación y Croquis.
- El alta configura separadamente tipo, estado, responsable, prioridad, inicio y entrega de cada Trabajo.
- Rutas profundas y contextos IA/OneDrive conservan Proyecto + Trabajo.
- APT activo solo para Plano de catastro; la historia externa inactiva solo aparece donde existe cambio legítimo.
- Contexto vivo conserva los 11 tipos relacionados mediante un selector compacto `Filtrar por tipo`; cada opción incluye conteo y abre el mismo inspector.

Archivos cambiados por el subagente `F1-PT-01`:

- `prototypes/fase1/app.js`
- `docs/product/REQUIREMENTS_BASELINE.md`
- `docs/product/ACCEPTANCE_CRITERIA.md`
- `docs/product/TRACEABILITY_MATRIX.md`
- `docs/testing/evidence/F01/PROJECT-WORKS-AUDIT-2026-07-23.md`

### Regresión ya ejecutada

- `node --check prototypes/fase1/app.js`: PASS.
- Invariantes: 4 Contrataciones, 8 Trabajos, 0 vacías, 0 atributos operativos prohibidos en Proyecto y 8/8 mapas relacionales.
- Aplicabilidad externa: 0 APT activos en Trabajos no catastrales.
- Reflujo del detalle: 0 px de desbordamiento horizontal en 360/768/1024/1440.
- Vistas generales y alta a 360 px: 0 px de desbordamiento en los recorridos probados.
- Inicio, Proyectos, Trabajo, Agenda, OneDrive, Aprobaciones, Notificaciones y Búsqueda: 42/42 enlaces operativos observados conservaron `work=`.
- Selector de Trabajo: cambió correctamente URL, estado, responsable, Contexto vivo y relaciones.
- IA: mostró correctamente `JBC-2026-0018 · TR-0018-02 · Croquis`.
- Filtro compacto: 11/11 opciones, selección `Tareas` abre el inspector, cerrar limpia el valor y devuelve el foco; 0 errores de consola y 0 px de overflow a 360 × 900.
- Convenciones UI: sidebar 220/244 px abierto y 64 px slim; compacto muestra únicamente la `J`, abierto alinea `J · JBC Proyectos · ×`; nombres accesibles, `aria-expanded`, foco visible y objetivo de 44 px. Aviso y detalle cierran con `×`; APT muestra `Actualización · Al día`; 0 overflow. La excepción móvil de `.record-detail-close` ya fue corregida y regresada.
- Densidad de Proyecto: se conservaron todos los bloques y funciones; los elementos visibles con borde bajaron de 36 a 8 (−77,8 %). Claro/oscuro y escritorio/móvil mantuvieron 0 overflow; el filtro e inspector siguieron operativos y la consola quedó en 0 errores.
- Pie del sidebar: `Sistema`, `Administración`, `Estados de interfaz` y `Prototipo · Fase 1` ya no aparecen; `⚙ Configuración` queda al fondo, se reduce al engranaje en 64 px, abre `#administracion`, activa el enlace y mantiene 0 overflow.

Incidente conocido de QA: una pestaña reutilizada conservó JavaScript anterior en caché y mostró el área principal vacía. Una pestaña nueva con query de versión cargó el código actual y toda la regresión pasó. Después de cada edición, usar pestaña nueva o query cache-busting; no registrar ese síntoma como defecto vigente sin reproducirlo con el corte fresco.

## 5. Estado de los hallazgos independientes

| Hallazgo R1                                        | Estado                | Acción restante                                |
| -------------------------------------------------- | --------------------- | ---------------------------------------------- |
| P1-01 — atributos de Trabajo mezclados en Proyecto | corregido y regresado | confirmar en R2                                |
| P1-02 — APT/SIRI no condicionado al Trabajo        | corregido y regresado | confirmar en R2                                |
| P1-03 — evidencia accesible incompleta             | **abierto**           | ejecutar pruebas reales, corregir y documentar |
| P2-01 — carga general fuera del compositor         | corregido             | confirmar en R2                                |
| P2-02 — capturas vigentes y obsoletas mezcladas    | **abierto**           | archivar y regenerar                           |
| P3-01 — evidencia inferida marcada como verificada | **abierto**           | reclasificar con método y resultado real       |

No editar el informe R1. Crear un documento R2 independiente al terminar las correcciones.

## 6. Secuencia exacta que falta

### Paso 1 — Establecer un corte fresco

1. Leer las fuentes de la sección 2 y comprobar que Fase 2 sigue sin cambios.
2. Revisar archivos/timestamps actuales porque no existe Git.
3. Servir `prototypes/fase1` localmente, por ejemplo:

   ```powershell
   Set-Location 'C:\Users\JBCTopografía\OneDrive - JBC Topografia\Documentos\AppGestionProyectos\prototypes\fase1'
   python -m http.server 41731 --bind 127.0.0.1
   ```

4. Abrir una pestaña fresca con query de versión, por ejemplo `http://127.0.0.1:41731/?v=f1-r2-a11y`.

### Paso 2 — Cerrar el P1 de accesibilidad

Ejecutar y documentar, como mínimo:

1. Recorrido de teclado de extremo a extremo: enlace de salto, sidebar normal/slim, navegación general, selector Proyecto/Trabajo, pestañas inmersivas, `Filtrar por tipo` con sus 11 opciones de Contexto vivo, inspector, compositor, menú `/`, adjunto, `Publicar` y apertura/cierre de IA.
2. Foco inicial, trampa de foco cuando corresponda y restauración al activador al cerrar inspector, selector/modal nativo y asistente; comprobar `Escape`.
3. Alternativa al arrastre completamente operable mediante `Adjuntar` con teclado y tacto; probar también arrastre físico al compositor si el entorno lo permite.
4. Zoom nativo del navegador al 200 % en rutas representativas, sin pérdida de controles/contenido ni scroll horizontal general.
5. axe-core sobre vistas generales, Proyecto con Trabajo catastral, Proyecto con Trabajo no catastral, Contexto vivo e IA, en claro/oscuro donde corresponda. Corregir todo resultado serio o crítico y repetir.
6. Verificación mínima con lector de pantalla en tema claro y oscuro: nombres, estados, orden, contexto activo, cambios anunciados y cierre de paneles.
7. Lighthouse puede añadirse como respaldo, pero no sustituye teclado, zoom, axe ni lector de pantalla.

Registrar cada caso con: fecha/hora, responsable, SO/navegador, viewport/zoom/tema, ruta/Trabajo, método, resultado `PASS|FAIL|PARCIAL|NO EJECUTADO`, hallazgo, corrección y artefacto. Si una prueba obligatoria no puede ejecutarse, no cerrar CP-UX.

Actualizar `docs/testing/evidence/F01/F01-ACCESSIBILITY-QA-2026-07-23.md` o crear una revisión R2 de accesibilidad sin borrar la evidencia anterior.

### Paso 3 — Ordenar y regenerar la evidencia visual

1. Verificar y mover de forma recuperable a una carpeta de archivo las capturas antiguas identificadas por R1:
   - `proyecto-768-claro.png`
   - `proyecto-360-claro.png`
   - `proyecto-360-oscuro.png`
   - `proyecto-1440-contexto-ia.png`
2. No sobrescribir ni eliminar a ciegas; comprobar rutas absolutas y que el destino esté dentro de `docs/testing/evidence/F01/archive/`.
3. Después de las correcciones accesibles, regenerar 360, 768, 1024 y 1440 px; cubrir claro y oscuro en escenarios representativos, Contexto vivo, IA y Contratación con varios Trabajos.
4. Crear un manifiesto con nombre, SHA-256, viewport, zoom, tema, URL/query, Proyecto/Trabajo, escenario, fecha y decisiones demostradas.
5. Actualizar el README de F01 para señalar un único corte activo.

### Paso 4 — Actualizar trazabilidad y reporte

1. Enlazar cada criterio accesible/responsive a evidencia real.
2. Diferenciar lo verificado de lo inferido mediante los cuatro estados acordados.
3. Actualizar `docs/product/TRACEABILITY_MATRIX.md` y el borrador `docs/ai/PHASE_1_REPORT.md`.
4. Repetir `node --check` y la regresión funcional/overflow después de cualquier corrección.

### Paso 5 — Revisión independiente R2

1. Asignar un subagente revisor de solo lectura, sin autoría en los artefactos corregidos.
2. Pedir regresión explícita de los tres P1, ambos P2, el P3 y de los criterios de salida de Fase 1.
3. Crear un archivo nuevo, recomendado:
   `docs/architecture/reviews/F1/F1-INDEPENDENT-REVIEW-R2-2026-07-23.md`.
4. Exigir cero P0/P1 abiertos. Los P2/P3 deben quedar corregidos o aceptados explícitamente con responsable y fecha.

### Paso 6 — Checkpoint con el usuario

Solo con R2 favorable:

1. Convertir `PHASE_1_REPORT.md` en reporte final.
2. Actualizar `CURRENT_STATUS.md`, `CHECKPOINTS.md`, `FILE_OWNERSHIP.md` y este handoff.
3. Presentar al usuario el resultado, la evidencia y los P2/P3 residuales si existen.
4. Solicitar aprobación explícita de CP-UX.
5. Detenerse. **No iniciar Fase 2 hasta recibir esa aprobación.**

## 7. Límites y riesgos que deben preservarse

- No crear módulos productivos, migraciones, autenticación, SDK ni integraciones reales en Fase 1.
- No usar ni solicitar credenciales de OneDrive, Supabase, APT/SIRI u OpenAI.
- RF-013 sigue excluido: no importar ni sincronizar proyectos desde Excel.
- No confundir estado interno del Trabajo con estado oficial externo APT/SIRI.
- No devolver tipo/estado operativo al Proyecto ni perder `work=` en enlaces profundos.
- No ocultar Contexto vivo al abrir IA; en escritorio la IA forma una tercera columna a la derecha.
- No afirmar WCAG 2.2 AA solo por inspección estructural o equivalencia de ancho.
- Las fuentes obligatorias son `--font-ui: "Inter", "Segoe UI", sans-serif` y `--font-data: "Roboto Mono", Consolas, monospace`.

## 8. Prompt listo para el nuevo chat

Copiar y pegar:

```text
Continúa la Fase 1 del proyecto en:
C:\Users\JBCTopografía\OneDrive - JBC Topografia\Documentos\AppGestionProyectos

Antes de hacer cualquier otra cosa, lee completo:
1) C:\Users\JBCTopografía\.codex\attachments\a1a4d6f8-557a-4172-baf6-f04014eceb90\goal-objective.md
2) docs/ai/HANDOFFS/F1-CONTINUATION-2026-07-23.md
3) docs/architecture/reviews/F1/F1-INDEPENDENT-REVIEW-2026-07-23.md
4) docs/testing/evidence/F01/PROJECT-WORKS-AUDIT-2026-07-23.md

La Fase 1 NO está cerrada. Proyecto/Contratación 1:N Trabajos y APT/SIRI por Trabajo ya fueron corregidos y regresados; no los rediseñes. Contexto vivo usa un único desplegable `Filtrar por tipo` para sus 11 alcances; no restaures la cuadrícula grande anterior. Cierra el P1 de accesibilidad con evidencia real de teclado/foco, alternativa al arrastre, zoom nativo 200 %, axe-core y lector de pantalla; corrige lo encontrado, ordena/regenera las capturas, actualiza trazabilidad y reporte, y después solicita una revisión independiente R2 de solo lectura mediante subagente. Se requiere cero P0/P1 antes de presentar CP-UX. No inicies Fase 2 ni uses integraciones, credenciales o datos reales. Conserva los cambios existentes porque esta carpeta no tiene Git.

Mantén también `DEC-0115`: el contenido de Proyecto permanece completo, pero no deben volver los bordes redundantes en contenedor, tarjetas hijas y filas. Consulta `docs/testing/evidence/F01/F01-PROJECT-VISUAL-DENSITY-QA-2026-07-23.md` antes de cambiar esa jerarquía.

Mantén `DEC-0116`: en el sidebar compacto el encabezado muestra solo la `J`; no agregues un `☰`. Al abrir, `J`, `JBC Proyectos` y `×` deben permanecer en una fila. Consulta `docs/testing/evidence/F01/F01-SIDEBAR-BRAND-TOGGLE-QA-2026-07-23.md`.

Mantén `DEC-0117`: no restaures el grupo `Sistema` ni el pie `Prototipo · Fase 1` en el sidebar. Debe existir un único `⚙ Configuración` inferior, solo engranaje en slim. Consulta `docs/testing/evidence/F01/F01-SIDEBAR-SETTINGS-FOOTER-QA-2026-07-23.md`.
```
