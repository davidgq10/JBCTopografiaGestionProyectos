# Principios visuales y de interacción

Estado: **propuesta de Fase 1 para checkpoint de usuario**  
Intención: una herramienta profesional, serena, directa y confiable para operación diaria.

## 1. La jerarquía nace del espacio

Para separar contenido se aplica este orden:

1. whitespace;
2. título o cambio tipográfico;
3. fondo sutil;
4. divisor horizontal;
5. borde, solo si los anteriores no resuelven la relación.

Las secciones principales tienen al menos 24 px de separación. `Card` y `Paper` no llevan borde por defecto. No se coloca una tarjeta dentro de otra; un solo contenedor visual puede contener grupos separados por espacio y encabezados.

## 2. Una decisión principal por zona

Cada cabecera, sección, formulario o panel de decisión contiene un único control primario. Las alternativas usan estilo secundario, texto o menú explícito.

Ejemplos:

- cabecera de Proyectos: `Nuevo proyecto` es primario; filtrar y guardar vista son secundarios;
- asistente de creación: `Continuar` o `Crear proyecto`, nunca ambos como primarios;
- aprobación: la zona de decisión puede priorizar `Aprobar` y mostrar `Rechazar` como acción destructiva secundaria con igual accesibilidad;
- explorador: `Subir` es primario; crear/vincular/mover están en acciones secundarias visibles.

“Primario” expresa jerarquía visual, no permiso ni seguridad.

## 3. Riesgos y vencimientos nunca se esconden

El minimalismo no elimina información operativa crítica. Siempre son visibles mediante texto e icono:

- vencimiento y atraso;
- estado En espera y próxima fecha de seguimiento;
- conflicto de persona/recurso;
- aprobación pendiente, obsoleta o fallida;
- cambio externo que requiere atención;
- actualización de datos, datos antiguos y fuente degradada;
- operación offline o no sincronizada.

No se exige abrir un tooltip, menú o hover para descubrirlos.

## 4. Separar significado, origen y confianza

### Proyecto, Trabajo y estado externo

El Proyecto es la contratación y muestra un agregado de `1..N` Trabajos. Cada Trabajo conserva su `Situación interna`; APT/SIRI solo aparece en el Trabajo Plano de catastro. No se fusionan estados entre Trabajos ni con la situación agregada.

### Dato confirmado y propuesta IA

Una propuesta IA lleva siempre:

- rótulo `Propuesta de IA`;
- evidencia enlazable;
- confianza expresada con texto y valor;
- fecha de corte;
- estado de decisión humana.

En el resumen de un Trabajo, la propuesta se presenta compacta arriba de `Situación interna` y `Estado oficial externo`, con espacio/fondo sutil y poco borde. No se inserta silenciosamente entre datos confirmados ni se confunde con un estado.

### Asistente transversal (`DEC-0107`)

El asistente es persistente como capacidad del AppShell, no como pestaña obligatoria ni burbuja superpuesta al trabajo.

- disparador estable `Abrir asistente` con nombre visible/accesible;
- hoja completa en móvil y panel lateral en escritorio, sin cubrir navegación, alertas o acción primaria; dentro del proyecto, DEC-0109 lo coloca a la derecha de Contexto vivo cuando cabe y lo apila/lleva a drawer cuando no;
- barra de contexto siempre visible (`General`, entidad o proyecto) y anuncio/revalidación al cambiar;
- compositor en la parte superior y conversación/propuestas debajo; las respuestas crecen hacia abajo sin desplazar la entrada;
- `/` abre comandos en el compositor o desde la página cuando el foco no está en otro campo; `Comandos` es alternativa táctil;
- `/tarea`, `/agenda` y `/gestion` producen borradores editables, nunca acciones ya realizadas;
- `/buscar` y `/resumen` muestran fuentes, alcance y fecha de corte;
- `Revisar` precede a `Confirmar`; una acción sensible continúa por aprobación/doble control;
- el Centro IA sigue disponible para historial, evidencia y configuración, pero no es requisito para invocar el asistente.

### Actividad unificada de proyecto (`DEC-0108`)

Actividad acompaña la contratación sin sustituir secciones ni fuentes de verdad.

- en escritorio es el alcance `Actividad` del carril Contexto vivo; si se abre IA con ancho seguro, esta aparece en una barra contigua a la derecha, nunca superpuesta;
- en móvil/tableta se abre como panel/drawer con título, cierre, foco contenido y retorno al control `Actividad`;
- no existen pestañas `Mensaje | Nota interna | Actividad`; texto sin `/` publica anotación del usuario y `/tarea`, `/gestion` o `/agenda` selecciona el tipo a crear;
- el compositor único contiene texto, campos del comando, detección de adjuntos, propuesta y un solo botón `Publicar`;
- arrastrar/elegir archivo ocurre dentro del compositor: no hay dropzone separada ni `Crear documento`; antes de `Publicar` se explica tipo, relación y carpeta OneDrive;
- una propuesta IA conserva rótulo, evidencia, confianza y fecha de corte dentro del compositor; una persona edita y confirma antes de publicar o continuar;
- un adjunto muestra destino OneDrive, nombre, tipo, tamaño y estado. El binario queda solo en OneDrive; ante fallo se reintenta o quita y se usa el mismo `Publicar`, sin acción paralela de envío;
- archivar con motivo sustituye cualquier acción de eliminación y conserva la referencia histórica.

### Contexto vivo y relaciones (`DEC-0109`)

Contexto vivo es un pilar ancho para comprender relaciones. Cubre once alcances: Trabajos, Datos, Gestiones, Tareas, Agenda, Trámites, Archivos, Aprobaciones, Actividad, Reportes e Historial; Trámites desaparece para el Trabajo no catastro.

- el nombre y la acción primaria relacionados abren la vista operativa normal; `Inspeccionar aquí` abre dropdown/inspector/sidebar/modal/hoja in situ;
- la navegación relacional es bidireccional y conserva objeto/propietario: Gestión ↔ Tarea ↔ Agenda y vínculos equivalentes con archivos, aprobaciones, actividad, reportes e historial;
- el inspector muestra Proyecto, Trabajo, relación, fuente, versión/estado, última actualización y alcance; nunca reemplaza el enlace real;
- `Adjuntar archivo` lleva al compositor de Actividad. Solo allí drag/selector detecta el adjunto y `Publicar` confirma propuesta y carga;
- el orden horizontal seguro es sección activa → Contexto vivo → IA. Si cualquiera incumpliría su mínimo legible, las zonas se apilan o pasan a drawer conservando objeto, relación, scroll, foco y borrador;
- la composición responde al contenedor y nunca crea una superposición, columna microscópica o scroll horizontal para sostener tres zonas.

### Estado y severidad

Los colores semánticos significan éxito, información, advertencia o error. Los colores de APT, SIRI e IA identifican origen, no resultado. Toda distinción añade texto e icono.

## 5. Superficies neutrales y temas Claro/Oscuro/Sistema

`DEC-0106` establece dos temas completos sobre fondos grises neutros. La neutralidad permite que cualquier acento aprobado conviva con la interfaz sin teñirla ni cambiar su tono profesional.

- `Sistema` es la preferencia inicial cuando el usuario no eligió otra; sigue los cambios claro/oscuro del dispositivo.
- Una elección explícita `Claro` u `Oscuro` prevalece y se sincroniza entre dispositivos.
- Canvas, superficies, navegación y paneles usan neutrales; el acento no rellena la página, sidebar, header ni grandes secciones.
- El acento se reserva para acción primaria, destino activo, selección, progreso y foco.
- Oscuro no es una inversión automática: tiene neutrales, elevación, divisores y variantes semánticas propias.
- Éxito, advertencia, error, información, IA, APT y SIRI conservan significado y contraste en ambos temas.
- Foco, hover, pressed, disabled, selected, gráficos y estados S01–S10 se prueban por tema y acento.
- Cambiar tema no recarga, no pierde foco/contexto y no produce un destello prolongado del tema incorrecto.
- Restaurar tema (`Sistema`) y restaurar acento (teal institucional) son decisiones separadas.

### Tipografía contractual

- `--font-ui: "Inter", "Segoe UI", sans-serif;`
- `--font-data: "Roboto Mono", Consolas, monospace;`

`--font-ui` rige navegación, controles, anotaciones y texto editorial. `--font-data` se reserva para identificadores, rutas/IDs OneDrive, marcas UTC, valores técnicos y fragmentos de comando; no convierte párrafos completos de Actividad en texto monoespaciado. Los fallbacks forman parte del contrato y el reflujo se valida con cada uno.

## 6. Mobile-first real, no versión reducida

El diseño base es una columna a 360 px. Ningún flujo crítico requiere escritorio.

- navegación inferior con cinco destinos;
- encabezado compacto y acciones de 44 × 44 px;
- listados convertidos en filas apiladas, sin scroll horizontal general;
- formularios extensos y comparativos en pantalla completa;
- agenda/lista como vista inicial;
- OneDrive por avance/retroceso y ruta visible;
- cámara y archivos como fuentes de carga;
- comparativos `Actual`/`Propuesto` apilados;
- filtros en hoja completa con resumen activo al volver;
- asistente IA en hoja completa con retorno de foco y contexto autorizado conservado durante la sesión;
- Actividad en panel/hoja con compositor único, adjuntos integrados y un solo `Publicar`;
- Contexto vivo en drawer ancho con sus once alcances; nombre/primaria navega e `Inspeccionar aquí` no navega;
- elegir archivo dentro del compositor equivale al drag-and-drop sobre ese mismo compositor;
- acciones alternativas a hover, swipe y drag.

En 768, 1024 y 1440 px se añade contexto y densidad, pero no capacidades exclusivas.

### Reflujo según contenedor, no solo viewport

- cada grid responde al ancho real de su región con `auto-fit/minmax` o equivalente; un panel lateral abierto puede forzar una columna aunque el viewport sea de escritorio;
- los hijos pueden encogerse y los textos largos usan wrap/`overflow-wrap` sin ampliar el contenedor;
- encabezados y badges permiten varias líneas o pasan a la línea siguiente; no usan `nowrap` cuando puedan desbordar;
- `Estado oficial externo` se prueba por Trabajo con propuesta IA compacta arriba, Contexto vivo ancho + IA, nombre de archivo largo y zoom 200 %;
- sección, Contexto vivo e IA solo se mantienen en paralelo si caben sus mínimos; el apilado/drawer ocurre antes de comprimir o desbordar;
- cronología, compositor y previsualización de adjuntos permiten wrap; ninguna ruta OneDrive, nombre de archivo, comando o error ensancha el carril;
- no existe desbordamiento horizontal general ni local en 360/768/1024/1440; una tabla bidimensional excepcional conserva alternativa accesible.

## 7. Densidad controlada

- una zona funcional tiene una sola delimitación estructural principal; no se acumulan contornos en panel, tarjetas hijas y filas;
- la jerarquía sigue el orden espacio/alineación → tipografía → superficie neutra → divisor puntual → borde completo;
- controles editables, foco, error y selección conservan una señal inequívoca; aligerar la pantalla no puede volver ambiguas las interacciones;
- máximo de 640–720 px para formularios de lectura lineal;
- filas de 48 px; la variante compacta no reduce el objetivo táctil por debajo de 44 px;
- tablas solo cuando comparar columnas aporta valor;
- paginación de servidor, encabezados persistentes y columnas prioritarias;
- detalle secundario mediante divulgación progresiva;
- el tablero usa secciones de acciones y listas breves, no una cuadrícula de tarjetas KPI.

Una tabla móvil se transforma en filas de término/valor. Si la comparación de varias columnas es esencial, se ofrece una vista de detalle por registro y exportación autorizada, no scroll general obligatorio.

## 8. Formularios previsibles

- etiqueta siempre encima; el placeholder solo ilustra formato;
- una columna por defecto; dos únicamente para pares relacionados en ≥1024 px;
- ayuda antes del error cuando evita una equivocación costosa;
- error junto al campo y resumen de errores al inicio;
- valores obligatorios se indican en texto, no solo con asterisco;
- fecha límite y bloque de ejecución tienen nombres distintos;
- acciones al final del flujo; en móvil pueden permanecer fijas si no cubren contenido ni foco;
- se conserva la entrada ante error recuperable;
- antes de crear proyecto o ejecutar una acción sensible se muestra vista previa.

## 9. Movimiento y respuesta

- duración breve y funcional, con reducción de movimiento respetada;
- sin parallax, rebotes decorativos ni transiciones que retrasen una tarea;
- Skeleton para carga estructural; indicador discreto para actualización en segundo plano;
- éxito visible en la página y anunciado; un toast solo es complemento;
- operaciones largas muestran etapa, elemento, posibilidad segura de salir y resultado posterior;
- el foco se mueve al título del nuevo estado o al primer error relevante.

## 10. Interacción equivalente

Cada acción tiene al menos una vía por teclado y tacto:

| Patrón evitado                          | Alternativa obligatoria                                                                                    |
| --------------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| acción solo en hover                    | botón/menú siempre visible y enfocable                                                                     |
| arrastrar tarea                         | `Mover antes de`, `Mover después de`, `Subir`, `Bajar`                                                     |
| arrastrar evento                        | campos Inicio/Fin y opciones sugeridas                                                                     |
| tooltip como única explicación          | texto visible o descripción asociada; tooltip complementario                                               |
| color como único estado                 | texto + icono + color                                                                                      |
| swipe para archivar                     | acción explícita con motivo/confirmación                                                                   |
| selección por mapa preciso              | búsqueda/lista y entrada de dirección equivalente                                                          |
| `/` como única entrada de comandos IA   | botón `Comandos`, lista navegable y formularios estructurados equivalentes                                 |
| `/` como única creación desde Actividad | botón `Comandos` abre `/tarea`, `/gestion`, `/agenda` en el mismo compositor                               |
| soltar archivo como única selección     | control `Adjuntar archivo` dentro del compositor; ambos alimentan la misma propuesta y el mismo `Publicar` |
| inspector como única vía relacional     | nombre/acción primaria abre la vista operativa; `Inspeccionar aquí` es alternativa in situ                 |

## 11. Lenguaje de producto

### Voz

Directa, respetuosa y específica. Se prefiere `No se pudo actualizar la tarea` a `Algo salió mal`.

### Verbos consistentes

- `Crear`, `Guardar`, `Solicitar aprobación`, `Aprobar`, `Rechazar`, `Archivar`, `Restaurar`, `Consultar ahora`.
- No usar `Eliminar` para documentos, clientes, proyectos, gestiones o tareas.
- Para la única excepción de OneDrive, usar `Solicitar envío a papelera de OneDrive` y explicar `solo carpeta vacía`.
- Para APT/SIRI usar `Consultar`, `Ver cambio`, `Ver texto original`; nunca `Presentar`, `Cargar`, `Enviar apelación` ni verbos que impliquen escritura.

### Fechas y tiempo

- interfaz operativa: `23 jul 2026, 14:30 (Costa Rica)`;
- auditoría: la misma presentación y `UTC 2026-07-23T20:30:00Z` en el detalle;
- actualización: `Actualizado hace 18 min · corte 14:12`;
- datos antiguos: `Datos de hace 2 días` más última consulta exitosa;
- avisos: `Entrega 07:00–20:00 · Silencio 20:00–07:00 (Costa Rica)`.

Evitar `hoy` o `mañana` como único dato en aprobaciones, auditoría o vencimientos; se acompaña de fecha absoluta.

## 12. Navegación y orientación

- título de página único y descriptivo;
- breadcrumb en escritorio; en móvil, Atrás con destino textual;
- estado de navegación activo usa acento, peso y marcador, no solo color;
- sidebar expandida alinea `J`, `JBC Proyectos` y `×` en una sola fila; slim muestra únicamente la `J` como botón para expandir, siempre con nombre programático, tooltip en hover/foco y `aria-expanded`; no duplica la marca con `☰` ni muestra textos `Compactar`/`Expandir`;
- el pie del sidebar contiene un único `⚙ Configuración`; en slim se oculta la palabra pero el enlace conserva nombre/tooltip. No se muestran allí `Sistema`, `Administración`, `Estados de interfaz` ni la fase del prototipo;
- Proyecto y Trabajo seleccionado se mantienen visibles; `Trabajo n de N` evita confundir el agregado con una unidad técnica;
- selector de sección de proyecto no usa pestañas horizontales desplazables a 360 px;
- filtros activos se resumen en chips removibles con nombre completo;
- un enlace profundo conserva el contexto y ofrece retorno al objeto padre;
- entorno y versión son visibles sin ocupar la acción principal.

## 13. Tablero, búsqueda y reportes

Orden recomendado del tablero:

1. `Requiere tu atención`;
2. `Agenda próxima`;
3. `Trabajo en curso`;
4. `Cambios externos` solo para Trabajos de catastro autorizados, agrupados por Proyecto;
5. `Salud y actualización` cuando el rol/permiso lo requiere.

### Controles convencionales (`DEC-0114`)

- Modales, drawers, inspectores, paneles y avisos cierran con `×` en su encabezado, nombre accesible contextual, tooltip y retorno de foco; no muestran un botón textual `Cerrar`.
- `×` cierra o abandona una capa; flecha vuelve; chevron expande; elipsis abre más acciones. Un símbolo no cambia de significado entre módulos.
- Los iconos universales compactan el shell, pero `Publicar`, `Guardar`, `Aprobar`, `Archivar` y demás acciones de negocio conservan texto visible.
- El contrato completo y la lista de revisión están en [UI_UX_IMPLEMENTATION_GUIDELINES.md](../development/UI_UX_IMPLEMENTATION_GUIDELINES.md).

Los indicadores tienen definición, periodo, fecha de corte y enlace a la lista fuente. No se usan gráficos 3D, medidores decorativos ni color sin significado. Para pocos valores se prefiere texto/tabla; para tendencias, líneas o barras 2D con alternativa tabular.

## 14. Estados como parte del diseño

Cada vista diseña carga, actualización, vacío, error, permisos, degradación, datos antiguos, offline, éxito y conflicto. Los estados se muestran en el lugar afectado:

- problema global: banner bajo el encabezado;
- problema de sección: estado dentro de esa sección sin ocultar otras;
- error de campo: junto al campo y en resumen;
- conflicto: comparativo con decisión explícita;
- éxito: confirmación persistente y siguiente paso.

En Actividad, el Skeleton se limita a la cronología o al metadato OneDrive afectado; el compositor sigue utilizable según permiso. La subida anuncia selección, progreso, éxito o error, y solo presenta el adjunto como disponible después de confirmar OneDrive y su referencia de metadatos.

En el compositor, `archivo detectado` es selección, no progreso. La secuencia es `Detectado → Propuesta inline → Publicar/confirmación humana → OneDrive → metadatos`. No existe dropzone o botón de confirmación separado.

La precedencia y microcopy están en [STATE_MATRIX.md](./STATE_MATRIX.md).

## 15. Accesibilidad por construcción

- WCAG 2.2 AA como mínimo;
- orden DOM igual al visual;
- foco visible con contraste suficiente y sin quedar oculto por barras fijas;
- objetivos de 44 × 44 px y separación adecuada;
- zoom al 200 % y reflujo sin pérdida ni scroll horizontal general;
- nombres accesibles específicos para iconos (`Abrir notificaciones`, no `Campana`);
- regiones, títulos y tablas semánticas;
- actualizaciones anunciadas sin interrumpir escritura;
- reducción de movimiento, lectores de pantalla y orientación compatibles;
- autocompletado y teclados adecuados para correo, teléfono, identificación, fecha y hora.

## 16. Patrones prohibidos

- tarjetas anidadas o pared de tarjetas;
- bordes completos repetidos en contenedor, hijos y filas cuando espacio, superficie o un divisor puntual ya expresan la relación;
- cuadrículas pesadas y separadores verticales ordinarios;
- sombras fuertes, gradientes decorativos o fondos dominados por el color de acento;
- iconos ambiguos sin nombre;
- placeholders usados como etiquetas;
- formularios largos en modal pequeño;
- scroll horizontal general a 360 px;
- acciones solo en hover, swipe o drag;
- estado representado solo por color;
- APT/SIRI activo para un Trabajo no Plano de catastro;
- mezclar Proyecto agregado, Situación interna del Trabajo y estado externo;
- IA como hecho, ejecución autónoma o panel persistente que obstruye contenido/navegación;
- Contexto vivo estrecho/secundario, sin alcance Trabajos, o que oculta enlaces operativos detrás del inspector;
- IA superpuesta sobre Contexto vivo, o tres zonas comprimidas/desbordadas cuando corresponde apilado/drawer;
- dropzone separada, `Crear documento`, pestañas Mensaje/Nota/Actividad, más de un botón Publicar o carga antes de ese único botón;
- IA activando `Publicar` en Actividad, adjunto fallido representado como disponible o archivo retirado mediante eliminación;
- almacenar o sugerir almacenar binarios en Supabase;
- botones de eliminación documental o `permanentDelete`.

## 17. Criterio de revisión visual

Una pantalla se considera lista para el checkpoint solo si:

- mantiene una acción primaria por zona y ≥24 px entre secciones;
- no contiene tarjeta dentro de tarjeta;
- conserva todos los riesgos/estados relevantes visibles;
- completa el mismo objetivo en 360, 768, 1024 y 1440 px;
- funciona por teclado, tacto, zoom 200 % y reducción de movimiento;
- conserva semántica al probar temas Claro/Oscuro/Sistema con varios acentos;
- mantiene superficies neutrales y no usa el acento como fondo dominante;
- mantiene asistente transversal accesible, contextual y no obstructivo; todo borrador requiere revisión/confirmación;
- mantiene Actividad complementaria, cronológica y accesible; las acciones respetan permiso/aprobación y los adjuntos viven exclusivamente en OneDrive;
- mantiene Proyecto→1..N Trabajos, propuesta IA compacta arriba de Situación interna/Estado oficial y APT/SIRI solo por Trabajo aplicable;
- mantiene Contexto vivo ancho en once alcances; enlaces abren vistas normales, inspector sigue in situ y el compositor integra adjunto/propuesta/un único Publicar;
- mantiene grids, encabezados, badges y textos largos dentro de su contenedor sin overflow a 360/768/1024/1440 y zoom 200 %;
- no muestra APT/SIRI para un Trabajo que no sea Plano de catastro;
- usa datos ficticios y no expone secretos.
