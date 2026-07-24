# ADR-0003 — Puertos, transacción de negocio y outbox idempotente

- Estado: aceptada en Fase 2
- Fecha: 2026-07-23
- RF: RF-006, RF-007, RF-008, RF-012, RF-015, RF-019
- Criterios: AC-012-01, AC-012-03, AC-012-04, AC-019-02, AC-019-04, AC-019-05

## Contexto

El monolito modular debe conservar datos y eventos coherentes, tolerar entrega al
menos una vez y permitir sustituir Graph, APT/SIRI, OpenAI o persistencia sin que el
dominio importe sus SDK. Aprobar una acción tampoco puede equivaler a ejecutarla.

## Decisión

Los casos de uso dependen de puertos definidos hacia adentro. Los adaptadores los
implementan y el composition root los conecta. Se congelan estas categorías:

- reloj e identificadores;
- autorización de servidor por actor, acción y `ResourceScope` discriminado; los puertos operativos conservan contexto Proyecto/Trabajo;
- repositorios propietarios con versión esperada;
- unidad de trabajo con `appendEvent` y `appendAudit`;
- reserva/completado idempotente;
- aprobación neutral, separada de ejecución;
- metadatos documentales sin binarios;
- consulta APT/SIRI de solo lectura;
- propuesta IA con evidencia, confianza y fecha de corte.

El guardado del agregado, la fila append-only de auditoría y el evento
`outbox_events` se confirman en una transacción. La publicación es posterior y al
menos una vez. Cada consumidor reserva una clave de efecto en
`idempotent_consumptions`; repetir la misma carga reproduce el resultado, mientras
reutilizar la clave con otra huella genera conflicto.

`approval.resolved.v1` comunica una decisión. El módulo objetivo revalida actor,
alcance, versión y clave de ejecución antes del cambio; la repetición del evento no
ejecuta dos veces. `work.type_changed.v1` conserva el tipo/estado anteriores y permite
desactivar monitoreo APT/SIRI sin borrar historia.

## DAG de compilación

`packages/contracts` es raíz estable; dominio no importa aplicación, adaptadores ni
presentación. Las aristas módulo a módulo se congelan en
`docs/architecture/MODULE_BOUNDARIES.md`. Eventos/proyecciones no son aristas de
compilación inversas. Auditoría recibe anexos y no consulta implementaciones ajenas.

## Consecuencias

- Un fallo del publicador/consumidor no revierte el negocio confirmado.
- Los consumidores deben ser observables y demostrar duplicados/conflictos.
- Realtime solo dispara una nueva lectura; nunca sustituye PostgreSQL como verdad.
- El puerto APT/SIRI no ofrece presentar, cargar, modificar ni eliminar.
- El puerto IA solo propone; aplicar una propuesta entra por un caso de uso humano.
- La escritura documental real permanece detrás de aprobación/checkpoint y adaptador;
  el contrato compartido expone únicamente metadatos.

## Alternativas descartadas

- Publicar después del commit sin outbox: puede perder eventos.
- Invocar al consumidor dentro de la transacción: acopla disponibilidad y permite
  ciclos/reversiones externas.
- Consumidores exactamente una vez por infraestructura: promesa no demostrable bajo
  reintentos; se exige efecto idempotente.
- Aprobaciones modificando tablas del objetivo: rompe propiedad y revalidación.
- SDK de proveedor en dominio: impide AC-012-01 y simuladores aislados.

## Verificación

- prueba estática del DAG/imports y dependencias prohibidas;
- contrato de evento duplicado y clave de efecto conflictiva en Fase 4;
- prueba de versión obsoleta y ejecución única en Fase 4;
- simuladores de adaptadores antes de conexiones reales;
- búsqueda estática de operaciones de escritura APT/SIRI y contenido binario.
