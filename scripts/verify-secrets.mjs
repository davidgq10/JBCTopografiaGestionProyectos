import { readFile, readdir } from 'node:fs/promises';
import { extname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = fileURLToPath(new URL('..', import.meta.url));
const ignored = new Set([
  'node_modules',
  '.pnpm-store',
  'dist',
  'coverage',
  '.git',
  'storybook-static',
  'playwright-report',
  'test-results',
]);
const allowedExtensions = new Set([
  '.ts',
  '.tsx',
  '.js',
  '.mjs',
  '.json',
  '.yml',
  '.yaml',
  '.toml',
  '.md',
  '.css',
  '.html',
  '.ps1',
  '.sql',
  '.psql',
  '.sh',
]);
const patterns = [
  /SUPABASE_SERVICE_ROLE_KEY\s*=\s*[^R\s][^\s]*/i,
  /VITE_[A-Z0-9_]*(?:SECRET|SERVICE_ROLE|PRIVATE_KEY|PASSWORD|TOKEN)\s*=/i,
  /-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----/,
  /sk-(?:proj-)?[A-Za-z0-9_-]{20,}/,
  /gh[opsu]_[A-Za-z0-9]{30,}/,
  /eyJ[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}/,
];

async function walk(directory) {
  const files = [];
  for (const entry of await readdir(directory, { withFileTypes: true })) {
    if (ignored.has(entry.name)) continue;
    const path = join(directory, entry.name);
    if (entry.isDirectory()) files.push(...(await walk(path)));
    else if (entry.name.startsWith('.env') || allowedExtensions.has(extname(entry.name))) {
      files.push(path);
    }
  }
  return files;
}

const findings = [];
for (const file of await walk(root)) {
  const source = await readFile(file, 'utf8');
  if (patterns.some((pattern) => pattern.test(source))) findings.push(file);
}

if (findings.length > 0) throw new Error(`Posibles secretos detectados:\n${findings.join('\n')}`);
console.log('SECRETS PASS | no se detectaron patrones de credenciales');
