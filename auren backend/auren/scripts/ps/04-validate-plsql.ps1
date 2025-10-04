param(
  [int]$UserId = 21,
  [int]$Month = 9,
  [int]$Year = 2025,
  [string]$DockerContainer = "oracle-xe"
)

$sqlPath = Join-Path $PSScriptRoot "..\oracle\03-validate-plsql-noninteractive.sql"
if (-not (Test-Path $sqlPath)) {
  throw "Arquivo não encontrado: $sqlPath"
}

docker cp $sqlPath "$DockerContainer`:/tmp/03-validate-plsql-noninteractive.sql" | Out-Null

docker exec -i $DockerContainer bash -lc "sqlplus -s auren_user/auren_pass@//localhost:1521/XEPDB1 @/tmp/03-validate-plsql-noninteractive.sql $UserId $Month $Year" 2>$null | Write-Host
