import { Alert, Button, Center, Stack, Text, ThemeIcon, Title } from '@mantine/core';
import { IconBrandWindows, IconMap2 } from '@tabler/icons-react';
import { useState } from 'react';
import { Navigate } from 'react-router-dom';

import { useAuth } from '../app/auth-context.js';
import { useServices } from '../app/services-context.js';
import { useOnlineStatus } from '../app/use-online-status.js';
import { userFacingError } from '../infrastructure/services.js';
import { LoadingState } from '../components/system-state.js';

export function LoginPage() {
  const { configured, configurationMessage } = useServices();
  const online = useOnlineStatus();
  const { initializationError, session, signIn, status } = useAuth();
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  if (status === 'loading') return <LoadingState label="Comprobando sesión segura…" />;
  if (session) return <Navigate to="/" replace />;

  const handleSignIn = async () => {
    setSubmitting(true);
    setError(null);
    try {
      await signIn();
    } catch (cause) {
      setError(userFacingError(cause));
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <Center className="loginPage">
      <Stack className="loginPanel" gap="lg" align="stretch">
        <ThemeIcon size={56} radius="lg" className="accentBackground">
          <IconMap2 aria-hidden="true" />
        </ThemeIcon>
        <Stack gap="xs">
          <Title order={1}>JBC Proyectos</Title>
          <Text c="dimmed">
            Ingrese con su cuenta corporativa autorizada. Microsoft aplica el acceso multifactor y
            Supabase vuelve a validar su alcance.
          </Text>
        </Stack>
        {!configured ? (
          <Alert color="yellow" title="Entorno pendiente de configurar">
            {configurationMessage}
          </Alert>
        ) : null}
        {!online ? (
          <Alert color="yellow" title="Sin conexión" role="status">
            El shell está disponible. Reconéctese para iniciar sesión y consultar datos protegidos.
          </Alert>
        ) : null}
        {error ? <Alert color="red">{error}</Alert> : null}
        {!error && initializationError ? (
          <Alert color="red" title="No se pudo comprobar la sesión">
            {initializationError}
          </Alert>
        ) : null}
        <Button
          className="primaryAction"
          leftSection={<IconBrandWindows aria-hidden="true" />}
          loading={submitting}
          disabled={!configured || !online}
          onClick={() => void handleSignIn()}
        >
          Entrar con Microsoft
        </Button>
        <Text size="sm" c="dimmed">
          El acceso se limita al tenant JBC y a cuentas preautorizadas. Esta aplicación nunca recibe
          su contraseña de Microsoft.
        </Text>
      </Stack>
    </Center>
  );
}
