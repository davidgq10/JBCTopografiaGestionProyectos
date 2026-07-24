/// <reference types="vite/client" />
/// <reference types="vite-plugin-pwa/client" />

declare const __APP_VERSION__: string;

declare module '@runtime-services' {
  export function createRuntimeServices(): import('./infrastructure/services').AppServices;
}
