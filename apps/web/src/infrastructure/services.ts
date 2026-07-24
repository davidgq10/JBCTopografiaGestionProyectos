import type { AppearanceProfilePort } from '@jbc/application';

export interface AuthenticatedSession {
  userId: string;
  email: string;
  displayName: string;
}

export interface SessionPort {
  getCurrentSession(): Promise<AuthenticatedSession | null>;
  subscribe(listener: (session: AuthenticatedSession | null) => void): () => void;
  signInWithMicrosoft(): Promise<void>;
  signOut(): Promise<void>;
}

export interface AppServices {
  configured: boolean;
  configurationMessage?: string;
  environment: 'local' | 'development' | 'test' | 'production';
  version: string;
  featureFlags: {
    oneDrive: boolean;
    aptSiri: boolean;
    push: boolean;
    ai: boolean;
  };
  session: SessionPort;
  profile: AppearanceProfilePort;
}

export type AppErrorCode =
  | 'VALIDATION_ERROR'
  | 'UNAUTHENTICATED'
  | 'FORBIDDEN'
  | 'NOT_FOUND'
  | 'STALE_VERSION'
  | 'NETWORK_ERROR'
  | 'CONFIGURATION_ERROR'
  | 'INTERNAL_ERROR';

export class AppGatewayError extends Error {
  constructor(
    readonly code: AppErrorCode,
    message: string,
    readonly correlationId = crypto.randomUUID(),
  ) {
    super(message);
    this.name = 'AppGatewayError';
  }
}

export function userFacingError(error: unknown): string {
  if (error instanceof AppGatewayError) return error.message;
  if (error instanceof Error) return error.message;
  return 'Ocurrió un error inesperado. Intente nuevamente.';
}
