import { Badge, Group, List, Stack, Text, ThemeIcon, Title } from '@mantine/core';
import { IconCheck, IconShieldCheck } from '@tabler/icons-react';

import { useOwnProfile } from '../app/profile-queries.js';
import { PageShell } from '../components/page-shell.js';

export function DashboardPage() {
  const profile = useOwnProfile();
  return (
    <PageShell
      title={`Hola, ${profile.data?.displayName ?? 'usuario JBC'}`}
      description="La base ejecutable está lista. Los módulos operativos se incorporarán por fases sin mezclar estados ni permisos."
      actions={<Badge color="green">Sesión autorizada</Badge>}
    >
      <section aria-labelledby="skeleton-status-title" className="surfaceSection">
        <Group align="flex-start" wrap="nowrap">
          <ThemeIcon color="green" variant="light" size={44}>
            <IconShieldCheck aria-hidden="true" />
          </ThemeIcon>
          <Stack gap="sm">
            <Title order={2} id="skeleton-status-title">
              Flujo vertical protegido
            </Title>
            <Text>
              Su perfil se validó con sus permisos. Puede comprobar el guardado seguro cambiando la
              apariencia en Cuenta → Apariencia; el sistema conserva el registro del cambio.
            </Text>
            <List
              spacing="xs"
              icon={
                <ThemeIcon color="green" size={22} radius="xl">
                  <IconCheck size={14} aria-hidden="true" />
                </ThemeIcon>
              }
            >
              <List.Item>Identidad Microsoft Entra mediante Supabase Auth</List.Item>
              <List.Item>Lectura y escritura limitadas por rol y alcance</List.Item>
              <List.Item>Validación accesible en cliente y servidor</List.Item>
              <List.Item>Registro de actividad inalterable sin datos sensibles</List.Item>
            </List>
          </Stack>
        </Group>
      </section>
    </PageShell>
  );
}
