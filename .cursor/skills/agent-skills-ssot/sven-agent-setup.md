# Skill: Sven Setup

> Sven = myAgents-app-api + Telegram-Adapter + Agent-Runner. Host: `https://myagents.lauer.team`. Config: `.env`.

## Trigger

- Sven neu einrichten, Bot reparieren, API-Health prüfen

## Voraussetzungen

- Secrets in `.env` des Environments (siehe `.env.example`)
- Maps via Symlinks (`brain/index-agents.md`)
- Staging/Prod: Image in GHCR (ADR 0009)

## Pfade

| Was | Ort |
|-----|-----|
| Staging (Hetzner, image-only) | `/opt/Azubuilder/Apps/myAgentsApp/staging/` — Compose + `.env` + `data/` |
| Development | `/opt/Azubuilder/Apps/myAgentsApp/development/repos/myAgents-app-api/` |
| Production | `/opt/Azubuilder/Apps/myAgentsApp/production/` **nur Netcup** |
| Config | `<env>/.env` (`MYAGENTS_MODEL`, E-Mail-Flags, Secrets) |
| Permissions | `config/agent-permissions.json` im Environment |
| Secrets | `<env>/.env` — `TELEGRAM_*`, `SVEN_API_TOKEN`, optional `CURSOR_API_KEY` |
| Runtime | Docker Compose: `myagents-app-api` + `myagents-app-telegram` (**kein** systemd-Default) |
| API intern | `http://myagents-app-api:8766` |
| API Tailnet | `https://myagents.lauer.team` |

**Kein** `staging/repos/`. File-Hub bleibt `/opt/Azubuilder/.cursor/` (nicht myAgentsDomain).

## API-Routen (Kern)

| Methode | Pfad | Zweck |
|---------|------|-------|
| GET | `/api/health` | Liveness |
| GET | `/api/sessions?chat_id=` | Session-Status |
| GET | `/api/agent-runs?chat_id=` | Lauf-Historie |
| POST | `/api/message` | Slash/Freitext (Telegram-Adapter) |
| POST | `/api/agent` | Agent-Aufgabe `{chat_id, text}` |
| POST | `/api/agent/interrupt` | Laufenden Agent stoppen (Session bleibt) |
| POST | `/api/agent/end` | Session beenden (Cursor-Kontext weg) |
| POST | `/api/agent/new` | Frische Session vorbereiten |
| POST | `/api/agent/approve` | Pending freigeben `{run_id}` |

**Telegram:** `/agent_interrupt` · `/agent_end` · `/agent_new` · `/agent_status`.

Cockpit: myUI-app-api → myAgents-app-api (Header `X-MyAgents-Token`).

## Start

### Staging (Hetzner, image-only)

```bash
cd /opt/Azubuilder/Apps/myAgentsApp/staging
# MYAGENTS_APP_IMAGE_TAG=<voller SHA> in .env
docker compose --env-file .env pull
docker compose --env-file .env up -d --no-build
```

### Development

```bash
cd /opt/Azubuilder/Apps/myAgentsApp/development/repos/myAgents-app-api
git pull --ff-only
docker compose --env-file ../../.env up -d --build
```

### Production (Netcup)

Wie Staging: `cd …/production` → `pull && up -d --no-build`. Kein `--build`, kein App-Git.

## Tests

Aus dem **Development-Repo** (nicht auf Staging/Prod-Image-only):

```bash
.venv/bin/python -m myagents_api.test_agent_runner
.venv/bin/python -m myagents_api.test_agent_permissions
.venv/bin/python -m myagents_lib.test_email_imap
.venv/bin/python -m myagents_api.test_email
```

## Erfolgskriterium

- Container `myagents-app-api` + `myagents-app-telegram` healthy
- `curl -s -H "X-MyAgents-Token: …" http://127.0.0.1:8766/api/health` → ok
- Telegram `/help` · Freitext-Agent · Cockpit-Chat

## Rollback

| Problem | Lösung |
|---------|--------|
| Bot antwortet nicht | `docker compose --env-file .env logs myagents-app-telegram`; Token/`.env` |
| Chat-Fassade down | `docker compose --env-file .env restart myagents-app-api` |
| Staging/Prod kaputt | vorheriges SHA in `.env` + `pull && up -d --no-build` |
| Dev kaputt | Git rollback im Repo + `--build` |

## Verwandt

- `vps-deploy.md` · `ghcr-publish.md` · `brain/index-agents.md`
- Repo-ADRs: `docs/adr/0001-sven-als-steuerzentrale.md` · `docs/adr/0002-agent-permissions.md`
