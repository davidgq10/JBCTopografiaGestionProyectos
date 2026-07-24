# Revisión independiente de arquitectura y UX — Fase 1

**ID:** F1-ARCH-01  
**Fecha:** 2026-07-23 (`America/Costa_Rica`)  
**Rol:** revisión independiente, sin autoría ni modificación de los artefactos revisados  
**Dictamen:** **NO-GO para cerrar G1 en el corte actual; GO condicional únicamente después de corregir y revalidar los P1**

## 1. Alcance y base de revisión

Se contrastaron la especificación aprobada y sus anexos, el objetivo y estado de F1, `DEC-0101` a `DEC-0112`, la documentación vigente de `docs/ux/**` y `docs/product/**`, el prototipo estático de `prototypes/fase1/**` y la evidencia de `docs/testing/evidence/F01/**`.

La revisión cubrió expresamente:

- arquitectura de información, navegación general e inmersiva;
- accesibilidad, reflujo y evidencia en 360, 768, 1024 y 1440 px;
- Proyecto/Contratación `1:N` Trabajos y separación de estados;
- aplicabilidad de APT/SIRI por Trabajo;
- Contexto vivo con los 11 alcances aprobados;
- inspección en sitio y apertura del objeto operativo mediante enlace real;
- compositor único, adjuntos y límite de almacenamiento OneDrive;
- ubicación, propuestas y confirmación humana de IA;
- sidebar slim, propuesta IA compacta, temas y fuentes contractuales;
- exclusión de RF-013.

## 2. Integridad del corte revisado

- La especificación completa fue leída y su integridad se comprobó mediante el hash registrado para el corte aprobado (`SHA-256 A35DB4…C6E`).
- Las decisiones `DEC-0105` a `DEC-0112` constan como aprobadas el 2026-07-23; `DEC-0103` y `DEC-0104` siguen pendientes y no se utilizaron para ampliar el alcance.
- No se identificaron secretos, datos reales, llamadas de red ni contacto con OneDrive, Supabase, APT, SIRI u OpenAI en el prototipo.
- La evidencia vigente usa datos ficticios. Esta revisión no realizó escrituras reales, despliegues ni cambios en `prototypes/fase1/**`, `docs/ux/**`, `docs/product/**` o la evidencia.

La documentación UX y de producto es, en términos generales, coherente con las decisiones aprobadas. Los bloqueos se concentran en contradicciones del prototipo y en evidencia de aceptación aún incompleta.

## 3. Hallazgos

### P0 — Críticos

**No se identificaron hallazgos P0.**

### P1 — Bloqueantes para G1

#### F1-REV-P1-01 — El prototipo todavía mezcla atributos del Proyecto/Contratación con atributos de un Trabajo

**Evidencia:** `prototypes/fase1/app.js`, en los datos `projects`, `projectTable()`, `renderProyectos()`, el asistente de creación y `renderProject()`.

Aunque el detalle inmersivo permite seleccionar tres Trabajos independientes, la vista general conserva un único `type` y `status` en cada Proyecto y muestra columnas singulares **Tipo** y **Estado interno**. El flujo **Crear proyecto** solicita un único **Tipo de proyecto**, no representa de forma inequívoca la contratación más su primer Trabajo obligatorio, y confirma una sola entidad conceptual. El encabezado y varias vistas transversales siguen tratando el tipo y el estado como si pertenecieran al Proyecto. También quedan operaciones y etiquetas como **Cambiar tipo de proyecto**, distribución por tipo de proyecto y administración de tipos de proyecto.

**Contradicción:** `DEC-0111`, RF-002 y RF-019 establecen que el Proyecto representa la contratación y contiene `1:N` Trabajos; tipo, estado, responsable, agenda, APT/SIRI, archivos e historial pertenecen al Trabajo. La implementación parcial del selector de Trabajos no compensa la mezcla en listado, alta, reportes y administración.

**Riesgo:** decisiones operativas y reportes ambiguos, pérdida de trazabilidad y diseño de contratos de aplicación incompatible con el modelo aprobado.

**Corrección requerida:** eliminar el tipo y estado singulares del Proyecto en todos los recorridos; mostrar un agregado explícito de Trabajos en vistas transversales; hacer que el alta cree la Contratación y al menos un Trabajo claramente separado; corregir terminología, filtros, reportes, aprobaciones y administración; añadir casos con Trabajos de tipos y estados diferentes bajo la misma contratación.

#### F1-REV-P1-02 — APT/SIRI no está condicionado de forma íntegra al Trabajo aplicable

**Evidencia:** `projectNavigation()`, `projectSummary()`, `projectExternal()`, `projectActivity()`, `projectChatter()` y `relatedView("tramites", …)` en `prototypes/fase1/app.js`.

El prototipo mantiene **Trámites** y referencias APT/SIRI para Trabajos no catastrales, presenta el texto **APT/SIRI no aplica**, fabrica una historia de cambio de tipo y puede mostrar actividad **APT requiere atención** sin condicionar el contenido al Trabajo activo. La ruta de trámites y el inspector también construyen registros APT/SIRI para cualquier Trabajo.

**Contradicción:** los invariantes, `DEC-0111` y la documentación UX exigen APT/SIRI de solo lectura exclusivamente para **Plano de catastro**, asociados al Trabajo y nunca mezclados con el estado interno. Una historia inactiva solo es válida cuando existe historia real; no debe inventarse ni aparecer como superficie activa para un Trabajo que nunca fue catastral.

**Riesgo:** exposición de estados externos irrelevantes, falsa trazabilidad y confusión entre estado interno y fuente oficial.

**Corrección requerida:** derivar navegación, tarjetas, inspector, actividad e historial desde la aplicabilidad y la historia real del Trabajo activo; ocultar superficies APT/SIRI cuando nunca aplicaron; conservar una historia inactiva únicamente si existe evidencia del cambio, con fecha de corte y sin mutar el estado interno; probar al menos un Trabajo catastral, uno no catastral sin historia y uno con historia legítimamente inactiva.

#### F1-REV-P1-03 — Falta evidencia de aceptación obligatoria de accesibilidad

**Evidencia:** `F01-ACCESSIBILITY-QA-2026-07-23.md` y `F01-RESPONSIVE-INTERACTION-QA-2026-07-23.md` declaran pendientes el recorrido completo de teclado, el gesto físico de arrastre y devolución de foco, zoom nativo al 200 %, axe-core, lector de pantalla real y Lighthouse.

La inspección estructural muestra nombres accesibles, foco visible, objetivos táctiles y reflujo sin desbordamiento, pero eso no demuestra todavía WCAG 2.2 AA ni la operación completa por teclado. La equivalencia de ancho no sustituye la prueba de zoom nativo.

**Riesgo:** cerrar F1 con una condición transversal obligatoria no demostrada y trasladar defectos de interacción a fases técnicas posteriores.

**Corrección requerida:** ejecutar y conservar evidencia reproducible de teclado de extremo a extremo, foco inicial y restauración, alternativa al arrastre, zoom 200 %, axe-core y una verificación mínima con lector de pantalla en ambos temas. Los hallazgos de esas ejecuciones deberán corregirse y regresarse antes de G1.

### P2 — Importantes, no bloqueantes por sí solos

#### F1-REV-P2-01 — La ruta general de Archivos ofrece una carga separada del compositor contractual

`renderArchivos()` expone **Subir documento** como acción general simulada. Esto abre una segunda entrada conceptual que no demuestra selección de Proyecto/Trabajo, propuesta de carpeta, revisión humana y el único **Publicar** definidos por `DEC-0110`.

**Recomendación:** convertir la vista general en búsqueda/navegación y, si se inicia una carga, exigir seleccionar Proyecto y Trabajo y continuar en el mismo compositor contractual. No mantener una carga paralela.

#### F1-REV-P2-02 — La carpeta de evidencia mezcla capturas vigentes y capturas obsoletas

Las capturas `*-trabajos*.png` reflejan el corte vigente, pero en la misma carpeta permanecen imágenes como `proyecto-768-claro.png`, `proyecto-360-claro.png`, `proyecto-360-oscuro.png` y `proyecto-1440-contexto-ia.png` con la interfaz anterior: pestañas de modo, **Crear documento**, dropzone independiente o ausencia del selector de Trabajos. Esto contradice visualmente las comprobaciones de máquina aun cuando el README intenta señalar el subconjunto vigente.

**Recomendación:** retirar del paquete de aceptación o archivar fuera del corte las capturas obsoletas, añadir manifiesto con hash, viewport, tema, URL/estado y decisión cubierta, y regenerar el conjunto después de corregir los P1.

### P3 — Menores

#### F1-REV-P3-01 — La evidencia debe distinguir “verificado” de “inferido”

La matriz responsive marca como PASS algunos comportamientos cuyo equivalente completo queda declarado como manual o posterior, especialmente zoom, teclado y arrastre. No es un defecto visual confirmado, pero reduce la precisión del paquete probatorio.

**Recomendación:** usar estados `PASS`, `FAIL`, `PARCIAL` y `NO EJECUTADO`, con responsable, método, fecha y artefacto enlazado.

## 4. Controles conformes observados

Sin perjuicio de los P1 anteriores, el corte demuestra correctamente los siguientes aspectos:

- navegación dual: vistas generales y navegación inmersiva por Proyecto coexisten;
- detalle inmersivo con tres Trabajos seleccionables y cambio de contexto visible;
- Contexto vivo con los 11 alcances exactos: Trabajos, Datos, Gestiones, Tareas, Agenda, Trámites, Archivos, Aprobaciones, Actividad, Reportes e Historial;
- inspector en sitio y enlaces reales hacia vistas operativas de tareas, archivos y otros objetos;
- compositor visual único, adjunto integrado y un solo botón **Publicar** en el contexto del Proyecto;
- propuesta de clasificación de adjuntos con destino OneDrive editable, explicación, descarte y revisión humana; el prototipo conserva únicamente la promesa de metadatos y no transfiere binarios;
- IA contextual persistente, compositor antes de la conversación, propuesta compacta antes de los estados y confirmación humana antes de cambios;
- sidebar expandible y slim de 64 px con nombre accesible;
- temas automático, claro y oscuro, fondos neutros y fuentes contractuales `Inter`/`Segoe UI` y `Roboto Mono`/`Consolas`;
- evidencia de reflujo sin desbordamiento horizontal en 360, 768, 1024 y 1440 px para el corte vigente;
- RF-013 permanece excluido: no hay importación ni sincronización desde Excel.

## 5. Dictamen y condiciones de salida

### Dictamen actual

**NO-GO para cerrar G1.** No hay P0, pero existen tres P1: dos contradicciones funcionales del prototipo con el modelo aprobado y una carencia de evidencia obligatoria de accesibilidad.

### GO condicional

El corte podrá proponerse de nuevo como **GO** cuando se cumplan, conjuntamente, estas condiciones:

1. cerrar `F1-REV-P1-01` con coherencia completa Proyecto/Contratación `1:N` Trabajos en alta, listado, detalle, reportes, aprobaciones y administración;
2. cerrar `F1-REV-P1-02` con APT/SIRI derivado exclusivamente del Trabajo aplicable y de historia real;
3. cerrar `F1-REV-P1-03` con evidencia reproducible de teclado, foco, alternativa al arrastre, zoom 200 %, axe-core y lector de pantalla;
4. regenerar las capturas vigentes en 360, 768, 1024 y 1440 px, en claro y oscuro donde corresponda, sin artefactos obsoletos en el paquete activo;
5. actualizar la matriz de trazabilidad con enlaces a correcciones, pruebas y evidencia;
6. solicitar una regresión independiente que confirme cero P0/P1 abiertos.

Los P2 y P3 deberán registrarse y resolverse o aceptarse explícitamente con responsable y fecha; no justifican por sí solos un NO-GO después de cerrar todos los P1.
