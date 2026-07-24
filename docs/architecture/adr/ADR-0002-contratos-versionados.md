# ADR-0002 — Contratos versionados y frontera de transporte

- Estado: aceptada en Fase 2
- Fecha: 2026-07-23
- RF: RF-010, RF-012, RF-015, RF-019
- Criterios: AC-012-01, AC-012-05, AC-019-02, AC-019-03, AC-019-05

## Contexto

Los módulos necesitan intercambiar datos sin compartir filas de PostgreSQL ni
entidades mutables. HTTP, eventos y adaptadores deben coincidir en UUID, UTC,
concurrencia, idempotencia y contexto `Proyecto 1:N Trabajo`. Al mismo tiempo,
`DEC-0103` impide congelar todavía una concesión de alcance por rol.

## Decisión

Crear `packages/contracts` como paquete aislado de esquemas Zod, DTO, eventos y
puertos TypeScript. Publicar un OpenAPI 3.1 mínimo en `docs/api/openapi.yaml`.

- Los contratos JSON usan `camelCase`; persistencia usa `snake_case` mediante un
  adaptador explícito.
- Cada carga declara `contractVersion: 1`; cada evento incluye `.v1` en su nombre.
- Toda operación de Trabajo conserva `projectId + workId` y una actualización usa
  `expectedVersion`.
- Todo comando reintentable incorpora clave idempotente y correlación; HTTP las
  transporta en headers y el adaptador las ensambla antes de Zod.
- Las fechas contractuales son UTC con `Z`. La zona `America/Costa_Rica` pertenece
  exclusivamente a presentación/planificación.
- Errores de API exponen código estable, mensaje seguro en español, correlación y
  violaciones opcionales. No exponen trazas, SQL, secretos ni existencia fuera del
  alcance autorizado.
- `ActorContext` lo deriva el servidor. Roles o contexto no conceden permiso; un
  puerto de autorización y RLS deciden conforme a la política aprobada.
- Los estados internos de Trabajo son códigos opacos de configuración versionada,
  no un enum global. Los cinco tipos de Trabajo y la normalización externa sí usan
  códigos físicos estables.

## Compatibilidad

Un cambio compatible agrega campos opcionales o endpoints y aumenta la versión
menor de OpenAPI. Un cambio incompatible publica carga/evento `v2` en paralelo y
aumenta versión mayor. No se reinterpreta ni reescribe historia `v1`.

## Consecuencias

- Sustituir adaptadores no cambia el dominio ni el contrato de aplicación.
- OpenAPI y Zod requieren una comprobación de correspondencia en cada cambio.
- El adaptador HTTP tiene la responsabilidad explícita de ensamblar path/headers/body.
- La duplicación controlada entre OpenAPI y Zod es visible y verificable; no se
  incorpora un generador o servicio nuevo en Fase 2.
- Fase 3 deberá integrar el paquete al monorepo y fijar versiones exactas en el
  lockfile aprobado; este ADR no crea el walking skeleton.

## Alternativas descartadas

- Exportar tipos de la base: filtra nombres/semántica de persistencia y acopla módulos.
- Generar todo desde OpenAPI en Fase 2: agrega toolchain antes del monorepo y no cubre
  invariantes refinadas de Zod.
- Aceptar rol/alcance desde el cliente: permite suplantar decisiones del servidor y
  presupone `DEC-0103`.
- Fechas locales sin zona: ambiguas y contrarias a RF-019.

## Verificación

`node packages/contracts/scripts/verify-contracts.mjs` comprueba referencias,
parejas OpenAPI/Zod, contexto Proyecto/Trabajo, eventos, límites, ausencia de
binarios/secretos y puertos de solo lectura. Un parser YAML local, si existe, valida
sintaxis sin red.
