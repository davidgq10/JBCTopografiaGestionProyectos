import { Code, Divider, Group, Stack, Text, Title } from '@mantine/core';

import { useServices } from '../app/services-context.js';
import { PageShell } from '../components/page-shell.js';

export function SettingsPage() {
  const services = useServices();
  return (
    <PageShell
      title="Configuración"
      description="Información de esta instalación y accesos autorizados."
    >
      <section className="surfaceSection" aria-labelledby="installation-title">
        <Title order={2} id="installation-title">
          Instalación
        </Title>
        <Divider my="lg" />
        <Stack gap="md">
          <Group justify="space-between" wrap="wrap">
            <Text c="dimmed">Entorno</Text>
            <Text>{services.environment}</Text>
          </Group>
          <Group justify="space-between" wrap="wrap">
            <Text c="dimmed">Versión</Text>
            <Code>{services.version}</Code>
          </Group>
          <Group justify="space-between" wrap="wrap">
            <Text c="dimmed">Conexión de aplicación</Text>
            <Text>{services.configured ? 'Configurada' : 'Pendiente'}</Text>
          </Group>
          <Group justify="space-between" wrap="wrap">
            <Text c="dimmed">Integraciones de fases futuras</Text>
            <Text>
              {Object.values(services.featureFlags).some(Boolean)
                ? 'Configuración parcial'
                : 'Desactivadas'}
            </Text>
          </Group>
        </Stack>
      </section>
    </PageShell>
  );
}
