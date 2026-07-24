# Plan de Fase 3 — esqueleto ejecutable

Estado: **implementación integrada; R3 NO-GO por un P1 de recorrido conectado; G3 pendiente**.

## Alcance autorizado

Construir el corte mínimo de la especificación: monorepo; React/Vite/Mantine; AppShell responsive; PWA; Supabase; inicio Microsoft Entra mediante Supabase Auth; lectura y actualización del acento propio con RLS, validación de servidor y auditoría; errores uniformes; versión/entorno; pruebas y contrato de CI.

RF dominantes: `RF-010`, `RF-012`, `RF-016`, `RF-018` y `RF-020`. Criterios inmediatos: `AC-010-01/03/04`, `AC-012-02/03/05`, `AC-016-07/08`, `AC-018-01/02/04`, `AC-020-01/04/06` y regresión `EX-013-01`.

## Corte vertical

```text
Microsoft/Supabase Auth → sesión → SELECT del perfil propio por RLS
→ cambio de acento → validación de aplicación y PostgreSQL
→ UPDATE optimista por versión → auditoría append-only
→ invalidación de consulta y confirmación accesible
```

La prueba de navegador usa adaptadores deterministas; la prueba PostgreSQL reproduce el mismo recorrido con claims autenticadas y AAL2. La conexión real a Entra requiere credenciales y tenant autorizados y se mantiene separada.

## Fuera de alcance

- módulos de negocio de Fase 4 o posteriores;
- conexiones reales APT/SIRI, OneDrive, Push u OpenAI;
- archivos binarios en Supabase;
- creación/importación de proyectos o RF-013;
- producción, repositorio remoto, rama protegida o proveedor CI sin resolver `DEC-0209`;
- secretos reales dentro del repositorio.

## Verificación y puerta

Antes de presentar G3: `pnpm verify:ci`, ruta limpia PostgreSQL 17 con `pnpm verify:database`, revisión independiente sin P0/P1, proveedor CI/rama aprobado y validación Entra real autorizada. La aprobación del usuario es siempre explícita.
