import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

const root = resolve(import.meta.dirname, '../../..');
const read = (path) => readFileSync(resolve(root, path), 'utf8');

const files = {
  openapi: read('docs/api/openapi.yaml'),
  readme: read('docs/api/README.md'),
  common: read('packages/contracts/src/common.ts'),
  profile: read('packages/contracts/src/profile.ts'),
  work: read('packages/contracts/src/work.ts'),
  approval: read('packages/contracts/src/approval.ts'),
  events: read('packages/contracts/src/events.ts'),
  ports: read('packages/contracts/src/ports.ts'),
  index: read('packages/contracts/src/index.ts'),
  catalog: read('docs/architecture/EVENT_CATALOG.md'),
  boundaries: read('docs/architecture/MODULE_BOUNDARIES.md'),
};

const failures = [];
const check = (condition, description) => {
  if (!condition) failures.push(description);
};
const includesAll = (text, values) => values.every((value) => text.includes(value));

check(/^openapi: 3\.1\.0$/m.test(files.openapi), 'OpenAPI debe declarar 3.1.0');
check(/^paths:$/m.test(files.openapi), 'OpenAPI debe declarar paths');
check(/^components:$/m.test(files.openapi), 'OpenAPI debe declarar components');
check(!/\t/.test(files.openapi), 'OpenAPI YAML no debe contener tabulaciones');

const refs = [
  ...files.openapi.matchAll(
    /\$ref:\s*['"]?#\/components\/(schemas|parameters|responses|securitySchemes)\/([A-Za-z0-9_-]+)/g,
  ),
];
for (const [, section, name] of refs) {
  const marker = section === 'securitySchemes' ? `  ${section}:` : `  ${section}:`;
  const start = files.openapi.indexOf(marker);
  check(start >= 0, `Falta sección components/${section}`);
  check(
    start >= 0 && files.openapi.slice(start).includes(`    ${name}:`),
    `Referencia OpenAPI no resuelta: ${section}/${name}`,
  );
}

const workTypes = ['delimitacion', 'curvas_nivel', 'avaluo', 'croquis', 'plano_catastro'];
check(includesAll(files.openapi, workTypes), 'OpenAPI no contiene todos los tipos de Trabajo');
check(includesAll(files.work, workTypes), 'Zod no contiene todos los tipos de Trabajo');

const pairedSchemas = [
  ['WorkContext', 'WorkContextSchema'],
  ['ResourceScope', 'ResourceScopeSchema'],
  ['WorkSummary', 'WorkSummarySchema'],
  ['ExternalProcedureSnapshot', 'ExternalProcedureSnapshotSchema'],
  ['DocumentReference', 'DocumentReferenceSchema'],
  ['ApprovalTarget', 'ApprovalTargetSchema'],
  ['ApprovalRequest', 'ApprovalRequestSchema'],
  ['AppearanceProfile', 'AppearanceProfileSchema'],
  ['UpdateOwnAppearanceCommandBody', 'UpdateOwnAppearanceCommandSchema'],
  ['UpdateOwnMobileNavigationCommandBody', 'UpdateOwnMobileNavigationCommandSchema'],
  ['ApiError', 'ApiErrorSchema'],
];
for (const [openApiName, zodName] of pairedSchemas) {
  check(files.openapi.includes(`    ${openApiName}:`), `Falta esquema OpenAPI ${openApiName}`);
  check(
    Object.values(files).some((text) => text.includes(`const ${zodName}`)),
    `Falta esquema Zod ${zodName}`,
  );
}

for (const path of [
  ...files.openapi.matchAll(/^  \/projects\/\{projectId\}\/works\/\{workId\}[^:]*:/gm),
]) {
  check(
    path[0].includes('{projectId}') && path[0].includes('{workId}'),
    `Path sin contexto completo: ${path[0]}`,
  );
}
check(
  !/^  \/projects\/(?!\{projectId\}(?:\/|:))/m.test(files.openapi),
  'Existe path operativo sin Proyecto',
);
check(
  files.openapi.includes('/projects/{projectId}/approval-requests:'),
  'Falta aprobación con alcance directo de Proyecto',
);
check(
  files.openapi.includes('/projects/{projectId}/works/{workId}/approval-requests:'),
  'Falta aprobación con alcance de Trabajo',
);

const eventNames = [
  'apt.status_changed.v1',
  'siri.procedure_changed.v1',
  'onedrive.item_changed.v1',
  'task.overdue.v1',
  'approval.requested.v1',
  'approval.resolved.v1',
  'notification.requested.v1',
  'project.archived.v1',
  'work.type_changed.v1',
];
for (const eventName of eventNames) {
  check(files.events.includes(eventName), `Falta evento Zod ${eventName}`);
  check(files.catalog.includes(eventName), `Falta evento documentado ${eventName}`);
}

const domainForbidden = /from\s+['"](?:react|@supabase|@microsoft|openai|.*(?:apt|siri))/i;
check(
  !domainForbidden.test(files.common + files.work + files.approval + files.events),
  'Contrato de dominio importa un proveedor prohibido',
);
check(
  /interface ExternalProcedureReadPort/.test(files.ports),
  'Falta puerto APT/SIRI de solo lectura',
);
check(
  !/interface ExternalProcedure(?:Write|Submit|Upload)Port/.test(files.ports),
  'Existe puerto de escritura APT/SIRI',
);
check(/interface AiProposalPort/.test(files.ports), 'Falta puerto de propuesta IA');
check(
  /appendEvent\(event: DomainEvent\)/.test(files.ports),
  'La transacción no representa escritura de outbox',
);
check(
  /appendAudit\(record: AuditAppendRecord\)/.test(files.ports),
  'La transacción no representa auditoría append-only',
);

const sensitivePatterns = [
  /service_role\s*[:=]\s*['"][^'"]+/i,
  /(?:password|secret|token|cookie|private[_-]?key)\s*[:=]\s*['"][^'"]+/i,
  /-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----/,
];
const all = Object.values(files).join('\n');
for (const pattern of sensitivePatterns) {
  check(!pattern.test(all), `Patrón de secreto detectado: ${pattern}`);
}
check(!/RedireccionarCargarPlano/i.test(all), 'Superficie de carga APT detectada');
check(
  !/(?:Buffer|Uint8Array|ArrayBuffer|base64|binaryContent)/.test(files.work),
  'El contrato documental expone binarios',
);

if (failures.length > 0) {
  console.error(`F2 contract verification failed (${failures.length})`);
  for (const failure of failures) console.error(`- ${failure}`);
  process.exit(1);
}

console.log(
  `F2 contract verification passed (${refs.length} OpenAPI refs, ${eventNames.length} events)`,
);
