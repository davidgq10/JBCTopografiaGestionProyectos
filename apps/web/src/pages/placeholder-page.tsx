import { Text, Title } from '@mantine/core';

import { PageShell } from '../components/page-shell.js';

export function PlaceholderPage({ title, phase }: { title: string; phase: number }) {
  return (
    <PageShell title={title} description={`Esta capacidad corresponde a la Fase ${String(phase)}.`}>
      <section className="surfaceSection emptySection" aria-labelledby="pending-title">
        <Title order={2} id="pending-title">
          Aún no disponible
        </Title>
        <Text c="dimmed">
          El esqueleto conserva esta ubicación aprobada, pero no adelanta datos ni operaciones de
          una fase posterior.
        </Text>
      </section>
    </PageShell>
  );
}
