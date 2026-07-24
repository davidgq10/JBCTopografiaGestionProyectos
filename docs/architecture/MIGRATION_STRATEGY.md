# Estrategia de migraciones — Fase 2

Estado: **migraciones y validación estática ejecutadas; rutas limpia e incremental verificadas en PostgreSQL 17.10**.

## Serie incremental

| Orden | Archivo                                                    | Responsabilidad                                                                                                       |
| ----: | ---------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- |
|     1 | `20260723090100_f2_foundation_identity_admin_clients.sql`  | extensiones/esquemas internos, funciones base, identidad, administración y clientes                                   |
|     2 | `20260723090200_f2_projects_and_operations.sql`            | Contrataciones, Trabajos, alcance neutral, inmuebles, gestiones, tareas y agenda                                      |
|     3 | `20260723090300_f2_integrations_approvals_ai_platform.sql` | externos, OneDrive, aprobaciones, notificaciones, IA, auditoría/outbox                                                |
|     4 | `20260723090400_f2_invariants_and_indexes.sql`             | concurrencia, append-only, 1:N diferible, cambio de tipo, ciclos, alcances e índices                                  |
|     5 | `20260723090500_f2_rls_fail_closed.sql`                    | RLS habilitada/forzada y privilegios cliente revocados sin conceder políticas antes de `DEC-0103`                     |
|     6 | `20260723090600_f2_schedule_assignment_history.sql`        | versionamiento, cierre con motivo y prohibición de borrado para asignaciones de personas/recursos                     |
|     7 | `20260723090700_f2_identity_assignment_history.sql`        | prohibición de borrado para asignaciones revocables de identidad                                                      |
|     8 | `20260723090800_f2_polymorphic_resource_scope.sql`         | alcance discriminado `organization/project/work` en superficies transversales                                         |
|     9 | `20260723090900_f2_work_type_external_capabilities.sql`    | APT/SIRI exclusivamente para Plano de catastro y capacidades invariables                                              |
|    10 | `20260723091000_f2_concurrent_graph_invariants.sql`        | pertenencia invariable del Trabajo y serialización del grafo de tareas                                                |
|    11 | `20260723091100_f2_active_assignment_uniqueness.sql`       | unicidad parcial de concesiones/membresías activas                                                                    |
|    12 | `20260723091200_f2_management_note_revision_chain.sql`     | cadena exacta de revisiones de notas                                                                                  |
|    13 | `20260723091300_f2_catalog_value_code_immutable.sql`       | código invariable de valores de catálogo                                                                              |
|    14 | `20260723091400_f2_private_function_default_acl.sql`       | ACL fail-closed para funciones privadas presentes y futuras                                                           |
|    15 | `20260723091500_f2_external_procedure_creation_scope.sql`  | prohíbe crear historia APT/SIRI fuera de Plano de catastro y limita la excepción a desactivar filas existentes        |
|    16 | `20260723091600_f2_protected_codes_immutable.sql`          | códigos físicos de roles, permisos, catálogos, especialidades y estados invariables                                   |
|    17 | `20260723091700_f2_user_specialty_reassignment.sql`        | conserva historia y permite reotorgar una especialidad archivada bajo unicidad activa parcial                         |
|    18 | `20260723091800_f2_work_type_change_approval_binding.sql`  | vincula el cambio exacto de tipo/configuración/estado con solicitud, decisión y ejecución vigente de un solo uso      |
|    19 | `20260723091900_f2_functional_rls_dec_0103.sql`            | roles aprobados, helpers endurecidos, propietario `NOLOGIN`, anclas directas OneDrive y 136 políticas funcionales RLS |

Cada archivo abre y cierra su propia transacción. La secuencia es estricta y las correcciones posteriores a R1 son migraciones hacia adelante. La quinta migración deja el esquema denegado por defecto; no representa la matriz funcional final.

## Migración limpia

En una base PostgreSQL/Supabase desechable:

```powershell
$env:PGOPTIONS='--client-min-messages=warning'
Get-ChildItem -LiteralPath 'supabase\migrations' -Filter '*.sql' |
  Sort-Object Name |
  ForEach-Object { psql -v ON_ERROR_STOP=1 -f $_.FullName $env:TEST_DATABASE_URL }
```

Verificación mínima:

```powershell
psql -v ON_ERROR_STOP=1 $env:TEST_DATABASE_URL -c "\dt public.*"
psql -v ON_ERROR_STOP=1 $env:TEST_DATABASE_URL -c "select table_name from information_schema.tables where table_schema='public' order by 1;"
```

No se debe usar una base con datos reales ni credenciales productivas.

## Ruta de actualización

Para comprobar incrementalidad:

1. crear una base desechable;
2. aplicar 01 y 02;
3. insertar fixtures mínimos dentro de una transacción que cree Proyecto+Trabajo juntos;
4. aplicar 03→19;
5. comprobar que los fixtures siguen legibles y que `version` inicia en 1;
6. ejecutar pruebas negativas de invariantes;
7. comparar el catálogo resultante con una migración limpia de 01→19.

Las migraciones no renombran ni eliminan columnas/tablas. Una corrección posterior debe agregarse en un archivo nuevo; no se modifica una migración ya aplicada fuera de este corte previo a G2.

## Pruebas SQL de integración requeridas

- `COMMIT` falla para un Proyecto sin Trabajo y pasa al crear ambos en la misma transacción.
- Una FK operativa rechaza `project_id` de otra Contratación.
- `UPDATE/DELETE` falla en cada tabla append-only.
- `DELETE` falla en Proyecto, Trabajo, documento y entidades archivables.
- Ninguna FK contiene `ON DELETE CASCADE`.
- APT/SIRI activo falla fuera de `plano_catastro`.
- Cambiar tipo sin contexto/aprobación falla; con aprobación válida anexa historia e inactiva monitoreo incompatible.
- Estado externo conserva `original_status_text` y clasificación aparte.
- Dependencia o parent de tarea circular falla.
- Reintento duplica ni `outbox_events.idempotency_key` ni `idempotent_consumptions`.
- `drive_items` no ofrece columna binaria/contenido.
- Todas las columnas temporales de persistencia son `timestamptz`, excepto horas locales explícitas de preferencia.

## Consultas de inspección

```sql
-- Cascadas destructivas: debe devolver cero filas.
select conrelid::regclass, pg_get_constraintdef(oid)
from pg_constraint
where contype = 'f'
  and pg_get_constraintdef(oid) ilike '%ON DELETE CASCADE%';

-- Tipos temporales persistidos.
select table_name, column_name, data_type
from information_schema.columns
where table_schema = 'public'
  and column_name like '%\_at' escape '\'
order by table_name, ordinal_position;

-- Columnas que podrían representar binarios: debe devolver cero filas.
select table_name, column_name, data_type
from information_schema.columns
where table_schema = 'public'
  and (data_type = 'bytea' or column_name ~* '(content|binary|blob)');

-- Pares operativos presentes.
select table_name,
       bool_or(column_name = 'project_id') as has_project_id,
       bool_or(column_name = 'work_id') as has_work_id
from information_schema.columns
where table_schema = 'public'
group by table_name
order by table_name;
```

## Compatibilidad y reversión

- PostgreSQL 15+ y Supabase; UUID usa `pgcrypto`.
- No se usan extensiones Premium, red ni proveedores externos.
- La reversión de esquema no borra datos. Antes de G2 se recrea la base desechable; después de publicar una migración, se corrige hacia adelante.
- Una migración destructiva futura exige respaldo restaurado, prueba, plan de reversión y aprobación conforme a RF-018.
- RLS fail-closed existe desde 05; la migración 19 concede únicamente las capacidades aprobadas en `DEC-0103` y conserva `FORCE ROW LEVEL SECURITY`.

## Estado de ejecución

El autor preparó las migraciones y el orquestador las ejecutó durante la integración en PostgreSQL 17.10:

- migración limpia 01→19: **PASS**;
- actualización 01→02, fixture Proyecto+Trabajo, 03→19: **PASS**;
- fixture incremental conservado con `version = 1`: **PASS**;
- catálogos limpio/actualizado: **57 tablas, 227 FK, 155 índices, 130 triggers y 136 políticas en ambos**;
- huella normalizada de esquema: **idéntica** (`761f627b03a648b03feb95136753a3e2209234c28ac2a1dae62d2d722a8b035c`), `293930` bytes UTF-8 tras excluir tokens aleatorios `restrict/unrestrict` de `pg_dump`;
- `RLS-STRUCT PASS` con 57/57 tablas habilitadas/forzadas y ACL privadas cerradas;
- `F2-INVARIANTS PASS`, incluido alcance directo de Proyecto y regresiones R1;
- dos carreras reales de ciclos, jerarquía y dependencia: **rechazadas**;
- carrera real sobre una misma revisión de nota: una sesión confirma, la otra recibe unicidad y queda exactamente una revisión 2;
- cambio de tipo: mismatch, ausencia de decisión/ejecución, ejecución consumida y reutilización rechazados; camino exacto consume aprobación y conserva APT histórico;
- matriz RLS funcional: **PASS 2561/2561** en las rutas limpia e incremental; con `dec_0103_approved=0` continúa bloqueada correctamente.

La evidencia reproducible final está en `docs/testing/evidence/F02/F02-RLS-FUNCTIONAL-2026-07-23.md`. R6 la confirmó sin hallazgos y el usuario aprobó G2 el 2026-07-23. Fase 3 no se inició dentro de este cierre.
