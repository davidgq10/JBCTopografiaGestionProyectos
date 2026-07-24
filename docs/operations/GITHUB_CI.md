# Integración continua en GitHub

Estado: **proveedor y política aprobados el 2026-07-24; publicación y protección remota pendientes de credencial administrativa**.

## Destino aprobado

- proveedor: GitHub Actions;
- repositorio: `davidgq10/JBCTopografia_GestionProyectos.git`;
- rama principal: `Main`;
- Node.js 24, pnpm 11.9, Chromium y PostgreSQL 17 efímero;
- ningún secreto de aplicación, Entra o producción es necesario para el pipeline base.

## Controles obligatorios

Los pull requests y cambios a `Main` ejecutan:

1. instalación con lockfile inmutable;
2. `pnpm verify:ci` en el job `CI / Quality`;
3. migración limpia, estructura, RLS 2561/2561 y walking skeleton mediante `pnpm verify:database` en `CI / Database`;
4. revisión de cambios de dependencias, bloqueando vulnerabilidades altas o críticas.

Dependabot revisa semanalmente paquetes pnpm y GitHub Actions. Las actualizaciones menores y parches se agrupan; ninguna actualización se integra automáticamente.

## Protección aprobada para `Main`

- pull request obligatorio con una aprobación;
- descartar aprobaciones cuando cambie el código;
- resolver todas las conversaciones;
- exigir rama actualizada antes de integrar;
- checks requeridos: `CI / Quality`, `CI / Database` y `Dependency review / Dependency review` cuando exista un pull request;
- impedir force-push y eliminación de `Main`;
- aplicar las reglas también a administradores;
- historial lineal y sin bypass ordinario.

La publicación del repositorio, cambios de configuración remota y reglas de protección requieren autenticación GitHub del propietario o un token temporal con permisos mínimos. No guardar el token en archivos, historial, logs ni documentación.
