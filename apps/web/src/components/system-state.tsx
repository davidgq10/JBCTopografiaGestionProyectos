import { Alert, Button, Center, Loader, Stack, Text, Title } from '@mantine/core';
import { IconAlertTriangle, IconLock } from '@tabler/icons-react';

export function LoadingState({ label = 'Cargando información autorizada…' }: { label?: string }) {
  return (
    <Center mih={240} role="status" aria-live="polite">
      <Stack align="center" gap="sm">
        <Loader aria-hidden="true" />
        <Text>{label}</Text>
      </Stack>
    </Center>
  );
}

export function ErrorState({
  title = 'No fue posible cargar esta vista',
  message,
  onRetry,
}: {
  title?: string;
  message: string;
  onRetry?: () => void;
}) {
  return (
    <Alert icon={<IconAlertTriangle aria-hidden="true" />} color="red" title={title}>
      <Stack gap="sm">
        <Text>{message}</Text>
        {onRetry ? (
          <Button variant="light" color="red" onClick={onRetry} w="fit-content">
            Intentar nuevamente
          </Button>
        ) : null}
      </Stack>
    </Alert>
  );
}

export function PermissionState({ message }: { message: string }) {
  return (
    <Center mih={320} px="md">
      <Stack align="center" gap="md" maw={560} ta="center">
        <IconLock size={40} aria-hidden="true" />
        <Title order={1}>Acceso no disponible</Title>
        <Text>{message}</Text>
      </Stack>
    </Center>
  );
}
