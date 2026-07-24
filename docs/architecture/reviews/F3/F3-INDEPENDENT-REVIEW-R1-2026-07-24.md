# F3 — revisión independiente R1

Fecha: **2026-07-24 UTC**  
Revisor: **`/root/f3_review`, solo lectura**  
Dictamen inicial: **NO-GO — 0 P0, 3 P1, 6 P2, 1 P3**.

Este documento transcribe el dictamen entregado por el revisor; el revisor no modificó archivos.

## P1 iniciales

1. faltaba evidencia negativa explícita de que la actualización propia no alterara columnas de identidad;
2. UI y PostgreSQL se probaban por separado, sin un recorrido único UI → PostgREST → RLS/auditoría → respuesta;
3. el arranque offline intentaba consultar perfil antes de mostrar un shell seguro.

## Hallazgos secundarios

Tokens no centralizados, tema no sincronizado, matriz de navegador limitada, DAG no incorporado a `verify`, escáner de secretos estrecho, dependencia/proveedor CI abierto, flags ausentes y rechazo inicial de sesión sin manejo uniforme.

## Estado después de correcciones

R2 confirmó cerrados la restricción/negativo de identidad, auditoría actor/rol/tema/acento/versión, shell offline seguro, tokens, sincronización de tema/acento, escáner, errores de sesión/cierre, feature flags y ejecución de contratos/DAG. El P1 del recorrido integrado permaneció abierto.

Fuente del estado posterior: [R2](F3-INDEPENDENT-REVIEW-R2-2026-07-24.md).
