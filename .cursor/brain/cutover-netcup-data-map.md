# Cutover-Datenkarte — Netcup LauerTeam

Stand: 2026-08-18. Live-SSOT wechselt mit den Phasen. Company/KiezQuiz/TunnelQuiz: **nicht Gegenstand** (TunnelQuiz bleibt unter `/opt/Lauer-Team/TunnelQuiz`).

## Hosts

- Hetzner Arbeit: `100.81.68.57` — `/opt/TunnelQuiz/` File-Hub + development/staging
- Netcup Production: `100.65.66.25` (SSH `netcup-ts`) — Altbaum `/opt/Lauer-Team/` (Bindestrich); Ziel `/opt/TunnelQuiz/` (ohne Bindestrich)
- Private Caddy-IP (DNS): `100.92.81.26` (`lauer-private-web`)

## Backup dieser Nacht

Pfad: `/opt/_backups/netcup-cutover-2026-08-18/` (Netcup)

- `db/myos.dump` (1.2M, pg_restore TOC 242) — Live-Fakten God-DB
- `db/sven.dump` `display.dump` `gunsdb.dump` `myguns.dump`
- `env/*.env` — Kopien, nicht Git
- `files/` — myOS-files, Sven, Display, Guns, downloads-token/logos/datenbank
- Counts (real): reminders=53 projects=12 routines=8 runs=15775 run_steps=34173 knowledge_docs=4 agent_instances=5 chat_messages=8 artifacts=1 cursor_quota.usage_snapshot=2991 server_kpi.usage_snapshot=8976; Dateien documents=88 todos=20 routinen=21

## Datenart → Live (genau ein Ort) → Backup → Kopie (kein Live)

| Datenart | Live (Netcup) | Backup 2026-08-18 | weitere Kopie | Löschbar |
|---|---|---|---|---|
| Todos/Projekte | `Domains/myProjectsDomain/production/data/database/` | `db/myos.dump` | Quarantäne-myOS | Quarantäne nach Restic-OK |
| Todo-Dateien | `Domains/myProjectsDomain/production/data/files/todos/` | `files/myOS-files/todos/` | `_TEMP` Lücken | `_TEMP` Dateien ja |
| Dokumente | `Domains/myBrainDomain/production/` | dump + files | `_TEMP` Lücken | `_TEMP` Dateien ja |
| Routinen | `Domains/myRoutinesDomain/production/` | dump + files | `_TEMP` Lücken | `_TEMP` Dateien ja |
| Agent-Instanzen | `Domains/myAgentsDomain/production/` | dump | Quarantäne | Quarantäne nach Restic-OK |
| Quota/KPI | `Domains/myOpsDomain/production/` | dump | Quarantäne | Quarantäne nach Restic-OK |
| Sven Chat/DB | `Apps/myAgentsApp/production/data/database/` | `db/sven.dump` | Quarantäne-Sven | Quarantäne nach Restic-OK |
| Chat myOS (8) | **gedroppt** — Restic-Snapshot `80f5f800` hat Dump | — | — | ✅ |
| artifacts (1) | **gedroppt** — Restic-Snapshot `80f5f800` hat Dump | — | — | ✅ |
| Guns Katalog | `Domains/myGunsDomain/production/data/database/` | `db/gunsdb.dump` | Quarantäne-GunsDB | Quarantäne nach Restic-OK |
| Guns privat | `Apps/myGunsApp/production/data/database/` | `db/myguns.dump` | Quarantäne-myGuns | Quarantäne nach Restic-OK |
| Display | `Apps/myDisplayApp/production/` | dump + files | Quarantäne-Display | Quarantäne nach Restic-OK |
| Downloads ZIP | `Domains/myDownloadsDomain/production/data/files/<token>/` | files/downloads-token | Quarantäne-Download-Links | Quarantäne nach Restic-OK |
| Downloads logos/datenbank | `.../data/files/{logos,datenbank}` | files/downloads-* | Quarantäne | Quarantäne nach Restic-OK |
| File-Hub | `/opt/TunnelQuiz/.cursor` (Git `LauerTeam/LauerTeam`) | GitHub | `/opt/Lauer-Team/.cursor` stale | stale `.cursor` auf Netcup ja |
| Widgets | `Apps/myWidgetsApp/production/` + myOps HTTP | — | — | n/a |
| tempui | `Apps/tempui/production/` | env | Quarantäne-temp-ui | Quarantäne nach Restic-OK |
| TunnelQuiz | `/opt/Lauer-Team/TunnelQuiz` | nicht unser Backup | — | nie in diesem Cutover |
| Company / KiezQuiz | `/opt/Company` `/opt/KiezQuiz` | — | — | unangetastet |

## Image-SHAs (GHCR)

Siehe P3 `.env` `*_IMAGE_TAG`. Quelle: Repo-HEAD 2026-08-18 nach `ghcr.yml`-Push.

## Phasenstatus

- P0–P9: **erledigt 2026-08-18**
- Live-SSOT: `/opt/TunnelQuiz/` auf Netcup (`production/`)
- Backup: `/opt/_backups/netcup-cutover-2026-08-18/`
- Quarantäne (kein SSOT): `/opt/_backups/netcup-myos-quarantine-2026-08-18/`
- GitHub `myOS-backend`: archiviert
- `_TEMP` Dummy-Postgres, File-Hub-Kopie und Nutzerdateien: gelöscht (nur README)
- `/opt/Lauer-Team/` auf Netcup: nur noch `TunnelQuiz` (stale `.cursor`/`.claude` entfernt)
