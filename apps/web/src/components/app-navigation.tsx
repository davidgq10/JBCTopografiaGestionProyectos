import {
  ActionIcon,
  AppShell,
  Box,
  Group,
  NavLink as MantineNavLink,
  Stack,
  Text,
  Tooltip,
} from '@mantine/core';
import {
  IconBell,
  IconCalendar,
  IconCheckupList,
  IconClipboardText,
  IconHome,
  IconLogout,
  IconSettings,
  IconUserCircle,
  IconX,
  type Icon,
} from '@tabler/icons-react';
import { notifications } from '@mantine/notifications';
import { type ReactNode, useRef, useState } from 'react';
import { NavLink, Outlet, useLocation } from 'react-router-dom';

import { useAuth } from '../app/auth-context.js';
import { userFacingError } from '../infrastructure/services.js';
import { EnvironmentBanner } from './environment-banner.js';

interface NavigationItem {
  label: string;
  to: string;
  icon: Icon;
}

const desktopItems: NavigationItem[] = [
  { label: 'Inicio', to: '/', icon: IconHome },
  { label: 'Proyectos', to: '/proyectos', icon: IconClipboardText },
  { label: 'Tareas', to: '/tareas', icon: IconCheckupList },
  { label: 'Agenda', to: '/agenda', icon: IconCalendar },
  { label: 'Avisos', to: '/notificaciones', icon: IconBell },
  { label: 'Cuenta', to: '/perfil/apariencia', icon: IconUserCircle },
];

const mobileItems: NavigationItem[] = [
  { label: 'Inicio', to: '/', icon: IconHome },
  { label: 'Agenda', to: '/agenda', icon: IconCalendar },
  { label: 'Avisos', to: '/notificaciones', icon: IconBell },
  { label: 'Cuenta', to: '/perfil/apariencia', icon: IconUserCircle },
];

function DesktopNavigationLink({ item, expanded }: { item: NavigationItem; expanded: boolean }) {
  const location = useLocation();
  const active =
    item.to === '/' ? location.pathname === '/' : location.pathname.startsWith(item.to);
  const content = (
    <MantineNavLink
      component={NavLink}
      to={item.to}
      label={expanded ? item.label : undefined}
      aria-label={item.label}
      leftSection={<item.icon size={20} aria-hidden="true" />}
      active={active}
      className="desktopNavLink"
    />
  );
  return expanded ? content : <Tooltip label={item.label}>{content}</Tooltip>;
}

export function AppNavigation({ content }: { content?: ReactNode }) {
  const [expanded, setExpanded] = useState(true);
  const toggleRef = useRef<HTMLButtonElement>(null);
  const { signOut } = useAuth();

  const handleSignOut = async () => {
    try {
      await signOut();
    } catch (error) {
      notifications.show({
        color: 'red',
        title: 'No se pudo cerrar la sesión',
        message: userFacingError(error),
        withCloseButton: false,
      });
    }
  };

  return (
    <AppShell
      header={{ height: 56, collapsed: false }}
      navbar={{ width: expanded ? 264 : 76, breakpoint: 'sm', collapsed: { mobile: true } }}
      footer={{ height: 68, collapsed: false }}
      padding={0}
    >
      <AppShell.Header hiddenFrom="sm" className="mobileHeader">
        <Group h="100%" px="md" justify="space-between">
          <Group gap="sm">
            <Box className="mobileBrand" aria-hidden="true">
              J
            </Box>
            <Text fw={650}>JBC Proyectos</Text>
          </Group>
          <Tooltip label="Cerrar sesión">
            <ActionIcon
              aria-label="Cerrar sesión"
              variant="subtle"
              onClick={() => void handleSignOut()}
            >
              <IconLogout aria-hidden="true" />
            </ActionIcon>
          </Tooltip>
        </Group>
      </AppShell.Header>

      <AppShell.Navbar visibleFrom="sm" className="desktopNavbar" aria-label="Menú principal">
        <Group
          className="desktopBrandRow"
          justify={expanded ? 'space-between' : 'center'}
          wrap="nowrap"
        >
          {expanded ? (
            <Group gap="sm" wrap="nowrap">
              <Box className="brandMark" aria-hidden="true">
                J
              </Box>
              <Text fw={650} className="brandTitle">
                JBC Proyectos
              </Text>
            </Group>
          ) : null}
          <Tooltip
            label={expanded ? 'Mostrar solo iconos del menú principal' : 'Expandir menú principal'}
          >
            <ActionIcon
              ref={toggleRef}
              variant="subtle"
              aria-label={
                expanded ? 'Mostrar solo iconos del menú principal' : 'Expandir menú principal'
              }
              aria-controls="desktop-main-navigation"
              aria-expanded={expanded}
              onClick={() => setExpanded((value) => !value)}
            >
              {expanded ? <IconX aria-hidden="true" /> : <Text fw={700}>J</Text>}
            </ActionIcon>
          </Tooltip>
        </Group>

        <Stack id="desktop-main-navigation" gap={4} p="sm" flex={1}>
          {desktopItems.map((item) => (
            <DesktopNavigationLink key={item.to} item={item} expanded={expanded} />
          ))}
        </Stack>

        <Box p="sm">
          <DesktopNavigationLink
            item={{ label: 'Configuración', to: '/configuracion', icon: IconSettings }}
            expanded={expanded}
          />
        </Box>
      </AppShell.Navbar>

      <AppShell.Main>
        <EnvironmentBanner />
        {content ?? <Outlet />}
      </AppShell.Main>

      <AppShell.Footer
        hiddenFrom="sm"
        className="mobileNavigation"
        component="nav"
        aria-label="Navegación inferior"
      >
        {mobileItems.map((item) => (
          <NavLink
            key={item.to}
            to={item.to}
            className={({ isActive }) => `mobileNavItem${isActive ? ' active' : ''}`}
          >
            <item.icon size={20} aria-hidden="true" />
            <span>{item.label}</span>
          </NavLink>
        ))}
      </AppShell.Footer>
    </AppShell>
  );
}
