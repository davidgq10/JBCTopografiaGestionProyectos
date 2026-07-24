# Evidencia de Fase 1

Esta carpeta conserva artefactos reproducibles de UX: matriz de cobertura, capturas con datos ficticios, tamaños/zoom, teclado, contraste, revisión de estados y dictámenes independientes. No contiene datos reales, secretos ni evidencia de integraciones reales.

## Corte activo

Artefactos principales del corte vigente:

- `F01-MACHINE-CHECKS-2026-07-23.md`
- `F01-MACHINE-CHECKS-R2-2026-07-23.md`
- `F01-CP-UX-USER-APPROVAL-2026-07-23.md` — aprobación formal del checkpoint y cierre de Fase 1.
- `F01-RESPONSIVE-INTERACTION-QA-2026-07-23.md`
- `F01-ACCESSIBILITY-QA-2026-07-23.md`
- `F01-ACCESSIBILITY-QA-R2-2026-07-23.md`
- `F01-ACCESSIBILITY-MANUAL-QA-2026-07-23.md` — intento físico histórico no ejecutado; se conserva sin reescritura.
- `F01-ACCESSIBILITY-USER-ATTESTATION-2026-07-23.md` — ejecución física posterior aprobada por el usuario; evidencia vigente para el cierre de P1-03.
- `F01-CONTEXT-TYPE-FILTER-QA-2026-07-23.md`
- `F01-UI-CONVENTIONS-LANGUAGE-QA-2026-07-23.md`
- `F01-SIDEBAR-BRAND-TOGGLE-QA-2026-07-23.md`
- `F01-SIDEBAR-SETTINGS-FOOTER-QA-2026-07-23.md`
- `F01-PROJECT-VISUAL-DENSITY-QA-2026-07-23.md`
- `F01-VISUAL-MANIFEST-R2-2026-07-23.md` — hashes, viewports, temas, estados y métricas del paquete final-candidato.
- `PROJECT-WORKS-AUDIT-2026-07-23.md`
- `USER-DECISIONS-2026-07-23.md`
- capturas `proyecto-*-trabajos*.png`:
  - `proyecto-360-trabajos.png`
  - `proyecto-360-trabajos-claro.png`
  - `proyecto-768-trabajos.png`
  - `proyecto-1024-trabajos.png`
  - `proyecto-1440-trabajos-contexto-ia.png`

Las capturas archivadas no forman parte del paquete activo ni demuestran el estado actual del prototipo. El conjunto activo fue regenerado contra el código vigente en 360, 768, 1024 y 1440 px; su hash, viewport, tema, ruta/estado y métricas están en `F01-VISUAL-MANIFEST-R2-2026-07-23.md`.

## Archivo histórico excluido

Las cuatro capturas sin `-trabajos` señaladas por `F1-REV-P2-02` se trasladaron sin eliminación ni sobrescritura a `archive/pre-r2-obsolete-2026-07-23/`:

- `proyecto-768-claro.png`
- `proyecto-360-claro.png`
- `proyecto-360-oscuro.png`
- `proyecto-1440-contexto-ia.png`

Su procedencia, ruta nueva, SHA-256, tamaño, motivo y fecha constan en el [manifiesto del corte archivado](archive/pre-r2-obsolete-2026-07-23/MANIFEST.md).
