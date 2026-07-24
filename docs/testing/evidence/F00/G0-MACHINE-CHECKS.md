# Evidencia G0 — comprobaciones estructurales R1

Estado histórico: **superada por la revisión R2** después de los hallazgos de la revisión independiente. El resultado estructural R1 se conserva como evidencia; no constituye por sí solo cierre G0.

- Fecha local: 2026-07-22 (`America/Costa_Rica`)
- Alcance: documentos de Fase 0
- Resultado: **PASS**

## Procedimiento reproducible

Con PowerShell se extrajeron las líneas de criterios `AC-###-##` del catálogo y las filas activas de la matriz; se compararon conjuntos, unicidad, estructura de columnas, presencia de fase/prueba/evidencia, RF-013, enlaces Markdown locales y SHA-256 de la especificación. No se modificaron archivos durante la comprobación.

## Resultado observado

```text
CATALOG_ACTIVE=100
TRACE_ACTIVE_ROWS=100
CATALOG_UNIQUE=100
TRACE_UNIQUE=100
MISSING_TRACE=0
EXTRA_TRACE=0
DUPLICATE_CATALOG=0
DUPLICATE_TRACE=0
BAD_TRACE_ROWS=0
ACTIVE_RF013_IDS=0
EXCLUSION_ROWS=1
BROKEN_LOCAL_LINKS=0
SPEC_SHA256=A35DB4A87B7D303A7B016C9DABC7F36257E18DC3205306F37B3D2B2493486C6E
G0_MACHINE_CHECKS=PASS
```

## Cobertura por RF

```text
RF-001=5   RF-002=5   RF-003=4   RF-004=5   RF-005=4
RF-006=5   RF-007=4   RF-008=4   RF-009=4   RF-010=4
RF-011=4   RF-012=5   RF-014=8   RF-015=5   RF-016=8
RF-017=6   RF-018=5   RF-019=6   RF-020=9
TOTAL=100
```

## Interpretación

La comprobación demuestra integridad estructural y exclusión RF-013; no sustituye la revisión humana de suficiencia semántica ni evidencia funcional futura. Esa revisión se realiza mediante `F0-REV-01` antes del dictamen G0.
