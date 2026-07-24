# QA de accesibilidad R2 — Fase 1

**Fecha de ejecución:** 2026-07-23 10:45 (`America/Costa_Rica`) / 2026-07-23T16:45Z  
**Responsable:** subagente de cierre técnico `F1-REV-P1-03`  
**Alcance:** prototipo estático de Fase 1 con datos ficticios; sin servicios, persistencia ni archivos reales  
**Entorno:** Windows, Chrome controlado localmente (versión exacta no expuesta), servidor `127.0.0.1`, viewport observado 1206 × 941 CSS px  
**Corte:** `prototypes/fase1/index.html`, `app.js` y `styles.css` al 2026-07-23

## Dictamen

**Resultado global: PARCIAL.** Se ejecutaron pruebas reales de teclado, foco, `Escape`, Contexto vivo, comandos `/`, publicación, IA y axe-core. Se corrigieron dos hallazgos: contraste insuficiente del token claro `--text-muted` y ausencia de cierre del inspector mediante `Escape` con restauración del foco.

No se declara cerrado `F1-REV-P1-03` ni conformidad WCAG 2.2 AA completa: el zoom nativo 200 %, el arrastre físico con archivo, la selección completa en el diálogo nativo de archivos y el lector de pantalla real no pudieron demostrarse con este entorno. Permanecen registrados como `NO EJECUTADO` o `PARCIAL`, no como equivalencias inferidas.

## Matriz de ejecución

| Caso                                | Entorno / ruta                                  | Método real                                                                           | Resultado        | Evidencia y observación                                                                                                                                                                                                                                                                                    |
| ----------------------------------- | ----------------------------------------------- | ------------------------------------------------------------------------------------- | ---------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Enlace de salto                     | Inicio, oscuro                                  | `Tab` físico seguido de `Enter`; lectura de `document.activeElement`                  | **PASS**         | Primer foco: `Saltar al contenido principal`; después de `Enter`, foco en `main#app-main` con `tabindex=-1`.                                                                                                                                                                                               |
| Orden de teclado en Inicio          | Inicio, oscuro                                  | 28 pulsaciones físicas de `Tab`, registrando elemento activo                          | **PASS**         | Se recorrieron acciones de la página, launcher IA y el ciclo posterior por marca, toggle, navegación y Configuración; no apareció un bloqueo de foco.                                                                                                                                                      |
| Sidebar normal/slim                 | Inicio, oscuro                                  | `Enter` y `Espacio` sobre `#sidebar-toggle`                                           | **PASS**         | `aria-expanded` cambió `true → false → true`; nombre cambió a `Expandir menú principal` y volvió a `Mostrar solo iconos…`; el foco permaneció en el toggle.                                                                                                                                                |
| Selector de Contexto vivo           | Proyecto catastral `JBC-2026-0042 / TR-0042-01` | `Home` y cuatro `ArrowDown` sobre el `select` nativo                                  | **PASS**         | Se seleccionó `Tareas · 5`; se abrió el inspector `Tareas`; el foco permaneció en el selector.                                                                                                                                                                                                             |
| Cierre del inspector y restauración | Mismo Proyecto                                  | Selección `tareas`, después `Escape` físico                                           | **FAIL → PASS**  | Antes: inspector abierto y valor `tareas`. Después de la corrección: inspector oculto, valor vacío y foco restaurado al selector.                                                                                                                                                                          |
| Menú `/` del Contexto vivo          | Mismo Proyecto                                  | Escritura `/`, recorrido con `Tab` y activación de `/tarea` con `Enter`               | **PASS**         | Se mostraron cuatro comandos; `/tarea` quedó en el compositor, el menú se ocultó y el foco volvió al campo.                                                                                                                                                                                                |
| Publicar desde Contexto vivo        | Mismo Proyecto                                  | Escritura, `Tab` hasta `Publicar` y `Enter`                                           | **PASS**         | Se añadió el quinto evento simulado, se limpió el campo, se restauró foco y se anunció el toast. No hubo escritura real.                                                                                                                                                                                   |
| IA: apertura, cierre y foco         | Mismo Proyecto                                  | `Alt+I`, después `Escape`                                                             | **PASS**         | Apertura: foco en `#assistant-input`, `aria-hidden=false`. Cierre: foco en `#assistant-launcher`, `aria-hidden=true`.                                                                                                                                                                                      |
| Menú `/` de IA                      | Estructura e interacción del panel              | Inspección accesible y cierre priorizado por `Escape` incorporado en la corrección    | **PARCIAL**      | La apertura/cierre del panel fue real; no se repitió un recorrido completo de los seis comandos tras la corrección final.                                                                                                                                                                                  |
| Alternativa `Adjuntar` por teclado  | Compositor de Proyecto                          | Foco sobre `input[type=file]` y `Enter` con espera del `filechooser`                  | **PARCIAL**      | `Enter` abrió el selector nativo, pero la automatización quedó esperando en la superficie del sistema y la pestaña se perdió. No se verificaron selección final ni retorno de foco. El control conserva nombre accesible y la envolvente muestra `:focus-within`, pero eso no sustituye la parte faltante. |
| Arrastre físico con archivo         | Compositor de Proyecto                          | Capacidad de arrastre del navegador evaluada                                          | **NO EJECUTADO** | La superficie disponible puede arrastrar coordenadas, pero no aportar un archivo físico al `DataTransfer`; no se simuló como equivalente.                                                                                                                                                                  |
| Zoom nativo 200 %                   | Proyecto catastral                              | `Ctrl+0`, siete intentos `Ctrl++` y un intento `Ctrl+=`; medición de `innerWidth`/DPR | **NO EJECUTADO** | Los atajos fueron ignorados por la superficie controlada: `innerWidth` permaneció 1206 y la razón observada fue 1.0. El reflujo previo por ancho no se presenta como sustituto del zoom nativo.                                                                                                            |
| Lector de pantalla real             | Windows / temas claro y oscuro                  | Detección local de ejecutables y procesos                                             | **NO EJECUTADO** | `Narrator.exe` existe, pero no había sesión activa ni un canal auditable de voz/historial en esta ejecución; NVDA no fue detectado. Los snapshots accesibles del navegador son evidencia complementaria, no una prueba con lector real.                                                                    |
| Corte limpio                        | Proyecto no catastral, oscuro                   | Recarga final, inspección de scripts, consola y overflow                              | **PASS**         | Solo quedaron el script inline de tema y `app.js`; `axe-qa-results=false`, atributo QA ausente, consola sin errores/advertencias y sin overflow horizontal (`scrollWidth - innerWidth = -12`).                                                                                                             |

## Matriz axe-core

Se utilizó el paquete oficial **axe-core 4.10.3**, descargado solo para QA. SHA-256 de `axe.min.js`: `880970C081707360E64F34CEA25FF91892F5BC95675B0776925B9709DD8A68BB`.

Configuración: reglas etiquetadas `wcag2a`, `wcag2aa`, `wcag21a`, `wcag21aa` y `wcag22aa`; resultados `violations` e `incomplete`.

| Escenario                                  |   Tema | Violaciones serious/critical | `incomplete`                                    | Resultado                                                              |
| ------------------------------------------ | -----: | ---------------------------: | ----------------------------------------------- | ---------------------------------------------------------------------- |
| Inicio                                     | Oscuro |                            0 | `color-contrast`, 14 nodos para revisión manual | **PASS** para violaciones; **PARCIAL** para comprobaciones incompletas |
| Inicio, después de corregir `--text-muted` |  Claro |                            0 | `color-contrast`, 14 nodos para revisión manual | **PASS** para violaciones; **PARCIAL** para comprobaciones incompletas |
| Proyecto catastral `TR-0042-01`            | Oscuro |                            0 | `color-contrast`, 34 nodos para revisión manual | **PASS** para violaciones; **PARCIAL** para comprobaciones incompletas |
| Contexto vivo `Tareas` + IA abiertos       | Oscuro |                            0 | `color-contrast`, 17 nodos para revisión manual | **PASS** para violaciones; **PARCIAL** para comprobaciones incompletas |
| Proyecto no catastral `TR-0018-02`         | Oscuro |                            0 | `color-contrast`, 20 nodos para revisión manual | **PASS** para violaciones; **PARCIAL** para comprobaciones incompletas |

### Hallazgo y corrección de contraste

Una ejecución estable en tema claro confirmó contrastes entre 4.01:1 y 4.35:1 para texto secundario con `--text-muted: #64748b`, por debajo de 4.5:1. Se cambió el token a `#5b6778`. Sus razones calculadas son 5.26:1 sobre `#f4f5f6`, 5.74:1 sobre blanco, 4.98:1 sobre `#eceff2` y 4.84:1 sobre `#e9ecef`. La repetición de axe en Inicio claro quedó con **0 violaciones**.

Los casos `incomplete` no se convirtieron en PASS automático: axe no pudo resolver todos los fondos/estados dinámicos y exige revisión manual. La revisión documental previa de pares de tokens sigue siendo complementaria, pero no sustituye un lector real ni el zoom nativo.

## Correcciones permanentes

1. `prototypes/fase1/app.js`
   - nueva función `closeRelatedInspector`;
   - `Escape` cierra primero el menú `/` de IA, el inspector relacionado o el menú `/` del Contexto vivo, según corresponda;
   - el inspector limpia su selector y devuelve el foco al mismo control;
   - el botón `×` reutiliza la misma lógica.
2. `prototypes/fase1/styles.css`
   - `--text-muted` claro cambió de `#64748b` a `#5b6778` para superar 4.5:1 en las superficies observadas.

No se alteraron `DEC-0115`, `DEC-0116` ni `DEC-0117`.

## Higiene y verificaciones finales

- `node --check prototypes/fase1/app.js`: **PASS**.
- Balance CSS: **566** llaves de apertura y **566** de cierre: **PASS**.
- Búsqueda de `.qa-axe`, `axe-qa-results`, `axe.min`, atajo QA y `.qa-upload` en `prototypes/fase1`: **sin coincidencias**.
- Carpeta temporal `.qa-axe` y archivo ficticio `.qa-upload.txt`: eliminados tras validar que sus rutas estaban dentro del workspace.
- Recarga del corte limpio: consola con **0** errores/advertencias.

## Pendientes obligatorios para cerrar `F1-REV-P1-03`

1. Ejecutar zoom nativo real al 200 % en Chrome/Edge y conservar captura o video con contenido y controles disponibles.
2. Completar la selección de un archivo ficticio mediante `Adjuntar` usando solo teclado y verificar retorno de foco; repetir por tacto.
3. Ejecutar un arrastre físico de archivo al campo del compositor.
4. Ejecutar una verificación mínima con Narrator o NVDA en claro y oscuro, incluyendo nombres, estados, cambios anunciados y cierre de capas.
5. Revisar manualmente los nodos que axe dejó como `incomplete` en `color-contrast`.

Hasta completar esas pruebas, esta evidencia mejora y acota el hallazgo, pero **no autoriza cerrar CP-UX ni iniciar Fase 2**.
