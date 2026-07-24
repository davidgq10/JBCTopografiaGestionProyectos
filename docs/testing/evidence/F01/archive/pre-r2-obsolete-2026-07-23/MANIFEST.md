# Manifiesto de capturas archivadas — corte anterior a R2

**Fecha de archivo:** 2026-07-23 (`America/Costa_Rica`)  
**Origen:** `docs/testing/evidence/F01/`  
**Destino recuperable:** `docs/testing/evidence/F01/archive/pre-r2-obsolete-2026-07-23/`  
**Motivo:** la revisión independiente R1 (`F1-REV-P2-02`) determinó que estas capturas muestran una interfaz anterior y no deben mezclarse con el paquete activo de aceptación.

No se eliminó ni sobrescribió ningún archivo. Los nombres se conservaron y cambió únicamente su ruta. Las capturas finales de Fase 1 se generarán después de cerrar las correcciones de accesibilidad.

| Nombre original                 | Nombre nuevo                                                       | SHA-256                                                            |   Bytes | Motivo                                                                | Fecha      |
| ------------------------------- | ------------------------------------------------------------------ | ------------------------------------------------------------------ | ------: | --------------------------------------------------------------------- | ---------- |
| `proyecto-768-claro.png`        | `archive/pre-r2-obsolete-2026-07-23/proyecto-768-claro.png`        | `E9E43BC3D0F4DC707F93EA2D85AEF7ADB84BB7C121837F108AAB6EF806B67DFA` |  67 598 | Corte anterior con patrones sustituidos; excluida por `F1-REV-P2-02`. | 2026-07-23 |
| `proyecto-360-claro.png`        | `archive/pre-r2-obsolete-2026-07-23/proyecto-360-claro.png`        | `91798B1A0B068178A2033077460E06595DA00823EB351AB974B0C8E068FADD31` |  29 780 | Corte anterior con patrones sustituidos; excluida por `F1-REV-P2-02`. | 2026-07-23 |
| `proyecto-360-oscuro.png`       | `archive/pre-r2-obsolete-2026-07-23/proyecto-360-oscuro.png`       | `6CAF93C1C726BCCE4DCC65FD2CE25C1F2FF6A7AD1BE25C80D212E453ADFF7099` |  30 372 | Corte anterior con patrones sustituidos; excluida por `F1-REV-P2-02`. | 2026-07-23 |
| `proyecto-1440-contexto-ia.png` | `archive/pre-r2-obsolete-2026-07-23/proyecto-1440-contexto-ia.png` | `45EB07EF74AF0B1BB77C751C6478483F45C6B15AC656CC2368DA5389A027B653` | 110 553 | Corte anterior con patrones sustituidos; excluida por `F1-REV-P2-02`. | 2026-07-23 |

## Recuperación

Para restaurar una captura, se debe verificar primero que el nombre original no exista en la raíz de `F01`, comprobar de nuevo el SHA-256 y moverla de regreso sin sobrescribir archivos. Este manifiesto debe conservarse como registro del saneamiento.
