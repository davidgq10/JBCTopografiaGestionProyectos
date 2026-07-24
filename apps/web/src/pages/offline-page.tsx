import { Alert, List, Stack, Text, Title } from '@mantine/core';
import { IconWifiOff } from '@tabler/icons-react';

import { PageShell } from '../components/page-shell.js';

export function OfflinePage() {
  return (
    <PageShell
      title="Sin conexión"
      description="La estructura de JBC Proyectos sigue disponible, pero no se muestran datos guardados ni se permiten modificaciones."
    >
      <section className="surfaceSection" aria-labelledby="offline-title">
        <Stack gap="md">
          <Alert
            icon={<IconWifiOff aria-hidden="true" />}
            color="yellow"
            title="Esperando conexión segura"
            role="status"
          >
            Reconéctese para volver a validar su sesión y consultar información protegida.
          </Alert>
          <div>
            <Title order={2} id="offline-title">
              Protección sin conexión
            </Title>
            <Text>Mientras no haya red:</Text>
          </div>
          <List>
            <List.Item>no se recuperan perfiles, proyectos ni otros datos de Supabase;</List.Item>
            <List.Item>no se envían escrituras ni se guardan cambios pendientes;</List.Item>
            <List.Item>solo permanece disponible el shell estático de la aplicación.</List.Item>
          </List>
        </Stack>
      </section>
    </PageShell>
  );
}
