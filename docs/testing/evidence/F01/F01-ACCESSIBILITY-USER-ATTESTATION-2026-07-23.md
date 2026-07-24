# Atestación manual de accesibilidad — Fase 1

**Fecha:** 2026-07-23  
**Responsable de ejecución:** usuario propietario del producto  
**Registro:** conversación de cierre de Fase 1  
**Entorno:** Google Chrome en Windows, prototipo local `127.0.0.1:41737`, Proyecto `JBC-2026-0042`, Trabajo `TR-0042-01`  
**Alcance:** validación física complementaria a `F01-ACCESSIBILITY-QA-R2-2026-07-23.md`

## Resultado

El usuario confirmó **“Aprobado”** después de recibir y ejecutar el siguiente bloque de validación manual:

| Caso                           | Método solicitado al usuario                                                                                                                    | Resultado | Evidencia                                           |
| ------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------- | --------- | --------------------------------------------------- |
| Zoom nativo 200 %              | Aumentar Chrome al 200 % y comprobar ausencia de desbordamientos o contenido inaccesible                                                        | **PASS**  | Atestación explícita del usuario en la conversación |
| Selector y arrastre de archivo | Usar `Adjuntar` y seleccionar o arrastrar `fixture-croquis-rev04.txt` al compositor; comprobar reconocimiento sin publicar                      | **PASS**  | Atestación explícita del usuario en la conversación |
| Lector de pantalla             | Activar Narrador y recorrer sidebar, Contexto vivo, compositor, `Publicar` y Asistente IA; comprobar nombres, controles y estados comprensibles | **PASS**  | Atestación explícita del usuario en la conversación |

## Integración con la evidencia automática

La evidencia técnica R2 ya registra:

- cero infracciones finales `serious` o `critical` en axe-core 4.10.3 para cinco escenarios representativos;
- recorrido de teclado, foco, sidebar, Contexto vivo, comandos `/`, `Publicar` e IA en `PASS`;
- corrección y regresión del cierre con `Escape` y de contraste del texto secundario.

Esta atestación no modifica los resultados históricos `NO EJECUTADO` de las corridas automatizadas. Los complementa con la ejecución física aprobada por el usuario y permite presentar `F1-REV-P1-03` a la revisión independiente R2 como **cerrado sujeto a confirmación del revisor**.

## Límites

- No se declara certificación integral WCAG 2.2 AA ni auditoría formal de terceros.
- No se publicaron archivos ni se probaron integraciones reales; el fixture es ficticio y local.
- Esta aprobación de pruebas no autoriza por sí sola Fase 2; CP-UX requiere el dictamen independiente R2 y el cierre formal de Fase 1.
