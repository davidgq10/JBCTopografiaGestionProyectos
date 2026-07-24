import { existsSync } from 'node:fs';
import { readFile, readdir } from 'node:fs/promises';
import { dirname, join, relative, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = fileURLToPath(new URL('..', import.meta.url));

async function collect(directory) {
  const files = [];
  for (const entry of await readdir(directory, { withFileTypes: true })) {
    const path = join(directory, entry.name);
    if (entry.isDirectory()) files.push(...(await collect(path)));
    else if (/\.(ts|tsx)$/.test(entry.name) && !entry.name.endsWith('.d.ts')) files.push(path);
  }
  return files;
}

const forbiddenByArea = new Map([
  [join(root, 'packages', 'domain'), ['react', '@supabase/', '@mantine/', 'openai']],
  [join(root, 'packages', 'application'), ['react', '@supabase/', '@mantine/']],
]);

const findings = [];
for (const [directory, forbidden] of forbiddenByArea) {
  for (const file of await collect(directory)) {
    const source = await readFile(file, 'utf8');
    for (const dependency of forbidden) {
      if (source.includes(`from '${dependency}`) || source.includes(`from "${dependency}`)) {
        findings.push(`${file}: dependencia prohibida ${dependency}`);
      }
    }
  }
}

const sourceRoots = [
  join(root, 'packages', 'domain', 'src'),
  join(root, 'packages', 'application', 'src'),
  join(root, 'packages', 'contracts', 'src'),
  join(root, 'packages', 'testing', 'src'),
  join(root, 'apps', 'web', 'src'),
];
const sourceFiles = (await Promise.all(sourceRoots.map(collect))).flat();
const sourceSet = new Set(sourceFiles.map((path) => resolve(path)));
const workspaceEntries = new Map(
  ['domain', 'application', 'contracts', 'testing'].map((name) => [
    `@jbc/${name}`,
    resolve(root, 'packages', name, 'src', 'index.ts'),
  ]),
);

function resolveImport(importer, specifier) {
  if (workspaceEntries.has(specifier)) return workspaceEntries.get(specifier);
  if (!specifier.startsWith('.')) return null;
  const base = resolve(dirname(importer), specifier);
  const candidates = [
    base,
    `${base}.ts`,
    `${base}.tsx`,
    base.replace(/\.js$/, '.ts'),
    base.replace(/\.js$/, '.tsx'),
    join(base, 'index.ts'),
    join(base, 'index.tsx'),
  ];
  return candidates.find((candidate) => existsSync(candidate)) ?? null;
}

const graph = new Map(sourceFiles.map((file) => [resolve(file), new Set()]));
const importPattern = /\b(?:import|export)\s+(?:type\s+)?(?:[^'";]*?\s+from\s+)?['"]([^'"]+)['"]/g;
for (const file of sourceFiles) {
  const source = await readFile(file, 'utf8');
  for (const match of source.matchAll(importPattern)) {
    const target = resolveImport(file, match[1]);
    if (target && sourceSet.has(resolve(target))) graph.get(resolve(file)).add(resolve(target));
  }
}

const visiting = new Set();
const visited = new Set();
const stack = [];
const cycles = [];

function visit(node) {
  if (visiting.has(node)) {
    const start = stack.indexOf(node);
    cycles.push([...stack.slice(start), node].map((path) => relative(root, path)).join(' -> '));
    return;
  }
  if (visited.has(node)) return;
  visiting.add(node);
  stack.push(node);
  for (const target of graph.get(node) ?? []) visit(target);
  stack.pop();
  visiting.delete(node);
  visited.add(node);
}

for (const file of graph.keys()) visit(file);
for (const cycle of cycles) findings.push(`ciclo de imports: ${cycle}`);

if (findings.length > 0) {
  throw new Error(`Límites de arquitectura incumplidos:\n${findings.join('\n')}`);
}

const edgeCount = [...graph.values()].reduce((total, edges) => total + edges.size, 0);
console.log(
  `ARCHITECTURE PASS | ${graph.size} archivos y ${edgeCount} imports internos sin ciclos; dominio/aplicación aislados`,
);
