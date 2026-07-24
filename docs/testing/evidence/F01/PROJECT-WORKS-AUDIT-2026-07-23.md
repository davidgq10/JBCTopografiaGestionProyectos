# Auditoría Proyecto → Trabajos — Fase 1

**ID:** F1-PT-01  
**Fecha:** 2026-07-23 (`America/Costa_Rica`)  
**Requisito auditado:** `DEC-0111`, RF-002, RF-019 y criterios relacionados  
**Resultado:** **CONFORME** para el modelo UX `Proyecto/Contratación 1:N Trabajo`  
**Límite del dictamen:** prototipo navegable de Fase 1; no declara construido el modelo productivo de Fase 2 ni cerrado G1.

## Regla validada

`Proyecto` representa la contratación y no posee tipo ni estado operativo de Trabajo. Toda Contratación contiene `1..N` Trabajos. Cada Trabajo conserva tipo, situación interna, responsable y relaciones operativas propias. Las vistas de Proyecto agregan esos Trabajos sin fusionarlos y las referencias operativas conservan simultáneamente Proyecto + Trabajo.

## Matriz requisito → evidencia

| Regla                                              | Evidencia del corte corregido                                                                                                                                                                                                                                                                                                                                          | Resultado |
| -------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------- |
| Proyecto/Contratación sin tipo ni estado operativo | `projects` conserva código neutral `JBC-*`, nombre, cliente y coordinación contractual; no contiene `type`, `status`, `owner`, `due` ni una ruta predefinida que oculte el Trabajo. Listado y encabezado distinguen coordinación contractual de estado/responsable del Trabajo activo.                                                                                 | PASS      |
| `1..N` Trabajos obligatorios                       | `worksByProject` contiene 4 Contrataciones y 8 Trabajos; ninguna Contratación queda vacía. El asistente de alta crea Contratación + al menos Trabajo 01 obligatorio y permite añadir más.                                                                                                                                                                              | PASS      |
| Independencia de tipo, estado y responsable        | Cada Trabajo ficticio tiene `id`, `type`, `status` y `owner`. El alta configura estado, responsable, prioridad, inicio y entrega por separado para Trabajo 01 y Trabajo 02.                                                                                                                                                                                            | PASS      |
| Caso heterogéneo realista                          | `JBC-2026-0018` contiene `TR-0018-01` Delimitación/En ejecución/Ana Solano y `TR-0018-02` Croquis/Planificado/Carlos Vega. `JBC-2026-0042` contiene tres planos con estados, responsables, contratos APT e hitos distintos.                                                                                                                                            | PASS      |
| Agregado sin fusión                                | Control general muestra cantidad y resumen de tipos/estados por Trabajo; el próximo hito identifica el Trabajo propietario. Reportes separan Contrataciones de Trabajos y filtran por tipo, estado y responsable de Trabajo. El detalle ofrece selector de todos los Trabajos y un reporte agregado que declara que no fusiona atributos.                              | PASS      |
| Rutas preservan selección                          | `projectRoute()` siempre serializa `id`, `work` y `tab`. Los 22 enlaces profundos literales auditados contienen `work=`. Inicio, Trabajo, Agenda, OneDrive, Aprobaciones, Notificaciones y Búsqueda abren el registro operativo con Proyecto + Trabajo.                                                                                                                | PASS      |
| Relaciones independientes                          | `workRelations` conserva conteos distintos de gestiones, tareas, agenda, archivos, aprobaciones, actividad, reportes e historial para los 8 Trabajos. Los identificadores relacionados se derivan con `workRecordId()` y el Contexto vivo cambia con el Trabajo activo.                                                                                                | PASS      |
| APT/SIRI por Trabajo aplicable                     | Solo los Trabajos `Plano de catastro` contienen APT/contrato activo. `TR-0018-01` demuestra historia externa legítimamente inactiva tras cambio aprobado, con tipo/estado anterior, actor, UTC y aprobación. Los demás Trabajos no catastrales no contienen propiedades activas; navegación y detalle externo se derivan de `isCatastroWork()`/`hasExternalHistory()`. | PASS      |
| OneDrive atribuido correctamente                   | Las rutas visibles y los enlaces de carpeta incluyen `Proyecto / Trabajo`; el compositor propone por defecto `Trabajo activo`; el binario continúa exclusivamente en OneDrive y la plataforma promete solo metadatos.                                                                                                                                                  | PASS      |
| IA conserva contexto                               | `activeAssistantContext()` devuelve Proyecto y Trabajo. `/tarea`, `/comentario`, `/agenda` y `/gestion` muestran `Proyecto / Trabajo`; desde vistas generales exigen seleccionarlos antes de confirmar.                                                                                                                                                                | PASS      |
| Vistas generales e inmersivas coexisten            | Se mantienen Inicio, Proyectos, Trabajo, Agenda, OneDrive, Aprobaciones, Notificaciones, Reportes y Búsqueda, junto con la navegación inmersiva por Contratación/Trabajo.                                                                                                                                                                                              | PASS      |

## Hallazgos y correcciones

### F1-PT-P1-01 — Alta incompleta para el segundo Trabajo — cerrado

El paso de equipo configuraba de manera explícita únicamente al Trabajo 01 y dejaba prioridad/fechas como campos singulares ambiguos. Se sustituyó por dos bloques operativos independientes, cada uno con estado inicial, responsable, prioridad, inicio y entrega; la coordinación permanece como atributo contractual separado.

### F1-PT-P1-02 — Referencias transversales sin `trabajoId` — cerrado

Tareas, agenda, avisos, aprobaciones y resultados de búsqueda mostraban en varios casos solo el código del Proyecto. Todas las referencias operativas representadas ahora muestran `Proyecto / Trabajo` y enlazan a la ruta inmersiva correspondiente con `work=` y `record=`.

### F1-PT-P1-03 — Contexto IA y documental insuficientemente atribuido — cerrado

Las propuestas del asistente conservaban solo Proyecto y algunas rutas documentales terminaban visualmente en la Contratación. El contexto IA ahora conserva ambos identificadores, una creación general exige seleccionarlos y OneDrive muestra el Trabajo propietario en ruta, metadatos y vínculos.

### F1-PT-P2-01 — Datos ficticios demasiado compartidos — cerrado

Conteos e identificadores relacionados eran iguales para cualquier Trabajo. Se incorporó `workRelations` y `workRecordId()` para demostrar gestiones, tareas, agenda, archivos, aprobaciones, actividad, reportes e historial independientes sin duplicar una entidad agregada.

### F1-PT-P2-02 — Semántica de código contractual — cerrado

Los prefijos `PC`, `DEL`, `CUR` y `AVA` podían sugerir un tipo único de Proyecto. Se reemplazaron por códigos contractuales neutrales `JBC-*`; el tipo permanece únicamente en cada Trabajo.

## Pruebas ejecutadas

| Prueba                                                                   | Resultado                                                                                          |
| ------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------- |
| `node --check prototypes/fase1/app.js`                                   | PASS; salida vacía, código 0                                                                       |
| Inspección estructural de datos ficticios                                | PASS: 4 Contrataciones, 8 Trabajos, 0 Contrataciones vacías, 8 mapas relacionales                  |
| Caso de tipos y estados distintos en una Contratación                    | PASS: 1 Contratación heterogénea explícita                                                         |
| Auditoría de enlaces profundos literales                                 | PASS: 22/22 contienen `work=`                                                                      |
| Ausencia de atributos operativos en `projects`                           | PASS: sin `type`, `status`, `owner`, `due` ni `href`                                               |
| Aplicabilidad externa                                                    | PASS: APT activo solo en catastro; no catastro sin campos activos salvo historia inactiva legítima |
| Búsqueda de códigos que codificaban tipo (`PC-`, `DEL-`, `CUR-`, `AVA-`) | PASS: 0 coincidencias en `app.js`                                                                  |

## Archivos corregidos durante la auditoría

- `prototypes/fase1/app.js`
- `docs/product/REQUIREMENTS_BASELINE.md`
- `docs/product/ACCEPTANCE_CRITERIA.md`
- `docs/product/TRACEABILITY_MATRIX.md`
- `docs/testing/evidence/F01/PROJECT-WORKS-AUDIT-2026-07-23.md`

Los ocho documentos `docs/ux/**` fueron contrastados y ya expresaban Proyecto/Contratación `1..N` Trabajos, rutas conceptuales con `proyectoId + trabajoId`, agregados sin fusión, APT/SIRI por Trabajo y Contexto vivo; no requirieron cambios en esta auditoría.

## Riesgos residuales y siguiente control

- El prototipo es estático y usa datos ficticios; las restricciones de base, RLS, cardinalidades e integridad referencial se implementarán y probarán en las fases autorizadas posteriores.
- La regresión visual/interactiva del corte corregido en 360/768/1024/1440 queda a cargo del orquestador antes del checkpoint de Fase 1.
- La revisión independiente R2 debe confirmar que no se reintroduce un tipo/estado singular de Proyecto y que todos los enlaces operativos conservan Trabajo.

## Dictamen

**CONFORME.** No queda incumplimiento P0/P1 conocido dentro del alcance específico `Proyecto/Contratación → 1..N Trabajos`. El Proyecto agrega; el Trabajo es la unidad operativa independiente.

## Regresión del orquestador posterior a la transferencia

El orquestador repitió la validación después de recibir los archivos del subagente:

| Comprobación independiente                         | Resultado                                                                                                                                                     |
| -------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Ejecución real del prototipo con recarga sin caché | PASS: la vista Proyectos renderiza 4 Contrataciones y sus agregados                                                                                           |
| Invariantes instrumentadas                         | PASS: 4 Contrataciones, 8 Trabajos, 0 vacías, 0 atributos `type/status/owner/due/href` en Proyecto y 8/8 mapas relacionales                                   |
| Códigos contractuales                              | PASS: todos usan prefijo neutral `JBC-`; no quedan `PC-`, `DEL-`, `CUR-` ni `AVA-`                                                                            |
| APT/SIRI                                           | PASS: 3 Trabajos catastrales activos, 1 historia inactiva legítima y 0 activos no catastrales                                                                 |
| Selector inmersivo                                 | PASS: al pasar de `TR-0042-01` a `TR-0042-02` cambian URL, estado, responsable, Contexto vivo y sus 9 conteos operativos                                      |
| Contratación heterogénea                           | PASS: `JBC-2026-0018` muestra Delimitación y Croquis con estados/responsables distintos; el segundo Trabajo no expone APT/SIRI                                |
| Alta manual                                        | PASS: Trabajo 01 y Trabajo 02 tienen tipo, estado, responsable, prioridad, inicio y entrega independientes; coordinación separada                             |
| Vistas generales                                   | PASS: Inicio, Proyectos, Gestiones/Tareas, Agenda, OneDrive, Aprobaciones, Notificaciones y Búsqueda; 42/42 enlaces operativos observados conservaron `work=` |
| Reflujo del detalle                                | PASS: 1440, 1024, 768 y 360 px con 0 px de desbordamiento horizontal; 3 tarjetas de Trabajo y 11 alcances de Contexto vivo                                    |
| Reflujo de vistas generales y alta                 | PASS: 360 px, 0 px de desbordamiento horizontal en las rutas y pasos probados                                                                                 |
| Contexto de IA                                     | PASS: muestra `JBC-2026-0018 · TR-0018-02 · Croquis`                                                                                                          |

La primera carga de una pestaña reutilizada conservó un recurso JavaScript anterior en caché y dejó el área principal vacía; una pestaña nueva con identificador de versión cargó el corte actual y toda la regresión anterior pasó. No se identificó un defecto del código vigente.
