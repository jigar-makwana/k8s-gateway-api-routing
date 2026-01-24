param(
  [string]$Image = "echo-api:0.1.0"
)

$ErrorActionPreference = "Stop"

$AppDir = $null
if (Test-Path "apps/echo-api") { $AppDir = "apps/echo-api" }
elseif (Test-Path "app/echo-api") { $AppDir = "app/echo-api" }

if (-not $AppDir) { throw "Cannot find app directory (apps/echo-api or app/echo-api)" }

Write-Host "Building image: $Image"
docker build -t $Image $AppDir
if ($LASTEXITCODE -ne 0) { throw "docker build failed (exit $LASTEXITCODE)" }
