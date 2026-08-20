# Skill: Server-Update (deploy → VPS)

> 🤖 AI-assisted — Einheitlicher Flow: `../Server/` (Runtime) → `/home/jjl/projects/Server/`, myOS-Repo → `/home/jjl/projects/myOS/`.

## Trigger

- User sagt: „Server updaten“, „deploy syncen“, „Änderungen auf VPS bringen“
- Nach Änderungen an `../Server/docker-compose.yml`, Caddyfile, Scripts, `SvenAgent/`, `www/`
- Vor größeren n8n-Änderungen: optional Backup — Skill `Skills/backup-postgres.md`

## Voraussetzungen

- Mac mit diesem Repo und SSH-Key: `~/.ssh/id_ed25519_hetzner`
- **Tailscale auf dem Mac aktiv**
- Server: `jjl@jjl-server-prod-01.tailbbda14.ts.net`, Stack unter `/home/jjl/projects/Server/`
- **Nie überschreiben:** `.env`, `.secrets/`, `SvenAgent/config.json`, `backups/`

## Was wohin?

| Quelle (Mac-Repo) | Ziel (Server) | Hinweis |
|-------------------|---------------|---------|
| `../Server/docker-compose.yml` | `/home/jjl/projects/Server/docker-compose.yml` | Danach oft `docker compose up -d` |
| `../Server/caddy/` | `/home/jjl/projects/Server/caddy/` | Caddy-Container liest Volume |
| `../Server/www/` | `/home/jjl/projects/Server/www/` | https://server.lauer.team |
| `../Server/scripts/` | `/home/jjl/projects/Server/scripts/` | u. a. `post-reboot-check.sh`, `migrate-sven-systemd.sh`, `setup-server-docs-git.sh` |
| `../SvenAgent/` | `/home/jjl/projects/SvenAgent/` | **ohne** `config.json`, `.venv/` |
| `../N8nWorkflows/` | `/home/jjl/projects/N8nWorkflows/` | JSON importieren in n8n UI |
| Git-Repo (push vom Mac) | `/home/jjl/projects/myOS/` | **Auto:** cron `sync-docs-auto.sh` (alle 5 Min) — siehe `Skills/docs-sync.md` |

**Drift vermeiden:** Wenn du nur lokal in `../Server/` (Runtime) änderst, ist der Server veraltet bis du diesen Skill ausführst.

---

## Schnellweg (empfohlen)

Vom Mac, im Repo:

```bash
chmod +x ../Server/scripts/projects-sync.sh   # einmalig

# Standard: Runtime (rsync) + Docs (git pull)
./../Server/scripts/projects-sync.sh

# Docs erzwingen per rsync (Fallback)
./../Server/scripts/projects-sync.sh --rsync-docs

# Mit Neustart nach Docker- oder Sven-Änderung
./../Server/scripts/projects-sync.sh --restart-docker
./../Server/scripts/projects-sync.sh --restart-sven
./../Server/scripts/projects-sync.sh --restart-docker --restart-sven
```

Nur Docs (manuell, falls Auto-Sync pausiert):

```bash
./../Server/scripts/projects-sync.sh --docs-only
# oder: ./../Server/scripts/sync-docs-mac-pull.sh  (Mac)
# oder: ssh … '/home/jjl/projects/Server/scripts/sync-docs-auto.sh'  (Server)
```

**Normal:** Docs syncen automatisch — Skill `Skills/docs-sync.md`.

Nur Runtime (Docker, Caddy, Bots):

```bash
./../Server/scripts/projects-sync.sh --runtime-only
```

---

## Manuell (falls Skript nicht geht)

### 1. Runtime syncen

```bash
SERVER="jjl@jjl-server-prod-01.tailbbda14.ts.net"
KEY="$HOME/.ssh/id_ed25519_hetzner"
RS='rsync -avz -e "ssh -i '"$KEY"'"'

eval $RS ../Server/docker-compose.yml $SERVER:/home/jjl/projects/Server/
eval $RS ../Server/caddy/ $SERVER:/home/jjl/projects/Server/caddy/
eval $RS ../Server/www/ $SERVER:/home/jjl/projects/Server/www/
eval $RS ../Server/scripts/ $SERVER:/home/jjl/projects/Server/scripts/ --exclude projects-sync.sh
eval $RS ../SvenAgent/ $SERVER:/home/jjl/projects/SvenAgent/ \
  --exclude config.json --exclude .venv/ --exclude __pycache__/
eval $RS ../N8nWorkflows/ $SERVER:/home/jjl/projects/N8nWorkflows/
```

### 2. myOS syncen

```bash
rsync -avz -e "ssh -i $KEY" \
  --exclude '.git' --exclude '.env' --exclude 'deploy/.secrets/' --exclude 'backups/' \
  "./" jjl@jjl-server-prod-01.tailbbda14.ts.net:/home/jjl/projects/myOS/
```

(Pfad `"./"` = Repo-Wurzel auf dem Mac.)

### 3. Dienste anwenden

**Docker-Stack** (Compose, Caddy, n8n):

```bash
ssh -i $KEY jjl@jjl-server-prod-01.tailbbda14.ts.net 'cd /home/jjl/projects/Server && docker compose up -d'
docker compose ps   # auf dem Server
```

**Sven** nach `bot.py`-Änderung:

```bash
# system-weit (Ziel-Setup, wie Kalle):
sudo systemctl restart SvenAgent

# oder aktuell user systemd:
systemctl --user restart SvenAgent
```

**KiezQuiz-Ops (Kalle)** — Bot + Ops nach Änderungen in `KiezQuiz-Ops/`:

```bash
cd ~/projects/Server
./scripts/projects-sync.sh --kiezquiz-ops --restart-kalle
# oder manuell auf dem Server:
sudo systemctl restart kiezquiz-agent
```

### 4. n8n-Workflows

JSON in `/home/jjl/projects/N8nWorkflows/` sind **Vorlagen**. Nach Sync:

1. n8n UI → Workflow importieren oder Nodes manuell anpassen
2. Credentials prüfen
3. **Publish** toggeln

---

## Checkliste nach Update

```bash
ssh -i ~/.ssh/id_ed25519_hetzner jjl@jjl-server-prod-01.tailbbda14.ts.net

cd /home/jjl/projects/Server && docker compose ps          # postgres, n8n, caddy: Up
curl -sI https://server.lauer.team | head -1
curl -sI https://n8n.server.lauer.team | head -1

# Sven — je nach Setup:
sudo systemctl status SvenAgent --no-pager
# oder: systemctl --user status SvenAgent

sudo systemctl status kiezquiz-agent --no-pager
```

Telegram (User): `/help` an `@jjl_sven_bot`, ggf. `/restart`.

---

## Optional: Sven auf system-weites systemd (wie Kalle)

**Stand 2026-06-16:** ✅ system-weit unter `/etc/systemd/system/SvenAgent.service`.

Logs: `sudo journalctl -u SvenAgent -f`

---

## Erfolgskriterium

- [ ] `../Server/scripts/projects-sync.sh` lief ohne Fehler
- [ ] `/home/jjl/projects/myOS/Todos/vps-hub-live.md` auf Server ≈ Mac-Stand
- [ ] `docker compose ps` — alle Container **Up**
- [ ] HTTPS erreichbar; Sven/Kalle antworten in Telegram
- [ ] Keine `.env` / Secrets vom Mac überschrieben

## Rollback

| Problem | Lösung |
|---------|--------|
| Site/n8n down | `docker compose logs`, ggf. alte `docker-compose.yml` aus Backup |
| Sven kaputt | Vorherige `bot.py` aus Git/rsync-Backup; `systemctl restart SvenAgent` |
| DB-Probleme nach Compose-Change | Restore — `Skills/backup-postgres.md` |
| Falsche Datei überschrieben | Server hat Hetzner-Snapshot (So 04:00) |

## Verwandte Dateien

- `Todos/vps-hub-live.md` — Live-Stand
- `Todos/server-setup-plan.md` — Phase 8 (erster rsync)
- `Todos/aios-aktivierung.md` — Git + Remote (Alternative zu rsync für `docs/`)
- `Skills/backup-postgres.md` — Backup vor großen Updates
- `Skills/sven-agent-setup.md` — Sven systemd Varianten
- `Skills/docs-sync.md` — Zwei-Wege Auto-Sync Docs
