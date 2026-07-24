# Contratos API de Fase 2

Estado: **diseño verificable; no desplegado**. Versión OpenAPI: `1.0.0`; versión de
carga: `contractVersion: 1`.

## Alcance

`openapi.yaml` congela un corte mínimo para consultar un Trabajo, solicitar un
cambio de tipo y registrar/decidir una aprobación de Proyecto o Trabajo. No
construye un backend ni el walking skeleton. Los paths de Trabajo contienen
`projectId + workId`; los de Proyecto nunca inventan `workId`. El servidor obtiene
el actor de la sesión y aplica autorización además de RLS.

`DEC-0103` está aprobada e implementada. El contrato deliberadamente no acepta
roles ni alcances enviados por el cliente: el servidor los resuelve desde identidad,
roles y membresías persistidos, y un `403` expresa el resultado de esa política.

## Convenciones

- JSON usa `camelCase`; persistencia usa `snake_case`. El adaptador de persistencia
  realiza el mapeo y nunca exporta filas mutables.
- Los códigos de tipo conservan los códigos físicos aprobados:
  `delimitacion`, `curvas_nivel`, `avaluo`, `croquis` y `plano_catastro`.
- `internalStatus` es un código opaco de `work_state_definitions`, versionado por
  configuración. El contrato no congela un enum global que impediría evolucionar
  catálogos en Fase 4.
- UUID para identificadores; fechas con sufijo `Z`; `America/Costa_Rica` es solo de
  presentación.
- Los comandos reintentables requieren `Idempotency-Key` y `X-Correlation-Id`.
- Los cambios concurrentes envían `expectedVersion`; una versión obsoleta responde
  `409` con `STALE_VERSION`.
- Aprobar y ejecutar son pasos separados. La ejecución revalida versión, permiso e
  idempotencia dentro del módulo propietario.
- Los errores tienen mensaje breve en español, código estable, correlación y campos
  opcionales; nunca incluyen secretos, trazas, SQL ni datos fuera de alcance.
- Un documento contiene solo metadatos, `driveId` y `driveItemId`. El binario no forma
  parte de ningún esquema persistible.
- APT/SIRI se representan como fotografías de solo lectura, con texto original y
  estado normalizado separados.

## Correspondencia OpenAPI ↔ Zod

| OpenAPI                                     | Zod                               | Propósito                                                |
| ------------------------------------------- | --------------------------------- | -------------------------------------------------------- |
| `WorkContext`                               | `WorkContextSchema`               | identidad inseparable Proyecto/Trabajo                   |
| `ResourceScope`                             | `ResourceScopeSchema`             | alcance discriminado organización/Proyecto/Trabajo       |
| `WorkSummary`                               | `WorkSummarySchema`               | estado interno de un Trabajo, sin agregación destructiva |
| `ExternalProcedureSnapshot`                 | `ExternalProcedureSnapshotSchema` | fotografía APT/SIRI de solo lectura                      |
| `DocumentReference`                         | `DocumentReferenceSchema`         | metadatos OneDrive sin binario                           |
| `ChangeWorkTypeCommandBody` + headers/path  | `ChangeWorkTypeCommandSchema`     | solicitud idempotente y concurrente                      |
| `ApprovalTarget`                            | `ApprovalTargetSchema`            | entidad y versión revisadas                              |
| `RequestApprovalCommandBody` + headers/path | `RequestApprovalCommandSchema`    | solicitud contextual                                     |
| `ResolveApprovalCommandBody` + headers/path | `ResolveApprovalCommandSchema`    | decisión separada de ejecución                           |
| `ApprovalRequest`                           | `ApprovalRequestSchema`           | estado de aprobación                                     |
| `ApiError`                                  | `ApiErrorSchema`                  | error uniforme y seguro                                  |

Los headers y parámetros se ensamblan en el adaptador HTTP antes de validar el
comando Zod. Los esquemas Zod son la frontera canónica de ejecución; OpenAPI es su
contrato de transporte equivalente.

## Evolución

- Cambio compatible: agrega campo opcional o endpoint, conserva `contractVersion: 1`
  y aumenta la versión menor de OpenAPI.
- Cambio incompatible: publica esquema/evento `v2` en paralelo y aumenta versión
  mayor; no se reinterpreta una carga `v1`.
- La retirada exige telemetría de consumidores, ventana documentada y ADR/decisión.

## Verificación local

Desde la raíz:

```powershell
pnpm --dir packages/contracts run typecheck
pnpm --dir packages/contracts run verify
```

Si el entorno dispone de PyYAML, puede añadirse validación sintáctica independiente:

```powershell
python -c "import pathlib,yaml; yaml.safe_load(pathlib.Path('docs/api/openapi.yaml').read_text(encoding='utf-8')); print('OpenAPI YAML válido')"
```

Las versiones resueltas están fijadas en `packages/contracts/pnpm-lock.yaml`; no se
usan dependencias productivas ni proveedores externos para esta verificación.
