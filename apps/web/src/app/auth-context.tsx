import {
  createContext,
  type PropsWithChildren,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
} from 'react';

import type { AuthenticatedSession } from '../infrastructure/services.js';
import { userFacingError } from '../infrastructure/services.js';
import { useServices } from './services-context.js';

interface AuthContextValue {
  session: AuthenticatedSession | null;
  status: 'loading' | 'authenticated' | 'anonymous';
  initializationError: string | null;
  signIn(): Promise<void>;
  signOut(): Promise<void>;
}

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: PropsWithChildren) {
  const services = useServices();
  const [session, setSession] = useState<AuthenticatedSession | null>(null);
  const [status, setStatus] = useState<AuthContextValue['status']>('loading');
  const [initializationError, setInitializationError] = useState<string | null>(null);

  useEffect(() => {
    let mounted = true;
    void services.session
      .getCurrentSession()
      .then((current) => {
        if (!mounted) return;
        setSession(current);
        setInitializationError(null);
        setStatus(current ? 'authenticated' : 'anonymous');
      })
      .catch((error: unknown) => {
        if (!mounted) return;
        setSession(null);
        setInitializationError(userFacingError(error));
        setStatus('anonymous');
      });
    const unsubscribe = services.session.subscribe((current) => {
      setSession(current);
      setInitializationError(null);
      setStatus(current ? 'authenticated' : 'anonymous');
    });
    return () => {
      mounted = false;
      unsubscribe();
    };
  }, [services.session]);

  const signIn = useCallback(
    async () => services.session.signInWithMicrosoft(),
    [services.session],
  );
  const signOut = useCallback(async () => services.session.signOut(), [services.session]);
  const value = useMemo(
    () => ({ session, status, initializationError, signIn, signOut }),
    [initializationError, session, signIn, signOut, status],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth(): AuthContextValue {
  const context = useContext(AuthContext);
  if (!context) throw new Error('AuthProvider no está disponible.');
  return context;
}
