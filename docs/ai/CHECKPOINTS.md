# Checkpoints y aprobaciones

Estado: **gobernanza vigente; G0, CP-UX y G2 aprobados; Fase 3 activa y G3 pendiente**

G0: **aprobado por el usuario el 2026-07-23**. DEC-0101 y DEC-0102 quedaron resueltas en la misma aprobación.

CP-UX: **aprobado por el usuario el 2026-07-23**. R2 emitió GO con 0 P0/P1/P2/P3 abiertos. Fase 1 está cerrada; Fase 2 no se inició en este cierre.

G2: **aprobado por el usuario el 2026-07-23** con la declaración “Aprobado cierre fase 2”. R6 emitió GO con 0 P0/P1/P2/P3. Fase 2 está cerrada y Fase 3 no se inició en este cierre.

G3: **pendiente / NO-GO independiente R3**. La base local está implementada y `DEC-0209` fue aprobada para GitHub Actions, pero falta publicar/proteger `Main`, el recorrido UI→PostgREST→DB único, la validación Entra autorizada, revisión sin P0/P1 y aprobación del usuario. No iniciar Fase 4.

| ID        | Momento                             | Evidencia mínima                                                                                                                                      | Aprobación requerida                                                        | Si no se aprueba                                        |
| --------- | ----------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------- | ------------------------------------------------------- |
| G0        | cierre Fase 0                       | inventario; 100/100 criterio→fase→prueba; RF-013 0 activo; módulos, amenazas, riesgos, contradicciones, secuencia, propiedad y revisión independiente | usuario aprueba línea base y decisiones abiertas necesarias para Fase 1     | no iniciar Fase 1; corregir solo F0                     |
| CP-UX     | cierre Fase 1                       | navegación, flujos, tokens, estados y prototipo/capturas 360/768/1024/1440                                                                            | usuario aprueba navegación, lenguaje visual, móvil y pantallas              | iterar UX; no construir todos los módulos               |
| G2        | cierre Fase 2                       | modelo/contratos/ADR, migración limpia/actualizada, RLS positiva/negativa, revisión seguridad                                                         | usuario acepta arquitectura/datos/permisos; revisor independiente sin P0/P1 | no crear skeleton conectado                             |
| G3        | cierre Fase 3                       | walking skeleton vertical, CI, PWA, versión/entorno, secretos ausentes                                                                                | usuario acepta base ejecutable/identidad                                    | no ampliar módulos                                      |
| G4        | cierre Fase 4                       | permisos negativos, doble control, obsolescencia, ejecución única, catálogos históricos y eventos idempotentes                                        | usuario acepta capacidades transversales                                    | no iniciar operaciones sensibles                        |
| CP-GRAPH  | Fase 7 antes de escritura real      | simulador/contrato, scopes mínimos, tenant/carpeta de prueba, vista previa, rollback y revisión                                                       | usuario autoriza ambiente y escritura Graph                                 | continuar solo con simulador                            |
| CP-APT    | Fase 9 antes de automatización real | lista blanca, fixtures, resultado legal/técnico, credenciales individuales, política CAPTCHA/MFA y worker                                             | autorización institucional/técnica documentada + usuario                    | no conectar; conservar fixtures/fallback                |
| CP-WORKER | Fase 9                              | comparativo Cloud Run vs Windows, costo, seguridad, operación                                                                                         | usuario elige y autoriza costo/infraestructura                              | mantener trabajador local/simulado según alcance seguro |
| CP-AI     | Fase 10 antes de API real           | minimización, modelos disponibles/configurables, presupuesto/alertas, `store:false`, simuladores y seguridad                                          | usuario aprueba datos, modelos y gasto                                      | continuar con simulador                                 |
| CP-EXPORT | Fase 11                             | formato, datos incluidos, permiso y aprobación para OneDrive                                                                                          | usuario aprueba política de exportación/guardado                            | exportación/guardado afectado queda deshabilitado       |
| G12-UAT   | cierre Fase 12                      | todos los AC, E2E 1–19, RLS, WCAG/ASVS, rendimiento/capacidad, degradación, restore, docs y UAT                                                       | usuarios designados aceptan UAT                                             | corregir; no congelar release                           |
| GO-PROD   | antes de producción                 | release notes, backup válido/restaurado, rollback, 0 P0/P1, aprobaciones, smoke plan                                                                  | usuario aprueba producción explícitamente                                   | no desplegar producción                                 |

## Aprobaciones materiales todavía pendientes

1. `DEC-0104`: matriz de nivel y composición por acción sensible, antes de G4.
2. `DEC-0202`: formato del código interno único, antes de Fase 5.

Ya están resueltos el tratamiento histórico APT/SIRI (`DEC-0101`), la ventana 07:00–20:00 y el silencio 20:00–07:00 (`DEC-0102`), el alcance por rol (`DEC-0103`) y la adopción de la gobernanza documental (`DEC-0201`).

Las decisiones de credenciales, proveedores reales, costos y producción pueden esperar a su checkpoint; no bloquean UX/documentación independiente.
