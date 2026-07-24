# Handoff — Fase 1 lista para CP-UX

> **Sustituido:** CP-UX fue aprobado posteriormente. Continúe desde `F1-CLOSED-2026-07-23.md`.

**Fecha:** 2026-07-23 (`America/Costa_Rica`)  
**Estado técnico:** entregables, integración, evidencia y R2 completos  
**Estado de gobernanza:** Fase 1 todavía abierta hasta decisión explícita del usuario  
**Fase 2:** no iniciada ni autorizada

## Punto exacto de continuación

La revisión independiente R2 emitió **GO para presentar CP-UX** con **0 P0, 0 P1, 0 P2 y 0 P3 abiertos**. Los seis hallazgos de R1 están cerrados. El único paso pendiente es preguntar al usuario si aprueba formalmente CP-UX y el cierre de Fase 1.

La respuesta anterior `Aprobado` correspondió a las pruebas físicas de accesibilidad solicitadas —zoom 200 %, adjunto/arrastre y Narrador— y no debe reinterpretarse como autorización retroactiva de CP-UX o Fase 2.

## Evidencia canónica

1. `docs/ai/PHASE_1_REPORT.md`
2. `docs/architecture/reviews/F1/F1-INDEPENDENT-REVIEW-R2-2026-07-23.md`
3. `docs/testing/evidence/F01/F01-ACCESSIBILITY-QA-R2-2026-07-23.md`
4. `docs/testing/evidence/F01/F01-ACCESSIBILITY-USER-ATTESTATION-2026-07-23.md`
5. `docs/testing/evidence/F01/F01-VISUAL-MANIFEST-R2-2026-07-23.md`
6. `docs/testing/evidence/F01/F01-MACHINE-CHECKS-R2-2026-07-23.md`
7. `docs/testing/evidence/F01/PROJECT-WORKS-AUDIT-2026-07-23.md`
8. `docs/testing/evidence/F01/README.md`

## Resultado que debe presentarse

- navegación general e inmersiva por Proyecto;
- Proyecto/Contratación `1:N` Trabajos gestionados por separado;
- APT/SIRI solo en Trabajo de catastro e historia inactiva legítima al cambiar tipo;
- Contexto vivo ancho con 11 tipos bajo `Filtrar por tipo`, enlaces reales y compositor único;
- adjuntos desde el compositor con OneDrive conceptual y un solo `Publicar`;
- Asistente IA contextual a la derecha, comandos `/` y confirmación humana;
- sidebar slim con `J`, encabezado abierto `J · JBC Proyectos · ×` y Configuración única al pie;
- fondos neutros, temas claro/oscuro y fuentes Inter/Roboto Mono;
- cero desbordamiento horizontal en 360/768/1024/1440 y corrección de la propuesta IA comprimida;
- axe 0 `serious/critical`, controles de teclado/foco y validación física aprobada por el usuario.

## Si el usuario aprueba CP-UX

1. Crear `docs/testing/evidence/F01/F01-CP-UX-USER-APPROVAL-<fecha>.md` con la cita/alcance de la aprobación.
2. Marcar `CURRENT_STATUS.md`, `PHASE_1_REPORT.md`, `CHECKPOINTS.md` y `PHASE_1_PLAN.md` como Fase 1/CP-UX aprobados.
3. Conservar R1, intentos `NO EJECUTADO` y archivos archivados; no reescribir evidencia histórica.
4. Actualizar este handoff como cerrado y preparar un handoff de inicio de Fase 2.
5. Antes de construir Fase 2, leer objetivo, especificación/Anexo A y documentos canónicos; resolver `DEC-0103` antes de G2. No iniciar Fase 3 ni módulos productivos fuera del alcance autorizado.

## Si el usuario no aprueba o pide cambios

Registrar cada cambio como nueva decisión, limitarse a Fase 1, actualizar prototipo/evidencia, ejecutar regresión y solicitar R2 adicional si se reabre un P0/P1. Fase 2 permanece bloqueada.

## Prompt para un chat nuevo

```text
Continúa la Plataforma JBC desde el handoff:
docs/ai/HANDOFFS/F1-CP-UX-READY-2026-07-23.md

Lee primero el objetivo adjunto, la especificación completa y los ocho artefactos canónicos enumerados en el handoff. Fase 1 tiene R2 GO con 0 P0/P1/P2/P3, pero solo puede marcarse cerrada si existe aprobación explícita del usuario a CP-UX. No interpretes la aprobación de pruebas físicas como aprobación de CP-UX. Si CP-UX fue aprobado, registra evidencia, actualiza gobernanza y prepara el inicio acotado de Fase 2; no avances a Fase 3 ni construyas módulos fuera de alcance.
```
