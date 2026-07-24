# Comprobaciones reproducibles R2 — Fase 1

**Fecha:** 2026-07-23  
**Responsable:** orquestador `/root`  
**Alcance:** regresión posterior a accesibilidad, saneamiento visual y corrección de compresión de la propuesta IA

## Resultados

| Comprobación                                                         | Resultado                         |
| -------------------------------------------------------------------- | --------------------------------- |
| `node --check prototypes/fase1/app.js`                               | **PASS**, salida vacía y código 0 |
| Balance de llaves de `styles.css`                                    | **PASS**, `569/569`               |
| Regla específica `.compact-ai-suggestion` bajo Proyecto + IA abierta | **PASS**, presente                |
| Texto visible legado `Frescura` en `app.js`                          | **PASS**, ausente                 |
| Instrumentación temporal axe/QA en prototipo                         | **PASS**, 0 coincidencias         |
| Hash de cada una de las cinco capturas contra manifiesto visual R2   | **PASS**, 5/5                     |
| Capturas obsoletas en la raíz activa F01                             | **PASS**, 0                       |

## Regresión visual ejecutada

La generación headless produjo, para 360, 768, 1024 y 1440 px:

- `scrollWidth === innerWidth` en los cinco casos;
- Contexto vivo visible;
- temas claro y oscuro representados;
- IA abierta y Contexto vivo simultáneos en 1440 px;
- cero errores funcionales de consola;
- propuesta compacta a 1440 px con `300 px` de contenedor, `272 px` útiles de texto y `45 px` de altura de texto.

Los hashes, tamaños y estados exactos están en `F01-VISUAL-MANIFEST-R2-2026-07-23.md`.

## Dictamen

**PASS como evidencia de integración previa a la revisión independiente R2.** No sustituye la aprobación de CP-UX ni autoriza Fase 2.
