# ADR-0001 — Arquitectura base de la plataforma

- Estado: aceptada por la especificación; ratificación de repositorio pendiente en G0
- Fecha: 2026-07-22
- RF: RF-012, RF-016, RF-018, RF-019

## Contexto

La plataforma combina gestión transaccional, PWA, datos autorizados, archivos externos, monitoreo programado e integraciones con distinta disponibilidad. Se requiere mantenibilidad sin complejidad de distribución prematura y una frontera fuerte alrededor del dominio.

## Decisión

Adoptar monolito modular con Clean Architecture; puertos y adaptadores para proveedores; outbox transaccional para eventos; despliegue serverless híbrido. Organizar el monorepo en `apps/web`, `packages/domain`, `packages/application`, `packages/contracts`, `packages/testing`, `supabase/migrations`, `supabase/functions` y `workers/monitoring`.

La PWA usa el stack obligatorio del RF-012. PostgreSQL/Supabase es la fuente transaccional de datos y metadatos; OneDrive es el único almacén de binarios. Cloud Run solo se habilita con autorización y conserva trabajador Windows alternativo.

Las dependencias de compilación entre módulos forman un DAG. Identidad no depende de Administración; Aprobaciones y Administración no se importan mutuamente. Un composition root de Aplicación coordina las acciones sensibles mediante contratos neutrales y puertos versionados, y el módulo objetivo siempre revalida el comando.

## Consecuencias

- Los módulos deben declarar propiedad de datos y contratos; un manifiesto/import graph acíclico se verifica en CI.
- El dominio es testeable sin React, Supabase ni proveedores.
- La consistencia entre módulos/proveedores es eventual donde lo exige el outbox; la UI muestra estado/frescura.
- El despliegue sigue siendo único para la aplicación principal, reduciendo carga operativa.
- Adaptadores y trabajadores requieren simuladores y contratos.
- No se admiten microservicios, microfrontends, Redux, Zustand, Event Sourcing o CQRS completo sin un ADR y aprobación de alcance/costo.

## Alternativas descartadas

- Microservicios/microfrontends: complejidad operativa y contractual sin necesidad demostrada.
- Acceso directo a proveedores desde React: expone secretos y elude controles servidor.
- Archivos en Supabase Storage: contradice la fuente de verdad documental.
- Eventos sin outbox: riesgo de pérdida o doble efecto entre transacción y publicación.

## Verificación

Pruebas de límites/imports con detección de componentes fuertemente conexos, adaptadores sustituidos por simuladores, ausencia de secretos en bundle, eventos duplicados, migración limpia, RLS por rol/alcance y walking skeleton vertical en Fases 2–3.
