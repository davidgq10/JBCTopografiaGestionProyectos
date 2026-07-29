# Estado actual

Actualizado: **2026-07-29 America/Costa_Rica**.

- Última fase cerrada: **3 — esqueleto ejecutable**.
- Fase activa: **ninguna; Fase 4 todavía no iniciada**.
- Estado: **Fase 3 cerrada; P1 conectado y Entra QA real cerrados; P2 residual aceptado y G3 aprobado**.
- Checkpoints cerrados: G0, CP-UX y G2 (2026-07-23), G3 (2026-07-29).
- Próxima fase: disponible para preparación cuando el usuario la solicite; requiere su propio checkpoint G4.

## Corte Fase 3

- Monorepo pnpm con React, TypeScript estricto, Vite, Mantine y límites Clean Architecture.
- AppShell responsive, sidebar normal/slim, navegación inferior a 360 px, preferencia de tres accesos móviles sincronizada por perfil, tema y acento accesibles.
- Supabase Auth Azure preparado y cerrado por defecto; cliente público sin secretos ni `service_role`.
- Perfil/apariencia propio: lectura RLS, preferencias visuales y orden móvil validado en servidor, versión optimista y auditoría append-only transaccional.
- PWA de shell estático; tráfico Supabase `NetworkOnly`, mutaciones deshabilitadas offline y recarga fría del build comprobada.
- entorno/versión visibles, estados/errores uniformes y Storybook a11y.
- contrato reproducible de CI: `pnpm verify:ci` + PostgreSQL efímero con `pnpm verify:database`.

## Evidencia vigente

- dominio 97.22 % y aplicación 97.43 % de cobertura;
- 57/57 tablas RLS habilitada/forzada; `RLS-STRUCT PASS`; `RLS-MATRIX PASS 2561/2561`;
- `F3-ACCENT PASS | login claims -> RLS read -> validated write -> append-only audit`;
- Playwright 14/14 escenarios ejecutables en Chromium 1440/1024/768/360 px (6 omitidos por viewport), más 1/1 de recarga PWA fría offline; axe 0 crítico/serio y sin desbordamiento;
- formato, lint, tipos, arquitectura, secretos, SQL estático, build PWA y Storybook PASS.
- `pnpm verify:ci` PASS: 14/14 E2E Chromium ejecutables (6 omitidos por viewport) y 1/1 PWA.
- `pnpm verify:database` PASS: PostgreSQL 17 efímero, 57/57 RLS, matriz 2561/2561 y `F3-ACCENT PASS`.
- `pnpm verify:connected` PASS: UI → PostgREST 14.12 → PostgreSQL 17 → RLS → auditoría.
- Entra QA real PASS: tenant QA, MFA, callback `localhost`, sesión preautorizada, rol `technician` y revocación/restauración controladas.
- Preferencia de navegación móvil PASS: Configuración, selección/orden con Inicio y Más fijos, RLS, versión y auditoría; evidencia en `F03/F03-MOBILE-NAV-PREFERENCES-2026-07-29.md`.
- R4 independiente y seguimiento: 0 P0, 0 P1, 1 P2 residual aceptado explícitamente por el usuario, 0 P3; evidencia suplementaria Edge/WebKit emulado PASS y Entra QA real PASS.

Fuentes: [informe F3](PHASE_3_REPORT.md) y [evidencia F03](../testing/evidence/F03/README.md).

## Cierre de G3

1. El P1 `F3-REV-P1-02` está cerrado técnicamente y por R4. El P2 residual de teclado/foco físico, zoom nativo 200 %, Chrome Android físico y Safari iPhone/iOS fue aceptado explícitamente por el usuario el 2026-07-29; Edge de escritorio y WebKit emulado tienen evidencia suplementaria.
2. La aprobación de P2 y G3 queda registrada en `docs/testing/evidence/F03/F03-G3-USER-APPROVAL-2026-07-29.md`.

`DEC-0209` ya no es un bloqueo: GitHub Actions fue publicado en `davidgq10/JBCTopografiaGestionProyectos`, `Main` es predeterminada y está protegida, y la primera ejecución alojada pasó `Quality` y `Database`.

El recorrido conectado local pasó el 2026-07-28 con PostgREST 14.12 y PostgreSQL 17: lectura RLS, escritura con versión, respuesta visible y auditoría transaccional. Evidencia: `F03/F03-VERIFICATION-2026-07-28.md`.

## Riesgo no bloqueante

El bundle principal ronda 799 kB sin comprimir. Se debe dividir por rutas antes de ampliar módulos; no invalida el walking skeleton actual.

## Continuación

Fase 3 está cerrada. La Fase 4 no se inicia automáticamente; cuando se autorice, debe seguir su plan y preparar el checkpoint G4.
