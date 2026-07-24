# Aprobación del usuario — DEC-0103

Fecha: **2026-07-23** (`America/Costa_Rica`)

Estado: **APROBADA**

El usuario definió y confirmó en la conversación de Fase 2:

- **Administrador:** alcance global; administra usuarios, roles, configuración y operación.
- **Coordinador:** alcance global; administra operación y asignaciones, pero no usuarios ni roles.
- **Técnico:** solo puede ver los Proyectos asignados a su propia cuenta; la asignación comprende todos los Trabajos de esos Proyectos; puede crear y actualizar datos operativos dentro de ellos. Una asignación aislada a Trabajo no concede alcance.
- **Solo lectura:** puede consultar todos los Proyectos y no realiza escrituras de negocio.

Continúan vigentes los invariantes aprobados: sin borrado físico de datos de negocio o historia; APT/SIRI solo lectura; auditoría append-only; acciones sensibles sujetas a aprobación; referencias indirectas no conceden alcance; validación en servidor y RLS en toda superficie expuesta.

Esta aprobación autoriza implementar y probar la matriz funcional RLS de Fase 2. No equivale por sí sola a aprobar G2.
