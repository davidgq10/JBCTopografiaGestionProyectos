$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($env:JBC_TEST_DATABASE_URL)) {
  throw 'Defina JBC_TEST_DATABASE_URL para una base PostgreSQL 17 efímera y vacía.'
}

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$psqlArguments = @($env:JBC_TEST_DATABASE_URL, '-X', '-v', 'ON_ERROR_STOP=1')

function Invoke-PsqlFile {
  param(
    [Parameter(Mandatory)]
    [string]$Path,
    [string[]]$Variables = @()
  )

  $arguments = @($psqlArguments)
  foreach ($variable in $Variables) {
    $arguments += @('-v', $variable)
  }
  $arguments += @('-f', $Path)
  & psql @arguments
  if ($LASTEXITCODE -ne 0) {
    throw "Falló psql al ejecutar $Path"
  }
}

Invoke-PsqlFile (Join-Path $repositoryRoot 'supabase/tests/bootstrap_supabase_roles.sql')

Get-ChildItem (Join-Path $repositoryRoot 'supabase/migrations') -Filter '*.sql' |
  Sort-Object Name |
  ForEach-Object { Invoke-PsqlFile $_.FullName }

Invoke-PsqlFile (Join-Path $repositoryRoot 'supabase/tests/run_structure.psql')
Invoke-PsqlFile (Join-Path $repositoryRoot 'supabase/tests/run_rls.psql') @('dec_0103_approved=1')
Invoke-PsqlFile (Join-Path $repositoryRoot 'supabase/tests/45_profile_accent_walking_skeleton.psql')

Write-Output 'DATABASE-VERIFY PASS | fresh migrations + RLS + F3 walking skeleton'
