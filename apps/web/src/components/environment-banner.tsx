import { Alert, Text } from '@mantine/core';
import { IconFlask } from '@tabler/icons-react';

import { useServices } from '../app/services-context.js';

export function EnvironmentBanner() {
  const { environment, version } = useServices();
  if (environment === 'production') return null;
  return (
    <Alert
      className="environmentBanner"
      icon={<IconFlask aria-hidden="true" />}
      color="blue"
      role="status"
    >
      <Text size="sm">
        Entorno {environment} · versión {version}. No use datos reales en este ambiente.
      </Text>
    </Alert>
  );
}
