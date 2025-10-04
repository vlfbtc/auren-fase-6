param([int]$UserId = 1, [int]$Month = 9, [int]$Year = 2025)

$envPath = Join-Path $PSScriptRoot "..\..\..\.env.ps1"
if (Test-Path $envPath) { . $envPath } else { throw "Arquivo .env.ps1 não encontrado. Rode 01-login.ps1 antes." }

$BASE = $env:BASE
$TOKEN = $env:TOKEN
$auth = @{ "Authorization" = "Bearer $TOKEN" }

Write-Host "Monthly balance:"
Invoke-RestMethod -Method Get -Uri "$BASE/api/v1/users/$UserId/reports/monthly-balance?month=$Month&year=$Year" -Headers $auth | ConvertTo-Json

Write-Host "`nDB Summary (JSON):"
Invoke-RestMethod -Method Get -Uri "$BASE/api/v1/users/$UserId/reports/db-summary" -Headers $auth | ConvertTo-Json

Write-Host "`nCategory report:"
Invoke-RestMethod -Method Get -Uri "$BASE/api/v1/users/$UserId/reports/category-report" -Headers $auth | ConvertTo-Json
