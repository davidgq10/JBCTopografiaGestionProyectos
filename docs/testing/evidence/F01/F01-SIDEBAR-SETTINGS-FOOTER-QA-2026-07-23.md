# QA de Configuración al pie del sidebar

Fecha: 2026-07-23 (`America/Costa_Rica`)  
Fase: F1 — UX y arquitectura de información  
Decisión: `DEC-0117`  
Artefacto: `prototypes/fase1/index.html`, `styles.css` y `app.js`

## Solicitud comprobada

Ocultar del sidebar el grupo `Sistema` con `Administración` y `Estados de interfaz`, y sustituir el pie `Prototipo · Fase 1 / Datos ficticios` por un único acceso con engranaje y texto `Configuración`.

## Resultado en navegador local

| Caso                      | Resultado                                                                                                                          | Estado                        |
| ------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- | ----------------------------- |
| Sidebar expandido         | no aparecen `Sistema`, `Administración`, `Estados de interfaz` ni `Prototipo · Fase 1`; al fondo aparece `⚙ Configuración`         | PASS                          |
| Posición                  | el borde inferior del enlace queda a menos de 30 px del borde inferior del sidebar                                                 | PASS                          |
| Sidebar slim 64 px        | se oculta la palabra `Configuración`; permanece únicamente el engranaje                                                            | PASS                          |
| Accesibilidad estructural | enlace real, `aria-label="Configuración"`, tooltip homónimo y texto accesible conservado aun cuando la etiqueta visual está oculta | PASS                          |
| Navegación                | abre `#administracion`; título del documento `Configuración · JBC Proyectos`; el enlace obtiene `aria-current="page"`              | PASS                          |
| Orientación               | la página destino usa `Configuración` como encabezado principal                                                                    | PASS tras ajuste de microcopy |
| Reflujo                   | 0 px de overflow horizontal en modo expandido y slim a 1024 px                                                                     | PASS                          |

Las rutas técnicas no se eliminaron. `#estados` permanece disponible para QA o acceso autorizado, pero deja de ser un destino permanente de navegación primaria. Entorno y versión siguen dentro de Configuración y el aviso persistente conserva la indicación de prototipo.

## Dictamen

`PASS` para `DEC-0117`. Esta regresión puntual no sustituye las pruebas integrales de teclado, zoom 200 %, axe-core y lector de pantalla pendientes antes de CP-UX.
