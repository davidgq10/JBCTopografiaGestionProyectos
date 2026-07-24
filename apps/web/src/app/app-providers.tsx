import { MantineProvider } from '@mantine/core';
import { Notifications } from '@mantine/notifications';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { type PropsWithChildren, useState } from 'react';

import type { AppServices } from '../infrastructure/services.js';
import { jbcCssVariablesResolver, jbcTheme } from '../theme.js';
import { AccentProvider } from './accent-context.js';
import { AuthProvider } from './auth-context.js';
import { ServicesProvider } from './services-context.js';

export function AppProviders({ children, services }: PropsWithChildren<{ services: AppServices }>) {
  const [queryClient] = useState(
    () =>
      new QueryClient({
        defaultOptions: {
          queries: { refetchOnWindowFocus: false },
          mutations: { retry: false },
        },
      }),
  );

  return (
    <MantineProvider
      theme={jbcTheme}
      cssVariablesResolver={jbcCssVariablesResolver}
      defaultColorScheme="auto"
    >
      <ServicesProvider services={services}>
        <QueryClientProvider client={queryClient}>
          <AccentProvider>
            <AuthProvider>
              <Notifications position="top-right" />
              {children}
            </AuthProvider>
          </AccentProvider>
        </QueryClientProvider>
      </ServicesProvider>
    </MantineProvider>
  );
}
