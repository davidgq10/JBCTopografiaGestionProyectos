# F03 — navegación móvil secundaria

Fecha: **2026-07-28 America/Costa_Rica**.

## Alcance

- RF-020 / AC-020-05: mantener el flujo operativo accesible a 360 px sin desplazamiento horizontal general.
- RF-020 / AC-020-08: navegación táctil y alternativa a la barra inferior saturada.

## Implementación

La barra inferior conserva Inicio, Agenda, Avisos y Cuenta. El quinto control **Más** abre un `Drawer` inferior de 280 px con enlaces visibles a **Proyectos**, **Tareas** y **Configuración**. El control expone `aria-expanded`, `aria-controls` y `aria-haspopup`; el cierre tiene el nombre accesible `Cerrar más opciones`, admite `Escape` y devuelve el foco al activador.

## Verificación

- `pnpm format:check`: **PASS**.
- `pnpm --filter @jbc/web typecheck`: **PASS**.
- `pnpm --filter @jbc/web test`: **PASS**, 2/2 pruebas.
- E2E Chromium: **13 PASS / 3 omitidas por viewport**; el recorrido nuevo en `chromium-360` abre el menú, encuentra Proyectos y Tareas y navega a Proyectos.
- La aserción responsive del recorrido mide el botón **Más** con ancho y alto mínimos de 44 px.
- Comprobación visual en navegador integrado a 360 px: **PASS**; sin desbordamiento horizontal, panel visible, cierre nombrado, `Escape` y retorno de foco comprobados.

La evidencia cubre navegador emulado; la matriz física Chrome Android/Safari iPhone de G3 sigue siendo una comprobación separada.
