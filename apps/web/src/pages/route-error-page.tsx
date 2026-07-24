import { Button, Center, Stack, Text, Title } from '@mantine/core';
import { useRouteError } from 'react-router-dom';

import { userFacingError } from '../infrastructure/services.js';

export function RouteErrorPage() {
  const error = useRouteError();
  return (
    <Center mih="100vh" p="lg">
      <Stack align="center" ta="center" maw={560}>
        <Title order={1}>La vista no pudo abrirse</Title>
        <Text>{userFacingError(error)}</Text>
        <Button component="a" href="/">
          Volver al inicio
        </Button>
      </Stack>
    </Center>
  );
}
