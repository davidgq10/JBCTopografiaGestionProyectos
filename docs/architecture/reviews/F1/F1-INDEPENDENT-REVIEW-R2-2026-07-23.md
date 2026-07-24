# Revisión independiente R2 de arquitectura y UX — Fase 1

**ID:** `F1-ARCH-R2`  
**Fecha:** 2026-07-23 (`America/Costa_Rica`)  
**Rol:** revisor independiente; sin autoría ni modificación de los artefactos revisados  
**Dictamen:** **GO para presentar CP-UX al usuario; 0 P0 y 0 P1 abiertos**

Este dictamen permite presentar el checkpoint de UX. No aprueba CP-UX, no cierra Fase 1 por cuenta propia y **no autoriza iniciar Fase 2**.

## 1. Alcance y método

Se contrastaron la especificación aprobada y su Anexo A, `AGENTS.md`, el estándar normativo UI/UX, el plan y reporte de Fase 1, estado/checkpoints, trazabilidad, documentación UX, revisión R1, prototipo `prototypes/fase1/**` y evidencia activa `docs/testing/evidence/F01/**`.

La regresión cubrió:

- navegación general e inmersiva y Proyecto/Contratación `1:N` Trabajos;
- APT/SIRI condicionado al Trabajo aplicable e historia externa legítima;
- Contexto vivo, inspector, `Filtrar por tipo`, compositor único y OneDrive conceptual;
- IA contextual, sidebar slim, Configuración y lenguaje de interfaz;
- accesibilidad automática, teclado/foco y atestación manual posterior del usuario;
- capturas activas en 360, 768, 1024 y 1440 px, temas claro/oscuro y manifiestos/hashes;
- corrección de compresión de `.compact-ai-suggestion` con Contexto vivo e IA abiertos a 1440 px.

Se ejecutaron comprobaciones independientes de solo lectura: `node --check`, balance de CSS, búsqueda de patrones retirados y comparación SHA-256 de las tres fuentes del prototipo y las cinco capturas activas. Los hashes y tamaños coincidieron 8/8 con `F01-VISUAL-MANIFEST-R2-2026-07-23.md`; `styles.css` quedó balanceado `569/569`. La evidencia integrada adicional `F01-MACHINE-CHECKS-R2-2026-07-23.md` informa 5/5 hashes visuales, cero capturas obsoletas en la raíz activa y ausencia de instrumentación temporal.

## 2. Regresión de hallazgos R1

| Hallazgo R1                                           | Resultado R2                                | Evidencia decisiva                                                                                                                                                                                                                                                                                                                                                                  |
| ----------------------------------------------------- | ------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `F1-REV-P1-01` — mezcla Proyecto/Trabajo              | **CERRADO**                                 | `projects` conserva atributos contractuales y `worksByProject` modela 4 Contrataciones/8 Trabajos sin vacíos; alta, agregados, rutas e IA mantienen Proyecto + Trabajo. `PROJECT-WORKS-AUDIT-2026-07-23.md` registra 42/42 enlaces operativos con `work=` en la regresión final.                                                                                                    |
| `F1-REV-P1-02` — APT/SIRI fuera del Trabajo aplicable | **CERRADO**                                 | APT activo únicamente en Trabajos `Plano de catastro`; el caso no catastral ordinario no expone superficies externas y `TR-0018-01` conserva solo historia inactiva legítima con tipo/estado anterior, actor, UTC y aprobación.                                                                                                                                                     |
| `F1-REV-P1-03` — accesibilidad incompleta             | **CERRADO para el checkpoint de prototipo** | axe-core 4.10.3: 0 infracciones finales `serious`/`critical` en cinco escenarios; teclado, foco, `Escape`, Contexto vivo, `/`, Publicar e IA regresados. La atestación posterior del usuario confirma zoom nativo 200 %, selector/arrastre del fixture y recorrido con Narrador. Los `NO EJECUTADO` históricos se preservan correctamente y no contradicen esa ejecución posterior. |
| `F1-REV-P2-01` — carga general paralela               | **CERRADO**                                 | La ruta general de Archivos funciona como navegación/búsqueda; la preparación de adjuntos queda en el compositor contractual con Proyecto + Trabajo, propuesta OneDrive, metadatos locales y un único `Publicar`. No queda `Subir documento` paralelo.                                                                                                                              |
| `F1-REV-P2-02` — capturas obsoletas mezcladas         | **CERRADO**                                 | Las cuatro capturas anteriores están separadas en `archive/pre-r2-obsolete-2026-07-23/` con manifiesto recuperable. El paquete activo contiene cinco capturas regeneradas; hashes verificados 5/5 y cero archivos obsoletos en la raíz.                                                                                                                                             |
| `F1-REV-P3-01` — verificado/inferido ambiguo          | **CERRADO**                                 | La evidencia conserva resultados históricos y distingue `PASS`, `FAIL→PASS`, `PARCIAL` y `NO EJECUTADO`, con responsable, método y fecha. La ejecución física posterior está documentada separadamente como atestación del usuario.                                                                                                                                                 |

## 3. Regresión visual y corrección a 1440 px

El paquete activo demuestra reflujo sin desplazamiento horizontal general en 360, 768, 1024 y 1440 px, con tema claro y oscuro. La captura de 1440 mantiene simultáneamente Contexto vivo e IA sin superposición.

Durante la regeneración se detectó compresión vertical de `.compact-ai-suggestion` dentro de la columna primaria reducida. La regla específica para `body.is-project-route.assistant-open .project-primary .compact-ai-suggestion` cambió la franja a una columna y distribuyó las acciones de forma flexible. La regresión final registra contenedor de `300 px`, texto útil de `272 px`, alto de texto de `45 px`, Contexto vivo visible, IA abierta, `scrollWidth === innerWidth === 1440` y cero errores funcionales.

También se confirmaron el selector compacto de 11 tipos, sidebar slim con una sola `J`, encabezado expandido `J · JBC Proyectos · ×`, Configuración única al pie, ausencia visible de `Frescura` y conservación de las fuentes contractuales.

## 4. Conteo de hallazgos abiertos R2

| Prioridad | Abiertos |
| --------- | -------: |
| P0        |    **0** |
| P1        |    **0** |
| P2        |    **0** |
| P3        |    **0** |

## 5. Límites y pendientes no bloqueantes

- La atestación de zoom, archivo y Narrador es evidencia manual del propietario del producto, no video ni auditoría WCAG formal de terceros.
- axe dejó nodos `color-contrast` como `incomplete`; el hallazgo confirmado del token claro fue corregido y las revisiones visual/manual complementan, pero no constituyen certificación WCAG integral.
- Lighthouse ≥95 y la matriz completa Edge/Chrome/Android/iPhone permanecen como controles productivos asignados a Fases 3/12; no se presentan como ejecutados en este prototipo.
- El prototipo usa HTML/CSS/JavaScript y datos ficticios: no demuestra persistencia, RLS, integraciones reales ni el stack productivo, que pertenecen a fases posteriores autorizadas.
- La trazabilidad productiva conserva evidencias finales previstas para fases posteriores; al formalizar el cierre de F1 conviene enlazar también este R2 y el manifiesto visual desde el registro de fase correspondiente.

Estos límites están declarados y no reabren P0/P1 dentro del alcance del checkpoint UX.

## 6. Dictamen

**GO para presentar CP-UX al usuario.** Los seis hallazgos de R1 están cerrados en el corte revisado; no quedan P0/P1 abiertos y el paquete activo es coherente con las decisiones aprobadas de Fase 1.

La aprobación del usuario sigue siendo obligatoria para cerrar CP-UX. Este informe **no concede esa aprobación**, **no declara iniciada Fase 2** y **prohíbe avanzar a Fase 2 hasta que el usuario apruebe explícitamente el cierre de Fase 1 y la gobernanza se actualice**.
