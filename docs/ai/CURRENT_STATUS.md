# Estado actual

Actualizado: **2026-07-24 UTC / 2026-07-23 America/Costa_Rica**.

- Última fase cerrada: **2 — arquitectura técnica, contratos y datos**.
- Fase activa: **3 — esqueleto ejecutable**.
- Estado: **implementación técnica integrada; G3 no presentado**.
- Checkpoints cerrados: G0, CP-UX y G2, aprobados por el usuario el 2026-07-23.
- Próxima fase: bloqueada hasta aprobación explícita de G3.

## Corte Fase 3

- Monorepo pnpm con React, TypeScript estricto, Vite, Mantine y límites Clean Architecture.
- AppShell responsive, sidebar normal/slim, navegación inferior a 360 px, tema y acento accesibles sincronizados por perfil.
- Supabase Auth Azure preparado y cerrado por defecto; cliente público sin secretos ni `service_role`.
- Perfil/apariencia propio: lectura RLS, escritura validada en servidor, versión optimista y auditoría append-only transaccional.
- PWA de shell estático; tráfico Supabase `NetworkOnly`, mutaciones deshabilitadas offline y recarga fría del build comprobada.
- entorno/versión visibles, estados/errores uniformes y Storybook a11y.
- contrato reproducible de CI: `pnpm verify:ci` + PostgreSQL efímero con `pnpm verify:database`.

## Evidencia vigente

- dominio 97.22 % y aplicación 100 % de cobertura;
- 57/57 tablas RLS habilitada/forzada; `RLS-STRUCT PASS`; `RLS-MATRIX PASS 2561/2561`;
- `F3-ACCENT PASS | login claims -> RLS read -> validated write -> append-only audit`;
- Playwright 12/12 en Chromium 1440/1024/768/360 px, más 1/1 de recarga PWA fría offline; axe 0 crítico/serio y sin desbordamiento;
- formato, lint, tipos, arquitectura, secretos, SQL estático, build PWA y Storybook PASS.

Fuentes: [informe F3](PHASE_3_REPORT.md) y [evidencia F03](../testing/evidence/F03/README.md).

## Bloqueos de G3

1. `F3-REV-P1-02`: falta un único recorrido de navegador conectado a Supabase/PostgREST/PostgreSQL que demuestre lectura, escritura, RLS, auditoría y respuesta visible; hoy UI y DB pasan por separado.
2. `DEC-0209` fue aprobada para GitHub Actions, repositorio `davidgq10/JBCTopografia_GestionProyectos.git` y rama `Main`; falta publicar la configuración y aplicar la protección remota con una credencial administrativa.
3. Microsoft Entra/Supabase Auth real: falta ambiente autorizado para comprobar tenant, MFA, allowlist y revocación; los simuladores no se presentan como evidencia real.
4. R3 independiente emitió **NO-GO: 0 P0, 1 P1, 1 P2, 0 P3**. El P2 restante corresponde a teclado/zoom/navegadores y dispositivos adicionales; el P1 es el recorrido conectado.
5. Aprobación expresa del usuario: requerida aun después de cerrar los puntos anteriores.

## Riesgo no bloqueante

El bundle principal ronda 799 kB sin comprimir. Se debe dividir por rutas antes de ampliar módulos; no invalida el walking skeleton actual.

## Continuación

No iniciar Fase 4. Seguir [F3-G3-PENDING-2026-07-24.md](HANDOFFS/F3-G3-PENDING-2026-07-24.md), resolver solo los frentes de G3 y repetir la verificación completa.
