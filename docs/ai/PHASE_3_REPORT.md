# Informe de Fase 3 — esqueleto ejecutable

Fecha de corte: **2026-07-29 America/Costa_Rica**

Estado: **implementación técnica integrada; P1 conectado y Entra QA real cerrados; G3 no presentado**.

## Resultado

- Monorepo pnpm con paquetes separados de dominio, aplicación, contratos, fixtures y web.
- React 19, TypeScript estricto, Vite, Mantine y React Router Data Mode con límites de arquitectura comprobados.
- AppShell profesional: sidebar normal/slim, una sola `J` para expandir, Configuración en el pie y navegación inferior móvil a 360 px con tres accesos configurables por usuario.
- Tema automático/claro/oscuro y acento individual predefinido o hexadecimal, sincronizados por perfil, previsualizables, restaurables y validados para contraste AA.
- Adaptadores Supabase para sesión Azure y perfil propio; sin `service_role` ni secreto en React.
- Migración F3 con validación de preferencias (acento, tema y orden móvil) en PostgreSQL, concurrencia por versión para todos los roles y auditoría append-only transaccional con actor/rol.
- PWA `injectManifest`: shell estático disponible y peticiones Supabase `NetworkOnly`; escrituras deshabilitadas al quedar offline; recarga fría del build probada.
- entorno no productivo y versión SemVer visibles; errores y estados de carga/vacío/degradación uniformes.
- Storybook con estados del sistema y addon a11y; Vitest/Testing Library/MSW y Playwright/axe.
- contrato de CI reproducible con `pnpm verify:ci` y `pnpm verify:database`.
- recorrido conectado validado con `pnpm verify:connected`: UI → PostgREST 14.12 → PostgreSQL 17 → RLS → auditoría → confirmación visible;
- accesibilidad suplementaria PASS en Edge de escritorio y WebKit con perfil iPhone emulado; la validación física continúa pendiente;
- Microsoft Entra QA real PASS con MFA, callback `http://localhost:54321/auth/v1/callback`, sesión preautorizada, rol `technician` y revocación/restauración controladas.
- Preferencia de navegación móvil PASS: Configuración persiste tres accesos ordenables entre Agenda, Avisos, Cuenta, Proyectos y Tareas, con Inicio/Más fijos, RLS, versión y auditoría. Evidencia: [F03-MOBILE-NAV-PREFERENCES-2026-07-29.md](../testing/evidence/F03/F03-MOBILE-NAV-PREFERENCES-2026-07-29.md).

## Evidencia ejecutada

- dominio: 97.22 % de líneas; aplicación: 97.43 %;
- RLS: `RLS-STRUCT PASS` y `RLS-MATRIX PASS 2561/2561`;
- F3 DB: `F3-ACCENT PASS | login claims -> RLS read -> validated write -> append-only audit`;
- navegador: 14/14 escenarios ejecutables en Chromium 1440/1024/768/360 px (6 omitidos por viewport) y 1/1 PWA compilada offline; axe 0 crítico/serio; sin desbordamiento horizontal;
- lint, tipos, arquitectura, secretos, SQL estático, build PWA y Storybook: PASS.

Detalle: [evidencia F03](../testing/evidence/F03/README.md).

## Límites y bloqueos correctos

R3 independiente registró un P1 porque UI y PostgreSQL pasaban por separado. La corrección posterior incorporó `pnpm verify:connected`: un navegador real lee y escribe por PostgREST 14.12, RLS limita la lectura al perfil propio, la UI confirma la operación y PostgreSQL demuestra versión y auditoría. R4 confirmó el cierre técnico del P1; el seguimiento independiente mantiene 0 P0/P1 abiertos y 1 P2 físico.

`DEC-0209` quedó implementada el 2026-07-24 en `davidgq10/JBCTopografiaGestionProyectos`: `Main` es la rama predeterminada y protegida, y la primera ejecución alojada pasó los jobs `Quality` y `Database`. La revisión de dependencias se ejecuta en pull requests y se promueve a check requerido tras su primer registro en GitHub.

La integración Entra está implementada y cerrada por defecto. El ambiente QA autorizado validó tenant, MFA, allowlist/callback `localhost`, sesión preautorizada, rol y revocación/restauración; producción no se tocó. La evidencia canónica está en [F03-ENTRA-QA-2026-07-28.md](../testing/evidence/F03/F03-ENTRA-QA-2026-07-28.md).

El bundle principal emite una advertencia de tamaño (~799 kB sin comprimir). No bloquea el skeleton, pero se conserva como riesgo de rendimiento para dividir rutas antes de ampliar módulos.

## Dictamen

La base ejecutable, el recorrido conectado y Entra QA están construidos y verificados. Fase 3 permanece activa en **NO-GO condicionado**: G3 no debe presentarse hasta cerrar el P2 físico (teclado/foco, zoom nativo 200 %, Chrome Android físico y Safari iPhone/iOS) y recibir aprobación explícita del usuario. El frente GitHub/CI de `DEC-0209` está cerrado.
