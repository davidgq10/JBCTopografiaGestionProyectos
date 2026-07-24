# Informe de Fase 3 — esqueleto ejecutable

Fecha de corte: **2026-07-24 UTC / 2026-07-23 America/Costa_Rica**  
Estado: **implementación técnica integrada; G3 no presentado**.

## Resultado

- Monorepo pnpm con paquetes separados de dominio, aplicación, contratos, fixtures y web.
- React 19, TypeScript estricto, Vite, Mantine y React Router Data Mode con límites de arquitectura comprobados.
- AppShell profesional: sidebar normal/slim, una sola `J` para expandir, Configuración en el pie y navegación inferior móvil a 360 px.
- Tema automático/claro/oscuro y acento individual predefinido o hexadecimal, sincronizados por perfil, previsualizables, restaurables y validados para contraste AA.
- Adaptadores Supabase para sesión Azure y perfil propio; sin `service_role` ni secreto en React.
- Migración F3 con validación de acento en PostgreSQL, concurrencia por versión para todos los roles y auditoría append-only transaccional con actor/rol.
- PWA `injectManifest`: shell estático disponible y peticiones Supabase `NetworkOnly`; escrituras deshabilitadas al quedar offline; recarga fría del build probada.
- entorno no productivo y versión SemVer visibles; errores y estados de carga/vacío/degradación uniformes.
- Storybook con estados del sistema y addon a11y; Vitest/Testing Library/MSW y Playwright/axe.
- contrato de CI reproducible con `pnpm verify:ci` y `pnpm verify:database`.

## Evidencia ejecutada

- dominio: 97.22 % de líneas; aplicación: 100 %;
- RLS: `RLS-STRUCT PASS` y `RLS-MATRIX PASS 2561/2561`;
- F3 DB: `F3-ACCENT PASS | login claims -> RLS read -> validated write -> append-only audit`;
- navegador: 12/12 en Chromium 1440/1024/768/360 px y 1/1 PWA compilada offline; axe 0 crítico/serio; sin desbordamiento horizontal;
- lint, tipos, arquitectura, secretos, SQL estático, build PWA y Storybook: PASS.

Detalle: [evidencia F03](../testing/evidence/F03/README.md).

## Límites y bloqueos correctos

R3 independiente mantiene un P1: UI y PostgreSQL pasan sus pruebas por separado, pero falta un único recorrido UI → Supabase/PostgREST → PostgreSQL → RLS/auditoría → respuesta visible. El E2E no se presenta como prueba de auditoría y G3 permanece en NO-GO hasta incorporar esa integración.

`DEC-0209` fue aprobada el 2026-07-24 para GitHub Actions, repositorio `davidgq10/JBCTopografia_GestionProyectos.git` y rama `Main`. El pipeline y la política quedaron versionables; su publicación y la protección remota requieren autenticación administrativa del propietario.

La integración Entra está implementada y cerrada por defecto, pero tenant, MFA, allowlist y revocación no se han validado contra un ambiente real porque no se proporcionaron credenciales ni autorización. Los simuladores y PostgreSQL prueban el contrato; no sustituyen esa validación.

El bundle principal emite una advertencia de tamaño (~799 kB sin comprimir). No bloquea el skeleton, pero se conserva como riesgo de rendimiento para dividir rutas antes de ampliar módulos.

## Dictamen

La base ejecutable está construida y sus capas pasan por separado. Fase 3 permanece activa en **NO-GO** y G3 no debe presentarse hasta demostrar el recorrido conectado, publicar y proteger el destino aprobado en `DEC-0209`, validar Entra en un ambiente autorizado, obtener revisión sin P0/P1 y recibir aprobación explícita del usuario.
