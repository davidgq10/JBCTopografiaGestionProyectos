# Reporte de Fase 0

    FASE: 0 — Inspección y línea base
    RESULTADO: G0 aprobado por el usuario el 2026-07-23; Fase 1 autorizada
    RF CUBIERTOS: RF-001 a RF-012 y RF-014 a RF-020 trazados; RF-013 descartado con prueba de ausencia

## 1. Inventario del repositorio inicial

- Un archivo: `Especificacion_Requerimientos_Plataforma_JBC.txt`, 60.386 bytes, 1.639 líneas.
- SHA-256: `A35DB4A87B7D303A7B016C9DABC7F36257E18DC3205306F37B3D2B2493486C6E`.
- No existía `AGENTS.md`; se añadió una propuesta alineada con la especificación.
- No existe repositorio Git válido en esta carpeta, por lo que no hay rama, commits ni cambios Git que preservar. Durante la orquestación aparecieron directorios ocultos vacíos `.git`/`.agents`, pero `git rev-parse` sigue fallando. La especificación no se modificó.
- No había código, dependencias, migraciones, pruebas, CI, configuración ni secretos.

## 2. Matriz completa

- Catálogo: [ACCEPTANCE_CRITERIA.md](../product/ACCEPTANCE_CRITERIA.md).
- Asignación RF→criterio→módulo→datos→permisos→interfaz→fase→prueba→evidencia: [TRACEABILITY_MATRIX.md](../product/TRACEABILITY_MATRIX.md).
- Pruebas y E2E obligatorios: [TEST_MATRIX.md](../testing/TEST_MATRIX.md).
- Meta G0: 100 criterios activos, 100 con fase y prueba; RF-013 0 activo y `EX-013-01` de ausencia.

## 3. Mapa de módulos y dependencias

- Visión/despliegue: [SYSTEM_OVERVIEW.md](../architecture/SYSTEM_OVERVIEW.md).
- Propiedad, contratos y grafo: [MODULE_BOUNDARIES.md](../architecture/MODULE_BOUNDARIES.md).
- Datos, eventos y amenazas: [DATA_MODEL.md](../architecture/DATA_MODEL.md), [EVENT_CATALOG.md](../architecture/EVENT_CATALOG.md), [SECURITY_MODEL.md](../architecture/SECURITY_MODEL.md).
- Arquitectura registrada: [ADR-0001](../architecture/adr/ADR-0001-arquitectura-base.md).

## 4. Riesgos, contradicciones y supuestos

- Registro completo: [RISKS.md](./RISKS.md).
- Decisiones y supuestos: [DECISIONS_LOG.md](./DECISIONS_LOG.md).
- Contradicciones visibles: conservación histórica APT/SIRI tras cambio de tipo y semántica del horario silencioso.
- Ambigüedades materiales: alcance exacto por rol y nivel de aprobación por acción.

## 5. Secuencia

[IMPLEMENTATION_SEQUENCE.md](./IMPLEMENTATION_SEQUENCE.md) conserva Fases 0–12, camino crítico, paralelismo seguro y puertas.

## 6. Tareas candidatas para subagentes

[SUBAGENT_TASKS.md](./SUBAGENT_TASKS.md) contiene paquetes mínimos para revisión G0, UX, arquitectura, datos/RLS, contratos, OneDrive, APT/SIRI y lanzamiento.

## 7. Propiedad exclusiva

[FILE_OWNERSHIP.md](./FILE_OWNERSHIP.md) define propietario actual, raíces futuras, zonas de conflicto y transferencia.

## 8. Checkpoints y aprobaciones

[CHECKPOINTS.md](./CHECKPOINTS.md) define G0, UX, G2, G3, G4, Graph, APT, worker, IA, exportación, UAT y producción.

## Demostración y pruebas F0

- R1 estructural: 100/100 IDs, 0 faltantes/extras/duplicados, 0 `AC-013-*`, 1 `EX-013-01`, 0 enlaces rotos y hash correcto: [evidencia R1](../testing/evidence/F00/G0-MACHINE-CHECKS.md).
- Revisión independiente R1: detectó tres P1 y dos P2; dictamen inicial “no pasa”: [hallazgos e integración](../testing/evidence/F00/G0-INDEPENDENT-REVIEW-R1.md).
- Correcciones: DAG modular y ADR; subcasos normativos IA/Identidad/stack; prueba RF-013 dedicada; doble control sin supuesto; estado actualizado.
- R2 automática: 100/100, subcasos presentes, RF-013 separado, 0 ciclos sólidos, 0 enlaces rotos, hash correcto y 0 archivos funcionales: [evidencia R2](../testing/evidence/F00/G0-MACHINE-CHECKS-R2.md).
- Revisión independiente R2: 0 hallazgos P0–P3; 100/100, RF-013 excluido, 0 ciclos y 0 enlaces rotos; dictamen “pasa para presentación”: [evidencia R2 independiente](../testing/evidence/F00/G0-INDEPENDENT-REVIEW-R2.md).

## Aprobación recibida

El usuario aprobó G0 y `AGENTS.md` el 2026-07-23. También resolvió DEC-0101 (historial de cambio de tipo con usuario, marca de tiempo y estado anterior; APT/SIRI histórico inactivo fuera de catastro) y DEC-0102 (entrega 07:00–20:00, silencio 20:00–07:00). La evidencia se conserva en `docs/testing/evidence/F00/G0-USER-APPROVAL-2026-07-23.md`.
