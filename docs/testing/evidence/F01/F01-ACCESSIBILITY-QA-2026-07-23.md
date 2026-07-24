# QA de accesibilidad — Fase 1

Fecha: 2026-07-23 (`America/Costa_Rica`)

## Verificado en el prototipo

- Documento en español, regiones `main`, navegación principal/móvil, breadcrumbs, headings y listas semánticas.
- Enlace `Saltar al contenido principal` visible al foco.
- Regla global `:focus-visible` de 3 px y alternativa textual/iconográfica para estados.
- Controles con mínimo táctil objetivo de 44 px en navegación y acciones principales.
- Sidebar slim conserva nombres accesibles aunque visualmente muestre solo iconos; su encabezado muestra únicamente una `J` como botón `Expandir menú principal`. Expandido alinea `J`, `JBC Proyectos` y la `×` rotulada `Mostrar solo iconos del menú principal`; el mismo botón conserva `aria-controls`, `aria-expanded` y foco visible.
- Contexto vivo tiene un selector nativo `Filtrar por tipo` con 11 opciones y conteos; el inspector usa `aria-live="polite"`, cierre rotulado y retorno de foco al selector.
- Los nombres de tarea, archivo, trabajo y otros objetos son enlaces reales; `Inspeccionar…` queda como acción secundaria.
- Compositor único rotulado como `Anotación, comando o archivo del proyecto`; el selector de archivo tiene nombre accesible explícito.
- IA: `role="dialog"`, contexto activo, cierre rotulado, atajo `Alt+I`; orden DOM y visual compositor → conversación.
- Tema claro/oscuro mantiene información textual además del color.
- Contraste documental de tokens: 52/52 pares aprobados, relación mínima 4.75:1.
- `overflow-x` general fue 0 en 360, 768, 1024 y 1440 px; nombres, rutas, badges y estados usan wrap/min-width seguro.

## Comprobaciones parciales o posteriores

- La API de automatización del navegador no avanzó el foco con `Tab`; el recorrido completo de teclado se mantiene como prueba manual obligatoria antes de aprobar el checkpoint.
- El gesto físico de drag-and-drop y la devolución de foco tras selector nativo requieren prueba manual; existe alternativa `Adjuntar` operable por teclado/tacto.
- Axe-core, lector de pantalla real, Lighthouse y zoom nativo 200 % no se ejecutaron aquí. La matriz de reflujo cubre sus anchos equivalentes, pero no sustituye esas ejecuciones.

## Estado posterior a la revisión independiente R1

La revisión independiente clasificó estas comprobaciones faltantes como `F1-REV-P1-03`, bloqueante para CP-UX. Por tanto, la inspección estructural anterior **no demuestra todavía conformidad WCAG 2.2 AA ni permite cerrar Fase 1**.

El siguiente corte debe registrar cada prueba como `PASS`, `FAIL`, `PARCIAL` o `NO EJECUTADO`, con método, responsable, entorno y artefacto. Debe cubrir teclado/foco de extremo a extremo, restauración de foco, alternativa al arrastre, zoom nativo 200 %, axe-core y lector de pantalla en ambos temas; cualquier resultado serio/crítico debe corregirse y regresarse antes de la revisión R2.
