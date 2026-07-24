# F03 — base de datos, RLS y walking skeleton

Fecha: **2026-07-24 UTC / 2026-07-23 America/Costa_Rica**  
Motor: **PostgreSQL 17.10 en contenedor local aislado**  
Datos: **fixtures sintéticos**.

## Ruta ejecutada

1. base efímera vacía;
2. roles locales mínimos `anon` y `authenticated`;
3. 20 migraciones, desde `20260723090100` hasta `20260724030100`;
4. estructura RLS;
5. matriz funcional aprobada `DEC-0103`;
6. caso F3 de acento propio.

## Resultados

```text
RLS-STRUCT PASS
RLS-MATRIX PASS 2561/2561
F3-ACCENT PASS | login claims -> RLS read -> validated write -> append-only audit
```

El caso F3 confirma claims autenticadas con AAL2, `SELECT` solo del perfil propio, rechazo/normalización del color en servidor, rechazo de cambios directos a columnas de identidad, sincronización de tema, `UPDATE` con versión esperada, incremento de versión también para el perfil propio Administrador, rol real conservado en auditoría, evento creado dentro de la misma transacción y prohibición de alterar/borrar auditoría desde el cliente.

No se usó `service_role`, conexión administrada, dato real ni proveedor externo. La ejecución es reproducible mediante `pnpm verify:database` sobre PostgreSQL 17 efímero.
