# QA del encabezado adaptable del sidebar

Fecha: 2026-07-23 (`America/Costa_Rica`)  
Fase: F1 — UX y arquitectura de información  
Decisión: `DEC-0116`  
Artefacto: `prototypes/fase1/index.html`, `styles.css` y `app.js`

## Solicitud comprobada

- En modo compacto debe verse únicamente el icono/marca `J`; no debe existir un `☰` separado debajo.
- En modo expandido, la `×` debe aparecer a la derecha del título `JBC Proyectos` dentro de la misma fila.

## Implementación observada

El encabezado usa un contenedor adaptable:

- expandido: enlace de marca `J · JBC Proyectos` y botón `×`;
- compacto: se oculta el enlace de marca y el mismo botón presenta una `J`;
- el botón nativo conserva 44 × 44 px, foco visible, tooltip, `aria-controls="primary-navigation"` y estado `aria-expanded`.

## Resultados en navegador local

| Ancho solicitado | Compacto                                            | Expandido                                                                      | Overflow horizontal |
| ---------------- | --------------------------------------------------- | ------------------------------------------------------------------------------ | ------------------- |
| 920 px           | rail 64 px; único texto visible del encabezado: `J` | sidebar 220 px; título en una línea; `×` a la derecha y centrada con el título | 0 px                |
| 1024 px          | rail 64 px; único texto visible del encabezado: `J` | sidebar 220 px; título en una línea; `×` a la derecha y centrada con el título | 0 px                |
| 1440 px          | rail 64 px; único texto visible del encabezado: `J` | sidebar 244 px; título en una línea; `×` a la derecha y centrada con el título | 0 px                |

Comprobaciones adicionales:

- compacto: `aria-expanded=false`, nombre `Expandir menú principal`, marca y `×` abiertas ocultas;
- expandido: `aria-expanded=true`, nombre `Mostrar solo iconos del menú principal`;
- el foco visible permanece sobre el botón después del cambio;
- la ruta y el contenido principal no cambian al alternar;
- el corte fresco carga CSS y JavaScript versionados para evitar caché anterior.

## Dictamen

`PASS` para la corrección visual y estructural de `DEC-0116`. La activación integral por teclado sigue formando parte del recorrido manual global pendiente de `F1-REV-P1-03`; esta prueba puntual no cierra por sí sola la conformidad WCAG ni CP-UX.
