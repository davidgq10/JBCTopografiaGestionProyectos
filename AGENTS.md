# Instrucciones del repositorio

Estado: **aprobado en G0 el 2026-07-23**. Estas reglas traducen la especificación aprobada a instrucciones operativas del repositorio. No cambian su alcance.

## Fuente de verdad y precedencia

1. Leer completamente `Especificacion_Requerimientos_Plataforma_JBC.txt`, incluidos sus anexos, antes de modificar código.
2. Aplicar, en este orden: último ajuste aprobado, requisito más específico, ADR vigente y suposición reversible documentada.
3. RF-001 a RF-012 y RF-014 a RF-020 están aprobados. RF-013 está descartado y no se implementa.
4. No cambiar silenciosamente alcance, seguridad, costos, permisos, datos ni UX. Registrar la decisión y solicitar aprobación si es material.
5. Para toda interfaz, leer y aplicar `docs/development/UI_UX_IMPLEMENTATION_GUIDELINES.md`; sus patrones y vocabulario son criterios de revisión, no recomendaciones opcionales.

## Ejecución por fases

- Respetar las Fases 0 a 12 y sus puertas. No iniciar una fase que requiera checkpoint sin aprobación explícita.
- En cada fase: identificar RF y criterios, asignar archivos exclusivos, implementar el corte vertical mínimo, probar, solicitar revisión independiente, corregir, integrar, probar el conjunto y actualizar trazabilidad.
- Compilar no equivale a terminar. La evidencia debe enlazarse desde `docs/product/TRACEABILITY_MATRIX.md`.
- Mantener `docs/ai/CURRENT_STATUS.md`, `docs/ai/DECISIONS_LOG.md`, `docs/ai/RISKS.md` y los handoffs al día.

## Invariantes

- Los proyectos se crean manualmente; no existe importación o sincronización desde Excel.
- APT/SIRI son de solo lectura y solo aplican a Plano de catastro. El estado interno nunca se mezcla con el estado externo.
- Los binarios viven exclusivamente en OneDrive. Supabase conserva datos, metadatos y `driveId`/`driveItemId`, nunca archivos de proyecto.
- Los documentos se archivan con motivo y nunca se eliminan. Solo una carpeta completamente vacía puede ir a la papelera, mediante doble control; nunca usar `permanentDelete`.
- La IA propone con evidencia, confianza y fecha de corte; una persona autorizada decide.
- Validar en cliente por UX y siempre en servidor por seguridad. Aplicar RLS a toda tabla expuesta.
- Nunca exponer secretos en navegador, repositorio, logs, auditoría, notificaciones o prompts.
- Guardar fechas en UTC y presentarlas en `America/Costa_Rica`.
- La auditoría es de solo adición y las acciones sensibles requieren aprobación.
- La interfaz es española, WCAG 2.2 AA, responsive y operable desde 360 px.
- La UI usa patrones convencionales de productos profesionales: controles de cierre y navegación por iconos universales con nombres accesibles, acciones de negocio con texto claro y ninguna jerga técnica expuesta sin traducción.

## Arquitectura y stack

- Monolito modular con Clean Architecture, puertos/adaptadores y outbox transaccional.
- Stack obligatorio: React, TypeScript estricto, Vite, pnpm, Mantine, Zod, React Router Data Mode, TanStack Query/Table/Virtual, FullCalendar, Day.js, Supabase SDK, PWA/Workbox, Vitest, Testing Library, MSW, Playwright, axe-core, ESLint, Prettier y Storybook.
- No introducir microservicios, microfrontends, Redux, Zustand, Event Sourcing, CQRS completo, servicios pagados ni complementos Premium sin aprobación.
- El dominio no depende de React, Supabase, Graph, OpenAI, APT ni SIRI.
- Evitar dependencias circulares entre módulos; integrar mediante contratos de aplicación y eventos versionados.

## Seguridad, cambios y pruebas

- TypeScript debe permanecer en modo estricto; contratos y migraciones se versionan.
- Toda tabla expuesta necesita pruebas RLS positivas y negativas por rol y alcance.
- Toda operación reintentable debe demostrar idempotencia. Toda actualización concurrente usa versión y resolución explícita.
- No realizar operaciones destructivas, conexiones reales APT/SIRI, escrituras reales OneDrive ni despliegues de producción sin su checkpoint.
- Antes de integrar: formato, lint, tipos, límites de arquitectura, pruebas aplicables, construcción y revisión de secretos/dependencias.
- Cobertura mínima del 80 % en dominio y aplicación. Las integraciones externas se prueban primero con simuladores.

## Delegación

- Máximo tres subagentes activos además del orquestador, profundidad máxima dos y solo para trabajos independientes.
- Un archivo tiene un único propietario simultáneo. Cada encargo declara rutas permitidas y prohibidas, RF, invariantes, dependencias, pruebas, riesgos y formato de entrega.
- Los revisores no modifican archivos durante la revisión y no son autores del trabajo revisado.
- No guardar conversación ni secretos como memoria; usar los documentos del repositorio.

## Bloqueos

Detener solo el frente afectado y pedir intervención ante falta de autorización, credencial o permiso; riesgo de datos; costo; contradicción material; operación destructiva; imposibilidad de validar APT/SIRI; o decisión de producto. No evadir MFA, CAPTCHA ni controles institucionales.
