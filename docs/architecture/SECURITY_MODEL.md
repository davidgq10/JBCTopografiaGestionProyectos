# Modelo de seguridad y amenazas

Estado: **`DEC-0103` implementada; revisión independiente R6 GO; G2 aprobado**  
Fecha de corte: **2026-07-23** (`America/Costa_Rica`)

## Objetivos e invariantes

El modelo protege confidencialidad por alcance, integridad de historia y decisiones, disponibilidad con degradación, trazabilidad de solo adición y mínimo privilegio. La referencia de verificación es OWASP ASVS 5.0 nivel 2 aplicable.

- Toda tabla del esquema expuesto activa y fuerza RLS. Una tabla nueva sin política falla la comprobación de inventario.
- Las vistas expuestas son `security_invoker`; una excepción requiere ADR, propietario, amenaza, privilegios mínimos y prueba negativa.
- Las funciones RPC expuestas son `security invoker`. Una función `security definer` solo puede vivir fuera de esquemas expuestos, tener `search_path` fijo y vacío/seguro, propietario sin inicio de sesión, `EXECUTE` revocado de `PUBLIC`, contrato mínimo y revisión independiente.
- El navegador usa únicamente la clave pública y la sesión del actor. `service_role`, secretos y credenciales quedan en backend, trabajador o vault autorizado y están fuera del arnés de cliente.
- La autorización real ocurre en servidor y PostgreSQL. Ocultar controles en React solo mejora la experiencia.
- Los proyectos son contrataciones con `1:N` Trabajos. El acceso operativo parte del Proyecto y, cuando existe `trabajo_id`, exige además que el Trabajo pertenezca a ese mismo Proyecto. Ninguna nota, tarea, documento, aprobación, notificación, trámite, búsqueda o referencia polimórfica concede alcance.
- Auditoría, historia, decisiones, eventos externos y consumos/outbox que corresponda son append-only; ningún rol de cliente puede actualizarlos ni eliminarlos.
- Se persisten instantes UTC; `America/Costa_Rica` es una transformación de presentación.
- Supabase no recibe binarios de proyecto. APT/SIRI es solo lectura y solo queda activo para Trabajos de Plano de catastro.
- `RF-013` continúa ausente.

## Decisión de alcance implementada

`DEC-0103` está aprobada e implementada. Administrador y Coordinador tienen alcance global: Administrador gestiona usuarios, roles, configuración y operación; Coordinador gestiona operación y asignaciones, pero no usuarios ni roles. El Técnico solo ve sus Proyectos asignados y todos sus Trabajos, y puede crear/actualizar datos operativos dentro de ellos; una asignación aislada a Trabajo no concede alcance. Solo lectura consulta globalmente todos los Proyectos y sus Trabajos, sin escrituras de negocio. Esto no permite borrado físico, decisiones de aprobación no autorizadas, mutación de auditoría ni escritura directa APT/SIRI.

La migración 19 materializa la decisión mediante helpers privados y 136 políticas sobre 57 tablas con RLS forzada. La matriz funcional pasó `2561/2561` en reconstrucciones limpia e incremental; al ejecutar con `dec_0103_approved=0`, el arnés conserva el bloqueo fail-closed. Las 17 funciones `SECURITY DEFINER` pertenecen a `app_rls_owner` (`NOLOGIN`, no superusuario, `BYPASSRLS` necesario y grants de tabla acotados). R6 confirmó el corte con 0 P0/P1/P2/P3 y el usuario aprobó G2 el 2026-07-23.

## Actores y fronteras de confianza

| Actor/frontera                  | Confianza                      | Regla mínima                                                                         |
| ------------------------------- | ------------------------------ | ------------------------------------------------------------------------------------ |
| Navegador autenticado           | no confiable                   | JWT identifica, pero no autoriza por sí solo; toda entrada se vuelve a validar       |
| Supabase Auth / Entra ID        | proveedor de identidad         | tenant permitido, usuario preautorizado, MFA delegado a Microsoft                    |
| PostgreSQL/RLS                  | frontera autoritativa de datos | verifica usuario activo, rol vigente, permiso, Proyecto y Trabajo en cada consulta   |
| Edge Function/backend           | proceso confiable limitado     | valida contrato y autorización antes de usar puertos; registra correlación y rechazo |
| `service_role`                  | privilegio excepcional         | solo backend/trabajador; nunca prueba un flujo de cliente ni aparece en bundle/log   |
| Graph, APT, SIRI, OpenAI y Push | externos no confiables         | lista blanca/minimización, respuesta validada, degradación y secretos redactados     |
| Respaldo/entornos inferiores    | frontera separada              | sin secretos/binarios, cifrado, datos anonimizados y restauración aislada            |

## Contexto autoritativo de autorización

Cada decisión se deriva de datos vigentes en base, no de `user_metadata` controlable por el usuario:

1. `auth.uid()` debe existir;
2. el perfil interno debe estar preautorizado, activo, pertenecer al tenant permitido y no tener `revoked_at`;
3. el rol y permisos efectivos se resuelven desde asignaciones versionadas/vigentes;
4. el alcance global o asignado se aplica conforme a `DEC-0103` cuando sea aprobada;
5. una fila con `trabajo_id` debe satisfacer simultáneamente `trabajo.proyecto_id = fila.proyecto_id` y acceso al par Proyecto/Trabajo;
6. `INSERT` y `UPDATE` repiten la autorización en `WITH CHECK`; cambiar claves de alcance no permite trasladar una fila a otro Proyecto/Trabajo;
7. archivo, cambio de tipo, permisos y otras acciones sensibles requieren además el flujo de aprobación aplicable; RLS no sustituye esa regla de negocio.

La revocación se consulta en base en toda operación nueva. No se confía solamente en la caducidad del JWT. El backend invalida/refresca la sesión cuando corresponda y registra el resultado sin guardar tokens.

## Patrón de políticas RLS

Las políticas se separan por operación y usan `TO authenticated`; no se usa una política `FOR ALL` genérica.

| Operación | `USING`                                     | `WITH CHECK`                                                     | Resultado por defecto              |
| --------- | ------------------------------------------- | ---------------------------------------------------------------- | ---------------------------------- |
| `SELECT`  | actor activo + permiso de lectura + alcance | no aplica                                                        | cero filas fuera de alcance        |
| `INSERT`  | no aplica                                   | actor activo + permiso de creación + Proyecto/Trabajo coherentes | rechazo                            |
| `UPDATE`  | acceso a fila anterior + permiso específico | acceso a fila nueva + mismo alcance + versión esperada           | rechazo/conflicto explícito        |
| `DELETE`  | denegado en superficies de negocio          | no aplica                                                        | rechazo; se usa archivo con motivo |

Para evitar RLS recursiva, los predicados de membresía no consultan desde una política la misma relación protegida. Si PostgreSQL exige un helper privilegiado, se limita a devolver un booleano de autorización, vive en un esquema privado no expuesto y cumple todas las restricciones de `security definer` de este documento. No se usa una referencia indirecta como prueba de acceso.

## Herencia Proyecto → Trabajo sin fuga inversa

```text
actor activo
  └─ permiso de operación
      └─ acceso al Proyecto
          └─ si la fila es de Trabajo: asignación/acceso al Trabajo
              └─ fila.proyecto_id = Trabajo.proyecto_id
```

- Acceder a un Proyecto puede habilitar el agregado autorizado y sus Trabajos conforme a la matriz aprobada.
- Acceder a un Trabajo nunca habilita otro Trabajo hermano ni amplía por sí solo la visibilidad del Proyecto completo.
- Una entidad hija solo es visible si sus claves directas conservan el mismo par `proyecto_id + trabajo_id`.
- Una referencia desde notificación, aprobación, auditoría, documento, tarea o búsqueda se reautoriza contra el recurso objetivo.
- El Proyecto agregado conserva identificadores de Trabajo; no fusiona tipos, estados, responsables ni historia.

## Superficies especiales

### Auditoría e intentos rechazados

RLS puede ocultar filas o rechazar DML antes de que un trigger de negocio observe el intento. Por eso los rechazos se registran en el límite autoritativo del backend mediante un comando mínimo de auditoría, con UTC, actor, rol efectivo, módulo, entidad/identificador no sensible, acción, resultado, motivo normalizado, IP disponible y `correlation_id`. Nunca se registra SQL, JWT, cookies, credenciales, contenido de documentos ni datos personales innecesarios.

Los clientes pueden consultar auditoría solo si la matriz aprobada lo permite. No pueden insertar, actualizar ni eliminar eventos. El escritor de auditoría es un puerto backend de solo adición; exportar auditoría genera otro evento.

### Vistas, búsquedas y reportes

Las vistas expuestas deben ejecutar con privilegios del invocador y apoyarse exclusivamente en relaciones con RLS. Búsqueda, conteos, tablero, enlaces profundos y exportaciones aplican el mismo alcance antes de proyectar o agregar. Un total no puede revelar la existencia de filas denegadas.

### Funciones RPC

Una RPC valida actor, contrato, permiso, alcance, versión y motivo. No acepta un rol o alcance aportado por el cliente como autoridad. Se niega `EXECUTE` a `anon` y `PUBLIC`, salvo contrato público expresamente aprobado (ninguno en Fase 2). Las funciones dinámicas parametrizan valores y no interpolan identificadores no permitidos.

### Procesos privilegiados

Cron, outbox, respaldo e integraciones usan identidades separadas y privilegios mínimos por propósito. `service_role` no se usa como sustituto de políticas RLS ni para demostrar `AC-010-01/02`. Toda acción conserva correlación e idempotencia; el proceso no puede leer credenciales de otro propósito.

`approval_requests` y `drive_operations` no admiten `UPDATE` directo desde ningún rol cliente. El navegador solo crea una solicitud válida atribuida al actor; decisión, ejecución, estado, tipo de operación y resultado autoritativo avanzan mediante backend/trabajador y revalidan versión, aprobación e idempotencia. `registered_by`, `requested_by` y `decided_by` deben coincidir con la identidad autenticada, y quien solicita no decide su propia solicitud.

## Amenazas ASVS L2 aplicables

| Amenaza                                  | Control preventivo/detectivo                                       | Prueba/evidencia de Fase 2                                    |
| ---------------------------------------- | ------------------------------------------------------------------ | ------------------------------------------------------------- |
| Acceso horizontal/vertical               | actor activo, permiso, RLS total y alcance Proyecto/Trabajo        | matriz allow/deny; asignado/no asignado; referencia indirecta |
| Rol/alcance falsificado en JWT           | rol efectivo en base; no confiar en metadatos mutables             | JWT con rol falso continúa denegado                           |
| Usuario no autorizado/revocado           | allowlist interna y revocación consultada por operación            | pruebas negativas y evento de rechazo preparado               |
| Omisión de autorización UI/backend       | políticas servidor y `WITH CHECK`                                  | DML directo como `authenticated` se rechaza                   |
| Fuga mediante vista/RPC/agregado         | `security_invoker`, RLS previa y contratos mínimos                 | inventario de catálogo y pruebas por superficie               |
| RLS recursiva o helper privilegiado      | helper privado booleano, `search_path` fijo, grants mínimos        | inspección `pg_proc`, propietarios y ACL                      |
| Cambio de claves para escapar de alcance | `USING` + `WITH CHECK`, FK compuesta Proyecto/Trabajo              | actualización cruzada denegada                                |
| Edición/borrado de historia              | append-only, sin `UPDATE/DELETE` cliente                           | casos negativos por cada tabla append-only                    |
| Secreto/binario en cliente o esquema     | allowlist de campos, backend/vault, revisión de bundle/repositorio | escaneo estático y catálogo de columnas                       |
| Inyección                                | Zod/servidor, SQL parametrizado, `search_path` seguro              | revisión de funciones y pruebas con entradas hostiles         |
| Reintento/concurrencia                   | clave idempotente, versión esperada, outbox                        | casos repetidos y versión obsoleta                            |
| Enumeración por error                    | respuestas uniformes sin confirmar existencia                      | mismo resultado fuera de alcance/inexistente                  |
| Abuso de `service_role`                  | solo backend, identidad separada y no incluida en pruebas cliente  | escaneo de bundle/configuración y revisión independiente      |

## Inventario y criterio de cierre

El inventario canónico se obtiene de `pg_class`, `pg_namespace`, `pg_policies`, `pg_proc` y ACL en `supabase/tests/`. El arnés compara todas las tablas, vistas/materializadas y funciones de esquemas expuestos con un manifiesto versionado y falla ante una superficie desconocida.

No se declara PASS de seguridad ni G2 hasta que:

- `DEC-0103` esté aprobada y reflejada sin ambigüedad en políticas y matriz;
- la migración limpia y la ruta de actualización hayan corrido en PostgreSQL;
- la matriz positiva/negativa de los cuatro roles haya corrido sin `service_role`;
- toda superficie expuesta esté inventariada y cubierta;
- vistas/RPC privilegiadas tengan justificación y revisión;
- revocación, coherencia Proyecto/Trabajo, append-only y referencias indirectas se demuestren;
- la revisión independiente cierre con cero P0/P1.

Hasta entonces, el resultado válido es **preparado/no ejecutado o bloqueado**, nunca aprobado.
