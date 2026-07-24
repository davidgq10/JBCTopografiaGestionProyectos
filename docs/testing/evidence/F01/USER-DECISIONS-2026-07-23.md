# Decisiones de usuario — Fase 1

Fecha: 2026-07-23 (`America/Costa_Rica`)

## DEC-0105 — Navegación dual

El usuario confirmó que la plataforma debe integrar todo por proyecto y conservar a la vez las vistas generales.

- **General/transversal:** inicio, todos los proyectos, trabajo, agenda, OneDrive, aprobaciones, notificaciones, reportes y administración.
- **Inmersiva por proyecto:** al ingresar se mantiene visible el contexto del proyecto y se puede consultar todo lo relacionado: resumen, cliente/inmuebles/participantes, gestiones, tareas/listas/dependencias, programación/recursos, APT/SIRI cuando aplica o su historia inactiva, documentos, aprobaciones, actividad/notificaciones, IA, reportes/entregables e historial/auditoría.

La navegación general no se sustituye; ambos niveles son complementarios.

## DEC-0106 — Fondos neutros y temas

El usuario confirmó que los tonos de fondo deben ser neutros, como grises, para que cualquier color de acento mantenga una presentación coherente. También solicitó temas claro y oscuro.

- Fondos, barras y superficies base: grises neutros.
- Acento: controles primarios, foco y énfasis; no fondo dominante.
- Temas: automático según el sistema, claro y oscuro.
- Estados semánticos: éxito, advertencia, error, información, APT, SIRI e IA no se recolorean con el acento.
- Validación F1: contraste, teclado, foco y legibilidad en ambos temas y con todos los acentos.

## DEC-0107 — IA integrada y comandos `/`

El usuario solicitó que la IA no dependa únicamente de una pestaña. Debe existir como chat contextual desde el que se puedan gestionar entidades de distintas tablas mediante comandos tipo Notion.

- Acceso persistente en vistas generales y dentro de un proyecto.
- Contexto visible de la vista/proyecto y respeto del alcance autorizado.
- Comandos iniciales: `/tarea`, `/comentario`, `/agenda`, `/gestion`, `/resumen` y `/buscar`.
- Los comandos que cambian datos generan una propuesta/borrador estructurado; nunca escriben automáticamente.
- Una persona revisa y confirma; las acciones sensibles mantienen su flujo de aprobación.
- La pestaña IA permanece como centro de historial, evidencia y configuración, pero deja de ser el único acceso.

## Hallazgo visual comunicado por el usuario

La captura aportada mostró un badge APT fuera de su tarjeta en un contenedor estrecho. Se convierte en regresión obligatoria: no puede existir desbordamiento horizontal; encabezados, badges, valores y textos deben envolver o apilarse según el ancho real del contenedor en ambos temas.

## DEC-0108 — Secciones + historial contextual tipo Odoo

El usuario aclaró que la integración conversacional no elimina las secciones. En el detalle de proyecto debe convivir una línea de actividad/historial a la derecha, inspirada en el “chatter” de Odoo.

- Escritorio: panel contextual derecho con mensajes, notas internas, actividades, creación e historial cronológico.
- Tablet/móvil: misma capacidad adaptada a una columna o panel accesible, sin desbordamientos.
- El compositor admite comandos `/` y propuestas de IA, pero conserva revisión humana.
- Crear documento o cargar adjunto desde el panel guarda el binario exclusivamente en la carpeta OneDrive del proyecto; la plataforma/Supabase conserva metadatos, vínculo, auditoría y estado.
- Ninguna sección de datos, tareas, agenda, archivos, aprobaciones, IA, reportes o historial se elimina.

## Fuentes obligatorias

```css
--font-ui: 'Inter', 'Segoe UI', sans-serif;
--font-data: 'Roboto Mono', Consolas, monospace;
```

`--font-ui` se usa en navegación, formularios y contenido; `--font-data` en códigos, fechas, rutas, identificadores y valores técnicos.

## DEC-0109 — Relaciones en sitio, arrastre e IA contigua

- Si una gestión tiene tareas relacionadas, se muestran mediante botón y detalle desplegable/inspector/panel/modal, sin obligar a abrir otra pestaña. El mismo patrón aplica en ambos sentidos entre gestiones, tareas, agenda y otras entidades.
- El contexto vivo cubre: datos, gestiones, tareas, agenda, trámites, archivos, aprobaciones, actividad, reportes e historial.
- La zona admite arrastrar o seleccionar archivos. Antes de cargar muestra los nombres, propone con explicación una carpeta OneDrive y permite cambiarla, consultar a la IA, descartar o confirmar.
- Confirmar destino no implica escritura autónoma de IA y, en el prototipo local, no transfiere binarios.
- En escritorio, el asistente IA abierto se monta como una barra adicional a la derecha del contexto vivo. A 1024 px o menos se adapta sin cubrir ni desbordar el contexto.

## DEC-0110 — Contexto vivo accionable y compositor único

- Contexto vivo aumenta su ancho y mantiene inspección rápida, pero los nombres y acciones de archivos, tareas, gestiones, agenda y demás objetos también abren su vista operativa normal.
- Se retiran la dropzone independiente, `Crear documento` y el selector Mensaje/Nota interna/Actividad.
- El campo de texto es también zona de arrastre/selección de archivos y detecta el adjunto antes de proponer tipo, relación y carpeta OneDrive.
- Texto sin `/` publica una anotación del usuario en el proyecto. Un comando `/` prepara la creación del tipo elegido. El único botón `Publicar` sirve para ambos casos.

## DEC-0111 — Proyecto/contratación con trabajos 1:N

El proyecto representa la contratación y contiene uno o más trabajos independientes. Una contratación catastral puede incluir varios planos de agrimensura; cada plano/trabajo mantiene por separado estado, responsable, gestiones, tareas, agenda, APT/SIRI cuando aplica, archivos e historial. El mismo principio aplica a los demás tipos de trabajo. La vista del proyecto conserva el agregado y permite seleccionar/abrir cada trabajo.

## DEC-0112 — Densidad, sidebar e IA

- Contexto vivo tiene prioridad espacial y un ancho mayor.
- La navegación principal puede compactarse a una barra estrecha de iconos con nombres accesibles.
- En el asistente IA, el compositor aparece arriba y la conversación/propuestas debajo.
- La propuesta IA del resumen se muestra de forma compacta antes de Situación interna y Estado oficial externo, con menos borde.

## DEC-0113 — Filtro compacto de tipos en Contexto vivo

El usuario confirmó que los tipos relacionados son útiles, pero la cuadrícula permanente ocupa demasiado espacio. Los once alcances se reúnen en un solo desplegable rotulado `Filtrar por tipo`.

- Cada opción conserva el nombre del tipo y su conteo para el Trabajo activo.
- Seleccionar un tipo abre el mismo inspector relacional sin abandonar la sección.
- Cerrar el inspector limpia la selección y devuelve el foco al desplegable.
- No se elimina ningún alcance ni vínculo hacia la vista operativa normal.

## DEC-0114 — Patrones UI convencionales y lenguaje comprensible

El usuario indicó que toda interfaz debe seguir prácticas consolidadas de desarrollo UI/UX profesional y no inventar controles textuales cuando existe una convención conocida.

- El sidebar no muestra `Compactar`/`Expandir` como texto visible. El detalle visual de expansión definido aquí fue sustituido posteriormente por `DEC-0116`.
- Modales, drawers, inspectores, paneles y avisos usan `×` para cerrar, con nombre accesible contextual, tooltip, objetivo de 44 px y retorno de foco.
- Acciones de negocio como `Publicar`, `Guardar`, `Aprobar` o `Archivar` conservan texto visible; no se reemplazan por iconos ambiguos.
- El concepto técnico `frescura` no aparece como etiqueta de usuario. En Proyecto → Resumen → Estado oficial externo → APT se presenta como `Actualización` y `Al día`, con edad/fecha de corte/última consulta cuando corresponda.
- El estándar normativo queda en `docs/development/UI_UX_IMPLEMENTATION_GUIDELINES.md` y debe consultarse antes de desarrollar o revisar cualquier interfaz.

## DEC-0115 — Densidad visual sin bordes redundantes

El usuario solicitó conservar el contenido de la página de Proyecto y reducir la sensación de saturación producida por contornos repetidos.

- Cada zona mantiene una sola delimitación visual principal; no se encadenan bordes en contenedor, tarjetas hijas y filas internas.
- La jerarquía se expresa primero con espacio, títulos, tipografía y superficies grises neutras; los divisores se usan únicamente cuando ayudan a recorrer información extensa.
- Los campos editables, el foco, la selección activa y los estados que necesitan una señal inequívoca sí conservan un contorno o marcador accesible.
- Reducir bordes no significa ocultar contenido, relaciones, acciones ni estados.

## DEC-0116 — Encabezado adaptable del sidebar

El usuario sustituyó expresamente el control `☰` del modo compacto porque duplicaba la marca y cargaba el rail.

- Modo compacto: el encabezado muestra únicamente la `J`; esa marca es un botón de 44 × 44 px con nombre accesible `Expandir menú principal`.
- Modo expandido: la misma zona muestra `J`, el título `JBC Proyectos` en una sola línea y la `×` inmediatamente a su derecha.
- La `×` mantiene el nombre accesible `Mostrar solo iconos del menú principal`; no se muestra texto redundante.
- El cambio conserva foco, tooltip, `aria-controls`, `aria-expanded`, ruta activa y los demás iconos del rail.

## DEC-0117 — Configuración única al pie del sidebar

El usuario solicitó ocultar del sidebar el grupo `Sistema`, incluidos los accesos visibles `Administración` y `Estados de interfaz`.

- El pie `Prototipo · Fase 1 / Datos ficticios` se sustituye por un único enlace `⚙ Configuración`.
- En modo compacto se muestra únicamente el engranaje, con nombre accesible y tooltip `Configuración`.
- El enlace abre la ruta operativa de Configuración y refleja el estado activo.
- Las pantallas técnicas no se eliminan: dejan de ser destinos primarios y quedan accesibles desde Configuración o mediante una ruta directa autorizada.
- La información de entorno/versión permanece dentro de Configuración y en el aviso persistente del prototipo, por lo que no se pierde el contexto no productivo.
