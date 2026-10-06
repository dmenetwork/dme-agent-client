# Rito Agent — Microsoft Intune Win32 app detection script.
#
# Use it as the Rito Agent app's detection rule (Apps > Windows > Rito Agent > Properties >
# Detection rules > "Use a custom detection script") instead of a file-exists rule.
#
# Why: a file rule keeps reporting "installed" when someone deletes the agent's Windows
# service and leaves the files behind, so Intune never repairs a device whose agent is dead.
# This script reports the app as installed only when the files AND the service registration
# are present, the service is not disabled, and the installed version is at least
# $MinimumVersion. Anything else makes Intune run the install command again, and the installer
# (rito.exe --unattended-update) re-registers and starts the service.
#
# Intune contract: detected = exit code 0 AND something written to STDOUT. Not detected = no
# STDOUT (the exit code is then irrelevant). Intune runs it as SYSTEM.
#
# Settings in Intune: "Run script as 32-bit process on 64-bit clients" = No,
# "Enforce script signature check" = No.

# Set this to the version of the rito.exe you uploaded to Intune. Devices update themselves,
# so a device reporting a NEWER version is still detected.
$MinimumVersion = [version]'2026.9.22'

# The 64-bit Program Files even if Intune ever runs this in a 32-bit host.
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

# A stopped (not disabled) service is deliberately still "installed": the service restarts
# itself through its recovery settings, and the auto-updater stops it for a few seconds during
# every update. Reinstalling in that window would fight the updater.
Write-Output "Rito Agent $installed installed (service $($service.Status))"
exit 0
