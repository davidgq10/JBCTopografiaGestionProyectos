# F3 — seguimiento independiente R4

Fecha: **2026-07-28 America/Costa_Rica**

Revisor: **`/root/f3_independent_review`**, solo lectura.
Alcance: regresión de la evidencia Entra QA y del corte de verificación posterior a R4.

## Dictamen vigente

- P0: `0`.
- P1: `0`; `F3-REV-P1-02` permanece cerrado por `verify:connected`.
- P2: `1`: teclado/foco físico, zoom nativo 200 %, Chrome Android físico y Safari iPhone/iOS.
- P3: `0`.

## Evidencia revisada

- `F03-ENTRA-QA-2026-07-28.md`: PASS real en tenant QA, callback `localhost`, MFA, sesión preautorizada, rol `technician` y revocación/restauración controladas; producción no se tocó.
- `F03-VERIFICATION-2026-07-28.md`: PASS de `verify:ci`, `verify:database` y `verify:connected`; Edge/WebKit emulado PASS como evidencia suplementaria.

## Condición de G3

El P1 conectado y Entra QA real están cerrados. G3 continúa NO-GO condicionado exclusivamente al cierre del P2 físico y a la aprobación explícita del usuario. La emulación de navegador no sustituye la comprobación en los dispositivos físicos indicados.
