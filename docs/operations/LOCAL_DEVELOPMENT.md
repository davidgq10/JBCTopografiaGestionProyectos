# Desarrollo local — Fase 3

Estado: **walking skeleton ejecutable; no usar datos ni credenciales de producción**.

## Requisitos

- Node.js 24 y pnpm 11.
- PostgreSQL 17 o Supabase CLI/Docker local para la ruta de base de datos.
- Chromium de Playwright para las pruebas de navegador.

## Instalación y aplicación web

```powershell
pnpm install --frozen-lockfile
Copy-Item .env.example .env.local
pnpm dev
```

Solo `VITE_SUPABASE_URL`, `VITE_SUPABASE_PUBLISHABLE_KEY` y `VITE_APP_ENV` llegan al navegador. No se permite `service_role`, secretos OAuth ni credenciales de proveedores bajo un prefijo `VITE_`.

Sin configuración pública válida, la aplicación permanece en estado seguro y explica que Supabase no está configurado. Para pruebas automáticas usa adaptadores en memoria; no simula una conexión real a Microsoft.

## Supabase y Microsoft Entra ID

`supabase/config.toml` mantiene Azure deshabilitado de forma predeterminada. Para un entorno autorizado:

1. crear una aplicación Entra específica del ambiente;
2. restringir el tenant en `SUPABASE_AUTH_EXTERNAL_AZURE_URL`;
3. guardar ID y secreto solo en el almacén seguro del ambiente;
4. habilitar el proveedor Azure en la configuración desplegada de Supabase;
5. preautorizar a la persona en `public.app_users` y exigir MFA desde la política de acceso condicional de Microsoft;
6. validar inicio, rechazo de otro tenant/no autorizado, revocación y AAL2 antes de G3.

La aplicación solicita únicamente `openid email profile`. El rol y el alcance se derivan en PostgreSQL; nunca se aceptan desde datos declarados por el cliente.

## Verificación

```powershell
pnpm verify:ci
```

La orden ejecuta formato, lint, tipos, límites de arquitectura, revisión de secretos/superficies SQL, cobertura, build PWA, Storybook y Playwright en escritorio y 360 px.

Para una base PostgreSQL 17 efímera y vacía:

```powershell
$env:JBC_TEST_DATABASE_URL = 'cadena configurada solo en la sesión'
pnpm verify:database
Remove-Item Env:JBC_TEST_DATABASE_URL
```

La URL no se guarda en el repositorio ni en la evidencia. El script crea roles locales, aplica todas las migraciones, ejecuta `RLS-STRUCT`, la matriz `2561/2561` y el flujo F3 de perfil/acento/auditoría.

Para demostrar el corte vertical conectado sin instalar PostgreSQL ni PostgREST en Windows:

```powershell
pnpm verify:connected
```

La orden usa Docker Desktop para levantar PostgreSQL 17 y PostgREST 14.12 efímeros, genera en memoria un JWT sintético AAL2, ejecuta Chromium y elimina los contenedores al finalizar. El token no se entrega al navegador, no se registra y no sustituye la validación Microsoft Entra.

## Contrato de integración continua

GitHub Actions y la rama `Main` fueron aprobados en `DEC-0209`. El pipeline definido en `.github/workflows/` debe ejecutar en un checkout limpio:

1. `pnpm install --frozen-lockfile`;
2. `pnpm verify:ci`;
3. PostgreSQL 17 efímero y `pnpm verify:database`;
4. revisión de dependencias del proveedor;
5. bloqueo de integración si falla cualquier paso.

La política completa y la protección aprobada están documentadas en [GITHUB_CI.md](GITHUB_CI.md). La publicación y los cambios remotos requieren autenticación del propietario; no se crea silenciosamente una cuenta ni un servicio pagado.
