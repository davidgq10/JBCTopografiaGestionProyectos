# Secuencia de implementación

Estado: **aprobado en G0; G0/CP-UX/G2/G3 cerrados; Fase 3 cerrada; cada checkpoint requiere cierre explícito**

| Fase | Corte mínimo y RF dominantes                                                                                                           | Dependencias                      | Puerta/checkpoint                                                                                |
| ---: | -------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------- | ------------------------------------------------------------------------------------------------ |
|    0 | línea base, trazabilidad, módulos, amenazas, pruebas, riesgos y gobernanza; RF-012/016/018/019 y todos trazados                        | especificación completa           | G0: 100 % criterio→fase→prueba; RF-013 0 activo; contradicciones visibles; aprobación usuario    |
|    1 | arquitectura de información, flujos, tokens, componentes y prototipo ficticio 360→1440; RF-020 y UX de todos                           | G0                                | aprobación de navegación, lenguaje visual, móvil y pantallas representativas                     |
|    2 | contratos, modelo físico, migraciones, RLS, puertos, OpenAPI/Zod, eventos, amenazas y ADR; RF-010/012/015/019                          | UX/flujo aprobado                 | G2: revisión independiente, migración limpia/actualizada y RLS positiva/negativa por rol/alcance |
|    3 | monorepo, React/Mantine, AppShell/PWA, Supabase, Entra, tema/acento, errores, CI, versión y walking skeleton                           | G2 y decisiones identidad/hosting | flujo login→lectura→escritura servidor→RLS→auditoría demostrado                                  |
|    4 | catálogos/versiones, estados, aprobaciones/doble control, auditoría, outbox, concurrencia y aviso interno; RF-014/015                  | skeleton estable                  | G4: negativos de permiso, ejecución única, aprobación obsoleta, historia e idempotencia          |
|    5 | clientes, contactos, direcciones, proyectos, inmuebles, participantes, creación manual, tipo/estado/archivo; RF-001/002                | G4                                | cinco tipos probados; APT/SIRI solo catastro; sin importación Excel                              |
|    6 | gestiones, notas, tareas, listas, dependencias, programación, personas/recursos, conflictos y agenda móvil; RF-003/004/005             | proyectos/configuración           | ciclos, concurrencia, archivo y alternativa accesible al drag/calendar                           |
|    7 | OneDrive con simulador, vínculo, plantillas, carga, archivo/restauración, papelera vacía, protección, delta; RF-007                    | aprobaciones/auditoría            | aprobación explícita antes de escritura Graph real                                               |
|    8 | centro persistente, preferencias, Push/PWA, varios dispositivos, enlaces y offline; RF-009                                             | identidad/outbox                  | Push degradable y PWA sin mutación/caché sensible offline                                        |
|    9 | fixtures/parser/historia/comparación/cron/consulta manual APT/SIRI, notificación y workers; RF-006                                     | proyectos/notificaciones          | puerta legal/técnica antes de real; decisión Cloud Run/fallback Windows                          |
|   10 | puerto IA, salidas estructuradas, resúmenes/propuestas, evidencia, decisión, presupuesto; RF-008                                       | permisos/aprobaciones             | modelos/presupuesto/datos aprobados; simuladores pasan antes de API real                         |
|   11 | tablero por rol, Control General, búsqueda RLS, vistas, exportaciones y guardado aprobado; RF-011                                      | módulos/proyecciones              | exactitud, rendimiento, auditoría y revisión visual sin saturación                               |
|   12 | regresión, WCAG/ASVS, rendimiento/capacidad, compatibilidad, fallos, respaldo/restore, monitoreo, release/rollback/UAT; RF-016/017/018 | todas las anteriores              | candidato congelado, 0 críticos/altos, UAT y aprobación de producción                            |

## Camino crítico

1. G0 y decisiones de alcance/permiso.
2. UX aprobada y modelo de autorización.
3. Datos/RLS/contratos antes del skeleton conectado.
4. Capacidades transversales antes de módulos de negocio.
5. Clientes/proyectos antes de trabajo e integraciones.
6. Aprobaciones/auditoría antes de cualquier escritura OneDrive o propuesta IA aplicable.
7. Simuladores antes de proveedores reales.
8. Observabilidad/respaldo/rollback antes de producción.

## Paralelismo seguro

- Fase 1: UX (`docs/ux/**`) y arquitectura preliminar (`docs/architecture/**`) pueden avanzar en paralelo con contratos de navegación compartidos, pero un único integrador modifica la matriz.
- Fase 2: modelo/migraciones y contratos pueden separarse si ninguna ruta se solapa; seguridad revisa sin editar.
- Fases funcionales: UI con MSW y dominio/aplicación pueden avanzar sobre contratos congelados; migraciones pertenecen a un solo autor.
- Integraciones Graph/APT/SIRI/OpenAI/Push no se paralelizan sobre funciones o secretos compartidos sin partición de rutas.
- Revisión independiente siempre es posterior al corte verificable y es de solo lectura.

## Política de cambio

Si una decisión altera alcance, datos, seguridad, costo, permiso o UX, se detiene solo el frente afectado, se registra `CHANGE-ID` y se solicita aprobación. Las tareas independientes continúan si no comprometen la decisión.
