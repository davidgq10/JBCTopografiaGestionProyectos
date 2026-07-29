import { Alert, Button, Code, Divider, Group, Select, Stack, Text, Title } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { IconCheck, IconLock } from '@tabler/icons-react';
import {
  DEFAULT_MOBILE_NAVIGATION,
  type MobileNavigationItem,
  type MobileNavigationSelection,
} from '@jbc/application';
import { useEffect, useRef, useState } from 'react';

import { useOwnProfile, useUpdateOwnMobileNavigation } from '../app/profile-queries.js';
import { useServices } from '../app/services-context.js';
import { useOnlineStatus } from '../app/use-online-status.js';
import { PageShell } from '../components/page-shell.js';
import { ErrorState, LoadingState } from '../components/system-state.js';
import { AppGatewayError, userFacingError } from '../infrastructure/services.js';

const mobileNavigationLabels: Record<MobileNavigationItem, string> = {
  agenda: 'Agenda',
  avisos: 'Avisos',
  cuenta: 'Cuenta',
  proyectos: 'Proyectos',
  tareas: 'Tareas',
};

const mobileNavigationOptions = Object.entries(mobileNavigationLabels).map(([value, label]) => ({
  value,
  label,
}));

export function SettingsPage() {
  const services = useServices();
  const profile = useOwnProfile();
  const updateMobileNavigation = useUpdateOwnMobileNavigation();
  const online = useOnlineStatus();
  const [selection, setSelection] = useState<MobileNavigationSelection>([
    ...DEFAULT_MOBILE_NAVIGATION,
  ]);
  const [conflict, setConflict] = useState(false);
  const appliedProfileVersion = useRef<number | null>(null);

  useEffect(() => {
    if (!profile.data || appliedProfileVersion.current === profile.data.version) return;
    appliedProfileVersion.current = profile.data.version;
    setSelection([...profile.data.mobileNavItems]);
  }, [profile.data]);

  if (profile.isPending) return <LoadingState />;
  if (profile.isError || !profile.data) {
    return (
      <PageShell title="Configuración">
        <ErrorState
          message={userFacingError(profile.error)}
          onRetry={() => void profile.refetch()}
        />
      </PageShell>
    );
  }

  const handleSelection = (index: number, value: string | null) => {
    if (!value) return;
    setConflict(false);
    setSelection((current) => {
      const next = [...current] as MobileNavigationSelection;
      next[index] = value as MobileNavigationItem;
      return next;
    });
  };

  const optionsFor = (index: number) =>
    mobileNavigationOptions.filter(
      (option) =>
        option.value === selection[index] ||
        !selection.includes(option.value as MobileNavigationItem),
    );

  const changed = selection.some((item, index) => item !== profile.data.mobileNavItems[index]);

  const handleSave = async () => {
    try {
      await updateMobileNavigation.mutateAsync({
        mobileNavItems: selection,
        expectedVersion: profile.data.version,
      });
      setConflict(false);
      notifications.show({
        color: 'green',
        title: 'Navegación móvil actualizada',
        message: 'El orden se guardó y se sincronizará en sus dispositivos.',
        withCloseButton: false,
      });
    } catch (error) {
      if (error instanceof AppGatewayError && error.code === 'STALE_VERSION') {
        await profile.refetch();
        setConflict(true);
        notifications.show({
          color: 'yellow',
          title: 'La configuración cambió en otra sesión',
          message: 'Recargamos el orden vigente. Revíselo y vuelva a guardar para confirmar.',
          withCloseButton: false,
        });
        return;
      }
      notifications.show({
        color: 'red',
        title: 'No se guardó la navegación',
        message: userFacingError(error),
        withCloseButton: false,
      });
    }
  };

  return (
    <PageShell
      title="Configuración"
      description="Personalice los accesos del panel móvil y revise esta instalación."
    >
      {!online ? (
        <Alert color="yellow" role="status">
          Está sin conexión. Puede revisar la configuración, pero debe reconectarse para guardar.
        </Alert>
      ) : null}
      {conflict ? (
        <Alert color="yellow" title="Configuración actualizada" role="alert">
          Otra sesión guardó este panel mientras lo editaba. Se mostró el orden más reciente;
          revíselo antes de confirmar.
        </Alert>
      ) : null}

      <section className="surfaceSection" aria-labelledby="mobile-navigation-title">
        <Stack gap="md">
          <div>
            <Title order={2} id="mobile-navigation-title">
              Panel móvil
            </Title>
            <Text c="dimmed">
              Elija y ordene tres accesos intermedios. Inicio siempre queda primero y Más siempre
              queda al final.
            </Text>
          </div>

          <Group align="flex-end" gap="sm" wrap="wrap" aria-label="Orden del panel móvil">
            <Group gap="xs" wrap="nowrap" className="mobileNavFixedItem">
              <IconLock size={18} aria-hidden="true" />
              <Text fw={600}>Inicio</Text>
            </Group>
            {selection.map((item, index) => (
              <Select
                key={`mobile-nav-slot-${String(index)}`}
                label={`Acceso ${String(index + 1)}`}
                value={item}
                data={optionsFor(index)}
                onChange={(value) => handleSelection(index, value)}
                allowDeselect={false}
                searchable={false}
                size="md"
                className="mobileNavSelect"
              />
            ))}
            <Group gap="xs" wrap="nowrap" className="mobileNavFixedItem">
              <IconLock size={18} aria-hidden="true" />
              <Text fw={600}>Más</Text>
            </Group>
          </Group>

          <Text size="sm" c="dimmed">
            Los accesos no seleccionados permanecen disponibles dentro de Más, junto con
            Configuración.
          </Text>

          <Button
            className="primaryAction"
            leftSection={<IconCheck aria-hidden="true" />}
            disabled={!online || !changed}
            loading={updateMobileNavigation.isPending}
            onClick={() => void handleSave()}
            w="fit-content"
          >
            Guardar panel móvil
          </Button>
        </Stack>
      </section>

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
