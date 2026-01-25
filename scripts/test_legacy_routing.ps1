param(
  [string]$BaseUrl = "http://localhost:8080"
)

$ErrorActionPreference = "Stop"

function HttpCode($url) {
  $code = & curl.exe -s -o NUL -w "%{http_code}" $url
  return [int]$code
}

$root = HttpCode "$BaseUrl/"
$nginx = HttpCode "$BaseUrl/nginx"

Write-Host "/ -> $root"
Write-Host "/nginx -> $nginx"

if ($root -ne 200) { throw "Expected 200 for / but got $root" }
if ($nginx -ne 200) { throw "Expected 200 for /nginx but got $nginx" }

Write-Host "Legacy routing looks good."
