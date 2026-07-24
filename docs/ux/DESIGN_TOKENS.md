# Tokens de diseño

Estado: **contrato UX propuesto para Fase 1; sujeto al checkpoint visual**  
Destino futuro: centralización única en `theme.ts` durante Fase 3 (`AC-020-01`). Este documento no es código ni autoriza implementación.

## Principios del sistema de tokens

- Los tokens expresan función (`text.muted`, `status.error.text`), no una pantalla concreta.
- El acento personal solo afecta acción primaria, navegación activa, selección, progreso y foco.
- Éxito, advertencia, error, información, IA, APT y SIRI conservan colores estables ante cualquier acento.
- `DEC-0106` exige temas Claro y Oscuro con canvas/superficies grises neutras; el acento nunca es fondo dominante.
- `DEC-0107` usa el color IA solo para identificar origen; el panel persistente conserva superficies neutrales y no domina el layout.
- `DEC-0108` usa un compositor único sin pestañas, adjuntos integrados y un solo `Publicar`; el binario va únicamente a OneDrive.
- `DEC-0109` convierte Contexto vivo en pilar ancho de once alcances y ordena sección → contexto → IA cuando caben mínimos legibles.
- Proyecto representa contratación con `1..N` Trabajos y Trabajo la unidad técnica; propuesta IA, Situación interna y estado externo mantienen jerarquías separadas. Los binarios van a OneDrive; Supabase conserva solo metadatos e identificadores.
- Toda combinación final se valida en ambos temas, incluidos estados hover, foco, seleccionado, deshabilitado y zoom.
- Una diferencia de color siempre se acompaña de texto, icono, forma o posición.

## Resolución del tema

| Preferencia guardada | Resolución                     | Comportamiento                                          |
| -------------------- | ------------------------------ | ------------------------------------------------------- |
| sin elección previa  | `Sistema`                      | toma Claro/Oscuro del dispositivo; es el estado inicial |
| `Sistema`            | preferencia activa del sistema | cambia con el sistema sin perder ruta, foco ni datos    |
| `Claro`              | tema claro                     | prevalece sobre el sistema y se sincroniza              |
| `Oscuro`             | tema oscuro                    | prevalece sobre el sistema y se sincroniza              |

Antes de conocer el perfil se usa Sistema. Después de iniciar sesión, una elección explícita sincronizada prevalece. Restaurar tema vuelve a `Sistema`; no modifica el acento. La aplicación evita un destello prolongado del tema incorrecto y anuncia el cambio solo cuando fue iniciado por el usuario.

## Colores neutros por tema

| Token                  |                    Claro |                Oscuro | Uso                                          |
| ---------------------- | -----------------------: | --------------------: | -------------------------------------------- |
| `color.canvas`         |                `#F5F5F5` |             `#171717` | fondo general neutro                         |
| `color.surface`        |                `#FFFFFF` |             `#262626` | superficie principal                         |
| `color.surface.subtle` |                `#FAFAFA` |             `#2F2F2F` | agrupación secundaria sin borde              |
| `color.surface.raised` |                `#FFFFFF` |             `#303030` | menú, drawer o elemento flotante             |
| `color.text`           |                `#171717` |             `#FAFAFA` | texto principal                              |
| `color.text.muted`     |                `#525252` |             `#D4D4D4` | metadatos y ayuda                            |
| `color.text.subtle`    |                `#737373` |             `#A3A3A3` | texto secundario solo sobre fondos validados |
| `color.divider`        |                `#E5E5E5` |             `#404040` | divisor horizontal tenue                     |
| `color.border`         |                `#D4D4D4` |             `#525252` | borde cuando el espacio/divisor no bastan    |
| `color.overlay`        | `rgba(23, 23, 23, 0.48)` | `rgba(0, 0, 0, 0.72)` | fondo de modal/drawer                        |

`color.surface` no implica tarjeta. Se usa una sola superficie por zona; las subsecciones se separan con espacio y títulos. Sidebar, header, canvas y paneles no usan el acento como relleno dominante.

## Acento institucional y opciones de usuario

| Opción             | `accent.solid` ambos temas | `accent.text/focus` claro | `accent.text/focus` oscuro |
| ------------------ | -------------------------: | ------------------------: | -------------------------: |
| Teal institucional |                  `#0F766E` |                 `#0F766E` |                  `#5EEAD4` |
| Azul               |                  `#1D4ED8` |                 `#1D4ED8` |                  `#93C5FD` |
| Índigo             |                  `#4338CA` |                 `#4338CA` |                  `#C7D2FE` |
| Violeta            |                  `#6D28D9` |                 `#6D28D9` |                  `#DDD6FE` |
| Rosa               |                  `#BE123C` |                 `#BE123C` |                  `#FECDD3` |
| Naranja            |                  `#C2410C` |                 `#C2410C` |                  `#FED7AA` |

Roles derivados por opción:

| Token                | Regla                                                                                                       |
| -------------------- | ----------------------------------------------------------------------------------------------------------- |
| `accent.solid`       | base aceptada para control primario                                                                         |
| `accent.solid.text`  | blanco o neutral oscuro según el par que alcance 4.5:1; predefinidos usan blanco sobre los sólidos listados |
| `accent.text`        | tono que alcanza 4.5:1 sobre `surface` y `canvas`                                                           |
| `accent.subtle`      | tinte claro en Claro y tinte oscuro en Oscuro para selección; nunca canvas dominante                        |
| `accent.subtle.text` | compañero validado a 4.5:1 sobre `accent.subtle` en cada tema                                               |
| `accent.focus`       | anillo con contraste mínimo 3:1 respecto a superficies adyacentes                                           |
| `accent.hover`       | variación perceptible que conserva contraste y significado                                                  |
| `accent.pressed`     | variación más oscura; no depende solo de color, también de estado del control                               |

Un color personalizado se acepta únicamente si la vista previa genera y valida todos esos pares en Claro y Oscuro. No se “corrige” silenciosamente: se muestra el valor propuesto, los derivados utilizables y la razón; el usuario confirma o elige otro. Restaurar acento vuelve a `#0F766E` y no cambia el tema.

## Colores semánticos estables

| Familia     | Claro fondo / texto   | Oscuro fondo / texto  | Uso                                           |
| ----------- | --------------------- | --------------------- | --------------------------------------------- |
| Neutral     | `#F5F5F5` / `#404040` | `#2F2F2F` / `#E5E5E5` | estado informativo neutro/archivado           |
| Éxito       | `#F0FDF4` / `#166534` | `#052E16` / `#BBF7D0` | operación confirmada o servicio sano          |
| Información | `#EFF6FF` / `#1D4ED8` | `#172554` / `#BFDBFE` | ayuda o proceso informativo                   |
| Advertencia | `#FFFBEB` / `#92400E` | `#451A03` / `#FDE68A` | atención, vencimiento próximo, datos antiguos |
| Error       | `#FEF2F2` / `#B91C1C` | `#450A0A` / `#FECACA` | fallo, vencido o validación bloqueante        |
| IA          | `#F5F3FF` / `#6D28D9` | `#2E1065` / `#DDD6FE` | origen IA, nunca estado de veracidad          |
| APT         | `#ECFEFF` / `#155E75` | `#083344` / `#A5F3FC` | origen APT, solo Plano de catastro            |
| SIRI        | `#FFF1F2` / `#9F1239` | `#4C0519` / `#FECDD3` | origen SIRI, solo Plano de catastro           |

Reglas:

- `Advertencia` y `Error` no se reemplazan por el color APT/SIRI cuando la fuente falla.
- `IA` identifica una propuesta; aprobado/rechazado usa además la semántica correspondiente.
- La prioridad Crítica usa texto `Crítica`, icono y semántica de error; Urgente usa `Urgente` y advertencia/error según contexto.
- Los estados externos normalizados se expresan principalmente con texto; su color semántico deriva del significado y no del proveedor.
- Cada par se comprueba en default, foco, hover, selected y disabled; no se deriva por inversión automática.

## Tipografía

Familias obligatorias exactas:

```css
--font-ui: 'Inter', 'Segoe UI', sans-serif;
--font-data: 'Roboto Mono', Consolas, monospace;
```

No se añade `system-ui` ni se sustituye `Inter` por `Inter Variable` en este contrato. La implementación puede cargar las fuentes de forma compatible con rendimiento/privacidad, pero debe conservar exactamente estas cadenas y fallbacks.

| Token               | Tamaño / línea |    Peso | Uso                                                                           |
| ------------------- | -------------: | ------: | ----------------------------------------------------------------------------- |
| `type.display`      |     32 / 40 px |     650 | título principal en escritorio amplio                                         |
| `type.h1`           |     28 / 36 px |     650 | título de página; 24/32 px en móvil                                           |
| `type.h2`           |     22 / 30 px |     650 | título de sección principal                                                   |
| `type.h3`           |     18 / 26 px |     600 | subsección o panel                                                            |
| `type.body`         |     16 / 24 px |     400 | contenido y formularios                                                       |
| `type.body.strong`  |     16 / 24 px |     600 | énfasis no decorativo                                                         |
| `type.small`        |     14 / 20 px |     400 | metadatos, tabla y ayuda                                                      |
| `type.small.strong` |     14 / 20 px |     600 | etiquetas/estado                                                              |
| `type.caption`      |     12 / 18 px |     500 | uso excepcional: versión o marca temporal auxiliar                            |
| `type.mono`         |     14 / 20 px |     400 | comandos y fragmentos técnicos; usa `--font-data`                             |
| `type.data`         |     14 / 20 px | 400/500 | códigos, correlación, `driveId`/`driveItemId`, rutas y UTC; usa `--font-data` |

Normas:

- tamaño mínimo ordinario 14 px; 12 px no contiene acciones, errores ni información crítica;
- ancho óptimo de párrafo 60–75 caracteres;
- números tabulares para fechas, cantidades y métricas comparables;
- mayúsculas sostenidas solo para códigos externos existentes, no para encabezados completos;
- subrayado o indicador adicional para enlaces; el acento solo no basta.
- navegación, controles, compositor, mensajes y notas usan `--font-ui`; `--font-data` no se aplica a párrafos completos ni sustituye jerarquía semántica.

## Espaciado

| Token      | Valor | Uso típico                           |
| ---------- | ----: | ------------------------------------ |
| `space.1`  |  4 px | icono/indicador interno              |
| `space.2`  |  8 px | elementos estrechamente relacionados |
| `space.3`  | 12 px | contenido dentro de fila             |
| `space.4`  | 16 px | grupo/campo                          |
| `space.6`  | 24 px | mínimo entre secciones principales   |
| `space.8`  | 32 px | separación de zonas                  |
| `space.12` | 48 px | cambio de bloque mayor               |
| `space.16` | 64 px | respiración de página amplia         |

La escala no se reduce por breakpoint. En móvil cambia el ancho y la composición; se mantiene al menos `space.6` entre secciones.

## Tamaños y objetivos interactivos

| Token                    |                            Valor | Regla                                                                               |
| ------------------------ | -------------------------------: | ----------------------------------------------------------------------------------- |
| `control.height`         |                            44 px | altura base de inputs y botones                                                     |
| `control.hit.min`        |                       44 × 44 px | objetivo táctil/teclado mínimo                                                      |
| `control.height.large`   |                            48 px | acción primaria móvil o campo destacado                                             |
| `control.composerAttach` | 44 × 44 px + área del compositor | elegir/arrastrar dentro del compositor detecta adjunto; no existe dropzone separada |
| `row.height`             |                            48 px | fila ordinaria                                                                      |
| `row.height.comfortable` |                            56 px | fila móvil con dos líneas                                                           |
| `icon.small`             |                            16 px | icono dentro de texto/control                                                       |
| `icon.medium`            |                            20 px | navegación y acciones                                                               |
| `icon.large`             |                            24 px | estado vacío o énfasis moderado                                                     |
| `form.max`               |                           720 px | formulario lineal                                                                   |
| `content.max`            |                          1440 px | contenido general                                                                   |
| `operations.max`         |                          1600 px | tabla/calendario operativo                                                          |

Una variante visual de 40 px solo es admisible en escritorio con puntero si su caja interactiva real sigue siendo al menos 44 × 44 px y no se reutiliza en superficies táctiles.

## Radio, borde y sombra

| Token            |                                  Valor | Uso                                        |
| ---------------- | -------------------------------------: | ------------------------------------------ |
| `radius.control` |                                   8 px | input, botón, badge                        |
| `radius.panel`   |                                  12 px | panel o drawer                             |
| `radius.round`   |                                 999 px | indicador corto/chip, no contenedor grande |
| `border.width`   |                                   1 px | borde excepcional                          |
| `shadow.float`   |    `0 8px 24px rgba(15, 23, 42, 0.12)` | menús, drawers y elementos flotantes       |
| `shadow.focus`   | 0 px de desplazamiento; anillo de 3 px | foco visible, no profundidad               |

No hay sombra en tarjetas ordinarias. No se usan sombras fuertes ni gradientes decorativos.

## Layout y breakpoints

| Token        | Rango objetivo | Composición                                        |
| ------------ | -------------- | -------------------------------------------------- |
| `bp.phone`   | 360–767 px     | una columna, navegación inferior, hojas completas  |
| `bp.tablet`  | 768–1023 px    | una columna amplia o panel auxiliar debajo; drawer |
| `bp.desktop` | 1024–1439 px   | barra lateral y dos zonas cuando aporten contexto  |
| `bp.wide`    | 1440–1919 px   | contenido 1440/operación 1600, densidad completa   |
| `bp.xwide`   | ≥1920 px       | contenido centrado; no estirar líneas/formularios  |

Otros tokens:

| Token                         |                  Valor inicial | Nota                                                                                                                |
| ----------------------------- | -----------------------------: | ------------------------------------------------------------------------------------------------------------------- |
| `layout.gutter.phone`         |                          16 px | conserva 328 px útiles a 360                                                                                        |
| `layout.gutter.tablet`        |                          24 px |                                                                                                                     |
| `layout.gutter.desktop`       |                          32 px |                                                                                                                     |
| `layout.sidebar.expanded`     |                         240 px | icono + etiqueta visible; `IconX` vuelve al modo slim con nombre accesible `Mostrar solo iconos del menú principal` |
| `layout.sidebar.slim`         |                          64 px | solo iconos; `IconMenu2` expande, nombre programático + tooltip hover/foco; activo no depende solo del color        |
| `layout.bottomNav`            |              64 px + safe area | contenido añade relleno inferior                                                                                    |
| `layout.header.phone`         |                          56 px | acciones 44 px                                                                                                      |
| `layout.header.desktop`       |                          64 px |                                                                                                                     |
| `layout.detailAside`          |                     320–360 px | solo ≥1024 px                                                                                                       |
| `layout.assistant.desktop`    |                     360–420 px | panel lateral redimensionable; el contenido conserva ancho utilizable                                               |
| `layout.assistant.mobile`     |  100 % del viewport disponible | hoja completa; respeta header, teclado y safe area                                                                  |
| `layout.liveContext.desktop`  |                     400–480 px | pilar principal de once alcances; filas admiten enlace primario + Inspeccionar                                      |
| `layout.liveContext.mobile`   |  100 % del viewport disponible | drawer/hoja con objeto, relación, cierre y retorno de foco                                                          |
| `layout.aiBar.project`        |                     320–380 px | se ubica inmediatamente a la derecha de Contexto vivo solo si las tres zonas caben                                  |
| `layout.ai.composerOrder`     |                        primero | barra de contexto → compositor → conversación/propuestas                                                            |
| `layout.contextAiFallback`    |               apilado o drawer | conserva orden DOM, objeto, relación, scroll, foco y borrador cuando no caben mínimos                               |
| `layout.mainWithContext.min`  |     `min(100%, 560px)` inicial | mínimo orientativo del contenido antes de activar el fallback; se valida por componente                             |
| `layout.activity.mobile`      |  100 % del viewport disponible | panel/drawer; título, cierre, foco contenido y retorno al disparador                                                |
| `layout.activity.composerMin` |             `min(100%, 360px)` | texto/comando, adjunto/propuesta inline y único Publicar reordenan sin overflow                                     |
| `layout.activity.timelineGap` |                          16 px | separación cronológica; no crea tarjetas anidadas                                                                   |
| `layout.aiProposal.compact`   | padding 12–16 px, borde 0–1 px | arriba de Situación interna y estado externo; superficie sutil, no Card dominante                                   |
| `layout.grid.minColumn`       |     `min(100%, 280px)` inicial | grid `auto-fit/minmax` o equivalente; nunca fuerza overflow                                                         |
| `layout.child.minInline`      |                              0 | todo hijo de flex/grid puede encogerse dentro de su contenedor                                                      |
| `text.wrap.long`              |           wrap agresivo seguro | IDs, rutas y texto externo usan `overflow-wrap:anywhere` o equivalente                                              |
| `badge.maxInline`             |           100 % del contenedor | badge/encabezado permite wrap y altura automática                                                                   |

El asistente, `Contexto` y `Actividad` conservan disparadores de 44 × 44 px. Contexto vivo es más ancho que un aside ordinario; el rail slim libera espacio sin forzar tres columnas. Comandos, adjunto integrado, enlaces, `Inspeccionar aquí` y el único `Publicar` conservan controles de 44 px.

Los breakpoints del viewport no bastan: `ExternalProcedures`, Contexto vivo, barra IA, paneles de estado y cualquier grid recalculan columnas por ancho de contenedor. La decisión paralelo/apilado/drawer usa la suma de mínimos útiles, no `bp.wide` por sí sola. `Estado oficial externo` con badge APT/SIRI es un caso de regresión obligatorio en 360/768/1024/1440 y zoom 200 %.

No se permite desplazamiento horizontal general. `Trabajo n de N`, enlaces, rutas OneDrive, propuesta inline, errores y comandos usan wrap. Contexto ancho + IA activan fallback antes de comprimir la sección; slim no es una excusa para violar mínimos.

## Foco, estados y accesibilidad

| Token              | Regla                                                      |
| ------------------ | ---------------------------------------------------------- |
| `focus.width`      | 3 px                                                       |
| `focus.offset`     | 2 px; 0 cuando el borde quedaría recortado                 |
| `focus.color`      | `accent.focus` validado o fallback institucional accesible |
| `disabled.opacity` | no inferior a 0.65; texto y causa deben seguir legibles    |
| `selected.marker`  | fondo sutil + borde/marcador + texto, nunca solo color     |
| `error.marker`     | texto + icono + asociación `aria-describedby` futura       |
| `required.marker`  | texto `Obligatorio` o leyenda comprensible                 |

El foco no se oculta bajo encabezados/barras fijas. Los estados deshabilitados explican la causa cuando es útil (`Sin conexión`, `Requiere aprobación`, `Solo Plano de catastro`). Un control sin permiso se omite; si su ausencia impediría comprender el proceso, se muestra texto de alcance sin fingir que el cliente es la barrera de seguridad.

## Movimiento

| Token           |                Valor | Uso                      |
| --------------- | -------------------: | ------------------------ |
| `motion.fast`   |               100 ms | respuesta de control     |
| `motion.normal` |               180 ms | expansión/selección      |
| `motion.slow`   |               240 ms | drawer o cambio de vista |
| `motion.easing` | `ease-out` funcional | entrada/salida           |

Con `prefers-reduced-motion`, las transiciones se reducen a cambio inmediato o fundido mínimo. Ninguna animación comunica por sí sola un cambio de estado.

## Capas

Orden conceptual, sin fijar valores de implementación:

1. contenido;
2. encabezado/navegación persistente;
3. menú o popover;
4. drawer/modal;
5. aviso urgente del sistema.

Tooltips no cubren controles y nunca contienen la única explicación de una acción.

## Iconografía y datos visuales

- Tabler Icons con trazo coherente y etiqueta accesible.
- Iconos de estado se acompañan de texto.
- APT, SIRI e IA tienen rótulo textual; no se inventan logotipos.
- Gráficos 2D usan una paleta que conserva contraste y patrones/etiquetas cuando se comparan series.
- Todo gráfico tiene título, periodo, fecha de corte, unidades y alternativa tabular.

## Validación antes de centralizar

Comprobación estática de los valores candidatos el 2026-07-23: **52/52 pares aprobaron**, con relación mínima **4.74:1**. Incluyó texto base, seis sólidos con texto blanco, texto/foco de cada acento por tema y ocho familias semánticas en Claro/Oscuro. Esto valida los pares declarados, no sustituye la prueba del componente renderizado, estados derivados ni navegador.

1. comprobar en Claro y Oscuro pares de contraste normales (4.5:1), texto grande cuando aplique (3:1) y componentes/foco (3:1);
2. probar `Sistema` sin elección, cambio del sistema y prevalencia/sincronización de una elección explícita;
3. probar institucional y cada acento predefinido sobre canvas, superficie, selección y foco de ambos temas;
4. probar un personalizado aceptado y uno rechazado por fallar al menos uno de los temas;
5. probar error, advertencia, éxito, IA, APT y SIRI con todos los acentos y ambos temas;
6. verificar reflujo 360/768/1024/1440 y zoom 200 % en Claro/Oscuro;
7. comprobar que cambiar tema no pierde foco/contexto, no cambia semántica ni introduce scroll horizontal;
8. comprobar que ninguna superficie grande, header o navegación usa el acento como fondo dominante.
9. comprobar que el asistente DEC-0107 no cubre navegación/foco, que `/` y `Comandos` son equivalentes y que la identidad IA conserva contraste en ambos temas.
10. comprobar `Estado oficial externo` y todos los grids con títulos/badges/texto largo: auto-fit/minmax o equivalente, wrap y cero overflow horizontal por viewport o contenedor a 200 %.
11. comprobar DEC-0108 sin pestañas/dropzone/Crear documento: texto vs `/`, adjunto/propuesta inline, un solo Publicar y error sin referencia disponible.
12. comprobar las cadenas exactas `--font-ui: "Inter", "Segoe UI", sans-serif;` y `--font-data: "Roboto Mono", Consolas, monospace;`, incluidos fallbacks, zoom y ausencia de cambio de layout bloqueante.
13. comprobar DEC-0109 en once alcances incluido Trabajos: enlace/primaria navega e Inspeccionar conserva relación bidireccional in situ.
14. comprobar sidebar 240/64, Contexto vivo 400–480, sección → contexto → IA y fallback a 360/768/1024/1440 y zoom 200 %.
15. comprobar compositor IA arriba, conversación debajo, y propuesta IA compacta arriba de Situación interna/Estado oficial sin borde pesado.
