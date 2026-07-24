# Reporte final de Fase 2 — G2 aprobado

Actualizado: **2026-07-23** (`America/Costa_Rica`)

| Campo                  | Estado                                                       |
| ---------------------- | ------------------------------------------------------------ |
| Fase                   | 2 — arquitectura técnica, contratos y datos                  |
| Estado técnico         | **COMPLETO**                                                 |
| Estado de gobernanza   | **FASE 2 CERRADA; G2 aprobado por el usuario el 2026-07-23** |
| Dictamen independiente | R6 GO; 0 P0/P1/P2/P3                                         |
| Fase 3                 | no iniciada en este cierre                                   |

## Resultado

- Modelo físico de 57 tablas, 227 claves foráneas, 155 índices y 130 triggers.
- Diecinueve migraciones hacia adelante; rutas limpia e incremental equivalentes.
- `DEC-0103` implementada con cuatro roles: Administrador, Coordinador, Técnico y Solo lectura.
- Técnico limitado a Proyectos asignados directamente, con todos sus Trabajos y escritura operativa dentro de ese alcance.
- Solo lectura con consulta global de todos los Proyectos y sus Trabajos, sin escrituras de negocio.
- 136 políticas sobre 57/57 tablas con RLS habilitada y forzada.
- Contratos TypeScript/Zod, OpenAPI, eventos y límites de módulos versionados.
- Invariantes Proyecto `1:N` Trabajos, APT/SIRI, historia, aprobaciones, concurrencia, archivo y OneDrive representados físicamente.
- Supabase sin binarios de proyecto; RF-013 sin superficie activa.

## Evidencia reproducida

| Control                            | Resultado                                                                                |
| ---------------------------------- | ---------------------------------------------------------------------------------------- |
| Matriz RLS limpia                  | `2561/2561 PASS`                                                                         |
| Matriz RLS incremental             | `2561/2561 PASS`                                                                         |
| Puerta `DEC-0103=0`                | bloqueo fail-closed esperado                                                             |
| Paridad de esquema                 | SHA-256 `761f627b03a648b03feb95136753a3e2209234c28ac2a1dae62d2d722a8b035c`; 293930 bytes |
| Migración 19                       | SHA-256 `023A11CAD420346BCB20E6462B5B0E07C42813D3FF38E73A1EB40DA60438BC16`               |
| Invariantes                        | PASS                                                                                     |
| Matriz negativa APT/SIRI           | 16/16 PASS                                                                               |
| Cambio de tipo ligado a aprobación | PASS                                                                                     |
| Carrera de notas                   | PASS; un ganador y un conflicto `23505`                                                  |
| TypeScript/contratos/eventos       | PASS; 92 referencias OpenAPI, 9 eventos, DAG 15/15                                       |
| Revisión independiente R6          | GO; 0 P0/P1/P2/P3                                                                        |

Evidencia canónica: [RLS funcional](../testing/evidence/F02/F02-RLS-FUNCTIONAL-2026-07-23.md), [integración](../testing/evidence/F02/F02-INTEGRATION-CHECKS-2026-07-23.md), [revisión R6](../architecture/reviews/F2/F2-INDEPENDENT-REVIEW-R6-2026-07-23.md), [modelo de seguridad](../architecture/SECURITY_MODEL.md) y [matriz de permisos](../architecture/PERMISSION_MATRIX.md).

## Cierre de R5

R5 registró dos P1 y dos P2. R6 confirmó el cierre de los cuatro:

- el cliente no actualiza directamente solicitudes de aprobación;
- el cliente no modifica el ciclo de vida ni los resultados de operaciones OneDrive y el alta inicial fija actor/estado/resultado;
- el perfil propio y las notificaciones solo permiten las columnas personales autorizadas;
- las 17 funciones privilegiadas pertenecen a `app_rls_owner`, rol `NOLOGIN` y no superusuario.

## Aprobación de G2

El usuario declaró **“Aprobado cierre fase 2”**. G2 y Fase 2 quedan cerrados; la evidencia formal está en [F02-G2-USER-APPROVAL-2026-07-23.md](../testing/evidence/F02/F02-G2-USER-APPROVAL-2026-07-23.md). Fase 3 no se inició en este cierre.
