# Estándar de desarrollo UI/UX

Estado: **normativo desde 2026-07-23**  
Alcance: prototipos, aplicación React, Storybook, pruebas y documentación de interfaz.  
Base: `DEC-0114`, `DEC-0116`, `DEC-0117`, RF-016 y RF-020.

## Propósito

Toda interfaz debe construirse con patrones consolidados y reconocibles de productos profesionales. No se inventan controles, vocabulario ni comportamientos cuando ya existe una convención ampliamente utilizada y accesible.

La referencia de implementación es, en este orden:

1. decisión de producto más reciente;
2. este estándar y los documentos de `docs/ux/`;
3. componentes aprobados de Mantine y Tabler Icons;
4. patrones WAI-ARIA/WCAG y sistemas de diseño maduros como Fluent y Carbon;
5. una variante nueva únicamente cuando el patrón existente no resuelva el caso, con justificación y prueba de usuario.

“Popular” no significa copiar una moda visual. Significa aprovechar convenciones que reducen aprendizaje, son coherentes con la plataforma y han sido probadas para teclado, tacto y tecnologías de asistencia.

## Regla previa a desarrollar un control

Antes de agregarlo:

1. identificar la tarea real del usuario;
2. buscar un componente equivalente en Mantine/Tabler y en el inventario local;
3. comprobar cuál es la convención habitual para abrir, cerrar, volver, desplegar, filtrar o mostrar más acciones;
4. elegir el elemento semántico nativo correcto: enlace para navegar, botón para ejecutar, `select` para seleccionar;
5. definir nombre accesible, foco, teclado, tacto, estados y retorno de foco;
6. validar el texto con una persona no técnica: si necesita explicación, se reescribe.

No se agrega un botón textual para explicar una acción que ya tiene un icono universal. Tampoco se reemplaza con un icono una acción de negocio que necesita claridad.

## Controles convencionales obligatorios

| Contexto                                | Presentación visible                                          | Nombre accesible recomendado                         | Comportamiento                                                |
| --------------------------------------- | ------------------------------------------------------------- | ---------------------------------------------------- | ------------------------------------------------------------- |
| Menú lateral expandido                  | marca `J`, título `JBC Proyectos` y `IconX` (`×`) en una fila | `Mostrar solo iconos del menú principal` para la `×` | vuelve al rail slim y conserva ruta/foco                      |
| Menú lateral slim                       | única marca `J` dentro de un botón de 44 px                   | `Expandir menú principal`                            | restaura etiquetas sin cambiar de ruta; no añade `☰` debajo  |
| Modal, drawer, inspector, panel o aviso | `IconX` en la esquina superior derecha                        | `Cerrar {contexto}`                                  | admite `Escape` cuando aplica y devuelve el foco al activador |
| Volver a la pantalla anterior           | flecha hacia atrás; en móvil puede incluir el destino         | `Volver a {destino}`                                 | navega; no usa `×`                                            |
| Más acciones                            | elipsis horizontal o vertical                                 | `Más acciones para {objeto}`                         | abre menú; no ejecuta una acción por sí sola                  |
| Expandir contenido inline               | chevron                                                       | `Mostrar {contenido}`                                | anuncia estado con `aria-expanded`                            |

Reglas específicas:

- El sidebar no muestra botones con los textos `Compactar` o `Expandir`. En modo slim, la única `J` funciona como control de expansión; abierto, la `×` queda a la derecha de `JBC Proyectos` en la misma fila. Los nombres descriptivos permanecen en `aria-label` y tooltip.
- El sidebar principal no expone páginas técnicas como grupo permanente. El único acceso inferior es `⚙ Configuración`; abierto muestra icono y texto, slim muestra solo el engranaje con el mismo nombre accesible. Entorno, versión y estados técnicos viven dentro de Configuración o en avisos no productivos, no como destinos principales separados.
- Un cierre ordinario no muestra un botón textual `Cerrar`. Usa `IconX` con nombre accesible contextual.
- `×` nunca significa eliminar, archivar, cancelar un proyecto ni descartar datos sin confirmación.
- Una flecha vuelve o navega; un chevron expande; una elipsis abre más acciones. No se intercambian sus significados.
- El icono es decorativo para el lector (`aria-hidden="true"`); el control aporta el nombre.
- El tooltip ayuda a usuarios visuales, pero no sustituye el nombre accesible ni una etiqueta visible cuando la acción es ambigua.

## Cuándo conservar texto visible

Se usan etiquetas visibles para:

- acciones primarias y de negocio: `Publicar`, `Guardar`, `Aprobar`, `Archivar`, `Consultar ahora`;
- acciones destructivas, sensibles o poco frecuentes;
- comandos propios del dominio sin icono universal;
- decisiones con consecuencias distintas o que exigen confirmación;
- cualquier icono que falle una prueba rápida de reconocimiento sin explicación.

No se fuerza una interfaz “solo iconos”. Los iconos compactan el chrome conocido; el texto explica el trabajo del negocio.

## Contrato de accesibilidad para botones de icono

Todo botón de icono debe:

- ser un `<button type="button">` nativo, o un enlace real si su única función es navegar;
- tener nombre accesible corto, específico y orientado a la acción;
- exponer `aria-expanded`, `aria-controls`, `aria-pressed` o `aria-haspopup` cuando corresponda;
- ser operable con `Enter` y `Espacio`, y con `Escape` para cerrar capas compatibles;
- tener foco visible, estados hover/pressed/disabled y contraste suficiente;
- usar un objetivo de **44 × 44 px** en este producto;
- devolver el foco al activador al cerrar una capa, salvo que el flujo conduzca lógicamente a otro punto;
- mantener tooltip disponible en hover y foco para controles sin texto visible;
- probarse con zoom 200 %, teclado, tacto y lector de pantalla.

## Lenguaje comprensible y vocabulario del producto

La interfaz habla en español directo. Los términos técnicos pueden existir en dominio, contratos, métricas o arquitectura, pero no llegan automáticamente a la UI.

Para APT/SIRI y datos sincronizados:

| Concepto técnico         | No mostrar         | Texto de interfaz                      |
| ------------------------ | ------------------ | -------------------------------------- |
| frescura de datos        | `Frescura`         | `Actualización`                        |
| datos dentro del umbral  | `Actual`           | `Al día` o `Datos actualizados`        |
| fotografía antigua       | `Frescura vencida` | `Datos de hace {periodo}`              |
| último éxito del monitor | jerga de ciclo     | `Última consulta exitosa` + fecha/hora |
| momento de la fotografía | timestamp aislado  | `Fecha de corte` + fecha/hora          |

En **Proyecto → Resumen → Estado oficial externo → APT**, el bloque usa como mínimo `Último cambio` y `Actualización`; el valor normal es `Al día`. Si los datos envejecen, muestra edad comprensible y la última consulta exitosa. El término visible `Frescura` queda prohibido.

Antes de introducir otra palabra técnica se valida:

1. ¿la usa normalmente el personal de JBC?;
2. ¿describe una acción o dato concreto?;
3. ¿hay una alternativa cotidiana más clara?;
4. ¿el mensaje indica qué ocurrió y qué puede hacer el usuario?

## Implementación objetivo

## Densidad de bordes y superficies

Una pantalla no debe depender de un contorno completo para identificar cada nivel de información. La prioridad para construir jerarquía visual es:

1. espacio y alineación;
2. título, peso y tamaño tipográfico;
3. cambio sutil de superficie neutra;
4. divisor local;
5. borde completo, solo cuando los recursos anteriores no bastan o el control lo requiere.

Reglas obligatorias:

- una zona funcional usa, como máximo, una delimitación estructural principal;
- no se apilan bordes en panel, tarjeta hija y cada fila de esa tarjeta;
- grupos breves relacionados se separan con espacio; una lista extensa puede usar divisores horizontales discretos;
- una selección puede usar un marcador lateral, fondo de selección y texto, sin encerrar de nuevo toda la jerarquía;
- campos editables, foco, error, arrastre activo y controles que necesitan reconocer su área conservan una señal visible suficiente;
- quitar bordes nunca autoriza quitar contenido, acciones, estados ni nombres accesibles;
- el resultado se revisa en claro y oscuro: las superficies adyacentes deben seguir siendo distinguibles sin convertir el color de acento en fondo dominante.

En la revisión visual se debe contar la repetición de delimitaciones, no solo valorar cada componente de forma aislada. Si una región se entiende al retirar el borde de sus hijos, ese borde es redundante.

## Implementación objetivo

En la aplicación React se priorizan `ActionIcon`, `Tooltip`, `Drawer`, `Modal` y otros componentes Mantine aprobados, con iconos de `@tabler/icons-react`. No se dibujan iconos nuevos si Tabler ya contiene el significado necesario.

Ejemplo conceptual:

```tsx
<Tooltip label="Cerrar detalle">
  <ActionIcon aria-label="Cerrar detalle" onClick={onClose} size={44} variant="subtle">
    <IconX aria-hidden="true" />
  </ActionIcon>
</Tooltip>
```

El prototipo HTML representa la expansión del rail con la marca `J` y su reducción con `×`; debe conservar semántica de botón, nombres y objetivos táctiles equivalentes.

## Patrones prohibidos

- texto visible `Cerrar`, `Compactar` o `Expandir` ocupando espacio cuando el contexto admite inequívocamente `×`, la marca `J` acordada o un chevron;
- mostrar simultáneamente `J` y `☰` en el encabezado del rail compacto, o colocar la `×` en una fila separada del título abierto;
- usar el pie del sidebar para estado técnico, versión o varios enlaces de sistema cuando existe el destino único `Configuración`;
- iconos ambiguos o decorativos convertidos en acciones;
- un mismo icono con significados distintos;
- botones sin nombre accesible o cuyo nombre sea solo `X`, `Menú` o `Icono`;
- tooltip como única explicación de una acción de negocio;
- controles personalizados que duplican un componente estándar;
- jerga de arquitectura, integración o datos expuesta sin traducción;
- cierre sin retorno de foco, objetivos menores a 44 px o acción disponible solo en hover.

## Revisión obligatoria

Una interfaz no pasa revisión si no demuestra:

- componente estándar elegido y significado consistente;
- lenguaje comprensible para una persona no técnica;
- icono, nombre accesible y tooltip coherentes;
- teclado, foco, `Escape` y retorno de foco;
- 44 × 44 px y ausencia de desbordamiento desde 360 px;
- temas claro y oscuro, zoom 200 % y contraste;
- prueba visual en navegador y prueba estructural automatizable;
- actualización de inventario, decisión y evidencia cuando el patrón sea nuevo.

## Referencias de práctica

- [WAI-ARIA Authoring Practices — Button Pattern](https://www.w3.org/WAI/ARIA/apg/patterns/button/)
- [WAI — nombres y descripciones accesibles](https://www.w3.org/WAI/ARIA/apg/practices/names-and-descriptions/)
- [WCAG 2.2 — tamaño mínimo de objetivos](https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum)
- [Fluent 2 — Button](https://fluent2.microsoft.design/components/web/react/core/button/usage)
- [Carbon — UI shell left panel](https://carbondesignsystem.com/components/UI-shell-left-panel/usage/)
