# F03 — preferencia de navegación móvil

Fecha: **2026-07-29 America/Costa_Rica**.

## Alcance

- RF-020 / AC-020-10: seleccionar y ordenar tres accesos intermedios desde Configuración.
- Inicio queda fijo como primer botón y Más queda fijo como último botón.
- Los accesos no seleccionados siguen disponibles dentro de Más junto con Configuración.

## Implementación

La preferencia se guarda en `app_users.mobile_nav_items` como una lista de tres valores distintos
entre Agenda, Avisos, Cuenta, Proyectos y Tareas. El caso de uso valida la lista, el adaptador la
persiste con control optimista de versión y PostgreSQL aplica la restricción, RLS y auditoría
append-only. La navegación consume el perfil y filtra automáticamente las opciones que permanecen
en Más.

## Verificación

- `pnpm --filter @jbc/application test`: **PASS**, 7/7 pruebas; incluye validación de selección y
  rechazo de duplicados.
- `pnpm --filter @jbc/web test -- settings-page.test.tsx`: **PASS**, 3/3 pruebas; incluye el
  guardado desde Configuración con teclado.
- `pnpm verify:database`: **PASS** en PostgreSQL 17 limpio; `RLS-STRUCT PASS`,
  `RLS-MATRIX PASS 2561/2561` y walking skeleton con orden móvil y auditoría.
- `pnpm verify:connected`: **PASS**; la UI cambió Agenda por Proyectos y PostgREST persistió
  `[proyectos, avisos, cuenta]`, versión y evento de auditoría.
- E2E responsive: **14 PASS / 6 omitidas por viewport**; el recorrido de 360 px valida
  Configuración, guardado, Inicio primero y el acceso elegido en la segunda posición.
- Accesibilidad suplementaria: **PASS** en Edge de escritorio y WebKit con perfil iPhone emulado;
  Configuración queda incluida en axe (0 violaciones críticas/serias), foco y overflow.

La prueba física de Chrome Android, Safari iPhone, foco táctil y zoom nativo 200 % fue el P2
independiente de G3. El usuario aceptó explícitamente ese P2 y aprobó G3 el 2026-07-29; la
declaración formal se conserva en `F03-G3-USER-APPROVAL-2026-07-29.md`.
