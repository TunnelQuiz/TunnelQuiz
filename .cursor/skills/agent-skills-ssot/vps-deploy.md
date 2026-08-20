# Skill: VPS deployen

> Zwei-VPS (`principles.md` §3.0–3.5): **Hetzner** = `development/` (repos + `--build`) · `staging/` (image-only). **Netcup** = `production/` (image-only). Images: ADR `.cursor/brain/adr/0009-ghcr-sha-images.md`.

## Trigger

- User: „deployen“, „auf Staging/Production bringen“, „Container neu starten“
- Nach Code-Änderung (GitHub) oder Image-Tag-Wechsel

## Host wählen

| Ziel | Host | Layout | Deploy |
|------|------|--------|--------|
| Arbeit | **Hetzner** (dieser Cursor-Host) | `…/development/repos/` + `.env` + Dummy-`data/` | git pull im Repo + `--build` |
| Test | **Hetzner** | `…/staging/` = `docker-compose.yml` + `.env` + Dummy-`data/` | GHCR-Pull, **kein** App-Git |
| Live | **Netcup** | `…/production/` = Compose + `.env` + Live-`data/` | GHCR-Pull, **kein** App-Git |

**Nie** Projekt-`production/` auf Hetzner. **Nie** `.env` zwischen Hosts kopieren.

## Images (ADR 0009)

| Teil | Wert |
|------|------|
| Registry | `ghcr.io/azubuilder/<repo-lowercase>` |
| Tag | voller Git-SHA in `.env` als `*_IMAGE_TAG` |
| Verboten | `:latest`, `:local`, unversionierte Tags |

Beispiel: `ghcr.io/azubuilder/myui-app-api:${MYUI_IMAGE_TAG}`

---

## Pfad A — Development (Hetzner)

Arbeitsverzeichnis = **Repo**, Env-Datei eine Ebene über `repos/`.

```bash
cd /opt/Azubuilder/Apps/myUIApp/development/repos/myUI-app-api
git pull --ff-only
# *_IMAGE_TAG in ../../.env = SHA von HEAD (nie latest/local)
docker compose --env-file ../../.env up -d --build
curl -sS http://127.0.0.1:8820/api/health
```

| Repo-Beispiel | Befehl |
|---------------|--------|
| Domain-API | `cd …/Domains/<Kurz>Domain/development/repos/<Kurz>-domain-api` |
| App-API | `cd …/Apps/<Kurz>App/development/repos/<Kurz>-app-api` |
| GUI Vite | `docker-compose.dev.yml` **im GUI-Repo**, `--env-file ../../.env` |

Tag setzen (SHA des gezogenen Commits):

```bash
git rev-parse HEAD   # → in ../../.env als z. B. MYUI_IMAGE_TAG=
```

Agent-SSOT: `/opt/Azubuilder/.cursor/` — dort gilt sofort, kein Container-Deploy.

---

## Pfad B — Staging (Hetzner) und Production (Netcup)

**Kein** `git pull` von App-Code. **Kein** `repos/`. **Kein** `--build`.

```bash
cd /opt/Azubuilder/Apps/myAgentsApp/staging   # Netcup: …/<Projekt>/production
# *_IMAGE_TAG=<voller SHA> in .env setzen
docker compose --env-file .env pull
docker compose --env-file .env up -d --no-build
```

Staging-Beispiel (Hetzner): `/opt/Azubuilder/Apps/myAgentsApp/staging/docker-compose.yml`  
Production: analog unter `…/production/` **auf Netcup**.

Voraussetzung: Image liegt in GHCR (`ghcr-publish.md`).

---

## Ausnahme — Plattform `_server`

Git-Klon bleibt: `/opt/_server/production/repos/Server` (Routing-Config = Produkt, `principles.md` §3.0).

```bash
cd /opt/_server/production/repos/Server
git pull --ff-only
# Hetzner (Slim):
docker compose -f docker-compose.yml -f docker-compose.hetzner.yml up -d
# Netcup: ohne hetzner-overlay (siehe Compose-Kommentare)
```

---

## Ports (Loopback)

| Dienst | Port |
|--------|------|
| myProjects-domain-api | 8810 |
| myAgents-domain-api | 8811 |
| myBrain-domain-api | 8812 |
| myUser-domain-api | 8813 |
| myOps-domain-api | 8814 |
| myRoutines-domain-api | 8815 |
| myUI-app-api (BFF) | 8820 |
| myGuns-app-api | 8821 |
| myDownloads-app-api | 8822 |
| myAgents-app-api | 8766 |
| myDisplay-app-api | 8765 |
| myWidgets-app-api | 8773 |

Hosts: `myui` · `myagents` · `mywidgets` · `mydisplay` · `mydownloads` · `myguns` · `tempui`.lauer.team

## Checkliste

```bash
docker ps
curl -sS http://127.0.0.1:8820/api/health
curl -sS https://myui.lauer.team/api/health
```

## Verboten

| ❌ | Stattdessen |
|---|-------------|
| `git pull` + `--build` auf Staging/Prod | Pfad B: Tag in `.env` + `pull && up -d --no-build` |
| `.env` Host→Host kopieren | je Host eigene Secrets |
| Projekt-`production/` auf Hetzner | Live nur Netcup |
| `:latest` / `:local` | voller SHA (`principles.md` §3.5) |

## Rollback

| Wo | Wie |
|----|-----|
| Development | vorheriger Commit im Repo + `--build` |
| Staging / Production | vorheriges SHA in `.env` + `compose pull && up -d --no-build` |

## Verwandt

- `ghcr-publish.md` · `sven-agent-setup.md` · `incident-response.md`
- `brain/principles.md` §3.3 · ADR 0009
