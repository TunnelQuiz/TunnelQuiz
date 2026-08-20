# Skill: Incident Response (VPS / Production)

> Erst stabilisieren, dann Ursache. Hosts trennen: **Hetzner** = dieser Cursor-Host (`development`/`staging`). **Netcup** = Production-Host (`production/`).

## Trigger

- User: „alles down“, „Production kaputt“, „Notfall“, „Cockpit geht nicht“
- Health-Checks fehl, Bots still, HTTPS tot, fehlgeschlagenes Deploy

## Voraussetzungen

- SSH auf den **betroffenen** Host (Hetzner-Konsole bzw. Netcup-Konsole, wenn Tailscale ausfällt)
- Keine destruktiven Aktionen ohne Backup — `brain/principles.md` §0.6

## Schritte

### 1. Scope klären (30 Sekunden)

| Frage | Wo / Befehl |
|-------|-------------|
| Welcher Host? | Hetzner = Arbeit · Netcup = Live — nicht denselben Tailscale-Namen als „prod“ verwenden, wenn unklar |
| SSH? | auf dem betroffenen Host einloggen |
| Tailscale? | `tailscale status` |
| Caddy / Cockpit? | `curl -skI https://myui.lauer.team/api/health` |

TLS ≠ App — getrennt debuggen (`ssl-troubleshooting-caddy.md`).

### 2. Schweregrad

| Stufe | Merkmale | Priorität |
|-------|----------|-----------|
| **S1** | Kein SSH, kein Tailscale | Web-Konsole des **betroffenen** Anbieters → `ensure-tailscale-up.sh` |
| **S2** | SSH ok, HTTPS/API down | Caddy + Container |
| **S3** | API ok, ein Bot/Projekt down | Projekt-Compose (Dev `--build` · Staging/Prod image-only) |
| **S4** | Alles läuft, Daten falsch | DB/Restore, kein blindes `rm` |

### 3. Standard-Recovery (Host trennen)

**Plattform (beide Hosts, Git-Klon):**

```bash
/opt/_server/production/repos/Server/scripts/post-reboot-check.sh
bash /opt/_server/production/repos/Server/scripts/ensure-tailscale-up.sh
cd /opt/_server/production/repos/Server
# Hetzner:
docker compose -f docker-compose.yml -f docker-compose.hetzner.yml up -d
# Netcup: ohne hetzner-overlay
```

**Hetzner — Arbeit (development, Repos):**

```bash
cd /opt/Azubuilder/Apps/myUIApp/development/repos/myUI-app-api
docker compose --env-file ../../.env up -d --build
curl -s http://127.0.0.1:8820/api/health
```

**Hetzner — Staging (image-only, kein `repos/`):**

```bash
cd /opt/Azubuilder/Apps/myAgentsApp/staging
docker compose --env-file .env ps
docker compose --env-file .env up -d --no-build
```

**Netcup — Production (image-only):**

```bash
cd /opt/Azubuilder/Apps/myUIApp/production
docker compose --env-file .env pull
docker compose --env-file .env up -d --no-build
```

Vollständiger Reboot-Check: `post-reboot-check.md`

### 4. Logs sammeln

```bash
cd /opt/_server/production/repos/Server && docker compose logs caddy --tail 100
# Hetzner Dev:
cd /opt/Azubuilder/Apps/myUIApp/development/repos/myUI-app-api && docker compose --env-file ../../.env logs --tail 100
# Hetzner Staging:
cd /opt/Azubuilder/Apps/myAgentsApp/staging && docker compose --env-file .env logs --tail 50
# Netcup Prod: analog unter …/production mit --env-file .env
tail -30 /opt/_server/production/data/files/logs/post-reboot-check.log
```

### 5. Daten-Incidents (DB, Dateien)

**Nicht:** Volume löschen, `.env` überschreiben, `docker compose down -v`.

1. Letzten Dump: `ls -lt /opt/_backups/db-dumps/ | head`
2. Restore gezielt — `backup-postgres.md` / `backup-system.md`
3. Dateiverlust: Restic — `_server/…/docs/BACKUP.md`

Live-Daten = **Netcup** `production/data/`. Hetzner = Dummy.

### 6. Nach Deploy kaputt

| Host | Rollback |
|------|----------|
| **Netcup Production** | vorheriges SHA-Tag in `.env` → `docker compose --env-file .env pull && docker compose --env-file .env up -d --no-build` |
| **Hetzner Staging** | gleich (image-only) |
| **Hetzner Development** | `git checkout <guter-commit>` im **Repo** + `up -d --build` |
| **Plattform `_server`** | `git checkout` im Server-Repo + Compose up |

**Verboten auf Production/Staging:** `git checkout` von App-Code + `--build` (kein Source-Tree).

### 7. Kommunikation

- User: **Was down · Was getan · Was noch offen**
- Optional Todo: `https://myui.lauer.team/api/reminders` oder Sven `/todo`

### 8. Eskalation

| Situation | Aktion |
|-----------|--------|
| SSH + Tailscale tot | Web-Konsole **Hetzner oder Netcup** (je nach Host) |
| Daten korrupt | Restore aus Backup, **nicht** raten |
| Unklar nach 30 Min | Snapshot des betroffenen Hosts (`backup-system.md`) |
| Security-Verdacht | Secrets rotieren (Token, DB-Passwort, Telegram) |

## Erfolgskriterium

- `curl -s https://myui.lauer.team/api/health` grün
- `post-reboot-check.sh` ohne FAIL
- Betroffene Funktion manuell getestet (Web, Telegram)

## Rollback

| Problem | Lösung |
|---------|--------|
| Image-Deploy schlecht | SHA in `.env` zurück + `pull && up -d --no-build` |
| Dev-Build schlecht | Git-Stand im Repo + `--build` |
| DB-Restore | Dump — nur nach User-Freigabe bei Datenverlust-Risiko |
| Host komplett kaputt | `vps-provider-migration.md` / Anbieter-Snapshot |

## Verwandt

| Skill | Wann |
|-------|------|
| `post-reboot-check.md` | Nach Reboot |
| `ssl-troubleshooting-caddy.md` | Nur HTTPS/Zertifikat |
| `vps-deploy.md` | Deploy-Modell |
| `backup-system.md` | Restore / Snapshots |
