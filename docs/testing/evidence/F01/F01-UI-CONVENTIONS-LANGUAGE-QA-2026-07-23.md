# QA — convenciones UI y lenguaje comprensible

Fecha: **2026-07-23** (`America/Costa_Rica`)  
Decisiones: `DEC-0114`, actualizada por `DEC-0116` para el encabezado del sidebar  
Entorno: prototipo estático local, navegador integrado, datos ficticios  
Rutas principales:

- `Proyecto → Resumen`, `JBC-2026-0042 / TR-0042-02`;
- `Proyecto → Tareas → TASK-TR-0042-02-01`.

## Alcance

Se verificaron el control de sidebar expandida/slim, cierres ordinarios, lenguaje visible de APT, tamaño táctil, navegación del cierre, desbordamiento y consola. Esta evidencia cubre el ajuste puntual; no sustituye axe-core, lector de pantalla ni el recorrido integral pendiente de `F1-REV-P1-03`.

## Resultados

| Caso                     | Resultado observado                                                                                                                                                    | Estado |
| ------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ |
| Sidebar expandida        | 220/244 px; `J`, título `JBC Proyectos` y `×` en una sola fila; nombre del control `Mostrar solo iconos del menú principal`; `aria-expanded=true`; objetivo 44 × 44 px | PASS   |
| Cambio a sidebar slim    | 64 px; en el encabezado queda visible únicamente la `J`; nombre `Expandir menú principal`; `aria-expanded=false`; foco visible observado; objetivo 44 × 44 px          | PASS   |
| Regreso a expandida      | restaura 220/244 px, título en una línea, `×` a su derecha y nombre programático sin cambiar ruta                                                                      | PASS   |
| Pie del sidebar          | el grupo `Sistema` y el pie técnico no se muestran; `⚙ Configuración` ocupa el fondo y se reduce al engranaje en slim                                                  | PASS   |
| APT en Resumen           | términos `Contrato`, `Último cambio`, `Actualización`; valores `2026-01843`, `22 jul, 19:04`, `Al día`                                                                 | PASS   |
| Prohibición de microcopy | `Frescura` no aparece en el texto visible de la ruta validada; tampoco existe control con texto visible exacto `Cerrar`                                                | PASS   |
| Cierre del aviso         | `×`, nombre `Cerrar aviso`, objetivo 44 × 44 px a 360 px                                                                                                               | PASS   |
| Cierre del detalle       | enlace visual `×`, nombre `Cerrar detalle`, tooltip, objetivo 44 × 44 px; elimina `record=` y vuelve al listado de Tareas                                              | PASS   |
| Reflujo                  | 0 px de overflow horizontal en escritorio y 360 px durante los casos ejecutados                                                                                        | PASS   |
| Consola                  | 0 errores en el corte fresco                                                                                                                                           | PASS   |

## Hallazgo y corrección durante QA

La primera prueba del detalle a 360 px encontró que una regla heredada `@media (max-width: 420px) { .icon-link { display: none; } }` ocultaba también el nuevo cierre. Se añadió una excepción específica para `.icon-link.record-detail-close`, se cargó un corte sin caché y se revalidó:

- `display: grid`;
- 44 × 44 px;
- `aria-label="Cerrar detalle"`;
- navegación correcta al listado;
- 0 px de overflow.

## Comprobaciones estructurales complementarias

- `node --check prototypes/fase1/app.js`: PASS.
- Balance CSS: mismo número de llaves de apertura y cierre.
- `#sidebar-toggle` conserva `aria-controls="primary-navigation"`.
- El mismo botón nativo presenta `J` en compacto y `×` en expandido; ambos símbolos son decorativos y el nombre accesible describe la acción.

El resultado anterior que usaba `☰` en modo slim queda sustituido por `DEC-0116`; la medición vigente está ampliada en `F01-SIDEBAR-BRAND-TOGGLE-QA-2026-07-23.md`.

## Límite explícito

`F1-REV-P1-03` permanece abierto. Antes de CP-UX todavía se requieren recorrido completo de teclado/foco, zoom nativo 200 %, axe-core y lector de pantalla, además de regenerar el paquete visual y obtener revisión independiente R2.
