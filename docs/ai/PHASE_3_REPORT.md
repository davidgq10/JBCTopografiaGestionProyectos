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

R3 independiente registró un P1 porque UI y PostgreSQL pasaban por separado. La corrección posterior incorporó `pnpm verify:connected`: un navegador real lee y escribe por PostgREST 14.12, RLS limita la lectura al perfil propio, la UI confirma la operación y PostgreSQL demuestra versión y auditoría. El hallazgo requiere un dictamen independiente actualizado antes de considerarse cerrado para G3.

`DEC-0209` quedó implementada el 2026-07-24 en `davidgq10/JBCTopografiaGestionProyectos`: `Main` es la rama predeterminada y protegida, y la primera ejecución alojada pasó los jobs `Quality` y `Database`. La revisión de dependencias se ejecuta en pull requests y se promueve a check requerido tras su primer registro en GitHub.

La integración Entra está implementada y cerrada por defecto, pero tenant, MFA, allowlist y revocación no se han validado contra un ambiente real porque no se proporcionaron credenciales ni autorización. Los simuladores y PostgreSQL prueban el contrato; no sustituyen esa validación.

El bundle principal emite una advertencia de tamaño (~799 kB sin comprimir). No bloquea el skeleton, pero se conserva como riesgo de rendimiento para dividir rutas antes de ampliar módulos.

## Dictamen

La base ejecutable y el recorrido conectado están construidos. Fase 3 permanece activa en **NO-GO** y G3 no debe presentarse hasta validar Entra en un ambiente autorizado, obtener revisión sin P0/P1, cerrar el P2 restante y recibir aprobación explícita del usuario. El frente GitHub/CI de `DEC-0209` está cerrado.
