import { readFileSync, readdirSync, statSync } from 'node:fs';
import { join, resolve } from 'node:path';

// Aristas proveedor estable -> consumidor, congeladas en MODULE_BOUNDARIES.md.
const graph = {
  contracts: [
    'audit',
    'identity',
    'administration',
    'clients',
    'approvals',
    'notifications',
    'ai',
    'projects',
    'managements',
    'tasks',
    'scheduling',
    'external-procedures',
    'documents',
  ],
  audit: [
    'identity',
    'administration',
    'clients',
    'approvals',
    'notifications',
    'ai',
    'projects',
    'managements',
    'tasks',
    'scheduling',
    'external-procedures',
    'documents',
  ],
  identity: [
    'administration',
    'clients',
    'approvals',
    'notifications',
    'ai',
    'projects',
    'managements',
    'tasks',
    'scheduling',
    'external-procedures',
    'documents',
  ],
  administration: ['projects', 'managements', 'tasks', 'scheduling', 'documents'],
  clients: ['projects'],
  projects: ['managements', 'tasks', 'external-procedures', 'documents', 'read-models'],
  managements: ['tasks', 'read-models'],
  tasks: ['scheduling', 'read-models'],
  approvals: ['read-models'],
  notifications: ['read-models'],
  ai: ['read-models'],
  'external-procedures': ['read-models'],
  documents: ['read-models'],
  scheduling: ['read-models'],
  'read-models': [],
};

const visiting = new Set();
const visited = new Set();
const stack = [];
const cycles = [];

function visit(node) {
  if (visiting.has(node)) {
    const start = stack.indexOf(node);
    cycles.push([...stack.slice(start), node].join(' -> '));
    return;
  }
  if (visited.has(node)) return;
  visiting.add(node);
  stack.push(node);
  for (const next of graph[node] ?? []) visit(next);
  stack.pop();
  visiting.delete(node);
  visited.add(node);
}

for (const node of Object.keys(graph)) visit(node);

const sourceRoot = resolve(import.meta.dirname, '..', 'src');
const sourceFiles = readdirSync(sourceRoot)
  .map((name) => join(sourceRoot, name))
  .filter((path) => statSync(path).isFile() && path.endsWith('.ts'));
const source = sourceFiles.map((path) => readFileSync(path, 'utf8')).join('\n');
const forbiddenImports = [
  /from\s+['"]react(?:\/|['"])/i,
  /from\s+['"]@supabase\//i,
  /from\s+['"]@microsoft\//i,
  /from\s+['"]openai(?:\/|['"])/i,
];
const importFailures = forbiddenImports.filter((pattern) => pattern.test(source));

if (cycles.length || importFailures.length) {
  console.error('F2 DAG verification failed');
  for (const cycle of cycles) console.error(`- ciclo: ${cycle}`);
  for (const pattern of importFailures) console.error(`- import prohibido: ${pattern}`);
  process.exit(1);
}

console.log(
  `F2 DAG verification passed (${Object.keys(graph).length} nodes, ${visited.size} visited)`,
);
