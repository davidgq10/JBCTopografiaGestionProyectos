# Evidencia G0 — revisión independiente R1

- Revisor: subagente independiente `F0-REV-01`
- Modo: solo lectura; ningún archivo modificado
- Alcance: especificación y anexos, `AGENTS.md` y 21 archivos entonces existentes bajo `docs/`
- Dictamen: **NO PASA** antes de correcciones

## Verificaciones que pasaron

- Especificación leída completa y hash correcto.
- Ocho entregables de Fase 0 presentes.
- 100 criterios activos únicos en catálogo/matriz; cero `AC-013-*`; una `EX-013-01`; cero enlaces rotos.
- Arquitectura general e invariantes alineados.

## Hallazgos

| Prioridad | Hallazgo                                                                                                                      | Corrección integrada                                                                                            |
| --------- | ----------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| P1        | Ciclos Identidad↔Administración y Administración↔Aprobaciones; tabla/grafo inconsistentes                                     | dependencias convertidas en DAG; contratos neutrales y composition root; grafo/ADR/prueba estática actualizados |
| P1        | Responses API/`store:false`/modelos-presupuesto, Entra/Supabase/tenant/MFA y stack obligatorio no tenían subcasos inequívocos | criterios, matriz y subcasos `T-AC-008-03`, `T-AC-010-03`, `T-AC-012-05` ampliados                              |
| P1        | E2E 03 se usaba indebidamente como evidencia RF-013                                                                           | vínculo retirado; `T-EX-013-01` dedicado a UI/API/datos/workers y diferencia exportación/importación            |
| P2        | Se asumían dos decisores para doble control                                                                                   | criterio/matriz parametrizados; `DEC-0104` explicita solicitante+aprobador versus dos aprobadores               |
| P2        | Estado decía que la validación automática seguía pendiente                                                                    | `CURRENT_STATUS` y reporte actualizados tras R2                                                                 |

## Resultado de integración

Todos los P1 y P2 se corrigieron sin añadir código funcional. Las comprobaciones posteriores están en [G0-MACHINE-CHECKS-R2.md](./G0-MACHINE-CHECKS-R2.md). El cierre requiere reevaluación independiente R2.
