import { createBrowserRouter } from 'react-router-dom';

import { ProtectedLayout } from './protected-layout.js';
import { AppearancePage } from '../pages/appearance-page.js';
import { DashboardPage } from '../pages/dashboard-page.js';
import { LoginPage } from '../pages/login-page.js';
import { PlaceholderPage } from '../pages/placeholder-page.js';
import { RouteErrorPage } from '../pages/route-error-page.js';
import { SettingsPage } from '../pages/settings-page.js';

export const router = createBrowserRouter([
  { path: '/iniciar-sesion', element: <LoginPage />, errorElement: <RouteErrorPage /> },
  {
    path: '/',
    element: <ProtectedLayout />,
    errorElement: <RouteErrorPage />,
    children: [
      { index: true, element: <DashboardPage /> },
      { path: 'perfil/apariencia', element: <AppearancePage /> },
      { path: 'configuracion', element: <SettingsPage /> },
      { path: 'proyectos', element: <PlaceholderPage title="Proyectos" phase={5} /> },
      { path: 'tareas', element: <PlaceholderPage title="Tareas" phase={6} /> },
      { path: 'agenda', element: <PlaceholderPage title="Agenda" phase={6} /> },
      { path: 'notificaciones', element: <PlaceholderPage title="Avisos" phase={8} /> },
      { path: '*', element: <PlaceholderPage title="Página no encontrada" phase={3} /> },
    ],
  },
]);
