# Matriz de permisos y alcance

Estado: **`DEC-0103` APROBADA E IMPLEMENTADA; matriz 2561/2561 PASS; R6 GO; G2 aprobado**  
Fecha de corte: **2026-07-23** (`America/Costa_Rica`)

Esta matriz convierte la decisión aprobada por el usuario en casos verificables. La autorización efectiva reside en las políticas RLS, no en este documento, y este documento por sí solo no declara G2. Si una decisión posterior cambia cualquier celda, deben actualizarse conjuntamente esta matriz, migraciones, manifiesto de superficies, casos SQL y trazabilidad.

## Convenciones

- `G`: alcance global aprobado.
- `P`: Proyecto asignado directamente y activo.
- `T`: Trabajo asignado directamente y activo; solo incluye el encabezado mínimo de su Proyecto, no Trabajos hermanos.
- `O`: registro propio del usuario.
- `B`: proceso backend/trabajador autorizado, nunca cliente.
- `—`: denegación explícita.
- `C/R/U/D`: crear, consultar, actualizar y eliminar.
- `A`: archivar mediante comando con motivo; no equivale a `DELETE`.
- `S`: acción sensible; además exige aprobación/revalidación aplicable.

Toda celda es vigente para el corte 19. La ausencia de una operación significa denegación. `D` está denegado en datos de negocio e historia; el archivo es una operación distinta. Un permiso de interfaz no sustituye RLS.

## Alcance aprobado por rol

| Rol           | Alcance de datos aprobado                                         | Escritura aprobada                                    | Restricciones no negociables                                                                                                                                                                     |
| ------------- | ----------------------------------------------------------------- | ----------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Administrador | `G`, confirmado por el usuario                                    | administra usuarios, roles, configuración y operación | acciones sensibles con aprobación; credenciales individuales nunca visibles                                                                                                                      |
| Coordinador   | `G`, confirmado por el usuario                                    | administra operación y asignaciones                   | no administra usuarios ni roles; acciones sensibles con aprobación                                                                                                                               |
| Técnico       | `P` activo, confirmado por el usuario; incluye todos sus Trabajos | crear y actualizar datos operativos dentro de `P`     | una asignación aislada a Trabajo no concede alcance; sin borrado físico, administración de identidad/asignaciones, decisión de aprobaciones, mutación de auditoría ni escritura directa APT/SIRI |
| Solo lectura  | `G`, confirmado por el usuario                                    | ninguna escritura de negocio                          | consulta todos los Proyectos y sus Trabajos; preferencias/notificaciones propias se tratan separadamente                                                                                         |

`DEC-0103` quedó aprobada por el usuario: Administrador y Coordinador tienen alcance global; el Administrador administra usuarios, roles, configuración y operación, mientras el Coordinador administra operación/asignaciones, pero no usuarios ni roles. El Técnico solo ve Proyectos asignados a su cuenta, incluidos todos sus Trabajos, y puede crear/actualizar sus datos operativos; una asignación aislada a Trabajo o referencia indirecta no concede alcance. Solo lectura consulta globalmente todos los Proyectos y sus Trabajos, y no tiene escrituras de negocio. Los invariantes mantienen prohibidos borrados físicos, decisiones de aprobación no autorizadas, mutación de auditoría y escritura directa APT/SIRI.

## Matriz CRUD vigente por superficie

Los nombres son capacidades conceptuales hasta que el manifiesto físico de Fase 2 los relacione con tablas, vistas y funciones. `C:G` significa crear con alcance global; `R:P/T` significa leer solo dentro del alcance asignado aprobado.

| Superficie/capacidad                                  | Administrador            | Coordinador                             | Técnico                                           | Solo lectura                           | Regla adicional                                                                                                  |
| ----------------------------------------------------- | ------------------------ | --------------------------------------- | ------------------------------------------------- | -------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| Usuarios preautorizados, revocación, roles y permisos | `C/R/U:G; D:—; S`        | `R:G; C/U/D:—`                          | `—`                                               | `—`                                    | cambio auditado; revocar impide operación nueva                                                                  |
| Perfil y preferencias propias                         | `R/U:O`                  | `R/U:O`                                 | `R/U:O`                                           | `R/U:O`                                | no permite cambiar rol, tenant, estado o alcance                                                                 |
| Asignaciones Proyecto/Trabajo                         | `C/R/U:G; D:—; S`        | `C/R/U:G; D:—; S`                       | `R:O; C/U/D:—`                                    | `R:O; C/U/D:—`                         | cierre/revocación, no borrado; referencia no concede acceso                                                      |
| Clientes base                                         | `C/R/U:G; D:—; A:S`      | `C/R/U:G; D:—; A:S`                     | `—`                                               | `—`                                    | acceso contextual, si se aprueba, será proyección mínima reautorizada                                            |
| Proyecto/Contratación                                 | `C/R/U:G; D:—; A:S`      | `C/R/U:G; D:—; A:S`                     | `R:P; C/U/D/A:—`                                  | `R:G; C/U/D/A:—`                       | puede operar dentro del Proyecto, no crear ni alterar la Contratación                                            |
| Trabajo                                               | `C/R/U:G; D:—; A:S`      | `C/R/U:G; D:—; A:S`                     | `R/U:P; C/D/A:—`                                  | `R:G; C/U/D/A:—`                       | todos los Trabajos del Proyecto asignado; cambio de tipo requiere aprobación                                     |
| Participantes, inmuebles y propiedades                | `C/R/U:G; D:—; A:S`      | `C/R/U:G; D:—; A:S`                     | `C/R/U:P; D/A:—`                                  | `R:G; C/U/D/A:—`                       | par Proyecto/Trabajo coherente en lectura y escritura                                                            |
| Gestiones, espera, seguimiento                        | `C/R/U:G; D:—; A:S`      | `C/R/U:G; D:—; A:S`                     | `C/R/U:P; D/A:—`                                  | `R:G; C/U/D/A:—`                       | espera requiere motivo y seguimiento; archivo no aprobado por esta decisión                                      |
| Notas e historial de actividad                        | `C/R:G; U/D:—`           | `C/R:G; U/D:—`                          | `C/R:P; U/D:—`                                    | `R:G; C/U/D:—`                         | append-only/versionado; una corrección crea versión                                                              |
| Tareas, listas y dependencias                         | `C/R/U:G; D:—; A:S`      | `C/R/U:G; D:—; A:S`                     | `C/R/U:P; D/A:—`                                  | `R:G; C/U/D/A:—`                       | versión esperada; dependencias no amplían alcance                                                                |
| Programación y asignación de recursos                 | `C/R/U:G; D:—`           | `C/R/U:G; D:—`                          | `C/R/U:P; D:—`                                    | `R:G; C/U/D:—`                         | conflicto y recurso se reautorizan por operación                                                                 |
| Trámites APT/SIRI e historia externa                  | `R:G; C/U/D:—`           | `R:G; C/U/D:—`                          | `R:P; C/U/D:—`                                    | `R:G; C/U/D:—`                         | solo Plano de catastro activo; escritura solo `B` desde consulta permitida                                       |
| Elementos/referencias OneDrive                        | `C/R/U:G; D:—; A:S`      | `C/R/U:G; D:—; A:S`                     | `C/R/U:P; D/A:—`                                  | `R:G; C/U/D/A:—`                       | nunca binarios en Supabase                                                                                       |
| Solicitudes de operación OneDrive                     | `C/R:G; U/D:—`           | `C/R:G; U/D:—`                          | `C/R:P; U/D:—`                                    | `R:G; C/U/D:—`                         | estado, resultado y tipo de operación solo avanzan en backend; papelera exige aprobación/doble control aplicable |
| Solicitudes de aprobación                             | `C/R:G; U/D:—`           | `C/R:G; U/D:—`                          | `C/R:P; U/D:—`                                    | `R:G; C/U/D:—`                         | crear solicitud no concede decidir ni ejecutar la acción                                                         |
| Decisiones/ejecuciones de aprobación                  | `R:G; decisión:S; U/D:—` | `R:G; decisión:S; U/D:—`                | `R:P; decisión/C/U/D:—`                           | `R:G; C/U/D:—`                         | append-only; actor distinto y versión objetivo según política aprobada                                           |
| Catálogos, plantillas y configuración                 | `C/R/U:G; D:—; A:S`      | `R:G; C/U/D/A:—`                        | `R; C/U/D/A:—` solo catálogo necesario            | `R; C/U/D/A:—` solo catálogo necesario | valores usados se versionan/archivan; no se eliminan                                                             |
| Notificaciones del usuario                            | `R/U:O`                  | `R/U:O`                                 | `R/U:O`                                           | `R/U:O`                                | `U` solo leído/preferencia; payload reautorizado                                                                 |
| Suscripción/dispositivo propio                        | `C/R/U:O; D:—; A`        | `C/R/U:O; D:—; A`                       | `C/R/U:O; D:—; A`                                 | `C/R/U:O; D:—; A`                      | revocación lógica; secretos Push no retornan al cliente                                                          |
| Auditoría                                             | `R:G; C/U/D:—`           | `R:G` solo permiso explícito; `C/U/D:—` | `R:P` solo permiso explícito pendiente; `C/U/D:—` | `—` salvo decisión expresa             | escritura únicamente `B`; exportación se audita                                                                  |
| Outbox, consumo idempotente y trabajos internos       | `—`                      | `—`                                     | `—`                                               | `—`                                    | exclusivamente `B`; no se exponen al cliente                                                                     |
| Credenciales, secretos, cookies y claves              | `—`                      | `—`                                     | `—`                                               | `—`                                    | exclusivamente vault/backend; ni administradores pueden ver credenciales APT/SIRI                                |

Las escrituras operativas confirmadas del Técnico siguen sujetas a validación de servidor, versión, coherencia Proyecto/Trabajo y aprobaciones sensibles. El rol por sí solo nunca permite salir de un Proyecto asignado ni ejecutar una acción reservada.

## Matriz mínima allow/deny de pruebas

Cada fila debe repetirse para toda tabla, vista y función física aplicable. Los casos `ALLOW` solo se activan después de aprobar `DEC-0103`; antes, el arnés falla cerrado.

| Caso                                                         |               Administrador |                      Coordinador |                         Técnico |                Solo lectura |
| ------------------------------------------------------------ | --------------------------: | -------------------------------: | ------------------------------: | --------------------------: |
| `SELECT` Proyecto/Trabajo dentro del alcance                 | **ALLOW global confirmado** |      **ALLOW global confirmado** |   **ALLOW asignado confirmado** | **ALLOW global confirmado** |
| `SELECT` Proyecto no asignado                                | **ALLOW global confirmado** |      **ALLOW global confirmado** |             **DENY confirmado** | **ALLOW global confirmado** |
| `SELECT` cualquier Trabajo dentro de Proyecto asignado       | **ALLOW global confirmado** |      **ALLOW global confirmado** |            **ALLOW confirmado** | **ALLOW global confirmado** |
| `SELECT` Trabajo de Proyecto no asignado                     | **ALLOW global confirmado** |      **ALLOW global confirmado** |             **DENY confirmado** | **ALLOW global confirmado** |
| `INSERT` dato operativo con par Proyecto/Trabajo válido      |         ALLOW por capacidad |              ALLOW por capacidad | **ALLOW con Proyecto asignado** |                        DENY |
| `INSERT` con Proyecto accesible y Trabajo de otro Proyecto   |                        DENY |                             DENY |                            DENY |                        DENY |
| `UPDATE` dato operativo autorizado y versión vigente         |         ALLOW por capacidad |              ALLOW por capacidad | **ALLOW con Proyecto asignado** |                        DENY |
| `UPDATE` para cambiar claves hacia otro alcance              |                        DENY |                             DENY |                            DENY |                        DENY |
| `DELETE` dato de negocio/historia                            |                        DENY |                             DENY |                            DENY |                        DENY |
| `UPDATE/DELETE` append-only                                  |                        DENY |                             DENY |                            DENY |                        DENY |
| Consultar por notificación/referencia a objeto no autorizado |                        DENY | DENY si permiso específico falta |                            DENY |                        DENY |
| Usar rol/alcance falso en metadatos JWT                      |         DENY como elevación |              DENY como elevación |             DENY como elevación |         DENY como elevación |
| Usuario no preautorizado o revocado                          |                        DENY |                             DENY |                            DENY |                        DENY |
| Invocar RPC no concedida                                     |                        DENY |                             DENY |                            DENY |                        DENY |

## Datos de prueba requeridos

El fixture reproducible contiene UUID sintéticos, sin PII:

- un usuario activo por cada rol y un usuario de cada rol revocado;
- un usuario autenticado pero no preautorizado;
- dos Proyectos (`P-A`, `P-B`), con dos Trabajos hermanos en `P-A` y uno en `P-B`;
- asignación a Proyecto, asignación solo a un Trabajo, asignación vencida/revocada y ausencia de asignación;
- una fila operativa por Trabajo y una referencia indirecta desde notificación/aprobación;
- una fila por cada tabla append-only;
- versiones vigente y obsoleta para concurrencia.

Todos los relojes de fixture son UTC y los resultados no dependen de la hora local.

## Reglas para vistas y funciones

- Una vista hereda exactamente la intersección del alcance de sus fuentes; no usa propietario para saltar RLS.
- Una vista materializada expuesta se considera una copia de datos y necesita RLS equivalente o no se expone.
- Una RPC devuelve el mismo resultado para recurso inexistente y recurso fuera de alcance cuando revelar existencia sea sensible.
- Un helper `security definer` privado no es una RPC: no aparece en el esquema expuesto, no devuelve filas de negocio y no puede recibir un rol declarado por el cliente.
- Toda excepción se incorpora al manifiesto con justificación y caso negativo propio; una superficie no inventariada falla.

## Criterio de aprobación

La decisión está aprobada, registrada e implementada por la migración 19. Las rutas limpia e incremental produjeron el mismo esquema y `RLS-MATRIX PASS 2561/2561`; por tanto, esta matriz queda **vigente implementada**. R6 confirmó el corte con 0 P0/P1/P2/P3 y el usuario aprobó G2 el 2026-07-23.
