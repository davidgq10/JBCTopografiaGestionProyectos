# Integración continua en GitHub

Estado: **publicado y protegido el 2026-07-24**.

## Destino aprobado

- proveedor: GitHub Actions;
- repositorio: `https://github.com/davidgq10/JBCTopografiaGestionProyectos`;
- rama principal: `Main`;
- Node.js 24, pnpm 11.9, Chromium y PostgreSQL 17 efímero;
- ningún secreto de aplicación, Entra o producción es necesario para el pipeline base.

La rama `Main` es la rama predeterminada. El commit inicial de Fase 3 es
`a93d0dac1eedced649d0eb5d7041adb52fa23f23` y su primera ejecución alojada
finalizó correctamente en [GitHub Actions #30112463543](https://github.com/davidgq10/JBCTopografiaGestionProyectos/actions/runs/30112463543).

## Controles obligatorios

Los pull requests y cambios a `Main` ejecutan:

1. instalación con lockfile inmutable;
2. `pnpm verify:ci` en el job `CI / Quality`;
3. migración limpia, estructura, RLS 2561/2561 y walking skeleton mediante `pnpm verify:database` en `CI / Database`;
4. recorrido conectado con Chromium, PostgREST 14.12, PostgreSQL 17, RLS y auditoría mediante `pnpm verify:connected` en `CI / Connected integration`;
5. revisión de cambios de dependencias, bloqueando vulnerabilidades altas o críticas.

Dependabot revisa semanalmente paquetes pnpm y GitHub Actions. Las actualizaciones menores y parches se agrupan; ninguna actualización se integra automáticamente.

## Protección aprobada para `Main`

- pull request obligatorio con una aprobación;
- descartar aprobaciones cuando cambie el código;
- resolver todas las conversaciones;
- exigir rama actualizada antes de integrar;
- checks requeridos desde la publicación: `Quality` y `Database`;
- `Connected integration` y `Dependency review` se agregan como checks requeridos en cuanto GitHub los registre durante el primer pull request;
- impedir force-push y eliminación de `Main`;
- aplicar las reglas también a administradores;
- historial lineal y sin bypass ordinario.

Los cambios posteriores de configuración remota y reglas de protección requieren autenticación GitHub del propietario o un token temporal con permisos mínimos. No guardar el token en archivos, historial, logs ni documentación.
