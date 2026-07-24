export const ACCENT_PRESETS = {
  teal: {
    label: 'Teal institucional',
    solid: '#0F766E',
    textLight: '#0F766E',
    textDark: '#5EEAD4',
  },
  azul: {
    label: 'Azul',
    solid: '#1D4ED8',
    textLight: '#1D4ED8',
    textDark: '#93C5FD',
  },
  indigo: {
    label: 'Índigo',
    solid: '#4338CA',
    textLight: '#4338CA',
    textDark: '#C7D2FE',
  },
  violeta: {
    label: 'Violeta',
    solid: '#6D28D9',
    textLight: '#6D28D9',
    textDark: '#DDD6FE',
  },
  rosa: {
    label: 'Rosa',
    solid: '#BE123C',
    textLight: '#BE123C',
    textDark: '#FECDD3',
  },
  naranja: {
    label: 'Naranja',
    solid: '#C2410C',
    textLight: '#C2410C',
    textDark: '#FED7AA',
  },
} as const;

export type AccentPresetCode = keyof typeof ACCENT_PRESETS;
export type AccentPreference = AccentPresetCode | `#${string}`;

export interface AccentPalette {
  preference: AccentPreference;
  label: string;
  solid: string;
  solidText: '#FFFFFF';
  textLight: string;
  textDark: string;
  focusLight: string;
  focusDark: string;
  subtleLight: string;
  subtleDark: string;
  subtleTextLight: '#171717';
  subtleTextDark: '#FAFAFA';
}

export class AccentValidationError extends Error {
  readonly code = 'INVALID_ACCENT';

  constructor(message: string) {
    super(message);
    this.name = 'AccentValidationError';
  }
}

const HEX_COLOR = /^#[0-9A-F]{6}$/;
const LIGHT_SURFACE = '#FFFFFF';
const LIGHT_CANVAS = '#F5F5F5';
const DARK_SURFACE = '#262626';
const DARK_CANVAS = '#171717';

function parseHex(value: string): [number, number, number] {
  return [1, 3, 5].map((start) => Number.parseInt(value.slice(start, start + 2), 16)) as [
    number,
    number,
    number,
  ];
}

function toHex(channels: readonly number[]): string {
  return `#${channels.map((channel) => Math.round(channel).toString(16).padStart(2, '0')).join('')}`.toUpperCase();
}

function mix(first: string, second: string, secondWeight: number): string {
  const a = parseHex(first);
  const b = parseHex(second);
  return toHex(
    a.map((channel, index) => channel * (1 - secondWeight) + (b[index] ?? 0) * secondWeight),
  );
}

function channelLuminance(channel: number): number {
  const normalized = channel / 255;
  return normalized <= 0.04045 ? normalized / 12.92 : ((normalized + 0.055) / 1.055) ** 2.4;
}

export function relativeLuminance(color: string): number {
  const [red, green, blue] = parseHex(color);
  return (
    0.2126 * channelLuminance(red) +
    0.7152 * channelLuminance(green) +
    0.0722 * channelLuminance(blue)
  );
}

export function contrastRatio(first: string, second: string): number {
  const lighter = Math.max(relativeLuminance(first), relativeLuminance(second));
  const darker = Math.min(relativeLuminance(first), relativeLuminance(second));
  return (lighter + 0.05) / (darker + 0.05);
}

function tintForDarkSurface(color: string, minimumRatio: number): string {
  for (let step = 0; step <= 20; step += 1) {
    const candidate = mix(color, '#FFFFFF', step / 20);
    if (
      contrastRatio(candidate, DARK_SURFACE) >= minimumRatio &&
      contrastRatio(candidate, DARK_CANVAS) >= minimumRatio
    ) {
      return candidate;
    }
  }
  throw new AccentValidationError(
    'No fue posible generar una variante accesible para el tema oscuro.',
  );
}

export function normalizeAccentPreference(value: string | null | undefined): AccentPreference {
  if (value === null || value === undefined || value.trim() === '') return 'teal';
  const normalized = value.trim().toLowerCase();
  if (normalized in ACCENT_PRESETS) return normalized as AccentPresetCode;
  const upperHex = value.trim().toUpperCase();
  if (HEX_COLOR.test(upperHex)) return upperHex as `#${string}`;
  throw new AccentValidationError(
    'Seleccione un acento disponible o use un color hexadecimal válido.',
  );
}

export function buildAccentPalette(value: string | null | undefined): AccentPalette {
  const preference = normalizeAccentPreference(value);
  const preset =
    preference in ACCENT_PRESETS ? ACCENT_PRESETS[preference as AccentPresetCode] : null;
  const solid = preset?.solid ?? preference;

  if (
    contrastRatio('#FFFFFF', solid) < 4.5 ||
    contrastRatio(solid, LIGHT_SURFACE) < 4.5 ||
    contrastRatio(solid, LIGHT_CANVAS) < 4.5
  ) {
    throw new AccentValidationError(
      'El color no alcanza el contraste mínimo en controles y texto del tema claro.',
    );
  }

  const textDark = preset?.textDark ?? tintForDarkSurface(solid, 4.5);
  const focusDark = preset?.textDark ?? tintForDarkSurface(solid, 3);

  return {
    preference,
    label: preset?.label ?? `Personalizado ${preference}`,
    solid,
    solidText: '#FFFFFF',
    textLight: preset?.textLight ?? solid,
    textDark,
    focusLight: preset?.textLight ?? solid,
    focusDark,
    subtleLight: mix(solid, '#FFFFFF', 0.9),
    subtleDark: mix(solid, DARK_SURFACE, 0.72),
    subtleTextLight: '#171717',
    subtleTextDark: '#FAFAFA',
  };
}

export function accentPaletteMeetsWcag(palette: AccentPalette): boolean {
  return (
    contrastRatio(palette.solidText, palette.solid) >= 4.5 &&
    contrastRatio(palette.textLight, LIGHT_SURFACE) >= 4.5 &&
    contrastRatio(palette.textDark, DARK_SURFACE) >= 4.5 &&
    contrastRatio(palette.focusLight, LIGHT_CANVAS) >= 3 &&
    contrastRatio(palette.focusDark, DARK_CANVAS) >= 3 &&
    contrastRatio(palette.subtleTextLight, palette.subtleLight) >= 4.5 &&
    contrastRatio(palette.subtleTextDark, palette.subtleDark) >= 4.5
  );
}
