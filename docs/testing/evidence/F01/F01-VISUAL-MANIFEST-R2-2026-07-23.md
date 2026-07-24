# Manifiesto visual R2 — Fase 1

**Fecha:** 2026-07-23  
**Responsable de integración:** orquestador `/root`  
**Método:** Google Chrome instalado, controlado en modo headless con Playwright; servidor HTTP local aislado; datos ficticios  
**Ruta:** `#proyecto?id=JBC-2026-0042&work=TR-0042-01&tab=resumen`  
**Estado:** paquete final-candidato para revisión independiente R2

## Fuentes capturadas

| Archivo                       |   Bytes | SHA-256                                                            |
| ----------------------------- | ------: | ------------------------------------------------------------------ |
| `prototypes/fase1/index.html` |  11 854 | `544AF136C930144CF017970B6CB8D27BE541A274BAF44626926904FDD4944385` |
| `prototypes/fase1/styles.css` |  66 434 | `96A2CA77B3684BF0DD847DA71AE0284BFBA7596B0F370C1ED0C11408630A5140` |
| `prototypes/fase1/app.js`     | 124 943 | `48E0C8AA5946289C10814CF3B4DDF746D45D08C09C0E1359FE861FB23B345B1D` |

## Capturas activas

| Archivo                                  | Viewport    | Tema/estado                               | Reflujo y consola                         |   Bytes | SHA-256                                                            |
| ---------------------------------------- | ----------- | ----------------------------------------- | ----------------------------------------- | ------: | ------------------------------------------------------------------ |
| `proyecto-360-trabajos.png`              | 360 × 900   | oscuro; IA cerrada; Contexto vivo visible | `scrollWidth=360`; 0 errores funcionales  | 168 812 | `904F27F723DF86E1CE392DCA0CFE1EE1599BA6B547C22663E75E9CB82EEDC62D` |
| `proyecto-360-trabajos-claro.png`        | 360 × 900   | claro; IA cerrada; Contexto vivo visible  | `scrollWidth=360`; 0 errores funcionales  | 168 343 | `E660085C8674299D6FE3E3916242AABBC4ABAA7F39D3E8E329BE8F5C03D066D8` |
| `proyecto-768-trabajos.png`              | 768 × 1024  | oscuro; IA cerrada; Contexto vivo visible | `scrollWidth=768`; 0 errores funcionales  | 167 364 | `A12D685C268CD0DECDD467E2FDCCC875989BF7E0067CCA27D89FB0739FC3DDE0` |
| `proyecto-1024-trabajos.png`             | 1024 × 1200 | oscuro; IA cerrada; Contexto vivo visible | `scrollWidth=1024`; 0 errores funcionales | 200 341 | `C81D82C6B7BE0E2E46D774795E08042C09C5BC40F556F38C46DF01894400BC21` |
| `proyecto-1440-trabajos-contexto-ia.png` | 1440 × 1200 | oscuro; Contexto vivo e IA abiertos       | `scrollWidth=1440`; 0 errores funcionales | 247 809 | `9E2A4C1F782F090789294AB1C0910CE5F6A78D78209C6CC60483A778A4F14766` |

Las capturas son de página completa; la segunda dimensión anterior es la altura inicial del viewport, no la altura final del PNG.

## Hallazgo y corrección durante la regeneración

La primera captura a 1440 px reveló que `.compact-ai-suggestion` conservaba tres columnas dentro de la columna primaria reducida cuando Contexto vivo e IA estaban abiertos. El texto del riesgo quedaba comprimido verticalmente. Se corrigió `styles.css` para que, en ese estado, la propuesta use una columna y las dos acciones compartan una cuadrícula flexible. La regresión final midió:

- ancho de propuesta: `300 px`;
- ancho de texto: `272 px`;
- alto de texto: `45 px`;
- `scrollWidth === innerWidth === 1440`;
- Contexto vivo visible e IA abierta;
- cero errores funcionales de consola.

Las cinco imágenes se regeneraron después de la corrección. Por tanto, sus hashes corresponden al mismo hash final de `styles.css` indicado arriba.

## Exclusiones

- Las cuatro imágenes de `archive/pre-r2-obsolete-2026-07-23/` son evidencia histórica y no pertenecen a este paquete.
- El `404` de `favicon.ico` del servidor local se excluyó por no afectar la interfaz ni el flujo; no se registraron errores de aplicación.
- Este manifiesto no autoriza Fase 2 ni sustituye la revisión independiente R2.
