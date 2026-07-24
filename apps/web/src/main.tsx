import '@mantine/core/styles.css';
import '@mantine/notifications/styles.css';
import './styles.css';

import { RouterProvider } from 'react-router-dom';
import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { registerSW } from 'virtual:pwa-register';

import { createRuntimeServices } from '@runtime-services';
import { AppProviders } from './app/app-providers.js';
import { router } from './app/router.js';

registerSW({ immediate: true });

const root = document.getElementById('root');
if (!root) throw new Error('No se encontró el contenedor principal.');

createRoot(root).render(
  <StrictMode>
    <AppProviders services={createRuntimeServices()}>
      <RouterProvider router={router} />
    </AppProviders>
  </StrictMode>,
);
