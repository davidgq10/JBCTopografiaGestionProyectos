# Catálogo canónico de criterios de aceptación

Estado: **aprobado en G0 el 2026-07-23**

Este catálogo normaliza la especificación en **100 criterios activos**. `E` indica un criterio explícito bajo “Criterios de aceptación”; `C` consolida reglas normativas de los RF que no traen una sección formal o que necesitan una condición medible transversal. Ningún criterio consolidado amplía el alcance.

RF-013 no contiene criterios activos: su única comprobación es una prueba de exclusión (`EX-013-01`) que impide reintroducirlo.

## RF-001 — Clientes

- `AC-001-01` (`E`): crear, consultar, editar y archivar clientes según permisos.
- `AC-001-02` (`E`): vincular un cliente con varios proyectos sin duplicar el cliente.
- `AC-001-03` (`E`): administrar contactos y direcciones de forma independiente.
- `AC-001-04` (`E`): ninguna acción de interfaz elimina documentos.
- `AC-001-05` (`E`): toda operación documental queda auditada.

## RF-002 — Proyectos por tipo

- `AC-002-01` (`E`): cada tipo de Trabajo muestra exclusivamente los campos autorizados y el Proyecto agrega `1..N` Trabajos sin fusionar estados.
- `AC-002-02` (`E`): APT y SIRI aparecen únicamente en cada Trabajo de Plano de catastro.
- `AC-002-03` (`E`): cada trámite externo conserva historia independiente del Trabajo, del Proyecto y de otros trámites.
- `AC-002-04` (`E`): no existe importador de proyectos desde Excel; la creación manual y confirmada produce una Contratación y `1..N` Trabajos, nunca un Proyecto sin Trabajo.
- `AC-002-05` (`E`): cambiar el tipo de un Trabajo o archivar una Contratación/Trabajo no pierde información ni historia; el cambio registra Trabajo, usuario, marca UTC, tipo y estado anteriores. Si el Trabajo deja de ser Plano de catastro, APT/SIRI queda solo como historia inmutable y cesan campos/monitoreo activos para ese Trabajo, sin afectar a los demás.

## RF-003 — Gestiones

- `AC-003-01` (`E`): consultar cronológicamente las gestiones de cada Trabajo y el agregado autorizado de la Contratación, conservando siempre el identificador del Trabajo y sin fusionar estados, responsables o historias.
- `AC-003-02` (`E`): una gestión puede originar varias tareas.
- `AC-003-03` (`E`): rechazar una espera sin motivo o fecha de seguimiento.
- `AC-003-04` (`E`): notas, responsables, fechas, estados y resultados conservan historial y no se sobrescriben.

## RF-004 — Tareas

- `AC-004-01` (`E`): descomponer tareas y relacionarlas mediante listas, subtareas y dependencias.
- `AC-004-02` (`E`): rechazar dependencias inválidas, incluidas las circulares.
- `AC-004-03` (`E`): detectar cambios concurrentes y exigir resolución explícita, sin sobrescritura silenciosa.
- `AC-004-04` (`E`): cierre, cancelación y archivo conservan historial y exigen motivo cuando aplica.
- `AC-004-05` (`E`): completar el flujo principal de tareas desde celular.

## RF-005 — Programación

- `AC-005-01` (`E`): impedir o advertir doble reserva de personas y recursos antes de confirmar.
- `AC-005-02` (`E`): dividir una tarea en varios bloques de ejecución, distintos de su vencimiento.
- `AC-005-03` (`E`): representar conflictos simultáneamente con texto e icono y ofrecer alternativa accesible al calendario.
- `AC-005-04` (`E`): respetar preferencias y, por defecto en `America/Costa_Rica`, entregar recordatorios de 07:00 inclusive a 20:00 exclusiva y silenciarlos de 20:00 a 07:00.

## RF-006 — APT y SIRI

- `AC-006-01` (`E`): ningún código de monitoreo puede invocar `POST /APT2/Plano/RedireccionarCargarPlano`; solo se permiten métodos/rutas de la lista blanca.
- `AC-006-02` (`E`): probar los ciclos 07:00, 13:00 y 19:00 en `America/Costa_Rica`, incluida la ventana máxima de inicio.
- `AC-006-03` (`E`): reintentos y consultas repetidas no duplican eventos ni notificaciones.
- `AC-006-04` (`E`): una caída de APT/SIRI no bloquea proyectos, tareas ni agenda y conserva éxitos parciales/frescura.
- `AC-006-05` (`E`): la activación real queda bloqueada hasta validar autorización legal y técnica, sin evadir CAPTCHA/MFA.

## RF-007 — OneDrive

- `AC-007-01` (`E`): repetir una operación no duplica carpetas, cargas ni movimientos.
- `AC-007-02` (`E`): una aprobación no se ejecuta si cambió la versión del elemento.
- `AC-007-03` (`E`): cambios directos de OneDrive se reflejan mediante notificaciones y delta.
- `AC-007-04` (`E`): Supabase no contiene binarios del proyecto; documentos nunca se eliminan y la papelera solo admite carpetas vacías con doble control.

## RF-008 — Inteligencia artificial

- `AC-008-01` (`E`): distinguir visual y estructuralmente sugerencias de IA de datos confirmados, con evidencia, confianza y fecha de corte.
- `AC-008-02` (`E`): auditar aprobación o rechazo y ejecutar propuestas sensibles solo mediante el flujo autorizado.
- `AC-008-03` (`E`): el backend usa Responses API con `store:false`, Structured Outputs, prompts/modelos/enrutamiento configurables, límite mensual y alertas; las pruebas automatizadas usan simuladores.
- `AC-008-04` (`E`): ninguna respuesta eleva permisos, revela secretos ni usa datos fuera del alcance autorizado; la aplicación degrada si OpenAI falla.

## RF-009 — Notificaciones

- `AC-009-01` (`E`): leer, filtrar y marcar avisos en un centro persistente.
- `AC-009-02` (`E`): denegar permisos de Windows/Web Push no impide usar la aplicación ni pierde el aviso interno.
- `AC-009-03` (`E`): enlaces profundos y contenido respetan permisos y no exponen información sensible.
- `AC-009-04` (`E`): reintentos no producen avisos duplicados y se respetan preferencias/dispositivo; el aviso interno se registra sin pérdida y la entrega visible predeterminada ocurre de 07:00 inclusive a 20:00 exclusiva, quedando en cola durante 20:00–07:00.

## RF-010 — Identidad, roles y seguridad

- `AC-010-01` (`E`): existen pruebas positivas y negativas para Administrador, Coordinador, Técnico y Solo lectura.
- `AC-010-02` (`E`): un usuario no consulta datos fuera de su alcance; RLS protege toda tabla expuesta.
- `AC-010-03` (`E`): Microsoft Entra ID se integra mediante Supabase Auth, restringe tenant y usuarios preautorizados, exige MFA de Microsoft, y una revocación impide nuevos accesos y queda auditada.
- `AC-010-04` (`E`): ocultar controles en la interfaz no sustituye autorización y validación de servidor; secretos/credenciales nunca llegan al navegador.

## RF-011 — Tablero, búsqueda y reportes

- `AC-011-01` (`E`): búsqueda, resultados, agregados y exportaciones respetan RLS.
- `AC-011-02` (`E`): totales y reportes concuerdan con fuentes normalizadas; los agregados de Contratación conservan el identificador de cada Trabajo y nunca fusionan tipos, estados o responsables.
- `AC-011-03` (`E`): filtros se conservan durante la sesión y listados usan paginación de servidor.
- `AC-011-04` (`E`): el tablero por rol prioriza acciones sin saturación visual; exportar y guardar quedan auditados/aprobados cuando corresponde.

## RF-012 — Arquitectura y stack

- `AC-012-01` (`E`): sustituir un adaptador no exige modificar el dominio.
- `AC-012-02` (`E`): React no realiza llamadas privilegiadas ni recibe `service_role` o secretos.
- `AC-012-03` (`E`): módulos y paquetes no presentan dependencias circulares.
- `AC-012-04` (`E`): eventos repetidos no duplican efectos y Realtime no sustituye la fuente transaccional.
- `AC-012-05` (`E`): contratos, eventos, límites y decisiones quedan versionados; manifiestos/lockfile demuestran el stack e infraestructura obligatorios y la ausencia de tecnologías, servicios pagados o Premium no aprobados.

## RF-013 — Exclusión

- `EX-013-01` (no activo): búsquedas estáticas, navegación y E2E confirman que no existe importación, migración o sincronización de proyectos desde Excel.

## RF-014 — Catálogos y configuración

- `AC-014-01` (`C`): todo valor conserva código invariable, metadatos, vigencia, versión, protección y archivo sin eliminación; `Otro` exige descripción.
- `AC-014-02` (`C`): cada tipo configura campos, estados, transiciones, tareas, carpetas, documentos, duración, integraciones, alertas, cierre y roles.
- `AC-014-03` (`C`): estados internos y etapa previa de `En espera` funcionan con motivo, responsable y seguimiento.
- `AC-014-04` (`C`): estados externos normalizados conservan siempre el texto original y no se mezclan con estados internos.
- `AC-014-05` (`C`): prioridades Urgente/Crítica exigen justificación y Crítica notifica al coordinador.
- `AC-014-06` (`C`): tipos de gestión y tarea se filtran por contexto y la opción `Otro` exige descripción.
- `AC-014-07` (`C`): tipos documentales aplican carpeta sugerida, extensiones, obligatoriedad, sensibilidad, aprobación y conservación configuradas.
- `AC-014-08` (`C`): niveles de aprobación son configurables; proyectos conservan su versión y una actualización requiere comparativo y aprobación.

## RF-015 — Aprobaciones y auditoría

- `AC-015-01` (`E`): doble control implica la participación de dos personas distintas y autorizadas conforme a la política aprobada; si son solicitante+aprobador o dos aprobadores se resuelve en `DEC-0104` antes de implementar.
- `AC-015-02` (`E`): una aprobación obsoleta por cambio de versión no se ejecuta.
- `AC-015-03` (`E`): una acción aprobada se ejecuta como máximo una vez, separando decisión y ejecución.
- `AC-015-04` (`E`): rechazos, cancelaciones y archivos exigen motivo conforme a la acción.
- `AC-015-05` (`E`): toda exportación de auditoría queda auditada; el registro es append-only y nunca contiene secretos.

## RF-016 — Calidad y operación

- `AC-016-01` (`C`): al percentil 75, LCP ≤ 2,5 s, INP ≤ 200 ms y CLS ≤ 0,1 en la matriz de dispositivos acordada.
- `AC-016-02` (`C`): tablero inicial < 5 s, consultas ordinarias p95 < 2 s, escrituras p95 < 3 s sin tiempo externo y búsqueda < 3 s.
- `AC-016-03` (`C`): soportar 25 usuarios simultáneos, 10.000 proyectos, 100.000 tareas/gestiones y 500.000 auditorías con paginación de servidor.
- `AC-016-04` (`C`): demostrar degradación independiente, frescura y espera progresiva ante fallos externos, con objetivo operativo mensual de 99 %.
- `AC-016-05` (`C`): cada ciclo programado inicia dentro de 15 minutos, intenta terminar antes del siguiente y conserva éxitos parciales.
- `AC-016-06` (`C`): verificar dos versiones recientes de Edge/Chrome, Chrome Android, Safari iPhone y WCAG 2.2 AA.
- `AC-016-07` (`C`): sin conexión, la PWA abre estructura e informa estado, pero bloquea modificaciones y no cachea datos sensibles por defecto.
- `AC-016-08` (`C`): concurrencia usa versión/comparativo; ASVS L2 aplicable, seguridad, fallos y calidad se prueban; dominio/aplicación alcanzan ≥ 80 % de cobertura.

## RF-017 — Respaldo, recuperación y monitoreo

- `AC-017-01` (`C`): respaldo lógico diario a las 22:00 de Costa Rica, comprimido, cifrado, con huella, en OneDrive administrativo y sin secretos/binarios de proyecto.
- `AC-017-02` (`C`): retener diarios 30 días, mensuales 12 meses e informes de restauración/auditoría permanentemente.
- `AC-017-03` (`C`): restaurar trimestralmente en entorno aislado sin avisos ni consultas externas; una copia solo es válida tras restauración.
- `AC-017-04` (`C`): demostrar RPO objetivo de 24 h y RTO de 8 h laborables.
- `AC-017-05` (`C`): panel y alertas cubren componentes definidos, integridad, ciclos omitidos, error > 20 %, cola detenida y límites 70/85 %.
- `AC-017-06` (`C`): logs estructurados correlacionados y procedimientos de incidente cubren los casos definidos sin secretos.

## RF-018 — Entornos y despliegue

- `AC-018-01` (`C`): Local, Desarrollo, Pruebas/UAT y Producción separan datos, credenciales, tareas y destinos; datos reales se anonimizan fuera de producción.
- `AC-018-02` (`C`): rama principal protegida y cada cambio ejecuta formato, lint, tipos, arquitectura, pruebas, dependencias, build, migraciones y navegador.
- `AC-018-03` (`C`): producción exige cambios, pruebas, respaldo, reversión y aprobación documentados.
- `AC-018-04` (`C`): SemVer, feature flags de integraciones/flujos y entorno/versión visibles funcionan por ambiente.
- `AC-018-05` (`C`): reversión conserva datos y última versión estable; migraciones destructivas requieren respaldo, prueba y aprobación; documentación de entrega está completa.

## RF-019 — Modelo de datos

- `AC-019-01` (`C`): el esquema representa todas las entidades enumeradas y cada módulo es propietario de sus datos.
- `AC-019-02` (`C`): relaciones cliente/proyecto, `Proyecto 1:N Trabajo` obligatorio y `Trabajo 1:N` gestiones/tareas/bloques/trámites/documentos/aprobaciones/actividad se verifican; toda referencia operativa conserva `proyectoId + trabajoId`.
- `AC-019-03` (`C`): campos transversales usan UUID, UTC, actor, versión, archivo, motivo y correlación cuando corresponden.
- `AC-019-04` (`C`): no hay eliminación en cascada de proyectos; historia, eventos y auditoría son de solo adición.
- `AC-019-05` (`C`): texto externo original se separa de normalización y los archivos permanecen fuera de la base.
- `AC-019-06` (`C`): toda entidad expuesta tiene RLS; índices y búsqueda por campos definidos respetan alcance y rendimiento.

## RF-020 — Sistema visual y celular

- `AC-020-01` (`E`): tokens visuales están centralizados en `theme.ts`.
- `AC-020-02` (`E`): no hay tarjetas anidadas ni tablas con separadores verticales ordinarios.
- `AC-020-03` (`E`): existe una sola acción primaria por zona; el compositor de Contexto vivo usa exactamente un `Publicar` para anotación, comando y adjunto.
- `AC-020-04` (`E`): hay al menos 24 px entre secciones principales.
- `AC-020-05` (`E`): los flujos críticos, incluidos selector de Trabajo, Contexto vivo y compositor integrado, funcionan a 360 px sin desplazamiento horizontal general.
- `AC-020-06` (`E`): el acento individual es accesible, previsualizable, restaurable y sincronizado sin cambiar colores semánticos.
- `AC-020-07` (`E`): axe-core no presenta hallazgos críticos/serios y Lighthouse accesibilidad alcanza al menos 95.
- `AC-020-08` (`E`): flujos críticos funcionan por teclado y móvil, con áreas táctiles mínimas y alternativas a hover/arrastre.
- `AC-020-09` (`E`): revisión visual independiente cubre Edge, Chrome, Android, iPhone, anchos objetivo, orientación, zoom y varios acentos.

## Regla de mantenimiento

No renumerar criterios existentes. Un cambio aprobado agrega, sustituye o retira criterios mediante `CHANGE-ID`, preservando historial en `DECISIONS_LOG.md` y actualizando simultáneamente la matriz de trazabilidad y pruebas.
