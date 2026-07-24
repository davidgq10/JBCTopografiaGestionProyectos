# Comprobaciones reproducibles — Fase 1

Fecha: 2026-07-23 (`America/Costa_Rica`)

Alcance: documentación UX y prototipo local estático. No se probaron servicios, persistencia ni datos reales.

## Resultado

| Comprobación                                                                 |                       Resultado |
| ---------------------------------------------------------------------------- | ------------------------------: |
| `node --check prototypes/fase1/app.js`                                       |                            PASS |
| Llaves CSS balanceadas                                                       |                551 / 551 · PASS |
| Patrones retirados (`chatter-dropzone`, pestañas de modo, `Crear documento`) |                        0 · PASS |
| Definición de tres trabajos ficticios en la contratación PC-2026-0042        |                        3 · PASS |
| Contexto vivo con alcance `Trabajos` y relaciones navegables                 |                 presente · PASS |
| Botón único `data-chatter-submit>Publicar`                                   |                        1 · PASS |
| Destino de arrastre integrado `data-composer-drop-target`                    |                 presente · PASS |
| Sidebar slim de 64 px                                                        |                 presente · PASS |
| `--font-ui: "Inter", "Segoe UI", sans-serif;`                                | 1 definición contractual · PASS |
| `--font-data: "Roboto Mono", Consolas, monospace;`                           | 1 definición contractual · PASS |
| Controles de importación/migración Excel                                     |         0 · PASS para EX-013-01 |
| Llamadas de red (`fetch`, XHR, WebSocket)                                    |                        0 · PASS |
| Asignaciones aparentes de secretos                                           |                        0 · PASS |
| Documentos `docs/ux/*.md`                                                    |                           8 / 8 |
| Documentos UX con Proyecto `1..N` Trabajos                                   |                           8 / 8 |
| Documentos UX con once alcances                                              |                           8 / 8 |
| Patrones UX obsoletos activos                                                |                               0 |

## Comandos base

```powershell
node --check prototypes/fase1/app.js
rg -n "chatter-dropzone|chatter-modes|Crear documento" prototypes/fase1
rg -n "1\.\.N.*Trabaj|once alcances|compositor único" docs/ux
```

La ausencia de llamadas de red confirma únicamente el límite del prototipo; no sustituye las pruebas de seguridad e integración de fases posteriores.
