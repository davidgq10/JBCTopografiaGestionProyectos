# F03 — comprobaciones de máquina

Fecha: **2026-07-24 UTC / 2026-07-23 America/Costa_Rica**  
Resultado: **PASS con una advertencia de tamaño no bloqueante**.

| Comprobación                      | Resultado                                                      |
| --------------------------------- | -------------------------------------------------------------- |
| `pnpm format:check`               | PASS                                                           |
| `pnpm lint`                       | PASS, 0 advertencias                                           |
| `pnpm typecheck`                  | PASS, TypeScript estricto                                      |
| `pnpm verify:architecture`        | PASS; 46 archivos, 92 imports internos, 0 ciclos               |
| `pnpm verify:secrets`             | PASS; incluye `.env`, SQL/PSQL y nombres sensibles `VITE_`     |
| `pnpm verify:sql`                 | PASS, 57 tablas y 0 vistas/funciones públicas no inventariadas |
| `pnpm test:coverage`              | PASS; dominio 97.22 %, aplicación 100 %                        |
| `pnpm build`                      | PASS; PWA y service worker generados                           |
| `pnpm build:storybook`            | PASS                                                           |
| `pnpm test:e2e`                   | PASS; 12/12 en 1440/1024/768/360                               |
| `pnpm --filter @jbc/web test:pwa` | PASS; 1/1 recarga fría offline del build                       |

El build advirtió que el chunk principal ronda 799 kB sin comprimir. No hay presupuesto de rendimiento de Fase 3 incumplido; se registra para partición por rutas antes del crecimiento funcional.

La revisión de secretos valida que el cliente solo consuma valores públicos `VITE_`; `.env.example` documenta secretos de servidor únicamente sin valores reales. El mismo control pasó en el proveedor alojado según `F03-GITHUB-CI-2026-07-24.md`.

La auditoría remota de vulnerabilidades npm no se ejecutó porque requiere autorización explícita para enviar el inventario de dependencias al registro externo. Debe formar parte del proveedor CI aprobado o de una ejecución autorizada; no se declara PASS.
