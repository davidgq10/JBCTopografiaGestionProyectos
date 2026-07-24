# F3 — revisión independiente R2

Fecha: **2026-07-24 UTC**  
Revisor: **`/root/f3_review`, solo lectura**  
Dictamen: **NO-GO — 0 P0, 1 P1, 4 P2, 0 P3**.

Este documento transcribe el dictamen entregado por el revisor; el revisor no modificó archivos.

## P1 abierto

El navegador continúa usando adaptadores en memoria y la prueba PostgreSQL se ejecuta separadamente. No existe aún evidencia de un único recorrido UI → Supabase/PostgREST → PostgreSQL → RLS → auditoría → respuesta visible. Por ello el flujo vertical exigido por Fase 3 y G3 no está demostrado de extremo a extremo.

## P2 señalados en R2

1. aplicar el tema sincronizado globalmente al cargar el perfil;
2. probar recarga/arranque frío offline contra el service worker compilado;
3. actualizar evidencia a los cuatro viewports y conservar pendientes de compatibilidad física/final;
4. derivar el grafo de imports real para detectar ciclos, no solo un DAG documental fijo.

Los cuatro recibieron corrección posterior: aplicación global en `ProtectedLayout`, smoke PWA compilado, 12 E2E en 1440/1024/768/360 y verificador real de 46 archivos/92 imports. R3 debe confirmar esos cierres; el P1 integrado permanece abierto por diseño.

## Límites correctamente representados

`DEC-0209` y Entra real siguen abiertos. No se encontraron secretos, `service_role` en React, RF-013 operativo ni binarios en Supabase.
