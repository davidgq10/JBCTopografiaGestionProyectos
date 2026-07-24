import { createHmac, randomBytes } from 'node:crypto';
import { readdirSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { spawn, spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const repositoryRoot = resolve(fileURLToPath(new URL('..', import.meta.url)));
const webRoot = join(repositoryRoot, 'apps', 'web');
const suffix = `${process.pid}-${Date.now()}`;
const networkName = `jbc-f3-connected-${suffix}`;
const postgresName = `jbc-f3-postgres-${suffix}`;
const postgrestName = `jbc-f3-postgrest-${suffix}`;
const databaseUrl = 'postgresql://postgres:postgres@127.0.0.1:5432/jbc_f3';
const jwtSecret = randomBytes(32).toString('base64url');
let webServer;

function docker(argumentsList, options = {}) {
  const result = spawnSync('docker', argumentsList, {
    cwd: repositoryRoot,
    encoding: 'utf8',
    ...options,
  });
  if (result.error) throw result.error;
  if (result.status !== 0) {
    throw new Error(result.stderr?.trim() || result.stdout?.trim() || 'Docker terminó con error.');
  }
  return result.stdout?.trim() ?? '';
}

function base64Url(value) {
  return Buffer.from(JSON.stringify(value)).toString('base64url');
}

function createAccessToken() {
  const now = Math.floor(Date.now() / 1000);
  const header = base64Url({ alg: 'HS256', typ: 'JWT' });
  const payload = base64Url({
    sub: 'b1000000-0000-4000-8000-000000000003',
    role: 'authenticated',
    aal: 'aal2',
    aud: 'authenticated',
    iat: now,
    exp: now + 600,
  });
  const unsigned = `${header}.${payload}`;
  const signature = createHmac('sha256', jwtSecret).update(unsigned).digest('base64url');
  return `${unsigned}.${signature}`;
}

async function waitUntil(check, label) {
  const deadline = Date.now() + 60_000;
  while (Date.now() < deadline) {
    try {
      if (await check()) return;
    } catch {
      // El servicio efímero todavía está iniciando.
    }
    await new Promise((resolvePromise) => setTimeout(resolvePromise, 250));
  }
  throw new Error(`${label} no respondió dentro de 60 segundos.`);
}

function applyDatabase() {
  const migrationCommands = readdirSync(join(repositoryRoot, 'supabase', 'migrations'))
    .filter((name) => name.endsWith('.sql'))
    .sort()
    .map((name) => `psql "$DB" -X -v ON_ERROR_STOP=1 -f "/repo/supabase/migrations/${name}"`);
  const command = [
    'set -e',
    `DB="${databaseUrl}"`,
    'psql "$DB" -X -v ON_ERROR_STOP=1 -f /repo/supabase/tests/bootstrap_supabase_roles.sql',
    ...migrationCommands,
    'psql "$DB" -X -v ON_ERROR_STOP=1 -f /repo/supabase/tests/50_postgrest_connected_fixture.sql',
  ].join('; ');
  docker(['exec', postgresName, 'sh', '-c', command], { stdio: 'inherit' });
}

function startWebServer(postgrestUrl, accessToken) {
  webServer = spawn(
    process.execPath,
    ['node_modules/vite/bin/vite.js', '--mode', 'connected-test', '--host', '127.0.0.1'],
    {
      cwd: webRoot,
      env: {
        ...process.env,
        JBC_CONNECTED_POSTGREST_URL: postgrestUrl,
        JBC_CONNECTED_JWT: accessToken,
      },
      stdio: 'ignore',
      windowsHide: true,
    },
  );
}

function runBrowser() {
  return new Promise((resolvePromise, reject) => {
    const browser = spawn(
      process.execPath,
      [
        'node_modules/@playwright/test/cli.js',
        'test',
        '--config',
        'playwright.connected.config.ts',
      ],
      { cwd: webRoot, stdio: 'inherit', windowsHide: true },
    );
    browser.once('error', reject);
    browser.once('exit', (code) => resolvePromise(code ?? 1));
  });
}

function assertDatabase() {
  docker(
    [
      'exec',
      postgresName,
      'psql',
      databaseUrl,
      '-X',
      '-v',
      'ON_ERROR_STOP=1',
      '-f',
      '/repo/supabase/tests/55_postgrest_connected_assertions.sql',
    ],
    { stdio: 'inherit' },
  );
}

function cleanup() {
  webServer?.kill();
  for (const container of [postgrestName, postgresName]) {
    spawnSync('docker', ['stop', container], { cwd: repositoryRoot, stdio: 'ignore' });
  }
  spawnSync('docker', ['network', 'rm', networkName], {
    cwd: repositoryRoot,
    stdio: 'ignore',
  });
}

let exitCode = 1;
try {
  docker(['network', 'create', networkName]);
  docker([
    'run',
    '--rm',
    '--name',
    postgresName,
    '--network',
    networkName,
    '-e',
    'POSTGRES_DB=jbc_f3',
    '-e',
    'POSTGRES_USER=postgres',
    '-e',
    'POSTGRES_PASSWORD=postgres',
    '-v',
    `${repositoryRoot}:/repo:ro`,
    '-d',
    'postgres:17',
  ]);
  await waitUntil(
    () =>
      docker([
        'exec',
        postgresName,
        'pg_isready',
        '-h',
        '127.0.0.1',
        '-U',
        'postgres',
        '-d',
        'jbc_f3',
      ]).includes('accepting connections'),
    'PostgreSQL 17',
  );
  applyDatabase();

  docker([
    'run',
    '--rm',
    '--name',
    postgrestName,
    '--network',
    networkName,
    '-p',
    '127.0.0.1::3000',
    '-e',
    `PGRST_DB_URI=postgres://postgres:postgres@${postgresName}:5432/jbc_f3`,
    '-e',
    'PGRST_DB_SCHEMAS=public',
    '-e',
    'PGRST_DB_ANON_ROLE=anon',
    '-e',
    `PGRST_JWT_SECRET=${jwtSecret}`,
    '-d',
    'postgrest/postgrest:v14.12',
  ]);
  const portOutput = docker(['port', postgrestName, '3000/tcp']);
  const postgrestPort = portOutput.match(/:(\d+)$/)?.[1];
  if (!postgrestPort) throw new Error('No fue posible determinar el puerto de PostgREST.');
  const postgrestUrl = `http://127.0.0.1:${postgrestPort}`;
  await waitUntil(async () => (await fetch(postgrestUrl)).ok, 'PostgREST');

  startWebServer(postgrestUrl, createAccessToken());
  await waitUntil(async () => (await fetch('http://127.0.0.1:4173')).ok, 'Aplicación web');
  const browserExitCode = await runBrowser();
  if (browserExitCode !== 0) throw new Error('Falló el recorrido conectado de navegador.');
  assertDatabase();
  console.log('CONNECTED-VERIFY PASS | UI + PostgREST 14.12 + PostgreSQL 17 + RLS + auditoría');
  exitCode = 0;
} catch (error) {
  console.error(error instanceof Error ? error.message : error);
} finally {
  cleanup();
}

process.exitCode = exitCode;
