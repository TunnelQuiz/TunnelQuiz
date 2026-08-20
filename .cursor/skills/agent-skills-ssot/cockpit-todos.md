# Skill: Cockpit & Todos (Postgres)

> Cockpit = myUI-app-web + myUI-app-api. **Todos** = SSOT in Postgres von **myProjectsDomain** — kein Markdown-Snapshot.

## Trigger

- User: Todo anlegen, `/todo`, Cockpit öffnen, Routinen bearbeiten
- Deploy nach Änderungen an Domain-/App-APIs (`vps-deploy.md`)

## Voraussetzungen

- myProjects-domain-api läuft (Hetzner `:8810`)
- Live-Fakten über BFF: `https://myui.lauer.team`
- Tailscale auf Client-Gerät (Web-UI)

## Schritte

### 1. Setup (Hetzner Development)

```bash
cd /opt/Azubuilder/Domains/myProjectsDomain/development/repos/myProjects-domain-api
docker compose --env-file ../../.env up -d --build
```

Staging/Prod: kein `repos/` — `cd …/<env>` → `docker compose --env-file .env pull && up -d --no-build`.

### 2. Todos für Agenten (API)

Hetzner (direkt):

```bash
curl -s 'http://127.0.0.1:8810/api/reminders?status=active&limit=50'
curl -s 'http://127.0.0.1:8810/api/reminders/<id>'
curl -s 'http://127.0.0.1:8810/api/reminders/due'
```

Öffentlich (BFF): `https://myui.lauer.team/api/reminders…`

### 3. Sven (Telegram)

```
/todo Titel | 2026-07-01
/todo list
/todo done | <id>
```

### 4. Nach Code-Änderungen

Siehe `vps-deploy.md`.

## URLs

| Was | URL |
|-----|-----|
| Cockpit | `https://myui.lauer.team/` |
| BFF Health (Hetzner) | `http://127.0.0.1:8820/api/health` |
| Reminders (Hetzner) | `http://127.0.0.1:8810/api/reminders` |

## Dateien

| Was | Development (Hetzner) | Staging / Production |
|-----|----------------------|----------------------|
| Domain-API | `Domains/myProjectsDomain/development/repos/myProjects-domain-api/` | kein `repos/` — Compose + Image |
| GUI | `Apps/myUIApp/development/repos/myUI-app-web/` | kein `repos/` |
| BFF | `Apps/myUIApp/development/repos/myUI-app-api/` | kein `repos/` |
| Todo-Notizen | `Domains/myProjectsDomain/<env>/data/files/todos/` | Staging Dummy · Prod Live (Netcup) |
| Routinen-Knoten | `Domains/myRoutinesDomain/<env>/data/files/routinen/` | Staging Dummy · Prod Live (Netcup) |

Karte: `brain/index-workspace.md`.

## Erfolgskriterium

- Health der Domain-API → ok
- Web-UI lädt im Tailnet
- Todos über API/Sven konsistent mit Postgres

## Rollback

| Problem | Lösung |
|---------|--------|
| API down (Dev) | `docker compose --env-file ../../.env up -d` im Domain-API-Repo |
| API down (Staging/Prod) | `cd …/<env>` → `up -d --no-build` |
| DB-Fehler | Restore aus `/opt/_backups/db-dumps/` — `backup-postgres.md` |

## Verwandt

- `vps-deploy.md` · `mc-hermetic-nodes.md` · `brain/index-workspace.md`
