# F3 — revisión independiente R4

Fecha: **2026-07-28 America/Costa_Rica**

Revisor: **`/root/f3_independent_review`**, solo lectura.
Dictamen técnico: **GO para el P1 conectado; NO-GO para presentar G3 mientras P2 y Entra real sigan abiertos**.

## Conteo

- P0: `0`.
- P1: `0` técnicos abiertos; `F3-REV-P1-02` queda cerrado por `verify:connected`.
- P2: `1` abierto: teclado/foco físico, zoom nativo 200 %, Chrome Android físico y Safari iPhone/iOS.
- P3: `0`.

## Base del dictamen

La ejecución conectada demuestra un único recorrido UI → PostgREST 14.12 → PostgreSQL 17 → RLS → auditoría → confirmación visible. La sesión utilizada por ese arnés es sintética AAL2 y no sustituye Microsoft Entra real.

La evidencia suplementaria de Edge de escritorio y WebKit con perfil iPhone emulado pasa teclado/foco y ausencia de overflow, pero no sustituye la matriz física ni el zoom nativo del navegador.

Para G3 todavía se requiere validar Entra QA (tenant, allowlist, MFA y revocación), repetir las verificaciones en el corte final y obtener aprobación explícita del usuario.
