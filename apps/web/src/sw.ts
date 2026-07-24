/// <reference lib="webworker" />
import { clientsClaim } from 'workbox-core';
import {
  cleanupOutdatedCaches,
  createHandlerBoundToURL,
  precacheAndRoute,
} from 'workbox-precaching';
import { NavigationRoute, registerRoute } from 'workbox-routing';
import { NetworkOnly } from 'workbox-strategies';

declare let self: ServiceWorkerGlobalScope & { __WB_MANIFEST: unknown[] };

void self.skipWaiting();
clientsClaim();
cleanupOutdatedCaches();
precacheAndRoute(self.__WB_MANIFEST);

registerRoute(
  new NavigationRoute(createHandlerBoundToURL('/index.html'), {
    denylist: [/^\/auth\/v1\//, /^\/rest\/v1\//],
  }),
);

registerRoute(
  ({ url }) => url.hostname.includes('supabase') || url.pathname.startsWith('/rest/v1/'),
  new NetworkOnly(),
  'GET',
);
registerRoute(
  ({ url }) => url.hostname.includes('supabase') || url.pathname.startsWith('/rest/v1/'),
  new NetworkOnly(),
  'POST',
);
registerRoute(
  ({ url }) => url.hostname.includes('supabase') || url.pathname.startsWith('/rest/v1/'),
  new NetworkOnly(),
  'PATCH',
);
