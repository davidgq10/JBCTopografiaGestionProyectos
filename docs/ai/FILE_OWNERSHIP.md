# Propiedad exclusiva de archivos

Estado: **Fase 3 integrada por el orquestador; revisión independiente R3 NO-GO con un P1 técnico abierto**

La propiedad es temporal por tarea. Nadie modifica una ruta fuera de su asignación; un revisor es siempre de solo lectura. El orquestador integra en secuencia y actualiza este registro antes de cada delegación.

## Propiedad actual — Fase 1

| Propietario                            | Rutas de escritura                                                                                                | Rutas prohibidas                                  | Estado                                                                        |
| -------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | ------------------------------------------------- | ----------------------------------------------------------------------------- |
| Orquestador `/root`                    | `docs/ai/**`, `prototypes/fase1/**`, `docs/product/**`, `docs/testing/evidence/F01/**` y revisión de `docs/ux/**` | `docs/architecture/reviews/F1/**`; especificación | Fase 1 integrada, aprobada y cerrada; sin tarea activa de Fase 2              |
| Subagente `F1-PT-01`                   | ninguna                                                                                                           | todo el repositorio para escritura                | completado; requisito Proyecto/Contratación `1:N` Trabajos declarado CONFORME |
| Autor UX `F1-UX-01`                    | ninguna                                                                                                           | todo el repositorio para escritura                | completado; 8 documentos transferidos al orquestador                          |
| Revisores arquitectura `F1-ARCH-01/R2` | ninguna                                                                                                           | todo el repositorio para escritura                | R1 y R2 completados; R2 emitió GO con 0 P0/P1/P2/P3 abiertos                  |
| Revisor `F0-REV-01/02`                 | ninguna                                                                                                           | todo el repositorio para escritura                | completado; R1 y R2 de solo lectura                                           |

La especificación permanece inmutable. Fase 1 puede crear únicamente documentación UX y un prototipo local con datos ficticios; no crea módulos productivos, migraciones ni integraciones.

## Propiedad activa — Fase 2

| Propietario         | Rutas de escritura exclusivas                                                                                        | Rutas prohibidas                   | Estado                                                                            |
| ------------------- | -------------------------------------------------------------------------------------------------------------------- | ---------------------------------- | --------------------------------------------------------------------------------- |
| Orquestador `/root` | `docs/ai/**`, `docs/product/**`, `docs/testing/evidence/F02/**` y archivos compartidos solo después de transferencia | especificación; Fase 1             | integración completada; G2 aprobado y Fase 2 cerrada                              |
| `F2-DATA-01`        | ninguna; rutas transferidas al orquestador                                                                           | todo el repositorio para escritura | completado con validación estática; integración PostgreSQL posterior PASS         |
| `F2-CONTRACTS-01`   | ninguna; rutas transferidas al orquestador                                                                           | todo el repositorio para escritura | completado; typecheck y OpenAPI posterior PASS                                    |
| `F2-SEC-01`         | ninguna; rutas transferidas al orquestador                                                                           | todo el repositorio para escritura | migración 19 corregida y matriz funcional 2561/2561 completadas                   |
| `F2-REV-R1`         | ninguna                                                                                                              | todo el repositorio para escritura | completado; NO-GO con 4 P1, 4 P2 y 1 P3; no corrigió implementación               |
| `F2-REV-R2`         | ninguna                                                                                                              | todo el repositorio para escritura | completado; NO-GO con 2 P1, 2 P2 y 1 P3 sobre corte anterior                      |
| `F2-REV-R3`         | ninguna                                                                                                              | todo el repositorio para escritura | completado; NO-GO con 2 P1, 3 P2 y 1 P3; no corrigió implementación               |
| `F2-REV-R4`         | ninguna; informe transferido al orquestador                                                                          | todo el repositorio para escritura | completado; GO técnico pre-`DEC-0103`, 0 P0/P1/P2/P3 y seis hallazgos R3 cerrados |
| `F2-REV-R5`         | ninguna; informe cerrado                                                                                             | todo el repositorio para escritura | completado; NO-GO con 2 P1 y 2 P2; no corrigió implementación                     |
| `F2-REV-R6`         | ninguna; informe cerrado y transferido al orquestador                                                                | todo el repositorio para escritura | completado; GO con 0 P0/P1/P2/P3; no corrigió implementación                      |

Las rutas no existentes se crean únicamente dentro de la propiedad indicada. La integración reasigna archivos al orquestador solo después del cierre explícito de cada tarea.

## Propiedad activa — Fase 3

| Propietario              | Rutas de escritura exclusivas                                                     | Rutas prohibidas                                    | Estado                                                         |
| ------------------------ | --------------------------------------------------------------------------------- | --------------------------------------------------- | -------------------------------------------------------------- |
| Orquestador `/root`      | código F3, configuración del workspace, migración 20, pruebas y documentación F03 | especificación; proveedores/secretos no autorizados | implementación integrada; conserva propiedad para correcciones |
| Revisor independiente F3 | ninguna                                                                           | todo el repositorio para escritura                  | R1/R2/R3 solo lectura; R3 NO-GO 0/1/1/0                        |

## Asignación propuesta por raíz futura

| Rol/tarea              | Propiedad exclusiva prevista                                                                   | Nunca modificar sin reasignación                           |
| ---------------------- | ---------------------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| Orquestador/integrador | archivos raíz, workspace/config compartida, `docs/product/**`, `docs/ai/**`                    | archivos con tarea activa de otro autor                    |
| UX/UI                  | `docs/ux/**`                                                                                   | código, migraciones, trazabilidad/decisiones               |
| Front-end              | `apps/web/**`                                                                                  | migraciones, workers, dominio de otros módulos             |
| Arquitectura/datos     | `docs/architecture/**`, `supabase/migrations/**` cuando se asigne                              | UI, workers y migraciones de otro autor                    |
| Backend/seguridad      | `packages/domain/**`, `packages/application/**`, `supabase/functions/**` por subruta explícita | UI y adaptadores no asignados                              |
| Contratos              | `packages/contracts/**`, `docs/api/**`                                                         | implementaciones/migraciones                               |
| Integraciones          | `workers/monitoring/**` y subrutas de adaptador explícitas                                     | dominio, UI, secretos y funciones compartidas no asignadas |
| Calidad                | `packages/testing/**`, suites/rutas de pruebas explícitas, `docs/testing/**`                   | implementación durante revisión independiente              |
| Operaciones            | documentación `docs/operations/**` y configuración CI/deploy explícita                         | lógica de negocio                                          |

## Zonas de alto conflicto

- `package.json`, `pnpm-lock.yaml`, `pnpm-workspace.yaml`, configuraciones TS/ESLint/Prettier y pipeline: solo integrador o una tarea exclusiva.
- `theme.ts`, rutas y AppShell: un único propietario durante cada corte UX/front-end.
- Migraciones: un solo autor activo y numeración reservada antes de delegar.
- Contratos/eventos: se congelan antes de paralelizar consumidores; cambios pasan por integrador.
- `CURRENT_STATUS`, `DECISIONS_LOG`, `RISKS` y trazabilidad: solo orquestador, salvo reasignación explícita.
- Funciones compartidas de autorización, auditoría, outbox y aprobaciones: se ejecutan en secuencia.

## Protocolo de transferencia

1. Cerrar o pausar formalmente al propietario anterior.
2. Registrar tarea, rutas exactas, commit/base o hash y dependencias.
3. Verificar árbol de trabajo y cambios del usuario.
4. Entregar contrato de salida, diff, pruebas y riesgos.
5. Integrador revisa, corrige conflictos y retoma propiedad.
