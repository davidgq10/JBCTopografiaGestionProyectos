import { spawn } from 'node:child_process';
import process from 'node:process';

const host = '127.0.0.1';
const port = 4173;
const url = `http://${host}:${port}`;

const server = spawn(
  process.execPath,
  ['node_modules/vite/bin/vite.js', '--mode', 'test', '--host', host, '--port', String(port)],
  {
    cwd: process.cwd(),
    stdio: 'ignore',
    windowsHide: true,
  },
);

async function waitForServer() {
  const deadline = Date.now() + 60_000;
  while (Date.now() < deadline) {
    if (server.exitCode !== null) throw new Error('El servidor E2E terminó antes de iniciar.');
    try {
      const response = await fetch(url);
      if (response.ok) return;
    } catch {
      // El servidor todavía está iniciando.
    }
    await new Promise((resolve) => setTimeout(resolve, 250));
  }
  throw new Error('El servidor E2E no respondió dentro de 60 segundos.');
}

function runPlaywright() {
  return new Promise((resolve, reject) => {
    const test = spawn(
      process.execPath,
      ['node_modules/@playwright/test/cli.js', 'test', ...process.argv.slice(2)],
      {
        cwd: process.cwd(),
        env: { ...process.env, PW_EXTERNAL_SERVER: '1' },
        stdio: 'inherit',
        windowsHide: true,
      },
    );
    test.once('error', reject);
    test.once('exit', (code) => resolve(code ?? 1));
  });
}

let exitCode = 1;
try {
  await waitForServer();
  exitCode = await runPlaywright();
} catch (error) {
  console.error(error instanceof Error ? error.message : error);
} finally {
  server.kill();
}

process.exitCode = exitCode;
