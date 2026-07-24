# Checklist móvil y de accesibilidad

Estado: **criterios UX documentados y corte de prototipo verificado; R2 favorable, pendiente decisión CP-UX del usuario**  
Norma objetivo: WCAG 2.2 AA, 360 px primero, Chrome Android y Safari iPhone.

## Cómo registrar resultados

- `[x]` verificado en la documentación UX de Fase 1.
- `[ ]` requiere ejecución sobre prototipo o aplicación.
- `N/A` exige justificación; no se usa para omitir un flujo difícil.
- Cada fallo se registra con ancho, navegador, orientación, zoom/tema/acento, rol/datos ficticios, pasos, captura y severidad.

## Resultado estático de F1-UX-01

| Control documental                                                                                            | Resultado                    | Evidencia                                                                                          |
| ------------------------------------------------------------------------------------------------------------- | ---------------------------- | -------------------------------------------------------------------------------------------------- |
| Todos los flujos tienen ruta y composición 360/768/1024/1440                                                  | Documentado                  | [USER_FLOWS.md](./USER_FLOWS.md), matriz final                                                     |
| Los diez estados están definidos para cada superficie                                                         | Documentado                  | [STATE_MATRIX.md](./STATE_MATRIX.md)                                                               |
| Teclado, tacto, contraste y zoom tienen criterios explícitos                                                  | Documentado                  | secciones de este checklist                                                                        |
| DEC-0106: Claro/Oscuro/Sistema, fondos neutros y acento no dominante                                          | Documentado                  | tokens, principios, flujo de Apariencia y W14B                                                     |
| DEC-0107: IA transversal, comandos `/` y revisión humana                                                      | Documentado                  | F14, componentes IA, estados y W12                                                                 |
| DEC-0108: Actividad con compositor unificado, una acción `Publicar` y adjuntos OneDrive integrados            | Documentado                  | F17, componentes/estados de Actividad y W12B                                                       |
| DEC-0109: Contexto vivo ancho, once alcances, navegación primaria, inspección in situ e IA adyacente/fallback | Documentado                  | F18, componentes/estados y W12C                                                                    |
| Proyecto contractual con `1..N` Trabajos independientes                                                       | Documentado                  | arquitectura, F03–F09 y W03–W06                                                                    |
| Sidebar 240/64 px y asistente con compositor primero                                                          | Documentado                  | principios, tokens, componentes, estados, W00B y W12                                               |
| Tipografías exactas UI/datos                                                                                  | Documentado                  | `--font-ui: "Inter", "Segoe UI", sans-serif;` y `--font-data: "Roboto Mono", Consolas, monospace;` |
| Regresión overflow `Estado oficial externo`/badge APT                                                         | Documentado                  | principios, tokens, componentes, estados y W05                                                     |
| Contraste estático de colores candidatos Claro/Oscuro                                                         | 52/52 pares; mínimo 4.74:1   | [DESIGN_TOKENS.md](./DESIGN_TOKENS.md); renderizado aún pendiente                                  |
| Hay alternativas a hover y arrastre                                                                           | Documentado                  | [VISUAL_PRINCIPLES.md](./VISUAL_PRINCIPLES.md) e inventario                                        |
| APT/SIRI activo solo en un Trabajo de Plano de catastro                                                       | Documentado                  | rutas, F03/F04/F09 y W04–W06                                                                       |
| Operación celular completa                                                                                    | Documentado a nivel de flujo | matriz siguiente; ejecución pendiente                                                              |
| Validación visual, axe-core, Lighthouse y navegadores reales                                                  | Pendiente                    | corresponde al prototipo/aplicación y revisión independiente                                       |

## Cobertura funcional completa a 360 px

| Capacidad             | Ruta/entrada móvil                                  | Acción completa que debe demostrarse                                                                                                                                               | Cobertura documental | Prueba ejecutable |
| --------------------- | --------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------- | ----------------- |
| Navegación dual       | general ↔ Proyecto/Trabajo                          | entrar al contrato, cambiar entre Trabajos, recorrer secciones y volver al origen/general sin perder contexto                                                                      | Sí                   | [ ]               |
| Acceso                | enlace → `/inicio`                                  | autenticar, MFA externo, retornar o negar sin filtrar datos                                                                                                                        | Sí                   | [ ]               |
| Clientes              | Más → Clientes                                      | crear, revisar duplicado, editar contacto/dirección, archivar                                                                                                                      | Sí                   | [ ]               |
| Proyecto manual       | Proyectos → Nuevo                                   | crear contratación + primer Trabajo obligatorio; revisar cliente, inmuebles, responsables, fechas y vista previa                                                                   | Sí                   | [ ]               |
| Cada tipo de Trabajo  | asistente de Proyecto/Trabajo                       | completar Delimitación, Curvas, Avalúo, Croquis y Plano de catastro como unidades independientes                                                                                   | Sí                   | [ ]               |
| Varios Trabajos       | Proyecto → Trabajos                                 | crear `1..N`, cambiar selector y comprobar que tipo, situación, gestiones, agenda, documentos y externos no se mezclan                                                             | Sí                   | [ ]               |
| Cambio de tipo        | Trabajo → Acciones                                  | comparar, solicitar, decidir, ejecutar y revisar historia sin afectar otros Trabajos                                                                                               | Sí                   | [ ]               |
| Gestiones             | Trabajo seleccionado                                | crear, nota versionada, espera, seguimiento, reanudar/cerrar                                                                                                                       | Sí                   | [ ]               |
| Tareas                | Trabajo seleccionado                                | crear, subtarea, lista, dependencia, avance, archivo                                                                                                                               | Sí                   | [ ]               |
| Agenda                | Agenda/tarea                                        | varios bloques, persona/recurso, detectar conflicto, reprogramar                                                                                                                   | Sí                   | [ ]               |
| APT/SIRI              | Trabajo catastro → Trámites                         | ver fuente/estado/actualización/historia y consultar ahora                                                                                                                         | Sí                   | [ ]               |
| Exclusión externa     | Trabajo no catastro/URL directa                     | no mostrar ruta/campos; historia inactiva solo tras cambio de ese Trabajo                                                                                                          | Sí                   | [ ]               |
| OneDrive              | Más/general o Proyecto/Trabajo/cliente → Documentos | navegar y abrir referencias; enfocar Actividad para adjuntar; mover/archivar/restaurar                                                                                             | Sí                   | [ ]               |
| Papelera excepcional  | carpeta vacía                                       | solicitar con motivo y doble control; bloquear demás casos                                                                                                                         | Sí                   | [ ]               |
| Aprobaciones          | Más → Aprobaciones                                  | comparar, aprobar/rechazar, diferenciar ejecución y obsolescencia                                                                                                                  | Sí                   | [ ]               |
| Notificaciones        | header → Avisos                                     | filtrar, abrir enlace autorizado, marcar, preferencias/horario                                                                                                                     | Sí                   | [ ]               |
| Tablero/búsqueda      | Inicio/Buscar                                       | priorizar, buscar, filtrar, paginar y abrir                                                                                                                                        | Sí                   | [ ]               |
| Control General       | Más → Control General                               | consultar filas normalizadas sin función Excel                                                                                                                                     | Sí                   | [ ]               |
| Reportes              | Más → Reportes                                      | definir, previsualizar, exportar y solicitar guardado OneDrive                                                                                                                     | Sí                   | [ ]               |
| IA transversal        | botón IA o `/` en general/Proyecto/Trabajo          | enfocar compositor superior, usar `/tarea` `/agenda` `/gestion`, leer propuestas debajo, revisar/confirmar y derivar sensible a aprobación                                         | Sí                   | [ ]               |
| Actividad unificada   | Proyecto → Actividad                                | sin `/` publicar anotación; con `/` crear el tipo elegido; usar exactamente un `Publicar` según permiso                                                                            | Sí                   | [ ]               |
| Contexto vivo         | Proyecto → Contexto o relación                      | usar `Filtrar por tipo` para recorrer Datos/Trabajos/Gestiones/Tareas/Agenda/Trámites/Archivos/Aprobaciones/Actividad/Reportes/Historial; abrir vista normal o `Inspeccionar aquí` | Sí                   | [ ]               |
| Adjunto en compositor | Actividad → arrastrar o Adjuntar                    | detectar sin cargar, revisar propuesta en línea tipo/relación/carpeta, usar `Publicar`, cargar a OneDrive, registrar metadatos y recuperar/archivar                                | Sí                   | [ ]               |
| Sidebar compactable   | escritorio → navegación                             | alternar 240/64 px, recorrer iconos por teclado y verificar nombre accesible, tooltip, activo y retorno de foco                                                                    | Sí                   | [ ]               |
| Centro IA             | Más/proyecto → Centro IA                            | consultar historial, evidencia, propuestas y configuración autorizada                                                                                                              | Sí                   | [ ]               |
| Historial/auditoría   | proyecto/Más                                        | filtrar, revisar anterior/nuevo y exportar si autorizado                                                                                                                           | Sí                   | [ ]               |
| Configuración         | pie `⚙ Configuración` / Más → Configuración         | catálogos/versiones/plantillas/recursos según permiso                                                                                                                              | Sí                   | [ ]               |
| Salud y versión       | Más → Salud/Sistema                                 | revisar última ejecución, antigüedad, degradación, umbrales, entorno y SemVer                                                                                                      | Sí                   | [ ]               |
| Apariencia            | Más → Cuenta → Tema y acento                        | seguir Sistema, elegir Claro/Oscuro, previsualizar, validar, guardar y restaurar tema/acento                                                                                       | Sí                   | [ ]               |
| Offline               | cualquier ruta                                      | abrir shell/estado, bloquear modificaciones y recuperar conexión                                                                                                                   | Sí                   | [ ]               |

La prueba falla si una acción exige pasar a escritorio, girar el dispositivo, usar hover/drag, desplazarse horizontalmente en la página o aceptar datos ocultos.

## Matriz mínima de dispositivos y tamaños

| ID        | Viewport/condición                               | Navegador objetivo        | Orientación | Tema                 | Acento             | Zoom/tamaño texto                   |
| --------- | ------------------------------------------------ | ------------------------- | ----------- | -------------------- | ------------------ | ----------------------------------- |
| `M-360-A` | 360 × 800                                        | Chrome Android            | vertical    | Sistema→Claro        | teal               | 100 %                               |
| `M-360-B` | 360 × 800                                        | Safari iPhone equivalente | vertical    | Sistema→Oscuro       | azul               | texto ampliado                      |
| `M-LAND`  | teléfono horizontal                              | Chrome/Safari móvil       | horizontal  | Oscuro explícito     | rosa               | 100 %                               |
| `T-768`   | 768 × 1024                                       | Chrome/Edge               | vertical    | Claro explícito      | índigo             | 100 %                               |
| `D-1024`  | 1024 × 768                                       | Edge/Chrome               | horizontal  | Claro y Oscuro       | naranja            | 100 % y 200 %                       |
| `D-1440`  | 1440 × 900                                       | Edge/Chrome               | horizontal  | Sistema/Claro/Oscuro | teal/personalizado | 100 % y 200 %                       |
| `REFLOW`  | viewport equivalente a 320 CSS px cuando aplique | Edge/Chrome               | vertical    | Claro y Oscuro       | violeta            | zoom 400 % para criterio de reflujo |

La especificación exige capturas 360/768/1024/1440; 1920 y orientación horizontal son controles adicionales. La revisión final también cubre las dos versiones estables recientes de Edge/Chrome.

## Teclado

### Navegación y foco

- [x] El diseño incluye salto a contenido y landmarks claros.
- [ ] Tab recorre controles en el mismo orden visual, sin saltos ni duplicados responsive.
- [ ] Shift+Tab revierte el orden de forma predecible.
- [ ] No existe trampa de teclado en menú, selector, calendario, Drawer o modal.
- [ ] Escape cierra superficies descartables sin perder cambios silenciosamente.
- [ ] Al cerrar, el foco vuelve al disparador; si este desapareció, pasa al siguiente destino lógico.
- [ ] El foco es visible con anillo de 3 px y contraste ≥3:1.
- [ ] Header, bottom nav y barra de acciones no ocultan el foco (`2.4.11`).
- [ ] Cambiar de ruta anuncia el título y posiciona el foco de forma coherente.
- [ ] Paginación, filtros y actualización no restablecen el foco ni el scroll injustificadamente.

### Operaciones

- [x] Hay botones/menús explícitos para toda acción de fila.
- [x] Reordenar usa Subir/Bajar o Mover antes/después.
- [x] Reprogramar usa Inicio/Fin y alternativas; drag no es obligatorio.
- [ ] Crear cliente, Proyecto + primer Trabajo, Trabajo adicional, gestión y tarea funciona solo con teclado.
- [ ] Calendario tiene AgendaList equivalente y operable.
- [ ] Explorador OneDrive permite entrar, volver, seleccionar y operar por teclado.
- [ ] Comparativo de aprobación/conflicto permite recorrer diferencias en orden.
- [ ] Ninguna función aparece únicamente al hover/focus de un contenedor.
- [ ] `/` abre comandos IA solo fuera de otros campos editables o dentro del compositor; Escape cierra y devuelve foco.
- [ ] El botón `Comandos` ejecuta la misma función que `/` por teclado, tacto y lector de pantalla.
- [ ] `Contexto` abre el pilar/inspector y `Actividad` su alcance; cambiar/cerrar conserva Proyecto, Trabajo, objeto/relación y devuelve el foco de forma predecible.
- [ ] En Actividad, `/tarea`, `/gestion` y `/agenda` tienen acciones visibles equivalentes; texto sin `/` sigue siendo anotación del Proyecto.
- [ ] El compositor expone exactamente un `Publicar`; seleccionar, revisar, reintentar o quitar un adjunto OneDrive funciona solo con teclado y vuelve a ese botón.
- [ ] El nombre/acción primaria de Gestión, Tarea, Agenda, archivo o Trabajo abre su vista operativa normal; `Inspeccionar aquí` ofrece la alternativa in situ y conserva retorno.
- [ ] `Adjuntar archivo` por teclado/tacto equivale a arrastrar dentro del compositor; ambos dejan estado `Detectado · aún no cargado` y enfocan la propuesta en línea, no una subida.
- [ ] La `×` expandida y la única `J` del modo slim alternan el sidebar sin texto visible redundante y conservan foco, destino activo y orden; el control y cada destino tienen nombre accesible y tooltip operable también por teclado.
- [ ] El pie muestra solo `⚙ Configuración`; en slim queda únicamente el engranaje con nombre accesible. `Sistema`, `Administración`, `Estados de interfaz` y la fase no aparecen como destinos separados del sidebar.

### Controles complejos

- [ ] Combobox anuncia etiqueta, valor, expansión, resultados y selección.
- [ ] Date/time picker admite escritura y no obliga uso de cuadrícula.
- [ ] Menús anuncian botón y relación con el registro (`Acciones de tarea…`).
- [ ] Tabs en escritorio implementan patrón correcto; en 360 se sustituyen por selector/hoja.
- [ ] Modales/Drawers contienen foco solo mientras están abiertos y tienen título.
- [ ] El compositor unificado anuncia si el contenido es `Anotación en el proyecto` o el tipo seleccionado mediante `/`; no existe selector de modos.
- [ ] Cronología permite llegar a entradas, vínculos relacionados y acciones sin recorrer controles duplicados del layout oculto.
- [ ] `Filtrar por tipo` anuncia sus once opciones y conteos; selección abre el inspector, cerrar limpia el valor y restaura foco; el trail, enlace operativo e `Inspeccionar aquí` anuncian objeto; Trámites no existe fuera de un Trabajo catastro.

## Tacto y puntero

- [x] Objetivo mínimo documentado: 44 × 44 px.
- [ ] Botones, iconos, chips removibles, filas accionables y targets de calendario cumplen 44 × 44 px.
- [ ] Existe separación suficiente para evitar activaciones accidentales, especialmente Aprobar/Rechazar y Archivar/Restaurar.
- [ ] La activación ocurre al completar el gesto; puede cancelarse antes de soltar (`2.5.2`).
- [x] No hay gesto multipunto, trazo preciso, swipe ni arrastre obligatorio (`2.5.1`, `2.5.7`).
- [ ] Scroll vertical no activa acciones de fila accidentalmente.
- [ ] Bottom nav respeta safe area y no cubre contenido/teclado.
- [ ] Barras sticky no cubren el último campo, el error ni el control enfocado.
- [ ] Cámara/Archivos permite cancelar y volver sin pérdida inesperada.
- [ ] El teclado virtual no oculta el campo activo ni el resumen de acciones.
- [ ] La hoja IA móvil respeta safe area/teclado; cerrada no tapa bottom nav y abierta ofrece cierre/retorno de foco.
- [ ] El panel Actividad móvil respeta safe area/teclado, conserva visible el compositor/único `Publicar` y devuelve foco a `Actividad` al cerrar.
- [ ] Carga de adjunto por cámara/archivos ofrece objetivos de 44 px y no confunde `Quitar` con `Archivar` ni con la publicación.
- [ ] Arrastrar dentro del compositor permite cancelar antes de soltar y no carga al completar el gesto; cámara/selector ofrece la misma propuesta en línea y el mismo `Publicar`.
- [ ] Al apilar Contexto vivo e IA, cada panel tiene cierre/Atrás, safe area y retorno de foco sin ocultar el objeto relacionado.

## Contraste, color y acento

- [x] Pares funcionales y reglas de acento están definidos en [DESIGN_TOKENS.md](./DESIGN_TOKENS.md).
- [x] Claro y Oscuro usan canvas/superficies grises neutras; el acento no es fondo dominante.
- [ ] Sin elección explícita, Tema inicia en Sistema y refleja cambios del dispositivo.
- [ ] Claro/Oscuro explícito prevalece, se sincroniza y Restaurar vuelve a Sistema.
- [ ] Cambiar tema conserva ruta, scroll, foco, datos y estado S01–S10 sin destello prolongado incorrecto.
- [ ] Texto normal alcanza al menos 4.5:1.
- [ ] Texto grande alcanza al menos 3:1 cuando aplica.
- [ ] Bordes necesarios, iconos informativos, foco y componentes alcanzan al menos 3:1 respecto a superficies adyacentes.
- [ ] Links se distinguen sin depender solo del color.
- [ ] Estado seleccionado/activo usa marcador, peso o texto además del color.
- [ ] Éxito, advertencia, error, información, IA, APT y SIRI mantienen significado con todos los acentos en ambos temas.
- [ ] Teal, azul, índigo, violeta, rosa y naranja pasan en default, hover, pressed, focus y selected de Claro/Oscuro.
- [ ] Un personalizado de bajo contraste en cualquiera de los temas es rechazado con explicación y no queda guardado.
- [ ] Un personalizado válido se sincroniza sin modificar colores semánticos.
- [ ] Modo alto contraste/colores forzados conserva foco, controles y estados cuando el navegador lo soporte.
- [ ] Capturas en escala de grises siguen permitiendo identificar estados.
- [ ] Anotación, tipo creado con `/`, Actividad, propuesta IA y estados de carga/error OneDrive conservan texto/icono/estructura además del color.

## Zoom, reflujo, orientación y texto

- [x] Formularios son de una columna en móvil; no hay scroll horizontal general por diseño.
- [ ] Zoom 200 % conserva contenido y funcionalidad en 1024/1440 sin superposición.
- [ ] Reflujo equivalente a 320 CSS px cumple `1.4.10` salvo contenido bidimensional esencial con alternativa.
- [ ] Texto al 200 % no se recorta, solapa ni desaparece.
- [ ] Espaciado de texto personalizado (`1.4.12`) no rompe botones, badges o filas.
- [ ] Vertical y horizontal funcionan sin restringir orientación (`1.3.4`).
- [ ] Nombres/rutas OneDrive largos parten línea o truncan con acceso al valor completo, sin scroll general.
- [ ] Tablas cambian a filas; no reducen tipografía para “hacerlas caber”.
- [ ] Comparativos se apilan a una columna y mantienen los rótulos Actual/Propuesto.
- [ ] A 200 % no aparece una segunda versión duplicada y enfocable de la navegación.
- [ ] Cero overflow horizontal local/general a 360/768/1024/1440 y zoom 200 %, con sección + Contexto vivo + IA o su fallback apilado/drawer.
- [ ] Grids responden al ancho real del contenedor mediante auto-fit/minmax o equivalente, no solo al viewport.
- [ ] Encabezados y badges permiten wrap/altura automática; `Estado oficial externo` + APT/SIRI no desborda.
- [ ] IDs, rutas OneDrive, textos oficiales y errores largos usan wrap seguro y conservan el valor completo accesible.
- [ ] Cronología, compositor unificado, comandos, nombre/tipo/tamaño/ruta de adjunto, progreso y error OneDrive reordenan sin overflow.
- [ ] Contexto vivo conserva 400–480 px solo cuando caben sección e IA; activa apilado/Drawer antes de overflow.
- [ ] Alcances, trail bidireccional y propuesta tipo/relación/carpeta reordenan; IA pasa a apilado/drawer antes de comprimir mínimos.
- [ ] Los fallbacks exactos de `--font-ui: "Inter", "Segoe UI", sans-serif;` y `--font-data: "Roboto Mono", Consolas, monospace;` no recortan texto ni alteran el orden funcional.

## Semántica y lector de pantalla

- [ ] Cada página tiene un `h1`; encabezados no saltan niveles sin razón.
- [ ] Landmarks tienen nombres únicos cuando se repiten.
- [ ] Listas, tablas, `dl`, fieldsets y timelines usan estructura semántica adecuada.
- [ ] Cada control expone nombre, rol, valor y estado (`4.1.2`).
- [ ] El texto visible del control está incluido en su nombre accesible (`2.5.3`).
- [ ] Iconos decorativos se ocultan; iconos funcionales tienen nombre por acción.
- [ ] Badges anuncian texto completo (`Situación interna: En ejecución`).
- [ ] APT, SIRI, IA, severidad y estado no se anuncian solo como color/icono.
- [ ] Actualizaciones, éxito, error, offline y conflicto usan mensajes de estado apropiados (`4.1.3`) sin duplicar anuncios.
- [ ] Contadores de avisos no interrumpen cada incremento; se anuncian al visitar o de forma agregada.
- [ ] El panel IA anuncia contexto General/entidad/Proyecto/Trabajo y sus cambios; el compositor precede en DOM a conversación/propuestas sin releerlas completas.
- [ ] Actividad es región identificable; la cronología usa lista/`feed` semántico y cada entrada expone actor, tipo, fecha/hora y vínculo operativo relacionado.
- [ ] Progreso OneDrive se anuncia de forma agregada; éxito/error se anuncian una vez y el adjunto fallido nunca se expone como disponible.
- [ ] Contexto vivo es región identificada; anuncia alcance, objeto, relación y fuente sin repetir la sección completa.
- [ ] Al arrastrar/elegir dentro del compositor se anuncia `detectado, aún no cargado`; propuesta y etapa de publicación tienen nombres distintos y no aparece otra confirmación.
- [ ] Fechas relativas tienen fecha absoluta disponible; auditoría incluye UTC en detalle.

## Formularios, errores y autenticación

- [x] Etiquetas superiores persistentes; placeholders no son etiquetas.
- [ ] Campos obligatorios se explican en texto y programáticamente.
- [ ] Ayuda/error está asociado al campo y el resumen enlaza a cada error.
- [ ] El mensaje identifica el problema y sugiere corrección cuando existe (`3.3.1`, `3.3.3`).
- [ ] Datos válidos permanecen tras error de servidor o validación.
- [ ] Entrada repetida se autocompleta o reutiliza cuando sea seguro (`3.3.7`).
- [ ] `autocomplete` e input modes adecuados para nombre, correo, teléfono, dirección y códigos (`1.3.5`).
- [ ] Vista previa distingue y confirma el Proyecto contractual y su primer Trabajo antes de crear.
- [ ] Autenticación no exige una prueba cognitiva adicional de la PWA; MFA permanece en Microsoft (`3.3.8`).
- [ ] Timeout de sesión advierte y permite continuar cuando la política lo admita, sin exponer datos.

## Estados y contenido dinámico

- [x] S01–S10 están definidos por superficie.
- [ ] Loading conserva estructura y evita CLS excesivo.
- [ ] Updating no borra datos, foco ni posición.
- [ ] Vacío distingue sin datos de sin resultados.
- [ ] Error local no bloquea módulos independientes.
- [ ] Permiso no filtra nombre, ID, tipo, totales o metadatos.
- [ ] Degradación identifica fuente, impacto, último éxito y lo disponible.
- [ ] Datos antiguos incluyen fecha de corte y tiempo absoluto.
- [ ] Offline bloquea toda modificación y no guarda datos sensibles por defecto.
- [ ] Éxito persiste en página y no depende de toast.
- [ ] Conflicto presenta diferencias y resolución explícita sin selección automática.
- [ ] Actividad fuerza S01–S10 sin bloquear la sección activa: carga local, vacío, permiso, OneDrive degradado, éxito confirmado y conflicto de versión/eTag.
- [ ] Error de subida conserva texto/propuesta seguros y ofrece Reintentar o Quitar antes de volver al mismo `Publicar`; no existe botón alterno de envío.
- [ ] Contexto vivo fuerza S01–S10 por alcance/relación y conserva sección/objeto; permiso no filtra nombres, IDs, totales o metadatos.
- [ ] Cambiar versión/relación/carpeta después de proponer fuerza S10 y exige un nuevo `Publicar`; no reutiliza una aceptación obsoleta.

## APT/SIRI: control negativo obligatorio

### Trabajo de Plano de catastro

- [x] Wireframe muestra propuesta IA compacta, Situación interna y Estado oficial externo como tres zonas separadas y en ese orden.
- [x] APT y SIRI tienen fuentes, trámites, textos e historias independientes.
- [x] Únicos verbos activos: Consultar ahora, Ver trámite, Ver texto original, Ver historial.
- [ ] `Actualización`, fecha de corte, última consulta exitosa y degradación se perciben por texto/icono; la palabra visible `Frescura` no aparece.
- [ ] Consultar ahora anuncia límite de frecuencia y no ejecuta escritura.

### Trabajos de Delimitación, Curvas de nivel, Avalúo y Croquis

- [x] Arquitectura y wireframes no incluyen ruta, pestaña, campo o estado APT/SIRI.
- [ ] Crear manualmente cada tipo confirma ausencia en 360/768/1024/1440.
- [ ] URL directa `/tramites` muestra sección genérica no disponible, sin datos o nombres externos.
- [ ] Búsqueda/tablero no presenta campos externos para esos Trabajos.
- [ ] Al cambiar un Trabajo desde catastro, la historia aparece solo en su Historial como `Histórico inactivo`, sin Consultar ahora ni efecto sobre otros Trabajos.
- [ ] El evento de cambio muestra usuario, UTC, tipo/estado anteriores, tipo nuevo y aprobación.

La prueba falla ante un campo deshabilitado APT/SIRI en un Trabajo no catastral: debe estar ausente, no meramente inactivo.

## OneDrive, Actividad, IA y acciones sensibles

- [x] No existe acción de eliminar documento ni `permanentDelete`.
- [ ] Carpeta no vacía solo ofrece Archivar; raíz/99/protegidas no ofrecen papelera.
- [ ] Papelera de carpeta vacía exige motivo, doble control y nueva validación.
- [ ] `Adjuntar archivo` enfoca el compositor de Actividad; no existe dropzone, `Crear documento` ni carga directa en Documentos/Contexto vivo.
- [ ] El compositor admite arrastre interno, cámara/archivos y presenta OneDrive como destino único.
- [ ] Propuesta IA anuncia evidencia, confianza, corte y estado de decisión.
- [ ] `/tarea`, `/agenda` y `/gestion` generan borradores estructurados editables; `/buscar` y `/resumen` se identifican como lectura.
- [ ] IA nunca escribe desde la respuesta: `Revisar` y confirmación humana preceden al comando normal de servidor.
- [ ] Acción IA sensible continúa por aprobación/doble control; el chat no permite omitirla.
- [ ] El contexto IA se revalida al navegar y un permiso revocado retira datos/borrador sensible.
- [ ] El panel persistente no tapa navegación, riesgos, acción primaria ni foco en 360/768/1024/1440; compositor arriba y conversación/propuestas debajo.
- [x] DEC-0108 mantiene todas las secciones; Actividad es contexto adicional, no reemplazo de Gestiones/Tareas/Programación/Documentos/Historial.
- [x] DEC-0109 cubre Datos, Trabajos, Gestiones, Tareas, Agenda, Trámites, Archivos, Aprobaciones, Actividad, Reportes e Historial sin convertirlos en copias o reemplazos.
- [ ] Nombres/acciones primarias abren las vistas operativas normales; `Inspeccionar aquí` recorre relaciones en ambos sentidos y conserva retorno a sección/objeto.
- [ ] En escritorio con ancho seguro, IA aparece inmediatamente a la derecha de Contexto vivo; nunca overlay ni barra que expulsa la sección del viewport.
- [ ] En ancho insuficiente, zoom o texto ampliado, IA/Contexto se apilan o usan drawer y conservan Proyecto, Trabajo, sección, objeto, relación, scroll, foco y borrador.
- [ ] No existen pestañas Mensaje/Nota interna/Actividad; sin `/` se presenta anotación del Proyecto y con `/` el tipo autorizado seleccionado.
- [ ] `/tarea`, `/gestion`, `/agenda` y acciones equivalentes crean borradores para los casos de uso normales; revalidan RLS, versión, auditoría y aprobación.
- [ ] IA dentro del compositor conserva rótulo, evidencia, confianza y fecha de corte; una persona edita y usa el mismo `Publicar`; IA nunca lo activa.
- [ ] Arrastrar/elegir dentro del compositor solo detecta; antes de `Publicar` aparece propuesta en línea de tipo, relación y carpeta OneDrive, con regla/evidencia y aprobación si aplica.
- [ ] La persona edita entre opciones autorizadas y existe exactamente un `Publicar` para anotación, comando y adjunto; no hay segunda confirmación ni carga automática.
- [ ] El binario se guarda solo en OneDrive; Supabase recibe exclusivamente metadatos, `driveId`/`driveItemId` y relación con Actividad.
- [ ] Metadatos en carga muestran Skeleton local; subida muestra etapa/progreso; fallo no publica referencia rota ni borra el texto.
- [ ] Si OneDrive recibió el archivo pero falló la relación, se reconcilia o archiva con motivo según permiso; nunca se elimina.
- [ ] Un adjunto existente solo ofrece Archivar/Restaurar conforme a permiso/aprobación, conserva historia y nunca muestra Eliminar.
- [ ] Aprobación distingue Pendiente, Aprobada, En ejecución, Ejecutada, Fallida y Desactualizada.
- [ ] La misma persona no satisface dos participaciones cuando se exige doble control.

## Contenido y localización

- [ ] Toda interfaz y mensajes están en español claro.
- [ ] Fechas operativas indican Costa Rica cuando puede haber ambigüedad.
- [ ] Horario de avisos dice `Entrega 07:00–20:00 · Silencio 20:00–07:00`.
- [ ] `Hoy`/`mañana` se acompaña de fecha absoluta en decisiones/auditoría.
- [ ] Textos largos, nombres legales, códigos y rutas ficticias no rompen layout.
- [ ] No se exponen secretos, cookies, tokens, credenciales, PII innecesaria ni payload sensible.
- [ ] No se usa lenguaje de “eliminar” donde el dominio exige archivar.
- [ ] Anotaciones usan `--font-ui`; comandos, IDs, rutas y UTC usan `--font-data` sin aplicar monoespaciada a párrafos completos.

## Rendimiento perceptual y movimiento

- [ ] Skeleton coincide con estructura y no produce saltos notorios.
- [ ] La acción responde visualmente de inmediato y evita doble envío.
- [ ] Indicador de operación larga muestra progreso/etapa sin prometer éxito prematuro.
- [ ] `prefers-reduced-motion` elimina desplazamientos/animaciones no esenciales.
- [ ] No hay parallax, autoplay, destellos ni animación que sea única señal.
- [ ] Listas grandes mantienen navegación y paginación accesibles.

## Secuencia de prueba recomendada

1. Ejecutar cada fila de cobertura a 360 px con Técnico ficticio y alcance limitado.
2. Repetir consultas con Solo lectura y confirmar que las acciones no aparecen y el servidor niega URL/comando.
3. Ejecutar acciones sensibles con actores ficticios conforme a la política que finalmente apruebe DEC-0104.
4. Repetir F03 para los cinco tipos de Trabajo, crear un Proyecto con varios planos independientes y ejecutar el control negativo APT/SIRI por Trabajo.
5. Forzar S01–S10 por ruta, con foco/lector de pantalla.
6. Repetir 768/1024/1440 y orientación horizontal.
7. Probar teclado completo, zoom 200 %, reflujo, texto ampliado y reducción de movimiento.
8. Probar IA desde capa general/Proyecto/Trabajo: compositor primero, conversación/propuestas debajo, `/` y botón Comandos, cinco comandos, cambio de contexto, confirmación y aprobación sensible.
9. Probar DEC-0108 desde toda sección: anotación sin `/`, `/tarea` `/gestion` `/agenda`, adjunto integrado y exactamente un `Publicar`, con lectura y permisos limitados.
10. Probar DEC-0109 desde Trabajo, Gestión, Tarea, Agenda y archivo: recorrer los once alcances, abrir cada vista operativa por nombre/primaria, usar `Inspeccionar aquí`, Atrás y control negativo de Trámites.
11. Probar arrastre dentro del compositor, selector, cámara y teclado: confirmar que solo detectan; revisar/cambiar propuesta tipo/relación/carpeta, usar `Publicar` y forzar éxito/error OneDrive, metadatos, conflicto, reintento y archivo.
12. Abrir Contexto vivo + IA: validar IA a la derecha cuando cabe y fallback apilado/drawer en contenedores estrechos, 360/768/1024/1440 y zoom 200 %, sin overlay ni pérdida de estado.
13. Forzar textos largos/badge APT/trail/nombre/propuesta/ruta/error OneDrive y confirmar auto-fit/wrap sin overflow.
14. Probar las dos familias/fallbacks exactos, texto ampliado y espaciado WCAG sin truncar controles o datos técnicos.
15. Probar Sistema→Claro/Oscuro, elección explícita y seis acentos más personalizado válido/inválido; ejecutar contraste automatizado y manual en ambos temas.
16. Ejecutar axe-core sin hallazgos críticos/serios y Lighthouse accesibilidad ≥95.
17. Realizar la revisión independiente posterior en Edge, Chrome, Android e iPhone y enlazar evidencia; esta lista no la sustituye.

## Criterio de salida del checkpoint UX

- [x] Cero hallazgos P0/P1 de navegación, móvil, acceso, semántica o invariantes.
- [x] Cero flujo crítico incompleto a 360 px.
- [x] Cero scroll horizontal general.
- [x] Cero control solo hover/drag/swipe.
- [x] Cero APT/SIRI activo fuera de un Trabajo de Plano de catastro.
- [x] Cero mezcla entre Situación interna/Estado oficial externo o propuesta IA/dato confirmado; orden propuesta → interna → externa.
- [x] Cero combinación de acento que cambie semántica o incumpla contraste.
- [x] Cero superficie dominante teñida por el acento y cero fallo de contraste/foco en Claro u Oscuro.
- [x] Cero escritura directa por IA, cero comando sin alternativa táctil y cero panel IA que obstruya el flujo.
- [x] Cero sustitución de secciones por Actividad, cero publicación directa de IA y cero acción asumida sin permiso/aprobación efectiva.
- [x] Cero relación unidireccional, cero entidad sin enlace operativo normal y cero alcance faltante entre los once de Contexto vivo salvo Trámites correctamente excluido.
- [x] Cero pestaña de modo, dropzone separado, `Crear documento` o segundo botón de confirmación; exactamente un `Publicar` sirve anotación, comando y adjunto.
- [x] Cero carga al detectar un archivo, cero propuesta sin tipo/relación/carpeta explicados y cero carga sin `Publicar` humano vigente.
- [x] Cero IA superpuesta al Contexto vivo y cero pérdida de Proyecto/Trabajo/sección/objeto/relación/foco al activar el fallback.
- [x] Cero binario en Supabase, cero adjunto roto presentado como disponible y cero eliminación de adjuntos/documentos.
- [x] Cero overflow horizontal; badges APT/SIRI, pilar/drawer de 400–480 px, cronología, adjuntos, encabezados y textos largos envuelven dentro del contenedor incluso a 200 %.
- [x] Cero mezcla entre los `1..N` Trabajos; el agregado contractual nunca impone un único tipo o estado operativo.
- [x] Sidebar compacta conserva nombre accesible, tooltip, foco y activo; asistente conserva compositor arriba en todo breakpoint.
- [x] Hallazgos P2 corregidos o aceptados explícitamente con riesgo visible.
- [x] Evidencia guardada por el orquestador bajo `docs/testing/evidence/F01/` sin datos reales.

Resultado integrado: `F1-INDEPENDENT-REVIEW-R2-2026-07-23.md` emitió GO para presentar CP-UX con 0 P0/P1/P2/P3 abiertos. Esto verifica el prototipo de Fase 1; no equivale a certificación WCAG integral ni a la futura UAT productiva.
