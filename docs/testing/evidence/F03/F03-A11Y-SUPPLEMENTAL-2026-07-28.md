# Evidencia suplementaria de accesibilidad y compatibilidad

Fecha: **2026-07-29 America/Costa_Rica** (actualización del recorrido).

Comando reproducible:

```text
pnpm --filter @jbc/web test:a11y:supplemental
```

Resultados:

```text
EDGE-DESKTOP PASS | keyboard focus + no overflow | settings axe=0 inner=1024 scroll=1024 client=1024
WEBKIT-IPHONE-EMULATED PASS | keyboard focus + no overflow | settings axe=0 inner=390 scroll=390 client=390
A11Y-SUPPLEMENTAL PASS | Edge desktop + WebKit iPhone emulated
```

El script recorre el login sintético, abre Cuenta y Configuración, ejecuta axe sobre el panel móvil, comprueba foco con `Shift+Tab`/`Tab` y mide `scrollWidth` frente a `clientWidth`. Es evidencia automatizada complementaria; no equivale a una prueba física de Chrome Android, Safari iPhone, lector de pantalla ni zoom nativo del navegador al 200 %.

Por lo tanto, el P2 de G3 permanece abierto hasta completar la matriz física acordada y registrar el zoom nativo 200 % en ambos temas.
