param(
  [string]$Base = "http://localhost:8080",
  [string]$Email = "alice@example.net",
  [string]$Password = "test123"
)

$loginUrl = "$Base/api/v1/auth/login"
Write-Host "Login em $loginUrl"

$bodyLogin = @{ email = $Email; password = $Password } | ConvertTo-Json

try {
  $resp = Invoke-WebRequest -Method Post -Uri $loginUrl -Headers @{ "Content-Type" = "application/json" } -Body $bodyLogin -ErrorAction Stop
  $raw = $resp.Content
  if (-not $raw) { throw "Resposta vazia do login." }
  $json = $raw | ConvertFrom-Json
  $token = $json.accessToken
  if (-not $token) { $token = $json.token }
  if (-not $token) { throw "Sem accessToken/token. Body: $raw" }
} catch {
  if ($_.Exception.Response -ne $null) {
    $status = $_.Exception.Response.StatusCode.value__
    $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
    $body   = $reader.ReadToEnd()
    throw "Falha ao logar. Status=$status Body=$body"
  } else {
    throw "Falha ao logar: $($_.Exception.Message)"
  }
}

Write-Host "Login OK. Token salvo em auren\.env.ps1"
$envFile = Join-Path $PSScriptRoot "..\..\..\.env.ps1"
@"
# Gerado por 01-login.ps1
`$env:BASE = '$Base'
`$env:TOKEN = '$token'
"@ | Out-File -Encoding UTF8 -Force $envFile
