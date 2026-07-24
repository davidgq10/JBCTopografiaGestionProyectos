import {
  Alert,
  Button,
  Divider,
  Group,
  SegmentedControl,
  Stack,
  Text,
  TextInput,
  Title,
  useMantineColorScheme,
} from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { IconCheck, IconRefresh } from '@tabler/icons-react';
import { ACCENT_PRESETS, buildAccentPalette, type AccentPresetCode } from '@jbc/domain';
import { useEffect, useMemo, useRef, useState } from 'react';

import { useAccent } from '../app/accent-context.js';
import { useOwnProfile, useUpdateOwnAppearance } from '../app/profile-queries.js';
import { useOnlineStatus } from '../app/use-online-status.js';
import { PageShell } from '../components/page-shell.js';
import { ErrorState, LoadingState } from '../components/system-state.js';
import { userFacingError } from '../infrastructure/services.js';

const presetEntries = Object.entries(ACCENT_PRESETS) as [
  AccentPresetCode,
  (typeof ACCENT_PRESETS)[AccentPresetCode],
][];

export function AppearancePage() {
  const profile = useOwnProfile();
  const updateAppearance = useUpdateOwnAppearance();
  const { applyAccent } = useAccent();
  const online = useOnlineStatus();
  const { setColorScheme } = useMantineColorScheme();
  const [selection, setSelection] = useState<string>('teal');
  const [customColor, setCustomColor] = useState('#0F766E');
  const [themeSelection, setThemeSelection] = useState<'auto' | 'light' | 'dark'>('auto');
  const appliedProfileVersion = useRef<number | null>(null);

  // El perfil remoto inicializa el borrador y puede cambiar por una resolución de concurrencia.
  /* eslint-disable react-hooks/set-state-in-effect */
  useEffect(() => {
    if (!profile.data || appliedProfileVersion.current === profile.data.version) return;
    appliedProfileVersion.current = profile.data.version;
    setSelection(profile.data.preferredAccent);
    setThemeSelection(profile.data.preferredTheme);
    setColorScheme(profile.data.preferredTheme);
    if (profile.data.preferredAccent.startsWith('#')) {
      setCustomColor(profile.data.preferredAccent);
    }
    applyAccent(profile.data.preferredAccent);
  }, [applyAccent, profile.data, setColorScheme]);
  /* eslint-enable react-hooks/set-state-in-effect */

  const preview = useMemo(() => {
    try {
      return { palette: buildAccentPalette(selection), error: null };
    } catch (error) {
      return { palette: null, error: userFacingError(error) };
    }
  }, [selection]);

  if (profile.isPending) return <LoadingState />;
  if (profile.isError || !profile.data) {
    return (
      <PageShell title="Apariencia">
        <ErrorState
          message={userFacingError(profile.error)}
          onRetry={() => void profile.refetch()}
        />
      </PageShell>
    );
  }

  const chooseAccent = (value: string) => {
    setSelection(value);
    try {
      applyAccent(value);
    } catch {
      // La vista previa muestra el motivo y evita guardar.
    }
  };

  const handleCustomColor = (value: string) => {
    const normalized = value.toUpperCase();
    setCustomColor(normalized);
    chooseAccent(normalized);
  };

  const handleSave = async () => {
    try {
      const updated = await updateAppearance.mutateAsync({
        preferredAccent: selection,
        preferredTheme: themeSelection,
        expectedVersion: profile.data.version,
      });
      applyAccent(updated.preferredAccent);
      setColorScheme(updated.preferredTheme);
      notifications.show({
        color: 'green',
        title: 'Apariencia actualizada',
        message: 'La preferencia quedó guardada y se sincronizará en sus dispositivos.',
        withCloseButton: false,
      });
    } catch (error) {
      notifications.show({
        color: 'red',
        title: 'No se guardó el cambio',
        message: userFacingError(error),
        withCloseButton: false,
      });
    }
  };

  const changed =
    selection !== profile.data.preferredAccent || themeSelection !== profile.data.preferredTheme;

  return (
    <PageShell
      title="Apariencia"
      description="El tema controla las superficies neutrales. Su acento identifica navegación, selección, progreso y foco sin cambiar los colores de estado."
      actions={
        <Button
          className="primaryAction"
          leftSection={<IconCheck aria-hidden="true" />}
          disabled={!online || !preview.palette || !changed}
          loading={updateAppearance.isPending}
          onClick={() => void handleSave()}
        >
          Guardar apariencia
        </Button>
      }
    >
      {!online ? (
        <Alert color="yellow" role="status">
          Está sin conexión. Puede revisar la apariencia, pero debe reconectarse para guardar.
        </Alert>
      ) : null}

      <section className="surfaceSection" aria-labelledby="theme-title">
        <Stack gap="md">
          <div>
            <Title order={2} id="theme-title">
              Tema
            </Title>
            <Text c="dimmed">
              Sistema es la opción inicial y sigue la preferencia del dispositivo.
            </Text>
          </div>
          <SegmentedControl
            aria-label="Tema de la aplicación"
            value={themeSelection}
            onChange={(value) => {
              const theme = value as 'auto' | 'light' | 'dark';
              setThemeSelection(theme);
              setColorScheme(theme);
            }}
            data={[
              { value: 'auto', label: 'Sistema' },
              { value: 'light', label: 'Claro' },
              { value: 'dark', label: 'Oscuro' },
            ]}
          />
        </Stack>
      </section>

      <section className="surfaceSection" aria-labelledby="accent-title">
        <Stack gap="lg">
          <div>
            <Title order={2} id="accent-title">
              Acento
            </Title>
            <Text c="dimmed">
              Todos los acentos predefinidos alcanzan WCAG 2.2 AA en ambos temas.
            </Text>
          </div>
          <div className="accentOptions" role="group" aria-label="Acentos predefinidos">
            {presetEntries.map(([code, preset]) => (
              <button
                key={code}
                type="button"
                className="accentOption"
                aria-pressed={selection === code}
                onClick={() => chooseAccent(code)}
              >
                <span
                  className="accentSwatch"
                  style={{ backgroundColor: preset.solid }}
                  aria-hidden="true"
                />
                <span>{preset.label}</span>
              </button>
            ))}
          </div>
          <Divider />
          <Stack gap="xs" maw={360}>
            <TextInput
              label="Color personalizado"
              description="Use seis dígitos hexadecimales. Se valida antes de guardar."
              value={customColor}
              onChange={(event) => handleCustomColor(event.currentTarget.value)}
              maxLength={7}
              spellCheck={false}
              inputMode="text"
              leftSection={
                <span
                  className="customAccentSwatch"
                  style={{ backgroundColor: preview.palette ? selection : 'transparent' }}
                  aria-hidden="true"
                />
              }
            />
            {selection.startsWith('#') && preview.error ? (
              <Alert color="red" title="Este color no se puede usar">
                {preview.error}
              </Alert>
            ) : null}
          </Stack>
          <Button
            variant="subtle"
            leftSection={<IconRefresh aria-hidden="true" />}
            onClick={() => chooseAccent('teal')}
            w="fit-content"
          >
            Restaurar acento institucional
          </Button>
        </Stack>
      </section>

      {preview.palette ? (
        <section className="appearancePreview" aria-labelledby="preview-title">
          <Stack gap="lg">
            <div>
              <Title order={2} id="preview-title">
                Vista previa
              </Title>
              <Text c="dimmed">Los colores semánticos permanecen estables.</Text>
            </div>
            <Group gap="md" wrap="wrap">
              <Button className="primaryAction">Acción principal</Button>
              <a href="#preview-title" className="accentLink">
                Enlace de ejemplo
              </a>
            </Group>
            <Group gap="sm" wrap="wrap" aria-label="Ejemplos de estado">
              <span className="semanticBadge semanticSuccess">Correcto</span>
              <span className="semanticBadge semanticWarning">Atención</span>
              <span className="semanticBadge semanticError">Error</span>
              <span className="semanticBadge semanticAi">Propuesta IA</span>
              <span className="semanticBadge semanticApt">APT</span>
              <span className="semanticBadge semanticSiri">SIRI</span>
            </Group>
          </Stack>
        </section>
      ) : null}
    </PageShell>
  );
}
