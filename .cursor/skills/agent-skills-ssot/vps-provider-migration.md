# Skill: VPS-Anbieter wechseln

> Umzugs-Checkliste. Zwei-VPS (`principles.md` §3.0): **Hetzner** = `development/` + `staging/` · **Netcup** = `production/`. Ordner: `/opt/Azubuilder/` (nicht `Lauer-Team`).

## Trigger

- Server-Umzug (Hetzner ↔ Netcup oder neuer Anbieter)

## Voraussetzungen

- Vollständiges Backup (SQL-Dumps + `data/` + `.env`)
- DNS-Zugang
- GHCR-Zugang (Images, ADR 0009)

## Was sichern?

| Was | Wo |
|-----|-----|
| Postgres je Projekt | `pg_dump` aus jeweiligem Projekt-DB-Container |
| Dateien | `data/` (Staging Dummy · Production Live) |
| Config | `.env` pro Environment **und Host** (nie in Git, nie Host→Host kopieren) |
| Plattform | `/opt/_server/production/` (Caddy, Zertifikate) + Git-Klon `repos/Server` |
| Images | GHCR `ghcr.io/azubuilder/<repo-lowercase>:<SHA>` — nicht der Source-Tree |

## Ziel-Layout (gleicher Baum, Env je Host)

```
/opt/
├── _server/production/          ← Plattform (beide Hosts; Hetzner Slim)
├── LauerTeam/                   ← Org-Root, File-Hub .cursor/
│   ├── Apps/<Kurz>App/
│   │   ├── development/         ← nur Hetzner: repos/ + .env + Dummy-data
│   │   ├── staging/             ← nur Hetzner: Compose + .env + Dummy-data
│   │   └── production/          ← nur Netcup: Compose + .env + Live-data
│   └── Domains/<Kurz>Domain/    ← gleiches Env-Schema
├── Company/
├── KiezQuiz/
└── Azubuilder/
```

**Kein** `myAgentsAppAgent`. Sven = `Apps/myAgentsApp/`.

## Restore-Modell

| Host | Wiederherstellen aus |
|------|---------------------|
| **Netcup Production** | GHCR-Images + `docker-compose.yml` + `.env` + `data/` — **kein** App-Source-Tree |
| **Hetzner Staging** | gleich (Dummy-`data/`) |
| **Hetzner Development** | Git-Klone in `repos/` + `.env` + Dummy-`data/` + `--build` |
| **Plattform** | Git-Klon `/opt/_server/production/repos/Server` |

## Schritte

1. Neuen VPS mit Ubuntu 24.04, Docker, Tailscale
2. `/opt/`-Baum anlegen; Production: Compose + `.env` + `data/` aus Backup, Images pullen
3. `.env` **manuell** setzen (nicht vom anderen Host kopieren)
4. Staging/Prod: `docker compose --env-file .env pull && docker compose --env-file .env up -d --no-build`
5. DNS auf neue IP (Cloudflare) — `domain-cloudflare.md`
6. Tailscale-Key — `tailscale-authkey.md`
7. Health: `curl https://myui.lauer.team/api/health`

## Erfolgskriterium

Registrierte Projekt-APIs erreichbar; myUI Health-Check grün; Production ohne `repos/`-App-Code.

## Rollback

| Problem | Lösung |
|---------|--------|
| Migration fehlgeschlagen | Alten VPS weiterbetreiben; DNS zurück |
| Daten unvollständig | Restic-Restore oder Snapshot des alten Servers |

## Verwandt

- `backup-system.md` · `vps-deploy.md` · `ghcr-publish.md` · `post-reboot-check.md`
