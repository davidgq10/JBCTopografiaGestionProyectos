# F03 — navegador, responsive y accesibilidad

Fecha: **2026-07-24 UTC / 2026-07-23 America/Costa_Rica**  
Navegador: **Chromium Playwright**  
Resultado: **12/12 UI PASS + 1/1 PWA compilada PASS**.

## Escenarios

| Viewport/proyecto          | Flujo                                                                        | Resultado |
| -------------------------- | ---------------------------------------------------------------------------- | --------- |
| Chromium 1440/1024/768/360 | login ficticio → perfil → tema Oscuro + acento Azul → guardar → confirmación | 4/4 PASS  |
| Chromium 1440/1024/768/360 | ausencia de desbordamiento y acción visible                                  | 4/4 PASS  |
| Chromium 1440/1024/768/360 | shell seguro sin datos ni mutaciones al perder conexión                      | 4/4 PASS  |
| Chromium build PWA         | visita online → service worker activo → red deshabilitada → recarga fría     | 1/1 PASS  |

`@axe-core/playwright` se ejecutó en tema oscuro después de la confirmación del cambio en los cuatro viewports: **0 infracciones críticas o serias**. Los controles de icono tienen nombre accesible, el texto secundario alcanza contraste AA y la navegación de escritorio se retira del árbol visible en móvil.

El flujo usa adaptadores de prueba deterministas y demuestra la integración de UI/aplicación. La autorización y auditoría se demuestran por separado en PostgreSQL; **no existe aún un único E2E UI→DB**, hallazgo P1 de la revisión independiente. Edge, Safari/iPhone, Android físico, teclado completo y zoom 200 % conservan sus puertas posteriores; no se infieren de Chromium.
