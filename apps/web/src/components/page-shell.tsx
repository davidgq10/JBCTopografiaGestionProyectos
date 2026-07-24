import { Box, Group, Stack, Text, Title } from '@mantine/core';
import type { PropsWithChildren, ReactNode } from 'react';

export function PageShell({
  title,
  description,
  actions,
  children,
}: PropsWithChildren<{ title: string; description?: string; actions?: ReactNode }>) {
  return (
    <Box className="pageShell">
      <Group className="pageHeader" align="flex-start" justify="space-between" wrap="wrap">
        <Stack gap={4} className="pageHeading">
          <Title order={1}>{title}</Title>
          {description ? (
            <Text c="dimmed" maw={720}>
              {description}
            </Text>
          ) : null}
        </Stack>
        {actions}
      </Group>
      <Stack gap={32}>{children}</Stack>
    </Box>
  );
}
