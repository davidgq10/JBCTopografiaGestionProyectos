# Mandato operativo del proyecto

Estado: **línea base de Fase 0**

La fuente normativa completa es `Especificacion_Requerimientos_Plataforma_JBC.txt` (SHA-256 inspeccionado `A35DB4A87B7D303A7B016C9DABC7F36257E18DC3205306F37B3D2B2493486C6E`), en particular el Anexo A entre “INICIO DEL PROMPT” y “FIN DEL PROMPT”. Este archivo no sustituye ni recorta esa fuente; permite recuperar el mandato sin depender de la conversación.

## Objetivo

Diseñar, desarrollar, probar, documentar y preparar para producción la PWA de control de proyectos de JBC Topografía. Entregarla segura, mantenible, verificable, minimalista, accesible y completa desde celular, cumpliendo RF-001 a RF-012 y RF-014 a RF-020. RF-013 permanece descartado.

## Forma de trabajo

- Orquestador responsable de visión, trazabilidad, decisiones, integración y verificación final.
- Fases 0–12 en orden, con checkpoints y revisión independiente.
- Subagentes solo para tareas independientes, máximo tres, rutas exclusivas y contexto mínimo.
- Cada corte enlaza RF/criterios, valida cliente/servidor, prueba RLS/permisos, audita, cubre estados y móvil, y entrega evidencia reproducible.
- No cambiar alcance, seguridad, costo, permisos, datos o UX sin registro y aprobación material.
- Mantener `CURRENT_STATUS.md`, `DECISIONS_LOG.md`, `RISKS.md`, trazabilidad y handoffs.

## Invariantes abreviados

Creación manual; APT/SIRI solo catastro y lectura; estados interno/externo separados; OneDrive único binario; documento se archiva; IA propone/persona decide; validación servidor y RLS; secretos protegidos; UTC/Costa Rica; acciones sensibles aprobadas; auditoría append-only; español/WCAG/mobile-first; acento accesible sin alterar semántica.

## Estado de autorización

G0 y CP-UX fueron aprobados el 2026-07-23; Fase 1 está cerrada. Fase 2 no se inició en el cierre y debe abordarse como corte separado. No programar módulos funcionales de producción ni inicializar integraciones reales fuera de la fase/checkpoint autorizado.
