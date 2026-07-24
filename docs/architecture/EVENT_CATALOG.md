# Catálogo de eventos versionados

Estado: **contrato congelado en Fase 2**. Fecha: 2026-07-23.

## Sobre `v1`

Cada evento se persiste en `outbox_events` dentro de la misma transacción que el
cambio de negocio. La carga canónica equivalente está en
`packages/contracts/src/events.ts` y contiene:

| Campo                                                | Regla                                                          |
| ---------------------------------------------------- | -------------------------------------------------------------- |
| `contractVersion`                                    | entero `1`                                                     |
| `eventId`                                            | UUID único, clave primaria de deduplicación                    |
| `eventName`                                          | nombre completo con sufijo `.v1`                               |
| `occurredAtUtc`                                      | instante UTC serializado con `Z`                               |
| `correlationId` / `causationId`                      | UUID; causación puede ser nula                                 |
| `producer`                                           | módulo propietario, nunca proveedor/credencial                 |
| `aggregateType` / `aggregateId` / `aggregateVersion` | agregado y versión confirmada                                  |
| `actorId`                                            | UUID o nulo para proceso; nunca token, cookie o correo         |
| `payload`                                            | carga mínima, validada y sin secretos/binarios/PII innecesaria |

Los DTO operativos conservan `projectId + workId`. `project.archived.v1` es la única
carga agregada a nivel Contratación: incluye `projectId` y la lista no vacía de
`workIds`, preservando la identidad de cada Trabajo sin fusionar estados.

## Eventos

| Evento                      | Productor                     | Consumidores iniciales                         | Carga mínima específica                                                                                      | Clave de efecto idempotente                                       |
| --------------------------- | ----------------------------- | ---------------------------------------------- | ------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------- |
| `apt.status_changed.v1`     | Trámites externos             | Notificaciones, proyecciones, Auditoría        | Proyecto/Trabajo/trámite, fuente `apt`, estado anterior/nuevo, texto original, observación UTC               | consumidor + evento; aviso por Trabajo/trámite/estado/observación |
| `siri.procedure_changed.v1` | Trámites externos             | Notificaciones, proyecciones, Auditoría        | igual, fuente `siri`                                                                                         | consumidor + evento; aviso por Trabajo/trámite/estado/observación |
| `onedrive.item_changed.v1`  | Documentos                    | proyecciones, Auditoría, Notificaciones        | Proyecto/Trabajo/documento, IDs OneDrive, tipo de cambio, versión y observación UTC; sin binario             | consumidor + evento; delta/op. externa conserva su propia clave   |
| `task.overdue.v1`           | Tareas/Programación           | Notificaciones, tablero, Auditoría             | Proyecto/Trabajo/tarea, vencimiento, detección y clave de condición                                          | consumidor + tarea + condición de vencimiento                     |
| `approval.requested.v1`     | Aprobaciones                  | Notificaciones, tablero, Auditoría             | `ResourceScope` organización/Proyecto/Trabajo, solicitud, acción, objetivo y versión revisada, solicitud UTC | consumidor + solicitud + estado                                   |
| `approval.resolved.v1`      | Aprobaciones                  | módulo objetivo, Notificaciones, Auditoría     | `ResourceScope`, solicitud, decisión, objetivo/versión revisada y decisión UTC                               | consumidor + decisión; **no** es clave de ejecución               |
| `notification.requested.v1` | cualquier módulo vía contrato | Notificaciones                                 | `ResourceScope`, solicitud, categoría, severidad, destinatarios, asunto, deduplicación y disponibilidad UTC  | destinatario + categoría + clave de hecho                         |
| `project.archived.v1`       | Proyectos                     | proyecciones y módulos dependientes, Auditoría | Proyecto, `workIds`, solicitud de aprobación y motivo                                                        | consumidor + Proyecto + versión archivada                         |
| `work.type_changed.v1`      | Proyectos                     | Trámites externos, proyecciones, Auditoría     | Proyecto/Trabajo, tipo/estado anterior, tipo nuevo, desactivación histórica, aprobación y motivo             | consumidor + Trabajo + versión posterior                          |

`work.type_changed.v1` formaliza DEC-0101/DEC-0111: si el nuevo tipo no es
`plano_catastro`, Trámites externos detiene monitoreo y conserva fotografías previas
como historia inmutable. No existe evento para escribir o presentar en APT/SIRI.

## Publicación y consumo

1. El caso de uso valida actor, contexto, versión e idempotencia.
2. La transacción guarda el agregado y anexa el evento a `outbox_events`.
3. El publicador reclama una fila de outbox y entrega al menos una vez.
4. El consumidor reserva una clave en `idempotent_consumptions` antes del efecto.
5. Repetir `eventId` devuelve el resultado previo; la misma clave de efecto con carga
   distinta produce conflicto observable.
6. El consumidor registra intento/resultado. Un fallo no revierte el negocio original.
7. La acción aprobada usa una clave idempotente propia y revalida versión/permiso;
   `approval.resolved.v1` nunca ejecuta por simple repetición.

Realtime solo avisa que puede existir un cambio. La UI vuelve a consultar la fuente
transaccional; un mensaje Realtime no se interpreta como verdad de negocio.

## Compatibilidad

- Un campo opcional puede añadirse a `v1` solo si consumidores antiguos lo ignoran.
- Cambiar significado, tipo, obligatoriedad o clave crea un nuevo nombre `.v2`.
- Productores publican versiones en paralelo durante una transición documentada.
- Nunca se reescribe una fila histórica de outbox para convertirla a otra versión.

## Reglas de fallo y datos

- Reintentos usan espera progresiva y cola de fallos observable.
- Fallos parciales de APT/SIRI conservan éxitos y fecha de última consulta exitosa.
- Un aviso interno se persiste antes de intentar Push.
- Los eventos no incluyen `service_role`, tokens, cookies, contraseñas, claves,
  contenido de archivo, `base64` ni rutas privadas innecesarias.
- Los timestamps son UTC. `America/Costa_Rica` se aplica únicamente al presentar.
