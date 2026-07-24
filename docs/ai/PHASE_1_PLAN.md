# Plan de Fase 1 — UX y arquitectura de información

- Estado: **completada; CP-UX aprobado por el usuario el 2026-07-23**
- Inicio: 2026-07-23 (`America/Costa_Rica`)
- Entrada: G0 aprobado; DEC-0101, DEC-0102 y DEC-0105 a DEC-0117 resueltas
- Salida: checkpoint explícito del usuario antes de Fase 2

## RF y criterios dominantes

- RF-020 completo: AC-020-01 a AC-020-09.
- Interfaces y flujos de RF-001 a RF-015.
- AC-016-06/07: compatibilidad, accesibilidad y offline.
- RF-017: salud y actualización comprensible visibles; `frescura` permanece solo como concepto técnico interno.
- RF-018: entorno/versión visibles.
- DEC-0101: historial de cambio de tipo y APT/SIRI inactivo fuera de catastro.
- DEC-0102: entrega 07:00–20:00 y silencio 20:00–07:00.
- DEC-0105: navegación general y navegación inmersiva por proyecto complementarias.
- DEC-0106: fondos neutros y temas automático/claro/oscuro con acento independiente.
- DEC-0107: asistente IA contextual y transversal con chat/comandos `/`, sin escritura autónoma.
- DEC-0108: secciones preservadas más “chatter” contextual, archivos exclusivamente OneDrive y fuentes UI/datos obligatorias.
- DEC-0109: inspector relacional in situ, arrastre con clasificación previa y asistente a la derecha del contexto vivo.
- DEC-0110: Contexto vivo ancho y accionable, con compositor único para anotaciones, comandos y archivos.
- DEC-0111: proyecto/contratación con uno o más trabajos gestionados de forma independiente.
- DEC-0112: sidebar compacto, IA con compositor superior y propuesta compacta sobre estados.
- DEC-0113: los once alcances de Contexto vivo se compactan en `Filtrar por tipo` sin perder conteos, inspección ni enlaces operativos.
- DEC-0114: toda interfaz aplica patrones convencionales y lenguaje comprensible; los cierres usan `×` sin texto redundante y `Frescura` no se expone en APT.
- DEC-0115: conservar contenido y reducir contornos redundantes; una delimitación estructural principal por zona, con bordes reservados para interacción, foco, selección o estado.
- DEC-0116: rail compacto con una única `J` como expansor; expandido con `J`, `JBC Proyectos` y `×` alineados en una sola fila.
- DEC-0117: ocultar el grupo técnico Sistema del sidebar; un único `⚙ Configuración` sustituye el pie de prototipo y se reduce al engranaje en modo slim.

## Entregables

1. Usuarios, tareas principales y navegación.
2. Arquitectura de información y mapa de rutas.
   - Navegación general/transversal para toda la operación.
   - Navegación inmersiva dentro de cada proyecto, con contexto persistente y acceso a todo lo relacionado.
3. Flujos de creación manual, proyecto, gestiones, tareas, agenda, APT/SIRI, OneDrive, aprobaciones, notificaciones, IA, reportes y administración.
   - El flujo IA incluye lanzador persistente, contexto activo, comandos `/`, borrador estructurado, revisión humana y derivación a aprobación cuando corresponda.
   - El detalle de proyecto conserva las secciones y suma Contexto vivo ancho con anotaciones, comandos, relaciones accionables e historial; en tamaños menores se adapta a una sola columna/panel.
   - El compositor único publica una anotación cuando no hay `/` y prepara el tipo de objeto indicado cuando sí lo hay; el mismo botón `Publicar` sirve para ambos casos.
   - Arrastrar o seleccionar un archivo en el compositor prepara clasificación y destino OneDrive; Supabase recibe solo metadatos.
   - Proyecto representa la contratación y expone uno o más trabajos independientes, con selector/resumen agregado y acceso a cada operación.
4. Principios visuales, tokens, tipografía, whitespace, acentos y colores semánticos.
5. Inventario de componentes Mantine objetivo.
6. Estados de carga, actualización, vacío, error, permisos, degradación, datos antiguos, offline, éxito y conflicto.
7. Wireframes 360/768/1024/1440.
8. Prototipo local navegable con datos ficticios en `prototypes/fase1/**`.
9. Capturas/evidencia en 360, 768, 1024 y 1440 px.
10. Revisión independiente de arquitectura, accesibilidad y visual.

## Límite del prototipo

El prototipo es un artefacto UX local, sin persistencia, autenticación real, SDK, secretos, red ni lógica de negocio productiva. Usa HTML/CSS/JavaScript nativo para demostrar navegación, densidad, responsive y estados sin introducir un segundo stack de aplicación. React/Vite/pnpm/Mantine se implementan en las Fases 2–3 conforme al RF-012.

No se publica ni se despliega: el hosting pertenece a checkpoints posteriores. El prototipo no crea datos reales ni escribe OneDrive/APT/SIRI/OpenAI/Push.

## Propiedad

- `F1-UX-01`: `docs/ux/**`.
- Orquestador: `prototypes/fase1/**`, trazabilidad, evidencia e integración.
- `F1-ARCH-01`: `docs/architecture/reviews/F1/**`, solo después de congelar la propuesta.
- Revisión visual/accesible: solo lectura del prototipo y salida en evidencia F01.

## Criterios del checkpoint

- Navegación y lenguaje visual comprensibles en español.
- Flujo completo móvil para cada capacidad exigida.
- APT/SIRI ausentes fuera de Plano de catastro y claramente separados del estado interno.
- Desde un proyecto se accede sin perder contexto a datos/inmuebles/participantes, gestiones, tareas, agenda, trámites aplicables, archivos, aprobaciones, actividad/notificaciones, IA, reportes e historial; las vistas generales permanecen disponibles.
- Historial de cambio de tipo muestra actor, UTC y estado anterior.
- Preferencias muestran ventana 07:00–20:00 y silencio 20:00–07:00.
- Fondos/superficies son grises neutros y el prototipo es legible y operable en tema claro, oscuro y automático con todos los acentos.
- Sin tarjetas anidadas, hover obligatorio ni scroll horizontal general.
- Ninguna tarjeta, badge, tabla o texto largo desborda su contenedor en 360/768/1024/1440 px ni a 200 % de zoom.
- La IA puede abrirse desde cualquier vista, hereda contexto/permisos y nunca modifica tablas sin revisión/confirmación humana.
- El “chatter” no sustituye ninguna sección, muestra creación e historial y permite preparar mensajes/notas/actividades/archivos sin romper el contexto del proyecto.
- Desde el contexto vivo se inspeccionan las diez familias relacionadas y se recorre gestión↔tarea↔agenda sin abandonar la sección actual.
- Desde Contexto vivo también se accede a Trabajos; cada elemento ofrece inspección rápida y enlace/acción hacia su vista operativa normal.
- Los once tipos relacionados no ocupan una cuadrícula permanente: un selector nativo `Filtrar por tipo` conserva nombre/conteo, abre el inspector y devuelve el foco al cerrarlo.
- Arrastrar/seleccionar un archivo sobre el compositor muestra propuesta de tipo, relación y carpeta OneDrive; confirmar el destino es una acción humana separada de la carga. No existe dropzone independiente.
- No existen `Crear documento` ni selector Mensaje/Nota/Actividad; texto normal significa anotación y `/` crea el tipo elegido con un único `Publicar`.
- En escritorio la IA abierta forma una tercera barra a la derecha del contexto vivo; nunca lo tapa. En anchos menores se apila o usa panel accesible sin desbordar.
- El asistente presenta el compositor antes de conversación/propuestas; la barra principal puede compactarse a iconos y Contexto vivo recibe mayor ancho.
- La propuesta IA del resumen aparece como franja compacta antes de Situación interna y Estado oficial externo.
- Se verifican los tokens tipográficos exactos `--font-ui` y `--font-data` y su uso en interfaz/datos.
- El sidebar compacto muestra únicamente una `J` de 44 px para expandir; abierto alinea `J`, `JBC Proyectos` y `×` en una fila. El control conserva nombre accesible, tooltip, foco y `aria-expanded`; los demás cierres usan `×` y las acciones de negocio conservan texto. APT muestra `Actualización`/`Al día`, no `Frescura`.
- El sidebar no muestra el grupo `Sistema`, `Administración`, `Estados de interfaz` ni el pie `Prototipo · Fase 1`; el único destino inferior es `⚙ Configuración`, reducido a engranaje con nombre accesible en modo slim.
- La página de Proyecto conserva todo su contenido sin acumular bordes en panel, hijos y filas; claro y oscuro mantienen jerarquía mediante espacio, tipografía, superficies y marcadores puntuales.
- Foco, teclado, tacto, contraste, 200 % zoom y estados documentados.
- Revisión independiente sin hallazgos P0/P1; P2 visibles y aceptados/corregidos.

## Evidencia prevista

`docs/testing/evidence/F01/` contendrá checklist, capturas, validación de rutas/estados, revisión independiente y reporte de fase. Ninguna captura contendrá datos reales.
