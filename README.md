# dME Agent — production release feed

Public, releases-only mirror for **dME DLP Agent** auto-updates. This repo carries
**production releases only**. Installed production agents read
`releases/latest/download/latest.json` (Windows) and `latest-mac.json` (macOS) from here —
no token, no API.

Source code lives in the private `dme-agent` repo, which also holds the QA release lane
(QA builds never land here). Releases are published via `installer/publish.ps1` (Windows)
and `installer/publish-mac.sh` / `installer/release-mac.sh` (macOS).
