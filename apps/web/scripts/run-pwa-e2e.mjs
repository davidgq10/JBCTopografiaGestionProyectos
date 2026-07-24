import { spawn } from 'node:child_process';
import process from 'node:process';

function run(command, args, options = {}) {
  return new Promise((resolve, reject) => {
    const child = spawn(command, args, {
      cwd: process.cwd(),
      stdio: 'inherit',
      windowsHide: true,
      ...options,
    });
    child.once('error', reject);
    child.once('exit', (code) => resolve(code ?? 1));
  });
}

async function waitForServer(server, url) {
  const deadline = Date.now() + 60_000;
  while (Date.now() < deadline) {
    if (server.exitCode !== null) throw new Error('La vista previa PWA terminó antes de iniciar.');
    try {
      const response = await fetch(url);
      if (response.ok) return;
    } catch {
      // La vista previa todavía está iniciando.
    }
    await new Promise((resolve) => setTimeout(resolve, 250));
  }
  throw new Error('La vista previa PWA no respondió dentro de 60 segundos.');
}

let exitCode = await run(process.execPath, [
  'node_modules/vite/bin/vite.js',
  'build',
  '--mode',
  'test',
]);

if (exitCode === 0) {
  const server = spawn(
    process.execPath,
    ['node_modules/vite/bin/vite.js', 'preview', '--host', '127.0.0.1', '--port', '4174'],
    { cwd: process.cwd(), stdio: 'ignore', windowsHide: true },
  );
  try {
    await waitForServer(server, 'http://127.0.0.1:4174');
    exitCode = await run(process.execPath, [
      'node_modules/@playwright/test/cli.js',
      'test',
      '--config=playwright.pwa.config.ts',
      '--workers=1',
    ]);
  } catch (error) {
    console.error(error instanceof Error ? error.message : error);
    exitCode = 1;
  } finally {
    server.kill();
  }
}

process.exitCode = exitCode;
