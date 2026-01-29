# Generate secrets for Railway deployment
Write-Host "Generating secrets..." -ForegroundColor Green
Write-Host ""

$reg = -join ((48..57) + (97..102) | Get-Random -Count 64 | ForEach-Object {[char]$_})
$mac = -join ((48..57) + (97..102) | Get-Random -Count 64 | ForEach-Object {[char]$_})
$form = -join ((48..57) + (97..102) | Get-Random -Count 64 | ForEach-Object {[char]$_})
$masenc = -join ((48..57) + (97..102) | Get-Random -Count 64 | ForEach-Object {[char]$_})
$massign = -join ((48..57) + (97..102) | Get-Random -Count 64 | ForEach-Object {[char]$_})

Write-Host "REGISTRATION_SHARED_SECRET=$reg"
Write-Host "MACAROON_SECRET_KEY=$mac"
Write-Host "FORM_SECRET=$form"
Write-Host "MAS_ENCRYPTION_SECRET=$masenc"
Write-Host "MAS_SIGNING_KEY=$massign"
