import { readdirSync } from 'node:fs';
import { extname, join, resolve } from 'node:path';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const databaseUrl = process.env.JBC_TEST_DATABASE_URL;
if (!databaseUrl) {
  throw new Error('Defina JBC_TEST_DATABASE_URL para una base PostgreSQL 17 efímera y vacía.');
}

const repositoryRoot = resolve(fileURLToPath(new URL('..', import.meta.url)));
const migrationsDirectory = join(repositoryRoot, 'supabase', 'migrations');

function runPsql(relativePath, variables = []) {
  const filePath = join(repositoryRoot, relativePath);
  const argumentsList = [databaseUrl, '-X', '-v', 'ON_ERROR_STOP=1'];
  for (const variable of variables) argumentsList.push('-v', variable);
  argumentsList.push('-f', filePath);

  const result = spawnSync('psql', argumentsList, {
    stdio: 'inherit',
    shell: process.platform === 'win32',
  });
  if (result.error) throw result.error;
  if (result.status !== 0) throw new Error(`Falló psql al ejecutar ${relativePath}`);
}

runPsql(join('supabase', 'tests', 'bootstrap_supabase_roles.sql'));

for (const fileName of readdirSync(migrationsDirectory)
  .filter((fileName) => extname(fileName) === '.sql')
  .sort()) {
  runPsql(join('supabase', 'migrations', fileName));
}

runPsql(join('supabase', 'tests', 'run_structure.psql'));
runPsql(join('supabase', 'tests', 'run_rls.psql'), ['dec_0103_approved=1']);
runPsql(join('supabase', 'tests', '45_profile_accent_walking_skeleton.psql'));

console.log('DATABASE-VERIFY PASS | fresh migrations + RLS + F3 walking skeleton');
