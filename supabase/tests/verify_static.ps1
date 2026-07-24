[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$testDirectory = $PSScriptRoot
$repositoryRoot = (Resolve-Path (Join-Path $testDirectory '..\..')).Path
$migrationDirectory = Join-Path $repositoryRoot 'supabase\migrations'
$manifestPath = Join-Path $testDirectory '00_surface_manifest.sql'
$runnerPath = Join-Path $testDirectory 'run_rls.psql'
$caseDataPath = Join-Path $testDirectory '30_case_data.sql'
$functionalMigrationPath = Join-Path $migrationDirectory '20260723091900_f2_functional_rls_dec_0103.sql'

$requiredFiles = @(
  '00_surface_manifest.sql',
  '10_rls_structure.sql',
  '20_rls_matrix.sql',
  '30_case_data.sql',
  'run_structure.psql',
  'run_rls.psql',
  'README.md'
)

$missingFiles = $requiredFiles | Where-Object {
  -not (Test-Path -LiteralPath (Join-Path $testDirectory $_) -PathType Leaf)
}

if ($missingFiles.Count -gt 0) {
  throw "Faltan archivos del arnés: $($missingFiles -join ', ')"
}

$migrationSql = Get-ChildItem -LiteralPath $migrationDirectory -Filter '*.sql' -File |
  Sort-Object Name |
  ForEach-Object { Get-Content -LiteralPath $_.FullName -Raw }

$migrationTables = [regex]::Matches(
  ($migrationSql -join "`n"),
  '(?im)^create\s+table\s+public\.([a-z_][a-z0-9_]*)'
) | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique

$manifestSql = Get-Content -LiteralPath $manifestPath -Raw
$manifestTables = [regex]::Matches(
  $manifestSql,
  "(?m)^\s*\('([a-z_][a-z0-9_]*)',\s*'table'"
) | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique

$surfaceDiff = Compare-Object -ReferenceObject $migrationTables -DifferenceObject $manifestTables
if ($surfaceDiff) {
  $details = $surfaceDiff | ForEach-Object { "$($_.SideIndicator) $($_.InputObject)" }
  throw "Inventario distinto de migraciones: $($details -join '; ')"
}

$publicViews = [regex]::Matches(
  ($migrationSql -join "`n"),
  '(?im)^create\s+(?:materialized\s+)?view\s+public\.([a-z_][a-z0-9_]*)'
)
$publicFunctions = [regex]::Matches(
  ($migrationSql -join "`n"),
  '(?im)^create\s+(?:or\s+replace\s+)?function\s+public\.([a-z_][a-z0-9_]*)'
)

if ($publicViews.Count -gt 0 -or $publicFunctions.Count -gt 0) {
  throw 'Existe una vista o función en public; debe inventariarse y revisarse antes de continuar.'
}

$runnerSql = Get-Content -LiteralPath $runnerPath -Raw
if ($runnerSql -notmatch "\\set\s+dec_0103_approved\s+'0'") {
  throw 'run_rls.psql no conserva el valor fail-closed predeterminado para DEC-0103.'
}
if ($runnerSql -notmatch '\\ir\s+10_rls_structure\.sql' -or $runnerSql -notmatch '\\ir\s+20_rls_matrix\.sql') {
  throw 'run_rls.psql no enlaza estructura y matriz funcional.'
}

$caseDataSql = Get-Content -LiteralPath $caseDataPath -Raw
if (-not (Test-Path -LiteralPath $functionalMigrationPath -PathType Leaf)) {
  throw 'Falta la migración funcional de DEC-0103.'
}
if ($caseDataSql -notmatch '(?im)^\s*insert\s+into\s+rls_test_cases') {
  throw '30_case_data.sql no contiene los casos funcionales aprobados de DEC-0103.'
}
if ($caseDataSql -notmatch 'DEC-0103 aprobada') {
  throw '30_case_data.sql no registra la decisión que autoriza sus casos.'
}

[pscustomobject]@{
  Result = 'RLS-STATIC PASS'
  MigrationTables = $migrationTables.Count
  ManifestTables = $manifestTables.Count
  PublicViews = $publicViews.Count
  PublicFunctions = $publicFunctions.Count
  DecisionGateDefault = 0
  FunctionalCasesFrozen = 'generated-and-gated'
} | Format-List
