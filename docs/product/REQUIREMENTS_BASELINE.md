# Línea base de requisitos

Estado: **línea base aprobada en G0 el 2026-07-23**  
Fuente normativa: `Especificacion_Requerimientos_Plataforma_JBC.txt`  
SHA-256 inspeccionado: `A35DB4A87B7D303A7B016C9DABC7F36257E18DC3205306F37B3D2B2493486C6E`  
Fecha de inspección: 2026-07-22 (`America/Costa_Rica`)

La especificación completa y sus anexos prevalecen. Este documento fija los identificadores, estados, propósito y criterios canónicos para impedir deriva durante la implementación. Los criterios detallados están en [ACCEPTANCE_CRITERIA.md](./ACCEPTANCE_CRITERIA.md) y su asignación a diseño, datos, permisos, prueba y evidencia está en [TRACEABILITY_MATRIX.md](./TRACEABILITY_MATRIX.md).

## Control de alcance

| RF     | Nombre canónico                                     | Estado                            | Criterios activos |
| ------ | --------------------------------------------------- | --------------------------------- | ----------------: |
| RF-001 | Gestión de clientes                                 | Aprobado                          |                 5 |
| RF-002 | Gestión de proyectos por tipo                       | Aprobado                          |                 5 |
| RF-003 | Gestión de gestiones                                | Aprobado                          |                 4 |
| RF-004 | Gestión de tareas                                   | Aprobado                          |                 5 |
| RF-005 | Programación                                        | Aprobado                          |                 4 |
| RF-006 | Monitoreo de APT y SIRI                             | Aprobado                          |                 5 |
| RF-007 | Gestión documental en OneDrive                      | Aprobado                          |                 4 |
| RF-008 | Asistente de inteligencia artificial                | Aprobado                          |                 4 |
| RF-009 | Notificaciones                                      | Aprobado                          |                 4 |
| RF-010 | Autenticación, roles y seguridad                    | Aprobado                          |                 4 |
| RF-011 | Tablero, búsqueda y reportes                        | Aprobado                          |                 4 |
| RF-012 | Arquitectura técnica y stack, v2                    | Aprobado                          |                 5 |
| RF-013 | Migración desde Excel                               | **Descartado — no implementar**   |             **0** |
| RF-014 | Catálogos y configuración por tipo, ajustado        | Aprobado                          |                 8 |
| RF-015 | Centro de aprobaciones y auditoría                  | Aprobado                          |                 5 |
| RF-016 | Requisitos no funcionales                           | Aprobado                          |                 8 |
| RF-017 | Respaldo, recuperación y monitoreo                  | Aprobado                          |                 6 |
| RF-018 | Entornos, despliegue y versiones                    | Aprobado                          |                 5 |
| RF-019 | Modelo de datos                                     | Aprobado                          |                 6 |
| RF-020 | Sistema visual, personalización y celular, ajustado | Aprobado                          |                 9 |
|        | **Total**                                           | **19 RF aprobados; 1 descartado** |           **100** |

## Requisitos canónicos

### RF-001 — Gestión de clientes

Registro único y reutilizable para personas físicas o jurídicas, con identificación única cuando exista, contactos y direcciones independientes, prevención de duplicados, archivo con motivo y documentos exclusivamente en OneDrive.

### RF-002 — Gestión de proyectos por tipo

Creación exclusivamente manual. El Proyecto representa la contratación y contiene `1..N` Trabajos independientes de Delimitación, Curvas de nivel, Avalúo, Croquis o Plano de catastro. Los campos y módulos dependen del tipo del Trabajo; APT/SIRI solo aplican al Trabajo Plano de catastro; estados internos y externos conservan historias separadas por Trabajo y el Proyecto ofrece un agregado sin fusionarlos.

### RF-003 — Gestión de gestiones

Organiza `Proyecto → Trabajo → Gestión → Tarea → Programación`, con notas versionadas, responsable, seguimiento y espera motivada. Cierre y archivo conservan consulta e historia.

### RF-004 — Gestión de tareas

Tareas, subtareas, listas, dependencias acíclicas, bloqueos, responsables, fechas, esfuerzo, avance y archivo. Las propuestas de IA requieren decisión humana y los cambios concurrentes no sobrescriben en silencio.

### RF-005 — Programación

Calendario y agenda con múltiples bloques por tarea, personas y recursos, conflictos, reprogramación y recordatorios. UTC en almacenamiento, `America/Costa_Rica` en presentación y alternativa textual accesible.

### RF-006 — Monitoreo de APT y SIRI

Consulta de solo lectura por cada Trabajo de Plano de catastro a las 07:00, 13:00 y 19:00 de Costa Rica, con lista blanca estricta, idempotencia, texto original, estado normalizado, frescura, degradación y puerta legal/técnica. El endpoint de carga queda prohibido.

### RF-007 — Gestión documental en OneDrive

OneDrive es el único almacén de archivos. Supabase solo conserva metadatos e identificadores. Las operaciones tienen vista previa, confirmación/aprobación, idempotencia y auditoría. Documentos y carpetas no vacías se archivan; solo carpetas vacías pueden ir a papelera con doble control.

### RF-008 — Asistente de inteligencia artificial

Responses API desde backend, salidas estructuradas con evidencia, confianza y fecha de corte, `store:false`, modelos y presupuesto configurables. La IA no eleva permisos ni ejecuta acciones sensibles; una persona aprueba o rechaza.

### RF-009 — Notificaciones

Centro persistente y Web Push/Windows, con categorías, severidad, preferencias, varios dispositivos, horario silencioso, enlaces autorizados, datos no sensibles, idempotencia y degradación al aviso interno.

### RF-010 — Autenticación, roles y seguridad

Microsoft Entra ID mediante Supabase Auth, tenant y usuarios autorizados, MFA de Microsoft, roles Administrador/Coordinador/Técnico/Solo lectura, mínimo privilegio, secretos solo en backend, credenciales externas individuales cifradas, RLS y auditoría inmutable.

### RF-011 — Tablero, búsqueda y reportes

Tablero por rol y Control General normalizado; búsqueda paginada con RLS; filtros y vistas guardadas; exportación Excel/CSV/PDF auditada y guardado en OneDrive mediante aprobación.

### RF-012 v2 — Arquitectura técnica y stack

Monolito modular, Clean Architecture, puertos/adaptadores, outbox transaccional y despliegue serverless híbrido. React/TypeScript/Vite/pnpm y el stack aprobado; dominio independiente; módulos sin ciclos; consumidores idempotentes; límites gratuitos medidos al 70/85 %.

### RF-013 — Descartado

No existe importación, migración ni sincronización de proyectos desde `Reporte_ListadoPlanos.xlsx`. Se conserva el identificador únicamente como exclusión verificable y tiene cero criterios activos.

### RF-014 ajustado — Catálogos y configuración por tipo

Catálogos versionados, archivables y con códigos invariables para tipos, estados, prioridades, gestiones, tareas, documentos, esperas, archivo/cancelación, especialidades, recursos y aprobaciones. Cada Trabajo conserva su versión de configuración; actualizarla requiere comparativo y aprobación sin alterar los demás Trabajos de la Contratación.

### RF-015 — Centro de aprobaciones y auditoría

Solicitudes versionadas y revalidadas, decisión separada de ejecución, doble control por dos personas, ejecución máxima una vez y rechazo/archivo motivado. Auditoría de solo adición, correlacionada y sin secretos.

### RF-016 — Requisitos no funcionales

Objetivos medibles de Web Vitals, latencia, capacidad, disponibilidad/degradación, compatibilidad, WCAG 2.2 AA, operación PWA sin edición offline, concurrencia explícita, OWASP ASVS 5.0 L2 aplicable, cobertura y pruebas multidimensionales.

### RF-017 — Respaldo, recuperación y monitoreo

Respaldo lógico diario cifrado e íntegro a las 22:00 de Costa Rica en OneDrive administrativo; retención; restauración trimestral aislada; RPO 24 h/RTO 8 h laborables; salud, alertas, logs e incidentes sin secretos.

### RF-018 — Entornos, despliegue y versiones

Entornos y credenciales separados, datos reales anonimizados fuera de producción, rama principal protegida, pipeline completo, gate de producción, SemVer, feature flags, versión visible, reversión no destructiva y documentación de entrega.

### RF-019 — Modelo de datos

Entidades y relaciones normalizadas, incluida `Proyecto 1:N Trabajo`, UUID, fechas UTC, versión, archivo, motivo y correlación; sin cascadas de historia; datos externos original/normalizado separados; RLS, índices y búsqueda autorizada; binarios fuera de base.

### RF-020 ajustado — Sistema visual, personalización y celular

Interfaz española serena y minimalista, tokens centralizados, whitespace antes que bordes, sin tarjetas anidadas, una acción primaria por zona, acento accesible por usuario sin alterar semántica, operación completa desde 360 px y WCAG 2.2 AA verificada. Contexto vivo es un pilar ancho con once alcances y enlaces operativos; el compositor integrado usa un único `Publicar`; la navegación lateral puede compactarse sin perder nombres accesibles.

## Invariantes de control

1. Creación manual de proyectos y ausencia demostrable de RF-013.
2. APT/SIRI solo para cada Trabajo de Plano de catastro, solo lectura y con estado separado.
3. OneDrive único almacén de binarios; documentos sin eliminación física.
4. IA con evidencia y decisión humana.
5. Validación de servidor, RLS, secretos protegidos y auditoría append-only.
6. UTC en persistencia y `America/Costa_Rica` en presentación.
7. Aprobación para acciones sensibles y control de versión antes de ejecutar.
8. Español, accesibilidad AA y flujos completos a 360 px.
9. Proyecto es la contratación y contiene uno o más Trabajos con tipo, estado, responsable y operación independientes; toda referencia operativa conserva Proyecto + Trabajo y el agregado nunca fusiona esos atributos.

## Control de cambios

Cualquier modificación requiere un `CHANGE-ID` con origen, RF afectados, alternativas, impactos funcional/técnico/datos/seguridad/costo-plazo, migración, reversión y aprobación. Arquitectura se registra mediante ADR. Las decisiones sustituidas se marcan; no se borran.
