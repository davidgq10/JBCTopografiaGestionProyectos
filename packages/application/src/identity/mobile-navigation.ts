export const MOBILE_NAVIGATION_ITEMS = [
  'agenda',
  'avisos',
  'cuenta',
  'proyectos',
  'tareas',
] as const;

export type MobileNavigationItem = (typeof MOBILE_NAVIGATION_ITEMS)[number];
export type MobileNavigationSelection = [
  MobileNavigationItem,
  MobileNavigationItem,
  MobileNavigationItem,
];

export const DEFAULT_MOBILE_NAVIGATION: MobileNavigationSelection = ['agenda', 'avisos', 'cuenta'];

export class InvalidMobileNavigationError extends Error {
  readonly code = 'INVALID_MOBILE_NAVIGATION';

  constructor() {
    super('Debe seleccionar tres accesos distintos para la navegación móvil.');
    this.name = 'InvalidMobileNavigationError';
  }
}

export function parseMobileNavigationSelection(
  input: readonly string[],
): MobileNavigationSelection {
  if (
    input.length !== 3 ||
    input.some((item) => !MOBILE_NAVIGATION_ITEMS.includes(item as MobileNavigationItem)) ||
    new Set(input).size !== 3
  ) {
    throw new InvalidMobileNavigationError();
  }
  return input as MobileNavigationSelection;
}
