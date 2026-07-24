(function () {
  "use strict";

  var main = document.getElementById("app-main");
  var statePicker = document.getElementById("view-state");
  var moreButton = document.getElementById("more-button");
  var moreSheet = document.getElementById("more-sheet");
  var sheetBackdrop = document.getElementById("sheet-backdrop");
  var closeSheetButton = document.getElementById("close-sheet");
  var profileButton = document.getElementById("profile-button");
  var profilePopover = document.getElementById("profile-popover");
  var toastRegion = document.getElementById("toast-region");
  var searchForm = document.getElementById("global-search");
  var searchInput = document.getElementById("search-input");
  var banner = document.getElementById("context-banner");
  var bannerCopy = document.getElementById("context-banner-copy");
  var dismissBanner = document.getElementById("dismiss-banner");
  var themeColorMeta = document.getElementById("theme-color");
  var colorSchemeQuery = window.matchMedia("(prefers-color-scheme: dark)");
  var assistantLauncher = document.getElementById("assistant-launcher");
  var assistantPanel = document.getElementById("ai-assistant");
  var assistantClose = document.getElementById("assistant-close");
  var assistantContext = document.getElementById("assistant-context");
  var assistantMessages = document.getElementById("assistant-messages");
  var assistantCommandMenu = document.getElementById("assistant-command-menu");
  var assistantForm = document.getElementById("assistant-form");
  var assistantInput = document.getElementById("assistant-input");
  var sidebarToggle = document.getElementById("sidebar-toggle");

  var currentState = "normal";
  var wizardStep = 1;
  var sidebarCompact = false;
  var themePreference = document.documentElement.dataset.themePreference || "system";
  var accentChoice = "#0f766e";
  var accentTextColors = {
    "#0f766e": { light: "#0b5f59", dark: "#5eead4" },
    "#1d4ed8": { light: "#1d4ed8", dark: "#93c5fd" },
    "#4338ca": { light: "#4338ca", dark: "#a5b4fc" },
    "#6d28d9": { light: "#6d28d9", dark: "#c4b5fd" },
    "#a21caf": { light: "#a21caf", dark: "#f0abfc" },
    "#9a3412": { light: "#9a3412", dark: "#fdba74" }
  };
  var routeNames = {
    inicio: "Inicio",
    proyectos: "Proyectos",
    crear: "Crear proyecto",
    proyecto: "Detalle de proyecto",
    trabajo: "Gestiones y tareas",
    agenda: "Agenda",
    archivos: "OneDrive",
    aprobaciones: "Aprobaciones",
    notificaciones: "Notificaciones",
    reportes: "Reportes",
    administracion: "Configuración",
    estados: "Estados de interfaz",
    buscar: "Búsqueda"
  };

  var projects = [
    {
      code: "JBC-2026-0042",
      name: "Regularización técnica · Lote San Rafael",
      client: "Inversiones Monte Verde S.A.",
      coordinator: "Carlos Vega"
    },
    {
      code: "JBC-2026-0018",
      name: "Servicios topográficos · Finca La Esperanza",
      client: "María Elena Rojas",
      coordinator: "Ana Solano"
    },
    {
      code: "JBC-2026-0009",
      name: "Estudio de terreno · Condominio Roble",
      client: "Desarrollos del Este Ltda.",
      coordinator: "Diego León"
    },
    {
      code: "JBC-2026-0011",
      name: "Servicios técnicos · Propiedad Escazú",
      client: "Fideicomiso Central",
      coordinator: "Laura Mora"
    }
  ];

  var worksByProject = {
    "JBC-2026-0042": [
      { id: "TR-0042-01", name: "Plano A · Finca 1-245678-000", type: "Plano de catastro", area: "250 m²", status: "Revisión interna", tone: "warning", owner: "Carlos Vega", due: "28 jul", apt: "Requiere atención", aptTone: "apt", contract: "2026-01842" },
      { id: "TR-0042-02", name: "Plano B · Parcela segregada", type: "Plano de catastro", area: "300 m²", status: "En elaboración", tone: "info", owner: "Ana Solano", due: "30 jul", apt: "En trámite", aptTone: "info", contract: "2026-01843" },
      { id: "TR-0042-03", name: "Plano C · Resto reservado", type: "Plano de catastro", area: "320 m²", status: "Pendiente de campo", tone: "danger", owner: "Diego León", due: "04 ago", apt: "Sin consultar", aptTone: "siri", contract: "2026-01844" }
    ],
    "JBC-2026-0018": [
      {
        id: "TR-0018-01",
        name: "Delimitación · Sector norte",
        type: "Delimitación",
        area: "1.120 m²",
        status: "En ejecución",
        tone: "info",
        owner: "Ana Solano",
        due: "30 jul",
        externalHistory: {
          previousType: "Plano de catastro",
          previousStatus: "Corrección interna",
          lastAptStatus: "En trámite",
          changedBy: "Laura Mora",
          changedAtUtc: "2026-07-21T16:42:18Z",
          approval: "AP-2026-0031"
        }
      },
      { id: "TR-0018-02", name: "Croquis · Sector sur", type: "Croquis", area: "860 m²", status: "Planificado", tone: "", owner: "Carlos Vega", due: "02 ago" }
    ],
    "JBC-2026-0009": [
      { id: "TR-0009-01", name: "Curvas · Zona residencial", type: "Curvas de nivel", area: "4,2 ha", status: "Planificado", tone: "", owner: "Diego León", due: "04 ago" },
      { id: "TR-0009-02", name: "Curvas · Zona común", type: "Curvas de nivel", area: "1,7 ha", status: "En espera", tone: "warning", owner: "Diego León", due: "07 ago" }
    ],
    "JBC-2026-0011": [
      { id: "TR-0011-01", name: "Avalúo · Propiedad Escazú", type: "Avalúo", area: "742 m²", status: "Pendiente de información", tone: "danger", owner: "Laura Mora", due: "25 jul" }
    ]
  };

  var workRelations = {
    "TR-0042-01": { gestiones: 3, tareas: 5, agenda: 3, archivos: 14, aprobaciones: 2, actividad: 8, reportes: 3, historial: 24 },
    "TR-0042-02": { gestiones: 2, tareas: 4, agenda: 2, archivos: 9, aprobaciones: 1, actividad: 6, reportes: 2, historial: 17 },
    "TR-0042-03": { gestiones: 2, tareas: 3, agenda: 1, archivos: 7, aprobaciones: 0, actividad: 4, reportes: 1, historial: 12 },
    "TR-0018-01": { gestiones: 4, tareas: 6, agenda: 2, archivos: 11, aprobaciones: 1, actividad: 9, reportes: 2, historial: 21 },
    "TR-0018-02": { gestiones: 1, tareas: 2, agenda: 1, archivos: 4, aprobaciones: 0, actividad: 3, reportes: 1, historial: 8 },
    "TR-0009-01": { gestiones: 2, tareas: 4, agenda: 3, archivos: 12, aprobaciones: 1, actividad: 6, reportes: 2, historial: 15 },
    "TR-0009-02": { gestiones: 2, tareas: 3, agenda: 1, archivos: 6, aprobaciones: 0, actividad: 5, reportes: 1, historial: 11 },
    "TR-0011-01": { gestiones: 3, tareas: 4, agenda: 2, archivos: 8, aprobaciones: 1, actividad: 7, reportes: 2, historial: 16 }
  };

  function getProjectWorks(project) {
    return worksByProject[project.code] || [];
  }

  function getProjectWork(project, id) {
    var works = getProjectWorks(project);
    return (
      works.find(function (work) {
        return work.id === id;
      }) || works[0]
    );
  }

  function isCatastroWork(work) {
    return work && work.type === "Plano de catastro";
  }

  function hasExternalHistory(work) {
    return Boolean(work && work.externalHistory);
  }

  function getWorkRelations(work) {
    return (
      workRelations[work.id] || {
        gestiones: 0,
        tareas: 0,
        agenda: 0,
        archivos: 0,
        aprobaciones: 0,
        actividad: 0,
        reportes: 0,
        historial: 0
      }
    );
  }

  function workRecordId(work, prefix, suffix) {
    return prefix + "-" + work.id + (suffix ? "-" + suffix : "");
  }

  function summarizeWorkValues(works, key) {
    var counts = works.reduce(function (summary, work) {
      var value = work[key];
      summary[value] = (summary[value] || 0) + 1;
      return summary;
    }, {});
    return Object.keys(counts)
      .map(function (value) {
        return value + (counts[value] > 1 ? " × " + counts[value] : "");
      })
      .join(" · ");
  }

  function escapeHtml(value) {
    return String(value || "")
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#039;");
  }

  function parseRoute() {
    var raw = window.location.hash.replace(/^#/, "") || "inicio";
    var parts = raw.split("?");
    return {
      name: routeNames[parts[0]] ? parts[0] : "inicio",
      params: new URLSearchParams(parts[1] || "")
    };
  }

  function badge(label, tone) {
    return '<span class="status-badge ' + (tone || "") + '">' + escapeHtml(label) + "</span>";
  }

  function pageHeader(eyebrow, title, summary, actions) {
    return [
      '<header class="page-header">',
      '<div class="page-header-copy">',
      eyebrow ? '<p class="eyebrow">' + escapeHtml(eyebrow) + "</p>" : "",
      "<h1>" + escapeHtml(title) + "</h1>",
      summary ? '<p class="page-summary">' + summary + "</p>" : "",
      "</div>",
      actions ? '<div class="header-actions">' + actions + "</div>" : "",
      "</header>"
    ].join("");
  }

  function sectionHeader(title, copy, link) {
    return [
      '<div class="section-header"><div><h2>',
      escapeHtml(title),
      "</h2>",
      copy ? "<p>" + copy + "</p>" : "",
      "</div>",
      link || "",
      "</div>"
    ].join("");
  }

  function stateBlock(kind) {
    var states = {
      loading: {
        symbol: "…",
        title: "Cargando información",
        copy: "Conservamos la estructura para que el contenido no cambie de lugar.",
        extra:
          '<div class="skeleton title"></div><div class="skeleton line"></div><div class="skeleton line short"></div>'
      },
      empty: {
        symbol: "○",
        title: "Todavía no hay elementos",
        copy: "Cuando exista información autorizada aparecerá aquí.",
        extra: '<button class="button primary" type="button" data-toast="Acción principal simulada">Crear primero</button>'
      },
      error: {
        symbol: "!",
        title: "No pudimos cargar esta vista",
        copy: "El resto de la plataforma continúa disponible. Puede intentar nuevamente.",
        extra: '<button class="button secondary" type="button" data-state-reset>Intentar de nuevo</button>'
      },
      permissions: {
        symbol: "⌁",
        title: "No tiene permiso para ver esta información",
        copy: "La autorización se verifica en el servidor. Si considera que necesita acceso, solicítelo a coordinación.",
        extra: '<a class="button secondary" href="#inicio">Volver al inicio</a>'
      },
      degraded: {
        symbol: "↯",
        title: "Integración temporalmente no disponible",
        copy: "Mostramos la última consulta exitosa. Proyectos, tareas y agenda continúan operando.",
        extra: '<button class="button secondary" type="button" data-state-reset>Usar datos disponibles</button>'
      },
      stale: {
        symbol: "◷",
        title: "Estos datos pueden estar desactualizados",
        copy: "Última consulta exitosa: 22 jul 2026, 19:04. Verifique la fecha de corte antes de decidir.",
        extra: '<button class="button secondary" type="button" data-toast="Consulta manual simulada">Consultar ahora</button>'
      },
      offline: {
        symbol: "⌁",
        title: "Está sin conexión",
        copy: "Puede recorrer la estructura, pero las modificaciones están deshabilitadas y no se muestran datos sensibles almacenados.",
        extra: '<a class="button secondary" href="#inicio">Ver estructura</a>'
      },
      success: {
        symbol: "✓",
        title: "Cambio registrado",
        copy: "La operación ficticia se confirmó y su evidencia quedó vinculada.",
        extra: '<button class="button primary" type="button" data-state-reset>Continuar</button>'
      },
      conflict: {
        symbol: "⇄",
        title: "Otra persona modificó este elemento",
        copy: "Compare su versión con la más reciente. Nunca sobrescribimos cambios de forma silenciosa.",
        extra:
          '<div class="inline-actions"><button class="button secondary" type="button" data-toast="Comparativo abierto">Comparar versiones</button><button class="button primary" type="button" data-state-reset>Recargar</button></div>'
      }
    };
    var item = states[kind] || states.error;
    return [
      '<section class="state-block ',
      kind,
      '" aria-labelledby="state-title">',
      '<span class="state-symbol" aria-hidden="true">',
      item.symbol,
      "</span><h2 id=\"state-title\">",
      item.title,
      "</h2><p>",
      item.copy,
      "</p>",
      item.extra,
      "</section>"
    ].join("");
  }

  function maybeState(route) {
    if (currentState === "normal" || route === "estados") {
      return "";
    }
    return [
      '<div class="page-shell">',
      pageHeader("Estado de interfaz", routeNames[route], "Este selector demuestra el comportamiento común de cualquier vista.", ""),
      stateBlock(currentState),
      "</div>"
    ].join("");
  }

  function projectTable(items) {
    return [
      '<div class="data-table-wrap"><table class="data-table">',
      "<thead><tr><th style=\"width:30%\">Contratación</th><th>Trabajos</th><th>Estados de trabajo</th><th>Coordinación</th><th>Próximo hito de Trabajo</th></tr></thead>",
      "<tbody>",
      items
        .map(function (item) {
          var works = getProjectWorks(item);
          var nextWork = works[0];
          return [
            "<tr>",
            '<td data-label="Contratación"><a href="',
            projectRoute(item, nextWork, "resumen"),
            '"><span class="cell-title">',
            escapeHtml(item.name),
            '</span><span class="cell-subtitle">',
            escapeHtml(item.code + " · " + item.client),
            "</span></a></td>",
            '<td data-label="Trabajos"><span class="cell-title">',
            works.length,
            works.length === 1 ? " trabajo" : " trabajos",
            '</span><span class="cell-subtitle">',
            escapeHtml(summarizeWorkValues(works, "type")),
            "</span></td>",
            '<td data-label="Estados de trabajo"><span class="cell-subtitle">',
            escapeHtml(summarizeWorkValues(works, "status")),
            "</span></td>",
            '<td data-label="Coordinación">',
            escapeHtml(item.coordinator),
            "</td>",
            '<td data-label="Próximo hito de Trabajo"><a class="object-link" href="',
            projectRoute(item, nextWork, "agenda"),
            '"><span class="code">',
            escapeHtml(nextWork.id),
            "</span> · ",
            escapeHtml(nextWork.due),
            "</a>",
            "</td>",
            "</tr>"
          ].join("");
        })
        .join(""),
      "</tbody></table></div>"
    ].join("");
  }

  function renderInicio() {
    return [
      '<div class="page-shell">',
      pageHeader(
        "Jueves, 23 de julio",
        "Buenos días, Laura",
        "Estas son las decisiones y compromisos que requieren atención hoy.",
        '<a class="button primary" href="#crear">Crear proyecto</a>'
      ),
      '<section class="metric-strip" aria-label="Resumen del día">',
      '<div class="metric"><strong>7</strong><span>acciones para hoy</span></div>',
      '<div class="metric"><strong>4</strong><span>aprobaciones pendientes</span></div>',
      '<div class="metric"><strong>2</strong><span>cambios APT/SIRI</span></div>',
      '<div class="metric"><strong>1</strong><span>conflicto de agenda</span></div>',
      "</section>",
      '<div class="split-layout section">',
      "<section>",
      sectionHeader("Atención requerida", "Ordenado por impacto y vencimiento", '<a class="section-link" href="#trabajo">Ver trabajo</a>'),
      '<div class="section-surface"><ul class="list">',
      '<li class="list-row"><span class="leading-marker high"></span><div class="list-row-main"><a class="object-link" href="#proyecto?id=JBC-2026-0042&amp;work=TR-0042-01&amp;tab=tareas&amp;record=TASK-TR-0042-01-01"><strong>Corregir minuta APT</strong></a><span>JBC-2026-0042 / TR-0042-01 · vence hoy a las 16:00</span></div><span class="priority critical">Crítica</span></li>',
      '<li class="list-row"><span class="leading-marker attention"></span><div class="list-row-main"><a class="object-link" href="#proyecto?id=JBC-2026-0042&amp;work=TR-0042-02&amp;tab=aprobaciones&amp;record=APPROVAL-TR-0042-02-OWNER"><strong>Resolver cambio de responsable</strong></a><span>JBC-2026-0042 / TR-0042-02 · solicitó Carlos Vega</span></div><span class="row-meta">hace 42 min</span></li>',
      '<li class="list-row"><span class="leading-marker info"></span><div class="list-row-main"><a class="object-link" href="#proyecto?id=JBC-2026-0018&amp;work=TR-0018-01&amp;tab=gestiones&amp;record=MANAGEMENT-TR-0018-01-CLIENTE"><strong>Confirmar acceso a finca</strong></a><span>JBC-2026-0018 / TR-0018-01 · seguimiento del cliente</span></div><span class="row-meta">11:30</span></li>',
      "</ul></div>",
      "</section>",
      "<section>",
      sectionHeader("Agenda de hoy", "Hora de Costa Rica", '<a class="section-link" href="#agenda">Abrir agenda</a>'),
      '<div class="section-surface"><div class="agenda-day"><span class="agenda-time">08:00</span><div class="agenda-event field"><a class="object-link" href="#proyecto?id=JBC-2026-0042&amp;work=TR-0042-01&amp;tab=agenda&amp;record=AGENDA-TR-0042-01-0800"><strong>Levantamiento en San Rafael</strong></a><p>JBC-2026-0042 / TR-0042-01 · Carlos + GNSS 02 · Campo</p></div></div>',
      '<div class="agenda-day"><span class="agenda-time">13:30</span><div class="agenda-event"><a class="object-link" href="#proyecto?id=JBC-2026-0042&amp;work=TR-0042-02&amp;tab=agenda&amp;record=AGENDA-TR-0042-02-1330"><strong>Revisión técnica</strong></a><p>JBC-2026-0042 / TR-0042-02 · Oficina</p></div></div>',
      '<div class="agenda-day"><span class="agenda-time">15:00</span><div class="agenda-event conflict"><strong>Conflicto de vehículo</strong><p>Vehículo 01 aparece en dos bloques</p></div></div></div>',
      "</section>",
      "</div>",
      '<section class="section">',
      sectionHeader("Proyectos en curso", "Vista normalizada del control general", '<a class="section-link" href="#proyectos">Ver todos</a>'),
      projectTable(projects.slice(0, 3)),
      "</section>",
      '<section class="section">',
      sectionHeader("Salud de integraciones", "La falla de un servicio no bloquea el trabajo interno", ""),
      '<div class="three-column">',
      '<div class="subtle-surface"><h3>OneDrive</h3><p class="muted">Sincronizado hace 3 min</p>',
      badge("Disponible", "success"),
      "</div>",
      '<div class="subtle-surface"><h3>APT / SIRI</h3><p class="muted">Último ciclo 07:06</p>',
      badge("2 cambios", "warning"),
      "</div>",
      '<div class="subtle-surface"><h3>Notificaciones</h3><p class="muted">Entrega 07:00–20:00</p>',
      badge("Activas", "success"),
      "</div>",
      "</div></section></div>"
    ].join("");
  }

  function renderProyectos() {
    return [
      '<div class="page-shell">',
      pageHeader(
        "Control general",
        "Proyectos",
        "Cada proyecto es una contratación; los tipos, estados y responsables pertenecen a sus Trabajos.",
        '<a class="button primary" href="#crear">Crear proyecto manualmente</a>'
      ),
      '<div class="filter-bar">',
      '<div class="filter-control"><label for="project-filter">Buscar</label><input id="project-filter" type="search" placeholder="Código, cliente o finca" /></div>',
      '<div class="filter-control"><label for="type-filter">Tipo de trabajo</label><select id="type-filter"><option>Cualquier tipo</option><option>Plano de catastro</option><option>Delimitación</option><option>Curvas de nivel</option><option>Avalúo</option><option>Croquis</option></select></div>',
      '<div class="filter-control"><label for="status-filter">Estado de trabajo</label><select id="status-filter"><option>Activos</option><option>En espera</option><option>Cerrados</option><option>Archivados</option></select></div>',
      "</div>",
      projectTable(projects),
      '<p class="muted section">Mostrando 4 de 184 proyectos ficticios · Paginación del servidor en la aplicación final.</p>',
      "</div>"
    ].join("");
  }

  function wizardSteps() {
    var labels = ["Cliente", "Contratación", "Trabajos", "Equipo", "Confirmar"];
    return [
      '<ol class="wizard-steps" aria-label="Pasos para crear proyecto">',
      labels
        .map(function (label, index) {
          var number = index + 1;
          var className = number === wizardStep ? "is-current" : number < wizardStep ? "is-complete" : "";
          var current = number === wizardStep ? ' aria-current="step"' : "";
          return '<li class="' + className + '"' + current + '><strong>' + number + '</strong><span>' + label + "</span></li>";
        })
        .join(""),
      "</ol>"
    ].join("");
  }

  function wizardContent() {
    if (wizardStep === 1) {
      return [
        '<div class="field"><label for="client">Cliente existente</label><input id="client" value="Inversiones Monte Verde S.A." /><small>La identificación se comprobará para evitar duplicados.</small></div>',
        '<div class="inline-actions section"><button class="button ghost" type="button" data-toast="Flujo de cliente nuevo simulado">Crear cliente nuevo</button></div>'
      ].join("");
    }
    if (wizardStep === 2) {
      return [
        '<div class="form-grid"><div class="field full"><label for="contract-name">Nombre de la contratación</label><input id="contract-name" value="Regularización técnica · Lote San Rafael" /><small>Describe el servicio contratado; no define el tipo ni el estado de los Trabajos.</small></div>',
        '<div class="field"><label for="contract-reference">Referencia del cliente</label><input id="contract-reference" value="OC-2026-118" /></div>',
        '<div class="field"><label for="contract-coordinator">Coordinación</label><select id="contract-coordinator"><option>Carlos Vega</option><option>Ana Solano</option></select></div>',
        '<div class="field full"><label for="contract-scope">Alcance contratado</label><textarea id="contract-scope">Preparar dos productos técnicos gestionados y entregados por separado.</textarea></div></div>'
      ].join("");
    }
    if (wizardStep === 3) {
      return [
        '<div class="work-builder"><article class="section-surface"><header><div><span class="eyebrow">Trabajo 01 · obligatorio</span><h2>Plano A · finca principal</h2></div>' +
          badge("Borrador", "") +
          '</header><div class="form-grid section"><div class="field"><label for="work-1-type">Tipo del trabajo</label><select id="work-1-type"><option selected>Plano de catastro</option><option>Delimitación</option><option>Curvas de nivel</option><option>Avalúo</option><option>Croquis</option></select><small>APT/SIRI solo se habilita para este Trabajo por su tipo.</small></div><div class="field"><label for="work-1-status">Estado inicial del Trabajo</label><select id="work-1-status"><option selected>Borrador</option><option>Pendiente de información</option><option>Planificado</option></select></div><div class="field"><label for="work-1-property">Finca / matrícula</label><input id="work-1-property" value="1-245678-000" /></div><div class="field full"><label for="work-1-name">Nombre del trabajo</label><input id="work-1-name" value="Plano A · Finca 1-245678-000" /></div></div></article>',
        '<article class="section-surface"><header><div><span class="eyebrow">Trabajo 02</span><h2>Croquis de acceso</h2></div><button class="button ghost" type="button" data-toast="Trabajo retirado del borrador">Quitar</button></header><div class="form-grid section"><div class="field"><label for="work-2-type">Tipo del trabajo</label><select id="work-2-type"><option>Plano de catastro</option><option>Delimitación</option><option>Curvas de nivel</option><option>Avalúo</option><option selected>Croquis</option></select><small>Este Trabajo no muestra ni monitorea APT/SIRI.</small></div><div class="field"><label for="work-2-status">Estado inicial del Trabajo</label><select id="work-2-status"><option>Borrador</option><option selected>Planificado</option><option>Pendiente de información</option></select></div><div class="field"><label for="work-2-property">Inmueble relacionado</label><input id="work-2-property" value="Acceso a finca principal" /></div><div class="field full"><label for="work-2-name">Nombre del trabajo</label><input id="work-2-name" value="Croquis · Acceso municipal" /></div></div></article></div>',
        '<button class="button ghost section" type="button" data-toast="Nuevo trabajo añadido al borrador">Añadir otro trabajo</button>'
      ].join("");
    }
    if (wizardStep === 4) {
      return [
        '<div class="field"><label for="owner">Coordinador de la contratación</label><select id="owner"><option>Carlos Vega · Topografía</option><option>Ana Solano · Catastro</option></select><small>Coordina el contrato; no reemplaza al responsable operativo de cada Trabajo.</small></div>',
        '<div class="work-builder section"><article class="section-surface"><header><div><span class="eyebrow">Trabajo 01</span><h2>Plano A · finca principal</h2></div>' +
          badge("Plano de catastro", "info") +
          '</header><div class="form-grid section"><div class="field"><label for="work-1-owner">Responsable</label><select id="work-1-owner"><option selected>Ana Solano · Catastro</option><option>Carlos Vega · Topografía</option></select></div><div class="field"><label for="work-1-priority">Prioridad</label><select id="work-1-priority"><option>Normal</option><option selected>Alta</option><option>Urgente</option><option>Crítica</option></select></div><div class="field"><label for="work-1-start">Inicio estimado</label><input id="work-1-start" type="date" value="2026-07-27" /></div><div class="field"><label for="work-1-finish">Entrega estimada</label><input id="work-1-finish" type="date" value="2026-08-21" /></div></div></article>',
        '<article class="section-surface"><header><div><span class="eyebrow">Trabajo 02</span><h2>Croquis de acceso</h2></div>' +
          badge("Croquis", "") +
          '</header><div class="form-grid section"><div class="field"><label for="work-2-owner">Responsable</label><select id="work-2-owner"><option>Ana Solano · Catastro</option><option selected>Carlos Vega · Topografía</option></select></div><div class="field"><label for="work-2-priority">Prioridad</label><select id="work-2-priority"><option selected>Normal</option><option>Alta</option><option>Urgente</option><option>Crítica</option></select></div><div class="field"><label for="work-2-start">Inicio estimado</label><input id="work-2-start" type="date" value="2026-07-29" /></div><div class="field"><label for="work-2-finish">Entrega estimada</label><input id="work-2-finish" type="date" value="2026-08-14" /></div></div></article></div>',
        '<div class="field section"><label for="participants">Participantes de la contratación</label><input id="participants" value="Laura Mora, Diego León" /></div>'
      ].join("");
    }
    return [
      '<div class="section-surface"><h2>Revise antes de crear</h2>',
      '<dl class="review-list section">',
      "<div><dt>Cliente</dt><dd>Inversiones Monte Verde S.A.</dd></div>",
      "<div><dt>Contratación</dt><dd>Regularización técnica · sin tipo ni estado operativo propios</dd></div>",
      "<div><dt>Trabajo 01</dt><dd>Plano A · Plano de catastro · Borrador · Ana Solano · entrega 21 ago</dd></div>",
      "<div><dt>Trabajo 02</dt><dd>Croquis de acceso · Croquis · Planificado · Carlos Vega · entrega 14 ago</dd></div>",
      "<div><dt>Coordinación</dt><dd>Carlos Vega</dd></div>",
      "<div><dt>APT / SIRI</dt><dd>Solo para Trabajo 01; consulta externa de solo lectura</dd></div>",
      "</dl></div>",
      '<p class="history-note section"><strong>Creación manual.</strong> Se crearán una Contratación y dos Trabajos independientes. No se importará desde Excel; los códigos se asignarán al confirmar.</p>'
    ].join("");
  }

  function renderCreate() {
    var back = wizardStep > 1 ? '<button class="button secondary" type="button" data-wizard="back">Anterior</button>' : '<a class="button secondary" href="#proyectos">Cancelar</a>';
    var next =
      wizardStep < 5
        ? '<button class="button primary" type="button" data-wizard="next">Continuar</button>'
        : '<button class="button primary" type="button" data-create-project>Confirmar y crear</button>';
    return [
      '<div class="page-shell is-form">',
      '<nav class="breadcrumbs" aria-label="Ruta"><a href="#proyectos">Proyectos</a><span aria-hidden="true">/</span><span>Crear manualmente</span></nav>',
      pageHeader("Asistente manual", "Crear proyecto", "Cree la Contratación y al menos un Trabajo; cada Trabajo conserva su propio tipo, estado y responsable.", ""),
      wizardSteps(),
      '<section aria-live="polite">',
      wizardContent(),
      "</section>",
      '<div class="form-actions">',
      back,
      next,
      "</div></div>"
    ].join("");
  }

  function getProject(id) {
    return (
      projects.find(function (project) {
        return project.code === id;
      }) || projects[0]
    );
  }

  function projectRoute(project, work, tab, record) {
    return (
      "#proyecto?id=" +
      encodeURIComponent(project.code) +
      "&work=" +
      encodeURIComponent(work.id) +
      "&tab=" +
      encodeURIComponent(tab || "resumen") +
      (record ? "&record=" + encodeURIComponent(record) : "")
    );
  }

  function projectWorkSwitcher(project, activeWork) {
    var works = getProjectWorks(project);
    return [
      '<section class="work-switcher" aria-labelledby="work-switcher-title"><header><div><span class="eyebrow">Contratación · ',
      escapeHtml(project.code),
      '</span><h2 id="work-switcher-title">Trabajos del proyecto</h2><p>',
      works.length,
      ' trabajo',
      works.length === 1 ? "" : "s",
      ' gestionado',
      works.length === 1 ? "" : "s",
      ' por separado; el proyecto conserva la vista agregada.</p></div><button class="button secondary" type="button" data-toast="Nuevo trabajo preparado">Añadir trabajo</button></header><div class="work-list">',
      works
        .map(function (work, index) {
          return (
            '<a class="work-card" href="' +
            projectRoute(project, work, "resumen") +
            '"' +
            (work.id === activeWork.id ? ' aria-current="true"' : "") +
            '><span class="work-index">' +
            String(index + 1).padStart(2, "0") +
            '</span><span class="work-card-copy"><strong>' +
            escapeHtml(work.name) +
            '</strong><small>' +
            escapeHtml(work.type) +
            " · " +
            escapeHtml(work.area) +
            " · " +
            escapeHtml(work.owner) +
            '</small></span><span class="work-card-status">' +
            badge(work.status, work.tone) +
            "</span></a>"
          );
        })
        .join(""),
      "</div></section>"
    ].join("");
  }

  function projectNavigation(project, tab, work) {
    var base =
      "#proyecto?id=" + encodeURIComponent(project.code) + "&work=" + encodeURIComponent(work.id) + "&tab=";
    var tabs = [
      ["resumen", "Resumen"],
      ["datos", "Datos"],
      ["gestiones", "Gestiones"],
      ["tareas", "Tareas"],
      ["agenda", "Agenda"],
      ["archivos", "Archivos"],
      ["aprobaciones", "Aprobaciones"],
      ["actividad", "Actividad"],
      ["ia", "IA"],
      ["reportes", "Reportes"],
      ["historial", "Historial"]
    ];
    if (isCatastroWork(work)) tabs.splice(5, 0, ["tramites", "Trámites"]);
    else if (hasExternalHistory(work)) tabs.splice(5, 0, ["tramites", "Historial externo"]);
    return [
      '<nav class="project-context-nav" aria-label="Secciones de la contratación y el trabajo activo">',
      '<p class="project-context-label"><span aria-hidden="true">◎</span>Trabajo activo · ',
      escapeHtml(project.code),
      " / ",
      escapeHtml(work.id),
      "</p>",
      '<div class="project-nav-links">',
      tabs
        .map(function (item) {
          return '<a href="' + base + item[0] + '"' + (tab === item[0] ? ' aria-current="page"' : "") + ">" + item[1] + "</a>";
        })
        .join(""),
      "</div>",
      '<div class="project-nav-select"><label for="project-section">Sección contextual del Trabajo</label><select id="project-section" data-project-nav-select data-project-id="',
      escapeHtml(project.code),
      '" data-project-work-id="',
      escapeHtml(work.id),
      '">',
      tabs
        .map(function (item) {
          return '<option value="' + item[0] + '"' + (tab === item[0] ? " selected" : "") + ">" + item[1] + "</option>";
        })
        .join(""),
      "</select></div></nav>"
    ].join("");
  }

  function projectSummary(project, work) {
    var isCatastro = isCatastroWork(work);
    var externalSummary = "";
    if (isCatastro) {
      externalSummary =
        '<aside><section>' +
        sectionHeader("Estado oficial externo", "Nunca sustituye el estado interno", "") +
        '<div class="integration-grid"><div class="integration-panel apt"><header><h3>APT</h3>' +
        badge(work.apt, work.aptTone) +
        '</header><dl><div><dt>Contrato</dt><dd>' +
        escapeHtml(work.contract) +
        '</dd></div><div><dt>Último cambio</dt><dd>22 jul, 19:04</dd></div><div><dt>Actualización</dt><dd>Al día</dd></div></dl></div><div class="integration-panel siri"><header><h3>SIRI</h3>' +
        badge("Sin consultar", "siri") +
        '</header><p class="muted">No existen apelaciones ni mantenimientos vinculados.</p></div></div></section></aside>';
    } else if (hasExternalHistory(work)) {
      externalSummary =
        '<aside><section>' +
        sectionHeader("Historial externo inactivo", "Solo existe porque este Trabajo cambió de tipo", "") +
        '<div class="history-note"><strong>Monitoreo cerrado</strong><p>Último APT: ' +
        escapeHtml(work.externalHistory.lastAptStatus) +
        " · inactivo desde " +
        escapeHtml(work.externalHistory.changedAtUtc) +
        '. Consulte el historial autorizado; el estado interno permanece independiente.</p></div></section></aside>';
    }
    return [
      '<section class="compact-ai-suggestion" aria-label="Propuesta de IA"><div><span class="status-badge ai">Propuesta de IA</span><span class="muted">Confianza 82 % · corte 07:06</span></div><p><strong>Riesgo:</strong> la revisión de ',
      escapeHtml(work.id),
      ' podría desplazar la entrega dos días.</p><div class="compact-ai-actions"><button class="button ghost" type="button" data-toast="Propuesta rechazada">Rechazar</button><button class="button secondary" type="button" data-toast="Solicitud de aprobación creada">Revisar propuesta</button></div></section>',
      '<div class="' + (externalSummary ? "split-layout" : "single-column") + '">',
      '<div><section>',
      sectionHeader("Situación interna", "Estado del trabajo activo, independiente de fuentes oficiales", ""),
      '<div class="section-surface"><dl class="review-list">',
      "<div><dt>Trabajo</dt><dd><span class=\"code\">" + escapeHtml(work.id) + "</span></dd></div>",
      "<div><dt>Estado interno</dt><dd>" + badge(work.status, work.tone) + "</dd></div>",
      "<div><dt>Responsable</dt><dd>" + escapeHtml(work.owner) + "</dd></div>",
      "<div><dt>Prioridad</dt><dd>Alta · justificada por entrega contractual</dd></div>",
      "<div><dt>Próximo hito</dt><dd>" + escapeHtml(work.due) + " · revisión técnica</dd></div>",
      "</dl></div></section>",
      '<section class="section">',
      sectionHeader("Próximos pasos", "Trabajo confirmado y propuestas pendientes", '<a class="section-link" href="' + projectRoute(project, work, "tareas") + '">Abrir tareas</a>'),
      '<div class="section-surface"><ul class="list">',
      '<li class="list-row"><span class="leading-marker high"></span><div class="list-row-main"><a class="object-link" href="' +
        projectRoute(project, work, "tareas", workRecordId(work, "TASK", "01")) +
        '"><strong>Corregir observaciones de revisión</strong></a><span>Responsable: ' +
        escapeHtml(work.owner) +
        ' · vence 24 jul</span></div>' +
        badge("En curso", "warning") +
        "</li>",
      '<li class="list-row"><span class="leading-marker info"></span><div class="list-row-main"><strong>Preparar paquete de entrega</strong><span>Bloqueada hasta terminar revisión</span></div>' +
        badge("Bloqueada", "") +
        "</li>",
      "</ul></div></section></div>",
      externalSummary,
      "</div>"
    ].join("");
  }

  function projectRecordDetail(tab, record, project, work) {
    if (!record) return "";
    var isCatastro = isCatastroWork(work);
    var labels = {
      resumen: ["Trabajo", work.name, "Estado, responsables y operación independiente dentro de la contratación."],
      trabajos: ["Trabajo", work.name, "Estado, responsables y operación independiente dentro de la contratación."],
      gestiones: ["Gestión", "Revisión técnica y calidad", "Seguimiento cronológico con tareas, agenda y resultado."],
      tareas: ["Tarea", isCatastro ? "Corregir minuta APT" : "Validar entregable técnico", "2 de 5 comprobaciones · vence 24 jul · responsable " + work.owner],
      agenda: ["Bloque de agenda", "23 jul · 08:00 · Levantamiento", "GNSS 02 · Vehículo 01 · " + work.id],
      tramites: isCatastro
        ? ["Trámite externo", "APT / SIRI de " + work.id, "Consulta oficial de solo lectura separada del estado interno."]
        : ["Historial externo", "Monitoreo anterior de " + work.id, "Registro inactivo conservado por un cambio de tipo aprobado."],
      archivos: ["Archivo OneDrive", "Croquis_rev03.pdf", "05-PRESENTACIONES · binario en OneDrive"],
      aprobaciones: ["Aprobación", "Archivar versión sustituida", "Pendiente de revisión humana"],
      reportes: ["Reporte", "Resumen ejecutivo", "PDF · fecha de corte hoy"],
      historial: ["Evento", "Trabajo creado manualmente", project.code + " / " + work.id + " · 18 jul · Laura Mora · solo adición"]
    };
    var item = labels[tab] || ["Detalle operativo", record, "Objeto relacionado con el trabajo activo."];
    var action =
      tab === "archivos"
        ? '<button class="button primary" type="button" data-toast="Archivo ficticio abierto en OneDrive">Abrir archivo en OneDrive</button>'
        : tab === "tramites"
          ? '<button class="button secondary" type="button" data-toast="Detalle oficial ficticio abierto en solo lectura">Abrir consulta de solo lectura</button>'
          : '<button class="button primary" type="button" data-toast="Edición operativa simulada">Editar ' + escapeHtml(item[0].toLowerCase()) + "</button>";
    return [
      '<section class="record-detail" aria-labelledby="record-detail-title"><header><div><span class="eyebrow">',
      escapeHtml(item[0]),
      ' · vista operativa</span><h2 id="record-detail-title">',
      escapeHtml(item[1]),
      '</h2><p>',
      escapeHtml(item[2]),
      '</p></div><a class="icon-link record-detail-close" aria-label="Cerrar detalle" title="Cerrar detalle" href="',
      projectRoute(project, work, tab),
      '"><span aria-hidden="true">×</span></a></header><dl><div><dt>Contratación</dt><dd>',
      escapeHtml(project.code),
      '</dd></div><div><dt>Trabajo</dt><dd>',
      escapeHtml(work.id),
      '</dd></div><div><dt>Referencia</dt><dd>',
      escapeHtml(record),
      '</dd></div></dl><div class="record-detail-actions">',
      action,
      '<button class="button secondary" type="button" data-scroll-chatter>Ver en Contexto vivo</button></div></section>'
    ].join("");
  }

  function projectData(project, work) {
    return [
      sectionHeader("Datos de la contratación y el Trabajo", "Los datos compartidos y los operativos conservan propietario explícito", '<button class="button secondary" type="button" data-toast="Edición contextual simulada">Editar datos</button>'),
      '<div class="two-column"><section class="section-surface"><h3>Contratación</h3><dl class="review-list section"><div><dt>Cliente</dt><dd>' +
        escapeHtml(project.client) +
        '</dd></div><div><dt>Contacto</dt><dd>Andrea Vargas · 8888-0142</dd></div><div><dt>Coordinación contractual</dt><dd>' +
        escapeHtml(project.coordinator) +
        '</dd></div></dl></section>',
      '<section class="section-surface"><h3>Trabajo activo</h3><dl class="review-list section"><div><dt>Identificador</dt><dd><span class="code">' +
        escapeHtml(work.id) +
        '</span></dd></div><div><dt>Tipo</dt><dd>' +
        escapeHtml(work.type) +
        '</dd></div><div><dt>Estado y responsable</dt><dd>' +
        escapeHtml(work.status + " · " + work.owner) +
        '</dd></div><div><dt>Área / alcance</dt><dd>' +
        escapeHtml(work.area) +
        "</dd></div></dl></section></div>",
      '<section class="section">',
      sectionHeader("Inmuebles y lotes", "Relaciones del Trabajo " + escapeHtml(work.id) + " dentro de la contratación", '<button class="button ghost" type="button" data-toast="Nuevo lote del Trabajo simulado">Vincular inmueble</button>'),
      '<div class="section-surface"><div class="admin-row"><div><strong>' +
        escapeHtml(work.name) +
        "</strong><p>" +
        escapeHtml(work.type + " · " + work.area + " · relación exclusiva del Trabajo activo") +
        "</p></div>" +
        badge("Principal", "info") +
        "</div></div></section>"
    ].join("");
  }

  function projectGestiones(project, work) {
    return [
      sectionHeader("Gestiones del trabajo", "Seguimiento independiente de " + escapeHtml(work.id) + ", espera motivada y resultado", '<button class="button primary" type="button" data-toast="Nueva gestión del trabajo simulada">Nueva gestión</button>'),
      '<div class="section-surface"><ul class="list">',
      '<li class="list-row"><span class="leading-marker info"></span><div class="list-row-main"><strong>Revisión técnica y calidad</strong><span>3 tareas · Ana Solano · vence 28 jul</span></div>' +
        badge("En ejecución", "info") +
        "</li>",
      '<li class="list-row"><span class="leading-marker attention"></span><div class="list-row-main"><strong>Información del cliente</strong><span>Motivo: autorización del cliente · seguimiento 25 jul</span></div>' +
        badge("En espera", "warning") +
        "</li>",
      '<li class="list-row"><span class="leading-marker"></span><div class="list-row-main"><strong>Preparación de entregables</strong><span>Resultado pendiente · responsable ' +
        escapeHtml(work.owner) +
        "</span></div>" +
        badge("Planificada", "") +
        "</li>",
      "</ul></div>"
    ].join("");
  }

  function projectTasks(project, work) {
    var primaryTask = isCatastroWork(work) ? "Corregir minuta APT" : "Validar entregable técnico";
    return [
      sectionHeader("Tareas del trabajo", "Listas, dependencias y vencimientos de " + escapeHtml(work.id), '<button class="button primary" type="button" data-toast="Nueva tarea del trabajo simulada">Crear tarea</button>'),
      '<div class="split-layout"><section class="section-surface"><ul class="list"><li class="list-row"><span class="leading-marker high"></span><div class="list-row-main"><strong>' +
        escapeHtml(primaryTask) +
        '</strong><span>2 de 5 comprobaciones · vence mañana</span></div><span class="priority critical">Crítica</span></li><li class="list-row"><span class="leading-marker info"></span><div class="list-row-main"><strong>Revisar cálculo de áreas</strong><span>Ana Solano · 80 %</span></div>' +
        badge("En curso", "info") +
        '</li><li class="list-row"><span class="leading-marker"></span><div class="list-row-main"><strong>Preparar paquete de entrega</strong><span>Bloqueada por revisión técnica</span></div>' +
        badge("Bloqueada", "") +
        "</li></ul></section>",
      '<aside class="subtle-surface"><h3>Dependencias</h3><p class="muted">La aplicación impedirá ciclos y mostrará la causa del bloqueo con texto e icono.</p><ul class="evidence-list"><li>Revisión técnica → paquete de entrega.</li><li>Autorización del cliente → visita de campo.</li></ul><p class="code">' +
        escapeHtml(project.code) +
        "</p></aside></div>"
    ].join("");
  }

  function projectAgenda(project, work) {
    return [
      sectionHeader("Agenda del trabajo", "Bloques de " + escapeHtml(work.id) + " sin perder la agenda general", '<a class="button secondary" href="#agenda">Abrir agenda general</a>'),
      '<div class="section-surface"><div class="agenda-day"><span class="agenda-time">23 jul<br />08:00</span><div class="agenda-event field"><strong>Levantamiento en San Rafael</strong><p>' +
        escapeHtml(project.code) +
        " / " +
        escapeHtml(work.id) +
        " · " +
        escapeHtml(work.owner) +
        ' · GNSS 02 · Vehículo 01</p></div></div><div class="agenda-day"><span class="agenda-time">23 jul<br />13:30</span><div class="agenda-event"><strong>Revisión técnica</strong><p>' +
        escapeHtml(project.code + " / " + work.id + " · " + work.owner) +
        ' · oficina</p></div></div><div class="agenda-day"><span class="agenda-time">25 jul<br />09:00</span><div class="agenda-event conflict"><strong>Reserva por confirmar</strong><p>Vehículo 01 tiene conflicto con otro Trabajo.</p><button class="button ghost" type="button" data-toast="Conflicto del Trabajo abierto">Resolver conflicto</button></div></div></div>'
    ].join("");
  }

  function projectApprovals(project, work) {
    return [
      sectionHeader("Aprobaciones del trabajo", "Decisión y ejecución separadas, filtradas por " + escapeHtml(work.id), '<a class="button secondary" href="#aprobaciones">Abrir centro general</a>'),
      '<div class="section-surface"><article class="approval-row"><div><strong>Mover versión sustituida a 99-ARCHIVADOS</strong><p>Documento técnico · versión objetivo v4</p></div><div><span class="muted">Solicitó</span><br />' +
        escapeHtml(project.coordinator) +
        "</div><div>" +
        badge("Pendiente", "warning") +
        '</div><div class="inline-actions"><button class="button secondary" type="button" data-toast="Comparativo del proyecto abierto">Revisar</button></div></article><article class="approval-row"><div><strong>Aplicar propuesta de IA</strong><p>Crear seguimiento y reservar revisión</p></div><div><span class="muted">Origen</span><br />Asistente IA</div><div>' +
        badge("Sugerencia", "ai") +
        '</div><div class="inline-actions"><button class="button secondary" type="button" data-toast="Evidencia de IA abierta">Ver evidencia</button></div></article></div>'
    ].join("");
  }

  function projectActivity(project, work) {
    var externalEvent = "";
    if (isCatastroWork(work)) {
      externalEvent =
        '<article class="notification-row is-unread"><span class="leading-marker high"></span><div><strong>APT requiere atención</strong><p>' +
        escapeHtml(work.id) +
        ' recibió observaciones nuevas.</p></div><time>08:14</time></article>';
    } else if (hasExternalHistory(work)) {
      externalEvent =
        '<article class="notification-row"><span class="leading-marker"></span><div><strong>Monitoreo externo cerrado</strong><p>' +
        escapeHtml(work.id) +
        ' conserva APT/SIRI únicamente como historia inactiva.</p></div><time>21 jul</time></article>';
    }
    return [
      sectionHeader("Actividad y notificaciones", "Eventos del trabajo " + escapeHtml(work.id) + " y su contratación", '<a class="button secondary" href="#notificaciones">Centro general</a>'),
      '<div class="section-surface">',
      externalEvent,
      '<article class="notification-row"><span class="leading-marker info"></span><div><strong>Tarea actualizada</strong><p>' +
        escapeHtml(work.owner) +
        " completó una tarea de " +
        escapeHtml(work.id) +
        '.</p></div><time>07:52</time></article><article class="notification-row"><span class="leading-marker"></span><div><strong>OneDrive sincronizado</strong><p>Se reflejó un cambio directo en ' +
        escapeHtml(project.code + " / " + work.id) +
        ' / 04-ARCHIVO DWG.</p></div><time>Ayer</time></article></div>',
      '<p class="muted section">La entrega visible respeta 07:00–20:00; la actividad interna conserva el registro sin pérdida.</p>'
    ].join("");
  }

  function projectAi(project, work) {
    var isCatastro = isCatastroWork(work);
    return [
      sectionHeader("Asistente del proyecto", "Analiza únicamente información autorizada de " + escapeHtml(project.code) + " / " + escapeHtml(work.id), ""),
      '<div class="ai-suggestion"><header>' +
        badge("Propuesta de IA", "ai") +
        '<span class="muted">Confianza 82 % · fecha de corte 23 jul, 07:06</span></header><p><strong>Resumen:</strong> revisión interna en curso; una corrección crítica y un conflicto de vehículo podrían mover la entrega dos días.</p><ul class="evidence-list"><li>Tarea “' +
        escapeHtml(isCatastro ? "Corregir minuta APT" : "Validar entregable técnico") +
        '”, vence 24 jul.</li><li>Bloque de campo del 25 jul con Vehículo 01 en conflicto.</li>' +
        (isCatastro ? '<li>Última consulta APT exitosa a las 07:06.</li>' : "") +
        '</ul><div class="inline-actions"><button class="button secondary" type="button" data-toast="Propuesta de IA rechazada">Rechazar</button><button class="button primary" type="button" data-toast="Solicitud de aprobación creada">Solicitar aprobación</button></div></div>',
      '<div class="subtle-surface section"><h3>La IA no ejecuta</h3><p class="muted">No cambia estados, mueve archivos, reserva recursos ni opera APT/SIRI. Una persona decide y la decisión queda auditada.</p></div>'
    ].join("");
  }

  function projectReports(project, work) {
    return [
      sectionHeader("Reportes y entregables", "Salidas del trabajo " + escapeHtml(work.id) + " con agregado de contratación disponible", '<button class="button primary" type="button" data-toast="Reporte del trabajo generado en borrador">Generar reporte</button>'),
      '<div class="two-column"><section class="section-surface"><h3>Control del Trabajo</h3><p class="muted">Estado, bloqueos, responsables, gestiones, agenda y evidencia de ' +
        escapeHtml(work.id) +
        ' con fecha de corte.</p><button class="button secondary section" type="button" data-toast="Vista previa del Trabajo abierta">Vista previa del Trabajo</button></section><section class="section-surface"><h3>Agregado de la contratación</h3><p class="muted">Compara los ' +
        getProjectWorks(project).length +
        ' Trabajos por identificador; no fusiona tipos, estados ni responsables.</p><button class="button secondary section" type="button" data-toast="Vista previa agregada abierta">Vista previa agregada</button></section></div>',
      '<div class="history-note section"><strong>Guardar en OneDrive requiere aprobación.</strong><p>Toda exportación queda auditada y respeta el alcance del usuario.</p></div>'
    ].join("");
  }

  function projectExternal(project, work) {
    var isCatastro = isCatastroWork(work);
    if (isCatastro) {
      return [
        sectionHeader("Trámites externos", "Consulta de solo lectura · última consulta exitosa 23 jul, 07:06", '<button class="button secondary" type="button" data-toast="Consulta manual limitada simulada">Consultar ahora</button>'),
        '<div class="integration-grid"><div class="integration-panel apt"><header><h3>APT · contrato ' +
          escapeHtml(work.contract) +
          "</h3>" +
          badge(work.apt, work.aptTone) +
          '</header><p>Texto original: “Plano devuelto con observaciones de calificación”.</p><p class="muted">Clasificación normalizada separada del texto institucional.</p></div><div class="integration-panel siri"><header><h3>SIRI</h3>' +
          badge("Sin consultar", "siri") +
          '</header><p>No hay apelaciones ni solicitudes de mantenimiento.</p></div></div>'
      ].join("");
    }
    if (!hasExternalHistory(work)) return projectSummary(project, work);
    return [
      sectionHeader("Historial externo", "Sin integración activa · evidencia vinculada al Trabajo " + escapeHtml(work.id), ""),
      '<div class="history-note"><strong>Historial protegido</strong><p>Este Trabajo cambió de ' +
        escapeHtml(work.externalHistory.previousType) +
        " a " +
        escapeHtml(work.type) +
        ". APT/SIRI dejó de monitorearse; los eventos anteriores permanecen disponibles solo en el historial autorizado.</p></div>",
      '<div class="section-surface section"><dl class="review-list"><div><dt>Último estado APT anterior</dt><dd>' +
        escapeHtml(work.externalHistory.lastAptStatus) +
        ' · dato histórico</dd></div><div><dt>Monitoreo</dt><dd>Inactivo desde ' +
        escapeHtml(work.externalHistory.changedAtUtc) +
        '</dd></div><div><dt>Acceso</dt><dd>Auditoría autorizada</dd></div></dl></div>'
    ].join("");
  }

  function projectFiles(project, work) {
    return [
      sectionHeader("Documentos en OneDrive", "Solo metadatos en la plataforma", '<a class="button primary" href="#archivos">Abrir explorador</a>'),
      '<div class="section-surface"><div class="file-path"><span>JBC</span><span>/</span><span>Proyectos</span><span>/</span><strong>' +
      escapeHtml(project.code) +
        "</strong><span>/</span><strong>" +
        escapeHtml(work.id) +
        "</strong></div>",
      fileRows(project, work),
      "</div>"
    ].join("");
  }

  function projectHistory(project, work) {
    var changedType = hasExternalHistory(work);
    var externalEvent = isCatastroWork(work)
      ? '<li><time>22 jul 2026 · 19:04</time><strong>Consulta externa registrada</strong><p>Texto original y clasificación normalizada conservados por separado.</p></li>'
      : "";
    return [
      sectionHeader("Historial del trabajo", "Solo adición · " + escapeHtml(work.id) + " · fechas de presentación en Costa Rica", ""),
      changedType
        ? '<div class="history-note"><strong>Cambio de tipo del Trabajo aprobado</strong><p>' +
          escapeHtml(work.externalHistory.previousType) +
          " → " +
          escapeHtml(work.type) +
          ". Estado anterior: " +
          escapeHtml(work.externalHistory.previousStatus) +
          ". Usuario: " +
          escapeHtml(work.externalHistory.changedBy) +
          ". Marca UTC: " +
          escapeHtml(work.externalHistory.changedAtUtc) +
          ". APT/SIRI quedó histórico e inactivo.</p></div>"
        : "",
      '<div class="section-surface ' +
        (changedType ? "section" : "") +
        '"><ol class="timeline">',
      changedType
        ? '<li><time>21 jul 2026 · 10:42 Costa Rica</time><strong>Tipo del Trabajo actualizado</strong><p>Comparativo ' +
          escapeHtml(work.externalHistory.approval) +
          " aprobado por dos personas según política pendiente de configurar.</p></li>"
        : '<li><time>23 jul 2026 · 08:12</time><strong>Estado del Trabajo actualizado</strong><p>' +
          escapeHtml(work.owner) +
          " cambió " +
          escapeHtml(work.id) +
          " a " +
          escapeHtml(work.status) +
          ".</p></li>",
      externalEvent,
      '<li><time>21 jul 2026 · 14:30</time><strong>Responsable actualizado</strong><p>Laura Mora asignó a ' +
        escapeHtml(work.owner) +
        " en " +
        escapeHtml(work.id) +
        ".</p></li>",
      '<li><time>18 jul 2026 · 09:30</time><strong>Trabajo creado manualmente</strong><p>' +
        escapeHtml(work.id) +
        " quedó vinculado a la contratación " +
        escapeHtml(project.code) +
        " sin heredar tipo, estado ni responsable de otros Trabajos.</p></li>",
      "</ol></div>"
    ].join("");
  }

  function projectChatter(project, work) {
    var inputId = "project-chatter-input-" + project.code + "-" + work.id;
    var fileInputId = "project-chatter-files-" + project.code + "-" + work.id;
    var relatedFilterId = "related-type-filter-" + project.code + "-" + work.id;
    var changedType = hasExternalHistory(work);
    var tramitesCount = isCatastroWork(work) ? 2 : changedType ? 1 : 0;
    var relations = getWorkRelations(work);
    var relatedTypes = [
      ["trabajos", "Trabajos", getProjectWorks(project).length],
      ["datos", "Datos", 4],
      ["gestiones", "Gestiones", relations.gestiones],
      ["tareas", "Tareas", relations.tareas],
      ["agenda", "Agenda", relations.agenda],
      ["tramites", "Trámites", tramitesCount],
      ["archivos", "Archivos", relations.archivos],
      ["aprobaciones", "Aprobaciones", relations.aprobaciones],
      ["actividad", "Actividad", relations.actividad],
      ["reportes", "Reportes", relations.reportes],
      ["historial", "Historial", relations.historial]
    ];
    return [
      '<aside class="project-chatter" id="project-activity" aria-label="Contexto vivo del proyecto y trabajo activo" data-project-chatter data-project-code="',
      escapeHtml(project.code),
      '" data-project-work-id="',
      escapeHtml(work.id),
      '"><header class="chatter-header"><div><span class="eyebrow">Contratación + trabajo activo</span><h2>Contexto vivo</h2><p>',
      escapeHtml(work.id),
      ' · ',
      escapeHtml(work.name),
      '</p></div>',
      badge("Solo adición", "info"),
      '</header><section class="live-context"><div class="live-context-heading"><h3>Relacionados</h3><span>Inspeccione aquí o abra el objeto real</span></div><div class="live-context-filter"><label for="',
      escapeHtml(relatedFilterId),
      '">Filtrar por tipo</label><select id="',
      escapeHtml(relatedFilterId),
      '" data-related-filter aria-describedby="',
      escapeHtml(relatedFilterId),
      '-help"><option value="">Seleccione un tipo relacionado</option>',
      relatedTypes
        .map(function (item) {
          return '<option value="' + escapeHtml(item[0]) + '">' + escapeHtml(item[1]) + " · " + escapeHtml(item[2]) + "</option>";
        })
        .join(""),
      '</select><p id="',
      escapeHtml(relatedFilterId),
      '-help">Los 11 tipos siguen disponibles sin ocupar espacio permanente.</p></div><section class="related-inspector" data-related-inspector aria-live="polite" hidden><header><div><span class="eyebrow">Vista rápida</span><h3 data-related-title>Detalle relacionado</h3></div><button class="icon-button" type="button" data-related-close aria-label="Cerrar detalle relacionado" title="Cerrar detalle relacionado">×</button></header><div data-related-content></div></section></section>',
      '<div class="chatter-composer"><label class="sr-only" for="',
      escapeHtml(inputId),
      '">Anotación, comando o archivo del proyecto</label><div class="chatter-input-shell" data-composer-drop-target><textarea id="',
      escapeHtml(inputId),
      '" rows="3" data-chatter-input placeholder="Anote en el proyecto o escriba / para crear…"></textarea><div class="chatter-input-tools"><span>También puede arrastrar archivos a este campo</span><label for="',
      escapeHtml(fileInputId),
      '" class="composer-attach" title="Seleccionar archivos"><span aria-hidden="true">⌁</span> Adjuntar</label></div><input class="sr-only" id="',
      escapeHtml(fileInputId),
      '" type="file" multiple data-chatter-file-input aria-label="Seleccionar archivos para clasificar en OneDrive" /></div>',
      '<div class="chatter-command-menu" data-chatter-command-menu hidden><p>Crear desde el contexto</p><button type="button" data-chatter-command="/tarea">/tarea <span>Nueva tarea</span></button><button type="button" data-chatter-command="/comentario">/comentario <span>Comentario trazable</span></button><button type="button" data-chatter-command="/agenda">/agenda <span>Bloque de agenda</span></button><button type="button" data-chatter-command="/gestion">/gestion <span>Nueva gestión</span></button></div>',
      '<div data-file-proposal-host></div>',
      '<div class="chatter-submit-row"><span>Sin /: anotación · Con /: crea el tipo elegido · Adjuntos: OneDrive</span><button class="button primary" type="button" data-chatter-submit>Publicar</button></div>',
      '<p class="chatter-storage"><strong>Destino:</strong> OneDrive / JBC / Proyectos / <span class="code">',
      escapeHtml(project.code),
      '</span> / <span class="code">',
      escapeHtml(work.id),
      '</span>. La plataforma conserva solo metadatos.</p></div>',
      '<ol class="chatter-feed" data-chatter-feed aria-label="Historial cronológico del proyecto">',
      '<li><span class="chatter-avatar" aria-hidden="true">LM</span><div><header><strong>Laura Mora</strong><time datetime="2026-07-23T14:12:00Z">Hoy · 08:12</time></header><p>Cambió el estado interno de Elaboración a Revisión interna.</p><span class="chatter-kind">Actividad</span></div></li>',
      '<li><span class="chatter-avatar file" aria-hidden="true">OD</span><div><header><strong>OneDrive</strong><time datetime="2026-07-23T13:44:00Z">Hoy · 07:44</time></header><p><a class="chatter-object-link" href="' +
        projectRoute(project, work, "archivos", workRecordId(work, "FILE", "CROQUIS-REV03")) +
        '"><strong>Croquis_rev03.pdf</strong></a> quedó vinculado a 05-PRESENTACIONES. Binario en OneDrive; metadatos sincronizados.</p><a class="chatter-file-link" href="' +
        projectRoute(project, work, "archivos", workRecordId(work, "FILE", "CROQUIS-REV03")) +
        '">Abrir archivo</a></div></li>',
      changedType
        ? '<li><span class="chatter-avatar system" aria-hidden="true">AU</span><div><header><strong>Auditoría</strong><time datetime="' +
          escapeHtml(work.externalHistory.changedAtUtc) +
          '">21 jul · 10:42</time></header><p>Tipo del Trabajo actualizado de ' +
          escapeHtml(work.externalHistory.previousType) +
          " a " +
          escapeHtml(work.type) +
          ". Estado anterior: " +
          escapeHtml(work.externalHistory.previousStatus) +
          ". APT/SIRI quedó histórico e inactivo.</p><span class=\"chatter-kind\">Cambio protegido</span></div></li>"
        : '<li><span class="chatter-avatar" aria-hidden="true">CV</span><div><header><strong>Carlos Vega</strong><time datetime="2026-07-22T21:08:00Z">Ayer · 15:08</time></header><p>Creó una tarea exclusiva de ' +
          escapeHtml(work.id) +
          ' con vencimiento 24 jul.</p><span class="chatter-kind">Tarea del Trabajo</span></div></li>',
      '<li><span class="chatter-avatar system" aria-hidden="true">J</span><div><header><strong>JBC Proyectos</strong><time datetime="2026-07-18T15:30:00Z">18 jul · 09:30</time></header><p>Trabajo ' +
        escapeHtml(work.id) +
        ' creado manualmente dentro de la contratación ' +
        escapeHtml(project.code) +
        '.</p><span class="chatter-kind">Creación del Trabajo</span></div></li>',
      '</ol><footer class="chatter-footer">Anotaciones, comandos y archivos respetan permisos, auditoría y aprobaciones.</footer></aside>'
    ].join("");
  }

  function renderProject(params) {
    var project = getProject(params.get("id") || projects[0].code);
    var work = getProjectWork(project, params.get("work"));
    var tab = params.get("tab") || "resumen";
    var record = params.get("record") || "";
    var sections = {
      resumen: projectSummary,
      datos: projectData,
      gestiones: projectGestiones,
      tareas: projectTasks,
      agenda: projectAgenda,
      archivos: projectFiles,
      aprobaciones: projectApprovals,
      actividad: projectActivity,
      ia: projectAi,
      reportes: projectReports,
      historial: projectHistory
    };
    if (isCatastroWork(work) || hasExternalHistory(work)) sections.tramites = projectExternal;
    if (!sections[tab]) tab = "resumen";
    var content = projectRecordDetail(tab, record, project, work) + sections[tab](project, work);
    return [
      '<div class="page-shell">',
      '<nav class="breadcrumbs" aria-label="Ruta"><a href="#proyectos">Proyectos</a><span aria-hidden="true">/</span><span>' +
        escapeHtml(project.code) +
        "</span></nav>",
      pageHeader(
        "Contratación · " + project.code,
        project.name,
        project.client + " · " + getProjectWorks(project).length + (getProjectWorks(project).length === 1 ? " trabajo" : " trabajos"),
        '<button class="button secondary" type="button" data-scroll-chatter>Actividad e historial</button><button class="button secondary" type="button" data-toast="Edición contractual simulada">Editar contratación</button><button class="button primary" type="button" data-toast="Nueva gestión de ' +
          escapeHtml(work.id) +
          ' simulada">Nueva gestión en ' +
          escapeHtml(work.id) +
          "</button>"
      ),
      '<div class="project-identity"><span class="code">' +
        escapeHtml(project.code) +
        '</span><span class="muted">Estado del Trabajo activo:</span>' +
        badge(work.status, work.tone) +
        '<span class="muted">Trabajo activo: ' +
        escapeHtml(work.id) +
        " · " +
        escapeHtml(work.owner) +
        "</span></div>",
      '<div class="project-workspace"><div class="project-primary">',
      projectWorkSwitcher(project, work),
      projectNavigation(project, tab, work),
      content,
      "</div>",
      projectChatter(project, work),
      "</div>",
      "</div>"
    ].join("");
  }

  function renderTrabajo() {
    return [
      '<div class="page-shell">',
      pageHeader(
        "Operación diaria",
        "Gestiones y tareas",
        "Seguimientos, dependencias, responsables y vencimientos en una vista accesible.",
        '<button class="button primary" type="button" data-toast="Nueva tarea simulada">Crear tarea</button>'
      ),
      '<div class="filter-bar"><div class="filter-control"><label for="work-view">Vista</label><select id="work-view"><option>Mis tareas</option><option>Mi equipo</option><option>En espera</option><option>Vencidas</option></select></div><div class="filter-control"><label for="work-priority">Prioridad</label><select id="work-priority"><option>Todas</option><option>Crítica</option><option>Alta</option></select></div></div>',
      '<div class="split-layout"><section>',
      sectionHeader("Para hoy", "5 tareas asignadas", ""),
      '<div class="section-surface"><ul class="list">',
      '<li class="list-row"><span class="leading-marker high"></span><div class="list-row-main"><a class="object-link" href="#proyecto?id=JBC-2026-0042&amp;work=TR-0042-01&amp;tab=tareas&amp;record=TASK-TR-0042-01-01"><strong>Corregir minuta APT</strong></a><span>JBC-2026-0042 / TR-0042-01 · 2 de 5 puntos completos</span></div><span class="priority critical">Crítica</span></li>',
      '<li class="list-row"><span class="leading-marker attention"></span><div class="list-row-main"><a class="object-link" href="#proyecto?id=JBC-2026-0018&amp;work=TR-0018-01&amp;tab=tareas&amp;record=TASK-TR-0018-01-01"><strong>Confirmar visita de campo</strong></a><span>JBC-2026-0018 / TR-0018-01 · cliente externo</span></div>' +
        badge("En espera", "warning") +
        "</li>",
      '<li class="list-row"><span class="leading-marker info"></span><div class="list-row-main"><a class="object-link" href="#proyecto?id=JBC-2026-0009&amp;work=TR-0009-01&amp;tab=tareas&amp;record=TASK-TR-0009-01-01"><strong>Revisar cálculo de áreas</strong></a><span>JBC-2026-0009 / TR-0009-01 · vence 16:00</span></div>' +
        badge("En curso", "info") +
        "</li>",
      "</ul></div></section>",
      "<aside>",
      sectionHeader("Dependencias", "Texto e icono, no solo color", ""),
      '<div class="section-surface"><ul class="list"><li class="list-row"><span class="leading-marker attention"></span><div class="list-row-main"><strong>2 tareas bloqueadas</strong><span>Esperan revisión técnica</span></div></li><li class="list-row"><span class="leading-marker high"></span><div class="list-row-main"><strong>1 vencimiento en riesgo</strong><span>Entrega mañana, 17:00</span></div></li></ul></div>',
      "</aside></div></div>"
    ].join("");
  }

  function renderAgenda() {
    return [
      '<div class="page-shell">',
      pageHeader(
        "Agenda móvil predeterminada",
        "Programación",
        "Bloques de ejecución distintos del vencimiento de las tareas.",
        '<button class="button primary" type="button" data-toast="Nuevo bloque simulado">Programar bloque</button>'
      ),
      '<div class="filter-bar"><div class="filter-control"><label for="agenda-date">Fecha</label><input id="agenda-date" type="date" value="2026-07-23" /></div><div class="filter-control"><label for="agenda-owner">Persona o recurso</label><select id="agenda-owner"><option>Todo el equipo</option><option>Carlos Vega</option><option>GNSS 02</option></select></div></div>',
      '<section class="section-surface" aria-label="Agenda del 23 de julio">',
      '<div class="agenda-day"><span class="agenda-time">08:00</span><div class="agenda-event field"><a class="object-link" href="#proyecto?id=JBC-2026-0042&amp;work=TR-0042-01&amp;tab=agenda&amp;record=AGENDA-TR-0042-01-0800"><strong>Levantamiento · San Rafael</strong></a><p>JBC-2026-0042 / TR-0042-01 · Carlos Vega · GNSS 02 · Vehículo 01</p></div></div>',
      '<div class="agenda-day"><span class="agenda-time">10:30</span><div class="agenda-event"><a class="object-link" href="#proyecto?id=JBC-2026-0009&amp;work=TR-0009-01&amp;tab=agenda&amp;record=AGENDA-TR-0009-01-1030"><strong>Procesamiento de puntos</strong></a><p>JBC-2026-0009 / TR-0009-01 · Diego León · Oficina</p></div></div>',
      '<div class="agenda-day"><span class="agenda-time">13:30</span><div class="agenda-event"><a class="object-link" href="#proyecto?id=JBC-2026-0042&amp;work=TR-0042-02&amp;tab=agenda&amp;record=AGENDA-TR-0042-02-1330"><strong>Revisión técnica</strong></a><p>JBC-2026-0042 / TR-0042-02 · Ana Solano</p></div></div>',
      '<div class="agenda-day"><span class="agenda-time">15:00</span><div class="agenda-event conflict"><a class="object-link" href="#proyecto?id=JBC-2026-0011&amp;work=TR-0011-01&amp;tab=agenda&amp;record=AGENDA-TR-0011-01-CONFLICT"><strong>Conflicto: Vehículo 01</strong></a><p>JBC-2026-0011 / TR-0011-01 · reservado también para otro Trabajo. Requiere resolución antes de confirmar.</p><button class="button ghost" type="button" data-toast="Comparativo de conflicto entre Trabajos abierto">Comparar reservas</button></div></div>',
      "</section></div>"
    ].join("");
  }

  function fileRows(project, work) {
    var files = [
      ["▣", "01-ESTUDIO PREVIO", "Carpeta protegida", "hace 3 min"],
      ["▣", "02-PLANOS RELACIONADOS", "Carpeta protegida", "ayer"],
      ["▣", "03-DATOS DEL LEVANTAMIENTO", "12 elementos", "22 jul"],
      ["▣", "04-ARCHIVO DWG", "4 elementos", "21 jul"],
      ["▣", "05-PRESENTACIONES", "2 elementos", "20 jul"],
      ["▣", "99-ARCHIVADOS", "Carpeta protegida", "18 jul"]
    ];
    return files
      .map(function (file, index) {
        var name =
          project && work
            ? '<a class="object-link" href="' +
              projectRoute(project, work, "archivos", workRecordId(work, "FOLDER", String(index + 1).padStart(2, "0"))) +
              '">' +
              file[1] +
              "</a>"
            : file[1];
        return [
          '<div class="file-row"><span class="file-icon" aria-hidden="true">',
          file[0],
          '</span><div class="file-name"><strong>',
          name,
          "</strong><small>",
          file[2],
          '</small></div><span class="file-meta">',
          file[3],
          '</span><button class="icon-button" type="button" aria-label="Más acciones para ',
          file[1],
          '" data-toast="Menú de archivo simulado">•••</button></div>'
        ].join("");
      })
      .join("");
  }

  function renderArchivos() {
    return [
      '<div class="page-shell">',
      pageHeader(
        "Microsoft OneDrive",
        "Documentos",
        "La plataforma conserva metadatos e identificadores; los archivos viven exclusivamente en OneDrive.",
        '<a class="button primary" href="#proyecto?id=JBC-2026-0042&work=TR-0042-01&tab=archivos">Adjuntar desde Contexto vivo</a>'
      ),
      '<div class="history-note"><strong>Entrada única de archivos</strong><p>Seleccione una Contratación y un Trabajo. El adjunto se arrastra o elige en el compositor del Contexto vivo y el único botón Publicar confirma la carga propuesta.</p></div>',
      '<div class="history-note section"><strong>Protección activa</strong><p>Los documentos no se eliminan. Una carpeta no vacía se archiva; solo una carpeta completamente vacía puede ir a la papelera con doble control.</p></div>',
      '<section class="section section-surface"><div class="file-path"><a href="#archivos">JBC</a><span>/</span><a href="#archivos">Proyectos</a><span>/</span><strong>JBC-2026-0042</strong><span>/</span><strong>TR-0042-01</strong></div>',
      fileRows(getProject("JBC-2026-0042"), getProjectWork(getProject("JBC-2026-0042"), "TR-0042-01")),
      "</section></div>"
    ].join("");
  }

  function renderAprobaciones() {
    return [
      '<div class="page-shell">',
      pageHeader("Decisión humana", "Centro de aprobaciones", "Aprobar y ejecutar son eventos separados; la versión se revalida antes de actuar.", ""),
      '<nav class="tabs" aria-label="Estados de aprobación"><button type="button" aria-selected="true">Pendientes · 4</button><button type="button">Resueltas</button><button type="button">Vencidas</button></nav>',
      '<section class="section-surface">',
      '<article class="approval-row"><div><a class="object-link" href="#proyecto?id=JBC-2026-0042&amp;work=TR-0042-01&amp;tab=aprobaciones&amp;record=APPROVAL-TR-0042-01-ARCHIVO"><strong>Mover carpeta a 99-ARCHIVADOS</strong></a><p>JBC-2026-0042 / TR-0042-01 · motivo: versión sustituida</p></div><div><span class="muted">Solicitó</span><br />Carlos Vega</div><div>' +
        badge("Impacto medio", "warning") +
        '</div><div class="inline-actions"><button class="button secondary" type="button" data-toast="Solicitud rechazada">Rechazar</button><button class="button primary" type="button" data-toast="Decisión registrada; ejecución pendiente">Aprobar</button></div></article>',
      '<article class="approval-row"><div><a class="object-link" href="#proyecto?id=JBC-2026-0018&amp;work=TR-0018-01&amp;tab=historial&amp;record=EVENT-TR-0018-01-TYPE"><strong>Cambiar tipo del Trabajo</strong></a><p>JBC-2026-0018 / TR-0018-01 · comparativo disponible</p></div><div><span class="muted">Solicitó</span><br />Ana Solano</div><div>' +
        badge("Impacto alto", "danger") +
        '</div><div class="inline-actions"><button class="button secondary" type="button" data-toast="Comparativo abierto">Revisar</button></div></article>',
      '<article class="approval-row"><div><a class="object-link" href="#proyecto?id=JBC-2026-0009&amp;work=TR-0009-02&amp;tab=ia&amp;record=AI-TR-0009-02-TASKS"><strong>Aplicar propuesta de IA</strong></a><p>JBC-2026-0009 / TR-0009-02 · crear 3 tareas para seguimiento</p></div><div><span class="muted">Origen</span><br />Asistente IA</div><div>' +
        badge("Sugerencia", "ai") +
        '</div><div class="inline-actions"><button class="button secondary" type="button" data-toast="Evidencia abierta">Ver evidencia</button></div></article>',
      "</section></div>"
    ].join("");
  }

  function renderNotificaciones() {
    return [
      '<div class="page-shell">',
      pageHeader("Centro persistente", "Notificaciones", "Los avisos internos permanecen aunque Windows o Web Push fallen.", '<button class="button secondary" type="button" data-toast="Todas marcadas como leídas">Marcar todas como leídas</button>'),
      '<div class="split-layout"><section>',
      sectionHeader("Recientes", "3 sin leer", ""),
      '<div class="section-surface">',
      '<article class="notification-row is-unread"><span class="leading-marker high"></span><div><a class="object-link" href="#proyecto?id=JBC-2026-0042&amp;work=TR-0042-01&amp;tab=tramites&amp;record=APT-2026-01842"><strong>APT requiere atención</strong></a><p>JBC-2026-0042 / TR-0042-01 recibió observaciones nuevas.</p></div><time>08:14</time></article>',
      '<article class="notification-row is-unread"><span class="leading-marker attention"></span><div><a class="object-link" href="#proyecto?id=JBC-2026-0042&amp;work=TR-0042-02&amp;tab=aprobaciones&amp;record=APPROVAL-TR-0042-02-OWNER"><strong>Aprobación pendiente</strong></a><p>JBC-2026-0042 / TR-0042-02 · cambio de responsable · vence hoy.</p></div><time>07:48</time></article>',
      '<article class="notification-row is-unread"><span class="leading-marker info"></span><div><a class="object-link" href="#proyecto?id=JBC-2026-0009&amp;work=TR-0009-01&amp;tab=agenda&amp;record=AGENDA-TR-0009-01-REMINDER"><strong>Recordatorio de agenda</strong></a><p>JBC-2026-0009 / TR-0009-01 · levantamiento en 45 minutos.</p></div><time>07:15</time></article>',
      '<article class="notification-row"><span class="leading-marker"></span><div><strong>OneDrive sincronizado</strong><p>2 cambios directos reflejados.</p></div><time>Ayer</time></article>',
      "</div></section><aside>",
      sectionHeader("Horario predeterminado", "America/Costa_Rica", ""),
      '<div class="quiet-hours"><div><strong>07:00</strong><span>Inicia entrega</span></div><span class="arrow" aria-hidden="true">→</span><div><strong>20:00</strong><span>Inicia silencio</span></div></div>',
      '<div class="subtle-surface section"><h3>Durante 20:00–07:00</h3><p class="muted">El aviso interno se registra sin pérdida y la entrega visible queda en cola hasta las 07:00. Los reintentos no duplican.</p></div>',
      '<button class="button secondary section" type="button" data-toast="Preferencias guardadas en borrador">Editar preferencias</button>',
      "</aside></div></div>"
    ].join("");
  }

  function renderReportes() {
    return [
      '<div class="page-shell">',
      pageHeader("Datos autorizados", "Reportes", "Contrataciones y Trabajos se agregan sin fusionar sus tipos, estados ni responsables.", '<button class="button primary" type="button" data-toast="Exportación CSV simulada y auditada">Exportar</button>'),
      '<div class="filter-bar"><div class="filter-control"><label for="report-type">Tipo de Trabajo</label><select id="report-type"><option>Todos los tipos</option><option>Plano de catastro</option><option>Delimitación</option><option>Curvas de nivel</option><option>Avalúo</option><option>Croquis</option></select></div><div class="filter-control"><label for="report-status">Estado de Trabajo</label><select id="report-status"><option>Todos los estados</option><option>Planificado</option><option>En ejecución</option><option>En espera</option><option>Revisión interna</option></select></div><div class="filter-control"><label for="report-owner">Responsable de Trabajo</label><select id="report-owner"><option>Todo el equipo</option><option>Ana Solano</option><option>Carlos Vega</option><option>Diego León</option></select></div></div>',
      '<section class="metric-strip"><div class="metric"><strong>184</strong><span>contrataciones</span></div><div class="metric"><strong>263</strong><span>trabajos totales</span></div><div class="metric"><strong>47</strong><span>trabajos en ejecución</span></div><div class="metric"><strong>91 %</strong><span>hitos a tiempo</span></div></section>',
      '<section class="section">',
      sectionHeader("Distribución por tipo de Trabajo", "Periodo: 1 ene – 23 jul 2026", ""),
      '<div class="section-surface"><ul class="list"><li class="list-row"><div class="list-row-main"><strong>Plano de catastro</strong><span>116 trabajos · 73 contrataciones</span></div><strong>44 %</strong></li><li class="list-row"><div class="list-row-main"><strong>Delimitación</strong><span>52 trabajos · 38 contrataciones</span></div><strong>20 %</strong></li><li class="list-row"><div class="list-row-main"><strong>Curvas de nivel</strong><span>38 trabajos · 26 contrataciones</span></div><strong>14 %</strong></li><li class="list-row"><div class="list-row-main"><strong>Avalúo y Croquis</strong><span>57 trabajos · 42 contrataciones</span></div><strong>22 %</strong></li></ul></div>',
      "</section>",
      '<div class="history-note section"><strong>Guardar en OneDrive requiere aprobación.</strong><p>Excel, CSV y PDF se generan con el alcance actual y toda exportación queda auditada.</p></div>',
      "</div>"
    ].join("");
  }

  function renderAdministracion() {
    return [
      '<div class="page-shell">',
      pageHeader("Preferencias y catálogos", "Configuración", "Catálogos y preferencias versionados; los valores usados se archivan, no se eliminan.", ""),
      '<div class="split-layout"><section>',
      sectionHeader("Catálogos", "Versión activa v3", ""),
      '<div class="section-surface"><div class="admin-row"><div><strong>Tipos de Trabajo</strong><p>5 valores protegidos · campos y módulos por cada Trabajo</p></div><button class="button secondary" type="button" data-toast="Catálogo abierto">Administrar</button></div><div class="admin-row"><div><strong>Estados internos de Trabajo</strong><p>11 estados + espera transversal; la Contratación solo agrega</p></div><button class="button secondary" type="button" data-toast="Estados abiertos">Administrar</button></div><div class="admin-row"><div><strong>Tipos documentales</strong><p>Carpeta, extensión, sensibilidad y conservación</p></div><button class="button secondary" type="button" data-toast="Tipos documentales abiertos">Administrar</button></div><div class="admin-row"><div><strong>Recursos</strong><p>GNSS, estaciones, vehículos y disponibilidad</p></div><button class="button secondary" type="button" data-toast="Recursos abiertos">Administrar</button></div></div>',
      "</section><aside>",
      sectionHeader("Apariencia personal", "Fondos neutros en ambos temas", ""),
      '<div class="section-surface"><h3>Tema</h3><p>Automático respeta la preferencia clara u oscura del sistema.</p><div class="theme-options section" role="group" aria-label="Tema de interfaz"><button type="button" data-theme-choice="system" aria-pressed="true">Automático</button><button type="button" data-theme-choice="light" aria-pressed="false">Claro</button><button type="button" data-theme-choice="dark" aria-pressed="false">Oscuro</button></div><hr class="preference-divider" /><h3>Color de acento</h3><p>Se aplica a controles, foco y énfasis; no altera fondos ni colores semánticos.</p><div class="accent-options section" role="group" aria-label="Acento de usuario"><button type="button" data-accent="#0f766e" aria-label="Teal institucional" aria-pressed="true" class="is-selected"></button><button type="button" data-accent="#1d4ed8" aria-label="Azul" aria-pressed="false"></button><button type="button" data-accent="#4338ca" aria-label="Índigo" aria-pressed="false"></button><button type="button" data-accent="#6d28d9" aria-label="Violeta" aria-pressed="false"></button><button type="button" data-accent="#a21caf" aria-label="Rosa" aria-pressed="false"></button><button type="button" data-accent="#9a3412" aria-label="Naranja" aria-pressed="false"></button></div><button class="button ghost section" type="button" data-accent-reset>Restaurar institucional</button></div>',
      '<section class="section subtle-surface"><h3>Entorno y versión</h3><p class="muted">Prototipo local · Fase 1<br />Sin servicios conectados</p></section>',
      "</aside></div></div>"
    ].join("");
  }

  function renderEstados() {
    var items = [
      ["Cargando", "loading"],
      ["Vacío", "empty"],
      ["Error", "error"],
      ["Sin permiso", "permissions"],
      ["Degradación externa", "degraded"],
      ["Datos antiguos", "stale"],
      ["Sin conexión", "offline"],
      ["Éxito", "success"],
      ["Conflicto concurrente", "conflict"]
    ];
    return [
      '<div class="page-shell">',
      pageHeader("Patrones compartidos", "Estados de interfaz", "Cada vista implementa estos estados con texto, icono y una salida clara.", ""),
      '<section class="section-surface">',
      items
        .map(function (item) {
          return '<div class="state-specimen"><strong>' + item[0] + "</strong>" + stateBlock(item[1]) + "</div>";
        })
        .join(""),
      "</section></div>"
    ].join("");
  }

  function renderSearch(params) {
    var query = params.get("q") || searchInput.value || "San Rafael";
    return [
      '<div class="page-shell">',
      pageHeader("Búsqueda autorizada", 'Resultados para “' + escapeHtml(query) + "”", "Coincidencias paginadas por proyecto, cliente, finca, plano y notas autorizadas.", ""),
      '<div class="section-surface"><ul class="list">',
      '<li class="list-row"><span class="leading-marker info"></span><div class="list-row-main"><a href="#proyecto?id=JBC-2026-0042&amp;work=TR-0042-01&amp;tab=resumen"><strong>Plano A · Lote San Rafael</strong><span>Trabajo · JBC-2026-0042 / TR-0042-01 · Inversiones Monte Verde</span></a></div>' +
        badge("Trabajo", "info") +
        "</li>",
      '<li class="list-row"><span class="leading-marker"></span><div class="list-row-main"><a href="#proyecto?id=JBC-2026-0042&amp;work=TR-0042-01&amp;tab=datos&amp;record=DATA-TR-0042-01-SCOPE"><strong>San Rafael, Escazú</strong><span>Inmueble · JBC-2026-0042 / TR-0042-01 · Finca 1-245678-000</span></a></div>' +
        badge("Inmueble", "") +
        "</li>",
      '<li class="list-row"><span class="leading-marker attention"></span><div class="list-row-main"><a href="#proyecto?id=JBC-2026-0042&amp;work=TR-0042-02&amp;tab=tareas&amp;record=TASK-TR-0042-02-01"><strong>Visita de campo San Rafael</strong><span>Tarea · JBC-2026-0042 / TR-0042-02 · vence 25 jul</span></a></div>' +
        badge("Tarea", "warning") +
        "</li>",
      "</ul></div></div>"
    ].join("");
  }

  function render() {
    if (assistantPanel.parentElement !== document.body) document.body.insertBefore(assistantPanel, toastRegion);
    var route = parseRoute();
    document.body.classList.toggle("is-project-route", route.name === "proyecto");
    var stateView = maybeState(route.name);
    var html = stateView;

    if (!html) {
      if (route.name === "inicio") html = renderInicio();
      else if (route.name === "proyectos") html = renderProyectos();
      else if (route.name === "crear") html = renderCreate();
      else if (route.name === "proyecto") html = renderProject(route.params);
      else if (route.name === "trabajo") html = renderTrabajo();
      else if (route.name === "agenda") html = renderAgenda();
      else if (route.name === "archivos") html = renderArchivos();
      else if (route.name === "aprobaciones") html = renderAprobaciones();
      else if (route.name === "notificaciones") html = renderNotificaciones();
      else if (route.name === "reportes") html = renderReportes();
      else if (route.name === "administracion") html = renderAdministracion();
      else if (route.name === "estados") html = renderEstados();
      else if (route.name === "buscar") html = renderSearch(route.params);
      else html = renderInicio();
    }

    main.innerHTML = html;
    if (route.name === "proyecto") document.querySelector(".project-workspace").appendChild(assistantPanel);
    syncPreferenceControls();
    updateAssistantContext();
    document.title = (routeNames[route.name] || "Inicio") + " · JBC Proyectos";
    updateNavigation(route.name);
    closeMoreSheet();
    window.scrollTo({ top: 0, behavior: "auto" });
  }

  function updateNavigation(route) {
    var current = route === "crear" || route === "proyecto" ? "proyectos" : route === "buscar" ? "" : route;
    document.querySelectorAll("[data-nav]").forEach(function (item) {
      if (item.getAttribute("data-nav") === current) item.setAttribute("aria-current", "page");
      else item.removeAttribute("aria-current");
    });
  }

  function openMoreSheet() {
    moreSheet.classList.add("is-open");
    moreSheet.setAttribute("aria-hidden", "false");
    moreButton.setAttribute("aria-expanded", "true");
    sheetBackdrop.hidden = false;
    closeSheetButton.focus();
  }

  function closeMoreSheet() {
    moreSheet.classList.remove("is-open");
    moreSheet.setAttribute("aria-hidden", "true");
    moreButton.setAttribute("aria-expanded", "false");
    sheetBackdrop.hidden = true;
  }

  function showToast(title, copy) {
    toastRegion.innerHTML =
      '<div class="toast"><span class="status-badge success">Listo</span><div><strong>' +
      escapeHtml(title || "Acción simulada") +
      "</strong><span>" +
      escapeHtml(copy || "Este prototipo no guarda cambios reales.") +
      "</span></div></div>";
    window.setTimeout(function () {
      toastRegion.innerHTML = "";
    }, 3600);
  }

  function resolveTheme(preference) {
    return preference === "system" ? (colorSchemeQuery.matches ? "dark" : "light") : preference;
  }

  function syncPreferenceControls() {
    document.querySelectorAll("[data-theme-choice]").forEach(function (item) {
      item.setAttribute("aria-pressed", String(item.getAttribute("data-theme-choice") === themePreference));
    });
    document.querySelectorAll("[data-accent]").forEach(function (item) {
      var selected = item.getAttribute("data-accent") === accentChoice;
      item.classList.toggle("is-selected", selected);
      item.setAttribute("aria-pressed", String(selected));
    });
  }

  function applyAccent() {
    var resolved = document.documentElement.dataset.theme || "light";
    var palette = accentTextColors[accentChoice] || accentTextColors["#0f766e"];
    document.documentElement.style.setProperty("--accent", accentChoice);
    document.documentElement.style.setProperty("--accent-strong", palette[resolved]);
    document.documentElement.style.setProperty("--focus-ring", palette[resolved]);
  }

  function setTheme(preference, source, announce) {
    themePreference = ["system", "light", "dark"].includes(preference) ? preference : "system";
    var resolved = resolveTheme(themePreference);
    document.documentElement.dataset.themePreference = themePreference;
    document.documentElement.dataset.theme = resolved;
    themeColorMeta.setAttribute("content", resolved === "dark" ? "#111315" : "#f4f5f6");
    applyAccent();
    syncPreferenceControls();
    if (announce !== false) {
      showToast("Tema actualizado", themePreference === "system" ? "La interfaz sigue la preferencia del sistema." : "Tema " + (resolved === "dark" ? "oscuro" : "claro") + " activo.");
    }
    if (source) source.focus();
  }

  function setAccent(color, source, announce) {
    accentChoice = accentTextColors[color] ? color : "#0f766e";
    applyAccent();
    syncPreferenceControls();
    if (announce !== false) showToast("Acento actualizado", "Los fondos neutros y los estados semánticos conservan su significado.");
    if (source) source.focus();
  }

  function setSidebarCompact(compact) {
    sidebarCompact = Boolean(compact);
    document.body.classList.toggle("sidebar-compact", sidebarCompact);
    sidebarToggle.setAttribute("aria-expanded", String(!sidebarCompact));
    var sidebarToggleLabel = sidebarCompact ? "Expandir menú principal" : "Mostrar solo iconos del menú principal";
    sidebarToggle.setAttribute("aria-label", sidebarToggleLabel);
    sidebarToggle.setAttribute("title", sidebarToggleLabel);
  }

  function activeAssistantContext() {
    var route = parseRoute();
    if (route.name === "proyecto") {
      var project = getProject(route.params.get("id") || projects[0].code);
      var work = getProjectWork(project, route.params.get("work"));
      return { label: project.code + " · " + work.id + " · " + work.type, project: project.code, work: work.id };
    }
    return {
      label: (routeNames[route.name] || "Vista general") + " · seleccione Proyecto y Trabajo para crear",
      project: "Por seleccionar",
      work: "Por seleccionar"
    };
  }

  function updateAssistantContext() {
    var context = activeAssistantContext();
    assistantContext.textContent = context.label;
    assistantContext.setAttribute("title", context.label);
  }

  function openAssistant() {
    document.body.classList.add("assistant-open");
    assistantPanel.classList.add("is-open");
    assistantPanel.inert = false;
    assistantPanel.setAttribute("aria-hidden", "false");
    assistantLauncher.setAttribute("aria-expanded", "true");
    assistantLauncher.setAttribute("aria-label", "Cerrar asistente IA");
    updateAssistantContext();
    window.requestAnimationFrame(function () {
      assistantInput.focus();
    });
  }

  function closeAssistant(restoreFocus) {
    document.body.classList.remove("assistant-open");
    assistantPanel.classList.remove("is-open");
    assistantPanel.inert = true;
    assistantPanel.setAttribute("aria-hidden", "true");
    assistantLauncher.setAttribute("aria-expanded", "false");
    assistantLauncher.setAttribute("aria-label", "Abrir asistente IA");
    assistantCommandMenu.hidden = true;
    if (restoreFocus !== false) assistantLauncher.focus();
  }

  function appendAssistantMessage(cssClass, content) {
    var article = document.createElement("article");
    article.className = "assistant-message " + cssClass;
    article.innerHTML = content;
    assistantMessages.appendChild(article);
    assistantMessages.scrollTop = assistantMessages.scrollHeight;
    return article;
  }

  function assistantProposal(command, detail) {
    var context = activeAssistantContext();
    var proposals = {
      "/tarea": ["Borrador de tarea", "Título", detail || "Revisar información pendiente", "Proyecto / Trabajo", context.project + " / " + context.work, "Estado", "Pendiente de revisión"],
      "/comentario": ["Borrador de comentario", "Contenido", detail || "Seguimiento preparado desde el asistente", "Proyecto / Trabajo", context.project + " / " + context.work, "Visibilidad", "Equipo autorizado"],
      "/agenda": ["Propuesta de agenda", "Bloque", detail || "Revisión técnica · 60 minutos", "Proyecto / Trabajo", context.project + " / " + context.work, "Validación", "Recursos y conflictos pendientes"],
      "/gestion": ["Borrador de gestión", "Asunto", detail || "Seguimiento operativo", "Proyecto / Trabajo", context.project + " / " + context.work, "Resultado", "Pendiente de completar"]
    };
    var item = proposals[command];
    if (!item) return false;
    appendAssistantMessage(
      "is-ai assistant-proposal",
      '<strong>' +
        escapeHtml(item[0]) +
        '</strong><p>Propuesta estructurada; todavía no modifica ninguna tabla.</p><dl><div><dt>' +
        escapeHtml(item[1]) +
        "</dt><dd>" +
        escapeHtml(item[2]) +
        "</dd></div><div><dt>" +
        escapeHtml(item[3]) +
        "</dt><dd>" +
        escapeHtml(item[4]) +
        "</dd></div><div><dt>" +
        escapeHtml(item[5]) +
        "</dt><dd>" +
        escapeHtml(item[6]) +
        '</dd></div></dl><div class="inline-actions"><button class="button secondary" type="button" data-ai-proposal="discard">Descartar</button><button class="button primary" type="button" data-ai-proposal="review">Revisar propuesta</button></div>'
    );
    return true;
  }

  function submitAssistantMessage(value) {
    var text = value.trim();
    if (!text) {
      assistantCommandMenu.querySelectorAll("[data-ai-command]").forEach(function (button) {
        button.hidden = false;
      });
      assistantCommandMenu.hidden = false;
      return;
    }
    appendAssistantMessage("is-user", "<strong>Usted</strong><p>" + escapeHtml(text) + "</p>");
    var parts = text.split(/\s+/);
    var command = parts[0].toLowerCase();
    var detail = text.slice(parts[0].length).trim();
    if (assistantProposal(command, detail)) return;
    if (command === "/resumen") {
      appendAssistantMessage("is-ai", "<strong>Resumen contextual</strong><p>Hay 2 tareas próximas, 1 aprobación pendiente y una consulta externa con fecha de corte visible. Solo se usó información autorizada del contexto actual.</p>");
      return;
    }
    if (command === "/buscar") {
      appendAssistantMessage("is-ai", '<strong>Búsqueda contextual</strong><p>Encontré coincidencias autorizadas en proyecto, tareas y documentos. <a class="section-link" href="#buscar?q=' + encodeURIComponent(detail || "San Rafael") + '">Abrir resultados verificables</a>.</p>');
      return;
    }
    appendAssistantMessage("is-ai", "<strong>Necesito una instrucción verificable</strong><p>Escriba <kbd>/</kbd> y elija una acción. Para cambiar datos prepararé un borrador antes de pedir confirmación.</p>");
  }

  function appendChatterEvent(chatter, title, copy, kind) {
    var feed = chatter.querySelector("[data-chatter-feed]");
    var item = document.createElement("li");
    item.innerHTML =
      '<span class="chatter-avatar" aria-hidden="true">LM</span><div><header><strong>' +
      escapeHtml(title) +
      '</strong><time>Ahora</time></header><p>' +
      escapeHtml(copy) +
      '</p><span class="chatter-kind">' +
      escapeHtml(kind) +
      "</span></div>";
    feed.insertBefore(item, feed.firstChild);
    feed.scrollTop = 0;
  }

  function relatedView(kind, projectCode, workId) {
    var project = getProject(projectCode);
    var work = getProjectWork(project, workId);
    var relations = getWorkRelations(work);
    var code = escapeHtml(projectCode);
    var open = function (tab, record) {
      return projectRoute(project, work, tab, record);
    };
    var workItems = getProjectWorks(project)
      .map(function (item) {
        return (
          '<li><a class="related-object-link" href="' +
          projectRoute(project, item, "resumen", item.id) +
          '"><strong>' +
          escapeHtml(item.name) +
          '</strong></a><span>' +
          escapeHtml(item.id) +
          " · " +
          escapeHtml(item.status) +
          " · " +
          escapeHtml(item.owner) +
          "</span></li>"
        );
      })
      .join("");
    var tramitesView;
    if (isCatastroWork(work)) {
      tramitesView = [
        "Trámites",
        '<ul class="related-list"><li><a class="related-object-link" href="' +
          open("tramites", "APT-" + work.contract) +
          '"><strong>APT · ' +
          escapeHtml(work.apt) +
          '</strong></a><span>Contrato ' +
          escapeHtml(work.contract) +
          ' · solo lectura</span></li><li><a class="related-object-link" href="' +
          open("tramites", "SIRI-" + work.id) +
          '"><strong>SIRI · sin consultar</strong></a><span>Estado separado del estado interno</span><div class="related-links"><button type="button" data-related-kind="historial">Inspeccionar historial</button></div></li></ul>'
      ];
    } else if (hasExternalHistory(work)) {
      tramitesView = [
        "Historial externo",
        '<ul class="related-list"><li><a class="related-object-link" href="' +
          open("tramites", "APT-HISTORICO-" + work.id) +
          '"><strong>APT histórico · ' +
          escapeHtml(work.externalHistory.lastAptStatus) +
          '</strong></a><span>Monitoreo inactivo desde ' +
          escapeHtml(work.externalHistory.changedAtUtc) +
          ' · auditoría autorizada</span><div class="related-links"><button type="button" data-related-kind="historial">Inspeccionar cambio de tipo</button></div></li></ul>'
      ];
    } else {
      tramitesView = [
        "Trámites",
        '<div class="empty-related"><strong>Sin trámites vinculados</strong><p>El Trabajo ' +
          escapeHtml(work.id) +
          " es de tipo " +
          escapeHtml(work.type) +
          ". No tiene una fuente oficial aplicable ni historia externa que mostrar.</p></div>"
      ];
    }
    var views = {
      trabajos: ["Trabajos", '<ul class="related-list">' + workItems + "</ul>"],
      datos: [
        "Datos",
        '<ul class="related-list"><li><a class="related-object-link" href="' +
          open("datos", "CLIENTE-PRINCIPAL") +
          '"><strong>' +
          escapeHtml(project.client) +
          '</strong></a><span>Cliente de la contratación · coordinación ' +
          escapeHtml(project.coordinator) +
          '</span><div class="related-links"><button type="button" data-related-kind="aprobaciones">Inspeccionar aprobaciones</button></div></li><li><a class="related-object-link" href="' +
          open("datos", workRecordId(work, "DATA", "SCOPE")) +
          '"><strong>' +
          escapeHtml(work.name) +
          '</strong></a><span>' +
          escapeHtml(work.id + " · " + work.type + " · " + work.area) +
          "</span></li></ul>"
      ],
      gestiones: [
        "Gestiones",
        '<ul class="related-list"><li><a class="related-object-link" href="' +
          open("gestiones", workRecordId(work, "MANAGEMENT", "REVISION")) +
          '"><strong>Revisión técnica y calidad</strong></a><span>' +
          relations.tareas +
          ' tareas del Trabajo · vence ' +
          escapeHtml(work.due) +
          '</span><div class="related-links"><button type="button" data-related-kind="tareas">Inspeccionar tareas</button><button type="button" data-related-kind="agenda">Inspeccionar agenda</button></div></li><li><a class="related-object-link" href="' +
          open("gestiones", workRecordId(work, "MANAGEMENT", "CLIENTE")) +
          '"><strong>Información del cliente</strong></a><span>En espera · seguimiento 25 jul</span><div class="related-links"><button type="button" data-related-kind="actividad">Inspeccionar actividad</button></div></li></ul>'
      ],
      tareas: [
        "Tareas",
        '<ul class="related-list"><li><a class="related-object-link" href="' +
          open("tareas", workRecordId(work, "TASK", "01")) +
          '"><strong>' +
          escapeHtml(isCatastroWork(work) ? "Corregir minuta APT" : "Validar entregable técnico") +
          '</strong></a><span>En curso · 2 de 5 · ' +
          escapeHtml(work.owner) +
          '</span><div class="related-links"><button type="button" data-related-kind="gestiones">Inspeccionar gestión</button><button type="button" data-related-kind="agenda">Inspeccionar bloque</button></div></li><li><a class="related-object-link" href="' +
          open("tareas", workRecordId(work, "TASK", "02")) +
          '"><strong>Preparar paquete de entrega</strong></a><span>Bloqueada por revisión técnica</span><div class="related-links"><button type="button" data-related-kind="archivos">Inspeccionar entregables</button></div></li></ul>'
      ],
      agenda: [
        "Agenda",
        '<ul class="related-list"><li><a class="related-object-link" href="' +
          open("agenda", workRecordId(work, "AGENDA", "2307-0800")) +
          '"><strong>23 jul · 08:00</strong></a><span>Levantamiento · GNSS 02 · Vehículo 01</span><div class="related-links"><button type="button" data-related-kind="tareas">Inspeccionar tarea</button></div></li><li><a class="related-object-link" href="' +
          open("agenda", workRecordId(work, "AGENDA", "2507-0900")) +
          '"><strong>25 jul · 09:00</strong></a><span>Reserva por confirmar · conflicto detectado</span><div class="related-links"><button type="button" data-related-kind="aprobaciones">Inspeccionar conflicto</button></div></li></ul>'
      ],
      tramites: tramitesView,
      archivos: [
        "Archivos",
        '<ul class="related-list"><li><a class="related-object-link" href="' +
          open("archivos", workRecordId(work, "FILE", "CROQUIS-REV03")) +
          '"><strong>Croquis_rev03.pdf</strong></a><span>OneDrive / ' +
          code +
          ' / ' +
          escapeHtml(work.id) +
          ' / 05-PRESENTACIONES</span><div class="related-links"><button type="button" data-related-kind="actividad">Inspeccionar evento</button></div></li><li><a class="related-object-link" href="' +
          open("archivos", workRecordId(work, "FOLDER", "ROOT")) +
          '"><strong>' +
          relations.archivos +
          ' elementos vinculados</strong></a><span>Binarios exclusivos en OneDrive; metadatos atribuidos a ' +
          escapeHtml(work.id) +
          "</span></li></ul>"
      ],
      aprobaciones: [
        "Aprobaciones",
        '<ul class="related-list"><li><a class="related-object-link" href="' +
          open("aprobaciones", workRecordId(work, "APPROVAL", "ARCHIVO")) +
          '"><strong>Archivar versión sustituida</strong></a><span>Pendiente · solicitó Carlos Vega</span><div class="related-links"><button type="button" data-related-kind="archivos">Inspeccionar archivo</button></div></li><li><a class="related-object-link" href="' +
          open("aprobaciones", workRecordId(work, "APPROVAL", "IA")) +
          '"><strong>Aplicar propuesta de IA</strong></a><span>Revisión humana requerida</span><div class="related-links"><button type="button" data-related-kind="tareas">Inspeccionar tareas</button></div></li></ul>'
      ],
      actividad: [
        "Actividad",
        '<ul class="related-list"><li><a class="related-object-link" href="' +
          open("historial", workRecordId(work, "EVENT", "ESTADO")) +
          '"><strong>Estado interno actualizado</strong></a><span>Hoy · 08:12 · Laura Mora</span></li><li><a class="related-object-link" href="' +
          open("archivos", workRecordId(work, "FILE", "CROQUIS-REV03")) +
          '"><strong>Archivo vinculado desde OneDrive</strong></a><span>Hoy · 07:44</span><div class="related-links"><button type="button" data-related-kind="archivos">Inspeccionar archivo</button></div></li></ul>'
      ],
      reportes: [
        "Reportes",
        '<ul class="related-list"><li><a class="related-object-link" href="' +
          open("reportes", workRecordId(work, "REPORT", "RESUMEN")) +
          '"><strong>Resumen ejecutivo</strong></a><span>PDF · fecha de corte hoy</span><div class="related-links"><button type="button" data-related-kind="datos">Inspeccionar datos</button></div></li><li><a class="related-object-link" href="' +
          open("reportes", workRecordId(work, "REPORT", "CONTROL")) +
          '"><strong>Control de trabajo</strong></a><span>Excel · gestiones, tareas y agenda</span><div class="related-links"><button type="button" data-related-kind="gestiones">Inspeccionar gestiones</button></div></li></ul>'
      ],
      historial: [
        "Historial",
        '<ul class="related-list"><li><a class="related-object-link" href="' +
          open("historial", workRecordId(work, "EVENT", "CREACION")) +
          '"><strong>Trabajo creado manualmente</strong></a><span>' +
          escapeHtml(project.code + " / " + work.id) +
          ' · 18 jul · Laura Mora</span></li><li><a class="related-object-link" href="' +
          open("historial", workRecordId(work, "EVENT", "AUDITORIA")) +
          '"><strong>' +
          relations.historial +
          ' eventos auditables</strong></a><span>Trabajo, actor, UTC, estado anterior y correlación</span><div class="related-links"><button type="button" data-related-kind="actividad">Inspeccionar actividad</button></div></li></ul>'
      ]
    };
    return views[kind] || views.actividad;
  }

  function showRelatedInspector(chatter, kind) {
    var inspector = chatter.querySelector("[data-related-inspector]");
    var view = relatedView(kind, chatter.getAttribute("data-project-code"), chatter.getAttribute("data-project-work-id"));
    var filter = chatter.querySelector("[data-related-filter]");
    if (filter) filter.value = kind;
    inspector.querySelector("[data-related-title]").textContent = view[0];
    inspector.querySelector("[data-related-content]").innerHTML = view[1];
    inspector.hidden = false;
  }

  function closeRelatedInspector(chatter) {
    if (!chatter) return false;
    var inspector = chatter.querySelector("[data-related-inspector]");
    if (!inspector || inspector.hidden) return false;
    inspector.hidden = true;
    var filter = chatter.querySelector("[data-related-filter]");
    if (filter) {
      filter.value = "";
      filter.focus();
    }
    return true;
  }

  function proposeFiles(chatter, files) {
    var items = Array.from(files || []).slice(0, 6);
    if (!items.length) return;
    var names = items.map(function (file) {
      return file.name;
    });
    var firstName = names[0].toLowerCase();
    var suggested = /\.(dwg|dxf)$/.test(firstName) ? "04-ARCHIVO DWG" : /\.(csv|txt|zip)$/.test(firstName) ? "03-DATOS DEL LEVANTAMIENTO" : "05-PRESENTACIONES";
    var suggestedType = /\.(dwg|dxf)$/.test(firstName) ? "Archivo CAD" : /\.(csv|txt|zip)$/.test(firstName) ? "Datos de campo" : "Documento técnico";
    var workId = chatter.getAttribute("data-project-work-id");
    var host = chatter.querySelector("[data-file-proposal-host]");
    host.innerHTML =
      '<article class="file-classification-proposal" data-file-proposal><strong>' +
      escapeHtml(names.join(", ")) +
      '</strong><p>Archivo detectado en el compositor. La IA propone tipo documental, relación y carpeta por nombre/extensión; revise los tres campos. Nada salió del dispositivo. Publicar confirma la carga simulada.</p><div class="file-classification-fields"><label>Tipo documental sugerido<select data-file-document-type><option' +
      (suggestedType === "Documento técnico" ? " selected" : "") +
      '>Documento técnico</option><option' +
      (suggestedType === "Archivo CAD" ? " selected" : "") +
      '>Archivo CAD</option><option' +
      (suggestedType === "Datos de campo" ? " selected" : "") +
      '>Datos de campo</option><option>Correspondencia</option></select></label><label>Vincular con<select data-file-relation><option selected>Trabajo activo · ' +
      escapeHtml(workId) +
      '</option><option>Contratación completa</option><option>Gestión activa</option><option>Tarea seleccionada</option></select></label><label>Carpeta OneDrive sugerida<select data-file-destination><option' +
      (suggested === "01-ESTUDIO PREVIO" ? " selected" : "") +
      '>01-ESTUDIO PREVIO</option><option' +
      (suggested === "02-PLANOS RELACIONADOS" ? " selected" : "") +
      '>02-PLANOS RELACIONADOS</option><option' +
      (suggested === "03-DATOS DEL LEVANTAMIENTO" ? " selected" : "") +
      '>03-DATOS DEL LEVANTAMIENTO</option><option' +
      (suggested === "04-ARCHIVO DWG" ? " selected" : "") +
      '>04-ARCHIVO DWG</option><option' +
      (suggested === "05-PRESENTACIONES" ? " selected" : "") +
      '>05-PRESENTACIONES</option></select></label></div><div class="file-proposal-actions"><button class="button ghost" type="button" data-file-action="discard">Descartar</button><button class="button secondary" type="button" data-file-action="analyze">Preguntar a IA</button></div></article>';
    host.dataset.fileNames = names.join(", ");
  }

  document.addEventListener("click", function (event) {
    var target = event.target.closest("button, a");
    if (!target) return;

    if (target.matches("[data-scroll-chatter]")) {
      var chatterTarget = document.getElementById("project-activity");
      if (chatterTarget) chatterTarget.scrollIntoView({ behavior: "smooth", block: "start" });
      return;
    }

    if (target.matches("[data-related-kind]")) {
      var relatedChatter = target.closest("[data-project-chatter]");
      showRelatedInspector(relatedChatter, target.getAttribute("data-related-kind"));
      return;
    }

    if (target.matches("[data-related-close]")) {
      var closeRelatedChatter = target.closest("[data-project-chatter]");
      closeRelatedInspector(closeRelatedChatter);
      return;
    }

    if (target.matches("[data-file-action]")) {
      var fileProposal = target.closest("[data-file-proposal]");
      var fileHost = fileProposal.parentElement;
      var proposalChatter = target.closest("[data-project-chatter]");
      var fileAction = target.getAttribute("data-file-action");
      if (fileAction === "discard") {
        fileHost.innerHTML = "";
        return;
      }
      var destination = fileProposal.querySelector("[data-file-destination]").value;
      if (fileAction === "analyze") {
        var documentType = fileProposal.querySelector("[data-file-document-type]").value;
        var relation = fileProposal.querySelector("[data-file-relation]").value;
        fileProposal.querySelector("p").textContent = "Sugerencia explicada: nombre y extensión apuntan a “" + documentType + "”, vinculado con “" + relation + "” y guardado en “" + destination + "”. Cambie cualquier campo; Publicar será la confirmación humana y la IA no cargará por sí sola.";
        showToast("Clasificación explicada", "La decisión sigue pendiente hasta pulsar Publicar.");
        return;
      }
    }

    if (target.matches("[data-chatter-command]")) {
      var commandChatter = target.closest("[data-project-chatter]");
      var commandInput = commandChatter.querySelector("[data-chatter-input]");
      commandInput.value = target.getAttribute("data-chatter-command") + " ";
      commandChatter.querySelector("[data-chatter-command-menu]").hidden = true;
      commandInput.focus();
      return;
    }

    if (target.matches("[data-chatter-submit]")) {
      var submitChatter = target.closest("[data-project-chatter]");
      var submitInput = submitChatter.querySelector("[data-chatter-input]");
      var submitValue = submitInput.value.trim();
      var submitFileProposal = submitChatter.querySelector("[data-file-proposal]");
      if (!submitValue && !submitFileProposal) {
        submitInput.focus();
        return;
      }
      if (submitFileProposal) {
        var submitFileHost = submitFileProposal.parentElement;
        var submitDestination = submitFileProposal.querySelector("[data-file-destination]").value;
        var submitDocumentType = submitFileProposal.querySelector("[data-file-document-type]").value;
        var submitRelation = submitFileProposal.querySelector("[data-file-relation]").value;
        appendChatterEvent(
          submitChatter,
          "Archivo publicado por Laura Mora",
          submitFileHost.dataset.fileNames + " · " + submitDocumentType + " · " + submitRelation + " → " + submitDestination + ". En el producto se cargaría a OneDrive y la plataforma guardaría solo metadatos.",
          "Carga OneDrive simulada"
        );
        submitFileHost.innerHTML = "";
      }
      if (submitValue) {
        var isCommand = submitValue.startsWith("/");
        var commandType = isCommand ? submitValue.split(/\s+/)[0].replace(/^\//, "") : "";
        appendChatterEvent(
          submitChatter,
          isCommand ? "Creación de " + commandType + " confirmada por Laura Mora" : "Anotación de Laura Mora",
          isCommand ? submitValue + " · creación simulada tras confirmación humana; la acción real quedaría auditada." : submitValue,
          isCommand ? "Comando publicado" : "Anotación"
        );
      }
      submitInput.value = "";
      submitChatter.querySelector("[data-chatter-command-menu]").hidden = true;
      showToast("Publicación confirmada", "Simulación local: no se guardó información ni se transfirió ningún archivo real.");
      submitInput.focus();
      return;
    }

    if (target.matches("[data-ai-command]")) {
      assistantInput.value = target.getAttribute("data-ai-command") + " ";
      assistantCommandMenu.hidden = true;
      assistantInput.focus();
      return;
    }

    if (target.matches("[data-ai-proposal]")) {
      var action = target.getAttribute("data-ai-proposal");
      if (action === "review") {
        appendAssistantMessage("is-ai", "<strong>Lista para revisión humana</strong><p>Se abriría el formulario con los campos propuestos. Guardar o solicitar aprobación seguirá siendo una decisión explícita.</p>");
        showToast("Propuesta preparada", "Ningún dato se modificó automáticamente.");
      } else {
        appendAssistantMessage("is-ai", "<strong>Propuesta descartada</strong><p>No se realizó ningún cambio.</p>");
      }
      target.closest(".assistant-proposal").querySelectorAll("button").forEach(function (button) {
        button.disabled = true;
      });
      return;
    }

    if (target.matches("[data-wizard]")) {
      wizardStep = Math.min(5, Math.max(1, wizardStep + (target.getAttribute("data-wizard") === "next" ? 1 : -1)));
      render();
      main.focus();
      return;
    }

    if (target.matches("[data-create-project]")) {
      showToast("Contratación y Trabajos listos", "En la aplicación real se validarán como entidades separadas y quedarán auditados.");
      window.setTimeout(function () {
        window.location.hash = "proyecto?id=JBC-2026-0042&work=TR-0042-01&tab=resumen";
      }, 500);
      return;
    }

    if (target.matches("[data-toast]")) {
      showToast(target.getAttribute("data-toast"));
      return;
    }

    if (target.matches("[data-state-reset]")) {
      currentState = "normal";
      statePicker.value = "normal";
      render();
      return;
    }

    if (target.matches("[data-accent-reset]")) {
      setAccent("#0f766e", target);
      return;
    }

    if (target.matches("[data-accent]")) {
      setAccent(target.getAttribute("data-accent"), target);
      return;
    }

    if (target.matches("[data-theme-choice]")) {
      setTheme(target.getAttribute("data-theme-choice"), target);
      return;
    }

    if (target.closest(".more-sheet") && target.tagName === "A") closeMoreSheet();
  });

  document.addEventListener("change", function (event) {
    var relatedFilter = event.target.closest("[data-related-filter]");
    if (relatedFilter) {
      var relatedChatter = relatedFilter.closest("[data-project-chatter]");
      if (!relatedFilter.value) {
        relatedChatter.querySelector("[data-related-inspector]").hidden = true;
        return;
      }
      showRelatedInspector(relatedChatter, relatedFilter.value);
      return;
    }
    var fileInput = event.target.closest("[data-chatter-file-input]");
    if (fileInput) {
      proposeFiles(fileInput.closest("[data-project-chatter]"), fileInput.files);
      return;
    }
    var select = event.target.closest("[data-project-nav-select]");
    if (!select) return;
    window.location.hash =
      "proyecto?id=" +
      encodeURIComponent(select.getAttribute("data-project-id")) +
      "&work=" +
      encodeURIComponent(select.getAttribute("data-project-work-id")) +
      "&tab=" +
      encodeURIComponent(select.value);
  });

  document.addEventListener("input", function (event) {
    var chatterInput = event.target.closest("[data-chatter-input]");
    if (!chatterInput) return;
    var chatter = chatterInput.closest("[data-project-chatter]");
    var menu = chatter.querySelector("[data-chatter-command-menu]");
    var query = chatterInput.value.trim().toLowerCase();
    var show = query.startsWith("/") && !/\s/.test(query);
    var visible = 0;
    menu.querySelectorAll("[data-chatter-command]").forEach(function (button) {
      var matches = show && button.getAttribute("data-chatter-command").startsWith(query);
      button.hidden = !matches;
      if (matches) visible += 1;
    });
    menu.hidden = !show || visible === 0;
  });

  document.addEventListener("dragover", function (event) {
    var dropzone = event.target.closest("[data-composer-drop-target]");
    if (!dropzone) return;
    event.preventDefault();
    dropzone.classList.add("is-dragging");
    if (event.dataTransfer) event.dataTransfer.dropEffect = "copy";
  });

  document.addEventListener("dragleave", function (event) {
    var dropzone = event.target.closest("[data-composer-drop-target]");
    if (!dropzone || dropzone.contains(event.relatedTarget)) return;
    dropzone.classList.remove("is-dragging");
  });

  document.addEventListener("drop", function (event) {
    var dropzone = event.target.closest("[data-composer-drop-target]");
    if (!dropzone) return;
    event.preventDefault();
    dropzone.classList.remove("is-dragging");
    proposeFiles(dropzone.closest("[data-project-chatter]"), event.dataTransfer && event.dataTransfer.files);
  });

  window.addEventListener("hashchange", function () {
    wizardStep = 1;
    render();
    main.focus();
  });

  statePicker.addEventListener("change", function () {
    currentState = statePicker.value;
    render();
    main.focus();
  });

  moreButton.addEventListener("click", openMoreSheet);
  closeSheetButton.addEventListener("click", closeMoreSheet);
  sheetBackdrop.addEventListener("click", closeMoreSheet);
  assistantLauncher.addEventListener("click", function () {
    if (assistantPanel.classList.contains("is-open")) closeAssistant();
    else openAssistant();
  });
  assistantClose.addEventListener("click", function () {
    closeAssistant();
  });
  sidebarToggle.addEventListener("click", function () {
    setSidebarCompact(!sidebarCompact);
  });

  assistantForm.addEventListener("submit", function (event) {
    event.preventDefault();
    var submittedValue = assistantInput.value;
    submitAssistantMessage(submittedValue);
    if (submittedValue.trim()) {
      assistantInput.value = "";
      assistantCommandMenu.hidden = true;
    }
    assistantInput.focus();
  });

  assistantInput.addEventListener("input", function () {
    var query = assistantInput.value.trim().toLowerCase();
    var showCommands = query.startsWith("/") && !/\s/.test(query);
    var visible = 0;
    assistantCommandMenu.querySelectorAll("[data-ai-command]").forEach(function (button) {
      var match = showCommands && button.getAttribute("data-ai-command").startsWith(query);
      button.hidden = !match;
      if (match) visible += 1;
    });
    assistantCommandMenu.hidden = !showCommands || visible === 0;
  });

  assistantInput.addEventListener("keydown", function (event) {
    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault();
      assistantForm.requestSubmit();
    }
  });

  profileButton.addEventListener("click", function () {
    var expanded = profileButton.getAttribute("aria-expanded") === "true";
    profileButton.setAttribute("aria-expanded", String(!expanded));
    profilePopover.hidden = expanded;
  });

  searchForm.addEventListener("submit", function (event) {
    event.preventDefault();
    window.location.hash = "buscar?q=" + encodeURIComponent(searchInput.value || "San Rafael");
  });

  dismissBanner.addEventListener("click", function () {
    banner.hidden = true;
  });

  document.addEventListener("keydown", function (event) {
    if ((event.ctrlKey || event.metaKey) && event.key.toLowerCase() === "k") {
      event.preventDefault();
      searchInput.focus();
      searchInput.select();
    }
    if (event.altKey && event.key.toLowerCase() === "i") {
      event.preventDefault();
      if (assistantPanel.classList.contains("is-open")) closeAssistant();
      else openAssistant();
    }
    if (event.key === "Escape") {
      if (assistantPanel.classList.contains("is-open") && !assistantCommandMenu.hidden) {
        assistantCommandMenu.hidden = true;
        assistantInput.focus();
        return;
      }
      var openRelatedInspector = document.querySelector("[data-related-inspector]:not([hidden])");
      if (openRelatedInspector && closeRelatedInspector(openRelatedInspector.closest("[data-project-chatter]"))) return;
      var openChatterMenu = document.querySelector("[data-chatter-command-menu]:not([hidden])");
      if (openChatterMenu) {
        openChatterMenu.hidden = true;
        var openChatterInput = openChatterMenu.closest("[data-project-chatter]").querySelector("[data-chatter-input]");
        if (openChatterInput) openChatterInput.focus();
        return;
      }
      if (assistantPanel.classList.contains("is-open")) {
        closeAssistant();
        return;
      }
      closeMoreSheet();
      profilePopover.hidden = true;
      profileButton.setAttribute("aria-expanded", "false");
    }
  });

  function setContextBanner() {
    banner.hidden = false;
    bannerCopy.innerHTML =
      "<strong>Prototipo UX.</strong> Todos los datos son ficticios; ninguna acción se guarda ni contacta servicios.";
  }

  colorSchemeQuery.addEventListener("change", function () {
    if (themePreference === "system") setTheme("system", null, false);
  });

  setTheme(themePreference, null, false);
  setAccent(accentChoice, null, false);
  setSidebarCompact(false);
  setContextBanner();
  render();
})();
