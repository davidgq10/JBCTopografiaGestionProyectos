# Arquitectura de información de la PWA JBC

Estado: **propuesta de Fase 1 para checkpoint de usuario**  
Fecha de corte: 2026-07-23 (`America/Costa_Rica`)  
Alcance: estructura, navegación y rutas conceptuales; no define permisos finos ni implementación.

## Objetivo

La arquitectura prioriza las decisiones que una persona debe tomar hoy y conserva el contexto `Cliente → Proyecto/contratación → Trabajo → Gestión → Tarea → Programación`. La aplicación se diseña primero para 360 px, en español y sin depender de hover, arrastre ni tablas anchas.

La navegación aprobada para Fase 1 es **dual**:

1. **Espacio general/transversal:** cruza proyectos y ofrece Inicio, Todos los proyectos, Trabajo, Agenda, OneDrive, Aprobaciones, Notificaciones y Reportes, siempre filtrados por el alcance efectivo; `Configuración` ocupa un único destino inferior según permiso.
2. **Espacio inmersivo de proyecto:** al abrir una contratación conserva proyecto, cliente y situación agregada; permite seleccionar uno de sus `1..N` Trabajos y reúne lo relacionado sin obligar a volver a vistas generales.

Ambos espacios son complementarios. Entrar a un proyecto no elimina las vistas transversales; cambia el contexto de navegación y ofrece un retorno explícito a `Todos los proyectos` o `Navegación general`.

Estas reglas son obligatorias en toda vista:

- los proyectos se crean manualmente; no existe entrada, ruta ni acción para importar Excel;
- la situación agregada del Proyecto, la Situación interna de cada Trabajo y el Estado oficial externo son conceptos separados;
- APT/SIRI es solo lectura, solo está activo para un Trabajo de tipo `Plano de catastro` y nunca ofrece presentar, cargar o modificar;
- OneDrive es el único lugar de binarios; la PWA muestra referencias y operaciones, no un almacén alterno;
- la IA presenta propuestas sustentadas; una persona autorizada decide;
- conforme a `DEC-0107`, el asistente IA es transversal y persistente en la sesión: hereda contexto/alcance, ofrece comandos `/`, prepara borradores y nunca escribe sin revisión y confirmación humana;
- conforme al refinamiento de `DEC-0108`, Actividad usa un compositor único: texto sin `/` publica una anotación del usuario; un comando `/` crea el tipo seleccionado por el flujo normal; adjuntos se arrastran o eligen dentro del mismo compositor y un solo botón `Publicar` confirma todo;
- conforme al refinamiento de `DEC-0109`, cada proyecto ofrece un `Contexto vivo` ancho como pilar relacional, con once alcances incluido Trabajos; la IA se abre a su derecha cuando el ancho seguro lo permite y se apila/usa drawer accesible cuando no;
- la navegación principal de escritorio puede compactarse a rail slim de iconos; cada destino mantiene nombre accesible, tooltip en hover/foco y marcador textual/semántico de selección;
- toda región responde al ancho real de su contenedor: grids colapsan, encabezados/badges envuelven y textos largos hacen wrap; hay cero desbordamiento (`overflow`) horizontal a 360/768/1024/1440 y con zoom 200 %;
- las fechas se muestran en hora de Costa Rica y el historial conserva su marca UTC;
- conforme a `DEC-0106`, las superficies usan grises neutros y existen temas Claro/Oscuro/Sistema; la opción inicial es Sistema salvo preferencia explícita del usuario, y el acento nunca domina el fondo;
- una ruta visible no concede permiso: el servidor valida rol y alcance en cada lectura y comando.

Fuentes: [línea base](../product/REQUIREMENTS_BASELINE.md), [criterios](../product/ACCEPTANCE_CRITERIA.md), [límites de módulos](../architecture/MODULE_BOUNDARIES.md) y [decisiones](../ai/DECISIONS_LOG.md).

Tipografías obligatorias del contrato UX:

- `--font-ui: "Inter", "Segoe UI", sans-serif;`
- `--font-data: "Roboto Mono", Consolas, monospace;`

## Personas y tareas principales

Los cuatro roles provienen de RF-010. Esta tabla describe necesidades UX; los permisos efectivos aprobados en `DEC-0103` se aplican en servidor/RLS. Las acciones sensibles dependen además de `DEC-0104`.

| Persona       | Necesita comprender                                                  | Tareas frecuentes                                                                     | Salvaguarda UX                                                                                       |
| ------------- | -------------------------------------------------------------------- | ------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| Administrador | salud, configuración, usuarios, auditoría y acciones de alto impacto | mantener catálogos, revisar operación y resolver acciones autorizadas                 | comparativo, motivo, versión y aprobación antes de ejecutar                                          |
| Coordinador   | carga, riesgos, agenda, aprobaciones y próximos vencimientos         | priorizar, asignar, programar, revisar y decidir dentro de su alcance                 | conflicto visible, última actualización y resumen de impacto                                         |
| Técnico       | trabajo asignado, información de campo, documentos y seguimientos    | actualizar gestiones/tareas, programar bloques, cargar evidencia y solicitar acciones | formulario móvil completo, borrador local no sensible solo durante la sesión y confirmación servidor |
| Solo lectura  | estado confiable y trazabilidad                                      | consultar, buscar, filtrar, revisar historial y descargar solo si está autorizado     | controles de modificación ausentes y explicación clara de alcance                                    |

## Modelo mental

### Objetos de negocio

1. **Cliente**: identidad reutilizable, contactos, direcciones, proyectos y referencias documentales.
2. **Proyecto**: contratación creada manualmente para un cliente; contiene de uno a muchos Trabajos y presenta un agregado sin fusionar sus estados.
3. **Trabajo**: unidad técnica independiente dentro del Proyecto, con tipo/configuración propios —plano, levantamiento u otro autorizado—, Situación interna, responsables y relaciones operativas. Una contratación catastral puede contener varios Trabajos de plano independientes.
4. **Gestión**: actuación cronológica perteneciente a un Trabajo, con responsable, seguimiento, anotaciones versionadas y resultado.
5. **Tarea**: unidad ejecutable de un Trabajo con subtareas, lista, dependencias, vencimiento y avance.
6. **Bloque de agenda**: tiempo reservado para ejecutar una tarea/Trabajo; no es su fecha límite.
7. **Trámite externo**: observación APT o SIRI independiente, de solo lectura y exclusiva de un Trabajo tipo Plano de catastro.
8. **Elemento OneDrive**: archivo o carpeta del Proyecto/Trabajo referenciado mediante metadatos e identificadores; el binario permanece en OneDrive.
9. **Solicitud de aprobación**: decisión versionada separada de su ejecución y vinculada al Proyecto/Trabajo afectado.
10. **Propuesta IA**: recomendación con evidencia, confianza y fecha de corte; nunca dato confirmado.
11. **Evento de historial**: registro de solo adición con actor, resultado, motivo, correlación y fecha UTC.
12. **Actividad de proyecto**: cronología contextual de anotaciones, comandos, propuestas, adjuntos y eventos. El compositor único no tiene pestañas de modo.
13. **Contexto vivo**: proyección autorizada y bidireccional del objeto activo con Trabajos, Datos, Gestiones, Tareas, Agenda, Trámites, Archivos, Aprobaciones, Actividad, Reportes e Historial; inspecciona y enlaza fuentes de verdad, no las duplica.

### Vistas de consulta

`Inicio`, `Buscar`, `Control General` y `Reportes` son proyecciones autorizadas, no fuentes de verdad. Siempre enlazan al objeto propietario y muestran fecha de corte cuando un total o resumen no es instantáneo. El asistente transversal consulta solo esas fuentes autorizadas y nunca se convierte en propietario.

## Navegación dual

### Capa general/transversal

La capa general responde “¿qué requiere atención en toda mi área?” y contiene estos destinos estables: Inicio, Todos los proyectos, Trabajo, Agenda, OneDrive, Aprobaciones, Notificaciones y Reportes. `⚙ Configuración` es el único destino al pie del sidebar; Buscar, Control General, Salud, Auditoría, el acceso persistente al Asistente y Cuenta se integran en el encabezado, Configuración o Más según ancho y permiso.

`Trabajo` reúne las bandejas transversales de Gestiones y Tareas; no crea un nuevo propietario de datos. `OneDrive` reúne referencias autorizadas de clientes/proyectos y siempre conduce al objeto propietario antes de una operación contextual.

### Capa inmersiva de proyecto

La capa de proyecto responde “¿qué contrató el cliente, qué ocurre en cada Trabajo y qué debo hacer después?”. Mantiene Proyecto y Trabajo seleccionado en la barra de contexto y da acceso a:

- Resumen agregado de la contratación;
- Trabajos `1..N`, con selector y situación propia;
- Cliente, inmuebles/lotes y participantes;
- Gestiones del Trabajo seleccionado y agregado autorizado;
- Tareas, listas y dependencias por Trabajo;
- Programación, personas y recursos por Trabajo;
- Trámites APT/SIRI, solo en cada Trabajo tipo Plano de catastro;
- Documentos OneDrive del Proyecto y del Trabajo;
- Aprobaciones del proyecto;
- Notificaciones del proyecto;
- Asistente IA del proyecto;
- Reportes, entregables y exportaciones del proyecto;
- Historial y auditoría del proyecto.

Si el Trabajo seleccionado no es Plano de catastro, Trámites no existe para ese Trabajo. Si antes lo fue, sus eventos externos aparecen únicamente como `Historia APT/SIRI inactiva` en su Historial; los demás Trabajos del Proyecto no cambian.

Actividad es un alcance del Contexto vivo y sigue siendo complementaria. El Contexto vivo es un pilar ancho, no un panel auxiliar estrecho. Sus filas relacionadas ofrecen un nombre/acción primaria que abre la vista operativa normal y una acción secundaria `Inspeccionar aquí`. Si se abre IA y hay ancho seguro, aparece inmediatamente a su derecha; si no cabe, se apila o pasa a drawer accesible.

### Teléfono: navegación general, 360–767 px

La navegación inferior mantiene cinco destinos, cada uno con área táctil mínima de 44 × 44 px:

1. `Inicio`;
2. `Proyectos`;
3. `Trabajo`;
4. `Agenda`;
5. `Más`.

El encabezado compacto ofrece `Buscar`, `Abrir asistente` y `Notificaciones` como acciones secundarias de 44 px. `Más` es una página, no un menú dependiente de hover, y agrupa únicamente destinos autorizados:

- Trabajo y archivos: Clientes y OneDrive.
- Decisiones: Aprobaciones y acceso alternativo a Notificaciones.
- Análisis: Control General, Reportes y Asistente IA.
- Configuración: preferencias, catálogos, Salud, Auditoría y versión, si corresponden al permiso efectivo.
- Cuenta: tema/apariencia, preferencias, notificaciones y dispositivos.

El botón Atrás del sistema conserva la jerarquía. Ningún flujo crítico termina en un callejón sin salida: cada éxito ofrece `Ver registro` y un siguiente paso contextual.

### Teléfono: navegación inmersiva de proyecto

Al entrar a `/proyectos/:proyectoId/*`, la navegación inferior cambia a `Resumen`, `Trabajos`, `Trabajo`, `Agenda` y `Más del proyecto`. El encabezado conserva Proyecto, Trabajo seleccionado y accesos `Contexto`, `Actividad`, asistente y avisos. `Trabajo` reúne Gestiones/Tareas del Trabajo activo; Documentos permanece en Más y Contexto vivo. Cambiar Trabajo no mezcla estados ni fuentes externas.

El cambio de capa no destruye filtros/posición de la vista general. `Navegación general` permanece disponible en Más del proyecto y el botón Atrás vuelve al origen cuando el proyecto se abrió desde Trabajo, Agenda, OneDrive, Aprobaciones o Notificaciones.

### Tableta, 768–1023 px

- barra lateral colapsable o `Drawer` con destinos generales; dentro de proyecto, el Drawer cambia a índice local y mantiene `Volver a navegación general`;
- encabezado con búsqueda, notificaciones y cuenta;
- dentro del proyecto, `Contexto` abre un drawer ancho con alcance Trabajos y los otros diez; Actividad abre el compositor único y el asistente se apila sin borrar Proyecto/Trabajo/relación;
- una columna para formularios; panel auxiliar debajo del principal;
- agenda textual predeterminada en orientación vertical y calendario opcional en horizontal;
- acciones de fila disponibles mediante botón explícito, nunca solo al deslizar.

### Escritorio, 1024–1440+ px

- barra lateral persistente: expandida alinea `J`, `JBC Proyectos` y `×` en el encabezado; slim muestra únicamente la `J` como botón accesible para expandir y conserva los iconos de destino con nombre/tooltip;
- contenido centrado, máximo 1440 px; vistas operativas pueden llegar a 1600 px;
- encabezado de página con título, contexto, estado y una acción primaria;
- panel secundario paralelo solo cuando reduce saltos de contexto; no genera tarjetas anidadas;
- en proyecto, Contexto vivo ocupa un pilar derecho más ancho; si el ancho real permite tres zonas útiles, la IA se abre en otra barra a su derecha;
- tablas paginadas sin borde exterior ni separadores verticales.

El rail slim puede liberar ancho, pero nunca se usa para forzar tres columnas ilegibles. Si no caben sección + Contexto vivo ancho + IA, la IA se apila/pasa a drawer y Contexto conserva Proyecto, Trabajo, objeto, relación y posición. El patrón esperado es grid fluido por contenedor y cero overflow.

## Mapa de rutas conceptual

Los nombres `:clienteId`, `:proyectoId`, `:trabajoId`, `:gestionId`, `:tareaId` y `:solicitudId` representan identificadores opacos. La existencia de una ruta no fija su autorización; una respuesta sin alcance muestra el estado de permisos sin datos sensibles.

| Ruta                                                          | Propósito                                                                                | Navegación móvil                                      | Condición o restricción                                                                               |
| ------------------------------------------------------------- | ---------------------------------------------------------------------------------------- | ----------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| `/inicio`                                                     | prioridades, agenda próxima, riesgos y pendientes según rol                              | Inicio                                                | proyección accionable, no pared de tarjetas                                                           |
| `/buscar`                                                     | búsqueda global, filtros y resultados autorizados                                        | acción del encabezado                                 | RLS, paginación servidor y sin adelantar existencia no autorizada                                     |
| `/clientes`                                                   | lista, filtros y archivo lógico                                                          | Más → Clientes                                        | lectura y acciones según permiso efectivo                                                             |
| `/clientes/nuevo`                                             | alta manual y revisión de posible duplicado                                              | Clientes → Nuevo cliente                              | advertir; nunca fusionar automáticamente                                                              |
| `/clientes/:clienteId/:seccion?`                              | resumen, contactos, direcciones, proyectos, documentos e historial                       | selector de sección                                   | archivar con motivo; documentos en OneDrive                                                           |
| `/proyectos`                                                  | cartera y vistas guardadas                                                               | Proyectos                                             | filtros conservados en la sesión                                                                      |
| `/proyectos/nuevo`                                            | alta manual de contratación y su primer Trabajo                                          | Proyectos → Nuevo proyecto                            | no existe importador; confirma Proyecto + al menos un Trabajo                                         |
| `/proyectos/:proyectoId/resumen`                              | agregado de Trabajos, responsables, hitos, riesgos y próximos pasos                      | cabecera del proyecto                                 | el agregado no sustituye ni mezcla estados de Trabajo                                                 |
| `/proyectos/:proyectoId/trabajos`                             | lista `1..N`, tipos, estados y atención por Trabajo                                      | proyecto → Trabajos                                   | nombre/acción primaria abre la vista normal; Inspeccionar abre Contexto vivo                          |
| `/proyectos/:proyectoId/trabajos/nuevo`                       | alta manual de otro Trabajo en la contratación                                           | Trabajos → Nuevo trabajo                              | tipo/configuración y confirmación propios; sin importación Excel                                      |
| `/proyectos/:proyectoId/trabajos/:trabajoId/resumen`          | Situación interna, propuesta IA compacta y estado externo aplicable                      | seleccionar Trabajo                                   | identifica siempre Proyecto + Trabajo; no hereda estado de otro Trabajo                               |
| cualquier ruta de Proyecto/Trabajo + `panel=contexto&scope=…` | Contexto vivo de once alcances; `scope=actividad` abre el compositor único               | acciones `Contexto`/`Actividad` o `Inspeccionar aquí` | nombres/primarias enlazan vistas normales; inspector no duplica entidades                             |
| `/proyectos/:proyectoId/datos`                                | cliente, inmuebles/lotes y participantes del proyecto                                    | Más del proyecto → Datos                              | relaciones contextuales; editar cada propietario según permiso                                        |
| `/proyectos/:proyectoId/trabajos/:trabajoId/gestiones`        | línea cronológica y seguimiento del Trabajo                                              | selector de sección                                   | espera exige motivo y fecha                                                                           |
| `/proyectos/:proyectoId/trabajos/:trabajoId/tareas`           | tareas, listas y dependencias del Trabajo                                                | selector de sección                                   | alternativa explícita a arrastrar                                                                     |
| `/proyectos/:proyectoId/trabajos/:trabajoId/programacion`     | bloques, personas, equipos, vehículos y conflictos                                       | Agenda del Trabajo                                    | vencimiento y ejecución se etiquetan por separado                                                     |
| `/proyectos/:proyectoId/trabajos/:trabajoId/documentos`       | referencias OneDrive del Trabajo                                                         | selector de sección                                   | adjuntar desde compositor; no existe `Crear documento`; nunca eliminar documento                      |
| `/proyectos/:proyectoId/trabajos/:trabajoId/tramites`         | APT/SIRI activos, actualización e historia por trámite                                   | selector de sección                                   | ruta/enlace solo para ese Trabajo tipo Plano de catastro                                              |
| `/proyectos/:proyectoId/aprobaciones`                         | solicitudes/decisiones relacionadas con el proyecto                                      | Más del proyecto → Aprobaciones                       | misma fuente que bandeja general, filtrada por proyecto                                               |
| `/proyectos/:proyectoId/notificaciones`                       | avisos relacionados con el proyecto                                                      | Más del proyecto → Notificaciones                     | misma fuente persistente, filtrada por proyecto y permiso                                             |
| `/proyectos/:proyectoId/asistente`                            | centro de ejecuciones, propuestas, evidencia y configuración IA del proyecto             | Más del proyecto → Centro IA                          | el panel transversal sigue siendo la entrada de conversación/comandos                                 |
| `/proyectos/:proyectoId/entregables`                          | reportes, exportaciones, productos y entregables relacionados                            | Más del proyecto → Entregables                        | binarios en OneDrive; guardar/exportar auditado y aprobado cuando aplica                              |
| `/proyectos/:proyectoId/historial`                            | cronología agregada con filtro por Trabajo/módulo                                        | selector de sección                                   | append-only; cada evento conserva Proyecto, Trabajo, actor y UTC                                      |
| `/trabajo`                                                    | hub transversal de Gestiones y Tareas                                                    | Trabajo                                               | proyecciones autorizadas; no nuevo propietario de negocio                                             |
| `/gestiones`                                                  | bandeja transversal de seguimiento                                                       | Trabajo → Gestiones                                   | proyección por alcance                                                                                |
| `/gestiones/:gestionId`                                       | detalle, notas versionadas, tareas y documentos                                          | desde lista o proyecto                                | volver al proyecto conserva contexto                                                                  |
| `/tareas`                                                     | bandeja personal/de equipo autorizada                                                    | Trabajo → Tareas                                      | estado, vencimiento, bloqueo y prioridad visibles                                                     |
| `/tareas/:tareaId`                                            | detalle, lista, dependencias, programación e historial                                   | desde lista/agenda                                    | conflicto concurrente requiere resolución explícita                                                   |
| `/agenda`                                                     | agenda global accesible y calendario opcional                                            | Agenda                                                | lista inicial en celular; hora Costa Rica visible                                                     |
| `/onedrive`                                                   | vista transversal de documentos/carpetas autorizados                                     | Más → OneDrive; sidebar en escritorio                 | conduce al cliente/proyecto propietario; nunca almacén alterno                                        |
| `/aprobaciones`                                               | pendientes, resueltas y estados de ejecución                                             | Más → Aprobaciones                                    | composición exacta pendiente de DEC-0104                                                              |
| `/aprobaciones/:solicitudId`                                  | evidencia, comparativo, decisión y ejecución                                             | desde bandeja/aviso                                   | una aprobación obsoleta no se ejecuta                                                                 |
| `/notificaciones`                                             | centro persistente y filtros                                                             | encabezado                                            | entrega 07:00–20:00; cola silenciosa 20:00–07:00 Costa Rica                                           |
| `/asistente`                                                  | centro general de historial, evidencia, propuestas y configuración IA                    | Más → Asistente                                       | interacción cotidiana desde panel persistente; `store:false`, alcance explícito                       |
| `/control-general`                                            | equivalente normalizado del control previo                                               | Más → Control General                                 | sin importación/sincronización Excel                                                                  |
| `/reportes`                                                   | indicadores y exportación                                                                | Más → Reportes                                        | guardar en OneDrive requiere aprobación; exportación auditada                                         |
| `/auditoria`                                                  | consulta/exportación autorizada de auditoría                                             | Más → Auditoría                                       | solo adición; exportar se audita                                                                      |
| `/administracion/:seccion?`                                   | Configuración: catálogos, tipos, plantillas, recursos, usuarios, integraciones y límites | pie `⚙ Configuración` o Más → Configuración           | secciones filtradas por permiso; cambios sensibles aprobados                                          |
| `/salud`                                                      | aplicación, integraciones, ciclos, respaldo y restauración                               | Más → Salud                                           | muestra salud, última ejecución exitosa y antigüedad de datos, nunca secretos                         |
| `/perfil/:seccion?`                                           | cuenta, tema, acento, avisos y dispositivos                                              | Más → Cuenta                                          | inicia con preferencia del sistema salvo elección; el acento no sustituye fondo ni colores semánticos |

## Navegación dentro de un proyecto

El encabezado de proyecto siempre contiene, en este orden:

1. código/nombre de la contratación;
2. selector y código/nombre del Trabajo `n de N`;
3. tipo y versión de configuración del Trabajo;
4. Situación interna del Trabajo y situación agregada del Proyecto, sin fusionarlas;
5. responsable, próxima fecha y acción primaria de la sección actual.

En 360 px, la barra local ofrece Resumen, Trabajos, Trabajo, Agenda y Más. Más contiene Datos, Documentos, Aprobaciones, Notificaciones, Asistente, Entregables e Historial; Trámites solo aparece dentro del Trabajo efectivo tipo Plano de catastro. En escritorio el índice puede compactarse a slim sin perder nombres accesibles.

El Contexto vivo no sustituye una sección. En una fila relacionada, pulsar el nombre o la acción primaria abre la vista operativa normal del Trabajo, archivo, gestión, tarea o bloque de agenda; `Inspeccionar aquí` mantiene la consulta in situ. En tamaños insuficientes usa drawer ancho con cierre y retorno al disparador.

Al entrar desde una bandeja transversal, la vista local resalta la sección relacionada y conserva un retorno contextual: por ejemplo, una tarea abierta desde Trabajo vuelve a Trabajo, pero `Ver proyecto completo` activa la capa inmersiva sin perder el proyecto. Las acciones/avisos/aprobaciones contextuales actualizan las mismas entidades que sus vistas generales; no existen copias de estado.

### Resumen operativo de un Trabajo

El orden vertical es: `Propuesta IA compacta` → `Situación interna` → `Estado oficial externo`. La propuesta usa espacio y fondo sutil, con poco borde, y siempre conserva evidencia/confianza/corte; nunca se fusiona con el estado. `Estado oficial externo` solo se monta para el Trabajo tipo Plano de catastro. El Resumen del Proyecto agrega estos datos por Trabajo, sin inventar un estado único editable.

## Asistente IA transversal (`DEC-0107`)

- El disparador `Abrir asistente` está disponible en el AppShell general y el de proyecto. Dentro de proyecto, DEC-0109 coloca IA a la derecha del Contexto vivo cuando cabe; en ancho insuficiente se apila o usa drawer accesible. Nunca flota encima de navegación, contexto, acciones o alertas.
- El panel puede permanecer abierto al navegar durante la sesión. Una barra de contexto muestra `General · alcance autorizado` o `Proyecto JBC-… · Trabajo …` cuando hay uno seleccionado; cada cambio se anuncia y vuelve a comprobar permisos.
- El orden del panel es fijo: barra de contexto, compositor arriba y conversación/propuestas debajo. El foco inicial llega al compositor; los resultados nuevos se anuncian sin mover el foco salvo petición explícita.
- Escribir `/` en el compositor abre comandos. Cuando el foco no está en un campo editable, `/` puede abrir el asistente; existe siempre un botón táctil `Comandos` equivalente.
- Comandos mínimos de escritura: `/tarea`, `/agenda` y `/gestion`; opcionales de lectura: `/buscar` y `/resumen`.
- Los comandos de escritura producen un borrador estructurado con campos, evidencia, confianza y fecha de corte. La revisión humana precede al caso de uso normal.
- `/buscar` y `/resumen` son de lectura y respetan RLS/alcance; sus resultados enlazan a la fuente y muestran corte/evidencia.
- Una acción sensible nunca se ejecuta al confirmar un chat: después de revisar, entra al flujo de aprobación y doble control configurado.
- El Centro IA general/del proyecto conserva acceso a historial de ejecuciones/propuestas, evidencia y configuración autorizada. La persistencia visual de la conversación no cambia `store:false` ni autoriza conservar secretos/datos innecesarios.

## Actividad unificada de proyecto (`DEC-0108`)

- No existen pestañas `Mensaje`, `Nota interna` ni `Actividad`. Hay un único compositor, identificado por Proyecto y Trabajo/objeto relacionado cuando aplica.
- Texto sin `/` publica una anotación atribuida al usuario en la Actividad del Proyecto; puede quedar relacionada con el Trabajo/objeto activo sin cambiar su propietario.
- Con `/tarea`, `/gestion` o `/agenda`, el compositor muestra los campos del tipo seleccionado y `Publicar` invoca su caso de uso normal. No crea una copia paralela.
- La IA puede proponer texto o estructura dentro del compositor, siempre rotulada con evidencia, confianza y fecha de corte. Una persona edita/revisa/confirma; la IA no publica ni ejecuta.
- El propio compositor acepta arrastrar o seleccionar archivos. Al detectar un adjunto muestra, dentro del compositor, propuesta editable de tipo documental, relación y carpeta OneDrive con su explicación; no existe dropzone separada ni acción `Crear documento`.
- Un único botón `Publicar` confirma anotación, comando y adjunto. Antes de pulsarlo no hay carga; con error se conserva el texto y se permite reintentar o quitar el adjunto y volver a pulsar el mismo botón.
- El binario se carga exclusivamente a OneDrive. Supabase conserva solo metadatos, `driveId`/`driveItemId` y la relación con la entrada de Actividad.
- Un adjunto se archiva con motivo; nunca se elimina. Operaciones protegidas, masivas o sensibles conservan vista previa, versión, aprobación/doble control e idempotencia.
- Si OneDrive falla, el adjunto no se publica como disponible; se ofrecen Reintentar o Quitar adjunto, sin introducir otro botón de publicación.
- Actividad vive como alcance del Contexto vivo. La IA puede usar una barra adyacente a la derecha cuando cabe; en móvil/tableta o contenedor estrecho se apila/usa panel accesible y conserva Proyecto, Trabajo, sección, objeto inspeccionado y borrador.

## Contexto vivo relacional (`DEC-0109`)

- Es un pilar ancho disponible desde cualquier sección y cubre exactamente once alcances: Trabajos, Datos, Gestiones, Tareas, Agenda, Trámites, Archivos, Aprobaciones, Actividad, Reportes e Historial. Trámites sigue ausente para Trabajos no catastrales.
- Cada nombre relacionado es un enlace real y su acción primaria abre la vista operativa normal. `Inspeccionar aquí` abre dropdown/inspector/sidebar/modal/hoja sin navegar; ambas vías son accesibles y conservan retorno.
- Las relaciones son bidireccionales: por ejemplo, una Gestión muestra Tareas/Agenda/Archivos relacionados y una Tarea o bloque de Agenda permite volver a inspeccionar su Gestión. Se expone el mismo identificador/versión y la misma entidad propietaria, no una copia.
- El inspector muestra objeto actual, tipo de relación, fuente, estado, última actualización y permiso efectivo. Controles de crear, editar, vincular, adjuntar o archivar aparecen únicamente cuando el servidor los autoriza; `DEC-0103/0104` no se completan por suposición UX.
- Los archivos solo se arrastran/seleccionan en el compositor de Actividad, no sobre una dropzone independiente del pilar. La propuesta explica tipo, relación y carpeta OneDrive, y el único `Publicar` constituye la confirmación humana.
- Supabase conserva únicamente metadatos, `driveId`/`driveItemId` y relaciones después del resultado OneDrive. Error, conflicto, archivo y restauración siguen DEC-0108 y los controles de aprobación vigentes.
- En un contenedor suficientemente ancho, el orden horizontal es `sección activa → Contexto vivo → IA`. La IA recibe únicamente el contexto autorizado visible y abre a la derecha, sin superposición. Cuando no caben los mínimos, el orden DOM se conserva y las zonas se apilan o pasan a drawer; al cerrar/volver se restauran objeto, relación, posición y foco.

Al cambiar un Trabajo desde Plano de catastro a otro tipo:

- desaparecen el enlace y los campos activos de Trámites;
- cesa el monitoreo activo;
- el historial conserva una entrada de cambio con usuario, fecha UTC, tipo/estado anterior, tipo nuevo, aprobación y correlación;
- los eventos APT/SIRI previos se consultan solo como historia inactiva de ese Trabajo; los demás Trabajos permanecen intactos.

## Jerarquía y divulgación progresiva

- Encabezado: identidad, estado y acción primaria.
- Resumen visible: vencimientos, riesgos, espera, aprobaciones y cambios externos que requieren atención.
- Secciones: al menos 24 px entre ellas, primero espacio, luego título, fondo sutil/divisor y borde solo si aún hace falta.
- Detalle secundario: `Mostrar detalles`, acordeón o panel de pantalla completa; nunca tarjeta dentro de tarjeta.
- Acciones secundarias: menú con etiqueta accesible y lista completa también disponible por teclado/tacto.
- Historial: lo más reciente primero por defecto, con orden cronológico alternativo y marcas horarias explícitas.
- Contención: todo hijo permite encogerse; títulos, códigos/rutas, `Estado oficial externo` y badges APT/SIRI envuelven dentro de su zona sin recorte ni scroll horizontal.

## Reglas de rutas, enlaces y recuperación

- Un enlace profundo revalida sesión, permiso, alcance y versión; la notificación no contiene datos sensibles.
- Tras iniciar sesión se vuelve al destino autorizado; si no lo está, se ofrece `Ir a Inicio` sin revelar el registro.
- Una ruta de Trámites solicitada para un Trabajo no catastral responde con una sección genérica no disponible y no muestra nombres, campos ni estados APT/SIRI; no afecta otros Trabajos del Proyecto.
- Los filtros viven en la URL cuando deben compartirse; las preferencias de sesión no generan rutas imposibles de recuperar.
- Un estado sin conexión mantiene el AppShell y la ruta, muestra la última vista no sensible permitida por la política y deshabilita toda modificación.
- Entorno y versión se ven dentro de `Configuración` y en Más/cuenta según permiso; fuera de Producción, el entorno aparece además como aviso persistente, no como pie técnico del sidebar.

## Documentos relacionados

- [Flujos de usuario](./USER_FLOWS.md)
- [Principios visuales](./VISUAL_PRINCIPLES.md)
- [Tokens de diseño](./DESIGN_TOKENS.md)
- [Inventario de componentes](./COMPONENT_INVENTORY.md)
- [Matriz de estados](./STATE_MATRIX.md)
- [Wireframes textuales](./WIREFRAMES.md)
- [Checklist móvil y accesibilidad](./MOBILE_ACCESSIBILITY_CHECKLIST.md)
