# Skill: Post-Reboot-Check

> Nach VPS-Neustart prüfen, ob der Stack wieder läuft. Hosts nicht vermischen.

## Trigger

- User: „Server neu gestartet“, „Reboot-Check“, „läuft alles wieder?“
- Nach `sudo reboot`

## Voraussetzungen

| Host | Wer | SSH |
|------|-----|-----|
| **Hetzner** | dieser Cursor-Host — `development/` · `staging/` | lokal / Tailscale-Name **dieses** Hosts |
| **Netcup** | Production-Host — `production/` | Tailscale-Name **des Netcup-Hosts** |

Nicht denselben Tailscale-Namen als „prod“ für beide verwenden, wenn unklar.

Skript: `/opt/_server/production/repos/Server/scripts/post-reboot-check.sh`

## Schritte

### 1. Neustart nötig?

```bash
cat /var/run/reboot-required 2>/dev/null || echo "Kein Neustart nötig"
```

### 2. Check ausführen

```bash
/opt/_server/production/repos/Server/scripts/post-reboot-check.sh
```

### 3. Manuell prüfen

| Check | Befehl / URL |
|-------|----------------|
| Docker | `docker ps` — Caddy, Domain-APIs, App-APIs |
| myUI BFF | `curl -s http://127.0.0.1:8820/api/health` |
| Cockpit | `curl -s https://myui.lauer.team/api/health` |
| Tailscale | `tailscale status` |
| Sven (Hetzner Staging) | `docker compose -f /opt/Azubuilder/Apps/myAgentsApp/staging/docker-compose.yml --env-file /opt/Azubuilder/Apps/myAgentsApp/staging/.env ps` |

Netcup: analog `…/myAgentsApp/production/docker-compose.yml` + `--env-file …/production/.env`.

### 4. Bei Fehlern

**Hetzner:**

```bash
cd /opt/Azubuilder/Apps/myUIApp/development/repos/myUI-app-api && docker compose --env-file ../../.env up -d
cd /opt/Azubuilder/Apps/myAgentsApp/staging && docker compose --env-file .env up -d --no-build
cd /opt/_server/production/repos/Server && docker compose -f docker-compose.yml -f docker-compose.hetzner.yml up -d
```

**Netcup:**

```bash
cd /opt/Azubuilder/Apps/myUIApp/production && docker compose --env-file .env up -d --no-build
cd /opt/_server/production/repos/Server && docker compose up -d
```

## Erfolgskriterium

HTTPS erreichbar, BFF/Domain-APIs `ok`, relevante Container `Up`.

## Rollback

| Problem | Lösung |
|---------|--------|
| Container startet nicht | `docker compose logs <service>`; ggf. `up -d --force-recreate` (Staging/Prod: `--no-build`) |
| Tailscale offline | `ensure-tailscale-up.sh` — `tailscale-authkey.md` |
| Sven down | `sven-agent-setup.md` (Compose `myagents-app-telegram`, kein systemd-Default) |

## Verwandt

- `incident-response.md` · `ssl-troubleshooting-caddy.md` · `vps-deploy.md`
