# Flujos de usuario

Estado: **propuesta de Fase 1 para checkpoint de usuario**  
Cobertura: RF-001 a RF-012, RF-014 a RF-020; RF-013 permanece excluido.

## Convenciones

- `A/C/T/L` significa Administrador, Coordinador, Técnico y Solo lectura.
- “Actor autorizado” significa que el servidor confirmó rol y alcance conforme a `DEC-0103`, además de transición y versión; la interfaz no concede permisos.
- “Decisor autorizado” no fija la composición pendiente en `DEC-0104`; donde el RF ya exige dos personas, la interfaz impide que una sola complete ambas participaciones.
- Todos los flujos usan los diez estados universales `S01–S10`: carga, actualización, vacío, error, permisos, degradación, datos antiguos, sin conexión, éxito y conflicto. Su comportamiento está en [STATE_MATRIX.md](./STATE_MATRIX.md).
- Toda hora operativa se presenta como `America/Costa_Rica`; los detalles de auditoría muestran además la marca UTC.
- En móvil, “hoja completa” significa una vista de pantalla completa con cierre y Atrás explícitos, no un modal estrecho.
- `DEC-0106` fija superficies grises neutras y temas Claro/Oscuro/Sistema; Sistema es el valor inicial salvo elección explícita y el acento no se usa como fondo dominante.
- `DEC-0107` integra un asistente IA persistente en vistas generales/proyecto; `/` abre comandos con alternativa táctil y toda escritura nace de un borrador revisado/confirmado por una persona.
- El refinamiento de `DEC-0108` usa un compositor único sin pestañas: texto publica anotación, `/` selecciona el tipo a crear, adjuntos se detectan dentro del compositor y un solo `Publicar` confirma todo.
- El refinamiento de `DEC-0109` hace Contexto vivo un pilar ancho de once alcances —incluido Trabajos—; nombres/primarias abren vistas normales e `Inspeccionar aquí` conserva la vista in situ.
- Un Proyecto representa una contratación y contiene `1..N` Trabajos independientes. Tipo, Situación interna, APT/SIRI y operación pertenecen al Trabajo; el Proyecto conserva el agregado.
- La tipografía obligatoria es `--font-ui: "Inter", "Segoe UI", sans-serif;` para interfaz y `--font-data: "Roboto Mono", Consolas, monospace;` para datos técnicos.
- Los layouts responden al ancho real del contenedor: grid fluido `auto-fit/minmax` o equivalente, encabezados/badges con wrap y cero desbordamiento (`overflow`) horizontal en 360/768/1024/1440 y zoom 200 %.

## F00 — Alternar navegación general e inmersiva de proyecto

**Actor:** cualquier usuario con lectura del proyecto.  
**Entrada general:** Inicio, Proyectos, Trabajo, Agenda, OneDrive, Aprobaciones, Notificaciones, Reportes o el acceso inferior Configuración.  
**Entrada inmersiva:** cualquier ruta `/proyectos/:proyectoId/*`.

1. La capa general muestra información transversal y conserva filtros, página y posición mientras la sesión siga vigente.
2. Al abrir `Ver proyecto completo`, la interfaz fija la contratación, muestra el agregado de Trabajos y conserva un selector `Trabajo n de N`.
3. El índice local ofrece Resumen, Trabajos, Datos y las vistas operativas del Trabajo seleccionado: Gestiones, Tareas, Programación, Documentos, Aprobaciones, Actividad, Reportes e Historial.
4. `Trámites APT/SIRI` se agrega solo para el Trabajo seleccionado tipo Plano de catastro. Cambiar otro Trabajo no altera este alcance.
5. `← Todos los proyectos`, `Volver a [origen]` y `Navegación general` permiten salir sin perder el contexto anterior.
6. Una tarea, aprobación, aviso o archivo abierto desde una vista general ofrece tanto `Volver a [vista general]` como `Ver proyecto completo`.
7. Un enlace profundo autorizado entra directamente al modo proyecto; uno no autorizado aplica S05 sin revelar identidad del proyecto.

Móvil: la navegación general es `Inicio · Proyectos · Trabajo · Agenda · Más`; la inmersiva es `Resumen · Trabajos · Trabajo · Agenda · Más`. En escritorio, la sidebar puede compactarse a rail slim de iconos con nombres accesibles/tooltips, sin perder retorno ni destino activo. Las capas no duplican estado.

## F01 — Acceso y enlace profundo

**Actor:** cualquier usuario preautorizado.  
**Entrada:** `/inicio` o enlace profundo.  
**Resultado:** sesión válida y destino autorizado, sin revelar datos fuera de alcance.

1. Mostrar marca JBC, entorno cuando no sea Producción y `Continuar con Microsoft`.
2. Delegar autenticación y MFA a Microsoft Entra ID.
3. Revalidar tenant, allowlist, sesión, rol y alcance en servidor.
4. Si el destino es válido, abrirlo; si no, mostrar `No tienes acceso a este contenido` y `Ir a Inicio`.
5. Registrar accesos e intentos rechazados sin secretos.

Variantes:

- sesión expirada: conservar solo la ruta de retorno, nunca datos del registro;
- usuario revocado: cerrar sesión y explicar que debe contactar a la administración;
- sin conexión: abrir únicamente el AppShell disponible y el estado offline; no simular una sesión nueva.

## F02 — Crear, revisar, editar y archivar un cliente

**Actor:** A/C/T si el permiso efectivo lo permite; L consulta dentro de su alcance.  
**Rutas:** `/clientes`, `/clientes/nuevo`, `/clientes/:clienteId/*`.

1. Desde Clientes, activar `Nuevo cliente`, única acción primaria de la cabecera.
2. Elegir Persona física o Persona jurídica.
3. Completar identidad y datos principales con etiquetas persistentes.
4. Ejecutar comprobación de identificación exacta y posibles coincidencias.
5. Si existen coincidencias, mostrar comparación y permitir `Ver cliente` o `Continuar de todos modos` con motivo; nunca fusionar automáticamente.
6. Añadir direcciones y contactos en secciones independientes.
7. Revisar resumen y confirmar creación.
8. Mostrar éxito persistente con `Ver cliente` y `Crear proyecto para este cliente`; desde un proyecto, `Cliente e inmuebles` mantiene el contexto inmersivo.

Edición y archivo:

- el detalle separa Resumen, Contactos, Direcciones, Proyectos, Documentos e Historial;
- archivar solicita motivo y muestra impacto; no elimina el cliente ni sus vínculos;
- un documento del cliente solo puede archivarse en OneDrive; no aparece `Eliminar`.

Móvil: una columna, contactos/direcciones como filas editables, cada edición en hoja completa; carga de documento desde `Cámara` o `Archivos` cuando corresponda.

## F03 — Crear manualmente una contratación y sus Trabajos

**Actor:** actor con permiso efectivo de crear proyecto.  
**Ruta:** `/proyectos/nuevo`.  
**Invariante:** no existe importación, migración ni sincronización desde Excel.

1. **Cliente:** buscar y seleccionar un cliente existente o ir a F02 y volver con el cliente seleccionado.
2. **Contratación:** nombre, descripción, prioridad, responsables, participantes y fechas del Proyecto.
3. **Primer Trabajo obligatorio:** elegir tipo/configuración —Delimitación, Curvas de nivel, Avalúo, Croquis, Plano de catastro u otro autorizado— y asignar nombre/código dentro del Proyecto.
4. **Datos del Trabajo:** completar solo los campos de su tipo, responsables, fechas e inmuebles/lotes relacionados.
5. **Documentos/carpeta:** vincular/preparar la raíz OneDrive del Proyecto y el destino del Trabajo; los archivos se adjuntarán luego desde el compositor, no mediante `Crear documento`.
6. **Vista previa:** separar datos de contratación y del Trabajo 1, incluido impacto documental y APT/SIRI cuando aplique.
7. **Confirmación:** `Crear proyecto y trabajo` es la única acción primaria. El Proyecto siempre nace con al menos un Trabajo; después, `Nuevo trabajo` añade otros independientes por el mismo patrón.

Regla condicional:

- solo al elegir Plano de catastro para ese Trabajo aparece `Preparación para monitoreo APT/SIRI`, claramente de consulta;
- para los otros cuatro tipos no se renderiza etiqueta, campo, paso ni opción APT/SIRI;
- cambiar el tipo del Trabajo aún no confirmado descarta únicamente sus valores específicos, después de advertir cuáles dejarán de aplicar; no modifica la contratación ni otros Trabajos.

Móvil: Stepper sustituido por `Paso n de 7`, resumen de errores al inicio y acciones `Atrás`/`Continuar` fijas sin cubrir campos. A 360 px el resumen es una lista de término/valor, nunca tabla horizontal.

## F04 — Solicitar cambio de tipo de un Trabajo

**Actor:** solicitante y decisor(es) según permiso/política aprobada.  
**Ruta:** `/proyectos/:proyectoId/trabajos/:trabajoId/resumen` → `Solicitar cambio de tipo` → aprobación compartida.

1. Elegir tipo propuesto.
2. Mostrar comparativo: tipo/versión actual, tipo/versión propuesta, campos que se activan, campos que pasan a historia, tareas/plantillas afectadas e integraciones.
3. Exigir motivo y confirmar solicitud.
4. Resolver mediante F11; aprobación y ejecución permanecen separadas.
5. Antes de ejecutar, revalidar versión. Si cambió, marcar `Desactualizada` y exigir nueva solicitud.
6. Al ejecutar, registrar Proyecto/Trabajo, usuario, UTC, tipo/estado anteriores, tipo nuevo, aprobación y correlación.

Si ese Trabajo deja de ser Plano de catastro:

- se detiene monitoreo futuro;
- se retiran ruta, navegación y campos APT/SIRI activos;
- el historial externo previo permanece inmutable y solo consultable desde Historial con etiqueta `Histórico inactivo`;
- su Situación interna no se reemplaza por el último estado externo y los demás Trabajos permanecen intactos.

## F05 — Cambiar estado, esperar, reanudar, cerrar, cancelar o archivar

**Actor:** actor autorizado; aprobación según acción configurada.  
**Ruta:** detalle del Trabajo, gestión o tarea; archivo del Proyecto solo cuando la contratación completa corresponda.

1. Abrir `Cambiar estado` y mostrar transiciones permitidas para ese Trabajo/entidad; el agregado del Proyecto no se edita como si fuera un Trabajo.
2. Para `En espera`, exigir motivo, responsable interno o externo y próxima fecha de seguimiento.
3. Al reanudar, mostrar y recuperar la etapa anterior.
4. Para cerrar, cancelar o archivar, exigir motivo y mostrar impacto/historia conservada.
5. Si la acción requiere aprobación, crear solicitud; no presentar el estado futuro como aplicado.
6. Confirmar el resultado con enlace al historial.

La interfaz nunca ofrece eliminación física. Un error de versión abre el comparativo de conflicto, no sobrescribe.

## F06 — Crear y seguir una gestión

**Actor:** A/C/T según permiso efectivo; L consulta.  
**Rutas:** `/trabajo`, `/gestiones`, `/proyectos/:proyectoId/trabajos/:trabajoId/gestiones`, `/gestiones/:gestionId`.

1. Crear gestión dentro del Trabajo seleccionado con tipo, título, descripción, prioridad, responsable, inicio, vencimiento y seguimiento.
2. Relacionar opcionalmente un trámite externo solo si ya existe y ese Trabajo es Plano de catastro.
3. Guardar y abrir el detalle cronológico.
4. Añadir notas; una edición crea versión y conserva autor/fecha anteriores.
5. Crear una o varias tareas relacionadas mediante F07.
6. Aplicar espera/reanudación mediante F05.
7. Registrar resultado y cerrar o archivar sin perder consulta.

Móvil: la cronología se apila; filtros y orden se abren en hoja completa; `Nueva tarea` es la acción primaria de la sección de tareas, no de toda la página.

## F07 — Crear, descomponer y resolver una tarea

**Actor:** A/C/T según permiso efectivo; L consulta.  
**Rutas:** `/trabajo`, `/tareas`, `/tareas/:tareaId`, `/proyectos/:proyectoId/trabajos/:trabajoId/tareas` y sección Tareas de la gestión.

1. Crear manualmente, desde plantilla o desde una propuesta IA aún no aplicada.
2. Completar tipo, título, responsable, prioridad, vencimiento, esfuerzo y relaciones.
3. Para prioridad Urgente o Crítica, exigir justificación; Crítica informa que notificará al coordinador.
4. Añadir subtareas y lista de comprobación.
5. Añadir dependencia mediante selector; validar y rechazar ciclos con explicación.
6. Guardar; después, programar uno o más bloques mediante F08.
7. Actualizar avance y completar, cancelar o archivar con historial/motivo cuando aplique.

Alternativas a arrastrar:

- `Mover antes de…` / `Mover después de…` para ordenar;
- `Cambiar estado` mediante selector;
- `Añadir dependencia` mediante búsqueda;
- teclado con botones `Subir` y `Bajar` anunciando la nueva posición.

Concurrencia: al guardar una versión antigua, mostrar valores propios y actuales; permitir `Conservar actual`, `Aplicar mis cambios sobre la versión nueva` campo por campo o `Cancelar`. Nunca elegir automáticamente.

## F08 — Programar personas y recursos

**Actor:** actor con permiso efectivo de programar.  
**Rutas:** `/agenda`, `/proyectos/:proyectoId/trabajos/:trabajoId/programacion`, `/tareas/:tareaId` → Programación.

1. Elegir tarea y `Programar bloque`.
2. Seleccionar inicio/fin, modalidad, ubicación, personas, equipos y vehículos.
3. Presentar fechas en Costa Rica y etiquetar por separado `Vence` y `Se ejecuta`.
4. Comprobar conflictos antes de confirmar.
5. Si hay conflicto, mostrar texto, icono, recurso/persona, bloque causante y alternativas; el color nunca es la única señal.
6. Confirmar, reprogramar o dividir en varios bloques.
7. Configurar recordatorio dentro de las preferencias autorizadas.

Móvil: Agenda/lista es la vista inicial. El calendario es opcional; seleccionar un bloque no requiere precisión de arrastre. Reprogramar usa campos `Inicio` y `Fin` o alternativas sugeridas.

Ventana predeterminada: los avisos se entregan desde 07:00 inclusive hasta 20:00 exclusiva y se encolan silenciosamente desde 20:00 hasta 07:00, hora de Costa Rica.

## F09 — Consultar APT/SIRI de un Trabajo Plano de catastro

**Actor:** usuario con lectura del Proyecto/Trabajo; consulta manual solo si su permiso efectivo lo permite.  
**Ruta:** `/proyectos/:proyectoId/trabajos/:trabajoId/tramites`, únicamente para ese Trabajo tipo Plano de catastro.

1. Entrar a Trámites desde el Trabajo seleccionado; Proyecto y `Trabajo n de N` permanecen visibles.
2. Ver APT y SIRI separados, sin mezclar eventos, Situación interna ni datos de otros Trabajos.
3. Para cada trámite, mostrar texto oficial original, clasificación normalizada, fecha de corte, última consulta exitosa y estado de actualización en lenguaje cotidiano.
4. Abrir la historia independiente del trámite.
5. Activar `Consultar ahora` cuando esté disponible; informar límite de frecuencia y que es solo lectura.
6. Ante caída parcial, conservar resultados exitosos y marcar únicamente la fuente afectada como degradada.

Regresión visual obligatoria: en `Estado oficial externo`, el badge APT/SIRI y el encabezado comparten espacio flexible. Si el contenedor se estrecha (incluidos Contexto vivo + IA o zoom 200 %), el grid baja a una columna y texto/badge envuelven; nunca se recortan ni crean scroll horizontal.

No existen acciones para presentar plano, cargar archivo, apelar o solicitar mantenimiento. Las apelaciones/mantenimientos SIRI se registran como trámites observados, no se ejecutan desde la PWA.

Para otro tipo de Trabajo no existe enlace, pestaña, campo ni estado activo. Una URL manipulada devuelve sección genérica no disponible. Si hubo cambio, la historia externa queda inactiva solo para ese Trabajo.

## F10 — Gestionar documentos y carpetas OneDrive

**Actor:** según permiso efectivo; Admin/Coordinador resuelven aprobaciones documentales previstas por RF-010.  
**Rutas:** `/onedrive`, Documentos del cliente o `/proyectos/:proyectoId/trabajos/:trabajoId/documentos`.

1. Mostrar ubicación, ruta, última sincronización y estado de vínculo.
2. En la vista transversal, filtrar por cliente/proyecto/trabajo y abrir el propietario; dentro del Proyecto, conservar contratación y Trabajo.
3. Navegar por avance/retroceso en móvil y por árbol/lista en escritorio.
4. Elegir `Crear carpeta`, `Vincular`, `Renombrar`, `Mover`, `Archivar` o `Restaurar` según permiso. No existe `Crear documento` ni dropzone de carga separada.
5. `Adjuntar archivo` abre/focaliza el compositor de Actividad. Arrastrar, Cámara o Archivos se reciben dentro del compositor.
6. El compositor propone tipo documental, relación con Proyecto/Trabajo/entidad y carpeta OneDrive, con explicación y aprobación aplicable.
7. El único `Publicar` confirma anotación/comando/adjunto y ejecuta o crea F11 según política; antes no hay carga.
8. Mostrar progreso idempotente y resultado auditado; el archivo relacionado abre luego su vista normal desde el nombre/acción primaria.

Salvaguardas:

- nunca existe `Eliminar documento` ni `permanentDelete`;
- carpeta no vacía se archiva en `99-ARCHIVADOS`;
- solo una carpeta completamente vacía puede solicitar `Enviar a papelera de OneDrive`, con motivo y doble control;
- raíz del proyecto, `99-ARCHIVADOS` y carpetas protegidas no ofrecen papelera;
- si el elemento cambió desde la aprobación, se marca obsoleta y no se ejecuta;
- Supabase se describe solo como metadatos/IDs, nunca destino de carga.

## F11 — Solicitar, decidir y ejecutar una aprobación

**Actor:** solicitante y persona(s) autorizada(s) según política; composición fina pendiente en `DEC-0104`.  
**Rutas:** `/aprobaciones`, `/aprobaciones/:solicitudId` y `/proyectos/:proyectoId/aprobaciones`.

1. El solicitante revisa acción, elemento, versión, motivo, impacto y evidencia.
2. Enviar registra y notifica; el estado pasa a Pendiente.
3. El decisor abre un comparativo accesible y revisa evidencia/fecha límite.
4. Aprobar o rechazar exige comentario cuando la política o el rechazo lo requiera.
5. El sistema impide que la misma persona satisfaga dos participaciones cuando se exige doble control.
6. Aprobar no ejecuta: se muestra `Aprobada · pendiente de ejecución`.
7. Antes de ejecutar, revalidar versión y permiso; si cambió, marcar Desactualizada/Sustituida.
8. Ejecutar una sola vez; mostrar En ejecución, Ejecutada o Fallida con correlación y reintento seguro.

La bandeja del proyecto contiene exactamente las solicitudes relacionadas con ese proyecto y conserva su contexto. La bandeja general cruza proyectos; decidir desde cualquiera actualiza la misma solicitud y vuelve al origen correcto.

Móvil: comparativo apilado `Actual` y `Propuesto`, con `Siguiente diferencia`; acciones de decisión permanecen después de la evidencia, no flotan sobre ella.

## F12 — Recibir y administrar notificaciones

**Actor:** cualquier usuario dentro de su alcance.  
**Rutas:** `/notificaciones`, `/proyectos/:proyectoId/notificaciones`, `/perfil/notificaciones`, `/perfil/dispositivos`.

1. El centro persistente recibe el aviso, aun si Push falla o fue denegado.
2. Filtrar por no leídas, categoría, severidad y fecha.
3. Abrir enlace profundo; revalidar permiso antes de mostrar el registro.
4. Marcar leído/no leído o varias como leídas con confirmación resumida.
5. Configurar categoría y dispositivo.
6. Mostrar la política `Entrega 07:00–20:00 · Silencio 20:00–07:00 (Costa Rica)`.
7. Un aviso nocturno queda registrado y muestra `Programado para 07:00`; reintentos no duplican.

Dentro de un proyecto, la lista se filtra por ese proyecto y ofrece `Ver todos los avisos` sin perder la ruta local. El centro general conserva todas las categorías autorizadas.

El texto del aviso usa información mínima. Denegar notificaciones de Windows no bloquea la aplicación ni genera un error crítico.

## F13 — Tablero, búsqueda, Control General y reportes

**Actor:** cualquier rol, según alcance y capacidad efectiva.  
**Rutas:** `/inicio`, `/buscar`, `/control-general`, `/reportes`, `/proyectos/:proyectoId/entregables`.

1. Inicio presenta primero acciones/alertas, luego agenda y finalmente panorama; máximo una acción primaria por zona.
2. Buscar acepta proyecto, cliente, identificación, contrato, plano, finca, tomo/asiento, SIRI, archivo y notas autorizadas.
3. Aplicar filtros y guardar vista; la paginación es del servidor.
4. Abrir resultado en su módulo propietario.
5. Control General ofrece columnas normalizadas y, en móvil, filas de detalle; no replica importación Excel.
6. Reportes muestran periodo, tipo, estado y responsable con fecha de corte.
7. Exportar Excel/CSV/PDF muestra alcance, columnas y cantidad; queda auditado.
8. `Guardar en OneDrive` crea aprobación; no escribe antes de resolverse.

En el modo proyecto, Entregables reúne reportes, exportaciones y productos relacionados, con vínculos a sus referencias OneDrive y al historial; `Ver todos los reportes` vuelve a la vista transversal.

Resultados sin permiso no aparecen ni alteran totales de forma que revelen su existencia.

## F14 — Usar el asistente IA transversal y decidir una propuesta

**Actor:** usuario con acceso a los datos de origen; decisor según acción propuesta.  
**Entradas:** `Abrir asistente` persistente; `/` fuera de campos editables; `/` dentro del compositor; botón táctil `Comandos`.  
**Centros:** `/asistente`, `/proyectos/:proyectoId/asistente` para historial, evidencia, propuestas y configuración.

1. Abrir el panel sin abandonar la vista. En Proyecto ocupa la barra a la derecha de Contexto vivo cuando cabe; si no, fallback accesible.
2. Mostrar contexto efectivo: General, Proyecto/contratación, Trabajo y entidad autorizada. Al navegar, anunciar/revalidar el cambio.
3. Colocar el compositor inmediatamente bajo la barra de contexto y la conversación/propuestas debajo; la entrada permanece arriba durante toda la sesión.
4. Escribir una pregunta o `/`. La paleta mínima ofrece:
   - `/tarea`: borrador de tarea, responsable/fechas/prioridad/relaciones;
   - `/agenda`: borrador de bloque, personas/recursos/ubicación y conflictos;
   - `/gestion`: borrador de gestión, seguimiento y relación;
   - `/buscar`: consulta autorizada sin escritura;
   - `/resumen`: resumen del contexto con bloqueos/próximos pasos.
5. Recabar campos faltantes uno por uno o mediante formulario estructurado; no inferir destino sensible.
6. Insertar cada respuesta/propuesta debajo del compositor, con evidencia enlazable, confianza y fecha de corte.
7. Para `/buscar` o `/resumen`, enlazar fuentes autorizadas sin escritura.
8. Para `/tarea`, `/agenda` o `/gestion`, revisar borrador y comparar datos actuales campo por campo.
9. Solo tras confirmación humana se envía el comando normal con RLS, versión y auditoría; lo sensible continúa por aprobación.
10. Registrar aprobación/rechazo/descartado y permitir consultar ejecución/evidencia en el Centro IA.

Persistencia y seguridad:

- el panel puede seguir abierto al cambiar de vista durante la sesión, pero el contexto se actualiza y se vuelve a autorizar;
- el atajo `/` no intercepta la escritura dentro de otros inputs; el botón `Comandos` ofrece equivalencia por tacto/lector de pantalla;
- la vista persistente no implica retener contenido en OpenAI: Responses API conserva `store:false` y no recibe secretos/PII innecesaria;
- si OpenAI falla, explicar que las funciones básicas siguen disponibles, conservar de forma segura la entrada de sesión y ofrecer reintento/manual;
- el panel nunca tapa navegación, alertas, acción primaria ni foco y no presenta texto generado como hecho confirmado.

## F15 — Administrar configuración, salud, versión y apariencia

**Actor:** secciones visibles según permiso efectivo; apariencia disponible al propietario del perfil.  
**Rutas:** `/administracion/*`, `/salud`, `/perfil/apariencia`.

Configuración:

1. Elegir catálogo, tipo, plantilla, recurso, política o feature flag.
2. Mostrar código invariable, vigencia, versión, protección y usos.
3. Comparar cambios; `Otro` exige descripción y valores usados se archivan, no se eliminan.
4. Crear aprobación cuando corresponda y mantener proyectos existentes en su versión.

Salud/versión:

1. Ver aplicación, Supabase, autenticación, Graph, APT, SIRI, OpenAI, Push, trabajador, cron, respaldo y restauración.
2. Cada fila muestra estado textual, última ejecución exitosa, antigüedad comprensible y acción segura; nunca credenciales.
3. Mostrar límites al 70/85 %, ciclos omitidos, error > 20 % y cola detenida.
4. Entorno y SemVer permanecen visibles; una reversión es información operativa, no botón casual.

Apariencia:

1. Si no existe preferencia explícita, mostrar `Tema: Sistema` y resolver Claro/Oscuro según el dispositivo; un cambio del sistema se refleja mientras esa opción siga activa.
2. Permitir elegir `Sistema`, `Claro` u `Oscuro`; la elección explícita prevalece sobre el sistema y se sincroniza en el perfil.
3. Elegir de forma independiente teal, azul, índigo, violeta, rosa, naranja o un color personalizado.
4. Previsualizar fondo/superficies neutras, texto, foco, botón, navegación, selección y estados semánticos en Claro y Oscuro con texto real.
5. Rechazar una combinación si foco, texto, controles o estados incumplen AA en cualquiera de los temas que pueda usar; el acento no cubre grandes superficies ni cambia semántica.
6. Guardar/sincronizar; restaurar tema vuelve a `Sistema` y restaurar acento vuelve al teal institucional como acciones separadas.

## F16 — Consultar historial y auditoría

**Actor:** historial del registro según alcance; auditoría global/exportación solo con permiso efectivo.  
**Rutas:** `/proyectos/:proyectoId/historial`, otros `*/historial` y `/auditoria`.

1. Abrir línea de tiempo y filtrar por módulo, actor, resultado y fecha.
2. Ver evento, valores anterior/nuevo, motivo, correlación, hora Costa Rica y UTC.
3. Distinguir eventos internos, externos, OneDrive, IA y aprobaciones sin mezclarlos.
4. Para cambio de tipo, mostrar Proyecto/Trabajo, usuario, UTC, tipo/estado anteriores, tipo nuevo y aprobación.
5. Para APT/SIRI de un Trabajo que ya no es catastro, usar `Histórico inactivo`; no ofrecer consulta nueva ni afectar otros Trabajos.
6. Exportar auditoría solo mediante el permiso y flujo auditado correspondiente.

## F17 — Anotar y actuar desde la Actividad unificada del proyecto

**Actor:** cualquier usuario con lectura del proyecto; publicar, crear, adjuntar, archivar o aprobar depende siempre del permiso efectivo confirmado por servidor.  
**Entrada:** acción `Actividad` desde cualquier `/proyectos/:proyectoId/*`; en escritorio abre el carril contextual derecho y en móvil/tableta un panel/drawer accesible.  
**Relación:** Actividad pertenece al Proyecto y puede relacionar Trabajo, Gestión, Tarea, Agenda o Archivo sin reemplazar sus vistas operativas.

1. Abrir `Actividad` en el Contexto vivo ancho. No hay pestañas `Mensaje`, `Nota interna` o `Actividad`; existe un único compositor.
2. Mostrar cronología con actor, tipo de evento, hora Costa Rica, UTC en detalle y enlaces reales. Pulsar nombre/primaria abre la vista normal; `Inspeccionar aquí` mantiene contexto.
3. Texto sin `/` prepara una anotación del usuario en el Proyecto, relacionada con el Trabajo/objeto activo cuando corresponda.
4. Escribir `/` abre `/tarea`, `/gestion` y `/agenda`; elegir uno transforma el mismo compositor en formulario estructurado del tipo seleccionado.
5. Arrastrar o elegir archivo dentro del compositor lo marca `Adjunto detectado · aún no cargado`. No existe dropzone separada ni acción `Crear documento`.
6. Mostrar inline la propuesta editable de tipo documental, relación y carpeta OneDrive, con explicación/evidencia y aprobación aplicable. La persona puede corregir entre opciones autorizadas.
7. Si participa IA, rotular propuesta con evidencia, confianza y corte; una persona edita o descarta. IA nunca activa la escritura.
8. Usar un único botón `Publicar` para anotación, comando y adjunto. Publicar constituye confirmación humana y envía el caso de uso normal con permiso, RLS, versión, auditoría y aprobación.
9. El binario va exclusivamente a OneDrive; Supabase registra después solo metadatos, `driveId`/`driveItemId` y relaciones.
10. Si OneDrive falla, conservar texto/comando/propuesta, no publicar referencia rota y ofrecer `Reintentar` o `Quitar adjunto`; después se vuelve a usar el mismo `Publicar`.
11. Un conflicto devuelve a revisión. Un adjunto existente se archiva con motivo según permiso/aprobación; nunca se elimina.

Sin conexión no se simula una carga OneDrive. El compositor explica qué puede conservarse de forma segura en la sesión, no almacena secretos y revalida proyecto, permiso y versión al reintentar.

## F18 — Inspeccionar relaciones y proponer archivos en Contexto vivo

**Actor:** usuario con lectura del proyecto; cada lectura o acción adicional depende de alcance y permiso efectivos.  
**Entrada:** `Contexto`, `Inspeccionar aquí` o un nombre/acción primaria relacionado.  
**Cobertura contextual:** Trabajos, Datos, Gestiones, Tareas, Agenda, Trámites, Archivos, Aprobaciones, Actividad, Reportes e Historial; Trámites solo en el Trabajo Plano de catastro.

1. Abrir el pilar ancho Contexto vivo sin sustituir la sección y mostrar Proyecto, Trabajo/objeto, relación, fuente, versión/estado y última actualización.
2. Abrir `Filtrar por tipo` y elegir uno de los once alcances con su conteo. El selector abre el inspector debajo; cerrarlo limpia la selección y devuelve el foco. Trabajos muestra `1..N`, tipo, Situación interna y atención; el agregado nunca fusiona estados.
3. En cualquier fila, pulsar el nombre o acción primaria abre la vista operativa normal del archivo, tarea, gestión, agenda o Trabajo. `Inspeccionar aquí` abre dropdown/inspector/sidebar/modal/hoja sin navegar.
4. Navegar bidireccionalmente: Proyecto ↔ Trabajo ↔ Gestión ↔ Tarea ↔ Agenda/Archivo y relaciones aplicables, preservando identificador/propietario.
5. Al abrir el resumen de un Trabajo, ordenar `Propuesta IA compacta → Situación interna → Estado oficial externo`; la propuesta usa un borde sutil de 0–1 px y el último bloque solo existe para Plano de catastro.
6. Acciones de crear, vincular, editar o archivar aparecen solo con permiso y continúan por su caso normal. `Adjuntar archivo` enfoca el compositor de Actividad; no crea otra dropzone.
7. En escritorio puede compactarse la sidebar principal a slim; nombres accesibles/tooltips y destino activo siguen disponibles.
8. Con ancho suficiente, el orden es `sección → Contexto vivo ancho → IA`. La IA usa solo contexto autorizado y muestra compositor arriba, conversación/propuestas debajo.
9. Con ancho insuficiente se apila/usa drawer, preservando Proyecto, Trabajo, objeto, relación, scroll, foco y borrador.
10. Validar 360/768/1024/1440 y zoom 200 % por contenedor; el fallback ocurre antes de cualquier overflow horizontal.

## Cobertura RF y criterios dominantes

| Flujo/artefacto                             | RF                                                                                     | Criterios principales                                                                                                                                                                                        |
| ------------------------------------------- | -------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| F00 navegación dual                         | RF-011, RF-016, RF-020                                                                 | AC-011-04, AC-016-06/07, AC-020-03/05/08/09                                                                                                                                                                  |
| F01 acceso/enlace                           | RF-010, RF-016                                                                         | AC-010-01/02/03/04, AC-016-07                                                                                                                                                                                |
| F02 clientes                                | RF-001, RF-007                                                                         | AC-001-01 a 05; salvaguardas AC-007-04                                                                                                                                                                       |
| F03 contratación + Trabajos manuales        | RF-002, RF-014, RF-020                                                                 | AC-002-01 a 04, AC-014-02, AC-020-05/08; refinamiento aprobado Proyecto→1..N Trabajos                                                                                                                        |
| F04 cambio de tipo de Trabajo               | RF-002, RF-015                                                                         | AC-002-05, AC-015-02/03/04; DEC-0101 aplicado al Trabajo                                                                                                                                                     |
| F05 estado/espera/archivo                   | RF-002/003/004/014/015                                                                 | AC-003-03/04, AC-004-04, AC-014-03, AC-015-04                                                                                                                                                                |
| F06 gestiones                               | RF-003, RF-014                                                                         | AC-003-01 a 04, AC-014-03/06                                                                                                                                                                                 |
| F07 tareas                                  | RF-004, RF-014                                                                         | AC-004-01 a 05, AC-014-05/06                                                                                                                                                                                 |
| F08 agenda                                  | RF-005, RF-009, RF-019                                                                 | AC-005-01 a 04, AC-009-04, AC-019-03; DEC-0102                                                                                                                                                               |
| F09 APT/SIRI                                | RF-002, RF-006, RF-014, RF-016, RF-019                                                 | AC-002-02/03/05, AC-006-01 a 05, AC-014-04, AC-016-04/05, AC-019-05                                                                                                                                          |
| F10 OneDrive                                | RF-001, RF-007, RF-014, RF-015                                                         | AC-001-04/05, AC-007-01 a 04, AC-014-07, AC-015-02/03/04                                                                                                                                                     |
| F11 aprobaciones                            | RF-010, RF-015                                                                         | AC-010-01/04, AC-015-01 a 05; DEC-0104 pendiente                                                                                                                                                             |
| F12 notificaciones                          | RF-005, RF-009                                                                         | AC-005-04, AC-009-01 a 04; DEC-0102                                                                                                                                                                          |
| F13 tablero/búsqueda/reportes               | RF-011, RF-015                                                                         | AC-011-01 a 04, AC-015-05                                                                                                                                                                                    |
| F14 IA transversal/comandos                 | RF-008, RF-015, RF-020                                                                 | AC-008-01 a 04, AC-015-01 a 04, AC-020-03/05/08; DEC-0107                                                                                                                                                    |
| F15 administración/salud/versión/apariencia | RF-014, RF-017, RF-018, RF-020                                                         | AC-014-01/02/08, AC-017-05/06, AC-018-04, AC-020-01/06/07/09; DEC-0106                                                                                                                                       |
| F16 historial/auditoría                     | RF-002, RF-003, RF-015, RF-019                                                         | AC-002-05, AC-003-04, AC-015-05, AC-019-03/04                                                                                                                                                                |
| F17 Actividad unificada                     | RF-003, RF-004, RF-005, RF-007, RF-008, RF-015, RF-019, RF-020                         | AC-003-04, AC-004-01/03/04/05, AC-005-01/02/03, AC-007-01/02/04, AC-008-01/02/04, AC-015-02/03/04, AC-019-03/04/05, AC-020-03/05/08/09; DEC-0108                                                             |
| F18 Contexto vivo/relaciones/Trabajos       | RF-002, RF-003, RF-004, RF-005, RF-006, RF-007, RF-008, RF-010, RF-015, RF-019, RF-020 | AC-002-01/02/03/05, AC-003-01/04, AC-004-01/03, AC-005-01/02/03, AC-006-01/03/05, AC-007-01/02/04, AC-008-01/02/04, AC-010-01/04, AC-015-02/03/04/05, AC-019-03/04/05, AC-020-03/05/08/09; DEC-0109 refinada |
| Estados S01–S10 y checklist                 | RF-016, RF-020                                                                         | AC-016-04/06/07/08, AC-020-02 a 09                                                                                                                                                                           |

## Matriz flujo → rol → ruta → estados → breakpoints

`Completo` significa que el objetivo, validaciones, alternativas y recuperación se pueden ejecutar sin cambiar a otro dispositivo. En todos los anchos se aplican `S01–S10`; los cambios son de composición, no de capacidad.

| Flujo                         | Rol/audiencia sin inventar permiso               | Ruta principal                                 | Estados | 360 px                          | 768 px                   | 1024 px                                      | 1440 px                                     |
| ----------------------------- | ------------------------------------------------ | ---------------------------------------------- | ------- | ------------------------------- | ------------------------ | -------------------------------------------- | ------------------------------------------- |
| F00 Navegación dual           | cualquier lector autorizado                      | general ↔ `/proyectos/:id/*`                   | S01–S10 | Completo; nav cambia de capa    | Completo; Drawer local   | Completo; índice local                       | Completo; índice local                      |
| F01 Acceso/enlace             | A/C/T/L preautorizado                            | `/inicio`, destino                             | S01–S10 | Completo; shell                 | Completo; drawer         | Completo; lateral                            | Completo; lateral                           |
| F02 Cliente                   | A/C/T según permiso; L lectura                   | `/clientes/*`                                  | S01–S10 | Completo; 1 columna             | Completo; 1 columna      | Completo; detalle 2 zonas                    | Completo; tabla + detalle                   |
| F03 Proyecto + Trabajo manual | actor con crear                                  | `/proyectos/nuevo`, `/trabajos/nuevo`          | S01–S10 | Completo; paso a paso           | Completo; paso a paso    | Completo; resumen lateral                    | Completo; resumen lateral                   |
| F04 Cambio de tipo            | solicitante/decisor según política               | Trabajo + aprobación                           | S01–S10 | Completo; comparativo apilado   | Completo                 | Completo; 2 columnas                         | Completo; 2 columnas                        |
| F05 Estados/archivo           | actor autorizado                                 | detalle de entidad                             | S01–S10 | Completo; hoja completa         | Completo                 | Completo                                     | Completo                                    |
| F06 Gestión                   | A/C/T según permiso; L lectura                   | `/trabajo`, Trabajo `/gestiones`               | S01–S10 | Completo; cronología            | Completo                 | Completo                                     | Completo                                    |
| F07 Tarea                     | A/C/T según permiso; L lectura                   | `/trabajo`, Trabajo `/tareas`                  | S01–S10 | Completo; sin drag              | Completo; sin drag       | Completo; tabla opcional                     | Completo; tabla opcional                    |
| F08 Agenda/recursos           | actor con programar                              | `/agenda`, Trabajo `/programacion`             | S01–S10 | Completo; agenda                | Completo; agenda         | Completo; calendario/lista                   | Completo; calendario/lista                  |
| F09 APT/SIRI                  | lectura/consulta efectiva, solo Trabajo catastro | Trabajo `/tramites`                            | S01–S10 | Completo; secciones apiladas    | Completo                 | Completo                                     | Completo                                    |
| F10 OneDrive                  | según permiso; A/C resuelven documental          | `/onedrive`, Trabajo `/documentos`, compositor | S01–S10 | Completo; compositor + cámara   | Completo; lista          | Completo; árbol/lista                        | Completo; árbol/lista                       |
| F11 Aprobaciones              | actores según DEC-0104                           | general/proyecto `/aprobaciones`               | S01–S10 | Completo; comparativo apilado   | Completo                 | Completo; comparativo                        | Completo; comparativo                       |
| F12 Notificaciones            | A/C/T/L                                          | general/proyecto `/notificaciones`             | S01–S10 | Completo; lista                 | Completo                 | Completo                                     | Completo                                    |
| F13 Consultas/reportes        | todos según alcance/exportar                     | general `/reportes`, proyecto `/entregables`   | S01–S10 | Completo; filas                 | Completo; filas          | Completo; tabla                              | Completo; tabla                             |
| F14 IA transversal/comandos   | usuario con fuentes; decisor autorizado          | panel persistente + centros IA                 | S01–S10 | Completo; hoja + botón Comandos | Completo; Drawer         | Completo; apilado/drawer si contexto abierto | Completo; a la derecha del contexto si cabe |
| F15 Admin/salud/tema/acento   | según permiso; perfil propio                     | admin/salud/perfil                             | S01–S10 | Completo; listas/hojas          | Completo                 | Completo                                     | Completo                                    |
| F16 Historial/auditoría       | lectura/exportación efectiva                     | `*/historial`, `/auditoria`                    | S01–S10 | Completo; cronología            | Completo                 | Completo; filtros laterales                  | Completo; filtros laterales                 |
| F17 Compositor/Actividad      | lectura; publicar según permiso efectivo         | `panel=contexto&scope=actividad`               | S01–S10 | Completo; único Publicar        | Completo; Drawer         | Completo; pilar ancho                        | Completo; contexto + IA si cabe             |
| F18 Contexto vivo             | lectura; acciones según permiso efectivo         | Proyecto/Trabajo + `panel=contexto&scope=…`    | S01–S10 | Completo; drawer ancho          | Completo; drawer/apilado | Completo; pilar + IA fallback                | Completo; tres zonas si caben               |

## Comprobaciones de exclusión

- No existe flujo, ruta, CTA, texto de ayuda ni estado denominado importar/sincronizar proyectos desde Excel.
- APT/SIRI no aparece para un Trabajo cuyo tipo no es Plano de catastro; otro Trabajo del mismo Proyecto no cambia esa regla.
- F09 no contiene verbos de escritura externa: presentar, cargar, apelar o solicitar no son acciones disponibles.
- F10 nunca elimina documentos y no ofrece papelera para carpetas no vacías/protegidas.
- F14 nunca omite evidencia, confianza, fecha de corte ni decisión humana.
- F17 no contiene pestañas de modo, dropzone separada, `Crear documento`, segundo botón de publicación, binario Supabase ni escritura directa de IA.
- F18 no oculta el enlace operativo detrás del inspector, rompe bidireccionalidad, omite Trabajos, reduce el pilar a panel estrecho ni superpone IA sobre Contexto vivo.
- Ningún Proyecto existe sin Trabajo ni usa un único tipo/estado para representar todos sus Trabajos.
