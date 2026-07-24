import { buildAccentPalette, type AccentPalette } from '@jbc/domain';
import {
  createContext,
  type PropsWithChildren,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
} from 'react';

interface AccentContextValue {
  palette: AccentPalette;
  applyAccent(preference: string | null | undefined): void;
}

const AccentContext = createContext<AccentContextValue | null>(null);

function setVariables(palette: AccentPalette): void {
  const root = document.documentElement;
  root.style.setProperty('--accent-solid', palette.solid);
  root.style.setProperty('--accent-solid-text', palette.solidText);
  root.style.setProperty('--accent-text-light', palette.textLight);
  root.style.setProperty('--accent-text-dark', palette.textDark);
  root.style.setProperty('--accent-focus-light', palette.focusLight);
  root.style.setProperty('--accent-focus-dark', palette.focusDark);
  root.style.setProperty('--accent-subtle-light', palette.subtleLight);
  root.style.setProperty('--accent-subtle-dark', palette.subtleDark);
}

export function AccentProvider({ children }: PropsWithChildren) {
  const [palette, setPalette] = useState(() => buildAccentPalette('teal'));
  useEffect(() => setVariables(palette), [palette]);
  const applyAccent = useCallback((preference: string | null | undefined) => {
    setPalette(buildAccentPalette(preference));
  }, []);
  const value = useMemo(() => ({ palette, applyAccent }), [applyAccent, palette]);
  return <AccentContext.Provider value={value}>{children}</AccentContext.Provider>;
}

export function useAccent(): AccentContextValue {
  const value = useContext(AccentContext);
  if (!value) throw new Error('AccentProvider no está disponible.');
  return value;
}
