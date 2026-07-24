# Arnés de seguridad, RLS y walking skeleton — Fases 2–3

Estado: **estructura y matriz funcional ejecutadas en PostgreSQL 17.10: PASS 2561/2561; flujo F3 PASS**

Este arnés prueba la superficie `public` completa sin extensiones de prueba y sin `service_role` en los casos de cliente. Está diseñado para `psql` contra una base efímera creada desde las migraciones de Fase 2. No usa red ni proveedores reales.

## Archivos

- `00_surface_manifest.sql`: inventario físico canónico, todos los alcances soportados, ciclo de vida y registro temporal de casos.
- `10_rls_structure.sql`: guardas de catálogo para RLS, vistas, funciones, grants, secretos/binarios y coherencia Proyecto→Trabajo.
- `20_rls_matrix.sql`: cobertura y ejecución funcional CRUD por cuatro roles y alcance.
- `30_case_data.sql`: fixtures sintéticos reproducibles y casos funcionales derivados de `DEC-0103`.
- `40_invariants.psql`: regresiones de integridad con fixtures sintéticos y `ROLLBACK` total; no concede permisos.
- `42_external_procedure_type_matrix.psql`: 16 altas APT/SIRI negativas (activas e inactivas) sobre los cuatro tipos no catastrales.
- `44_work_type_change_approval.psql`: cambio de tipo ligado al payload aprobado, decisión y ejecución de un solo uso; historia APT/SIRI posterior.
- `concurrency/43_management_note_*.psql`: carrera reproducible de dos sesiones sobre la misma revisión lógica; una confirma y la otra debe fallar por unicidad.
- `upgrade/41_incremental_fixture_*.psql`: fixture creado tras 01→02 y comprobado intacto tras 03→19.
- `50_rls_harness_guards.psql`: mutantes que prueban que un rol falsamente etiquetado y un UUID objetivo inexistente son rechazados por el arnés.
- `45_profile_accent_walking_skeleton.psql`: sesión autenticada, lectura propia, escritura validada por servidor, RLS y auditoría append-only del acento.
- `bootstrap_supabase_roles.sql`: crea únicamente los roles locales mínimos de una base efímera antes de aplicar migraciones.
- `run_structure.psql`: ejecuta solo controles estructurales.
- `run_rls.psql`: ejecuta estructura y matriz; falla cerrado si la decisión no está aprobada o la cobertura está incompleta.
- `verify_static.ps1`: compara el manifiesto con las migraciones y comprueba el bloqueo sin requerir PostgreSQL.

## Precondiciones

1. PostgreSQL/Supabase local disponible, sin datos reales.
2. Base efímera reconstruida desde todas las migraciones vigentes.
3. Roles PostgreSQL `anon` y `authenticated` existentes como en Supabase.
4. `public` es el único esquema expuesto de aplicación en Fase 2. Una ampliación requiere actualizar el manifiesto y revisar amenazas.
5. Para la matriz funcional, `DEC-0103` debe estar aprobada y `30_case_data.sql` debe contener fixtures sintéticos y cobertura total.

No se acepta una base administrada de producción ni una cadena de conexión almacenada en archivos/logs. La variable de entorno usada por el operador no forma parte de la evidencia.

La comprobación local que no necesita motor es:

```powershell
& supabase/tests/verify_static.ps1
```

El camino completo y reproducible de Fase 3 se ejecuta con `pnpm verify:database`, según `docs/operations/LOCAL_DEVELOPMENT.md`.

Si la política corporativa de PowerShell no permite ejecutar scripts, se registra esa limitación y se conserva como mínimo la validación de sintaxis y la comparación equivalente de inventario; no se reduce la exigencia de ejecutar después PostgreSQL.

## Ejecución reproducible

Desde la raíz del repositorio, con una conexión local/efímera ya configurada en la sesión:

```powershell
psql $env:JBC_F2_TEST_DATABASE_URL -X -v ON_ERROR_STOP=1 -f supabase/tests/run_structure.psql
```

Para verificar que la puerta conserva su postura fail-closed, incluso después de aprobar `DEC-0103`, se ejecuta deliberadamente el caso negativo:

```powershell
psql $env:JBC_F2_TEST_DATABASE_URL -X -v ON_ERROR_STOP=1 -v dec_0103_approved=0 -f supabase/tests/run_rls.psql
```

Resultado esperado: código distinto de cero y mensaje `RLS-MATRIX BLOCKED`. Esto demuestra fail-closed; no demuestra que RLS sea correcta.

Después de la aprobación registrada y de poblar los casos:

```powershell
psql $env:JBC_F2_TEST_DATABASE_URL -X -v ON_ERROR_STOP=1 -v dec_0103_approved=1 -f supabase/tests/run_rls.psql
```

Un resultado válido finaliza con `RLS-STRUCT PASS` y `RLS-MATRIX PASS`. Todo se ejecuta dentro de una transacción que termina en `ROLLBACK`.

## Cobertura exigida

El ejecutor rechaza una matriz que omita:

- `SELECT/INSERT/UPDATE/DELETE` para Administrador, Coordinador, Técnico y Solo lectura en cada tabla y cada variante de alcance físicamente soportada;
- Proyecto asignado, asignación aislada a Trabajo y no asignado para Técnico; alcance global de Solo lectura;
- Trabajo hermano para probar que no existe fuga inversa;
- usuario no preautorizado y revocado para cada rol/superficie;
- `UPDATE/DELETE` de toda tabla append-only;
- referencias indirectas desde dependencias, notificaciones, aprobaciones, documentos e IA;
- cualquier superficie física nueva no incorporada al manifiesto.

Además, cada `command_sql` debe corresponder léxicamente con su tabla y operación declaradas. Los `SELECT` comparan el conjunto exacto de UUID esperados; una mutación exitosa exige postcondición observable. Cada caso se revierte en su propia subtransacción para impedir contaminación entre casos.

La gramática es canónica: `SELECT` y `DELETE` usan exclusivamente `WHERE id = '<target_id>'`; `UPDATE` termina con ese mismo predicado y `INSERT` usa columnas explícitas + `VALUES`. Antes de cambiar al rol `authenticated`, cada comando se ejecuta como propietario dentro de una subtransacción revertida: debe leer/afectar exactamente el UUID tipado y dejar el alcance/propietario esperado. Esto impide negativos fabricados con `AND 1=0` o datos inválidos.

Para funciones futuras se agrega `EXECUTE` por rol y se valida el mismo alcance. Ninguna vista o función nueva pasa solamente porque sus tablas tengan políticas.

## Criterio allow/deny

- `SELECT` denegado: cero filas, sin revelar si el identificador existe.
- `INSERT` denegado por `WITH CHECK`: SQLSTATE esperado, normalmente `42501`.
- `UPDATE/DELETE` fuera de alcance: cero filas; datos sin cambios.
- append-only: actualización/borrado siempre denegado, incluso para Administrador/Coordinador de cliente.
- éxito: cantidad exacta de filas; el fixture comprueba además el estado antes del `ROLLBACK` cuando aplique.

El rol de aplicación se deriva de `app_users`/asignaciones vigentes; el arnés solo coloca `sub`, `role=authenticated` y `aal=aal2` en las claims. No coloca `app_role` en el JWT, para impedir que un dato declarado por el cliente se convierta en autoridad.

## Evidencia

La salida final se guarda fuera de este directorio bajo `docs/testing/evidence/F02/` por el orquestador, con:

- versión PostgreSQL/Supabase y hash/lista de migraciones;
- comando redactado, fecha UTC y fecha Costa Rica;
- decisión `DEC-0103` aplicada;
- conteo de superficies y casos;
- resultado esperado/real y defectos;
- revisor independiente.

No se guardan URL de conexión, JWT, cookies, UUID reales, PII, secretos ni binarios. La ejecución estructural y funcional vigente está enlazada en `docs/testing/evidence/F02/F02-RLS-FUNCTIONAL-2026-07-23.md`.
