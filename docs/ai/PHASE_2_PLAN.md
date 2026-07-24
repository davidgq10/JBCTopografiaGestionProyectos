# Plan de Fase 2 — Arquitectura técnica, contratos y datos

Fecha de apertura: **2026-07-23** (`America/Costa_Rica`)  
Estado: **CERRADA; G2 aprobado por el usuario el 2026-07-23**

## Alcance autorizado

Esta fase produce diseño físico verificable, migraciones incrementales, contratos versionados, límites de módulos, eventos/outbox, modelo de seguridad y pruebas RLS. No crea el walking skeleton de Fase 3, módulos funcionales completos ni conexiones reales con OneDrive, APT, SIRI, OpenAI o Push.

RF dominantes: `RF-010`, `RF-012`, `RF-015` y `RF-019`. Criterios de salida inmediatos: `AC-010-01`, `AC-010-02`, `AC-012-01`, `AC-012-03`, `AC-012-05`, `AC-016-08`, `AC-019-01` a `AC-019-06` y `EX-013-01`.

## Decisión material resuelta

`DEC-0103` fue aprobada por el usuario e implementada en la migración 19. R5 detectó dos P1 y dos P2; los cuatro fueron corregidos. La matriz pasó `2561/2561` en reconstrucciones limpia e incremental y la revisión independiente R6 cerró con `0/0/0/0` y GO. El usuario aprobó G2 y el cierre de Fase 2 el 2026-07-23.

## Cortes y propiedad

1. **F2-DATA-01 — modelo físico y migraciones**: diccionario, claves, restricciones, archivo/historia, UTC, concurrencia, outbox y rutas limpia/actualizada.
2. **F2-CONTRACTS-01 — contratos y límites**: puertos, OpenAPI, esquemas compartidos, eventos versionados, grafo de dependencias y ADR.
3. **F2-SEC-01 — seguridad y RLS**: matriz de permisos dependiente de `DEC-0103`, políticas, amenazas, casos positivos/negativos y arnés reproducible.
4. **Integración del orquestador**: coherencia cruzada, trazabilidad, pruebas conjuntas, revisión de secretos/RF-013 y documentación de estado.
5. **F2-REV-R1 — revisión independiente**: solo lectura de la implementación; escritura exclusiva del informe. Si hay P0/P1, corregir y solicitar regresión independiente.

## Verificación de G2

- modelo conceptual y físico coherentes con Proyecto/Contratación `1:N` Trabajos;
- migración limpia y actualización desde la base de Fase 2 reproducibles;
- RLS positiva y negativa por rol y alcance aprobado;
- tablas, vistas y funciones expuestas cubiertas;
- contratos OpenAPI/esquemas/eventos versionados y coherentes;
- dominio aislado de adaptadores y grafo sin ciclos;
- auditoría append-only, outbox e idempotencia representados;
- UTC persistido y `America/Costa_Rica` reservado a presentación;
- binarios ausentes de Supabase y secretos ausentes de cliente/esquema/evidencia;
- `RF-013` con cero superficie activa;
- trazabilidad y evidencia bajo `docs/testing/evidence/F02/`;
- revisión independiente con cero P0/P1.

## Puerta

Las verificaciones se completaron, el paquete G2 fue presentado y el usuario aprobó el cierre. Fase 3 no se inició dentro de esta fase.
