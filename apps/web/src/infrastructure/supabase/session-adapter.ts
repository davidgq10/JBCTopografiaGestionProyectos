import type { SupabaseClient, User } from '@supabase/supabase-js';

import { AppGatewayError, type AuthenticatedSession, type SessionPort } from '../services.js';

function toSession(user: User | null): AuthenticatedSession | null {
  if (!user) return null;
  return {
    userId: user.id,
    email: user.email ?? '',
    displayName:
      typeof user.user_metadata.name === 'string' && user.user_metadata.name.trim() !== ''
        ? user.user_metadata.name
        : (user.email ?? 'Usuario JBC'),
  };
}

export class SupabaseSessionAdapter implements SessionPort {
  constructor(private readonly client: SupabaseClient) {}

  async getCurrentSession(): Promise<AuthenticatedSession | null> {
    const { data, error } = await this.client.auth.getSession();
    if (error) throw new AppGatewayError('UNAUTHENTICATED', 'No fue posible comprobar la sesión.');
    return toSession(data.session?.user ?? null);
  }

  subscribe(listener: (session: AuthenticatedSession | null) => void): () => void {
    const { data } = this.client.auth.onAuthStateChange((_event, session) => {
      listener(toSession(session?.user ?? null));
    });
    return () => data.subscription.unsubscribe();
  }

  async signInWithMicrosoft(): Promise<void> {
    const { error } = await this.client.auth.signInWithOAuth({
      provider: 'azure',
      options: {
        redirectTo: window.location.origin,
        scopes: 'openid email profile',
      },
    });
    if (error) {
      throw new AppGatewayError(
        'UNAUTHENTICATED',
        'Microsoft no pudo iniciar la sesión. Verifique su cuenta autorizada.',
      );
    }
  }

  async signOut(): Promise<void> {
    const { error } = await this.client.auth.signOut();
    if (error) throw new AppGatewayError('NETWORK_ERROR', 'No fue posible cerrar la sesión.');
  }
}
