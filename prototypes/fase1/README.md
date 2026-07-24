# Prototipo UX de Fase 1

Artefacto local y desechable para validar navegación, lenguaje visual, responsive, accesibilidad y estados con datos ficticios.

- No contiene datos reales.
- No persiste información ni llama servicios.
- No autentica ni ejecuta acciones sensibles.
- No representa la implementación productiva.
- React, Vite, pnpm, Mantine, Supabase y los adaptadores se incorporan en las fases técnicas aprobadas.

Abrir index.html mediante un servidor HTTP local. Las rutas usan hash y funcionan sin backend.

## Recorridos representados

Inicio, proyectos, creación manual, detalle e historial, gestiones/tareas, agenda, OneDrive, aprobaciones, notificaciones, IA, búsqueda, reportes, administración, preferencias visuales y estados de interfaz.

## Decisiones visibles

- Conviven dos capas: navegación general transversal y navegación inmersiva que mantiene el contexto del proyecto.
- El proyecto representa la contratación y contiene uno o más trabajos independientes; cada trabajo conserva su tipo, estado, responsable, operación, integraciones y archivos, mientras el proyecto muestra el agregado.
- Dentro de cada proyecto se accede a trabajos, resumen, datos, gestiones, tareas, agenda, trámites, archivos, aprobaciones, actividad, IA, reportes e historial.
- Los fondos y superficies base usan grises neutros; el acento se limita a controles, foco y énfasis.
- Incluye tema claro, oscuro y automático según la preferencia del sistema; la selección dura solo durante la sesión del prototipo.
- El asistente IA es transversal: conserva el contexto de la vista/proyecto y ofrece comandos `/tarea`, `/comentario`, `/agenda`, `/gestion`, `/resumen` y `/buscar`; las mutaciones quedan siempre como borrador sujeto a revisión humana.
- Cada proyecto conserva sus secciones y añade Contexto vivo como pilar ancho con cronología y un compositor único.
- Contexto vivo permite inspeccionar once ámbitos —trabajos más los diez ámbitos anteriores— y recorrer relaciones en ambos sentidos. El nombre/acción principal abre además la vista operativa normal del archivo, tarea, gestión u objeto.
- Sin `/`, el compositor publica una anotación del usuario; con `/`, crea el tipo seleccionado. Un solo botón `Publicar` sirve para texto, comando y adjunto.
- Los archivos se arrastran o seleccionan dentro del campo del compositor; no existe dropzone independiente ni `Crear documento`. Antes de `Publicar` se presenta una propuesta revisable de clasificación y carpeta OneDrive.
- En escritorio, el asistente abierto ocupa una tercera barra a la derecha del contexto vivo; no lo cubre.
- El asistente muestra su compositor arriba y la conversación/propuestas debajo. La navegación lateral alterna entre expandida y rail de 64 px: compacta muestra únicamente la `J` como expansor; abierta alinea `J`, `JBC Proyectos` y `×`, sin texto visible redundante y con nombres accesibles.
- El grupo técnico `Sistema` no aparece en la navegación principal. El pie contiene un único `⚙ Configuración`; el modo slim conserva solamente el engranaje y las rutas técnicas siguen disponibles dentro de Configuración o por enlace directo autorizado.
- Los cierres ordinarios usan `×`. En APT, el estado temporal se presenta como `Actualización: Al día`; `Frescura` queda reservado al concepto técnico interno.
- La propuesta IA del resumen se presenta como franja compacta antes de Situación interna y Estado oficial externo.
- Tipografías fijadas por tokens: `--font-ui: "Inter", "Segoe UI", sans-serif` y `--font-data: "Roboto Mono", Consolas, monospace`.
- Los paneles y textos largos se adaptan al ancho real del contenedor, sin desbordamiento horizontal general.
- APT/SIRI solo aparece activo en Plano de catastro y separado del estado interno.
- El cambio de tipo conserva actor, UTC, tipo/estado anterior y deja APT/SIRI como historia inactiva fuera de catastro.
- La entrega de notificaciones es 07:00–20:00 y el silencio 20:00–07:00, hora de Costa Rica.
- El acento cambia controles primarios y foco, no los colores semánticos.
