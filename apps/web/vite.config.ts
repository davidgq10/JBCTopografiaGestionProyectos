import { resolve } from 'node:path';
import react from '@vitejs/plugin-react';
import { defineConfig } from 'vite';
import { VitePWA } from 'vite-plugin-pwa';

import packageJson from './package.json';

export default defineConfig(({ mode }) => {
  const connectedPostgrestUrl = process.env.JBC_CONNECTED_POSTGREST_URL;
  if (mode === 'connected-test' && !connectedPostgrestUrl) {
    throw new Error('Defina JBC_CONNECTED_POSTGREST_URL para ejecutar el modo conectado.');
  }

  return {
    plugins: [
      react(),
      VitePWA({
        strategies: 'injectManifest',
        srcDir: 'src',
        filename: 'sw.ts',
        registerType: 'prompt',
        injectManifest: {
          globPatterns: ['**/*.{js,css,html,svg,png,woff2}'],
        },
        manifest: {
          name: 'JBC Proyectos',
          short_name: 'JBC',
          description: 'Control de proyectos de JBC Topografía',
          theme_color: '#0F766E',
          background_color: '#F5F5F5',
          display: 'standalone',
          lang: 'es-CR',
          start_url: '/',
          icons: [
            { src: '/pwa-192.svg', sizes: '192x192', type: 'image/svg+xml' },
            { src: '/pwa-512.svg', sizes: '512x512', type: 'image/svg+xml' },
          ],
        },
      }),
    ],
    resolve: {
      alias: {
        '@runtime-services': resolve(
          __dirname,
          mode === 'test'
            ? 'src/testing/test-services.ts'
            : mode === 'connected-test'
              ? 'src/testing/connected-services.ts'
              : 'src/infrastructure/create-services.ts',
        ),
      },
    },
    define: {
      __APP_VERSION__: JSON.stringify(packageJson.version),
    },
    server: {
      port: 4173,
      strictPort: true,
      ...(mode === 'connected-test'
        ? {
            proxy: {
              '/rest/v1': {
                target: connectedPostgrestUrl!,
                changeOrigin: true,
                rewrite: (path: string) => path.replace(/^\/rest\/v1/, ''),
                headers: {
                  authorization: `Bearer ${process.env.JBC_CONNECTED_JWT ?? ''}`,
                },
              },
            },
          }
        : {}),
    },
    preview: {
      port: 4173,
      strictPort: true,
    },
  };
});
