import { existsSync, readFileSync, readdirSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const repositoryRoot = resolve(fileURLToPath(new URL('..', import.meta.url)));
const testDirectory = join(repositoryRoot, 'supabase', 'tests');
const migrationDirectory = join(repositoryRoot, 'supabase', 'migrations');

const requiredFiles = [
  '00_surface_manifest.sql',
  '10_rls_structure.sql',
  '20_rls_matrix.sql',
  '30_case_data.sql',
  'run_structure.psql',
  'run_rls.psql',
  'README.md',
];

const missingFiles = requiredFiles.filter((fileName) => !existsSync(join(testDirectory, fileName)));
if (missingFiles.length > 0)
  throw new Error(`Faltan archivos del arnés: ${missingFiles.join(', ')}`);

const migrationSql = readdirSync(migrationDirectory)
  .filter((fileName) => fileName.endsWith('.sql'))
  .sort()
  .map((fileName) => readFileSync(join(migrationDirectory, fileName), 'utf8'))
  .join('\n');

function uniqueMatches(source, expression) {
  return [...new Set([...source.matchAll(expression)].map((match) => match[1]))].sort();
}

const migrationTables = uniqueMatches(
  migrationSql,
  /^create\s+table\s+public\.([a-z_][a-z0-9_]*)/gim,
);
const manifestSql = readFileSync(join(testDirectory, '00_surface_manifest.sql'), 'utf8');
const manifestTables = uniqueMatches(manifestSql, /^\s*\('([a-z_][a-z0-9_]*)',\s*'table'/gm);

const missingInManifest = migrationTables.filter((table) => !manifestTables.includes(table));
const extraInManifest = manifestTables.filter((table) => !migrationTables.includes(table));
if (missingInManifest.length > 0 || extraInManifest.length > 0) {
  throw new Error(
    `Inventario distinto de migraciones: faltan [${missingInManifest.join(', ')}]; sobran [${extraInManifest.join(', ')}]`,
  );
}

const publicViews = [...migrationSql.matchAll(/^create\s+(?:materialized\s+)?view\s+public\./gim)];
const publicFunctions = [
  ...migrationSql.matchAll(/^create\s+(?:or\s+replace\s+)?function\s+public\./gim),
];
if (publicViews.length > 0 || publicFunctions.length > 0) {
  throw new Error('Existe una vista o función en public; debe inventariarse y revisarse.');
}

const runnerSql = readFileSync(join(testDirectory, 'run_rls.psql'), 'utf8');
if (!/\\set\s+dec_0103_approved\s+'0'/.test(runnerSql)) {
  throw new Error('run_rls.psql no conserva el valor fail-closed predeterminado para DEC-0103.');
}
if (
  !/\\ir\s+10_rls_structure\.sql/.test(runnerSql) ||
  !/\\ir\s+20_rls_matrix\.sql/.test(runnerSql)
) {
  throw new Error('run_rls.psql no enlaza estructura y matriz funcional.');
}

const caseDataSql = readFileSync(join(testDirectory, '30_case_data.sql'), 'utf8');
const functionalMigration = join(
  migrationDirectory,
  '20260723091900_f2_functional_rls_dec_0103.sql',
);
if (!existsSync(functionalMigration)) throw new Error('Falta la migración funcional de DEC-0103.');
if (!/^\s*insert\s+into\s+rls_test_cases/im.test(caseDataSql)) {
  throw new Error('30_case_data.sql no contiene los casos funcionales aprobados de DEC-0103.');
}
if (!caseDataSql.includes('DEC-0103 aprobada')) {
  throw new Error('30_case_data.sql no registra la decisión que autoriza sus casos.');
}

console.log('RLS-STATIC PASS');
console.log(`MigrationTables: ${migrationTables.length}`);
console.log(`ManifestTables: ${manifestTables.length}`);
console.log(`PublicViews: ${publicViews.length}`);
console.log(`PublicFunctions: ${publicFunctions.length}`);
console.log('DecisionGateDefault: 0');
console.log('FunctionalCasesFrozen: generated-and-gated');
