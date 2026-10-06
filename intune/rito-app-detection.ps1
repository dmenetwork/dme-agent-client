$MinimumVersion = [version]'2026.9.22'
$programFiles = if ($env:ProgramW6432) { $env:ProgramW6432 } else { $env:ProgramFiles }
$exe = Join-Path $programFiles 'dME\Agent\rito-service.exe'

if (-not (Test-Path -LiteralPath $exe)) { exit 1 }

$service = Get-Service -Name 'dmeAgentService' -ErrorAction SilentlyContinue
if ($null -eq $service) { exit 1 }
if ($service.StartType -eq 'Disabled') { exit 1 }

# The leading dotted number of the file version ("2026.9.22", or "10.0.1 (build...)" style).
$fileVersion = "$((Get-Item -LiteralPath $exe).VersionInfo.FileVersion)"
if ($fileVersion -notmatch '^\s*(\d+(\.\d+){1,3})') { exit 1 }
$installed = [version]$Matches[1]
if ($installed -lt $MinimumVersion) { exit 1 }

Write-Output "Rito Agent $installed installed (service $($service.Status))"
exit 0
