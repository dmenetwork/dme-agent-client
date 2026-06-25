# dME Agent — release feed

Public, releases-only mirror for **dME DLP Agent** auto-updates. Installed agents read
`releases/latest/download/latest.json` (Windows) and `latest-mac.json` (macOS) from here — no token, no API.

Source code lives in the private `dme-agent` repo. Releases are published via `installer/publish.ps1`
(Windows) and `installer/build-mac.sh` (macOS).
