# QA — `Filtrar por tipo` en Contexto vivo

Fecha: **2026-07-23** (`America/Costa_Rica`)

## Cambio validado

La cuadrícula permanente de once controles relacionados se sustituyó por un único `select` nativo rotulado **Filtrar por tipo**. Las opciones conservan tipo y conteo, y abren el mismo inspector relacional bajo el control.

## Resultados

| Comprobación                           | Resultado                                                          |
| -------------------------------------- | ------------------------------------------------------------------ |
| `node --check prototypes/fase1/app.js` | PASS; código 0                                                     |
| Nombre accesible del control           | PASS; un único `combobox` llamado `Filtrar por tipo`               |
| Cobertura de tipos                     | PASS; 11 opciones reales más placeholder                           |
| Conteos                                | PASS; cada opción muestra nombre + conteo del Trabajo activo       |
| Selección `tareas`                     | PASS; valor `tareas`, inspector visible y título `Tareas`          |
| Cierre del inspector                   | PASS; inspector oculto, valor vacío y foco devuelto al `select`    |
| Reflujo móvil                          | PASS a 360 × 900: control 287 px dentro de Contexto vivo de 311 px |
| Desbordamiento horizontal              | PASS; 0 px a 360 px y en viewport de escritorio probado            |
| Consola                                | PASS; 0 errores registrados                                        |

Ruta probada:
`#proyecto?id=JBC-2026-0042&work=TR-0042-02&tab=resumen`

## Archivos de implementación

- `prototypes/fase1/app.js`
- `prototypes/fase1/styles.css`

## Límite del resultado

Esta regresión confirma el ajuste puntual de densidad, interacción y reflujo. No sustituye las pruebas todavía pendientes de teclado extremo a extremo, zoom nativo 200 %, axe-core ni lector de pantalla, por lo que `F1-REV-P1-03` y CP-UX continúan abiertos.
