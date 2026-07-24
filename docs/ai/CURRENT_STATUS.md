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

1. Microsoft Entra/Supabase Auth real: falta ambiente autorizado para comprobar tenant, MFA, allowlist y revocación; el JWT sintético del arés conectado no se presenta como evidencia Entra.
2. R3 independiente emitió **NO-GO: 0 P0, 1 P1, 1 P2, 0 P3**. `F3-REV-P1-02` tiene corrección y evidencia conectada nuevas, pero requiere dictamen independiente actualizado. El P2 de teclado/zoom/navegadores y dispositivos adicionales sigue abierto.
3. Aprobación expresa del usuario: requerida aun después de cerrar los puntos anteriores.

`DEC-0209` ya no es un bloqueo: GitHub Actions fue publicado en `davidgq10/JBCTopografiaGestionProyectos`, `Main` es predeterminada y está protegida, y la primera ejecución alojada pasó `Quality` y `Database`.

El recorrido conectado local pasó el 2026-07-24 con PostgREST 14.12 y PostgreSQL 17: lectura RLS, escritura con versión, respuesta visible y auditoría transaccional. Evidencia: `F03/F03-CONNECTED-POSTGREST-2026-07-24.md`.

## Riesgo no bloqueante

El bundle principal ronda 799 kB sin comprimir. Se debe dividir por rutas antes de ampliar módulos; no invalida el walking skeleton actual.

## Continuación

No iniciar Fase 4. Seguir [F3-G3-PENDING-2026-07-24.md](HANDOFFS/F3-G3-PENDING-2026-07-24.md), resolver solo los frentes de G3 y repetir la verificación completa.
