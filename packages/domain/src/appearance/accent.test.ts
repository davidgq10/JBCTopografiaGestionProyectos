import { describe, expect, it } from 'vitest';

import {
  ACCENT_PRESETS,
  AccentValidationError,
  accentPaletteMeetsWcag,
  buildAccentPalette,
  contrastRatio,
  normalizeAccentPreference,
} from './accent.js';

describe('preferencia de acento', () => {
  it.each(Object.keys(ACCENT_PRESETS))('genera la paleta accesible %s', (code) => {
    expect(accentPaletteMeetsWcag(buildAccentPalette(code))).toBe(true);
  });

  it('usa el acento institucional cuando no existe una preferencia', () => {
    expect(normalizeAccentPreference(null)).toBe('teal');
    expect(buildAccentPalette(undefined).solid).toBe('#0F766E');
  });

  it('normaliza y valida un color personalizado accesible', () => {
    const palette = buildAccentPalette('#0f766e');
    expect(palette.preference).toBe('#0F766E');
    expect(accentPaletteMeetsWcag(palette)).toBe(true);
  });

  it('rechaza colores con contraste insuficiente', () => {
    expect(() => buildAccentPalette('#FFFFFF')).toThrow(AccentValidationError);
  });

  it('rechaza formatos que no son códigos ni colores', () => {
    expect(() => normalizeAccentPreference('rgb(0,0,0)')).toThrow(
      'Seleccione un acento disponible',
    );
  });

  it('calcula contraste simétrico', () => {
    expect(contrastRatio('#000000', '#FFFFFF')).toBeCloseTo(21);
    expect(contrastRatio('#FFFFFF', '#000000')).toBeCloseTo(21);
  });
});
