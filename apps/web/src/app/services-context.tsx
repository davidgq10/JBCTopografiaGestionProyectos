import { createContext, type PropsWithChildren, useContext } from 'react';

import type { AppServices } from '../infrastructure/services.js';

const ServicesContext = createContext<AppServices | null>(null);

export function ServicesProvider({
  children,
  services,
}: PropsWithChildren<{ services: AppServices }>) {
  return <ServicesContext.Provider value={services}>{children}</ServicesContext.Provider>;
}

export function useServices(): AppServices {
  const services = useContext(ServicesContext);
  if (!services) throw new Error('ServicesProvider no está disponible.');
  return services;
}
