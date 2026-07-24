# Tareas candidatas para subagentes

Estado: **candidatas; no autorizan por sí mismas iniciar una fase ni modificar archivos**

Cada encargo efectivo se reduce al mínimo de contexto y usa el contrato de salida del Anexo A. Máximo tres subagentes activos además del orquestador, profundidad dos y sin creación de subagentes salvo autorización.

## F0-REV-01 — Revisión independiente G0

    TASK-ID: F0-REV-01
    ROL: Calidad y lanzamiento — revisor independiente
    OBJETIVO: Auditar integridad de la Fase 0 y puerta G0 sin modificar archivos.
    REQUISITOS Y CRITERIOS: Todos; 100 criterios activos; RF-013 cero activo; entregables 1–8 de Fase 0.
    INVARIANTES: Fuente completa; no código funcional; no resolver ambigüedades por supuesto.
    CONTEXTO MÍNIMO: Especificación, AGENTS.md propuesto, docs/product, docs/architecture, docs/testing y docs/ai.
    ENTRADAS: Árbol de archivos y resultados de validación G0.
    DEPENDENCIAS: Artefactos de Fase 0 listos.
    RUTAS PERMITIDAS: Lectura de todo el repositorio.
    RUTAS PROHIBIDAS: Toda escritura.
    DECISIONES EXISTENTES: Arquitectura RF-012; RF-013 descartado.
    PRUEBAS OBLIGATORIAS: Conteo/conjuntos de IDs, filas incompletas, enlaces, contradicciones, cobertura de entregables.
    COMANDOS DE VERIFICACIÓN: rg/Get-Content y validaciones no mutantes.
    RIESGOS: Falso positivo por criterios consolidados o rutas futuras.
    FORMATO DE ENTREGA: Hallazgos P0–P3, conteos, dictamen G0 y pendientes.

## F1-UX-01 — UX móvil y arquitectura de información

    TASK-ID: F1-UX-01
    ROL: UX/UI
    OBJETIVO: Diseñar flujos, navegación y estados mobile-first para todos los módulos.
    REQUISITOS Y CRITERIOS: RF-020; interfaces de AC-001 a AC-015; AC-016-06/07; criterios E2E móviles.
    INVARIANTES: Español, 360 px, WCAG AA, whitespace, sin tarjetas anidadas, una primaria/zona, APT/SIRI solo catastro.
    CONTEXTO MÍNIMO: Baseline, criterios, trazabilidad y decisiones UX aprobadas en G0.
    ENTRADAS: Mapa modular y matriz.
    DEPENDENCIAS: G0 aprobado; horario silencioso y conflicto de cambio de tipo aclarados si afectan flujos.
    RUTAS PERMITIDAS: docs/ux/** exclusivamente.
    RUTAS PROHIBIDAS: apps/**, packages/**, supabase/**, docs/product/**, docs/ai/**.
    DECISIONES EXISTENTES: RF-020 y stack Mantine.
    PRUEBAS OBLIGATORIAS: revisión 360/768/1024/1440, teclado, tacto, contraste y todos los estados.
    COMANDOS DE VERIFICACIÓN: validadores Markdown/enlaces y artefactos de prototipo acordados.
    RIESGOS: saturación, controles solo hover/drag, ocultar riesgo por minimalismo.
    FORMATO DE ENTREGA: contrato estándar con capturas y criterios cubiertos.

## F1-ARCH-01 — Revisión de arquitectura de información y límites

    TASK-ID: F1-ARCH-01
    ROL: Arquitectura y datos
    OBJETIVO: Validar que los flujos UX respeten módulos, propiedad, estados y datos sin diseñar esquema físico aún.
    REQUISITOS Y CRITERIOS: RF-002/012/014/015/019 y dependencias de RF-020.
    INVARIANTES: Monolito modular, dominio aislado, historia sin borrado, manual, OneDrive único binario.
    CONTEXTO MÍNIMO: docs/architecture y borradores docs/ux.
    ENTRADAS: Flujos definidos por F1-UX-01.
    DEPENDENCIAS: G0 aprobado.
    RUTAS PERMITIDAS: docs/architecture/reviews/F1/**.
    RUTAS PROHIBIDAS: docs/ux/** y código.
    DECISIONES EXISTENTES: ADR-0001.
    PRUEBAS OBLIGATORIAS: matriz flujo→módulo→propietario y búsqueda de ciclos/estado mezclado.
    COMANDOS DE VERIFICACIÓN: revisión documental no mutante fuera de su ruta.
    RIESGOS: convertir consultas en nuevo propietario o acoplar UX a proveedor.
    FORMATO DE ENTREGA: hallazgos priorizados y recomendaciones para integrador.

## F2-DATA-01 — Modelo físico, migraciones y RLS

    TASK-ID: F2-DATA-01
    ROL: Arquitectura y datos / backend y seguridad
    OBJETIVO: Implementar esquema incremental, restricciones, índices y RLS verificable.
    REQUISITOS Y CRITERIOS: RF-010, RF-014, RF-015, RF-019; AC-010-*, AC-019-*.
    INVARIANTES: RLS total, UTC, UUID, sin cascadas de historia, sin binarios/secretos.
    CONTEXTO MÍNIMO: modelo conceptual, matriz rol–alcance aprobada, ADR y contratos.
    ENTRADAS: Decisiones G0/G1 y nombres canónicos.
    DEPENDENCIAS: Fase 1 aprobada; decisiones de alcance y credenciales.
    RUTAS PERMITIDAS: supabase/migrations/**, pruebas RLS asignadas, docs/architecture/DATA_MODEL.md.
    RUTAS PROHIBIDAS: apps/web/**, workers/**, otros docs de propiedad del orquestador.
    DECISIONES EXISTENTES: ADR-0001 y políticas aprobadas.
    PRUEBAS OBLIGATORIAS: migración limpia/actualizada, allow/deny por rol/alcance, cascadas, append-only.
    COMANDOS DE VERIFICACIÓN: comandos Supabase/pnpm fijados en Fase 2.
    RIESGOS: fuga RLS, función definer, migración irreversible.
    FORMATO DE ENTREGA: contrato estándar con inventario de migraciones y evidencia.

## F2-CONTRACT-01 — Contratos, eventos y puertos

    TASK-ID: F2-CONTRACT-01
    ROL: Arquitectura y datos
    OBJETIVO: Versionar OpenAPI, Zod compartido, eventos y puertos sin acoplar dominio.
    REQUISITOS Y CRITERIOS: RF-012/015/019; AC-012-* y eventos aprobados.
    INVARIANTES: sin secretos/PII innecesaria, idempotencia y correlación.
    CONTEXTO MÍNIMO: ADR, límites, catálogo de eventos y flujos aprobados.
    ENTRADAS: Casos de uso definidos.
    DEPENDENCIAS: decisiones de datos estabilizadas.
    RUTAS PERMITIDAS: packages/contracts/**, docs/api/**, docs/architecture/EVENT_CATALOG.md.
    RUTAS PROHIBIDAS: migraciones, UI y adaptadores.
    DECISIONES EXISTENTES: envoltorio de eventos propuesto.
    PRUEBAS OBLIGATORIAS: contratos válidos, compatibilidad y payload mínimo.
    COMANDOS DE VERIFICACIÓN: pnpm test/typecheck de contratos por definir.
    RIESGOS: contrato prematuro o incompatible.
    FORMATO DE ENTREGA: contrato estándar y notas de compatibilidad.

## F7-INT-01 — Adaptador OneDrive

    TASK-ID: F7-INT-01
    ROL: Integraciones
    OBJETIVO: Implementar primero simulador y después adaptador Graph autorizado.
    REQUISITOS Y CRITERIOS: RF-001 documental, RF-007, RF-014 documental, RF-015.
    INVARIANTES: binario solo OneDrive, sin eliminar documentos/permanentDelete, carpeta vacía con doble control.
    CONTEXTO MÍNIMO: contratos, políticas, lista de operaciones y permisos Graph aprobados.
    ENTRADAS: ambiente Graph de prueba.
    DEPENDENCIAS: G4 y checkpoint de escritura real.
    RUTAS PERMITIDAS: adaptador/funciones OneDrive y sus pruebas de contrato asignadas.
    RUTAS PROHIBIDAS: dominio, migraciones ajenas, UI, secretos.
    DECISIONES EXISTENTES: estructura inicial y protección RF-007.
    PRUEBAS OBLIGATORIAS: idempotencia, eTag obsoleto, delta, archivo/restauración y negativos de papelera.
    COMANDOS DE VERIFICACIÓN: suite contractual/E2E fijada en Fase 7.
    RIESGOS: permiso excesivo, cambio directo, pérdida de ruta, throttling.
    FORMATO DE ENTREGA: contrato estándar con scopes y evidencia redactada.

## F9-INT-01 — APT/SIRI

    TASK-ID: F9-INT-01
    ROL: Integraciones
    OBJETIVO: Fixtures, parser, lista blanca, comparación, cron y fallback; conexión real solo autorizada.
    REQUISITOS Y CRITERIOS: RF-002/006/014/016/017.
    INVARIANTES: solo catastro, solo lectura, sin endpoint de carga, sin evasión ni secretos.
    CONTEXTO MÍNIMO: endpoints permitidos, modelo externo y puerta legal.
    ENTRADAS: fixtures anonimizados; credencial individual solo en ambiente autorizado.
    DEPENDENCIAS: proyectos, outbox, avisos y decisión de worker.
    RUTAS PERMITIDAS: workers/monitoring/** y adaptadores APT/SIRI asignados.
    RUTAS PROHIBIDAS: UI, migraciones ajenas, cargas APT/SIRI.
    DECISIONES EXISTENTES: horarios y fallback.
    PRUEBAS OBLIGATORIAS: ruta prohibida, horario/DST, idempotencia, parcial, CAPTCHA/MFA bloqueado.
    COMANDOS DE VERIFICACIÓN: suites fixtures/contrato/cron.
    RIESGOS: legalidad, interfaz inestable, bloqueo institucional.
    FORMATO DE ENTREGA: contrato estándar más lista exacta de egress.

## F12-REV-01 — Revisión de lanzamiento

    TASK-ID: F12-REV-01
    ROL: Calidad y lanzamiento — independiente
    OBJETIVO: Revisar candidato congelado, pruebas, seguridad, UX, restore y rollback sin editar.
    REQUISITOS Y CRITERIOS: Todos los AC activos y definición de terminado.
    INVARIANTES: 0 críticos/altos, RF-013 ausente, producción solo aprobada.
    CONTEXTO MÍNIMO: release diff, trazabilidad, reportes, riesgos y runbooks.
    ENTRADAS: candidato/versiones/entornos.
    DEPENDENCIAS: todas las fases cerradas.
    RUTAS PERMITIDAS: lectura total; salida fuera de rutas de autor según asignación.
    RUTAS PROHIBIDAS: modificación del candidato.
    DECISIONES EXISTENTES: ADR y cambios aprobados.
    PRUEBAS OBLIGATORIAS: regresión, RLS, WCAG, ASVS, capacidad, degradación, restore, rollback y smoke.
    COMANDOS DE VERIFICACIÓN: pipeline fijado y ejercicios operativos.
    RIESGOS: evidencia caduca o ambiente no representativo.
    FORMATO DE ENTREGA: hallazgos P0–P3 y recomendación go/no-go.
