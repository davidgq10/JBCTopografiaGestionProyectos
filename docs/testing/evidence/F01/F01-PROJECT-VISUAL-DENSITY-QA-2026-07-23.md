# QA de densidad visual — Proyecto

Fecha: 2026-07-23 (`America/Costa_Rica`)  
Fase: F1 — UX y arquitectura de información  
Decisión: `DEC-0115`  
Artefacto: `prototypes/fase1/index.html`, `styles.css` y `app.js`

## Solicitud comprobada

Mantener el contenido de la página de Proyecto y reducir la sensación de saturación eliminando bordes estructurales redundantes. La corrección no podía ocultar Trabajos, estados, navegación inmersiva, Contexto vivo, compositor, historial, APT/SIRI ni acciones.

## Método

1. Se abrió una pestaña nueva contra el servidor local con hoja de estilos versionada para evitar caché anterior.
2. Se midieron los elementos visibles con borde dentro de `main` antes y después de la corrección.
3. Se inspeccionaron visualmente la ruta de Proyecto en tema oscuro y claro, escritorio y móvil.
4. Se comprobó desbordamiento horizontal, contenido clave, selector `Filtrar por tipo`, inspector, cierre/retorno de foco y consola.

El conteo incluye elementos visibles cuyo estilo computado tenía al menos uno de los cuatro bordes con ancho mayor que cero. Es una métrica comparativa de esta pantalla, no un objetivo universal para otras vistas.

## Cambio de jerarquía

Se retiraron contornos completos de:

- selector/resumen de Trabajos y sus tarjetas;
- navegación inmersiva del Trabajo;
- contenedor, encabezado, Contexto vivo, compositor y pie del historial derecho;
- botones secundarios del encabezado;
- propuesta compacta de IA;
- paneles APT/SIRI, filas internas y lista de revisión.

Se conservaron deliberadamente:

- borde del campo/compositor y del selector, porque delimitan controles editables;
- foco visible de teclado;
- marcador lateral y fondo del Trabajo seleccionado;
- señales semánticas puntuales de APT/SIRI y estados.

## Resultados

| Caso                             | Resultado | Evidencia observada                                                                                       |
| -------------------------------- | --------- | --------------------------------------------------------------------------------------------------------- |
| Contenido preservado             | PASS      | 3 Trabajos, 4 entradas del historial, 2 paneles externos y los bloques principales permanecieron visibles |
| Contornos visibles               | PASS      | 36 antes → 8 después; reducción de 28 elementos, equivalente a 77,8 %                                     |
| Escritorio oscuro                | PASS      | ancho útil estable, Contexto vivo a 420 px y jerarquía legible sin pared de tarjetas                      |
| Escritorio claro                 | PASS      | 8 elementos con borde; superficies adyacentes distinguibles y acento no dominante                         |
| Móvil 360 × 900 solicitado       | PASS      | 3 Trabajos presentes, contenido refluye y `scrollWidth - clientWidth = 0`                                 |
| Escritorio 1440 × 900 solicitado | PASS      | `scrollWidth - clientWidth = 0`                                                                           |
| Filtro relacionado               | PASS      | 12 opciones totales: placeholder + 11 tipos; `Tareas` abrió el inspector real                             |
| Cierre del inspector             | PASS      | limpió el selector, ocultó el inspector y devolvió foco a `Filtrar por tipo`                              |
| Consola                          | PASS      | 0 errores en el corte fresco                                                                              |

Los tamaños efectivos del área de contenido del navegador fueron 1425 × 900 y 345 × 900, debido al chrome de la herramienta; se solicitaron 1440 × 900 y 360 × 900 respectivamente.

## Dictamen

`PASS` para `DEC-0115`: la página mantiene su información y comportamiento, pero la jerarquía ya no depende de contornos repetidos en cada nivel. La corrección no cierra CP-UX: siguen pendientes las pruebas globales de accesibilidad, zoom nativo 200 %, lector de pantalla, axe-core y la revisión independiente R2 documentadas en el reporte de Fase 1.
