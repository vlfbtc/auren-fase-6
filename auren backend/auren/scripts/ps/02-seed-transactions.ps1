param([int]$UserId = 1)

$envPath = Join-Path $PSScriptRoot "..\..\..\.env.ps1"
if (Test-Path $envPath) { . $envPath } else { throw "Arquivo .env.ps1 não encontrado. Rode 01-login.ps1 antes." }

$BASE = $env:BASE
$TOKEN = $env:TOKEN
$headers = @{ "Authorization" = "Bearer $TOKEN"; "Content-Type" = "application/json" }

$txs = @(
  @{ description="Salário Setembro"; type="INCOME";  amount=7500.00; date="2025-09-01"; category="Renda" },
  @{ description="Aluguel Setembro"; type="EXPENSE"; amount=2500.00; date="2025-09-05"; category="Moradia" },
  @{ description="Mercado";          type="EXPENSE"; amount=640.45;  date="2025-09-07"; category="Alimentação" },
  @{ description="Conta de Luz";     type="EXPENSE"; amount=320.89;  date="2025-09-08"; category="Moradia" },
  @{ description="Internet";         type="EXPENSE"; amount=120.00;  date="2025-09-09"; category="Serviços" },
  @{ description="Freelance";        type="INCOME";  amount=1500.00; date="2025-09-10"; category="Renda Extra" },
  @{ description="Restaurante";      type="EXPENSE"; amount=180.50;  date="2025-09-12"; category="Alimentação" },
  @{ description="Compra TV";        type="EXPENSE"; amount=3500.00; date="2025-09-15"; category="Eletrônicos" },
  @{ description="Transporte";       type="EXPENSE"; amount=210.00;  date="2025-09-16"; category="Transporte" },
  @{ description="Streaming";        type="EXPENSE"; amount=55.90;   date="2025-09-17"; category="Entretenimento" },
  @{ description="Consultoria";      type="INCOME";  amount=2200.00; date="2025-09-18"; category="Renda Extra" },
  @{ description="Notebook novo";    type="EXPENSE"; amount=4999.99; date="2025-09-20"; category="Eletrônicos" }
)

$createdIds = @()
foreach ($t in $txs) {
  $body = $t | ConvertTo-Json
  try {
    $resp = Invoke-RestMethod -Method Post -Uri "$BASE/api/v1/users/$UserId/transactions" -Headers $headers -Body $body
    $createdIds += $resp.id
    Write-Host "Criada: $($t.description) id=$($resp.id)"
  } catch {
    Write-Warning "Falha ao criar '$($t.description)': $($_.Exception.Message)"
    if ($_.Exception.Response -ne $null) {
      $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
      Write-Host "Resposta: $($reader.ReadToEnd())"
    }
  }
}
Write-Host "IDs criados: $([string]::Join(',', $createdIds))"
