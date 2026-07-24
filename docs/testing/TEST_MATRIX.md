# Estrategia y matriz de pruebas

Estado: **estrategia vigente; evidencia UX de Fase 1 aprobada y ejecución funcional posterior pendiente**

## Regla de trazabilidad

Cada criterio activo `AC-RRR-NN` tiene una prueba canónica `T-AC-RRR-NN` en `TRACEABILITY_MATRIX.md`. La prueba puede agrupar varias capas, pero debe producir evidencia inequívoca para ese criterio. `T-EX-013-01` es una comprobación de ausencia y no convierte RF-013 en activo.

Ningún resultado se marca aprobado sin comando/configuración reproducible, versión/entorno, datos de prueba, resultado esperado/real y artefacto. Los defectos críticos o altos impiden cerrar la puerta.

## Capas

| Capa     | Alcance                                                                                   | Herramienta prevista                                            | Evidencia mínima                                    |
| -------- | ----------------------------------------------------------------------------------------- | --------------------------------------------------------------- | --------------------------------------------------- |
| `UT`     | entidades, valores, transiciones, validaciones, dependencias, normalización, idempotencia | Vitest                                                          | reporte y cobertura                                 |
| `IT`     | repositorios, migraciones, funciones, outbox, reintentos, concurrencia                    | Vitest + Supabase local + MSW                                   | reporte, logs redactados y estado DB                |
| `RLS`    | casos positivos/negativos por rol y alcance para toda tabla/vista/función expuesta        | SQL/test harness                                                | matriz rol–operación y resultados deny/allow        |
| `CT`     | Graph, APT, SIRI, OpenAI, Push, OpenAPI y eventos                                         | fixtures + MSW/simuladores                                      | contrato versionado y diff                          |
| `E2E`    | flujo usuario/servidor/proyección                                                         | Playwright                                                      | traza, captura/video solo ante fallo y estado final |
| `A11Y`   | teclado, foco, semántica, lector, reflujo, zoom y contraste                               | axe-core + Playwright + revisión manual                         | reporte sin crítico/serio y checklist               |
| `VIS`    | 360/768/1024/1440/1920, orientación, varios acentos y navegadores                         | Storybook/Playwright + revisión independiente                   | capturas comparables y hallazgos                    |
| `PERF`   | Web Vitals p75, latencias y capacidad RF-016                                              | Lighthouse y herramienta de carga a definir sin servicio pagado | percentiles, dataset y ambiente                     |
| `SEC`    | ASVS L2 aplicable, CSP, secretos, inyección, permisos y abuso                             | análisis estático/dinámico y revisión manual                    | checklist y hallazgos por severidad                 |
| `OPS`    | degradación, cron, respaldo/restauración, alertas, despliegue y rollback                  | simulación/runbooks/pipeline                                    | bitácora con tiempos, hashes y resultado            |
| `STATIC` | límites arquitectónicos, rutas prohibidas, bundle, RF-013 y dependencias                  | ESLint/TypeScript/búsqueda/reglas CI                            | salida reproducible                                 |

## Asignación primaria por fase

| Fase | Pruebas dominantes                                     | Puerta/evidencia                                                             |
| ---: | ------------------------------------------------------ | ---------------------------------------------------------------------------- |
|    0 | integridad documental G0                               | 100/100 criterios con fase/prueba, RF-013 0 activo, contradicciones visibles |
|    1 | prototipo, `A11Y`, `VIS`                               | flujos y navegación aprobados a 360/768/1024/1440                            |
|    2 | `UT`, migración, `RLS`, `STATIC`, amenazas             | G2: migración limpia/actualizada y RLS positiva/negativa                     |
|    3 | walking skeleton `IT+E2E+SEC`, PWA                     | login→lectura→escritura servidor→RLS→auditoría                               |
|    4 | estados, aprobación, auditoría, outbox `UT+IT+RLS+E2E` | G4: doble control, obsolescencia, ejecución única, historia                  |
|    5 | clientes/proyectos `UT+IT+RLS+E2E`                     | cinco tipos manuales; APT/SIRI ausente salvo catastro                        |
|    6 | gestiones/tareas/agenda `UT+IT+E2E+A11Y`               | ciclos, conflictos, concurrencia y agenda móvil                              |
|    7 | Graph primero simulado `CT+IT+RLS+E2E+SEC`             | archivo/restauración, protección, idempotencia; checkpoint escritura real    |
|    8 | centro/Push/PWA `IT+E2E+SEC`                           | degradación al centro y offline sin mutación/datos sensibles                 |
|    9 | APT/SIRI simulados y luego autorizados `CT+IT+OPS+SEC` | lista blanca, horario, frescura, reintentos y puerta legal                   |
|   10 | IA simulada `CT+IT+RLS+SEC+E2E`                        | salida estructurada, evidencia, minimización y decisión humana               |
|   11 | consultas/exportación `RLS+IT+E2E+VIS+PERF`            | exactitud, paginación, auditoría y aprobación OneDrive                       |
|   12 | regresión completa `A11Y+VIS+PERF+SEC+OPS+E2E`         | UAT, restore, degradación, release y rollback demostrados                    |

## E2E obligatorios y criterios vinculados

| E2E | Flujo                                       | Criterios principales           |
| --: | ------------------------------------------- | ------------------------------- |
|  01 | Crear cliente                               | AC-001-01, AC-001-03, AC-010-04 |
|  02 | Crear manualmente cada tipo de proyecto     | AC-002-01, AC-002-04, AC-014-02 |
|  03 | APT/SIRI solo en Plano de catastro          | AC-002-02, AC-014-04            |
|  04 | Crear gestión y tarea                       | AC-003-02, AC-004-01            |
|  05 | Programar persona y recurso                 | AC-005-02                       |
|  06 | Detectar conflicto                          | AC-005-01, AC-005-03            |
|  07 | Resolver aprobación                         | AC-015-01, AC-015-02, AC-015-03 |
|  08 | Crear estructura OneDrive                   | AC-007-01, AC-014-07            |
|  09 | Archivar y restaurar                        | AC-007-01, AC-007-04            |
|  10 | Impedir eliminar documento/carpeta no vacía | AC-001-04, AC-007-04            |
|  11 | Procesar cambio APT/SIRI simulado           | AC-006-03, AC-002-03            |
|  12 | Mostrar notificación                        | AC-009-01, AC-009-04            |
|  13 | Crear y decidir propuesta IA                | AC-008-01, AC-008-02            |
|  14 | Buscar y exportar                           | AC-011-01, AC-011-02, AC-011-04 |
|  15 | Verificar auditoría                         | AC-001-05, AC-015-05, AC-019-04 |
|  16 | Verificar cada rol                          | AC-010-01, AC-010-02            |
|  17 | Flujos críticos a 360 px                    | AC-004-05, AC-020-05, AC-020-08 |
|  18 | Cargar fotografía desde celular             | AC-007-04, AC-020-05            |
|  19 | Cambiar acento sin alterar semántica        | AC-020-06                       |

## Subcasos normativos materiales

Una prueba canónica no puede aprobarse por demostrar solo su título abreviado. Estos subcasos son obligatorios:

- `T-AC-008-03`: llamada exclusivamente desde backend a Responses API; `store:false`; Structured Outputs validado; prompts versionados; modelo y enrutamiento configurables; rutas iniciales de modelos de la especificación configurables; límite mensual y alertas; simulador sin red en automatización.
- `T-AC-010-03`: Microsoft Entra ID mediante Supabase Auth; tenant permitido; usuario preautorizado; usuario de otro tenant denegado; usuario no autorizado denegado; MFA delegado/exigido por Microsoft; revocación impide un acceso nuevo y se audita.
- `T-AC-012-05`: manifiestos y lockfile contienen el stack obligatorio aplicable; infraestructura coincide con las decisiones aprobadas; no aparecen Redux, Zustand, microservicios, microfrontends, Event Sourcing, CQRS completo, Supabase Storage para proyectos, servicios pagados o Premium sin `CHANGE-ID` aprobado; límites 70/85 % quedan instrumentados.
- `T-AC-015-01`: se parametriza con la política aprobada en `DEC-0104`, siempre exige dos personas distintas y rechaza que una sola persona satisfaga ambas participaciones.
- `T-AC-002-05`: al cambiar tipo registra actor, instante UTC, tipo/estado anteriores y comparativo aprobado; al salir de Plano de catastro conserva eventos APT/SIRI históricos sin campos ni monitoreo activos.
- `T-AC-005-04` y `T-AC-009-04`: prueban límites 06:59:59, 07:00:00, 19:59:59 y 20:00:00 en `America/Costa_Rica`; una entrega nocturna queda en cola hasta las 07:00 sin duplicarse y el aviso interno no se pierde.

## Prueba dedicada de exclusión RF-013

`T-EX-013-01` no pertenece al E2E 03. Combina:

1. análisis estático de rutas React, navegación, OpenAPI/Zod, funciones, migraciones, jobs/workers, dependencias y textos de acción para detectar importación/migración/sincronización Excel;
2. inspección del flujo de creación para confirmar que solo existe el asistente manual con vista previa y confirmación;
3. E2E negativo que intenta navegar/invocar rutas canónicas de importación y obtiene ausencia (`404` o contrato inexistente), sin aceptar archivos Excel para crear proyectos;
4. búsqueda de excepciones permitidas: exportar reportes a Excel no se confunde con importar proyectos.

## Casos negativos obligatorios

- Usuario no autorizado y usuario revocado.
- Lectura/escritura fuera del alcance RLS por cada tabla/vista/función.
- Validación cliente omitida pero servidor rechaza.
- Cambio concurrente con versión antigua.
- Dependencia circular y reserva solapada.
- Espera/archivo/rechazo sin motivo.
- Autoaprobación en doble control, aprobación obsoleta y reejecución.
- Documento, carpeta no vacía, raíz, `99-ARCHIVADOS` y carpeta protegida ante intento de papelera.
- Endpoint APT de carga o ruta/método fuera de lista blanca.
- CAPTCHA/MFA/credencial ausente causa bloqueo visible, no evasión.
- OpenAI/Graph/APT/SIRI/Push caídos sin bloquear módulos independientes.
- Prompt/aviso/exportación intentando revelar datos fuera de alcance o secretos.
- PWA offline intentando modificar.
- `T-EX-013-01` confirma por separado ausencia de importador/sincronizador Excel en UI, API, datos y trabajadores.

## Matriz no funcional

| Objetivo       | Datos/condición                                                        | Criterio de pase                                                            |
| -------------- | ---------------------------------------------------------------------- | --------------------------------------------------------------------------- |
| Web Vitals     | p75 en dispositivos/red acordados                                      | LCP ≤2,5 s; INP ≤200 ms; CLS ≤0,1                                           |
| Latencia       | dataset representativo, sin latencia externa en escrituras             | tablero <5 s; consulta p95 <2 s; escritura p95 <3 s; búsqueda <3 s          |
| Capacidad      | 25 concurrentes; 10k proyectos; 100k tareas/gestiones; 500k auditorías | sin corrupción, límites anteriores y paginación servidor                    |
| Accesibilidad  | flujos críticos/estados, 200 % zoom, teclado y lector                  | WCAG 2.2 AA; axe 0 crítico/serio; Lighthouse ≥95                            |
| Compatibilidad | Edge/Chrome recientes, Chrome Android, Safari iPhone                   | flujos críticos y estados sin defecto alto                                  |
| Operación      | fallos externos, respaldo, restauración, rollback                      | módulos independientes; RPO≤24 h; RTO≤8 h laborables; reversión sin pérdida |

## Contrato de evidencia

Cada carpeta `docs/testing/evidence/Fxx/<criterio>/` deberá contener un `README.md` con versión/entorno, precondiciones, datos anonimizados, comando, resultado esperado/real, fecha UTC y Costa Rica, autor/revisor, enlaces a reporte y defectos. No se almacenan tokens, cookies, PII real ni binarios de proyecto.

## Comprobaciones G0

- `T-G0-01`: conjunto de IDs activos en catálogo = conjunto activo en trazabilidad = 100.
- `T-G0-02`: cada fila activa tiene fase, `T-AC-*` y destino de evidencia.
- `T-G0-03`: RF-013 tiene cero `AC-013-*` y exactamente una comprobación `EX-013-01`.
- `T-G0-04`: toda contradicción/supuesto material está visible en decisiones/riesgos; ninguna se resuelve por silencio.
