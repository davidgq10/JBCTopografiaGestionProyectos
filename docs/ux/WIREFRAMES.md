# Wireframes textuales

Estado: **propuesta de Fase 1 para checkpoint de usuario**  
Datos: todos los nombres, códigos y cifras siguientes son ficticios.  
Nota: los marcos ASCII indican regiones de layout, no tarjetas ni bordes visuales obligatorios.

Tipografía obligatoria en todos los wireframes: `--font-ui: "Inter", "Segoe UI", sans-serif;` y `--font-data: "Roboto Mono", Consolas, monospace;` para comandos, códigos, rutas, IDs y UTC.

## Leyenda

- `[* Acción]`: acción primaria de la zona.
- `[Acción]`: acción secundaria.
- `⋯`: menú explícito, visible y enfocable.
- `!`: estado que requiere atención, acompañado por texto.
- `○/●`: selección; siempre tiene etiqueta.
- `↕`: reordenamiento con botones/selector, no arrastre obligatorio.
- `CR`: hora presentada en `America/Costa_Rica`.

## W00 — Shell responsive

### 360 px

```text
┌──────────────────────────────────────┐
│ JBC            [Buscar] [IA] [Avisos]│ 56 px
├──────────────────────────────────────┤
│ ! Sin conexión · Los cambios están   │ estado global opcional
│   deshabilitados                     │
├──────────────────────────────────────┤
│                                      │
│  h1 Título de página                 │
│  contexto / fecha de corte           │
│                                      │
│  [* Acción primaria]                 │
│                                      │
│  Sección 1                           │
│  contenido apilado                   │
│                                      │
│  Sección 2                           │
│  contenido apilado                   │
│                                      │
│  relleno para barra + safe area      │
├──────────────────────────────────────┤
│ Inicio Proyectos Trabajo Agenda Más  │ 64 px + safe area
└──────────────────────────────────────┘
```

Reglas: gutter 16 px, una columna, objetivos 44 px, el contenido no pasa por debajo de la navegación y no hay scroll horizontal general. El mismo shell usa superficies grises neutrales en Claro y Oscuro; `Sistema` es inicial sin elección y el acento no rellena header/canvas/sidebar.

### 768 px

```text
┌──────────────────────────────────────────────────────────────┐
│ [Menú] JBC        [Buscar________________] [Avisos] [Cuenta] │
├──────────────────────────────────────────────────────────────┤
│ h1 Título                                      [* Primaria] │
│ contexto / corte                                             │
│                                                              │
│ Contenido principal en una columna amplia                    │
│                                                              │
│ Panel auxiliar debajo del contenido                          │
└──────────────────────────────────────────────────────────────┘
```

El menú abre Drawer. En orientación vertical, agenda y comparativos siguen apilados.

### 1024 px

```text
┌──────────────┬─────────────────────────────────────────────────────────┐
│ JBC          │ [Buscar____________________] [Avisos] [Cuenta]          │
│ Inicio       ├─────────────────────────────────────────────────────────┤
│ Proyectos    │ Inicio > Objeto                                        │
│ Trabajo      │ h1 Título                               [* Primaria]   │
│ Agenda       │ contexto                                                │
│ OneDrive     │                                                         │
│ Aprobaciones │ Principal (flujo DOM primero)      Contexto 320 px      │
│ Notificaciones│                                                        │
│ Reportes     │ Secciones separadas por ≥24 px                          │
│               │                                                        │
│ ⚙ Configuración│                                                        │
└──────────────┴─────────────────────────────────────────────────────────┘
```

### 1440 px

```text
┌────────────────┬────────────────────────────────────────────────────────────────────┐
│ Navegación     │ header global: búsqueda · avisos · cuenta                         │
│ 240 px         ├────────────────────────────────────────────────────────────────────┤
│ Inicio         │ breadcrumb                                                         │
│ Proyectos      │ h1 Título + estado                         [* Acción primaria]      │
│ Trabajo        │ contexto / corte / actualización                                   │
│ Agenda         │                                                                    │
│ OneDrive       │ contenido hasta 1440 px; operación hasta 1600 px, centrado         │
│ Aprobaciones   │                                                                    │
│ Notificaciones │ tabla sin borde exterior  |  detalle auxiliar solo si aporta       │
│ Reportes       │                                                                    │
│                │                                                                    │
│ ⚙ Configuración│                                                                    │
└────────────────┴────────────────────────────────────────────────────────────────────┘
```

El ancho adicional no alarga formularios más allá de 720 px ni crea más columnas decorativas.

## W00B — Cambio a espacio inmersivo de proyecto

### 360 px

```text
┌──────────────────────────────────────┐
│ ← Todos los proyectos          [Avisos]│
│ [Contexto] [Actividad] [IA]            │
├──────────────────────────────────────┤
│ Proyecto JBC-2026-001 · Contrato     │ contexto contractual
│ Levantamiento catastral Finca Ficticia│
│ Trabajo 2 de 4 [Cambiar trabajo v]   │
│ PL-02 · Plano de catastro · CAT-03   │
│ Situación interna: Revisión interna  │
├──────────────────────────────────────┤
│ h1 Sección actual                    │
│ [* Acción primaria de esta sección]  │
│                                      │
│ contenido relacionado solo con       │
│ PL-02; el agregado sigue en Resumen  │
│                                      │
│ [Volver a Trabajo/Agenda/etc.]       │ si entró desde vista transversal
├──────────────────────────────────────┤
│ Resumen Trabajos Trabajo Agenda Más  │ barra local
└──────────────────────────────────────┘
```

`Contexto` abre el inspector relacional; `Actividad` abre su alcance directamente. Si por densidad un control visual usa solo icono, conserva el nombre accesible `Abrir contexto del proyecto` o `Abrir actividad del proyecto`; ninguno desaparece a 360 px. El Proyecto representa la contratación y contiene `1..N` Trabajos independientes.

`Más del proyecto` abre una página/hoja completa:

```text
JBC-2026-001              h1 Más del proyecto
> Trabajos (4)
> Cliente, inmuebles y participantes
> Gestiones del Trabajo PL-02
> Tareas, listas y dependencias de PL-02
> Programación y recursos de PL-02
> Trámites APT/SIRI de PL-02  (solo Plano de catastro)
> Documentos OneDrive de PL-02
> Aprobaciones
> Notificaciones
> Asistente IA
> Reportes y entregables
> Historial y auditoría

> Navegación general
> Todos los proyectos
```

Para un Trabajo no catastral, la fila Trámites no existe. Si ese Trabajo anteriormente fue Plano de catastro, `Historial y auditoría` contiene `Historia APT/SIRI inactiva`; no se agrega una fila activa de Trámites ni se altera otro Trabajo.

### 1024 px o contenedor insuficiente

```text
┌────────────────────┬───────────────────────────────┬────────────────────────┐
│ ← Navegación gral. │ [Buscar] [Contexto] [IA]      │ Contexto vivo          │
│ ← Todos proyectos  ├───────────────────────────────┤ Trabajo PL-02          │
│ Contrato ficticio  │ Proyecto JBC-2026-001         │ Alcance: Actividad     │
│                    │ Trabajo 2/4 · Plano catastro  │ cronología/relaciones  │
│ Resumen            │ h1 Sección actual [* Acción] │ pilar ancho 400–480 px │
│ Trabajos           │                               │                        │
│ Datos              │ contenido inmersivo          │ [Escribe o usa /…    ] │
│ Gestiones          │ recalcula por su contenedor  │ [Adjuntar] [Comandos]  │
│ Tareas             │ y conserva min-inline-size:0 │ [* Publicar]           │
│ Programación       │                               │                        │
│ Trámites*          │ * solo Trabajo catastro      │ IA usa fallback        │
│ Documentos         │                               │ apilado/Drawer         │
│ Historial          │                               │                        │
└────────────────────┴───────────────────────────────┴────────────────────────┘

IA abierta: se apila bajo Contexto vivo o usa Drawer accesible.
El encabezado conserva proyecto + objeto + relación y vuelve al mismo foco.
```

### 1440+ cuando caben los mínimos del contenedor

```text
┌────────────┬─────────────────────┬──────────────────────┬──────────────────┐
│ navegación │ sección activa      │ Contexto vivo        │ IA               │
│ 240/64 px  │ h1 + acción         │ 400–480 px           │ contexto visible │
│ expandible │ contenido refluido  │ 11 alcances          │ [Compositor____] │
│ o iconos   │ sin mínimo ilegible │ objeto/relación      │ [Comandos][Enviar]│
│            │                     │ [Abrir vista normal] │ conversación     │
│            │                     │ [Inspeccionar aquí]  │ propuestas       │
└────────────┴─────────────────────┴──────────────────────┴──────────────────┘
```

La barra lateral cambia de índice, no crea copias, y puede compactarse de 240 a 64 px. En modo iconos cada destino conserva nombre accesible, tooltip, foco y marcador activo. DEC-0109 exige el orden `sección → Contexto vivo → IA`; si esa composición no cabe —también a 1440 o zoom 200 %— se usa el fallback anterior antes de comprimir o desbordar. Volver a la capa general restaura filtros/posición conservados durante la sesión.

## W01 — Inicio orientado a acciones, 360 px

```text
JBC                    [Buscar] [IA] [3 avisos]

h1 Buenos días
jueves 23 jul 2026 · 08:10 CR

Requiere tu atención
! 2 tareas vencidas
  La más antigua venció 21 jul
  [Ver tareas]

! 1 aprobación por revisar
  vence 23 jul, 16:00 CR
  [Ver aprobación]

Agenda próxima
08:30–10:30  Levantamiento lote norte
Persona: Técnica Uno · Recurso: GNSS-02
[Ver agenda]

Trabajo en curso
Proyecto JBC-2026-001 · Trabajo PL-02
Plano de catastro · Situación interna: Revisión
Próximo seguimiento: 24 jul
[Abrir trabajo] [Ver proyecto]

Inicio | Proyectos | Trabajo | Agenda | Más
```

No hay cuadrícula de KPIs. Para un usuario sin APT/SIRI autorizado, no aparece la sección de cambios externos. En escritorio, estas listas se distribuyen en una zona principal y un panel de agenda, sin convertir cada fila en tarjeta.

## W02 — Más, 360 px

```text
< Atrás                      h1 Más

Trabajo y archivos
> Clientes
> OneDrive

Decisiones
> Aprobaciones                  (si está autorizado)
> Notificaciones

Análisis
> Control General
> Reportes
> Asistente IA

Sistema
> Salud                         (si está autorizado)
> Auditoría                     (si está autorizado)
> Configuración                 (si está autorizado)

Cuenta
> Tema y acento
> Notificaciones y dispositivos

Entorno: Pruebas · Versión 1.0.0
```

Los grupos o destinos sin permiso no se muestran. El servidor sigue revalidando cualquier URL directa.

## W03 — Crear Proyecto contractual y primer Trabajo, 360 px

### Paso 2: contratación

```text
< Proyectos              Paso 2 de 7
h1 Datos del proyecto
Nombre del contrato      [________________]
Cliente                  [Seleccionar____v]
Prioridad contractual    [Normal_________v]

[Atrás]                  [* Continuar]
```

### Paso 3: primer Trabajo obligatorio

```text
< Atrás                  Paso 3 de 7
h1 Configurar primer trabajo
Nombre                    [Plano lote A___]
Tipo del Trabajo

○ Delimitación
○ Curvas de nivel
○ Avalúo
○ Croquis
● Plano de catastro
  Incluye monitoreo APT/SIRI de solo lectura.

Versión de configuración: CAT-03
[Atrás]                  [* Continuar]
```

Si se selecciona cualquiera de los primeros cuatro tipos, no aparece ninguna mención, campo o paso APT/SIRI.

### Paso 6: campos del Trabajo, opción no catastral

```text
< Atrás                  Paso 6 de 7
h1 Datos del Trabajo de Avalúo

Finalidad                   [____________]
Fecha de referencia         [23/07/2026]
Moneda                      [CRC       v]
...campos autorizados por AVA-02...

[Atrás]                  [* Continuar]
```

No existe hueco, pestaña deshabilitada ni texto APT/SIRI.

### Paso 7: vista previa

```text
< Atrás                  Paso 7 de 7
h1 Revisar proyecto

Cliente
Cliente Ficticio Uno

Proyecto
Nombre             Contrato catastral ficticio
Prioridad          Normal

Trabajo 1 de 1
Nombre             Plano lote A
Tipo               Plano de catastro
Configuración      CAT-03
Responsable        Técnica Uno

Inmuebles (2)     [Mostrar detalles]
Fechas            inicio 24 jul · estima 31 ago

OneDrive
Preparar estructura estándar al confirmar

Monitoreo externo
APT/SIRI: solo consulta; aún sin fotografía

[Atrás]       [* Crear proyecto y trabajo]
```

La barra de acciones fija deja espacio inferior y no cubre el último campo. Al confirmar nace un Proyecto con `1..N` Trabajos —inicialmente uno— y luego aparece `Nuevo trabajo`. A 1024/1440 px, el formulario sigue en 640–720 px y la vista previa ocupa un panel auxiliar; no se añaden pasos.

## W04 — Trabajo no catastral dentro de un Proyecto, 360 px

```text
← Todos los proyectos     [Avisos] [⋯]
Proyecto JBC-2026-014 · Contrato La Loma
Trabajo 1 de 3 [Cambiar trabajo v]
h1 Curvas de nivel · Sector norte
Tipo: Curvas de nivel · Configuración CNI-02
Situación interna: En ejecución
Responsable: Técnica Dos

[* Nueva gestión]

[Resumen del trabajo] [Ver los 3 trabajos]

Requiere atención
! Falta confirmar acceso al inmueble

Próximo trabajo
25 jul, 07:00–11:00 CR · Campo
[Ver agenda]

Secciones disponibles
Datos (cliente/inmuebles/participantes)
Gestiones · Tareas/listas/dependencias
Programación/recursos · Documentos OneDrive
Aprobaciones · Notificaciones · Asistente IA
Reportes/entregables · Historial/auditoría

Resumen | Trabajos | Trabajo | Agenda | Más
```

Prueba visual de exclusión: para este Trabajo no existen Trámites, APT, SIRI, estado externo ni `Consultar ahora`; otro Trabajo del mismo Proyecto puede ser catastral sin mezclar estados.

## W05 — Trabajo de Plano de catastro, separación IA/interno/externo

### 360 px

```text
← Todos los proyectos     [Avisos] [⋯]
Proyecto JBC-2026-001 · Contrato catastral
Trabajo 2 de 4 [Cambiar trabajo v]
h1 PL-02 · Plano lote B
Tipo: Plano de catastro · CAT-03

─ Propuesta IA ─────────────────────────
Revisar cabida antes de enviar · Conf. 0,72
Evidencia 3 · corte 23 jul, 10:00 CR
[Ver evidencia] [Usar como borrador]

Situación interna
Revisión interna
Responsable: Técnica Uno · vence 24 jul
[Cambiar estado]

Estado oficial externo · solo lectura

APT
Requiere atención
Texto original disponible
Corte: 23 jul, 07:04 CR · fresco
[Ver trámite] [Consultar ahora]

SIRI
Sin consultar
Próximo ciclo: 23 jul, 13:00 CR
[Ver trámite]

Historial del Trabajo PL-02
[Ver historial]

Resumen | Trabajos | Trabajo | Agenda | Más
```

La propuesta IA compacta tiene borde de 0–1 px y siempre precede a `Situación interna`, que a su vez precede a `Estado oficial externo`. Ninguna de las tres zonas se fusiona. `Consultar ahora` tiene ayuda de límite de frecuencia y nunca cambia datos externos.

Regresión de contenedor estrecho/zoom 200 %:

```text
Estado oficial externo
APT
Requiere atención
Texto original largo que envuelve dentro
del panel sin ampliar su ancho.
Corte: 23 jul, 07:04 CR
```

El encabezado y el badge APT pasan de línea; el grid APT/SIRI usa `auto-fit/minmax` o equivalente y queda en una columna. No hay overflow, recorte ni desplazamiento horizontal local/general a 360/768/1024/1440.

### 1440 px

```text
Proyecto JBC-2026-001 · Trabajo PL-02/4 · Plano catastro     [* Nueva gestión]
[Propuesta IA compacta · evidencia/confianza/corte]
Situación interna: Revisión interna · responsable · vencimiento

Resumen | Datos | Gestiones | Tareas | Programación | Trámites | Documentos
Aprobaciones | Notificaciones | Asistente | Entregables | Historial

Estado oficial externo · solo lectura                Última actualización 07:04 CR

APT                                                  SIRI
Requiere atención                                    Sin consultar
Texto oficial + clasificación separadas              Corte / próxima consulta
Última consulta exitosa / actualización               Historia independiente
[Ver trámite] [Consultar ahora]                      [Ver trámite]
```

Las dos columnas son secciones hermanas, no tarjetas anidadas.

## W06 — Historial de un Trabajo tras cambiar fuera de catastro, 360 px

```text
< Trabajo PL-02             h1 Historial
[Filtrar]

23 jul 2026, 15:10 CR
Cambio de tipo ejecutado
Usuario: Coordinación Ficticia
UTC: 2026-07-23T21:10:00Z
Anterior: Plano de catastro · Revisión interna
Nuevo: Delimitación
Aprobación: APR-FIC-018 · Ejecutada

Historia externa · Histórico inactivo
APT · último evento 22 jul, 19:08 CR
SIRI · último evento 20 jul, 13:03 CR
El monitoreo está desactivado para el tipo actual.
[Ver eventos históricos]

No hay acción Consultar ahora.
```

El Trabajo actual no tiene sección Trámites. Estos datos solo aparecen dentro de su Historial; el agregado contractual y los otros Trabajos permanecen intactos.

## W07 — Gestión y tarea, 360 px

Vista general/transversal:

```text
Trabajo                         [Filtrar]
h1 Trabajo
[Gestiones] [Tareas]

! Coordinar visita de campo
Proyecto: JBC-2026-014 · seguimiento 24 jul
[Abrir gestión] [Ver proyecto completo]

! Preparar equipo de campo
Proyecto: JBC-2026-014 · vence 24 jul
[Abrir tarea] [Ver proyecto completo]

Inicio | Proyectos | Trabajo | Agenda | Más
```

Al activar `Ver proyecto completo`, la misma entidad se abre en la capa inmersiva y la barra local resalta Gestiones o Tareas. Volver a Trabajo restaura filtros y posición.

Detalle dentro del proyecto:

```text
← Trabajo     JBC-2026-014   [Avisos] [⋯]
h1 Coordinar visita de campo
Proyecto: JBC-2026-014 · Trabajo CN-01
Estado: En espera
Motivo: Acceso al inmueble
Responsable externo: Cliente
Seguimiento: 24 jul 2026
[Reanudar] [Cambiar estado]

Notas
23 jul, 09:20 · Técnica Dos
Se solicitó confirmación…
[Ver versión anterior]
[Añadir nota]

Tareas
! Confirmar acceso · vence hoy
  Bloqueada por respuesta del cliente
  [Ver tarea]
[* Nueva tarea]

Resumen | Trabajos | Trabajo | Agenda | Más
```

Detalle de tarea:

```text
← Trabajo     JBC-2026-014   [Avisos] [⋯]
h1 Preparar equipo de campo
Trabajo: CN-01 · Curvas de nivel
Prioridad: Alta · Vence: 24 jul
Estado: En ejecución · Avance 40 %

Lista
[x] Verificar baterías
[ ] Reservar GNSS-02          [Subir] [Bajar]
[ ] Preparar libreta          [Subir] [Bajar]
[Añadir elemento]

Dependencias
Después de: Confirmar acceso
[Añadir dependencia]

Programación
25 jul, 07:00–08:00 CR
[Programar otro bloque]

[* Guardar cambios]

Resumen | Trabajos | Trabajo | Agenda | Más
```

No hay drag obligatorio. A ≥1024 px, lista y contexto pueden verse en dos zonas, pero el orden de lectura permanece.

## W08 — Agenda con conflicto, 360 px

```text
Agenda                    [Calendario opcional]
h1 Jueves 23 de julio
[Filtrar]                      [* Programar]

07:00–09:00  Campo · JBC-2026-014
Técnica Dos · GNSS-02
[Ver bloque]

09:00–11:00  Oficina · JBC-2026-001
Técnica Uno
[Ver bloque]

--------------------------------------
Programar bloque
Tarea            [Preparar equipo   v]
Inicio           [23/07] [08:30]
Fin              [23/07] [10:30]
Persona          [Técnica Dos       v]
Recurso          [GNSS-02           v]

! Conflicto de reserva
  Técnica Dos y GNSS-02 están ocupados
  de 07:00 a 09:00.
  [Usar 11:00–13:00]
  [Cambiar persona/recurso]

[Cancelar]             [* Revisar bloque]
```

La fecha límite de la tarea aparece como dato aparte, nunca como evento de calendario. En 1024/1440 px, FullCalendar comparte espacio con AgendaList; todas las acciones siguen disponibles por campos y botones.

## W09 — OneDrive móvil

### Vista general/transversal

```text
OneDrive                         [Filtrar]
h1 Archivos y carpetas
Última sincronización general: 08:02 CR

Proyecto · JBC-2026-014
03-DATOS DEL LEVANTAMIENTO · 8 elementos
[Abrir en proyecto]

Cliente · Cliente Ficticio Uno
Correspondencia · 3 elementos
[Abrir en cliente]

Inicio | Proyectos | Trabajo | Agenda | Más
```

La vista general cruza referencias autorizadas, pero una operación abre primero el cliente/proyecto propietario. No existe una carpeta global alternativa ni copia de binarios.

### Vista inmersiva del proyecto

```text
← OneDrive   JBC-2026-014       [Avisos]
h1 Documentos
OneDrive · última sincronización 08:02 CR
Ruta: Proyecto / Trabajo CN-01 / 03-DATOS DEL LEVANTAMIENTO

[← Carpeta superior]       [Adjuntar archivo]

> CAMPO
> FOTOGRAFÍAS
  puntos.csv                 ⋯
  libreta.pdf                ⋯

Acciones de libreta.pdf
> Abrir en OneDrive
> Mover
> Renombrar
> Archivar en 99-ARCHIVADOS
> Ver historial

Resumen | Trabajos | Trabajo | Agenda | Más
```

No existe Eliminar, dropzone separado ni `Crear documento`. `Adjuntar archivo` lleva el foco a Actividad y abre el mismo compositor unificado:

```text
Actividad · Proyecto JBC-2026-014 · Trabajo CN-01
[Anotación opcional___________________]
[Arrastra aquí o Adjuntar archivo]

foto-campo-01.jpg · detectado, aún no cargado
Tipo              [Fotografía de campo_v]
Relación          [Gestión Visita______v]
Carpeta OneDrive  [CN-01/FOTOGRAFÍAS___v]

[Quitar] [Comandos]          [* Publicar]
```

`Publicar` es la única confirmación humana. Primero almacena el binario en OneDrive y solo después Supabase guarda metadatos, `driveId`/`driveItemId` y relación.

Carpeta vacía excepcional:

```text
Solicitar envío a papelera de OneDrive
Carpeta: TEMP-VACÍA · verificada vacía a 10:31 CR
Motivo [________________________________]
Requiere doble control y nueva verificación al ejecutar.
[Cancelar]          [* Solicitar aprobación]
```

Para carpeta no vacía/protegida, esta acción no aparece y se explica `Archivar` o la protección aplicable.

## W10 — Aprobación y conflicto de versión

La solicitud puede abrirse desde la bandeja general o desde `Más del proyecto → Aprobaciones`. En ambos casos es la misma solicitud; el encabezado conserva el origen:

```text
← Aprobaciones generales    o    ← JBC-2026-001
Proyecto: JBC-2026-001            [Ver proyecto completo]
```

### Comparativo móvil

```text
< Aprobaciones
h1 Cambiar tipo de trabajo
Pendiente · vence 24 jul, 16:00 CR

Solicitante: Coordinación Ficticia
Proyecto: JBC-2026-001 · Trabajo PL-02
Motivo: cambio de alcance documentado

Diferencia 1 de 4
ACTUAL
Tipo: Plano de catastro · CAT-03

PROPUESTO
Tipo: Delimitación · DEL-02

[Anterior diferencia] [Siguiente diferencia]

Impacto
APT/SIRI de PL-02 pasará a historia inactiva.
No se eliminarán eventos anteriores.
Los otros Trabajos no cambiarán.

Evidencia [2 elementos]
Comentario [________________________]

[Rechazar]                   [* Aprobar]
```

Después de aprobar:

```text
Aprobada · pendiente de ejecución
La aprobación no modificó aún el Trabajo PL-02.
[Ver historial]
```

Si la versión cambia:

```text
! Solicitud desactualizada
La versión aprobada era 7; el Trabajo PL-02 está en versión 8.
[Comparar cambios] [Crear solicitud sustituta]
No existe acción Ejecutar.
```

En escritorio, Actual y Propuesto forman dos columnas alineadas; no se usa color como único indicador.

## W11 — Centro de notificaciones y horario

```text
Notificaciones                    [Filtrar]
h1 Avisos
Entrega 07:00–20:00 · Silencio 20:00–07:00
Hora de Costa Rica

No leído · Alta · Aprobaciones
Solicitud vence hoy a las 16:00
[Abrir]

No leído · Atención · Tareas
Tarea vencida el 22 jul
[Abrir]

Registrado 22:14 · Programado para 07:00
OneDrive · sincronización recuperada
[Ver detalle]

[Marcar visibles como leídas]
```

Si Push está denegado, un aviso local explica `Los avisos de Windows están desactivados; el centro interno sigue funcionando`, sin bloquear la pantalla.

Dentro del proyecto, la misma fuente se filtra sin duplicarse:

```text
← Avisos generales      JBC-2026-001
h1 Notificaciones del proyecto
Entrega 07:00–20:00 · Silencio 20:00–07:00 CR

Alta · Aprobación APR-FIC-018
[Abrir]

Atención · Cambio APT observado · Trabajo PL-02
[Abrir trámite]                  solo Trabajo catastro

[Ver todos los avisos]
Resumen | Trabajos | Trabajo | Agenda | Más
```

En un Trabajo no catastral no aparece la categoría/cambio APT/SIRI; la historia inactiva de ese Trabajo no genera consultas nuevas.

## W12 — Asistente IA transversal (`DEC-0107`)

### Acceso persistente y hoja móvil

El botón `[IA]` del AppShell está disponible en Inicio, vistas generales y dentro del proyecto. Al abrirlo a 360 px:

```text
┌──────────────────────────────────────┐
│ [×]             h1 Asistente IA      │
│ Contexto: General · alcance autorizado│
│ [Cambiar contexto]                   │
├──────────────────────────────────────┤
│ [Pregunta o comando_______________]  │
│ [Comandos]                   [Enviar]│
├──────────────────────────────────────┤
│ Conversación y propuestas            │
│ ¿Qué requiere atención hoy?          │
│                                      │
│ Resumen de IA                        │
│ Corte: 23 jul, 10:00 CR              │
│ Confianza: Media (0,72)              │
│ Evidencia (3) [Ver fuentes]          │
└──────────────────────────────────────┘
```

La hoja ocupa el viewport disponible y respeta teclado/safe area. El compositor es la primera zona interactiva y la conversación/propuestas se leen debajo. Cerrar devuelve foco a `[IA]`; la navegación inferior no queda tapada en el estado cerrado.

### Paleta `/` con alternativa táctil

Escribir `/` en el compositor, o pulsar `/` fuera de otro campo editable, abre:

```text
Comandos
> /tarea       Preparar borrador de tarea
> /agenda      Preparar bloque de ejecución
> /gestion     Preparar gestión y seguimiento
> /buscar      Buscar en tu alcance (solo lectura)
> /resumen     Resumir contexto (solo lectura)

[×]  (nombre accesible: Cerrar comandos)
```

`[Comandos]` abre la misma lista por tacto/teclado. El atajo no intercepta `/` escrito dentro de otro input de la página.

### Contexto heredado dentro del proyecto

```text
[×]                      h1 Asistente IA
Contexto: Proyecto JBC-2026-014
Trabajo CN-01 · Curvas de nivel
Situación interna: En ejecución
[Cambiar contexto autorizado]

[Pregunta o comando____________________]
[Comandos]                      [Enviar]

Conversación y propuestas
> /tarea Preparar visita con base en la gestión actual
```

Al navegar a otro proyecto con el panel abierto, aparece `Actualizando contexto…`; no responde ni confirma hasta revalidar permiso y anunciar el nuevo proyecto.

### Borrador estructurado; nunca escritura directa

```text
Borrador de IA · Tarea
Fecha de corte: 23 jul, 10:00 CR
Confianza: Media (0,72)

Título          [Preparar visita de campo_____]
Proyecto        JBC-2026-014
Gestión         Coordinar visita de campo
Responsable     [Técnica Dos_______________v]
Vence           [24/07/2026]
Prioridad       [Alta______________________v]

Evidencia (3)
> Gestión “Coordinar visita” · versión 4
> Comentario del 23 jul · versión 2
> Agenda · corte 10:00 CR

[Descartar]               [* Revisar borrador]
```

Después de revisar:

```text
Revisar creación de tarea
Actual / propuesto / validaciones / conflictos

[Volver a editar]          [* Confirmar creación]
```

Solo `Confirmar creación` envía un comando atribuido al usuario por el flujo normal de servidor. Si la acción requiere aprobación:

```text
Solicitud de aprobación preparada
La IA no ejecutará la acción.
[Revisar solicitud]        [* Enviar a aprobación]
```

Doble control y permisos no cambian por haberse originado en IA.

### Panel lateral, 1024/1440 px

```text
┌───────────────────────────────────────────────┬──────────────────────────────┐
│ vista general; o sección activa del proyecto │ IA · 380 px                  │
│                                               │ Contexto visible             │
│ contenido, alertas y acción primaria          │ [Compositor____________]     │
│ siguen visibles y operables                   │ [Comandos] [Enviar]          │
│                                               │ conversación/propuestas      │
└───────────────────────────────────────────────┴──────────────────────────────┘
```

El panel ajusta el área de contenido; no flota encima de controles. En vistas generales ocupa el lateral mostrado. Dentro de un proyecto, DEC-0109 conserva Contexto vivo y abre `ProjectAiBar` inmediatamente a su derecha cuando caben los mínimos; en caso contrario la IA se apila o pasa a Drawer accesible, nunca se superpone.

Al abrirlo, cualquier grid del contenido principal recalcula columnas por el ancho restante. `Estado oficial externo`, badges APT/SIRI, títulos y rutas largas envuelven; no conservan columnas basadas únicamente en el viewport.

### Centro IA general/del proyecto

```text
h1 Centro IA                         [Filtrar]
Historial | Propuestas | Evidencia | Configuración autorizada

23 jul · /tarea · Borrador confirmado por Técnica Dos
Proyecto JBC-2026-014 · evidencia 3 · corte 10:00
[Ver ejecución]

22 jul · /resumen · Solo lectura
[Ver evidencia]
```

El centro no es requisito para abrir el asistente. La persistencia visual durante la sesión no cambia Responses API `store:false`. Si una fuente cambió antes de confirmar:

```text
! La evidencia cambió desde esta propuesta
[Ver diferencias] [Regenerar] [Descartar]
Confirmar está deshabilitado.
```

## W12B — Actividad unificada de Proyecto (`DEC-0108`)

### Actividad dentro del Contexto vivo en escritorio

Actividad acompaña cualquier sección del Proyecto y su Trabajo seleccionado. No sustituye Gestiones, Tareas, Programación, Documentos, Historial ni el Centro IA.

```text
┌────────────────────────────────────┬──────────────────────────────────────┐
│ h1 Gestiones       [* Nueva gestión]│ Contexto vivo · 400–480 px [Abrir IA]│
│ Proyecto JBC-2026-014              │ Trabajo CN-01 · Alcance Actividad   │
│ Trabajo CN-01 · Curvas de nivel    ├──────────────────────────────────────┤
│                                    │ 10:08 · Técnica Dos · Anotación     │
│ contenido de la sección activa     │ “Visita confirmada…”                │
│                                    │ [Abrir gestión] [Inspeccionar aquí] │
│ el grid responde al contenedor     │                                      │
│ sin overflow a 1024/1440/zoom      │ 09:40 · Coordinación · Tarea creada │
│                                    │ [Abrir tarea] [Inspeccionar aquí]   │
│                                    ├──────────────────────────────────────┤
│                                    │ [Escribe una anotación o /comando_]│
│                                    │ [Adjuntar] [Comandos] [* Publicar] │
└────────────────────────────────────┴──────────────────────────────────────┘
```

No hay pestañas de modo. Sin `/`, `Publicar` crea una anotación del usuario en el Proyecto; con `/`, el compositor adopta el tipo seleccionado. Cada nombre o acción primaria abre la vista operativa normal y `Inspeccionar aquí` conserva la revisión in situ. Al abrir IA con ancho seguro aparece a la derecha; si no cabe, se apila o usa Drawer sin borrar texto, objeto ni posición.

### Panel móvil/tableta accesible

```text
┌──────────────────────────────────────┐
│ [×]      h1 Actividad del proyecto   │
│ JBC-2026-014 · Trabajo CN-01         │
├──────────────────────────────────────┤
│ [Escribe una anotación o /comando_] │
│ [Adjuntar] [Comandos]                │
│                         [* Publicar] │
├──────────────────────────────────────┤
│ 10:08 CR · Técnica Dos · Anotación   │
│ Visita confirmada para mañana.       │
│ [Abrir gestión] [Inspeccionar aquí]  │
│                                      │
│ 09:40 CR · Coordinación              │
│ Tarea creada                         │
│ [Abrir tarea] [Inspeccionar aquí]    │
│ [Cargar actividad anterior]          │
└──────────────────────────────────────┘
```

En 360–1023 px el panel usa el ancho disponible, respeta teclado/safe area, contiene el foco y lo devuelve a `Actividad`. La cronología es una lista/`feed` semántico; actor, tipo, hora Costa Rica y destino se expresan con texto. UTC permanece en el detalle con `--font-data: "Roboto Mono", Consolas, monospace;`.

### Texto, comandos y una sola publicación

```text
Compositor
[ /tarea Preparar visita______________]

Tipo seleccionado: Tarea
Título       [Preparar visita________]
Responsable  [Seleccionar___________v]
Vence        [24/07/2026]

[Adjuntar] [Comandos]        [* Publicar]
```

`/tarea`, `/gestion` y `/agenda` tienen acciones visibles equivalentes y preparan el mismo caso de uso propietario. El botón `Publicar` es único: sirve para la anotación sin `/`, el tipo elegido con `/` y cualquier adjunto revisado. RLS, versión, auditoría y aprobación aplican igual que en la vista normal; no se crea una copia local.

### IA dentro del compositor: propuesta, no publicación

```text
Propuesta de IA · Anotación
Corte: 23 jul 2026, 10:00 CR
Confianza: Media (0,72)
Evidencia (2) [Ver fuentes]

[Texto propuesto editable____________]
[Descartar]                 [Usar borrador]

[Adjuntar] [Comandos]        [* Publicar]
```

La IA no activa `Publicar`. Una persona edita o descarta y confirma con ese mismo botón; si la acción es sensible, continúa por la aprobación configurada.

### Adjunto integrado y exclusivo de OneDrive

No existe dropzone independiente ni acción `Crear documento`. Arrastrar sobre el compositor, tomar una foto o elegir un archivo produce el mismo estado en línea:

```text
Compositor
[Anotación opcional___________________]
[Arrastra aquí o Adjuntar archivo]     │ zona del propio compositor

levantamiento-campo.pdf · 2,4 MB
Estado: Detectado · aún no cargado

Propuesta en línea
Tipo sugerido       [Informe de campo_____v]
Relacionar con      [Gestión Visita______v]
Carpeta OneDrive    [Trabajo CN-01/03-DATOS_v]
Por qué: nombre + contexto [Ver evidencia]

[Quitar] [Comandos]          [* Publicar]
```

La persona puede cambiar tipo, relación y carpeta entre opciones autorizadas. Detectar el archivo no inicia red ni escritura; el único `Publicar` constituye la confirmación humana vigente y revalida permiso, versión, destino y aprobación.

Después de `Publicar`:

```text
Subiendo exclusivamente a OneDrive
██████████████░░░░ 72 %
levantamiento-campo.pdf
Etapa: cargando binario

Después: metadatos + driveId/driveItemId
Supabase no recibe el binario.
```

Error recuperable dentro del mismo compositor:

```text
! No se pudo completar la carga en OneDrive
El texto y la propuesta siguen disponibles.
El archivo no aparece como publicado.

[Reintentar] [Quitar adjunto]
                            [* Publicar]
```

`Reintentar` o `Quitar` vuelve al mismo `Publicar`; no aparece un segundo botón para enviar. Si OneDrive recibió el archivo pero falló la relación, se ofrece reconciliar o archivar con motivo según permiso/aprobación; nunca se elimina. Nombres, rutas, estados y errores usan wrap seguro y cero overflow a 360/768/1024/1440 y zoom 200 %.

## W12C — Contexto vivo relacional (`DEC-0109`)

### Once alcances y ancho de pilar

```text
Contexto vivo · JBC-2026-014
Trabajo CN-01 · Objeto: Gestión “Coordinar visita”

Filtrar por tipo
┌──────────────────────────────────────┐
│ Seleccione un tipo relacionado     ▾ │
└──────────────────────────────────────┘

Opciones: Datos · Trabajos · Gestiones · Tareas · Agenda ·
Trámites* · Archivos · Aprobaciones · Actividad · Reportes · Historial

* solo en Trabajo de Plano de catastro
```

En escritorio, Contexto vivo usa 400–480 px y funciona como pilar, no como carril residual. `Filtrar por tipo` reúne los once alcances en un único selector de 44 px; cada opción añade su conteo. Elegir una opción abre el inspector debajo y cerrarlo devuelve el foco al selector. Nunca se usan pestañas horizontales, una cuadrícula permanente ni scroll para escoger alcance. Solo se muestra información autorizada y cada fuente conserva estado/última actualización. El `h1` y la sección activa permanecen detrás o al lado según composición, no se reemplazan.

### Navegación primaria e inspección secundaria

Desde la sección Gestiones:

```text
Gestión · Coordinar visita
[3 tareas relacionadas] [Agenda] [Archivos]

┌ Inspector: Tareas relacionadas ─────────┐
│ Tarea · Preparar visita · En curso      │ ← nombre es enlace real
│ Vence 24 jul · versión 4                │
│ [Abrir tarea] [Inspeccionar aquí]       │
└─────────────────────────────────────────┘
```

`Tarea · Preparar visita` o `Abrir tarea` navega a la ruta operativa normal de la tarea. Al pulsar `Inspeccionar aquí`:

```text
Gestión: Coordinar visita
  ↕ relación: pertenece a / contiene
Tarea: Preparar visita
  ↕ relación: programada mediante
Agenda: 24 jul, 08:00–10:00 CR

[Atrás a Gestión] [Abrir agenda] [Inspeccionar archivos aquí]
```

La misma relación se inicia desde Tarea, Agenda, archivo, Gestión o Trabajo y permite volver. El inspector, sidebar, modal o drawer se elige por densidad/ancho; nunca sustituye el enlace normal ni crea una ruta paralela. Atrás conserva Proyecto, Trabajo, sección, scroll y foco.

### IA a la derecha del Contexto vivo

```text
┌─────────────────────┬──────────────────────┬───────────────────┐
│ sección activa      │ Contexto vivo        │ IA                │
│ Gestión             │ 400–480 px           │ Objeto autorizado │
│ contenido operable  │ Trabajo/Tarea/Agenda │ [Compositor_____] │
│                     │ [Abrir vista normal] │ [Comandos][Enviar]│
│                     │ [Inspeccionar aquí]  │ conversación      │
│                     │                      │ propuestas        │
└─────────────────────┴──────────────────────┴───────────────────┘
```

IA recibe solo el contexto autorizado visible. Su compositor queda arriba y la conversación/propuestas debajo. No cubre ni desplaza fuera del viewport el inspector; la grid conserva `min-inline-size: 0` y activa fallback antes de perder mínimos.

### Fallback por ancho insuficiente, zoom o texto ampliado

```text
Sección activa · Gestión
[Abrir Contexto] [Abrir IA]

Contexto vivo (región apilada o Drawer)
Objeto: Tarea relacionada · [Volver a Gestión]
[Abrir tarea] [Inspeccionar aquí]
[Continuar en IA con este contexto]

IA (debajo o Drawer accesible)
Contexto: JBC-2026-014 · Tarea relacionada
[Pregunta o comando___________________]
[Comandos]                     [Enviar]
Conversación y propuestas
[Volver a Contexto vivo]
```

El fallback conserva Proyecto, Trabajo, sección, alcance, objeto, trail relacional, scroll, borrador y retorno de foco. En 360/768 se usa normalmente Drawer/hoja; en 1024/1440/zoom 200 % la decisión depende del ancho real. No se duplican regiones enfocables ni aparece overlay sobre Contexto vivo.

Contexto vivo no contiene dropzone ni carga propia. `Adjuntar archivo` enfoca el compositor unificado de W12B, donde se detecta el archivo, se propone tipo/relación/carpeta y el único `Publicar` confirma la operación humana.

## W13 — Buscar, Control General y reportes

### Buscar, 360 px

```text
< Atrás                    h1 Buscar
[proyecto, cliente, finca…________]
[Filtrar]

Filtros: Tipo = Avalúo [quitar]
8 resultados autorizados

Trabajo · AV-01 · Proyecto JBC-2026-022
Avalúo Local ficticio
Situación interna: Planificado
[Abrir]

Cliente · Cliente Ficticio Dos
2 proyectos dentro de tu alcance
[Abrir]

[Anterior] Página 1 de 2 [Siguiente]
```

### Control General, 360 px

```text
h1 Control General
Corte: 23 jul, 10:15 CR      [Filtrar]

JBC-2026-022 · Trabajo AV-01 · Avalúo
Cliente: Cliente Ficticio Dos
Situación interna: Planificado
Responsable: Técnica Uno
Vence: 31 jul
[Ver detalle]

Vista normalizada; no importa ni sincroniza Excel.
```

### Reporte, 1024/1440 px

```text
h1 Reportes                                        [* Generar exportación]

Definición (máx. 720 px)          Vista previa / fecha de corte
Periodo                           24 proyectos autorizados
Tipo / estado / responsable       Columnas incluidas
Formato: Excel | CSV | PDF        Advertencias de alcance

[Descargar] [Solicitar guardar en OneDrive]
```

`Solicitar guardar en OneDrive` inicia una aprobación; no presenta guardado como completado.

### Entregables dentro del proyecto, 360 px

```text
← Reportes generales      JBC-2026-014
h1 Reportes y entregables
Corte: 23 jul, 10:15 CR

Entregables
Informe técnico · Borrador · OneDrive
[Abrir] [Ver historial]

Exportaciones
Reporte de avance · PDF · 22 jul
[Descargar si está autorizado]

[* Generar reporte del proyecto]
[Solicitar guardar en OneDrive]
[Ver todos los reportes]

Resumen | Trabajos | Trabajo | Agenda | Más
```

Los binarios enlazados siguen en OneDrive. Generar, descargar y guardar conservan alcance, fecha de corte, auditoría y aprobación cuando corresponde.

## W14 — Salud, administración y versión

### Salud, 360 px

```text
< Más                     h1 Salud
Actualizado 10:20 CR            [Actualizar]

Aplicación        Sano
Supabase          Sano
Autenticación     Sano
OneDrive          ! Degradado
Último éxito 09:42 · impacto: documentos
[Ver detalle]

APT               Datos antiguos
Último ciclo 07:04 · solo proyectos catastro

SIRI              Sin consultar en este ciclo
OpenAI            Disponible
Push              Disponible
Trabajador        Sano · próximo 13:00
Respaldo          Último válido 22 jul, 22:18
Restauración      Última prueba 01 jul

Uso plan gratuito
Base de datos 71 % · Atención (umbral 70 %)

Entorno Pruebas · Versión 1.0.0
```

### Administración de catálogo, 1440 px

```text
Administración > Catálogos                         [* Nuevo valor]
h1 Prioridades

[Buscar] [Vigencia] [Versión]

Código   Nombre     Estado   Protección   Usos   Acciones
PRI-NOR  Normal     Vigente  Protegido    124    [⋯]
PRI-CRI  Crítica    Vigente  Protegido      8    [⋯]

Panel de detalle (sin tarjeta interna)
Código invariable · color/icono · tipos · vigencia · versión
[Comparar cambio] [Solicitar aprobación]
```

Un valor usado se archiva; no aparece eliminar. Los usuarios/permisos y niveles sensibles permanecen condicionados por DEC-0103/0104.

## W14B — Tema y acento (`DEC-0106`), 360 px

```text
< Cuenta                  h1 Tema y acento

Tema
● Sistema
  El dispositivo usa Oscuro en este momento.
○ Claro
○ Oscuro

Si eliges Claro u Oscuro, prevalecerá sobre Sistema
y se sincronizará entre tus dispositivos.

Vista previa
[Ver Claro] [Ver Oscuro]
Fondo neutral · superficie neutral · texto principal
[Botón primario]  foco visible  selección activa
Éxito · Advertencia · Error · IA · APT · SIRI

Acento
[Teal] [Azul] [Índigo]
[Violeta] [Rosa] [Naranja]
[Color personalizado]

✓ Contraste de texto y foco válido en Claro y Oscuro
El acento solo se usa en acciones, navegación, selección,
progreso y foco; no domina el fondo.

[Restaurar Tema: Sistema]
[Restaurar Acento: teal]
[* Guardar preferencias]
```

Al cambiar Tema o la preferencia del sistema, la vista conserva ruta, scroll y foco. En ≥1024 px, las vistas previas Claro/Oscuro pueden ir lado a lado; no se usan tarjetas anidadas ni grandes paneles teñidos por el acento.

## W15 — Estados representativos

### Vacío filtrado

```text
No hay resultados con estos filtros
Prueba quitando Estado = Archivado.
[Limpiar filtros]
```

### Degradación local

```text
! OneDrive no está disponible
El proyecto, las gestiones y las tareas siguen disponibles.
Última sincronización exitosa: 23 jul, 09:42 CR.
[Reintentar]
```

### Error de formulario

```text
No se pudo guardar la gestión · 2 campos por revisar
> Motivo de espera
> Próxima fecha de seguimiento

Motivo de espera                 Error: obligatorio
Próxima fecha                    Error: selecciona una fecha
Tus otros datos siguen en el formulario.
```

### Sin conexión

```text
! Sin conexión
Puedes consultar la estructura disponible, pero no realizar cambios.
[Guardar] (deshabilitado: requiere conexión)
```

### Permiso

```text
h1 No tienes acceso a este contenido
Tu sesión es válida, pero este registro no está dentro de tu alcance.
[Ir a Inicio]
```

No se muestra nombre, código, tipo ni metadatos del registro.

## Transformación por breakpoint

| Patrón                 | 360 px                                                                   | 768 px                   | 1024 px                              | 1440 px                                                     |
| ---------------------- | ------------------------------------------------------------------------ | ------------------------ | ------------------------------------ | ----------------------------------------------------------- |
| Navegación general     | Inicio/Proyectos/Trabajo/Agenda/Más                                      | header + Drawer general  | sidebar o Drawer según contenedor    | sidebar 240 px o compacta 64 px, con nombres/tooltips       |
| Navegación de proyecto | Resumen/Trabajos/Trabajo/Agenda/Más + retorno                            | Drawer local + retorno   | sidebar local o Drawer               | sidebar local 240/64 px + retorno                           |
| Tema                   | Sistema/Claro/Oscuro, neutral                                            | igual                    | igual                                | vista previa Claro/Oscuro paralela                          |
| Cabecera de página     | apilada                                                                  | apilada/ancha            | título + primaria                    | título + primaria                                           |
| Formulario             | 1 columna                                                                | 1 columna                | 1; pares relacionados pueden usar 2  | igual, máx. 720 px                                          |
| Tabla/listado          | filas apiladas                                                           | filas/lista              | tabla opcional                       | tabla paginada                                              |
| Grid en contenedor     | auto-fit/minmax → 1 columna                                              | según ancho real         | 1+ columnas si caben                 | 1+ columnas si caben                                        |
| Filtros                | hoja completa                                                            | Drawer/hoja              | barra + panel                        | barra + panel                                               |
| Comparativo            | Actual y Propuesto apilados                                              | apilado                  | 2 columnas                           | 2 columnas                                                  |
| Agenda                 | lista inicial                                                            | lista inicial            | calendario + lista                   | calendario + lista                                          |
| OneDrive               | avance/retroceso                                                         | lista/ruta               | árbol + lista                        | árbol + lista                                               |
| Proyecto/Trabajo       | contrato + selector `Trabajo n de N` + 5 destinos                        | agregado + Drawer local  | agregado + índice acotado al Trabajo | agregado + `1..N` Trabajos e índice completo                |
| Actividad DEC-0108     | compositor unificado + cronología en hoja                                | alcance en Drawer        | dentro de Contexto vivo              | dentro de Contexto vivo ancho                               |
| Contexto vivo DEC-0109 | Drawer/hoja, 11 alcances y relaciones                                    | Drawer/apilado           | pilar ancho + IA apilada/drawer      | pilar 400–480 px + IA a la derecha si caben; fallback si no |
| Adjunto                | dentro del compositor: cámara/selector/arrastre → propuesta → `Publicar` | igual                    | igual                                | igual; sin dropzone separado ni segunda confirmación        |
| Modal complejo         | pantalla completa                                                        | pantalla completa/Drawer | modal amplio o página                | modal amplio o página                                       |
| Panel secundario       | debajo                                                                   | debajo                   | paralelo si aporta                   | paralelo si aporta                                          |

Ninguna transformación elimina acciones, obliga hover/drag, sustituye secciones con Contexto vivo/Actividad o introduce APT/SIRI fuera de un Trabajo de Plano de catastro. La IA queda a la derecha solo si cabe, con el compositor arriba; fallback, relaciones, propuestas y adjuntos conservan cero overflow horizontal a zoom 200 %.
