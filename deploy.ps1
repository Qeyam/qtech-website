<#
  QTECH - Deploy su Netlify con un solo comando.

  Uso:
      .\deploy.ps1             -> pubblica in PRODUZIONE (https://qtech-services.netlify.app)
      .\deploy.ps1 -Preview    -> crea un deploy di ANTEPRIMA (URL temporaneo, non tocca il sito online)

  Pubblica solo i file del sito (index.html, netlify.toml).
  I file di sviluppo (node_modules, package.json, ask.js) vengono esclusi automaticamente.
#>
param([switch]$Preview)

$ErrorActionPreference = 'Stop'
$root  = $PSScriptRoot
$stage = Join-Path $env:TEMP 'qtech-deploy'

# 1) Cartella di staging pulita
if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }
New-Item -ItemType Directory -Path $stage | Out-Null

Copy-Item (Join-Path $root 'index.html')   $stage
Copy-Item (Join-Path $root 'netlify.toml') $stage -ErrorAction SilentlyContinue

Write-Host "`nFile che verranno pubblicati:" -ForegroundColor Cyan
Get-ChildItem $stage | Select-Object Name, Length | Format-Table -AutoSize

# 2) Comando netlify
$cliArgs = @(
  'deploy',
  '--dir', $stage,
  '--no-build',
  '--message', "Deploy $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
)
if (-not $Preview) { $cliArgs += '--prod' }

$netlify = Join-Path $env:APPDATA 'npm\netlify.cmd'
Set-Location $root
& $netlify @cliArgs
