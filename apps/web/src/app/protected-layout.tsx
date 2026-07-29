import { useMantineColorScheme } from '@mantine/core';
import { useEffect } from 'react';
import { useRef } from 'react';
import { Navigate } from 'react-router-dom';

import { AppNavigation } from '../components/app-navigation.js';
import { LoadingState, PermissionState } from '../components/system-state.js';
import { userFacingError } from '../infrastructure/services.js';
import { OfflinePage } from '../pages/offline-page.js';
import { useAccent } from './accent-context.js';
import { useAuth } from './auth-context.js';
import { useOwnProfile } from './profile-queries.js';
import { useOnlineStatus } from './use-online-status.js';

export function ProtectedLayout() {
  const { session, status } = useAuth();
  const online = useOnlineStatus();
  const profile = useOwnProfile(status === 'authenticated' && online);
  const { applyAccent } = useAccent();
  const { setColorScheme } = useMantineColorScheme();
  const appliedProfileVersion = useRef<number | null>(null);

  useEffect(() => {
    if (!profile.data || appliedProfileVersion.current === profile.data.version) return;
    appliedProfileVersion.current = profile.data.version;
    applyAccent(profile.data.preferredAccent);
    setColorScheme(profile.data.preferredTheme);
  }, [applyAccent, profile.data, setColorScheme]);

  if (status === 'loading') return <LoadingState label="Comprobando su acceso…" />;
  if (!session) return <Navigate to="/iniciar-sesion" replace />;
  if (!online) return <AppNavigation content={<OfflinePage />} />;
  if (profile.isPending) return <LoadingState label="Aplicando permisos de su perfil…" />;
  if (profile.isError || !profile.data)
    return <PermissionState message={userFacingError(profile.error)} />;
  return <AppNavigation mobileNavItems={profile.data.mobileNavItems} />;
}
