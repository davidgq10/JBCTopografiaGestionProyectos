import {
  loadOwnAppearanceProfile,
  updateOwnAppearance,
  updateOwnMobileNavigation,
  type AppearanceProfile,
  type MobileNavigationSelection,
} from '@jbc/application';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';

import { useServices } from './services-context.js';

export const ownProfileQueryKey = ['identity', 'own-profile'] as const;

export function useOwnProfile(enabled = true) {
  const services = useServices();
  return useQuery({
    queryKey: ownProfileQueryKey,
    queryFn: () => loadOwnAppearanceProfile(services.profile),
    enabled,
    staleTime: 30_000,
    retry: false,
  });
}

export function useUpdateOwnAppearance() {
  const services = useServices();
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: {
      preferredAccent: string;
      preferredTheme: string;
      expectedVersion: number;
    }) => updateOwnAppearance(services.profile, input),
    onSuccess: (profile: AppearanceProfile) => {
      queryClient.setQueryData(ownProfileQueryKey, profile);
    },
  });
}

export function useUpdateOwnMobileNavigation() {
  const services = useServices();
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: { mobileNavItems: MobileNavigationSelection; expectedVersion: number }) =>
      updateOwnMobileNavigation(services.profile, input),
    onSuccess: (profile: AppearanceProfile) => {
      queryClient.setQueryData(ownProfileQueryKey, profile);
    },
  });
}
